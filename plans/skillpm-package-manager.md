# Plan: `skillpm` — Agent Skills Package Manager

## Context

The Agent Skills spec at `/home/user/agentskills` defines a portable format
(`SKILL.md` + `scripts/|references/|assets/`) and ships a Python reference
library (`skills-ref/`) that validates skills and emits the `<available_skills>`
XML block. What it does **not** provide is a way to *find*, *install*, *pin*,
*update*, or *recommend* skills from project to project. Today users hand-copy
skill folders into `.claude/skills/` or `.agents/skills/`, which doesn't scale.

`skillpm` fills that gap: a single static CLI — installable via Homebrew / apt /
Scoop / winget — that detects the project's tech stack and goal, recommends
skills with a clear rationale, pins them in a lockfile, and keeps them updated.
No central server; the registry is a static, git-hosted JSON index, with a
direct-URL escape hatch for unlisted skills.

Chosen constraints from prior discussion:
- **Stack**: Rust + `clap` (static binary, easy cross-compile and packaging).
- **Registry**: Hybrid — central git-hosted index plus `github:owner/repo@tag`.
- **API**: `npm`/`cargo`-style subcommands.
- **Day-one detection**: JVM (Maven/Gradle/Spring Boot) and Node/TS.
- **No service**: all state is files; all network I/O is `GET` against
  `raw.githubusercontent.com` / GitHub Releases.

## Use cases

1. **Bootstrap a new project.** A developer runs `skillpm init` in a Spring
   Boot repo. The CLI reads `pom.xml`, spots `spring-boot-starter-web` and
   `spring-boot-starter-test`, asks one goal question ("api / library /
   cli / data-pipeline"), and proposes five relevant skills with a short
   *why* line each. Selected skills are installed to `.agents/skills/` and
   pinned in `skillpm.lock`.
2. **Onboarding a teammate.** Teammate clones the repo, runs `skillpm install`
   (no args) → reads the lockfile, fetches and verifies exactly the same
   skill versions. Byte-identical skill set across the team.
3. **Keeping skills fresh.** `skillpm update` shows a semver diff and the
   skill's `CHANGELOG` excerpt for each upgrade; user can accept selectively.
   Previous versions stay in `.skillpm/cache/` for instant `skillpm rollback`.
4. **Searching.** `skillpm search postgres migrations` ranks registry entries
   by description match; `skillpm why <skill>` explains the match against the
   current project profile.
5. **Ad-hoc install.** `skillpm install github:acme/pdf-skill@v1.3.0` pulls a
   skill from any GitHub repo without it being in the central index — useful
   for private/org skills.
6. **CI reproducibility.** `skillpm install --frozen-lockfile` in CI fails if
   the lockfile is stale. Matches `npm ci` / `cargo --locked` semantics.
7. **Pruning.** After removing a framework, `skillpm prune` proposes removing
   skills whose detected stack is no longer present; nothing auto-deleted.
8. **Auditing.** `skillpm list --explain` prints installed skills with the
   reason they were selected (stack tokens + goal tokens matched). Feeds code
   review / onboarding docs.

## Repo layout — recommendation

Rust code does not belong in this Python/Mintlify-shaped repo. Recommendation:

- **`skillpm` CLI**: new standalone repo (`fabapp2/skillpm`), Rust workspace.
- **Central registry**: new standalone repo (`fabapp2/skillpm-registry`),
  JSON-only, no code.
- **This repo (`agentskills`)**: add a single docs page describing `skillpm`
  and linking out. No Rust code here.

If the user prefers everything in one place, a `skillpm/` subdirectory here
works — but adds Cargo + CI complexity to a docs repo. Worth avoiding.

## CLI API surface

```
skillpm init                      # interactive: detect + goal prompt + install
skillpm detect                    # print ProjectProfile as JSON
skillpm search <terms...>         # BM25 rank against registry descriptions
skillpm recommend                 # detect + list top N with rationale (no install)
skillpm install                   # from lockfile
skillpm install <name>[@version]  # central-index install
skillpm install github:<o>/<r>[@<ref>]   # direct-URL install
skillpm update [<name>...]        # show semver diff + changelog, prompt per skill
skillpm remove <name>             # uninstall + lockfile update
skillpm list [--explain]          # show installed skills (+ why)
skillpm why <name>                # explain selection vs. current profile
skillpm prune                     # propose removing orphaned skills
skillpm rollback <name>           # restore previous version from .skillpm/cache/
skillpm validate [<path>]         # reuse skills-ref rules (port to Rust)
```

Global flags: `--frozen-lockfile`, `--global` (install to
`~/.agents/skills/`), `--registry <url>`, `--offline`, `--json`, `-y`.

## Detection strategy (day one)

`ProjectProfile { stacks: Vec<String>, frameworks: Vec<String>,
goals: Vec<String>, confidence: f32 }`

- **JVM**
  - `pom.xml` — parse `<dependencies>` groupId/artifactId. Spring Boot
    starters (`spring-boot-starter-*`) → `spring-boot` + sub-frameworks
    (`web`, `data-jpa`, `security`, `webflux`).
  - `build.gradle` / `build.gradle.kts` — regex over `implementation(...)`
    lines; same starter mapping.
  - `application.yml` / `application.properties` — presence strengthens
    Spring Boot signal.
- **Node/TS**
  - `package.json` — `dependencies` + `devDependencies`. Framework hints:
    `next` → nextjs, `vite` → vite, `@nestjs/core` → nest, `express` →
    express, `react`, `vue`, `svelte`.
  - `tsconfig.json` present → add `typescript`.
  - `next.config.*`, `vite.config.*`, `nest-cli.json` boost confidence.
- **Goal prompt** — one question asked by `skillpm init`: `api | webapp |
  library | cli | data-pipeline | infra | mobile` (multi-select). Token
  weight higher than static detection in ranking.

Parsers via `serde_json`, `toml`, `quick-xml`, `serde_yaml`. All detectors
implement a `trait StackDetector { fn detect(&self, root: &Path) ->
Option<StackSignal>; }` so adding Python/Go/Rust later is mechanical.

## Recommendation engine

Two stages against the registry index:

1. **Hard filter** — registry entry's `compatibility` and `stacks` must
   overlap with `ProjectProfile.stacks`. Rules from skills-ref mirrored.
2. **Soft rank** — BM25 on `description` field against stack + goal
   tokens. Library: `tantivy` in-memory, or a lighter hand-rolled BM25
   (`~120 LoC`, no index file) given the expected small corpus.

Every ranked entry carries an **explanation** built from the matched tokens
and the registry's structured fields:

```
pdf-processing @ 2.1.0
  Why: matched stack=[nodejs], goal=[api]; description mentions "pdf",
       "extract", "forms"
  What: Extract PDF text, fill forms, merge files.
```

Shown by `recommend`, `why`, `init`, and `list --explain`.

## Registry schema

Central index: `https://raw.githubusercontent.com/fabapp2/skillpm-registry/main/index.json`

```json
{
  "schemaVersion": 1,
  "skills": [
    {
      "name": "pdf-processing",
      "summary": "Extract PDF text, fill forms, merge files.",
      "stacks": ["python", "nodejs"],
      "goals": ["data-pipeline", "api"],
      "source": { "kind": "github", "repo": "acme/pdf-skill", "path": "" },
      "versions": [
        {
          "version": "2.1.0",
          "ref": "v2.1.0",
          "sha256": "…",
          "compatibility": "",
          "changelog": "Fix form field encoding."
        }
      ]
    }
  ]
}
```

The CLI caches `index.json` with an `ETag` + 1h TTL in
`~/.cache/skillpm/index.json`.

## Lockfile

`skillpm.lock` (TOML, git-tracked):

```toml
schema_version = 1

[[skill]]
name    = "pdf-processing"
version = "2.1.0"
source  = "registry"
repo    = "acme/pdf-skill"
ref     = "v2.1.0"
sha256  = "…"
reasons = ["stack:nodejs", "goal:api", "description:pdf"]
```

`install` verifies `sha256` before extracting into `.agents/skills/<name>/`.

## Versioning

- **Skill authors** publish SemVer tags; version surfaces in
  `SKILL.md` frontmatter as `metadata.version` (already spec-supported)
  *and* in the registry entry's `versions[].version`.
- **Registry entry shape** is versioned via `schemaVersion`.
- **Lockfile** pins exact versions + content hash, giving reproducibility.
- `skillpm update` shows `2.0.3 → 2.1.0 (minor)` with the `changelog`
  string from the registry.

## Rust project structure

```
skillpm/
├── Cargo.toml                 # workspace
├── crates/
│   ├── skillpm-cli/           # clap entrypoint, thin
│   ├── skillpm-core/          # ProjectProfile, lockfile, install engine
│   ├── skillpm-spec/          # port of skills-ref validator + parser
│   ├── skillpm-detect/        # StackDetector impls (JVM, Node/TS)
│   ├── skillpm-registry/      # index fetch + BM25 rank
│   └── skillpm-github/        # GitHub Releases / raw.githubusercontent fetch
├── xtask/                     # release packaging (Homebrew formula, deb, etc.)
└── .github/workflows/         # build matrix: macos-{x64,arm64}, linux-{x64,arm64}, windows-x64
```

The **`skillpm-spec` crate is the direct port** of:
- `skills-ref/src/skills_ref/parser.py` → `parser.rs`
- `skills-ref/src/skills_ref/validator.py` → `validator.rs`
  (mirror every rule from the Python validator exactly; the Python test
  fixtures in `skills-ref/tests/` are the conformance suite — port them to
  `#[test]` Rust unit tests first to lock parity).
- `skills-ref/src/skills_ref/prompt.py` → `prompt.rs` (emit identical
  `<available_skills>` XML; HTML-escape bodies).
- `skills-ref/src/skills_ref/errors.py` → `error.rs` (`thiserror`).

Result: any skill validated by `skills-ref` is validated by `skillpm`.

## Changes in `agentskills` (this repo)

**Only a docs change here — no Rust lands in this repo.**

1. Add `docs/package-management.mdx` describing `skillpm`: what it does,
   install command, quick-start, link to the standalone repo.
2. Update `docs/docs.json` — add a new navigation group "Package management"
   containing the new page.
3. Update `docs/home.mdx` "Get started" `CardGroup` with one card pointing
   at the new page.

No changes to `skills-ref/` (it stays the canonical Python reference).

## Critical files

Read-only / reference:
- `/home/user/agentskills/skills-ref/src/skills_ref/validator.py` — rules to
  port.
- `/home/user/agentskills/skills-ref/src/skills_ref/parser.py` — frontmatter
  behavior to mirror.
- `/home/user/agentskills/skills-ref/src/skills_ref/prompt.py` — XML output
  format to match.
- `/home/user/agentskills/skills-ref/tests/` — conformance fixtures to
  port.
- `/home/user/agentskills/docs/specification.mdx` — field constraints.
- `/home/user/agentskills/docs/client-implementation/adding-skills-support.mdx`
  — install directories (`~/.agents/skills/`, `.agents/skills/`,
  `.claude/skills/`) and precedence rules.

To be created (in this repo only):
- `/home/user/agentskills/docs/package-management.mdx` — new page.
- `/home/user/agentskills/docs/docs.json` — nav update.
- `/home/user/agentskills/docs/home.mdx` — card update.

Separate repo (`fabapp2/skillpm`): Rust workspace per structure above.
Separate repo (`fabapp2/skillpm-registry`): `index.json` only.

## Verification

Once implemented:

1. **Docs**: `cd docs && npx mint dev` — confirm the new page renders and is
   reachable from the home page and the nav.
2. **Spec parity (in skillpm repo)**: port `skills-ref/tests/` fixtures to
   Rust unit tests; `cargo test -p skillpm-spec` must pass for every
   fixture. CI job reruns the Python `skills-ref validate` alongside the
   Rust `skillpm validate` on the same fixture set and diffs the output.
3. **Detection golden tests**: fixture projects in
   `crates/skillpm-detect/tests/fixtures/` (a minimal Spring Boot Maven
   project, a Next.js `package.json`, a Gradle Kotlin DSL file). Assert
   `ProjectProfile` matches a checked-in expected JSON.
4. **End-to-end smoke**: `skillpm init` in each fixture project —
   non-interactive via `--goal api -y --registry
   file://$(pwd)/test-registry/index.json`; assert `.agents/skills/`
   contains the expected skill folders and `skillpm.lock` matches a
   golden file.
5. **Packaging**: `xtask dist` produces tarballs for all target triples;
   a smoke job installs via Homebrew formula on macOS runner and runs
   `skillpm --version`.
6. **Reproducibility**: `skillpm install --frozen-lockfile` on a clean
   checkout yields byte-identical `.agents/skills/` trees across OSes
   (compare sha256 of each file).

## Out of scope (explicitly not in this plan)

- Any server component, web UI, or auth.
- Private registries (can be added later via `--registry` pointing at a
  file:// or https:// URL; no code change needed).
- GPG signing of releases — rely on per-version `sha256` in the index
  and GitHub's commit signing for now.
- LLM-assisted ranking — BM25 + structured filters are enough for v1.
- Auto-applying updates — always interactive unless `-y`.

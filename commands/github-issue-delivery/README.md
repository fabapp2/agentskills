# github-issue-delivery

A disciplined, role-based workflow for delivering GitHub issues end-to-end: read and clarify the issue, analyze the repo, plan, implement with XP-style pair engineering, add user-facing tests, run a mandatory review loop, perform security analysis (and authorized adversarial testing where applicable), and produce a sprint-review demo.

## Layout

```
github-issue-delivery/
├── README.md                       ← you are here
├── PROCEDURE.md                    ← canonical workflow (consumer-neutral)
├── team-roles.md                   ← role definitions and subagent brief format
├── log-formats.md                  ← entry formats for progress and decision logs
├── github-issue-templates.md       ← issue comment templates
├── log-templates/                  ← starter files for the six artifacts
├── scripts/                        ← helper scripts
│   ├── init-artifacts.sh
│   ├── append-progress.sh
│   ├── archive-current-state.sh
│   └── load-issues.sh
└── deliver-issue.md                ← Claude Code slash command wrapper
```

`PROCEDURE.md` is the canonical, agent-neutral procedure. Other clients can ingest it directly.

## Install for Claude Code

Copy or symlink the entire `github-issue-delivery/` directory into your project's `.claude/commands/`:

```bash
# From the root of the project where you want to use the command:
mkdir -p .claude/commands
cp -r /path/to/this/github-issue-delivery .claude/commands/

# Or, if you want to track upstream updates, symlink instead:
ln -s /path/to/this/github-issue-delivery .claude/commands/github-issue-delivery
```

The command will be available as `/github-issue-delivery:deliver-issue` (Claude Code namespaces commands placed in subdirectories).

If you prefer the bare name `/deliver-issue`, also symlink the wrapper file to the top of `.claude/commands/`:

```bash
ln -s github-issue-delivery/deliver-issue.md .claude/commands/deliver-issue.md
```

The wrapper resolves all paths against `.claude/commands/github-issue-delivery/...`, so this works regardless of which symlink you invoke.

### Verify install

From your project root:

```bash
# Inline-load syntax used by the wrapper:
.claude/commands/github-issue-delivery/scripts/load-issues.sh

# Should print "(no issue numbers passed; …)" — that's the expected
# fallback when called with no args.
```

## Usage

```
/deliver-issue 42
/deliver-issue 42 43 44
```

Pass one or more issue numbers as arguments. The wrapper:

1. Pre-loads repo state (branch + working tree) inline.
2. Pre-loads each issue's title, state, labels, body, and comments via `gh` (or prints a fallback message if `gh` is unavailable).
3. Tells the orchestrator agent to follow `PROCEDURE.md` from step 1 to step 12.

The agent will create artifacts under `.claude/issue-delivery/` (configurable — see `PROCEDURE.md` "Mandatory artifacts").

## Use from other agents

`PROCEDURE.md` is consumer-neutral. To run the workflow with a non-Claude-Code client:

1. Have the agent read `PROCEDURE.md`, `team-roles.md`, and the supporting docs as context.
2. Have the agent run `scripts/init-artifacts.sh .claude/issue-delivery` to create the artifact files.
3. Have the agent execute the 12-step procedure, calling `scripts/append-progress.sh` and `scripts/archive-current-state.sh` as instructed.
4. Issue loading is straightforward via `gh issue view <N>` or the agent's own GitHub integration.

The procedure does not depend on any Claude-Code-specific feature beyond what the wrapper provides; everything in `PROCEDURE.md` is plain Markdown plus shell helpers.

## Requirements

- `bash`
- `git`
- `gh` (GitHub CLI) authenticated to the repo — required for issue loading and comment posting
- `jq` — used by the GitHub CLI templates internally; not strictly required

## License

Apache-2.0 (matches the parent repository).

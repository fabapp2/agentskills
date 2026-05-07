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

The wrapper file (`deliver-issue.md`) goes under `.claude/commands/` so Claude Code registers it as a slash command. **Everything else** — `PROCEDURE.md`, `team-roles.md`, `scripts/`, `log-templates/`, etc. — must live **outside** `.claude/commands/`, because Claude Code registers every Markdown file under that tree as a separate command. The wrapper expects the support tree at `.claude/github-issue-delivery/`.

### Install steps

```bash
# From the root of the project where you want to use the command.
mkdir -p .claude/commands

# 1. Install the support tree at .claude/github-issue-delivery/
cp -r /path/to/this/github-issue-delivery .claude/github-issue-delivery
# Or symlink to track upstream updates:
#   ln -s /path/to/this/github-issue-delivery .claude/github-issue-delivery

# 2. Place the wrapper under .claude/commands/ so Claude Code sees the
#    slash command. Symlink (preferred — single source of truth):
ln -s ../github-issue-delivery/deliver-issue.md .claude/commands/deliver-issue.md
# Or copy if you can't symlink:
#   cp .claude/github-issue-delivery/deliver-issue.md .claude/commands/deliver-issue.md
```

The command is available as `/deliver-issue`.

### Verify install

From the project root:

```bash
# Should print "(no issue numbers passed; …)":
.claude/github-issue-delivery/scripts/load-issues.sh

# Should show only `/deliver-issue` from this command (plus your other
# commands, if any) — NOT every .md file in the support tree:
ls .claude/commands/
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

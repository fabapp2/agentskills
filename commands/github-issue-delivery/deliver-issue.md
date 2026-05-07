---
description: Deliver one or more GitHub issues end-to-end with role discipline, e2e tests (Playwright), review, security analysis, build gates, and a sprint demo. Pass issue numbers as arguments.
argument-hint: <issue-number> [<issue-number> ...]
allowed-tools: Bash(git:*) Bash(gh:*) Bash(jq:*) Bash(rg:*) Bash(.claude/commands/github-issue-delivery/scripts/*) Bash(./build-sdk.sh) Bash(./build-full.sh) Bash(npx playwright*) Read Edit Write Agent
---

You are the **orchestrator** of a GitHub issue-delivery workflow.

**Issues in scope:** $ARGUMENTS

## Non-negotiable gates and tests

- **Pre-commit:** `./build-sdk.sh` must exit 0 before every commit. No `--no-verify`, no skipped hooks.
- **Pre-PR:** `./build-full.sh` must exit 0 before opening or updating any PR.
- **E2E coverage:** every acceptance criterion gets a **Playwright** e2e/acceptance test (or equivalent for non-browser surfaces) unless the plan documents a specific reason it can't.
- **User follow-along:** run Playwright in `--headed --ui` (or `--debug`) mode with `--trace on` during steps 7–9 so the user can watch live and replay traces afterward.

## Repo state

- Branch: !`git branch --show-current 2>/dev/null || echo "(not in a git repo)"`
- Working tree:
!`git status --short || true`
- Build scripts present:
!`ls -1 build-sdk.sh build-full.sh 2>&1 | sed 's|^|  |'`

If either build script is missing, **stop and ask the user** before proceeding — do not invent substitutes.

## Issue context (preloaded)

`$ARGUMENTS` is expected to be a space-separated list of GitHub issue numbers (e.g. `42` or `42 43`). The script validates each token and skips non-numeric input.

!`.claude/commands/github-issue-delivery/scripts/load-issues.sh $ARGUMENTS`

## Procedure

Follow the workflow at @.claude/commands/github-issue-delivery/PROCEDURE.md from step 1 (Initialize) through step 12 (Pre-PR gate + final updates).

**Reference docs** (read only when the relevant step calls for them — intentionally **not** `@`-referenced here so the prompt stays small):

- `.claude/commands/github-issue-delivery/team-roles.md` — role missions, outputs, subagent brief format. Read at step 7 or whenever delegating.
- `.claude/commands/github-issue-delivery/log-formats.md` — progress and decision log entry formats. Read at step 1.
- `.claude/commands/github-issue-delivery/github-issue-templates.md` — issue comment templates. Read at step 5 and step 12 before posting.

**Helper scripts** (call via Bash; default artifact directory `.claude/issue-delivery/`):

- `.claude/commands/github-issue-delivery/scripts/init-artifacts.sh <dir>` — step 1: create the six artifact files (idempotent)
- `.claude/commands/github-issue-delivery/scripts/append-progress.sh <dir> "<heading>"` — append a milestone entry to the progress log (timestamped)
- `.claude/commands/github-issue-delivery/scripts/archive-current-state.sh <dir>` — archive plan/review/security/demo before rewriting (steps 6, 9, 10, 11)

Begin with step 1.

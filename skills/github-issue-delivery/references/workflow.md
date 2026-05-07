# Workflow detail

Per-step checklists and decision points for the 12-step delivery loop. The summary lives in `SKILL.md` — read this file when you need the full procedure for a step.

---

## Step 1 — Initialize state and logs

**Goal.** Make the work auditable from the start.

**Do.**

1. Confirm repo root (`pwd`, `git rev-parse --show-toplevel`).
2. `git status` and current branch (`git branch --show-current`).
3. Decide artifact directory: `.claude/issue-delivery/` by default, `.ai/issue-delivery/` if the repo already uses `.ai/`, or whatever the repo convention is. Log the choice in the decision log if it isn't the default.
4. Create the six artifact files if missing (templates: `assets/log-templates/`). Distinguish append-only logs (`progress-log.md`, `decision-log.md`) from current-state documents (the other four) — see `SKILL.md` "Mandatory artifacts".
5. **Append** an initial progress-log entry: timestamp, repo path, branch, issues in scope, current assumptions, `git status` summary.

**Do not.** Overwrite existing logs. If the user explicitly requested a clean run, archive the previous artifact directory under `archive/<YYYY-MM-DD-HHMM>/` first — never delete history.

---

## Step 2 — Read and analyze GitHub issues

**Owner.** product-owner.

**Do.**

1. Use the GitHub MCP tools if available; otherwise `gh issue view <N>`, `gh issue list`.
2. Read each issue's description, comments, labels, milestones, linked issues.
3. If specific issue numbers were provided, prioritize those; otherwise identify likely-relevant open issues and proceed unless scope is genuinely ambiguous.

**Extract per issue.**

- Number + title
- User problem
- Expected behavior
- Acceptance criteria
- Non-goals / implied scope limits
- Affected components
- Labels, priority, milestone, assignees
- Dependencies / linked issues
- Ambiguities / missing info
- Product risk level
- Candidate demo scenario

**Output.** Append issue analysis to `.claude/issue-delivery/progress-log.md`. Add product-scope decisions to the decision log when they matter.

---

## Step 3 — Repository and architecture analysis

**Owners.** architect, test-engineer, security-analyst (read-only — these can run in parallel).

**Do.**

1. Inspect: `README`, `CONTRIBUTING`, `CLAUDE.md`, `AGENTS.md`, architecture docs, package manifests, build files, CI config.
2. Map relevant modules, boundaries, APIs, data flow, configuration, conventions.
3. Identify likely files to change.
4. Capture test framework, test commands, build, lint, typecheck, format commands.
5. Identify trust boundaries, sensitive data flows, input surfaces, authn/authz, network boundaries, file handling, dependency risks.

**Output.** Append to `.claude/issue-delivery/implementation-plan.md`:

- Architecture summary
- Relevant files / modules
- Test + CI summary
- Verification command candidates
- Security and privacy notes
- Initial implementation constraints

---

## Step 4 — Clarify with the user (only if blocking)

**Owners.** orchestrator, product-owner; pull in architect or security-analyst when relevant.

**Ask only when** missing info blocks correct or safe implementation. Do not ask about anything that can be inferred from issues, repo conventions, tests, docs, product copy, or API behavior.

**When asking, include.**

1. A concise summary of your understanding.
2. Only the essential open questions.
3. A recommended default for each.
4. Which decisions block implementation and which assumptions you'll proceed on.

**When not asking.**

1. State the assumptions you'll proceed with.
2. Continue.

**Output.** Log the questions, defaults, and assumptions in `.claude/issue-delivery/progress-log.md`.

---

## Step 5 — Adjust GitHub issues after clarification

**Owners.** product-owner, orchestrator.

**Do.** Posting an issue comment is an externally visible action. Before posting, surface the proposed comment text to the user and get explicit confirmation. After confirmation, if GitHub write access is available, post a comment on each affected issue with: clarified acceptance criteria, scope/non-goals, dependencies, security considerations, demo scenarios. (Templates: `references/github-issue-templates.md`.)

**Do not.** Close issues unless the user explicitly asked or repo conventions clearly indicate it. Do not post the comment without a per-issue confirmation — a confirmation for one issue does not authorize comments on others.

**Fallback.** If no write access, write the proposed comment into `.claude/issue-delivery/implementation-plan.md` and log the limitation.

---

## Step 6 — Implementation planning

**Owners.** orchestrator + product-owner + architect + test-engineer + security-analyst.

**Plan must contain.**

- Objective
- Issue scope
- Product assumptions
- Acceptance criteria
- Demo scenarios
- Architecture approach
- Workstreams (each mapped to ≥1 acceptance criterion)
- XP pair-engineering plan
- Parallelization plan (independent slices only)
- Files likely to change
- Verification matrix (criterion → test → command)
- Tests to add/update — user-facing first, then unit
- Threat-model summary
- Pen-test scope (if applicable)
- Rollback plan
- Open risks

**Pause and re-clarify if.** The change is destructive, alters public APIs, performs data migrations, modifies authn/authz, or has unresolved product decisions.

**Output.** `.claude/issue-delivery/implementation-plan.md`. This is a current-state document: archive any previous version under `.claude/issue-delivery/archive/<YYYY-MM-DD-HHMM>/` before rewriting, then write the new plan.

---

## Step 7 — Execute implementation with XP pair

**Owners.** xp-driver + xp-navigator; test-engineer alongside; security-analyst on sensitive slices.

**Loop per slice.**

1. **Driver** implements a small vertical slice (prefer something demoable end-to-end).
2. **Navigator** reviews direction, acceptance alignment, edge cases, naming, architecture, test coverage.
3. **test-engineer** adds/updates tests with the change.
4. **security-analyst** reviews the slice if it touches a sensitive surface.
5. Repeat until the agreed scope is complete.

**Rules.**

- Keep changes focused and minimal.
- Match repo style.
- Prefer user-facing tests for acceptance evidence.
- Add unit tests for edge cases and fast diagnosis.
- No unrelated refactors or broad rewrites.
- Stop and escalate on unresolved product, architecture, security, or destructive decisions.

**Logging.** Append progress-log entries at meaningful milestones; record material decisions.

---

## Step 8 — Verification

**Owners.** test-engineer, orchestrator.

**Run, in this priority order, what the repo actually defines.**

1. User-facing acceptance tests
2. End-to-end tests
3. Integration tests
4. API contract tests
5. CLI behavior tests
6. UI behavior tests
7. Unit tests
8. Type check
9. Lint
10. Build
11. Format
12. Dependency / security audit
13. Manual reproduction for user-visible behavior
14. Regression checks around touched areas

**On failure.** Diagnose root cause → fix if in scope → re-run → record in progress log.

**If a check can't run** in this environment, document: why; the exact command that should be run later; residual risk; suggested mitigation.

**Output.** Append verification evidence to `.claude/issue-delivery/review-report.md` and `.claude/issue-delivery/sprint-review-demo.md`.

---

## Step 9 — Mandatory review loop

Run **at least one** formal review pass after implementation and initial verification.

**Reviewers.** code-reviewer, test-engineer, security-analyst. Add penetration-tester if externally reachable; architect if architecture moved; product-owner if user-visible behavior changed.

**Process.**

1. Summarize the diff.
2. Review against acceptance criteria, architecture, tests, maintainability, security.
3. Classify findings: **blocker / high / medium / low / note**.
4. Fix all blockers and highs unless explicitly out of scope.
5. Fix mediums when reasonable and safe.
6. Record unresolved findings with rationale.
7. Re-run relevant verification after fixes.

**Required perspectives.** Correctness; user-facing behavior; regression risk; test coverage; error handling; edge cases; maintainability; security; privacy; performance (where relevant); accessibility (where relevant).

**Output.** `.claude/issue-delivery/review-report.md`, plus `.claude/issue-delivery/security-report.md` for the security pieces.

---

## Step 10 — Security analysis and pen-testing

**Required when** the change touches: user input, authn/authz, data storage or access, logging, networking, file handling, dependencies, secrets, payments, admin functionality, public APIs.

**security-analyst tasks.** Lightweight threat model (assets, trust boundaries, attackers, abuse cases, sensitive flows). Review authn/authz, input validation, output encoding, error handling, logging, secrets, dependencies. Recommend mitigations and tests. The threat-model review is read-only and does not require additional authorization.

**Authorization gate for adversarial testing.** Before any pen-test action, the orchestrator must (a) state the proposed scope (targets, attack classes, expected side effects), (b) get explicit user confirmation, and (c) record the confirmation in `.claude/issue-delivery/security-report.md` under "Authorization confirmation". Authorization covers only the scope as recorded — broadening scope requires a fresh confirmation.

**penetration-tester tasks.** Only after the authorization gate. Within authorized local/test boundaries, attempt: injection, XSS, CSRF, SSRF, IDOR, path traversal, unsafe upload, auth bypass, privilege escalation, sensitive data exposure, error disclosure, business-rule bypass.

**Hard limits.**

- No attacks on third-party or production systems.
- No exfiltration of real secrets, credentials, or user data.
- No destructive actions.

**Output → `.claude/issue-delivery/security-report.md`.**

- Scope
- Threat-model summary
- Findings by severity
- Pen-test scenarios attempted
- Results + evidence
- Fixes applied
- Residual risks

---

## Step 11 — Sprint-review demo

**Owner.** demo-lead.

**`.claude/issue-delivery/sprint-review-demo.md` must contain.**

- Issue(s) addressed
- User problem solved
- User-visible behavior — before vs. after
- Demo script / steps
- Acceptance-criteria checklist
- Screenshots, command transcripts, API examples, CLI examples, or UI flows where applicable
- Tests + verification evidence
- Review-loop summary
- Security review + pen-test summary
- Known limitations
- Recommended follow-ups

**Principle.** Lead with user value, then technical implementation, then verification.

---

## Step 12 — Final issue and log updates

**Owners.** orchestrator, product-owner, demo-lead.

**Do.**

1. Append final entries to `.claude/issue-delivery/progress-log.md`: status, changed files, verification results, review results, security results, residual risks.
2. Append final material decisions to `.claude/issue-delivery/decision-log.md`.
3. Update GitHub issues with implementation summary, verification evidence, security notes, demo notes, follow-ups (if write access).
4. **Do not close issues** unless the user explicitly asked or the repo's convention clearly indicates closure.
5. Produce the final user-facing summary.

**Final summary must list.**

- Issues addressed
- Implementation summary
- Files changed
- Verification commands + results
- User-facing tests added/updated
- Review findings + fixes
- Security analysis + pen-test summary
- Residual risks / follow-ups
- Whether issues were updated
- Locations of all six artifact files

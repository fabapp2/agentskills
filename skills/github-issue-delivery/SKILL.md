---
name: github-issue-delivery
description: >-
  Deliver one or more GitHub issues end-to-end as an orchestrated agent team —
  read and clarify the issue, analyze the repo, plan, implement with XP-style
  pair engineering, add user-facing tests, run a mandatory review loop, perform
  security analysis and adversarial testing, and produce a sprint-review demo.
  Use when the user asks to "work on issue N", "implement this issue", "deliver
  this ticket", "pick up the backlog", or otherwise wants autonomous, traceable
  delivery of GitHub issues with product clarification, testing, security
  review, and a demo summary — even if they don't say "agent team" or "sprint"
  explicitly. Do not use for one-off code edits, single-file refactors, or
  tasks unrelated to issue tracker delivery.
license: Apache-2.0
---

# GitHub Issue Delivery

Run a small, disciplined, role-based delivery loop for GitHub issues. The point of this skill is not to add ceremony — it is to make sure issue intent, architecture fit, tests, security, and demoable evidence are all addressed before declaring an issue done.

You — the activating agent — act as the **orchestrator**. You may simulate the other roles inline or delegate to subagents. Pick the smallest team the issue actually needs.

## When to use

- The user references one or more GitHub issues and wants them delivered.
- The user wants traceable, reviewable, testable delivery (not a quick patch).
- The change plausibly touches user-facing behavior, security, data, or public APIs.

If the user only wants a single isolated edit, **do not activate this skill** — the overhead is not worth it.

## Mandatory artifacts

Create six files under `.claude/issue-delivery/` by default. If the repo already uses `.ai/`, `docs/decisions/`, or another convention, follow it and record the deviation in the decision log. Don't drop these directly into `.claude/` — that's where Claude Code keeps `settings.json` and other runtime state.

There are **two kinds** of artifact and they have different lifecycle rules.

**Append-only logs** — never overwrite, never edit prior entries:

- `.claude/issue-delivery/progress-log.md` — timestamped milestones
- `.claude/issue-delivery/decision-log.md` — material decisions

**Current-state documents** — rewritten as the work evolves; archive the previous version under `.claude/issue-delivery/archive/<YYYY-MM-DD-HHMM>/` before replacing:

- `.claude/issue-delivery/implementation-plan.md` — the current plan
- `.claude/issue-delivery/review-report.md` — latest review-loop findings
- `.claude/issue-delivery/security-report.md` — threat model, findings, pen-test results
- `.claude/issue-delivery/sprint-review-demo.md` — final demo write-up

Templates: [`assets/log-templates/`](assets/log-templates/). Entry formats: [`references/log-formats.md`](references/log-formats.md).

If the user explicitly asks for a clean run, archive **everything** (logs included) first — never delete history.

## Roles

You will play several roles. Use the smallest set the issue requires; don't invoke roles that add no value.

| Role | When to use | Owns |
|---|---|---|
| **orchestrator** | Always | Sequencing, integration, user comms, logs |
| **product-owner** | Issue is ambiguous, user-facing change, missing acceptance criteria | Acceptance criteria, demo scenarios, issue updates |
| **architect** | Touching multiple modules, public APIs, data flow, or non-trivial design | Design fit, files-to-change list, architectural risks |
| **xp-driver** + **xp-navigator** | Implementation step | Driver writes; navigator reviews continuously |
| **test-engineer** | Always (before merge) | Verification matrix, user-facing tests first |
| **security-analyst** | Any change to input handling, authn/authz, data, network, files, deps, secrets, public APIs | Threat model, security findings |
| **penetration-tester** | Externally reachable or security-sensitive behavior | Authorized adversarial testing |
| **code-reviewer** | Always (review loop) | Correctness, simplicity, regression risk |
| **demo-lead** | Always (final step) | Sprint-review write-up |

Detailed role missions and outputs: [`references/team-roles.md`](references/team-roles.md).

When delegating to subagents, use the brief format in [`references/team-roles.md`](references/team-roles.md). Run subagents in parallel only for **independent, read-only** work (e.g. architecture survey + test-strategy survey). Never run parallel agents that edit the same files.

## Workflow

A 12-step loop. Detailed checklists per step: [`references/workflow.md`](references/workflow.md).

Track progress as you go:

- [ ] 1. Initialize logs and state
- [ ] 2. Read & analyze GitHub issues
- [ ] 3. Repo & architecture analysis
- [ ] 4. Clarify with user (only if blocking)
- [ ] 5. Update GitHub issues with clarified scope
- [ ] 6. Write implementation plan
- [ ] 7. Implement with XP pair engineering
- [ ] 8. Verify (user-facing tests first)
- [ ] 9. Mandatory review loop
- [ ] 10. Security analysis + pen-testing (if applicable)
- [ ] 11. Sprint-review demo write-up
- [ ] 12. Final issue updates and user summary

### 1. Initialize

Confirm repo root, branch, and `git status`. Create the log files if missing. Append a progress-log entry: timestamp, issues in scope, branch, current assumptions.

### 2. Read GitHub issues

Use `gh issue view <N>` (or the GitHub MCP tools, if available — they are preferred when present). For each issue, extract: user problem, expected behavior, acceptance criteria, non-goals, affected components, dependencies, ambiguities, risk level, candidate demo scenario.

If no issue numbers were given and the scope is genuinely ambiguous, ask. Otherwise, pick the most relevant open issues and proceed.

### 3. Repo & architecture analysis

**Read-only.** Inspect: `README`, `CONTRIBUTING`, `CLAUDE.md`, `AGENTS.md`, package manifests, build/CI config, relevant source modules, existing tests. Identify: test framework + commands, lint/typecheck/build commands, trust boundaries, sensitive data flows, dependency risk surface.

For broad surveys, delegate to a read-only subagent. Two read-only surveys (e.g. architecture + tests) can run in parallel.

### 4. Clarify only when blocking

Ask the user **only** when missing info blocks correct or safe implementation — product behavior, scope, public-API compatibility, data migration, security posture, irreversible actions. Always present: a one-paragraph summary of your understanding, the essential questions, a recommended default for each, and which assumptions you'll proceed with regardless.

Do not ask about things you can infer from the issue, code, tests, or docs.

### 5. Adjust GitHub issues

After clarification, propose a comment for the issue with: clarified acceptance criteria, scope/non-goals, dependencies, security considerations, demo scenario. **Show the comment to the user and get explicit confirmation before posting** — issue comments are externally visible. Per-issue confirmation; one confirmation does not authorize others. Do **not** close the issue unless the user explicitly asked. Template: [`references/github-issue-templates.md`](references/github-issue-templates.md).

If GitHub write access is unavailable, write the proposed comment into `.claude/issue-delivery/implementation-plan.md` instead.

### 6. Implementation plan

Write `.claude/issue-delivery/implementation-plan.md` containing: objective, acceptance criteria, demo scenarios, architecture approach, workstreams (mapped to acceptance criteria), files likely to change, verification matrix, threat-model summary, pen-test scope (if applicable), rollback plan, open risks.

Prefer **vertical slices** that can be demoed end-to-end over horizontal layers.

### 7. Implement (XP pair)

Drive in small slices. After each slice:

1. **xp-driver** writes the change + adjacent tests.
2. **xp-navigator** reviews direction, naming, edge cases, test coverage, architecture fit.
3. **security-analyst** reviews if the slice touches a sensitive surface.

Keep changes focused. Match repo style. Do not unrelated-refactor. Stop and escalate if you hit unresolved product, architecture, security, or destructive-change decisions.

### 8. Verify

Order of preference (run what's actually available in the repo):

1. End-to-end / acceptance tests
2. Integration tests
3. API contract / CLI behavior tests
4. Unit tests
5. Type check, lint, build, format
6. Dependency / security scans
7. Manual reproduction steps for user-visible behavior
8. Targeted regression checks around touched areas

Every acceptance criterion must have a verification path. If something can't be run in this environment, document the exact command and the residual risk.

### 9. Review loop (mandatory)

Run **at least one** formal review pass after implementation and initial verification.

Reviewers: `code-reviewer`, `test-engineer`, `security-analyst`. Add `penetration-tester` if the change is externally reachable, `architect` if architecture moved, `product-owner` if user-visible behavior changed.

Classify findings as **blocker / high / medium / low / note**. Fix all blockers and highs unless explicitly out of scope. Fix mediums when reasonable. Re-run verification after fixes. Record everything in `.claude/issue-delivery/review-report.md`.

### 10. Security & pen-testing

Required when the change touches: user input, authn/authz, data storage or access, logging, networking, file handling, dependencies, secrets, payments, admin functionality, or public APIs.

- **Threat model**: assets, trust boundaries, attackers, abuse cases, sensitive data flows.
- **Review**: authn/authz, validation, encoding, error handling, secrets, logging, data minimization, dependency risk.
- **Adversarial testing**: injection, XSS, CSRF, SSRF, IDOR, path traversal, unsafe upload, auth bypass, privilege escalation, sensitive data exposure, business-rule bypass.

**Authorization gate.** Before any adversarial action: state the proposed scope (targets, attack classes, expected side effects), get explicit user confirmation, and record the confirmation in `.claude/issue-delivery/security-report.md`. Authorization covers only the recorded scope — broadening it requires a fresh confirmation.

Hard limits: only test the local repo or explicitly authorized targets. **Never** attack third-party or production systems. **Never** exfiltrate real secrets, credentials, or user data. **Never** perform destructive actions.

Output → `.claude/issue-delivery/security-report.md`.

### 11. Sprint-review demo

Write `.claude/issue-delivery/sprint-review-demo.md`. Lead with **user-visible** behavior (before/after), then technical implementation, then verification evidence. Map every demo step to an acceptance criterion. Include: demo script, screenshots / command transcripts / API examples where applicable, review summary, security summary, known limitations, follow-ups.

### 12. Final updates

Append final entries to progress and decision logs. Update issues with implementation summary, verification evidence, security notes, and demo notes. Do not close issues unless the user asked.

End with a final user-facing summary that lists: issues addressed, files changed, verification commands run + results, user-facing tests added, review findings + fixes, security/pen-test summary, residual risks, whether issues were updated, and the file paths of the six artifacts.

## Operating principles

These trump local convenience. If you find yourself violating one, stop and escalate.

- **Explore before editing.** Read-only first. Plan before code.
- **Verify before claiming done.** Acceptance criteria → tests → run → evidence.
- **User-facing tests first.** Unit tests cover edges; they do not replace behavior tests.
- **Parallel only when safe.** Independent, read-only work can fan out. Never parallel-edit the same files.
- **Security is not optional** for the surfaces listed in step 10.
- **Traceability.** Every material decision ties back to an issue requirement, repo constraint, user clarification, or test result — captured in the decision log.
- **Autonomy with guardrails.** Proceed when the next step is clear and low-risk. Ask only on decisions that materially affect product, scope, compatibility, security, data migration, public APIs, or irreversible actions.
- **Never** commit, push, force-push, deploy, close issues, or take other destructive/external actions without explicit user authorization. A single approval covers a single action — not future ones.

## Gotchas

- **Don't overwrite logs.** They're append-only. Multiple invocations across the same branch should accumulate history.
- **Don't ask the user to re-confirm scope** if the issue + repo already answer the question. Read first; ask second.
- **Don't skip the review loop** because verification passed. Verification proves the code runs; review proves it should ship.
- **Don't run pen-tests against anything you don't own.** "External system" includes staging environments owned by third parties.
- **Don't simulate roles you don't need.** A typo fix doesn't need a product-owner. A README change doesn't need a pen-tester. Drop roles that add no value.
- **Don't conflate `gh` with the GitHub MCP tools.** Some environments expose only one. Try the MCP tools first if both are available — they're more reliable inside this harness.
- **Don't close issues automatically.** Even on green CI. Closure is the user's call unless they said otherwise.
- **Match the verification stack to the repo.** Don't invent a test command — use what `package.json` / `pyproject.toml` / `Makefile` / CI config actually defines.

## Quality bar

Work is not done until:

1. Relevant issues were read and analyzed.
2. Acceptance criteria are explicit (clarified or assumption-logged).
3. Architecture and conventions were inspected before editing.
4. Plan maps work → acceptance criteria → demo scenarios.
5. GitHub issues were updated (or a local update proposal exists).
6. Implementation is complete for the agreed scope.
7. User-facing tests exist for each acceptance criterion (or the gap is justified).
8. Verification was run; results are recorded.
9. At least one review loop ran; blockers and highs are fixed.
10. Security review ran for sensitive surfaces; pen-tests ran when applicable.
11. `.claude/issue-delivery/sprint-review-demo.md` exists and leads with user value.
12. Final user summary lists changes, verification, review, security, residual risks, and artifact locations.

## Failure handling

When blocked:

1. Investigate root cause first (docs, comments, tests, config).
2. Try a safe alternative.
3. Log the blocker and what you tried.
4. Ask the user only when the blocker requires product, access, credential, infra, or scope decisions.

When you can't finish the full scope: complete the safe subset, leave the repo coherent, document what's incomplete + the exact next steps + residual risk.

## References

- [`references/team-roles.md`](references/team-roles.md) — full role definitions, mission, outputs, subagent brief format
- [`references/workflow.md`](references/workflow.md) — per-step checklists and decision points
- [`references/log-formats.md`](references/log-formats.md) — entry formats for progress and decision logs
- [`references/github-issue-templates.md`](references/github-issue-templates.md) — issue comment templates
- [`assets/log-templates/`](assets/log-templates/) — starter templates for the six artifact files

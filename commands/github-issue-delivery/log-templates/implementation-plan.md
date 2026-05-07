# Implementation plan

## Objective

## Issues in scope

## Product assumptions

## Acceptance criteria

- [ ] AC-1:
- [ ] AC-2:

## Demo scenarios

1.
2.

## Architecture approach

## Workstreams

| # | Workstream | Mapped to AC | Owner | Notes |
|---|---|---|---|---|
| 1 |  |  |  |  |

## XP pair-engineering plan

- Driver:
- Navigator:
- Slice cadence:

## Parallelization plan

## Files likely to change

## Verification matrix

Every acceptance criterion needs an e2e/acceptance row (Playwright by default for user-facing flows). Justify any criterion that can't have one.

| Acceptance criterion | Test type (e2e / integration / unit) | Test / file | Command | Trace / video path |
|---|---|---|---|---|
|  |  |  |  |  |

## Build-gate plan

- `./build-sdk.sh` — runs before every commit (pre-commit gate). Failure → fix and re-run; never `--no-verify`.
- `./build-full.sh` — runs before opening or updating the PR (pre-PR gate). PR is only opened on exit 0.

## Playwright follow-along plan

- Command(s) the user should run to follow along live (`npx playwright test --headed --ui` etc.):
- Trace/video output directory:
- Replay command (`npx playwright show-trace ...`):

## Threat-model summary

- Assets:
- Trust boundaries:
- Attackers / abuse cases:
- Sensitive data flows:

## Pen-test scope

## Rollback plan

## Open risks

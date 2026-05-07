#!/usr/bin/env bash
# append-decision.sh — append a decision-log entry skeleton with an
# auto-incremented D-NNN identifier. The entry uses the format defined
# in commands/github-issue-delivery/log-formats.md.
#
# Usage:
#   append-decision.sh <artifact-dir> "<decision short title>"
#
# Optional: pipe additional Markdown into stdin to fill the body fields.
#
# Example:
#   append-decision.sh .claude/issue-delivery "Use SQLite for cache" <<'EOF'
#   Context: need a small embedded store for the new cache layer.
#   Options considered:
#     - SQLite (stdlib, file-based)
#     - Redis (extra dependency)
#   Decision: SQLite
#   Rationale: zero ops cost, fits volume; reversible.
#   Consequences: introduces sqlite3 module usage; reversible by swapping driver.
#   Related issue(s): #42
#   Related file(s): src/cache/store.py
#   EOF

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "usage: append-decision.sh <artifact-dir> \"<decision short title>\"" >&2
  exit 2
fi

ARTIFACT_DIR="$1"
TITLE="$2"
LOG="$ARTIFACT_DIR/decision-log.md"
TS="$(date "+%Y-%m-%d %H:%M %Z")"

if [[ ! -f "$LOG" ]]; then
  echo "append-decision: $LOG does not exist; run init-artifacts.sh first" >&2
  exit 1
fi

# Highest existing decision number, ignoring the literal template
# placeholder ("## Decision D-001: <short title>"). Numbers are matched
# with leading zeros stripped so D-007 -> 7.
highest="$(
  grep -E '^## Decision D-[0-9]+:' "$LOG" \
    | grep -v '^## Decision D-[0-9]\+: <short title>$' \
    | sed -E 's/^## Decision D-0*([0-9]+):.*/\1/' \
    | sort -n \
    | tail -n 1 \
    || true
)"

next=$(( ${highest:-0} + 1 ))
id="$(printf 'D-%03d' "$next")"

{
  printf '\n## Decision %s: %s\n' "$id" "$TITLE"
  printf 'Date/time: %s\n' "$TS"
  if [[ ! -t 0 ]]; then
    cat
  else
    cat <<'EOF'
Context:
Options considered:
  -
  -
Decision:
Rationale:
Consequences:
Related issue(s):
Related file(s):
EOF
  fi
} >> "$LOG"

echo "append-decision: appended $id \"$TITLE\" to $LOG"

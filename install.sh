#!/usr/bin/env bash
# Copyright 2025 promptLM
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ---------------------------------------------------------------------------
# install.sh — download agent-skills into the current project
#
# Usage:
#   bash install.sh [REF]
#
# REF is a branch name or tag (default: main).
#
# The script downloads the skills/ directory from the agentskills repo and
# places it at .agents/skills/ in your project. It does NOT commit — you
# should review and commit yourself.
# ---------------------------------------------------------------------------
set -euo pipefail

REPO="https://github.com/promptics/agentskills"
REF="${1:-main}"
TARGET=".agents/skills"

echo "Installing agent-skills ($REF) into $TARGET ..."

rm -rf "$TARGET"
mkdir -p "$TARGET"

curl -fsSL "$REPO/archive/refs/heads/$REF.tar.gz" \
  | tar xz --strip-components=2 -C "$TARGET" "agentskills-$REF/skills/" \
  2>/dev/null \
|| curl -fsSL "$REPO/archive/refs/tags/$REF.tar.gz" \
  | tar xz --strip-components=2 -C "$TARGET" "agentskills-$REF/skills/"

echo ""
echo "Done. Skills installed into $TARGET/"
echo ""
echo "Next steps:"
echo "  git add $TARGET && git commit -m 'Import agent-skills ($REF)'"  

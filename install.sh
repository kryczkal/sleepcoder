#!/usr/bin/env bash
# sleepcoder — drop-in autonomous loop for Claude Code.
# https://github.com/kryczkal/sleepcoder
#
# Run this from the root of any git repo:
#
#     curl -fsSL https://raw.githubusercontent.com/kryczkal/sleepcoder/main/install.sh | bash
#
# Works on Linux and macOS. Requires bash, curl, git.

set -euo pipefail

PROMPT_URL="https://raw.githubusercontent.com/kryczkal/sleepcoder/main/AUTONOMOUS_LOOP_PROMPT.md"
PROMPT_FILE="AUTONOMOUS_LOOP_PROMPT.md"

# Soft warning if not in a git repo. We don't bail — the loop still works
# without git, just with less to do at CHECKPOINT.
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo ""
  echo "!  Heads up: this directory isn't inside a git repo."
  echo "   The loop ships work as commits on topic branches, so it works"
  echo "   best inside a git repo. Consider 'git init' first."
  echo ""
fi

# Overwrite warning
if [ -e "$PROMPT_FILE" ]; then
  echo "!  $PROMPT_FILE already exists here -- overwriting with the latest."
fi

# Fetch the prompt
curl -fsSL "$PROMPT_URL" -o "$PROMPT_FILE"

LINES=$(wc -l < "$PROMPT_FILE" | tr -d ' ')
HERE=$(pwd)

echo ""
echo "  sleepcoder installed."
echo ""
echo "  Wrote: $HERE/$PROMPT_FILE  ($LINES lines)"
echo ""
echo "  -- Next step ---------------------------------------------"
echo ""
echo "  In Claude Code, from this directory, run:"
echo ""
echo "      /loop 5min read AUTONOMOUS_LOOP_PROMPT.md"
echo ""
echo "  Any interval works; 5min is a reasonable default."
echo ""
echo "  The first iteration bootstraps a minimal wiki/ if you don't"
echo "  have one. Every wake-up: ORIENT -> DECIDE -> ACT -> VERIFY"
echo "  -> CHECKPOINT. Topic-branches you merge when you review."
echo ""
echo "  -- Control -----------------------------------------------"
echo ""
echo "  Pause one iteration:   touch .LOOP_PAUSE"
echo "  Steer the next iter:   echo 'your priority' > .LOOP_FOCUS"
echo "  Stop entirely:         run /loop again in Claude Code"
echo ""
echo "  -- More --------------------------------------------------"
echo ""
echo "  Docs:    https://github.com/kryczkal/sleepcoder"
echo "  Safety:  see prompt section 6 -- never pushes, never deletes,"
echo "           never touches your uncommitted work."
echo ""

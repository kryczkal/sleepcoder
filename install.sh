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

# Soft warning if not in a git repo. The loop still works without git;
# it just has less to do at CHECKPOINT.
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

# Soft check for the Claude Code CLI
if ! command -v claude >/dev/null 2>&1; then
  echo ""
  echo "!  'claude' command not found in PATH. Install Claude Code first:"
  echo "     https://docs.claude.com/en/docs/claude-code/overview"
fi

cat <<'NEXTSTEP'

  -- Run it (full auto, recommended) ----------------------------

  In this directory, run:

      claude --dangerously-skip-permissions "/loop 5min read AUTONOMOUS_LOOP_PROMPT.md"

  Launches Claude Code with the /loop already filled in. Runs without
  per-tool permission prompts so the loop actually progresses overnight
  instead of blocking on approvals.

  About the flag: --dangerously-skip-permissions bypasses Claude Code's
  per-tool confirmation prompts. The autonomous loop is designed to
  run with it -- safety lives in the PROMPT (section 6: never pushes,
  never deletes, never touches your uncommitted files, never spends
  money, never messages other people, never modifies dotfiles). You
  merge what you want when you review.

  -- Alternative: supervised mode -------------------------------

  If you want to approve each tool call manually:

      claude "/loop 5min read AUTONOMOUS_LOOP_PROMPT.md"

  The loop will pause on impactful actions and wait for you.

  -- Control while it's running ---------------------------------

  Pause one iteration:   touch .LOOP_PAUSE
  Steer the next iter:   echo 'your priority' > .LOOP_FOCUS
  Stop entirely:         run /loop again in Claude Code (toggles off)

  -- More -------------------------------------------------------

  Docs:  https://github.com/kryczkal/sleepcoder

NEXTSTEP

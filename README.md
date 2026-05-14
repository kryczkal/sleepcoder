# sleepcoder

Drop-in autonomous engineering loop for Claude Code. One file, one
command, runs while you sleep. Wakes up periodically, picks tangible
work from your repo's wiki, ships topic-branches you merge later.

Built on [Andrej Karpathy's LLM Wiki pattern](https://karpathy.bearblog.dev/blog/llm-wiki/)
— a persistent, LLM-maintained synthesis layer that compounds across
sessions instead of being re-derived on every query.

## Install — one line

In any git repo (Linux or macOS), run:

```bash
curl -fsSL https://raw.githubusercontent.com/kryczkal/sleepcoder/main/install.sh | bash
```

The installer writes `AUTONOMOUS_LOOP_PROMPT.md` to the current directory
and prints the next step.

The next step it prints — paste this in the same directory:

```bash
claude --dangerously-skip-permissions "/loop 5min read AUTONOMOUS_LOOP_PROMPT.md"
```

This launches Claude Code with the `/loop` command already filled in
and skips the per-tool permission prompts so the loop actually
progresses overnight instead of blocking on approvals. First iteration
bootstraps a minimal `wiki/` if none exists. Every subsequent iteration
runs the protocol: **ORIENT → DECIDE → ACT → VERIFY → CHECKPOINT**.

**About `--dangerously-skip-permissions`:** it bypasses Claude Code's
per-tool confirmation dialogs. The autonomous loop is built to run with
it — the [safety rails](#safety-rails) live in the prompt itself, not
in the per-tool prompts. If you'd rather supervise each tool call:

```bash
claude "/loop 5min read AUTONOMOUS_LOOP_PROMPT.md"
```

Same setup, but the loop will pause on impactful actions and wait for
you.

**Prefer to skip `curl | bash` entirely?** Fetch the prompt file
directly:

```bash
curl -fsSL https://raw.githubusercontent.com/kryczkal/sleepcoder/main/AUTONOMOUS_LOOP_PROMPT.md -o AUTONOMOUS_LOOP_PROMPT.md
```

…then run either of the `claude …` commands above.

## How it works

Every wake-up the loop:

1. **Pre-flight** — checks `.LOOP_PAUSE`, reads `.LOOP_FOCUS`, snapshots
   the working tree so it never touches your uncommitted work, and (on
   the first run) bootstraps `wiki/` from the embedded schema.
2. **Orient** — reads `wiki/log.md`, the session journal, the morning
   handoff. Grounded entirely on disk; survives context resets.
3. **Decide** — picks from a T0–T5 hierarchy:
   - **T0** — something is broken: fix first
   - **T1** — recent commits without verification: backfill proof
   - **T2** — outstanding demo blockers from `wiki/status/*.md`
   - **T3** — quality maintenance (lint, dead code, missing tests)
   - **T4** — product / architecture gaps: file in `wiki/gaps/`
   - **T5** — meta: capture recurring frictions for next session
4. **Act** — ships ONE coherent unit of work on a topic branch
   (`auto/<date>-<topic>`). Multi-commit branches are normal.
5. **Verify** — tests green, screenshot taken, log inspected. No
   commit without proof.
6. **Checkpoint** — commits, appends to journal, overwrites
   `morning-handoff.md` so you can resume in 30 seconds.

State lives entirely on disk. The loop is patient — a task can span
many wake-ups across many iterations.

## Karpathy LLM Wiki, briefly

Three layers:

- `raw/` — immutable source documents you drop in (articles, papers,
  screenshots). The loop reads, never edits.
- `wiki/` — LLM-owned synthesis pages. The loop writes and maintains.
- `wiki/CLAUDE.md` — the schema that tells the loop how the wiki is
  structured.

Pages cross-link via relative paths. Every substantive change appends
to `wiki/log.md`. Page types: `component`, `decision`, `principle`,
`source`, `status`, `gap`, `session`. The loop bootstraps a minimal
version of all this on first iteration if your repo doesn't already
have a `wiki/`.

## Safety rails

Hard limits baked into the prompt (§6):

- **Never** `git push`, `--force`, `reset --hard`, or `clean -fd`
- **Never** touches files in your uncommitted set
- **Never** modifies `~/.claude/` or other user dotfiles
- **Never** ships code that exposes secrets
- **Never** deletes user data — run dirs, screenshots, transcripts are
  append-only
- **Never** sends messages to other people, makes payments, deploys to
  production, or touches shared infra

You merge what you want when you review. The loop only writes to local
topic branches.

## Share with a friend

One line. They run it in any of their repos and the installer tells
them exactly what to do next.

Copy-paste-ready message for chat:

> Autonomous loop for Claude Code — runs while you sleep, ships
> topic-branches you merge later. In any git repo:
>
> ```
> curl -fsSL https://raw.githubusercontent.com/kryczkal/sleepcoder/main/install.sh | bash
> ```
>
> The installer prints the exact launch command — it's
> `claude --dangerously-skip-permissions "/loop 5min read AUTONOMOUS_LOOP_PROMPT.md"`.
> First iteration sets up a wiki, every subsequent iter advances real
> work. Safety rails are in the prompt itself.

## Control while it's running

- **Pause one iteration:** `touch .LOOP_PAUSE` in the repo root.
- **Steer the next iteration:** write priorities to `.LOOP_FOCUS`.
- **Stop entirely:** kill the cron via `/loop` in Claude Code, or end
  the Claude Code session.

## License

MIT.

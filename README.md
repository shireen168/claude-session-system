# The Claude Code Session System

A 4-phase workflow that eliminates cold starts, prevents rate limit surprises, and ensures nothing is lost between sessions.

Built and used daily by [Shireen Low](https://aiwithshireen.com) - AI Project Strategist.

> This is my personal setup. Every phase is independently useful - pick what fits your workflow. The statusline values, context files, and command prompts can all be adjusted to suit how you work.

---

## The Problem

Every Claude Code session starts cold. You spend the first 20 minutes rebuilding context. You hit rate limits mid-task with zero warning. You close without saving and lose everything. This system fixes all three.

---

## The 4 Phases

| Phase | Command | When | What it does |
|---|---|---|---|
| 01 | `/standup` | Session start | Reads your context files, outputs a 30-second brief |
| 02 | `plan mode` | Before any build | Claude plans first, no code written until you approve |
| 03 | `Statusline` | All session | Live: context %, 5hr rate limit, 7-day budget |
| 04 | `/wrap` | Session end | Summarizes, saves to log, updates context, pushes to GitHub |

---

## Before You Start

**Where these commands work:**

The `/standup` and `/wrap` custom commands work in any Claude Code interface. The **Statusline (Phase 03) only works in the terminal CLI** (`claude` command). It does not render in the VS Code extension, JetBrains plugin, or the claude.ai web interface - those have their own UI. If you primarily use an IDE extension, skip Phase 03 or use it alongside your IDE workflow by opening a terminal session.

**What you need for /wrap:**

`/wrap` commits and pushes to GitHub at the end of every session. Your project needs:
- `git init` already done
- A GitHub remote configured (`git remote add origin ...`)
- If you don't use GitHub or don't want auto-push, edit `commands/wrap.md` and remove the push step.

---

## Setup

### File structure to create

Before running any command, create this structure in your project:

```
your-project/
  .claude/
    commands/
      standup.md       <- copy from this repo's commands/standup.md
      wrap.md          <- copy from this repo's commands/wrap.md
  context/
    current-priorities.md   <- your active focus areas (starter template in examples/)
  sessions/
    log.md             <- session history, auto-updated by /wrap (starter in examples/)
    last-active.md     <- last session timestamp, auto-updated by /wrap (starter in examples/)
```

The `.claude/commands/` folder is where Claude Code reads custom slash commands. Commands placed here are available as `/standup` and `/wrap` within that project.

**For use across all projects:** copy the command files to `~/.claude/commands/` instead. Commands there are available globally in every Claude Code session.

---

### Phase 01: /standup

**1. Create your context files**

Use the starter templates in `examples/` as a starting point. Fill in your current priorities and leave `log.md` and `last-active.md` blank - `/wrap` will populate them after your first session.

**2. Copy the command**

```bash
# For this project only:
cp commands/standup.md your-project/.claude/commands/standup.md

# Or globally (all projects):
cp commands/standup.md ~/.claude/commands/standup.md
```

**3. Use it**

Type `/standup` at the start of every Claude Code session. Claude reads your 3 context files and outputs a brief in under 30 seconds. It asks one question before touching any code.

> The standup command reads `context/current-priorities.md`, `sessions/last-active.md`, and `sessions/log.md` (last 3 entries). If any file is missing it skips it gracefully - no errors.

---

### Phase 02: plan mode

Built into Claude Code. No file setup required.

Before any task with 3 or more steps, type `/plan` to enter plan mode.

Claude will explore the codebase, write out a structured plan, and wait for your approval. Zero code is written until you say go.

**Why it matters:** Planning costs ~200 tokens. Building in the wrong direction and fixing it costs ~2,000. The ROI on planning is immediate on any task longer than 10 minutes.

> Adjust the threshold to your preference. I use 3+ steps. Some people use it for everything; others only for architectural decisions.

---

### Phase 03: Statusline

**Terminal CLI only.** The statusline does not show in the VS Code extension or JetBrains plugin. If you use an IDE extension, run Claude Code in a separate terminal window alongside it.

The statusline shows live at the bottom of every prompt:

```
[Sonnet 4.6]  $1.02  48m 6.91s  |  ctx 10k / 200k (36%)  cache 72k
5hr ████░░░░ 34%  resets 4h 8m  |  7day ███░░░░░ 28%  resets 5d 21h
>> accept edits on  (shift+tab to cycle)
```

**What each metric means:**

| Metric | What it tracks | Why it matters |
|---|---|---|
| `ctx 36%` | Context window used | At 90%: Claude cuts off mid-response. Run `/compact` or start fresh. |
| `5hr 34%` | Hourly rate limit | At 100%: all work stops with zero warning. |
| `7day 28%` | Weekly token budget | Visible at all times so you can pace heavy tasks. |

**Color thresholds:** green = under 70% (keep going), yellow = 70-90% (batch prompts, consider `/compact`), red = over 90% (start a fresh session now).

These thresholds are set in `statusline.ps1`. Adjust them to match your usage pattern.

**Setup (Windows - PowerShell):**

1. Copy `statusline.ps1` to your Claude config directory:

```
C:/Users/[username]/.claude/statusline.ps1
```

2. Open `~/.claude/settings.json` and **add** (merge, do not overwrite) the `statusLine` block:

```json
{
  "statusLine": {
    "type": "command",
    "command": "powershell -NoProfile -ExecutionPolicy Bypass -File C:/Users/[username]/.claude/statusline.ps1"
  }
}
```

Replace `[username]` with your actual Windows username. The full snippet is in `settings-snippet.json`.

If `~/.claude/settings.json` does not exist yet, create it with just the content above.

3. **Restart Claude Code.** The statusline only activates after a full restart - not after `/compact` or starting a new conversation. Close Claude Code completely and reopen it.

**Setup (Mac / Linux - Bash):**

The statusline script in this repo is PowerShell only. For Mac/Linux, you can write a bash equivalent following the same pattern - Claude Code's statusline accepts any command that reads stdin JSON and writes a string to stdout. The [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code/settings#status-line) covers the input schema.

> The fields I display (context %, 5hr limit, 7-day budget, cost, model) are what matter most to my workflow. You can strip it down to just context % if that's all you need, or add fields like session duration. The script is fully commented - adjust it.

---

### Phase 04: /wrap

**1. Copy the command**

```bash
# For this project only:
cp commands/wrap.md your-project/.claude/commands/wrap.md

# Or globally:
cp commands/wrap.md ~/.claude/commands/wrap.md
```

**2. Verify your file structure exists**

`/wrap` writes to `sessions/YYYY-MM-DD.md`, `sessions/log.md`, `sessions/last-active.md`, and `context/current-priorities.md`. These folders need to exist before you run it. Create them once manually - `/wrap` handles the file content from then on.

**3. Use it**

Type `/wrap` at the end of every session. It:
1. Writes a session summary to `sessions/YYYY-MM-DD.md`
2. Prepends a one-line entry to `sessions/log.md` (newest first)
3. Updates `context/current-priorities.md` to reflect what changed
4. Commits and pushes everything to GitHub

The next `/standup` reads the log that `/wrap` wrote. The loop closes.

> If you do not want auto-push to GitHub, edit `commands/wrap.md` and remove the git commit and push commands from the final step. Everything else still works.

---

## The Compound Effect

- **Day 1:** set it up once
- **Day 7:** `/standup` reads your last 3 sessions from the log, session opens in 30 seconds
- **Day 30:** searchable project log, zero cold starts, never blindsided by a limit

Every session builds on the last.

---

## Files in This Repo

```
README.md                    <- this file
statusline.ps1               <- PowerShell statusline script (Windows)
settings-snippet.json        <- merge this into ~/.claude/settings.json
commands/
  standup.md                 <- /standup command definition
  wrap.md                    <- /wrap command definition
examples/
  current-priorities.md      <- starter template
  sessions/
    log.md                   <- starter template (leave blank, /wrap fills it)
    last-active.md           <- starter template (leave blank, /wrap fills it)
```

---

## Author

**Shireen Low** - AI Project Strategist

- [aiwithshireen.com](https://aiwithshireen.com)
- [LinkedIn](https://linkedin.com/in/shireenlowyk)

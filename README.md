# The Claude Code Session System

A 4-phase workflow that eliminates cold starts, prevents rate limit surprises, and ensures nothing is lost between sessions.

Built and used daily by [Shireen Low](https://aiwithshireen.com) - AI Project Strategist.

---

## The Problem

Every Claude Code session starts cold. You spend the first 20 minutes rebuilding context. You hit rate limits mid-task with zero warning. You close without saving and lose everything. This system fixes all three.

---

## The 4 Phases

| Phase | Command | When | What it does |
|---|---|---|---|
| 01 | `/standup` | Session start | Reads your context files, outputs a 30-second brief |
| 02 | `plan mode` | Before any build | Claude plans first, no code written until you approve |
| 03 | `Statusline` | All session | Live: context %, 5hr rate limit, 7day budget |
| 04 | `/wrap` | Session end | Summarizes, saves to log, updates context, pushes to GitHub |

---

## Setup

### Prerequisites

- [Claude Code](https://claude.ai/code) installed
- PowerShell (Windows) for the statusline script

---

### Phase 01: /standup

**1. Create your context files**

```
your-project/
  context/
    current-priorities.md    <- your active focus areas
  sessions/
    log.md                   <- session history (auto-updated by /wrap)
    last-active.md           <- timestamp of last session (auto-updated by /wrap)
```

See `examples/` in this repo for starter templates.

**2. Add the command**

Copy `commands/standup.md` to `.claude/commands/standup.md` in your project.

**3. Use it**

Type `/standup` at the start of every Claude Code session. Claude reads your 3 context files and outputs a brief. It asks one question before touching any code.

---

### Phase 02: plan mode

Built into Claude Code. No setup required.

Before any task with 3+ steps, ask Claude to plan first:

> "Enter plan mode and plan the approach before we build."

Claude will explore the codebase, present a structured plan, and wait for your approval. Zero code written until you say go.

**Why it saves tokens:** Planning costs ~200 tokens. Building in the wrong direction and fixing it costs ~2,000. Always plan first.

---

### Phase 03: Statusline

The statusline shows live metrics at the bottom of every prompt:

```
[Sonnet 4.6]  $1.02  48m 6.91s  |  ctx 10k / 200k (36%) cache 72k
5hr ████░░░░ 34%  resets 4h 8m  |  7day ███░░░░░ 28%  resets 5d 21h
>> accept edits on  (shift+tab to cycle)
```

**What each metric means:**
- `ctx 36%` - how full your context window is. At 90%: Claude cuts off mid-response. Run `/compact`.
- `5hr 34%` - your hourly rate limit. At 100%: work stops with zero warning.
- `7day 28%` - your weekly token budget. Visible at all times.

**Color coding:** green = under 70% (keep going), yellow = 70-90% (batch your prompts), red = over 90% (start a fresh session now).

**Setup (Windows PowerShell):**

1. Copy `statusline.ps1` to `C:/Users/[username]/.claude/statusline.ps1`

2. Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "powershell -NoProfile -ExecutionPolicy Bypass -File C:/Users/[username]/.claude/statusline.ps1"
  }
}
```

Replace `[username]` with your Windows username.

---

### Phase 04: /wrap

**Add the command**

Copy `commands/wrap.md` to `.claude/commands/wrap.md` in your project.

**Use it**

Type `/wrap` at the end of every session. It:
1. Writes a session summary to `sessions/YYYY-MM-DD.md`
2. Prepends a one-line entry to `sessions/log.md`
3. Updates `context/current-priorities.md` to reflect what changed
4. Commits and pushes everything to GitHub

The next `/standup` reads the log that `/wrap` wrote. The loop closes.

---

## The Compound Effect

- **Day 1:** set it up once
- **Day 7:** `/standup` reads your full session history, session opens in 30 seconds
- **Day 30:** searchable project log, zero cold starts, never blindsided by a limit

Every session builds on the last.

---

## Files in This Repo

```
README.md                    <- this file
statusline.ps1               <- PowerShell statusline script
settings-snippet.json        <- add this to ~/.claude/settings.json
commands/
  standup.md                 <- /standup command definition
  wrap.md                    <- /wrap command definition
examples/
  current-priorities.md      <- starter template
  sessions/
    log.md                   <- starter template
    last-active.md           <- starter template
```

---

## Author

**Shireen Low** - AI Project Strategist

- [aiwithshireen.com](https://aiwithshireen.com)
- [LinkedIn](https://linkedin.com/in/shireenlowyk)

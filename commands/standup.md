Read the following files and generate a morning brief. Do not re-state what you are doing -- just output the brief directly.

Files to read:
- `context/current-priorities.md`
- `sessions/last-active.md` (if exists)
- `sessions/log.md` (last 3 entries if exists)

Output format (under 200 words, no fluff):

---
**[Today's date, MYT]**
**Last session:** [from last-active.md, or "no prior sessions" if missing]

**Current Focus:**
[Top 3 priorities as tight bullet points -- one line each]

**Recent Work:**
[2-3 lines summarizing last 1-2 sessions from log.md, skip if no log exists]

**Suggested focus for this session:**
[1-2 specific, actionable items based on where priorities currently stand]
---

After outputting the brief, ask ONE question:

> "What are we working on this session -- or should I follow the suggested focus above?"

Wait for the answer before doing anything else. Once confirmed:
- If the task involves 3+ steps or any build work, enter plan mode and write a plan to `tasks/todo.md` for the relevant project
- Show the plan and get approval before touching any code or files
- Only then start executing

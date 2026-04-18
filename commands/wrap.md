Summarize this session, save it, and push all work to GitHub. Do not ask for confirmation -- execute all steps.

Steps (in order):

1. Write a session summary to `sessions/YYYY-MM-DD.md` using today's actual date (MYT).
   Format:
   ```
   # Session: YYYY-MM-DD

   **Focus:** [one line -- what this session was about]

   **Done:**
   - [bullet: completed item]

   **Decisions:**
   - [any decisions made, or "none" if none]

   **Next:**
   - [1-3 clear next actions to continue from here]
   ```

2. Prepend a one-line entry to `sessions/log.md` (create if it doesn't exist), inserting it immediately after the `<!-- Newest entries first -->` comment line so the newest entry is always at the top:
   `### YYYY-MM-DD HH:MM MYT — [one-line summary of what was done]`

3. Update context files to reflect current state:

   a. `context/current-priorities.md` -- rewrite the priorities list based on what is now active, completed, or newly started this session. Update the `_Last updated:` date. Rules:
      - If a freelance client project was worked on, it should appear as priority #1
      - If a portfolio project shipped or changed status, reflect it
      - If something was completed this session, remove or demote it
      - If something new started, add it

   b. `context/work.md` -- update only the parts that changed:
      - Portfolio projects list: add newly completed projects with their live URLs
      - Freelance section: update active client if it changed
      - Do not touch tools, MCP servers, or other stable sections

   c. `decisions/log.md` -- if any meaningful decisions were made this session (stack choices, project direction, naming, strategy), prepend them immediately after the `<!-- Newest entries first -->` comment line. Format: `[YYYY-MM-DD] DECISION: ... | REASONING: ... | CONTEXT: ...`
      - Only log decisions that are non-obvious or worth remembering across sessions
      - Skip if nothing decision-worthy happened

4. Sync to Obsidian Vault (`C:/Users/user/Desktop/Obsidian Vault/`):

   The vault is Shireen's persistent knowledge base. Update the relevant files based on what happened this session. Always append to the wiki log. Do not modify files under `raw/`.

   a. **Always:** Append to `wiki/log.md` (newest first):
      ```
      ## [YYYY-MM-DD] edit | [session focus line]
      - Updated: [list all Obsidian files touched this step]
      - Notes: [1-2 line summary of what changed and why]
      ```

   b. **If a portfolio project was worked on:** Update `projects/<name>.md`:
      - Add decisions made this session to Key Decisions
      - Add techniques that worked to What Worked
      - Add blockers or hard parts to What Failed / Hard Parts
      - Add lessons to Lessons (for next project)
      - If the project is newly complete, set `status: complete` in frontmatter and add live URL

   c. **If a freelance client project was worked on:** Update `pillars/freelance/client-<name>.md`:
      - Tick completed checklist items
      - Add any decisions made
      - Add lessons if something was hard or went wrong

   d. **If a new AI portfolio project starts:** Copy `projects/_template.md` to `projects/<name>.md`, fill in what's known, update `index.md`.

   e. **If a new freelance client starts:** Copy `pillars/freelance/client-template.md` to `pillars/freelance/client-<name>.md`, fill in what's known, update `index.md`.

   f. **If a new technique, tool, or pattern was discovered:** Append to `pillars/ai-portfolio/learning-log.md`.

   g. **If Sunny Homemade content was planned:** Overwrite the "Active Week" section of `pillars/sunny-homemade/content-calendar.md`, move the old week to Archive, and append new ideas to `pillars/sunny-homemade/content-ideas.md`.

   h. **Update `index.md`** if any new files were created or a project status changed.

5. Commit and push all work to GitHub:
   - Run `git status` to see what changed
   - Stage all modified and new files: `git add -A`
   - Commit with a message that matches the session focus: `git commit -m "[focus line from step 1]"`
   - Push: `git push`
   - Report the commit hash and what was pushed

Keep the session summary under 150 words. Prioritize clarity over completeness.

You are running the `/absorb` command. Your job is to find a project, file, or repo — wherever it lives — bring it into Foreman, deeply analyze it, and iterate until it's production-ready.

---

## Phase 1 — Find it

The user may give you a name, a description, a partial path, or nothing at all. Search like you would in a terminal.

```bash
# Note: on macOS /tmp is a symlink to /private/tmp — search both
find ~ /private/tmp /tmp /var/tmp -maxdepth 4 -type d -iname "*<keyword>*" 2>/dev/null
find ~ /private/tmp /tmp /var/tmp -maxdepth 4 -type f -iname "*<keyword>*" 2>/dev/null
ls ~/Desktop ~/Downloads ~/Documents ~/Projects 2>/dev/null
```

If the user gave a URL (GitHub, GitLab, etc.), skip the search — that's the source.

Present what you found:

```
Found these matches:
  1. ~/my-shopify-theme         (directory, last modified 3 days ago)
  2. ~/Downloads/shopify.zip    (file, 2.4MB)

Which one? (or type a path / URL directly)
```

Wait for the user to confirm before continuing.

---

## Phase 2 — Check if already absorbed

Look for an existing Foreman project that matches — check both the directory listing and `_projects.md`:

```bash
ls <foreman-root>/
grep -i "<name>" <foreman-root>/_projects.md
```

If a match exists, tell the user:

```
"<name>" is already a Foreman project at <foreman-root>/<name>/.
Run /new-project if you want to start fresh, or open that directory to continue.
```

Stop here if already absorbed.

---

## Phase 3 — Absorb

Ask the user two questions (one at a time):

1. **Name:** "What should this project be called inside Foreman? (lowercase, no spaces — e.g. `shopify-theme`)"
2. **Visibility:** "Public plugin (shared via `plugins.public.yml`) or private project (git-ignored, your own repo)?"

Then copy the source. Use `rsync` to exclude dependency dirs and any existing `.git` history — the absorbed project gets a fresh git history inside Foreman:

```bash
rsync -a \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='.venv' \
  --exclude='venv' \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  --exclude='.DS_Store' \
  --exclude='dist' \
  --exclude='build' \
  --exclude='.next' \
  --exclude='vendor' \
  --exclude='*.zip' \
  <source-path>/ <foreman-root>/<name>/
```

If source is a git repo URL:
```bash
git clone --depth=1 <url> <foreman-root>/<name>
rm -rf <foreman-root>/<name>/.git
```

If source is a single file, create a minimal structure:
```bash
mkdir -p <foreman-root>/<name>/src
cp <source-path> <foreman-root>/<name>/src/
```

**On any failure during copy:** immediately remove the partial directory and tell the user what failed — do not leave a broken state.
```bash
rm -rf <foreman-root>/<name>
```

Initialize as its own git repo. Check git version first — `-b main` requires Git 2.28+:
```bash
git --version
```
If 2.28 or newer:
```bash
git -C <foreman-root>/<name> init -b main
```
If older:
```bash
git -C <foreman-root>/<name> init
git -C <foreman-root>/<name> symbolic-ref HEAD refs/heads/main
```
Then:
```bash
git -C <foreman-root>/<name> add .
git -C <foreman-root>/<name> commit -m "Initial import"
```

**If public plugin:** copy into `.claude/commands/` (if it's a runnable command) or `_skills/` (if it's a playbook/pattern). Ask if unclear.

---

## Phase 4 — Deep scan

Read everything. Do not skim.

Go through all files in the project and build a complete picture:

**What it is**
- What does this do? One sentence.
- What problem does it solve?
- Who is it for?
- What tech stack / language / framework?

**What works**
- List what's functional and solid.

**What's broken**
- Errors, bugs, missing error handling, hardcoded values that will fail in prod.

**What's missing**
- No README? No tests? No env config? No deploy setup? Missing features the user probably needs?

**What's weak**
- Code quality issues, security risks, performance problems, bad patterns.

**Production gap**
- What specifically needs to happen before this is production-ready?

Write a `spec.md` based on what you find using the standard Foreman spec template (`_templates/spec_output.md`). The milestones should map to closing the production gap.

Write a `CLAUDE.md` based on `_templates/project_claude.md`.

Show the user the scan summary and spec draft. Ask: **"Does this look right? Any corrections before I start fixing?"**

Wait for sign-off before Phase 5.

---

## Phase 5 — Iterate to production

Work through the spec milestones in order. For each task:

1. Fix it
2. Run `/verify-output` — self-review + independent critic
3. Fix what the critic flags
4. Mark the task complete in spec.md
5. Report to the user: what was fixed, what's next

After each milestone, pause and show the user:

```
Milestone <n> complete.

Fixed:
  - <item>
  - <item>

Remaining:
  - <milestone n+1 summary>

Continue? (yes / adjust scope / stop here)
```

Wait for the user's go-ahead before the next milestone.

---

## Phase 6 — Production gate

When all milestones are done, run a final `/verify-output` against the full M3 "Done when..." criteria from spec.md.

If it passes:

1. Update `_projects.md` — add the project with status `active`
2. Report:

```
<name> is production-ready.

  Spec:     <foreman-root>/<name>/spec.md
  Project:  <foreman-root>/<name>/

Next steps:
  - Push to your private repo (git remote add origin <url> && git push -u origin main)
  - Run /brew-release if you want to distribute it via Homebrew
```

If it doesn't pass — loop back to Phase 5 and keep going.

---

## Rules

- Never skip the scan. Even if the project looks simple, read everything.
- Never assume. If something is unclear (visibility, name, scope), ask.
- Never mark production-ready without a passing /verify-output against the spec criteria.
- Never copy `.git` history — absorbed projects always get a fresh git history.
- Never copy `node_modules`, `.venv`, `dist`, `build`, or similar dependency/output dirs.
- Always roll back (remove the partial directory) if the copy or git init fails.
- Keep the user in the loop at each milestone — don't run ahead without sign-off.
- If the source is a GitHub repo you can't clone (private, auth required), tell the user and ask them to clone it manually first.

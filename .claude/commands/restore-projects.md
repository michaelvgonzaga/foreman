You are running the `/restore-projects` command. Your job is to pull the user's existing Foreman projects from their GitHub account down into this local workspace — for setting up a new device, or recovering projects that aren't cloned here yet. Bring remote state in **intact**, push **nothing**, and skip anything redundant or unrelated.

## Step 0 — Preconditions

```bash
gh auth status        # must be logged in; if not, tell the user to run: gh auth login
```

Determine the foreman root (the directory containing this `_skills/` and `_templates/`). Call it `<foreman-root>`.

## Step 1 — Enumerate candidate repos

List repos the user owns or collaborates on (owned + permitted):

```bash
gh repo list --json nameWithOwner,name,isPrivate,url --limit 300
gh api user/repos --paginate -q '.[] | "\(.full_name)\t\(.private)"'   # includes collaborator/org repos
```

## Step 2 — Keep only Foreman projects (skip redundant/unrelated)

A repo is a Foreman project only if it has **both `spec.md` and `CLAUDE.md` at its root**. Check each candidate cheaply via the API — do not clone to find out:

```bash
gh api "repos/<owner>/<repo>/contents/spec.md"   --silent 2>/dev/null && \
gh api "repos/<owner>/<repo>/contents/CLAUDE.md" --silent 2>/dev/null && echo "foreman-project"
```

Drop everything else (e.g. infrastructure, dotfiles, unrelated tools). Also drop the framework repos themselves (`foreman`, `homebrew-*`).

## Step 3 — Classify each Foreman project

For each project repo, decide its action by what's already on disk:

- **Missing locally** (`<foreman-root>/<name>` absent) → **clone** it.
- **Present and clean** → `git fetch` + `git pull --ff-only` to bring remote updates in intact. If already up to date, skip (redundant).
- **Present but dirty** (uncommitted changes) → **skip with a warning**; never clobber local work. Tell the user to commit/stash first.
- **Present but diverged** (`pull --ff-only` fails) → **skip with a warning**; do not force or merge. Surface the divergence.

## Step 4 — Preview, then act

Show the plan before doing anything destructive-adjacent:

```
Found N Foreman projects on your account:
  clone   → mjolnir            (not present locally)
  update  → cse-cli            (behind 2 — fast-forward)
  skip    → dashboards         (already up to date)
  skip    → invoicer           (local has uncommitted changes — commit first)

Proceed? (yes / pick a subset)
```

Wait for confirmation, then for each project:

```bash
# clone
git clone <repo-url> "<foreman-root>/<name>"
# or update an existing clean clone
git -C "<foreman-root>/<name>" pull --ff-only
```

Cloned projects land as top-level dirs and are auto-ignored by the foreman `.gitignore` pattern — they stay private to this workspace.

## Step 5 — Refresh the local index

For every project now present, ensure it has a row in `_projects.md` (create `_projects.md` from `_templates/projects.md` first if it doesn't exist — it is git-ignored local state). Read each project's `spec.md`/`CLAUDE.md` to fill visibility, status, and the one-line goal. Do not duplicate rows that already exist.

## Step 6 — Report

```
Restored into <foreman-root>:
  cloned:  mjolnir, dashboards
  updated: cse-cli
  skipped: invoicer (dirty), infra-scripts (not a Foreman project)

_projects.md updated. Nothing was pushed.
```

## Rules

- **Pull only — never push.** This command brings remote state down; it changes nothing on any remote.
- Never overwrite local work: skip dirty or diverged clones, fast-forward only.
- Never clone non-Foreman repos or the framework repos themselves.
- If `gh` isn't authenticated or has no network, stop with a clear message — do not guess.
- Keep the user in control: show the plan and get confirmation before cloning/updating.

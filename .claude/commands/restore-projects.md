Pull Foreman projects from GitHub into this workspace — clone what's missing, fast-forward the rest, push nothing.

## Step 0 — Preconditions

Check `gh auth status`. If not authenticated, tell the user to run `gh auth login` and stop.

```bash
gh auth status
```

Determine the foreman root (the directory containing this `_skills/` and `_templates/`). Call it `<foreman-root>`.

## Step 1 — Enumerate candidate repos

List all repos: `gh repo list --json nameWithOwner,name,isPrivate,url --limit 300` (add `gh api user/repos --paginate` to catch org/collaborator repos not in the list).

## Step 2 — Keep only Foreman projects (skip redundant/unrelated)

A repo is a Foreman project only if it has both `spec.md` and `CLAUDE.md` at its root. Check via API before cloning. Skip framework repos (`foreman`, `homebrew-*`).

## Step 3 — Classify each Foreman project

For each project repo, decide its action by what's already on disk:

- **Missing locally** (`<foreman-root>/<name>` absent) → **clone** it.
- **Present and clean** → `git fetch` + `git pull --ff-only` to bring remote updates in intact. If already up to date, skip (redundant).
- **Present but dirty** (uncommitted changes) → **skip with a warning**; never clobber local work. Tell the user to commit/stash first.
- **Present but diverged** (`pull --ff-only` fails) → **skip with a warning**; do not force or merge. Surface the divergence.

## Step 4 — Preview, then act

Show a plan (clone/update/skip with reasons) and wait for confirmation before acting.

Then for each project:

```bash
# clone
git clone <repo-url> "<foreman-root>/<name>"
# or update an existing clean clone
git -C "<foreman-root>/<name>" pull --ff-only
```

Cloned projects are auto-ignored by `.gitignore` and stay private to this workspace.

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

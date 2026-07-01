Pull 4ORMan projects from GitHub into this workspace — clone what's missing, fast-forward the rest, push nothing.

## Step 0 — Preconditions

Check GitHub auth. If not authenticated, tell the user to run `gh auth login` and stop.

```bash
# With 4orman-tools (preferred):
4orman-tools gh-user
# Fallback:
gh auth status
```

Determine the 4orman root (the directory containing this `_skills/` and `_templates/`). Call it `<4orman-root>`.

## Step 1 — Enumerate and classify repos

```bash
# With 4orman-tools (preferred — lists repos, checks spec.md, and isLocal in one call):
4orman-tools list-projects <4orman-root>
# Fallback:
gh repo list --json nameWithOwner,name,url --limit 100
```

The JSON returns `[{name, url, isForeman, isLocal}]`. Filter to `isForeman: true` entries — those are the candidates to restore.

## Step 2 — Keep only 4ORMan projects (skip redundant/unrelated)

When using the fallback: a repo is a 4ORMan project only if it has `spec.md` at its root. Check via `gh api repos/<owner>/<name>/contents/spec.md` before cloning. Skip framework repos (`4orman`, `homebrew-*`).

## Step 3 — Classify each 4ORMan project

For each project repo, decide its action by what's already on disk:

- **Missing locally** (`<4orman-root>/<name>` absent) → **clone** it.
- **Present and clean** → `git fetch` + `git pull --ff-only` to bring remote updates in intact. If already up to date, skip (redundant).
- **Present but dirty** (uncommitted changes) → **skip with a warning**; never clobber local work. Tell the user to commit/stash first.
- **Present but diverged** (`pull --ff-only` fails) → **skip with a warning**; do not force or merge. Surface the divergence.

## Step 4 — Preview, then act

Show a plan (clone/update/skip with reasons) and wait for confirmation before acting.

Then for each project:

```bash
# clone
git clone <repo-url> "<4orman-root>/<name>"
# or update an existing clean clone
git -C "<4orman-root>/<name>" pull --ff-only
```

Cloned projects are auto-ignored by `.gitignore` and stay private to this workspace.

## Step 5 — Refresh the local index

For every project now present, ensure it has a row in `_projects.md` (create `_projects.md` from `_templates/projects.md` first if it doesn't exist — it is git-ignored local state). Read each project's `spec.md`/`CLAUDE.md` to fill visibility, status, and the one-line goal. Do not duplicate rows that already exist.

## Step 6 — Report

```
Restored into <4orman-root>:
  cloned:  mjolnir, dashboards
  updated: cse-cli
  skipped: invoicer (dirty), infra-scripts (not a 4ORMan project)

_projects.md updated. Nothing was pushed.
```

## Rules

- **Pull only — never push.** This command brings remote state down; it changes nothing on any remote.
- Never overwrite local work: skip dirty or diverged clones, fast-forward only.
- Never clone non-4ORMan repos or the framework repos themselves.
- If `gh` isn't authenticated or has no network, stop with a clear message — do not guess.
- Keep the user in control: show the plan and get confirmation before cloning/updating.

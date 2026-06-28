# GitHub Repo

**Works well for:** Creating a GitHub repo for a new project — public or private — and wiring it up as the git remote in one step
**Confidence:** High

## The pattern

### Step 1 — Check prerequisites

```bash
# With foreman-tools (preferred — auth check + username in one call):
foreman-tools gh-user
# Fallback:
gh auth status
gh api user --jq '.login'
```

If `authenticated` is false (or fallback exits non-zero), tell the user (`brew install gh` / `gh auth login`) and stop.

### Step 2 — Confirm details

Confirm name, visibility, and GitHub username (from `foreman-tools gh-user` `.login` field, or `gh api user --jq '.login'`) before creating anything.

### Step 3 — Create the repo

```bash
gh repo create <repo-name> \
  --<public|private> \
  --source <project-path> \
  --remote origin \
  --push
```

`--source` points to the project directory. This creates the repo, sets `origin`, and pushes the initial commit in one step.

If the repo name is already taken under that account, stop and tell the user — do not pick an alternative name automatically.

### Step 4 — Confirm

Print:

```
GitHub repo created:
  https://github.com/<owner>/<repo-name>
  Visibility: <public / private>
  Remote:     origin → https://github.com/<owner>/<repo-name>

First push done. Future pushes: git push
```

Update the project's `CLAUDE.md` Tools & Resources section with the repo URL.

## When to use it

- Inside `/new-project` — after scaffolding and spec sign-off, when the user confirms visibility
- Inside `/absorb` — after the project is copied in and git is initialized
- Any time a project needs a GitHub remote created from scratch

## When NOT to use it

- When the project already has a remote (`git remote -v` shows one) — don't overwrite it
- When the user says they'll handle GitHub setup themselves
- When `gh` is not available and the user doesn't want to install it — note the remote URL they'll need and move on

## Rules

Never create the repo without confirming name and visibility first. Always update `CLAUDE.md` with the repo URL after creation.

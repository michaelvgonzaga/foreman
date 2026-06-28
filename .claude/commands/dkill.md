You are running `/dkill`. Check if Foreman has updates available from the remote repo, show what changed, and apply them if the user confirms.

## Step 1 — Check remote for updates

```bash
git -C <foreman-root> fetch origin main --quiet
git -C <foreman-root> rev-parse HEAD
git -C <foreman-root> rev-parse origin/main
```

If both hashes are the same — Foreman is up to date. Print:

```
Foreman is up to date. (local matches origin/main)
```

Stop here.

## Step 2 — Show what changed

If the hashes differ, show a summary of what's incoming:

```bash
git -C <foreman-root> log HEAD..origin/main --oneline
git -C <foreman-root> diff HEAD origin/main --stat
```

Print:

```
Foreman update available.

Commits coming in:
  <commit list>

Files changing:
  <diff stat>
```

Ask: **"Apply this update? (yes/no)"**

Wait for the user's answer before continuing.

## Step 3 — Apply the update

If yes:

Check for local uncommitted changes first:

```bash
git -C <foreman-root> status --porcelain
```

If there are uncommitted changes, stop and tell the user:

```
Cannot update — you have uncommitted local changes in Foreman:
  <list of changed files>

Commit or stash them first, then run /dkill again.
```

Otherwise pull:

```bash
git -C <foreman-root> pull origin main --ff-only
```

If `--ff-only` fails (diverged history), stop and tell the user:

```
Cannot fast-forward — local and remote histories have diverged.
This needs manual resolution: cd <foreman-root> && git log --oneline HEAD..origin/main
```

Do not force-pull or reset. Let the user resolve it.

## Step 4 — Confirm

Print:

```
Foreman updated to <new-hash>.

What changed:
  <commit list from Step 2>

All commands and skills are now current.
```

## Rules

- Never pull without showing the user what's incoming first.
- Never force-pull, reset --hard, or discard local changes.
- If fast-forward fails, stop — do not attempt merges or rebases.
- Run this check automatically at the start of each session by adding it to the session opening behavior in CLAUDE.md if the user asks for that.

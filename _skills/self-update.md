# Self-Update

**Works well for:** Keeping Foreman current by checking for upstream changes on every session start or on demand
**Reference implementation:** Foreman framework (2026-06-28)
**Confidence:** High

## The pattern

At the start of every session (or when the user asks), silently check if Foreman is behind its remote and surface the result before doing anything else.

```bash
# 1. Fetch without merging
git -C <foreman-root> fetch origin main --quiet

# 2. Compare local vs remote
LOCAL=$(git -C <foreman-root> rev-parse HEAD)
REMOTE=$(git -C <foreman-root> rev-parse origin/main)
```

**If equal** — up to date, say nothing and continue.

**If different** — surface before starting work:

```
⚠ Foreman update available.

Changes incoming:
  <git log HEAD..origin/main --oneline>

Files affected:
  <git diff HEAD origin/main --stat>

Update now? (yes / no — I'll remind you again next session if no)
```

If yes — check for local uncommitted changes first:

```bash
git -C <foreman-root> status --porcelain
```

If clean, pull:

```bash
git -C <foreman-root> pull origin main --ff-only
```

If dirty — tell the user which files are modified and stop. Do not pull over uncommitted changes.

If `--ff-only` fails (diverged) — stop, show the user the divergence, do not force anything.

## When to use it

- At the top of every session when working inside Foreman
- Whenever the user says "check for updates", "is foreman current", "update foreman", or similar
- Before running `/new-project` or `/absorb` — stale commands can produce outdated behavior

## When NOT to use it

- When the user is mid-task and explicitly says not to interrupt
- In offline environments with no git remote access — skip silently if `git fetch` times out

## Rules

- Never pull without showing what's incoming first
- Never force-pull, reset --hard, or discard local changes
- Fast-forward only — if history has diverged, surface it and stop
- If the fetch itself fails (no network, auth error), skip silently — do not block the session over a connectivity issue

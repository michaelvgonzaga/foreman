# Self-Update

**Works well for:** Keeping Foreman current by checking for upstream changes on every session start or on demand
**Confidence:** High

## The pattern

At the start of every session (or when the user asks), silently check if Foreman is behind its remote.

### With foreman-tools (preferred)

If `foreman-tools` is in PATH, use it — one call, no shell reasoning:

```bash
git -C <foreman-root> fetch origin main --quiet
foreman-tools status <foreman-root>
```

Read the JSON: if `upToDate` is `true`, say nothing and continue. If `false`, surface the update prompt below using `behindBy` for the commit count.

### Without foreman-tools (fallback)

```bash
# 1. Fetch without merging
git -C <foreman-root> fetch origin main --quiet

# 2. Compare local vs remote
LOCAL=$(git -C <foreman-root> rev-parse HEAD)
REMOTE=$(git -C <foreman-root> rev-parse origin/main)
```

**If equal** — up to date, say nothing and continue.

**If different** — surface before starting work.

## Update prompt (when behind)

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

- **Automatically at the start of every session** — wired into `CLAUDE.md` guardrails, no manual trigger needed
- Whenever the user says "check for updates", "is foreman current", "update foreman", or similar
- Before running `/new-project` or `/absorb` — stale commands can produce outdated behavior

## When NOT to use it

- When the user is mid-task and explicitly says not to interrupt
- In offline environments with no git remote access — skip silently if `git fetch` times out

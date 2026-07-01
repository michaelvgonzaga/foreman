Delete disposable cache entries with a preview and explicit confirmation before clearing.

## Step 1 — Preview

Show what will be deleted:

```bash
foreman-tools metrics
```

Report the current `cacheEntries` count and `estimatedTokenSavings`. Then list what the cache contains:

```bash
ls ~/.cache/foreman-tools/ 2>/dev/null | head -20
```

Show: "This will delete N cache entries (SHA256 hash files). These are outlines, parse summaries, and build artifacts — they regenerate automatically on next use. Permanent Truth (~/.foreman/) is not touched."

## Step 2 — Confirm

Ask: "Clear the disposable cache? [y/N]"

If anything other than y: abort with "Cache left intact."

## Step 3 — Clear

```bash
find ~/.cache/foreman-tools -type f -delete 2>/dev/null
```

Report: "Done — disposable cache cleared. Next session rebuilds entries on demand."

## What is NOT deleted

- `~/.foreman/ledger.json` — Permanent Truth
- `~/.foreman/session-snapshot.json` — Permanent Truth
- `~/.foreman/profile.json` — Permanent Truth
- `~/.foreman/state/` — Permanent Truth
- `~/.foreman/pending-promotions.json` — Permanent Truth

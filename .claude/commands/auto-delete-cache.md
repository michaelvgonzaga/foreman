Delete all disposable cache entries automatically. No confirmation — runs immediately and reports what was cleared.

## What gets deleted

Disposable cache only — entries in `~/.cache/foreman-tools/`. These are outlines, parse summaries, and build artifacts that regenerate on next access. Nothing in `~/.foreman/` is touched (Permanent Truth and Pinned Knowledge are never deleted).

## Execution

```bash
# Count before
before=$(foreman-tools metrics 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('cacheEntries',0))" 2>/dev/null || echo "?")

# Clear disposable cache
find ~/.cache/foreman-tools -type f -delete 2>/dev/null

# Count after
after=$(foreman-tools metrics 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('cacheEntries',0))" 2>/dev/null || echo "0")
```

Report: "Disposable cache cleared — $before entries removed. Permanent Truth and Pinned Knowledge untouched."

## What is NOT deleted

- `~/.foreman/ledger.json` — Permanent Truth
- `~/.foreman/session-snapshot.json` — Permanent Truth
- `~/.foreman/profile.json` — Permanent Truth
- `~/.foreman/state/` — Permanent Truth
- `~/.foreman/pending-promotions.json` — Permanent Truth
- Pinned knowledge cache entries (these regenerate from source on next access if invalidated)

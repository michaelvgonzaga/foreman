# Foreman Workers

Language-specific workers invoked by `foreman-tools worker-run`. Each worker:
- Reads config from **argv[1] as JSON** (when invoked via `worker-run`); falls back to stdin for direct testing
- Writes result to **stdout as JSON**
- Writes errors to **stderr** (never stdout)
- Exits 0 on success, 1 on hard failure
- Uses **stdlib only** — no pip install, no npm install, no go mod tidy

Claude invokes via:
```bash
foreman-tools worker-run python _workers/web/crawl.py '{"url":"https://example.com","max_depth":1}'
```

Zig receives `{ lang, exit_code, stdout, stderr, duration_ms }` — Claude reads JSON, never raw text.

---

## Directory Structure

```
_workers/
├── web/          ← HTTP, crawl, fetch, parse
│   └── crawl.py
├── sys/          ← process, disk, network analysis
└── code/         ← AST, deps, complexity, linting
```

---

## Worker Standards (Senior Quality)

Every worker must:

1. **Single responsibility** — one task, one file, no shared state
2. **Typed I/O contract** — document every input field and output field in the module docstring
3. **Graceful errors** — never crash; return `{"success": false, "error": "..."}` on failure
4. **Resource limits** — cap memory, time, and output size explicitly
5. **Idempotent** — same input always produces same output (no side effects)
6. **No external deps** — stdlib only; if a dep is truly required, document why and gate on it
7. **Rate limiting** — any worker that touches a network adds configurable delay
8. **Robots.txt** — any web crawler respects robots.txt and identifies itself with a UA string

---

## Adding a New Worker

Use `/new-worker`. It will:
1. Check if `foreman-tools capability-check` already covers the need
2. Spec the worker (inputs, outputs, constraints, language choice)
3. Scaffold the file with the standard header
4. Test it via `foreman-tools worker-run`
5. Register it here

---

## Worker Catalog

| Worker | Lang | Invocation | Purpose |
|--------|------|-----------|---------|
| `web/crawl.py` | Python 3 | `worker-run python _workers/web/crawl.py '<json>'` | Depth-limited BFS crawler — robots.txt, rate limiting, structured page data |

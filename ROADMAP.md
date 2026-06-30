# Foreman Roadmap

## Active Work — pick up here after any restart

**Wave:** 1 — Token Savings  
**Wave:** 2 — Speed  
**Wave:** 2 — Speed  
**Wave:** 2 — Speed  
**Current subcommand:** `project-state` (W2-C) → next to implement.  
**Completed Wave 1:** `compat-check` ✅, `run-tests` ✅, `build` ✅, `env-inspect` ✅, `symbol-find` ✅, `secret-scan` ✅  
**Completed Wave 2 so far:** `device-scan` (W2-F, v0.36.0) ✅, `delta-context` (W2-D, v0.37.0) ✅, `git-cache` (W2-B, v0.38.0) ✅  
**Repo:** `foreman-tools/` is a separate git repo — check its own CHANGELOG for version state (current: v0.38.0).

---

## Architecture Principle

```
Claude decides.
Foreman orchestrates.
Zig verifies.
Specialist workers execute.
Tests decide.
```

Foreman is Claude's deterministic engineering runtime. Foreman frees Claude to think. Foreman turns repeated AI reasoning into permanent, validated engineering capability.

---

## Execution Path (Target)

```
User → Claude → foreman-tools API → Foreman Core / Zig → Capability Router
  ├─ Cache
  ├─ Zig native
  ├─ Existing CLI
  ├─ Python / Node / Go / Rust / Shell / Docker worker
  └─ Claude-designed missing plugin
→ Validation Engine → Quality Gate → Context Builder / Optimizer
→ Distilled evidence to Claude → Claude reasons
→ Production Readiness verdict → User
```

**Promotion rule:** No Critical. No High. No Medium. Tests pass. Schema valid. Output accurate. Rollback available.

---

## Current State — Module Coverage (v1.26.0)

| Module | Status | Subcommands / Skills Built |
|--------|--------|---------------------------|
| 0 — Architecture Constitution | M2 done | `api-schema.md` (JSON output contract) |
| 5 — Filesystem Engine | M1–M4 done | `list-dir`, `find-files`, `file-stats`, `file-hash` |
| 6 — Project Index | M1–M3 done | `scan`, `outline`, `deps` |
| 7 — Git Engine | M1–M3 done | `git-diff`, `changes-preview`, `commits`, `status` |
| 8 — Parser Engine | M1, M4 done | `json-query`, `yaml-query`, `toml-query`, `parse-stack` |
| 12 — Context Builder | M1–M3 done | `context-scan`, `context-evidence`, `context-changed` |
| 13 — Context Optimizer | M1 done | `context-rank` |
| 14 — Cache Engine | M1–M4 done | `file-hash`, `cache-check`, `cache-store`, `cache-fetch` |
| 22 — Claude Interface | ongoing | All subcommands, stable JSON API |

Modules 1–4, 9–11, 15–21, 23–29 not yet started.

---

## Roadmap — Prioritized by Token Savings → Speed → Quality

### Wave 1 — Token Savings (Biggest ROI First)

Each of these eliminates multi-step Claude-side reasoning loops. One subcommand replaces detect + run + parse + read.

#### W1-A: `compat-check` — Module 31 M1–M3 ← IMPLEMENT NEXT
**Problem:** When Homebrew, Zig, git, or other tools auto-update, Foreman can silently break — wrong JSON output, build failures, subcommand errors — and the user has no warning until something goes wrong mid-session.  
**Fix:** A pure Zig, zero-token, ~20ms guard that runs before the first user prompt. Compares current tool versions to a stored baseline. If drift is detected, surfaces rollback advice and pauses — the user knows exactly what changed, why it might break, and how to roll back before they type a single character.  
**Output:** `{ ok: bool, baselineAge: "2026-06-30", drifted: [{tool, was, now, risk, rollback}], advice: string }`  
**Milestones:**
- M1: `compat-check --baseline` — snapshot current tool versions to `~/.foreman/compat-baseline.json` (zig, git, gh, homebrew, node, python3, foreman_tools, os, arch)
- M2: `compat-check` (default) — compare current vs baseline; return `{ ok, drifted }` with rollback commands for each drifted tool
- M3: `compat-check --update-baseline` — after user confirms drift is safe, update baseline to current versions; push verified combination to `foreman-env` repo (opt-in, same consent flow as device-scan)

**Status: ✅ Implemented v0.30.0** — `compat-check`, `compat-check --baseline`, `compat-check --update-baseline` all live in PATH.

#### W1-C: `run-tests <path>` — Module 18 M1–M3
**Saves:** Test framework detection + command run + raw output parsing + failure reading.  
**Output:** `{ framework, passed, failed, errors: [{file, line, message}], duration }`  
**Milestones:**
- M1: Detect test framework (Jest, pytest, go test, cargo test, bats)
- M2: Run tests, capture exit code + stdout/stderr
- M3: Parse failures into structured `{file, line, message}` per framework

#### W1-D: `build <path>` — Module 17 M1–M4
**Saves:** Build system detection + command run + compiler error parsing.  
**Output:** `{ tool, success, errors: [{file, line, col, message, severity}], warnings, duration }`  
**Milestones:**
- M1: Detect build system (Cargo, npm/yarn, go build, Makefile, Zig build)
- M2: Discover build command
- M3: Run build, capture output
- M4: Parse errors/warnings into structured JSON per toolchain

#### W1-E: `env-inspect <path>` — Module 4 M1–M4
**Saves:** Multiple `which`, `--version`, and manifest reads to discover project stack.  
**Output:** `{ languages: [{name, version, present}], packageManagers, missing, envVars }`  
**Milestones:**
- M1: Detect languages (Go, Python, Node, Rust, Zig, Ruby, Java)
- M2: Version checks
- M3: Package manager checks (npm, pip, cargo, brew)
- M4: Missing dependency report

#### W1-F: `symbol-find <path> <name>` — Module 6 M2
**Saves:** Claude running grep + reading N files to locate a symbol.  
**Output:** `{ definition: {file, line}, references: [{file, line}], kind }`  
**Milestones:**
- M1: Definition lookup (function, class, struct, const)
- M2: Reference listing across project

#### W1-G: `secret-scan <path>` — Module 19 M1
**Saves:** Manual inspection + reading files to check for accidental secrets.  
**Output:** `{ findings: [{file, line, pattern, severity}] }`  
**Milestones:**
- M1: Scan for hardcoded secrets (API keys, tokens, passwords by pattern)
- M2: `.env` file cross-check (keys that appear in source)

---

### Wave 2 — Speed

Reduce latency by caching, state persistence, and shrinking context delivery.

#### W2-A: Cache warm-up + atomic writes — Module 14 M3–M5
**Problem:** Cache exists but nobody calls it. 4 entries in the wild. No session warm-up pattern.  
**Fix 1 — CLAUDE.md guardrail (done):** Before reading any large file, call `cache-fetch` first. Standard sub-keys documented so hits accumulate across sessions.  
**Fix 2 — Atomic writes (done v0.30.0):** `writeCacheEntry` and `computeCacheStore` now write to `.tmp` then `std.c.rename` atomically. Power loss = safe miss, no corrupted entry.  
**Fix 3 — Project scan cache:** `foreman-tools scan` and `context-scan` re-run from scratch every session. Add `cache-fetch <project-root>/build.zig "scan"` pattern — skip the full walk when no files changed.

#### W2-B: `git-cache <path>` — Module 14 M3
Cache git status/log/branch — invalidated on HEAD change. Eliminates repeated git subprocess calls within a session.

#### W2-C: `project-state <path>` — Module 28 M1–M2
Persist project state and decision history across sessions.  
**Output:** `{ decisions: [{date, what, why}], knownPatterns, lastBuildResult, lastTestResult }`

#### W2-D: `delta-context <path> [ref]` — Module 13 M2
Delta-only context: changed symbols + their callers, not full file diffs.  
**Output:** `{ symbols: [{name, file, before, after, callers}] }`

#### W2-E: `shell-run <cmd>` with structured output — Module 9 M1–M4
Safe shell execution: timeout, retry, exit-code parse, destructive-command check before run.  
**Output:** `{ exitCode, stdout, stderr, duration, timedOut }`

#### W2-F: `device-scan` — Module 30 M1–M2
**Problem:** Every new session (and every new device) re-discovers the environment — hardware, installed tools, optimal build flags. Tokens burned re-running `doctor` + version checks every time.  
**Fix M1 — Local profile:** `foreman-tools device-scan` snapshots hardware + tools + optimal settings → `~/.foreman/profile.json`. Claude reads this at session start (cached by `cache-fetch`) instead of running any shell commands.  
**Fix M2 — Community profile (`foreman-env` repo):** Public repo stores one JSON per hardware profile (e.g. `apple_m3_pro_36gb_macos_arm64.json`). Contains hardware specs and optimal settings only — **no paths, no usernames, no personal data**. When a new device is profiled, Foreman shows the user exactly what will be shared and asks for consent before pushing. A user on an M3 Pro gets pre-validated optimal flags on day 1 without burning any tokens to discover them.  
**Output:** `{ profile_id, hardware: {cpu, cores, ram_gb, os, arch}, tools: {zig/git/gh/…}, optimal: {zig_build_flags, bottleneck, git_spawn_ms_estimate}, shell, scanned_at }`  
**Compat ledger in `foreman-env`:** When `compat-check --update-baseline` runs, Foreman pushes the verified tool-version combination to `foreman-env` alongside the hardware profile — so any future install with the same hardware can skip the version-discovery phase entirely. Format: `{ profile_id, compat_matrix: [{ tools: {zig, git, gh, homebrew, ...}, status: "verified", tested_at }] }`. Same consent + no-PII rules apply.  
**Consent rule:** Foreman never pushes to `foreman-env` without explicit user confirmation. Shows a diff of what will be shared. Community benefit is opt-in, not default.

---

### Wave 3 — Quality

Enforce correctness gates so Claude gets verdicts, not raw data.

#### W3-A: `quality-gate <path>` — Module 15 M1–M3
Aggregate test + build + lint results into a severity-blocked verdict.  
**Output:** `{ verdict: pass|fail, critical: [], high: [], medium: [], low: [] }`  
Blocks on Critical/High. Warns on Medium. Passes on Low/Info.

#### W3-B: `validate-schema <file> <schema>` — Module 16 M5
Schema compliance check — pass/fail + violations without Claude reading both files.  
**Output:** `{ valid, violations: [{path, expected, got}] }`

#### W3-C: `prod-ready <path>` — Module 24 M1–M5
Composite verdict: build pass + test pass + quality gate + deps + security scan.  
**Output:** `{ ready: bool, blockers: [], warnings: [] }`  
This is the final gating command before any deploy or promote.

---

### Wave 4 — Architecture Completion

Modules needed to reach the full execution path.

| Module | Priority | Key capability unlocked |
|--------|----------|------------------------|
| 1 — Foreman Core | High | CLI entrypoint, command router, module registry |
| 2 — Capability Registry | High | Know what's natively available vs. needs a plugin |
| 3 — Tool Router | High | Cache → Zig → CLI → Worker → Claude fallback chain |
| 10 — Language Worker Manager | Medium | Python/Node/Go/Rust/Shell/Docker workers |
| 11 — Plugin System | Medium | Plugin manifest, discovery, execution, versioning |
| 20 — Multi-Agent Coordinator | Medium | Context slicing, shared state, result merge |
| 21 — Capability Promotion | Medium | Detect repeated task → propose → validate → register |
| 23 — Reporting Layer | Low | Status, confidence, issue, artifact, next-action reports |
| 26 — Telemetry / Metrics | Low | Token savings, cache-hit rate, latency, ROI dashboard |
| 27 — Permissions / Sandbox | Low | Install, destructive, deploy approval gates |
| 29 — Rollback / Recovery | Low | Change snapshots, plugin rollback, safe revert |

---

## Foreman Framework Roadmap (Separate from foreman-tools)

### Commands + Skills
- `/run-tests` — trigger `foreman-tools run-tests`, surface structured failures to Claude
- `/build` — trigger `foreman-tools build`, surface errors with file:line navigation
- `/quality-gate` — run full quality gate before any promote/merge/release
- `/prod-ready` — composite production readiness check before deploy

### Framework Maturity
- Plugin protocol formalized (Module 11 milestone integration)
- Worker protocol for language workers (Module 10)
- Multi-agent context slicing wired into `/new-project` (Module 20)
- Capability promotion loop in `/verify-output` (Module 21)

---

## Versioning Alignment

| Version Range | Theme |
|---------------|-------|
| v1.0–v1.26 (current) | Foundation: filesystem, git, context, cache, parser subcommands |
| v1.27–v1.35 | Wave 1: run-tests ✅, build ✅, env-inspect, symbol-find, secret-scan |
| v1.36–v1.42 | Wave 2: git-cache, project-state, delta-context, shell-run |
| v1.43–v1.50 | Wave 3: quality-gate, validate-schema, prod-ready |
| v2.0 | Wave 4: Foreman Core, Capability Registry, Tool Router, Workers |

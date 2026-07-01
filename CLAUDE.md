# App Factory

Base of operations. Every project lives here. Every project follows the 3-layer framework.

> **4ORMan exists to reduce the token and time cost of Claude reasoning about engineering state. It fails if a user session starts slower, burns more tokens, or produces a less reliable output than without it. It succeeds when session-start is under 200ms, cache hit rate exceeds 80%, and Claude never has to shell-parse a git command.**

---

## First-time setup (after cloning)

Run `/setup`. It reads `plugins.public.yml` (public plugins, tracked) and `plugins.local.yml` (your private repos, git-ignored) and clones whatever your git credentials can reach. If you have private repos to add, copy `plugins.local.yml.example` → `plugins.local.yml` and fill it in before running.

## Starting a new project

Run `/new-project`.

## Working on an existing project

Read the project's `CLAUDE.md` and `spec.md` before making any changes.

---

## The 3-Layer Framework

### Layer 1 — The Spec
Run `/new-project`. Spec interview, scaffolding, explicit sign-off before any work begins.

### Layer 2 — The Verifier
Run `/verify-output` before marking any output complete — self-review + critic agent.

---

## Guardrails

### Always do (autopilot)
**At the start of every session, in order:**
1. Check `$FOREMAN_MODE` (set once by `4orman-ai` at launch, from the Manual/Auto prompt). `autopilot` (or unset) → decide and build without asking, per the exceptions below. `gate` → surface a proposal and wait before acting. `/gate` flips it for the rest of this terminal session only.
2. If `.first-run` exists in the workspace root, run `/first-run` immediately and complete it before doing anything else.
3. Run `4orman-tools compat-check` BEFORE doctor. If `ok: false`, surface the `advice` string and each drifted tool's `rollback` command, then pause — do not proceed until user confirms or rolls back. Zero Claude tokens; the advice is pre-computed Zig output.
4. Run `4orman-tools doctor` via Bash. If it fails (binary missing), prompt once: "`4orman-tools` not found — run `brew install michaelvgonzaga/4orman/orman-tools`." If it succeeds, use the JSON to check `claude`, `git`, and `gh`. Then immediately verify the binary is current by running `4orman-tools cache-fetch /dev/null x 2>&1`— if the output contains "unknown subcommand" instead of JSON, surface once: "Homebrew binary is stale (missing cache + context subcommands). Run `/brew-release` to fix." and skip all `cache-fetch`, `cache-store`, `cache-check`, `outline`, `context-*`, `yaml-query`, and `deps` calls for this session.
5. Apply `_skills/self-update.md` — silently fetch origin, compare with local, and surface any incoming changes. If fetch fails (no network), skip silently.
6. If binary is current (not stale per above), check `~/.4orman/profile.json` via `4orman-tools cache-fetch ~/.4orman/profile.json device` — if `hit: true`, load the stored hardware/tools/optimal profile and skip tool-detection shell calls. If miss, continue normally.
7. Run `4orman-tools ledger check-stale` — if any entries are stale (`is_stale: true`), surface them to the user and re-validate each via the scoring protocol before acting on them. Stale entries must not be used as ground truth.

- **Zig-first (non-negotiable):** Before any action — data lookup, shell command, file read, build, test — check if a `4orman-tools` subcommand covers the need. One JSON call (~10–50ms) replaces 200–2000 tokens of Claude reasoning. Break-even or better → use Zig. When in doubt: `4orman-tools capability-check <what>` returns `{ available, subcommand }`. If no native subcommand exists: (1) check `_workers/` for an existing language worker → invoke via `4orman-tools worker-run <lang> _workers/<path> '<json>'`; (2) if no worker exists and the need is language-specific (web, ML, concurrency, JS ecosystem), run `/new-worker` to scaffold a permanent stdlib-only worker following senior-quality standards — one file, typed I/O contract, graceful errors, no external deps; (3) if pure computation with no existing coverage, use `4orman-tools shell-run <cmd>` so output is JSON, never raw text; (4) run `4orman-tools capability-promote <cmd>` — if the need appears 2+ times this session or score is high, implement it as a permanent Zig subcommand immediately: write to `4orman-tools/src/root.zig` + `main.zig`, bump VERSION, run `zig build -Doptimize=ReleaseSafe` so it is live in this session, then call `4orman-tools promotion-queue add <name> <description>` to queue it for the next brew-release. The Stop hook will surface pending entries at session end. Claude decides. Zig orchestrates. Workers execute. Claude reads structured data. Repeated needs become permanent Zig subcommands or permanent workers.
- **Before any action that touches git data, filesystem state, or project metadata:** use `4orman-tools` — full subcommand map:
  | Need | Subcommand |
  |---|---|
  | session deps (claude/git/gh present) | `4orman-tools doctor` |
  | tool version drift check vs baseline | `4orman-tools compat-check` |
  | workspace up-to-date vs origin | `4orman-tools status <workspace>` |
  | incoming commits + files changed | `4orman-tools changes-preview <repo>` |
  | commits since a tag (for release notes) | `4orman-tools commits <repo> [tag]` |
  | GitHub auth + login | `4orman-tools gh-user` |
  | latest tag, next version, dirty state | `4orman-tools release-info <repo>` |
  | remote owner/repo/url | `4orman-tools repo-info <repo>` |
  | check if a tag exists | `4orman-tools tag-exists <repo> <tag>` |
  | project structure, entry point, file inventory (use instead of find/ls) | `4orman-tools scan <path>` |
  | structural diff of two directories (use instead of diff -r or manual comparison) | `4orman-tools diff-dirs <path1> <path2>` |
  | search for a string across multiple files (use instead of bash grep/rg) | `4orman-tools grep <root-path> <pattern> [ext]` |
  | find files by name/glob (use instead of bash find) | `4orman-tools find-files <root-path> <glob>` |
  | extract a value from a JSON file (use instead of reading the whole file) | `4orman-tools json-query <file-path> <dot-path>` |
  | structured diff summary — use instead of reading raw git diff output | `4orman-tools git-diff <repo-path> [ref]` |
  | immediate directory contents (use instead of bash ls or shallow find) | `4orman-tools list-dir <path>` |
  | line count + byte size of a file (use instead of wc -l or stat) | `4orman-tools file-stats <file-path>` |
  | .env* file keys in a project root (keys only, never values) | `4orman-tools env-scan <root-path>` |
  | extract a value from a TOML file (Cargo.toml, pyproject.toml) | `4orman-tools toml-query <file-path> <dot-path>` |
  | stack trace in context — pipe it here to get structured file:line:col:fn JSON instead of reading it manually | `4orman-tools parse-stack` (reads stdin) |
  | GitHub repos with isForeman + isLocal flags (use instead of gh repo list + per-repo API) | `4orman-tools list-projects <4orman-root>` |
  | GitHub tarball SHA256 with retry (use in /brew-release instead of curl \| shasum) | `4orman-tools tarball-sha <owner> <repo> <tag>` |
  | Homebrew formula fields — url, sha256, version (use in /brew-release instead of reading .rb) | `4orman-tools formula-info <tap-path> <formula-name>` |
  | Claude Code Stop hooks present check (use in /setup-automation and /first-run instead of jq) | `4orman-tools validate-hooks` |
  | GitHub release creation via notes file (use in /release and /brew-release instead of --notes "...") | `4orman-tools gh-release <owner> <repo> <tag> <title> <notes-file>` |
  | SHA256 hash of a local file (use before re-reading to detect if file changed) | `4orman-tools file-hash <abs-file-path>` |
  | Skip re-reading an unchanged file — `hit: true` means use `value` directly without reading; `hit: false` means read + extract + call cache-store | `4orman-tools cache-fetch <abs-file-path> <sub-key>` |
  | Store extracted JSON after a cache miss so next call is a hit (stdin → cache, auto-invalidates when file changes) | `echo '<json>' \| 4orman-tools cache-store <abs-file-path> <sub-key>` |
  | Use ONLY when you need to know if a file changed and have no extracted value to store (rare) | `4orman-tools cache-check <abs-file-path>` |
  | Compact project summary (structure + top 10 files by size) — use instead of `scan` when only structure is needed, not the full file inventory | `4orman-tools context-scan <abs-path>` |
  | Relevance ranking — score and rank files by query relevance so Claude reads most-important files first (top 15, content + name match) | `4orman-tools context-rank <abs-root-path> <query>` |
  | Changed files with unified diff content — orient to what changed without reading raw git output (first 8 files, 100 lines/file) | `4orman-tools context-changed <repo-path> [ref]` |
  | Evidence packets — relevant excerpts from a file without reading the whole thing (case-insensitive, ±10 lines context, merged windows, up to 8 chunks) | `4orman-tools context-evidence <abs-file-path> <pattern>` |
  | extract a value from a YAML file (GitHub Actions, docker-compose, k8s, Rails) | `4orman-tools yaml-query <file-path> <dot-path>` |
  | structural outline of a source file (function/class/struct names + line numbers) — use instead of reading the full file when you only need to understand its structure | `4orman-tools outline <abs-file-path>` |
  | project dependencies from any package manifest (package.json/Cargo.toml/go.mod/requirements.txt) — use instead of reading the manifest when you only need the dep list | `4orman-tools deps <abs-root-path>` |
  | run tests + get structured pass/fail/failures (use instead of running the test command and reading raw output); `resolvedBy` is `"detection"` (unambiguous), `"ledger"` (multiple frameworks found, an exact-match ledger precedent named one), or `"tie-break"` (`roleConfidence: "uncertain"` — no precedent, picked `uncertaintyCandidates[0]` by priority order, resolve and `ledger record`) | `4orman-tools run-tests <abs-root-path>` |
  | detect build system, run build, get structured errors/warnings (use instead of running the build command and parsing raw compiler output); same `resolvedBy`/`roleConfidence` contract as `run-tests` | `4orman-tools build <abs-root-path>` |
  | detect languages, runtimes, package managers, and missing deps for a project (use instead of running which/--version loops) | `4orman-tools env-inspect <abs-root-path>` |
  | locate a symbol's definition and all references across a project (use instead of grep + read N files) | `4orman-tools symbol-find <abs-root-path> <symbol>` |
  | scan for hardcoded secrets (API keys, tokens, passwords, private keys) across a project | `4orman-tools secret-scan <abs-root-path>` |
  | snapshot hardware + tools + optimal settings to `~/.4orman/profile.json` (run once per device) | `4orman-tools device-scan` |
  | changed symbols since a ref + their callers — use instead of reading raw diffs for impact analysis | `4orman-tools delta-context <repo-path> [ref]` |
  | branch, HEAD SHA, dirty state, ahead/behind, last 10 commits — cached by HEAD SHA, hit: true within same HEAD | `4orman-tools git-cache <repo-path>` |
  | read/write project decisions and known patterns across sessions (state at `~/.4orman/state/`) | `4orman-tools project-state <abs-path> [record-decision <what> [<why>]]` |
  | decision ledger — show/record/validate Claude-vs-Zig decisions with 365-day staleness (stored at `~/.4orman/ledger.json`) | `4orman-tools ledger [show \| record <winner> <question> <reasoning> \| check-stale \| validate <id>]` |
  | Jungian ledger category — for values/trade-off decisions with no measured data, no credible source, no formal proof (the "Mathematical proof" gate has nothing to check), and that can't be deferred. No winner, no contest — record `chosen` (the decision), `shadow` (the strongest case against it, not a strawman), and `synthesis` (what's retained from the rejected alternative, what's consciously sacrificed). Never consulted by `capability-check`/`route`/`build`/`run-tests` — values trade-offs must never silently override a factual or tool-choice decision | `4orman-tools ledger record-jungian <question> <chosen> <shadow> <synthesis>` |
  | score a contested decision — Zig computes composite from cited sources, checks ledger, returns winner/void verdict | `4orman-tools ledger score <question> <sources-json>` |
  | run a shell command safely — blocks destructive patterns, captures stdout/stderr as JSON, tracks duration | `4orman-tools shell-run [--timeout <ms>] <shell-command>` |
  | aggregate build + test results into a severity-bucketed verdict (pass/fail + critical/high/medium/low findings) | `4orman-tools quality-gate <abs-path>` |
  | validate a JSON file against a JSON Schema subset — returns violations with $-rooted paths | `4orman-tools validate-schema <abs-file> <abs-schema>` |
  | composite production readiness check — runs quality-gate + secret-scan + env-inspect; returns `{ ready, blockers, warnings }` | `4orman-tools prod-ready <abs-path>` |
  | machine-readable catalog of all subcommands — returns `{ version, subcommands: [{name, description, args}] }` | `4orman-tools registry` |
  | check if a capability is natively available, has a non-stale ledger precedent, or needs Claude fallback — `source` is `native`\|`ledger`\|`claude`; `needsDecision: true` means neither exists — resolve now and `ledger record` the verdict | `4orman-tools capability-check <query...>` |
  | task router — same 3-way check as `capability-check`, enriched into steps `{ routed, steps: [{layer, subcommand, argHint, confidence, reason}], fallback, reason }`; a `ledger`-layer step means reuse the recorded decision, don't re-reason | `4orman-tools route <task...>` |
  | composite project status — git state + build + tests + secrets → `{ status, confidence, issues, nextAction }` | `4orman-tools report <abs-path>` |
  | telemetry snapshot — cache entry count, project-state decisions/patterns, device-profile + compat-baseline presence, estimated token savings | `4orman-tools metrics` |
  | write ground-truth session state (version, wave, current step, pending errors) to `~/.4orman/session-snapshot.json` — called by PreCompact hook before every compaction | `4orman-tools session-snapshot <4orman-root>` |
  | classify a shell operation by severity (safe/caution/destructive/blocked) and return whether it is allowed — use before any shell command that modifies state | `4orman-tools sandbox-check <command...>` |
  | snapshot/list/revert git state — capture current HEAD+branch, list stored snapshots, or get revert commands for a snapshot | `4orman-tools rollback <repo-path> [--list \| --revert <id>]` |
  | score a repeated shell command for 4orman-tools promotion eligibility — use in `/verify-output` Step 7 for any command repeated 2+ times this session | `4orman-tools capability-promote <command...>` |
  | list files changed in a path since a timestamp (mtime-based, no git required) — use at session start to find what changed since last session | `4orman-tools ant <path> [--since <ms>]` |
  | run a script in a language runtime (python/node/deno/bun/go/ruby/bash/swift/zig/lua/php) — returns `{ lang, interpreter, exit_code, stdout, stderr, duration_ms, timed_out, truncated }` | `4orman-tools worker-run <lang> <script> [args...]` |
  | list all supported language workers with binary name and file extension | `4orman-tools worker-list` |
  | focused project slice — top 8 files ranked by relevance + evidence excerpts; give to a subagent instead of full context | `4orman-tools context-slice <abs-path> <focus-query>` |
  | merge two JSON objects — array fields concatenated, non-array fields v2 wins; combine multi-agent partial results | `4orman-tools state-merge <file1> <file2>` |
  | interactive split-panel project dashboard — left panel lists projects, right panel shows release state + MVP readiness; j/k nav, r reload, q quit | `4orman-tools tui [<4orman-root>]` |
  | pre-export/archive gate — scans a project for spec.md, CLAUDE.md decision log, knowledge/ mirror, git cleanliness, push state, ledger refs, _skills/ mentions; returns `{ ready, captured, unextracted, warnings }` | `4orman-tools knowledge-audit <project-path> [<4orman-root>]` |
  | package a project as .fmz archive or generate a platform installer script — formats: fmz, brew, mac, linux, windows, backup | `4orman-tools export <project-path> [--format fmz\|brew\|mac\|linux\|windows\|backup] [--out <dir>]` |
  | absorb a .fmz or raw project directory into the 4orman workspace; detects workspace backup vs single project; restores knowledge/ | `4orman-tools import <source-path> [<4orman-root>]` |
  | track Zig subcommands built locally but not yet brew-released — Stop hook surfaces pending count at session end | `4orman-tools promotion-queue [list \| add <name> <description> \| clear]` |
  | list installed plugins (name, lang, description, args) — use in `/install-plugin`/`/export-plugin` instead of reading plugin.json by hand | `4orman-tools plugin-list` |
  | execute an installed plugin via its worker runtime — returns plugin JSON output verbatim | `4orman-tools plugin-run <name> [args...]` |
- **Before reading any large project file (spec.md, CLAUDE.md, ROADMAP.md, any source file >2KB):** call `cache-fetch <abs-path> <sub-key>` first — if `hit: true` use `value` and skip the read entirely. If `hit: false`: read the file, extract the key facts as JSON, call `cache-store`. Cache is local disk (`~/.cache/4orman-tools/`), persistent across restarts and power loss, auto-invalidates on file change. Standard sub-keys: `spec.md` → `"milestones"`, `CLAUDE.md` → `"guardrails"`, `ROADMAP.md` → `"state"`, source files → `"outline"`.
- **At the start of every session, and whenever the user says "next", "continue", or similar:** determine the absolute path to `ROADMAP.md` in the 4orman workspace root (same directory as this CLAUDE.md), then call `4orman-tools cache-fetch <abs-path-to-ROADMAP.md> state` — if `hit: true`, use the cached state directly. If miss or stale binary, read `ROADMAP.md`. The "Active Work" section at the top shows exactly where to resume. Do not ask the user what they were doing; the answer is there.
- **Knowledge State Taxonomy — three tiers, three rules:**
  - **Permanent Truth** — never touched by any hook or command: `~/.4orman/ledger.json`, `~/.4orman/session-snapshot.json`, `~/.4orman/profile.json` (clear only on hardware change), `~/.4orman/state/`
  - **Pinned Knowledge** — promoted out of cache; required at every session start; *not deleted, only invalidated then regenerated*: `CLAUDE.md → guardrails`, `ROADMAP.md → state`, `spec.md → milestones`, `_skills/README.md → outline`. Rule: source file hash same → use pinned value directly. Hash changed → rebuild that sub-key only, re-store. Value corrupt or source missing → mark stale, rebuild from source, never trust stale. Essential knowledge is not deleted; it is invalidated, regenerated, and verified.
  - **Disposable Cache** — outlines for changed source files, parse summaries, build artifacts, temp results. Hash invalidation handles stale entries automatically on next access. On session close: Stop hook purges entries older than 30 days. After `knowledge-audit ready: true`: that project's disposable entries may be cleared. Full purge of `~/.cache/4orman-tools/` is last-resort only (confirmed corruption). Never clear on session start.
- **At the start of every session:** if `_projects.md` does not exist, create it by copying `_templates/projects.md`. `_projects.md` is git-ignored **local** state (your private project index) — it is never tracked by or committed to the framework repo, so editing it never makes the workspace dirty or blocks self-update.
- Run `/verify-output` before marking any task complete — Claude runs this, not the user. Skip for trivial tasks (see **Scale to task size** below).
- **After any contested decision where Claude overrides Zig data OR Zig proves superior:** record via `4orman-tools ledger record <winner> <question> <reasoning>` — winner is "claude" or "zig", question is the contested claim, reasoning is the evidence summary. Only record confirmed wins; void rounds are not recorded.
- **After completing any milestone step:** update `ROADMAP.md` in that project — check the step done (`[x]`), update the current milestone status — before asking the user to proceed with the next step. Never skip this update.
- Document key decisions in the project's `CLAUDE.md` decision log (not spec.md)
- Check `_skills/README.md` for relevant playbooks before starting work in a new domain or project type
- Update `_knowledgebase/` and `_skills/` when candidates surface during `/verify-output` Step 6
- Prefer editing existing files over creating new ones
- Keep changes small and reversible
- **After `/new-project` or after adding/editing any command or skill:** read and follow `_skills/foreman-tools-audit.md` — one-minute check for shell patterns worth promoting to a 4orman-tools subcommand.
- **After committing changes to any project:** read and follow `_skills/release-notes.md` — check if commits have accumulated since the last tag and, if so, remind the user: "You have unreleased changes in `<project>` since `<last-tag>`. Run `/release` when ready to publish." Do not generate notes unprompted — just surface the reminder.
- **Every compaction summary MUST open with this exact block** (populated from the `session-snapshot` values injected by the PreCompact hook):
  ```
  Current version: vX.X.X
  Last completed: [subcommand name]
  Next step: [exact text from ROADMAP Active Work **Current:** line]
  Pending errors: [none | verbatim error text]
  ```
  These four lines are machine-readable ground truth. Never recall them from memory — they come from the hook. Claude narrates context below this block; the block itself is never paraphrased or omitted.

### Scale to task size

Before starting, classify the task and match the treatment:

- **Trivial** — question, lookup, one-liner fix. Answer directly. No spec, no `/verify-output`.
- **Standard** — a bug fix, a contained feature, a single-file change. Run the normal workflow. Skip `/verify-output` only when the change is a single, obvious, reversible fix.
- **Full build** — a new project, a major feature, anything touching multiple files or introducing new architecture. Full 3-layer treatment without exception: spec → build → verify-output.

### Terminal commands — open a new terminal after upgrading

`4orman-ai` walks up the directory tree looking for an existing workspace (`CLAUDE.md` + `.claude/`) before deciding to clone, so running it from inside the workspace or a project subdirectory reuses that workspace instead of nesting `4orman/4orman/`.

Whenever you ask the user to run `brew upgrade orman-ai` or `brew upgrade orman-tools`, prepend: **"Open a fresh terminal tab first (⌘T)"** — the current session's open workspace is unaffected by the upgrade, but the next `4orman-ai` launch in a stale terminal won't pick up the new version.

### Ask first (consequences)
- Any action that costs money — API calls, cloud deploys, paid services
- Installing, upgrading, or removing packages
- Copying, moving, or creating files outside the current project's directory
- Any database read or write operation
- Sending messages, emails, or notifications of any kind
- Pushing to remote repositories
- Any one-way or hard-to-reverse decision
- Running scripts you didn't write
- Any mid-project scope change — propose the change, get sign-off, then update spec.md

### Mathematical proof (non-negotiable)

Every architectural decision, performance claim, or worker promotion must be backed by one of:
- **Measured data** — `4orman-tools metrics` before and after; state both numbers
- **100% credible online source** — state the exact URL and specific claim; training memory alone is not evidence
- **Formal proof** — state the algorithm, complexity class, and why it dominates

If neither is available: do not proceed. Run the measurement first, then decide. **Exception:** a values/trade-off decision with genuinely no factual answer and that can't be deferred — use `ledger record-jungian` instead of guessing (see subcommand table). This is not a loophole around measuring when measurement is possible; it's for the class of decision measurement can't touch.

When a worker or subcommand produces output: `confidence` and `self_healed` fields quantify result quality mathematically. `confidence: 1.0` = complete. `confidence < 0.8` = degraded; report to user before acting on the result.

**First: check Zig's memory.** `capability-check`/`route` already do this automatically — before falling back to Claude they consult the ledger for a non-stale precedent (`source: "ledger"`). `build`/`run-tests` do too: when tool/framework detection is genuinely ambiguous (e.g. both `Cargo.toml` and `build.zig` present), they check the ledger for an exact-match precedent *before* choosing which tool to invoke — if an unambiguous one exists (`resolvedBy: "ledger"`), it overrides the tie-break; if not, they flag `roleConfidence: "uncertain"` (`resolvedBy: "tie-break"`) instead of silently guessing. `quality-gate` (which runs both) reports the resolved case as a `low`-severity note and the unresolved case as `medium` — a priority decision to resolve and `ledger record`. For anything not going through these, run `4orman-tools ledger show` directly — if Zig has a stored entry for this question (non-stale), use it. Zero tokens. Only when nothing has a native or ledger answer does Claude reason fresh and enter the scoring protocol below — and must `ledger record` the verdict afterward so it isn't re-litigated next time.

### The Ledger — Rigged Rock-Paper-Scissors

Every contested decision between Claude reasoning and Zig stored data runs through this protocol. The game is rigged toward mathematical truth, not toward either player.

**Claude wins a round when all four conditions are met:**
1. Composite confidence score is exactly 100%
2. Score is backed by minimum 10 sampled sources retrieved online this session
3. Every source is cited with exact URL and specific claim — no paraphrasing
4. Zig has no stored ledger entry on this question, or the stored entry is stale

**Zig wins a round when all three conditions are met:**
1. A ledger entry exists for this question at `~/.4orman/ledger.json`
2. Entry is not stale — recorded within the last 365 days
3. Claude cannot produce 10 verified sources that contradict the stored data

**Round is void when:** composite below 100%, fewer than 10 sources, or evidence is contradictory. No promotion, no decision — gather more evidence first.

**Scoring formula** — Zig computes, Claude never self-certifies:
```
4orman-tools ledger score <question> <sources-json>
```
Returns `{ composite, sample_count, winner, void, reason, zig_entry_found, zig_entry_stale }`.

Per source: cited URL retrieved this session + exact claim = 10 pts; training memory alone = 0 pts; contradicted by another source = −10 pts. Composite = total_points / (sample_count × 10) × 100. Minimum 10 sources or automatic void.

**Tiebreaker:** Zig wins. Stored verified data costs zero tokens. A 100% Claude score that agrees with a valid Zig entry confirms the entry — Zig retains the win.

**Staleness:** After 365 days Zig's entry is stale. `4orman-tools ledger check-stale` runs at every session start. Stale entries surface immediately — Claude never silently relies on outdated Zig data. Claude re-samples 10 sources; if score reaches 100% on updated data, Claude wins and the ledger updates.

**Promotion gate:** Only a confirmed win triggers promotion. Claude win → capability promoted to permanent Zig subcommand or worker immediately. Zig win → stored entry confirmed, no new build needed. Void → no promotion.

**Hard rules:**
- Claude never scores its own round — Zig computes and returns the JSON verdict
- Training memory alone scores 0 — never counts toward the 100% threshold
- A void round never promotes anything
- The ledger is append-only — old entries are never deleted, only superseded by newer entries on the same question

### Self-healing (automatic, modular)

Workers and subcommands self-heal before escalating to the user:
1. **Detect** — output schema is declared; violations surface as `schema_violations` in JSON
2. **Retry** — network workers retry 3× with exponential backoff before reporting failure
3. **Degrade gracefully** — partial results are valid; `confidence` quantifies completeness
4. **Report** — `self_healed: true` marks any output that required recovery; never silently wrong
5. **Escalate** — only if `success: false` after all retries; surface structured error, not raw exception

Claude reads `confidence` and `self_healed` on every worker output. If `confidence < 0.8`: investigate before acting. If `self_healed: true`: note it but proceed if `success: true`.

### Never do (hard lines)
- Touch production systems, databases, or live infrastructure
- Expose, log, print, or echo API keys, passwords, tokens, or secrets
- Send real emails, SMS, or messages to real users
- Modify another project's files without explicit permission
- Delete any file — deletion is blocked; if a file needs to go, tell the user and let them do it
- Skip the spec interview (`/new-project`) when starting fresh work
- Commit or push code without the user reviewing the diff
- Add features, abstractions, or error handling beyond what was asked
- Make an architectural decision based on a guess — measure first, decide after
- Accept worker output with `schema_violations` as correct — investigate the violation

### Token discipline (when editing framework files)

Every line in every command, skill, template, and CLAUDE.md loads into Claude's context and costs tokens on every use. When making changes to framework files:

- **Earn your tokens** — every line must change behavior or prevent a real mistake. If removing it wouldn't change what Claude does, remove it.
- **One location per rule** — if a rule exists in CLAUDE.md, it must not be repeated in a command or skill. Pick the authoritative location and delete the duplicate.
- **No rationale commentary** — explain the *what*, never the *why*. The reason a rule exists belongs in a commit message or PR description, not in the prompt file loaded every session.
- **No placeholder sections** — "Results: TBD", "TODO: fill in later", projected future entries. If it has no content yet, delete the section entirely.
- **No obvious instructions** — don't tell Claude things it already knows (e.g. "read the file before editing", "don't guess", "use good judgment"). Reserve instructions for non-obvious constraints only.
- **Tighten, don't expand** — when editing framework files, the default move is to shorten. If your edit makes a file longer, you need a strong reason.

---

## Directory Structure

```
4orman/
├── CLAUDE.md
├── .claude/
│   ├── settings.json          ← permissions & hooks
│   └── commands/
│       ├── new-project.md     ← Layer 1: spec interview + scaffolding
│       └── verify-output.md   ← Layer 2: self-review + critic agent
├── _templates/
│   ├── project_claude.md      ← per-project CLAUDE.md template
│   └── spec_output.md         ← spec format (single source of truth)
├── plugins.public.yml         ← public plugins anyone can install via /setup
├── plugins.local.yml          ← your private repos (git-ignored — create from .example)
├── plugins.local.yml.example  ← template for plugins.local.yml
├── _projects.md               ← index of all projects and their status
├── _knowledgebase/            ← domain knowledge shared across all projects
├── _skills/                   ← reusable prompt patterns & playbooks
└── [project-name]/            ← each project lives here (git-ignored — own private repo)
    ├── CLAUDE.md
    ├── spec.md
    ├── knowledge/             ← project-specific knowledge
    └── ...
```

## Projects vs Plugins

**Projects** — built inside `4orman/`, own git repo, git-ignored by pattern (any root dir not starting with `_` or `.`). Public or private GitHub repo.
**Plugins** — extend 4ORMan (new commands, skills, knowledgebase). Listed in `plugins.public.yml` (tracked) or `plugins.local.yml` (git-ignored). Share private plugins as zip: `/export-plugin` → `/install-plugin`.

---

## Completing a project

When all M3 criteria are met: run `/verify-output` against the M3 "Done when..." criteria, then update `_projects.md` to `complete`. Do not mark complete if any M3 criterion is unmet — downscope or move to v2.

---

## Updating a spec mid-project

Stop implementation → propose the change (what's changing, why, what it affects) → get explicit sign-off → update `spec.md` → log the decision in `[project]/CLAUDE.md` → continue.

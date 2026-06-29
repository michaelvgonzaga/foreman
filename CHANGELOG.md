# Changelog

## v1.15.0 — 2026-06-29

### Improved
- `/release` and `/brew-release` now use `foreman-tools gh-release` to create GitHub releases via a notes file, eliminating heredoc/quote escaping issues with multiline release notes

---

## v1.14.0 — 2026-06-29

### Improved
- `/brew-release` now uses `foreman-tools tarball-sha` to compute GitHub tarball SHA256 with automatic retry, replacing `curl | shasum -a 256`
- `/brew-release` now uses `foreman-tools formula-info` to read the current formula state, replacing manual .rb file parsing
- `/setup-automation` now uses `foreman-tools validate-hooks` to verify Stop hooks exist, replacing `jq` traversal of settings.json

---

## v1.6.0 — 2026-06-28

### New
- `/from-context` — paste any raw context (notes, requirements, code, docs) and Claude synthesizes the project, picks the right toolchain (Zig/Python/bash/none), and flags CLI tool candidates with token savings estimates before spec work begins
- `foreman-tools-audit` skill — runs after every new project and command/skill edit; scans for shell patterns worth promoting to a native CLI subcommand
- `foreman-tools-first` guardrail — Claude checks for a `foreman-tools` subcommand before any data-gathering shell command; warns at session start if `foreman-tools` is not installed

---

## v1.5.0 — 2026-06-28

### New
- `foreman-tools` binary now installs automatically alongside `foreman-ai` via Homebrew — no separate install step

### Improvements
- `self-update` skill uses `foreman-tools status` when available — one JSON read replaces two git subprocess calls; falls back cleanly without it
- `/release` command uses `foreman-tools commits` when available — pre-categorized JSON replaces raw `git log`; falls back cleanly without it

---

## v1.4.0 — 2026-06-28

### New commands
- `/first-run` — guided first-time setup wizard: dependency checks, GitHub auth, per-machine automation hooks, project restore, memory sync, and plugin install
- `/release` — cut a GitHub release for any project (CHANGELOG, tag, push, publish GitHub release)
- `/setup-automation` — install per-machine auto-sync and auto-push Stop hooks into `~/.claude/settings.json`; portable across usernames, idempotent
- `/sync-memory` — back up and restore Claude Code memory across machines via a private GitHub repo
- `/restore-projects` — pull existing Foreman projects from GitHub into a fresh workspace (clone missing, fast-forward existing, push nothing)

### Improvements
- **Token efficiency pass** — net −348 lines across all 27 commands, skills, and templates; removed preamble boilerplate, redundant rules sections, over-specified examples, and placeholder content
- **Token discipline guardrail** — CLAUDE.md now enforces rules for keeping framework files lean when making future edits (earn every token, one location per rule, no rationale commentary, no placeholders)
- **Proportional effort guardrail** — trivial/standard/full-build tiers with appropriate verification; `/verify-output` (second-agent critic) only fires when the work warrants it
- Auto-push hooks hardened for concurrent Claude sessions — `pull --rebase` fallback prevents push rejection when another session pushed first
- Self-update and release-notes skills wired into CLAUDE.md session-start guardrails for automatic behavior
- `_projects.md` is now git-ignored local state seeded from template at session start (never committed to the framework repo)

### Docs
- Foreman reframed: "a foreman directs Claude Code" — not an AI
- README overhauled: identity, who it's for, prerequisites (added `gh`), getting started, commands table
- GitHub repo description updated

### Fixes
- `.gitignore`: inline comments moved to their own lines (were silently ignored by git)
- `mjolnir.md` gitignored and scrubbed from git history via `git filter-repo` (private project command was accidentally public)

---

## v1.3.1 — 2026-06-28

- Launcher now `git clone`s the workspace (was `cp -r`) so `/self-update` works correctly
- Tag and tap formula aligned with `main`

## v1.3.0 — 2026-06-28

- Auto-release notes skill; GitHub repo skill wired into `/new-project` and `/absorb`
- Auto-commit and auto-push Stop hooks for project repos

## v1.2.0

- Plugin system: `/export-plugin`, `/install-plugin`, public/private plugin model

## v1.1.0

- `/absorb` command — import any file, repo, or project into Foreman

## v1.0.0

- Initial release: 3-layer framework, `/new-project`, `/verify-output`, self-update skill

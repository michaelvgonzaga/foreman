# App Factory

Base of operations. Every project lives here. Every project follows the 3-layer framework.

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
- **At the start of every session:** if `.first-run` exists in the workspace root, run `/first-run` immediately and complete it before doing anything else.
- **At the start of every session:** apply `_skills/self-update.md` — silently fetch origin, compare with local, and surface any incoming changes before doing anything else. If fetch fails (no network), skip silently and continue.
- **At the start of every session:** run `foreman-tools doctor` via Bash. If it fails (binary missing), prompt once: "`foreman-tools` not found — run `brew install michaelvgonzaga/foreman/foreman-tools` for faster sessions." If it succeeds, use the JSON to check `claude`, `git`, and `gh` without extra shell calls. Then continue.
- **Before any shell command that reads git data, filesystem state, or project metadata:** use `foreman-tools` — one JSON call beats shell parsing every time. Full subcommand map:
  | Need | Subcommand |
  |---|---|
  | session deps (claude/git/gh present) | `foreman-tools doctor` |
  | workspace up-to-date vs origin | `foreman-tools status <workspace>` |
  | incoming commits + files changed | `foreman-tools changes-preview <repo>` |
  | commits since a tag (for release notes) | `foreman-tools commits <repo> [tag]` |
  | GitHub auth + login | `foreman-tools gh-user` |
  | latest tag, next version, dirty state | `foreman-tools release-info <repo>` |
  | remote owner/repo/url | `foreman-tools repo-info <repo>` |
  | check if a tag exists | `foreman-tools tag-exists <repo> <tag>` |
  | project structure, entry point, file inventory (use instead of find/ls) | `foreman-tools scan <path>` |
  | structural diff of two directories (use instead of diff -r or manual comparison) | `foreman-tools diff-dirs <path1> <path2>` |
  | search for a string across multiple files (use instead of bash grep/rg) | `foreman-tools grep <root-path> <pattern> [ext]` |
  | find files by name/glob (use instead of bash find) | `foreman-tools find-files <root-path> <glob>` |
  | extract a value from a JSON file (use instead of reading the whole file) | `foreman-tools json-query <file-path> <dot-path>` |
  | structured diff summary — use instead of reading raw git diff output | `foreman-tools git-diff <repo-path> [ref]` |
  | immediate directory contents (use instead of bash ls or shallow find) | `foreman-tools list-dir <path>` |
  | line count + byte size of a file (use instead of wc -l or stat) | `foreman-tools file-stats <file-path>` |
  | .env* file keys in a project root (keys only, never values) | `foreman-tools env-scan <root-path>` |
  | extract a value from a TOML file (Cargo.toml, pyproject.toml) | `foreman-tools toml-query <file-path> <dot-path>` |
  | stack trace in context — pipe it here to get structured file:line:col:fn JSON instead of reading it manually | `foreman-tools parse-stack` (reads stdin) |
  | GitHub repos with isForeman + isLocal flags (use instead of gh repo list + per-repo API) | `foreman-tools list-projects <foreman-root>` |
- **At the start of every session:** if `_projects.md` does not exist, create it by copying `_templates/projects.md`. `_projects.md` is git-ignored **local** state (your private project index) — it is never tracked by or committed to the framework repo, so editing it never makes the workspace dirty or blocks self-update.
- Run `/verify-output` before marking any task complete — Claude runs this, not the user. Skip for trivial tasks (see **Scale to task size** below).
- Document key decisions in the project's `CLAUDE.md` decision log (not spec.md)
- Check `_skills/README.md` for relevant playbooks before starting work in a new domain or project type
- Update `_knowledgebase/` and `_skills/` when candidates surface during `/verify-output` Step 6
- Prefer editing existing files over creating new ones
- Keep changes small and reversible
- **After `/new-project` or after adding/editing any command or skill:** read and follow `_skills/foreman-tools-audit.md` — one-minute check for shell patterns worth promoting to a foreman-tools subcommand.
- **After committing changes to any project:** read and follow `_skills/release-notes.md` — check if commits have accumulated since the last tag and, if so, remind the user: "You have unreleased changes in `<project>` since `<last-tag>`. Run `/release` when ready to publish." Do not generate notes unprompted — just surface the reminder.

### Scale to task size

Before starting, classify the task and match the treatment:

- **Trivial** — question, lookup, one-liner fix. Answer directly. No spec, no `/verify-output`.
- **Standard** — a bug fix, a contained feature, a single-file change. Run the normal workflow. Skip `/verify-output` only when the change is a single, obvious, reversible fix.
- **Full build** — a new project, a major feature, anything touching multiple files or introducing new architecture. Full 3-layer treatment without exception: spec → build → verify-output.

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

### Never do (hard lines)
- Touch production systems, databases, or live infrastructure
- Expose, log, print, or echo API keys, passwords, tokens, or secrets
- Send real emails, SMS, or messages to real users
- Modify another project's files without explicit permission
- Delete any file — deletion is blocked; if a file needs to go, tell the user and let them do it
- Skip the spec interview (`/new-project`) when starting fresh work
- Commit or push code without the user reviewing the diff
- Add features, abstractions, or error handling beyond what was asked

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
foreman/
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

**Projects** — built inside `foreman/`, own git repo, git-ignored by pattern (any root dir not starting with `_` or `.`). Public or private GitHub repo.
**Plugins** — extend Foreman (new commands, skills, knowledgebase). Listed in `plugins.public.yml` (tracked) or `plugins.local.yml` (git-ignored). Share private plugins as zip: `/export-plugin` → `/install-plugin`.

---

## Completing a project

When all M3 criteria are met: run `/verify-output` against the M3 "Done when..." criteria, then update `_projects.md` to `complete`. Do not mark complete if any M3 criterion is unmet — downscope or move to v2.

---

## Updating a spec mid-project

Stop implementation → propose the change (what's changing, why, what it affects) → get explicit sign-off → update `spec.md` → log the decision in `[project]/CLAUDE.md` → continue.

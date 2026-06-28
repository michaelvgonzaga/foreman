# App Factory

Base of operations. Every project lives here. Every project follows the 3-layer framework.

---

## First-time setup (after cloning)

Run `/setup`. It reads `plugins.public.yml` (public plugins, tracked) and `plugins.local.yml` (your private repos, git-ignored) and clones whatever your git credentials can reach. If you have private repos to add, copy `plugins.local.yml.example` → `plugins.local.yml` and fill it in before running.

## Starting a new project

Run `/new-project`. Do not skip this. The interview takes 5 minutes and prevents weeks of wasted work.

## Working on an existing project

Read that project's `CLAUDE.md` and `spec.md` before making any changes. Do not rely on memory from a previous session — read the files.

---

## The 3-Layer Framework

### Layer 1 — The Spec
Run `/new-project`. Claude interviews the user one question at a time to uncover the real goal, writes the spec, scaffolds the project directory, and requires explicit sign-off on every key decision before any work begins.

### Layer 2 — The Verifier
Before marking any output complete, Claude runs `/verify-output` — defines success criteria upfront, self-reviews, then spawns a second Claude agent as an independent critic. Claude fixes what the critic flags before showing the user.

### Layer 3 — The Workspace
Each project has its own `CLAUDE.md`, `spec.md`, and knowledge directory that improve over time. The knowledgebase and skills directories are shared across all projects.

---

## Guardrails

### Always do (autopilot)
- **At the start of every session:** if `.first-run` exists in the workspace root, run `/first-run` immediately and complete it before doing anything else.
- **At the start of every session:** apply `_skills/self-update.md` — silently fetch origin, compare with local, and surface any incoming changes before doing anything else. If fetch fails (no network), skip silently and continue.
- **At the start of every session:** if `_projects.md` does not exist, create it by copying `_templates/projects.md`. `_projects.md` is git-ignored **local** state (your private project index) — it is never tracked by or committed to the framework repo, so editing it never makes the workspace dirty or blocks self-update.
- Read the project's `CLAUDE.md` and `spec.md` before touching any code or files
- Run `/verify-output` before marking any task complete — Claude runs this, not the user. Skip for trivial tasks (see **Scale to task size** below).
- Document key decisions in the project's `CLAUDE.md` decision log (not spec.md)
- Check `_skills/README.md` for relevant playbooks before starting work in a new domain or project type
- Update `_knowledgebase/` and `_skills/` when candidates surface during `/verify-output` Step 6
- Prefer editing existing files over creating new ones
- Keep changes small and reversible
- **After committing changes to any project:** apply `_skills/release-notes.md` — check if commits have accumulated since the last tag and, if so, remind the user: "You have unreleased changes in `<project>` since `<last-tag>`. Run `/release` when ready to publish." Do not generate notes unprompted — just surface the reminder. (Use `/brew-release` only when distributing via a Homebrew formula.)

### Scale to task size

Before starting, classify the task and match the treatment:

- **Trivial** — a question, a lookup, a rename, a one-liner fix. Answer directly. No spec, no `/verify-output`. Keep the response short.
- **Standard** — a bug fix, a contained feature, a single-file change. Run the normal workflow. Skip `/verify-output` only when the change is a single, obvious, reversible fix.
- **Full build** — a new project, a major feature, anything touching multiple files or introducing new architecture. Full 3-layer treatment without exception: spec → build → verify-output.

`/verify-output` spawns a second Claude agent and burns tokens proportionate to the output size — worth it for standard and full-build tasks, wasteful for trivial ones.

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

---

## Directory Structure

```
foreman/
├── CLAUDE.md                  ← you are here
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

## Four categories of work

**Projects** — things you build with Foreman's help. Each is its own git repo inside `foreman/`, git-ignored by pattern so it never leaks into the framework repo.
- `private project` — pushed to a private GitHub repo; only you can access it
- `public project` — pushed to a public GitHub repo; anyone can clone or use it

**Plugins** — things that extend Foreman itself: new commands, skills, or knowledgebase entries.
- `private plugin` — listed in `plugins.local.yml` (git-ignored); only installed on your machine
- `public plugin` — listed in `plugins.public.yml` (tracked); anyone who runs `/setup` can install it

## Distribution model

- The `foreman` repo contains only the framework — templates, skills, knowledgebase, commands, and public plugin list
- Project directories are git-ignored by pattern: any root-level dir not starting with `_` or `.` is excluded automatically
- Each project is its own independent git repo (`git init -b main` inside the project dir)
- Someone who clones `foreman` gets the framework only; projects and private plugins are never exposed
- No git submodules — each project is fully independent, zero wiring required
- Private plugins can be shared as zip files: `/export-plugin <name>` → send zip → recipient runs `/install-plugin <path>`

---

## Completing a project

When all M3 milestone criteria are met:
1. Run `/verify-output` against the M3 "Done when..." conditions in `spec.md` — do not declare complete without this
2. Do a final knowledge and skills capture: review the whole project for domain facts or prompt patterns worth keeping in `_knowledgebase/` or `_skills/`
3. Update `_projects.md`: change status to `complete`, update "Last updated" to today's date

Do not mark complete if any M3 criterion is unmet. Downscope or move the unmet item to a v2 spec instead.

---

## Updating a spec mid-project

When scope needs to change:
1. Stop implementation — do not build the new scope yet
2. Propose the change to the user with: what's changing, why, and what it affects
3. Get explicit sign-off ("yes, update the spec")
4. Update `spec.md` — move the item into scope, adjust milestones if needed
5. Add the decision to the decision log in `[project]/CLAUDE.md`
6. Then continue implementation

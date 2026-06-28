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
- Read the project's `CLAUDE.md` and `spec.md` before touching any code or files
- Run `/verify-output` before marking any task complete — Claude runs this, not the user
- Document key decisions in the project's `CLAUDE.md` decision log (not spec.md)
- Check `_skills/README.md` for relevant playbooks before starting work in a new domain or project type
- Update `_knowledgebase/` and `_skills/` when candidates surface during `/verify-output` Step 6
- Prefer editing existing files over creating new ones
- Keep changes small and reversible

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

## Distribution model

**Foreman is public. Projects are private.**

- The `foreman` repo contains only the framework — templates, skills, knowledgebase, commands
- Project directories (`mjolnir/`, etc.) are git-ignored by pattern: any root-level dir not starting with `_` or `.` is excluded automatically
- Each project is its own independent git repo (`git init` inside the project dir) pushed to a private GitHub repo
- Someone who clones `foreman` gets the framework; projects are never exposed
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

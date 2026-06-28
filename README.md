<div align="center">
  <img src="assets/logo.svg" alt="Foreman" width="120"/>
</div>

# Foreman

The name is literal: a foreman doesn't swing the hammer — they run the job site. Foreman is a framework that directs Claude Code: spec the work, structure the build, verify before shipping.

Every project starts with a spec interview, every output goes through a verification step, and a shared knowledgebase and skills library accumulates across all your projects.

---

## Who it's for

Engineers, technical teams, and agencies running real projects with Claude Code. Claude Code is a skilled worker — but a skilled worker without a foreman builds the wrong thing confidently, skips verification, and forgets what was decided last session. Foreman puts the structure in place: specs before work, verification before shipping, and a knowledgebase that carries context across every session.

---

## What it does

**Layer 1 — Spec** (`/new-project`)
Interview → real goal → scoped spec → explicit sign-off before any work begins.

**Layer 2 — Verifier** (`/verify-output`)
Self-review → independent critic (forked Claude agent) → fix what fails → then ship.

**Layer 3 — Workspace**
Every project builds its own knowledge. A shared skills library and knowledgebase accumulate across all projects so you don't re-solve the same problems.

**Plugin system** (`/setup`, `/export-plugin`, `/install-plugin`)
Install public plugins, add your own private repos, or share a plugin with anyone as a zip file.

---

## Prerequisites

- [Claude Code](https://claude.ai/code) installed and authenticated
- Git (`brew install git` if missing)
- A Claude account with API access

---

## Installation

### Option 1 — Homebrew (recommended)

```bash
brew tap michaelvgonzaga/foreman
brew install foreman-ai
```

Then launch it from any directory:

```bash
foreman-ai
```

On first run it clones the Foreman workspace from GitHub into a `foreman/` folder in your current directory and opens it in Claude Code. Subsequent runs just open it. Brew checks for Claude Code and Git on launch and warns you if either is missing.

**To update to the latest version:**

```bash
brew upgrade foreman-ai
```

**To uninstall:**

```bash
brew uninstall foreman-ai
brew untap michaelvgonzaga/foreman
```

**To reinstall from scratch:**

```bash
brew untap michaelvgonzaga/foreman
brew tap michaelvgonzaga/foreman
brew install foreman-ai
```

### Option 2 — Manual

```bash
git clone https://github.com/michaelvgonzaga/foreman.git
claude /path/to/foreman
```

---

## Getting started

1. Run `/setup-automation` to install the per-machine auto-sync and auto-push hooks
2. Run `/setup` to install available plugins
3. Run `/new-project` to start your first project

## How to use

**Starting a new project**
Run `/new-project`. Claude will interview you one question at a time to uncover your real goal, write a spec, scaffold the project directory, and require explicit sign-off before any work begins. Don't skip this — the interview takes 5 minutes and prevents weeks of wasted work.

**Working on an existing project**
Open foreman in Claude Code (`claude /path/to/foreman`), then navigate to your project. Claude will read that project's `CLAUDE.md` and `spec.md` automatically before making any changes.

**Verifying output**
Before marking any task complete, run `/verify-output`. Claude self-reviews the output, then spawns a second Claude agent as an independent critic. It fixes what the critic flags before showing you the result.

**Adding private plugins**
Copy `plugins.local.yml.example` → `plugins.local.yml`, add your private repo URLs, then run `/setup` again.

**Sharing a plugin**
Run `/export-plugin <name>` to package it as a zip. The recipient runs `/install-plugin <path>` to install it.

---

## Commands

| Command | What it does |
|---------|-------------|
| `/help` | Show all available commands |
| `/new-project` | Start a new project — spec interview, scaffolding, and sign-off before any work begins |
| `/verify-output` | Verify any output before marking it done — self-review + independent critic agent |
| `/setup` | Install available plugins from the public list and your private repos |
| `/export-plugin <name>` | Package a plugin as a zip file to share with anyone |
| `/install-plugin <path>` | Install a plugin from a zip file |
| `/release` | Cut a GitHub release for any project — update CHANGELOG, tag, push, and publish a GitHub release |
| `/brew-release` | Cut a Homebrew release — tag, SHA256, update formula, push both repos |
| `/absorb` | Find a file, repo, or project → bring it into Foreman → scan, fix, and iterate to production |
| `/restore-projects` | Pull your existing Foreman projects from GitHub down into this workspace (new device / recovery) — clone what's missing, fast-forward the rest, push nothing |
| `/sync-memory` | Back up your machine-local Claude memory to a private repo, or restore it on a new machine — makes memory portable across devices |
| `/setup-automation` | Install the per-machine auto-sync/auto-push Stop hooks (memory + project repos) into ~/.claude/settings.json — run once on a new machine |

---

## Skills

Built-in playbooks Claude applies automatically:

| Skill | When it kicks in |
|-------|-----------------|
| `self-update` | Session start — silently checks if Foreman is behind its remote and prompts to update before any work begins |
| `release-notes` | Auto-generates categorized release notes from git commits for Foreman or any project — called automatically by `/brew-release` |
| `github-repo` | Creates a public or private GitHub repo and wires it as the git remote — called by `/new-project` and `/absorb` |
| `domain-research` | Before building in an unfamiliar field |
| `software-projects` | Stack decisions and risk checklist for software builds |
| `rubric-driven-verification` | Defining quality criteria upfront for subjective outputs |
| `vendor-neutral-adapter-pattern` | Building integrations that aren't locked to one provider |
| `two-tier-classification` | Routing inputs to specialist handlers via a fast pre-pass |

---

## Plugins

Public plugins are listed in `plugins.public.yml` and install automatically via `/setup`.

To add your private repos: copy `plugins.local.yml.example` → `plugins.local.yml`, add your repos, run `/setup` again.

To share a private plugin with someone: run `/export-plugin <name>` → send the zip → they run `/install-plugin <path>`.

---

## Four categories

| Type | Visibility | How |
|------|-----------|-----|
| Project | Private | Own private git repo, git-ignored inside Foreman |
| Project | Public | Own public git repo, git-ignored inside Foreman |
| Plugin | Private | Listed in `plugins.local.yml` (git-ignored), install via `/setup` |
| Plugin | Public | Listed in `plugins.public.yml` (tracked), anyone can install via `/setup` |

**Projects** are things you build. **Plugins** extend Foreman itself — new commands, skills, or knowledgebase entries. Both can be public or private.

---

Built with [Claude Code](https://claude.ai/code).

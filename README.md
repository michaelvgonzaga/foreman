<div align="center">
  <img src="assets/logo.svg" alt="Foreman" width="120"/>
</div>

# Foreman

A framework for Claude Code that brings structure, verification, and shared knowledge to every project you build.

Every project starts with a spec interview, every output goes through a verification step, and a shared knowledgebase and skills library improves across all your projects.

---

## Who it's for

Engineers, technical teams, and agencies who want Claude Code to produce consistent, senior-level work — not just fast answers. If you've felt like AI output is hit-or-miss depending on how you prompt it, Foreman is the structure that makes it reliable.

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

## Install via Homebrew

```bash
brew tap michaelvgonzaga/foreman https://github.com/michaelvgonzaga/foreman
brew install --HEAD michaelvgonzaga/foreman/foreman
```

Then launch it any time with:

```bash
foreman
```

Brew checks for Claude Code and Git on install and warns you if either is missing.

## Getting started (manual)

1. Clone this repo:
   ```bash
   git clone https://github.com/michaelvgonzaga/foreman.git
   ```
2. Open it in Claude Code:
   ```bash
   claude /path/to/foreman
   ```
3. Run `/setup` to install available plugins
4. Run `/new-project` to start your first project

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

---

## Plugins

Public plugins are listed in `plugins.public.yml` and install automatically via `/setup`.

To add your private repos: copy `plugins.local.yml.example` → `plugins.local.yml`, add your repos, run `/setup` again.

To share a private plugin with someone: run `/export-plugin <name>` → send the zip → they run `/install-plugin <path>`.

---

## The framework is public. Your projects stay private.

Everything in this repo is the framework — templates, commands, skills, knowledgebase. Project directories are git-ignored by design; each lives in its own private repo.

---

Built with [Claude Code](https://claude.ai/code).

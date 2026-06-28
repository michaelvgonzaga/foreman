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

## Getting started

1. Clone this repo and open it in Claude Code
2. Run `/setup` to install available plugins
3. Run `/new-project` to start your first project

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

# Foreman

A domain-agnostic project operating system built inside Claude Code.

Foreman turns any vague idea into a scoped, verified output — then gets smarter with every project. It works for any field: software, legal, healthcare, trades, retail, or anything else.

---

## How it works

**Layer 1 — Spec** (`/new-project`)
Interview → real goal → scoped spec → explicit sign-off before any work begins.

**Layer 2 — Verifier** (`/verify-output`)
Self-review → independent critic (forked Claude agent) → fix what fails → then ship.

**Layer 3 — Workspace**
Every project builds a knowledge base. Foreman gets smarter with every domain it touches.

---

## Setup

1. Clone this repo into your working directory
2. Open the directory in Claude Code
3. Run `/new-project` to start your first project

---

## Structure

```
foreman/
├── CLAUDE.md                  ← root instructions for Claude
├── .claude/
│   ├── settings.json          ← auto-approved and blocked permissions
│   └── commands/
│       ├── new-project.md     ← Layer 1: spec interview + scaffolding
│       └── verify-output.md   ← Layer 2: self-review + critic agent
├── _templates/                ← spec and project CLAUDE.md templates
├── _knowledgebase/            ← domain knowledge shared across all projects
├── _skills/                   ← reusable playbooks (domain research, software builds)
├── _projects.md               ← index of all projects and their status
└── [your-project]/            ← each project lives here
```

---

## Why Foreman?

A foreman scopes the job before work starts, enforces quality before it leaves the site, and knows the trade. That's exactly what this does.

Built with [Claude Code](https://claude.ai/code).

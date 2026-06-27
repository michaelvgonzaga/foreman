# [Project Name]

[One sentence: what this project does and who it's for.]

---

## Spec

See `spec.md` for the full spec. Key facts:

- **Goal:** [the real goal, from spec.md]
- **User:** [who uses this]
- **Domain:** [the field or industry — e.g., legal, healthcare, plumbing, retail, software]
- **v1 scope:** [what's in for this version]
- **Out of scope:** [what's explicitly not being built]

---

## Guardrails (project-specific)

> Fill in what you know now. Bracket placeholders like `[this]` must be replaced. Fields marked "TODO" may be completed later once tools and workflow are confirmed.

### Always do
- Read `spec.md` before any implementation work
- Run `/verify-output` before marking tasks complete
- Keep changes scoped to v1 — do not add features not in the spec
- Before making domain-specific decisions: read `_knowledgebase/README.md` to find relevant files, then read those files
- Before starting a new domain or project type: read `_skills/README.md` and apply any relevant playbooks

### Ask first
- Any use of an external service, API, or integration — list what's used in this project: [list here, or "None in v1"]
- Any change to the data model, schema, or core workflow
- Installing, upgrading, or removing dependencies or packages
- Any operation that writes files outside this project directory
- Any mid-project scope change — propose it, get sign-off, then update spec.md

### Never do
- Never write to a production database or live system
- Never send real messages, emails, or notifications to real users
- [Project-specific hard line — add one or more, or remove this line if none apply]
- Skip the verifier before marking work done
- Add scope without updating spec.md and getting explicit sign-off first

---

## Tools & Resources

> Fill in after tools are decided. Do not leave example values in place.

- **Platform / runtime:** [e.g., web app, mobile, desktop, CLI, physical hardware — or "TODO: not yet decided"]
- **Key tools & services:** [e.g., Supabase, Stripe, Twilio, QuickBooks API, or specific domain software — or "TODO"]
- **Data & storage:** [e.g., SQLite, Google Sheets, Postgres, paper forms — or "TODO"]
- **Domain-specific requirements:** [e.g., HIPAA compliance, bar association rules, trade licensing, accessibility standards — or "None identified"]

---

## How to execute

> Fill in after the workflow is defined. For software projects, include install/run/test commands. For other projects, describe the process steps.

```
# setup


# run / work


# validate / test

```

---

## Knowledgebase

Domain knowledge and research relevant to this project:
- Global (shared): `_knowledgebase/[topic].md` — update the index table in `_knowledgebase/README.md` when adding
- Project-specific: `knowledge/[topic].md` (relative to this project's root)

---

## Decision log

Confirmed decisions from spec sign-off and key choices made during development.
Mirror each confirmed spec decision here immediately after sign-off.

| Date | Decision | Why |
|------|----------|-----|
| [date] | [what was decided] | [why] |

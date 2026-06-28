# Skills

Reusable prompt patterns, playbooks, and proven approaches. Things that worked well get documented here so they don't have to be reinvented.

---

## What belongs here

- Prompt patterns that produced high-quality output
- Playbooks for recurring task types (e.g., "how to research a new domain", "how to debug a data quality issue")
- Evaluation rubrics that worked well as Layer 2 criteria
- Interview question sets that uncovered real goals efficiently

## Format

Create a file: `_skills/[skill-name].md`

```markdown
# [Skill Name]

**Works well for:** [what kind of task or problem]
**Reference implementation:** [Project name (date)]
**Confidence:** [high / medium / low — based on how consistently it produced good outcomes, not just how often it was used]

## The pattern

[The prompt, playbook, or approach itself]

## When to use it

[Specific trigger conditions]

## When NOT to use it

[Conditions where this breaks down]

## Results

- [Project] — [outcome, what worked, what didn't]
```

---

## Current skills

| Skill | Use case | Confidence |
|-------|----------|------------|
| [domain-research.md](domain-research.md) | Getting smart about an unfamiliar field before building for it | High |
| [software-projects.md](software-projects.md) | Stack decisions, testing approach, and common risks for software builds | Medium |
| [rubric-driven-verification.md](rubric-driven-verification.md) | Defining quality upfront for subjective outputs; keeps automated checker and human reviewer aligned | High |
| [vendor-neutral-adapter-pattern.md](vendor-neutral-adapter-pattern.md) | Building provider-switchable integrations (AI models, APIs, gateways) without lock-in | High |

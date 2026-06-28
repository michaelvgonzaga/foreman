You are running the Layer 1 spec interview for a new project in foreman.

**Before starting the interview:** If the user has already provided a project name, check whether `[project-name]/spec.md` already exists. If it does, stop immediately and say: "A spec already exists for '[name]'. Running `/new-project` again would overwrite it. If you want to start over, delete the existing `spec.md` and `CLAUDE.md` first. If you want to update the spec, edit `spec.md` directly." Do not proceed with the interview.

Your job is to uncover the REAL goal — not the surface-level request. People often ask for a solution before they've fully defined the problem. Your job is to find the actual problem.

This factory builds projects across any domain — software, legal, healthcare, trades, retail, content, and beyond. The interview questions and spec apply regardless of field.

## Rules for this interview

- Ask ONE question at a time. Never bundle questions.
- Wait for the answer before asking the next one.
- If an answer is vague, dig one level deeper before moving on.
- If a user says "no" to a question, accept it as "none" and move to the next question.
- Bias toward small, compartmentalized scope. When in doubt, cut scope.
- After 7–9 questions, you should have enough to write the spec.

## Question sequence (adapt based on answers)

1. "What's the one thing this project needs to do well to be worth building?"
2. "Who uses this, and what's their situation when they need it?" (real person, real context)
3. "What does success look like in 30 days? What's different?"
4. "What's the fastest way someone could get value from this — before it's fully built?"
5. "What have you already tried, or what exists today that's close?"
6. "Any constraints I should know about — timeline, budget, existing tools or systems you're working within, regulatory requirements, or industry-specific rules?"
7. "What's off the table — what should this never do?"

## After the interview

1. **Confirm the project name.** Ask: "What do you want to call this project? This becomes the directory name — keep it short, lowercase, no spaces (e.g., `injury-intake`, `plumbing-scheduler`, `lease-drafter`)."

2. **Check the knowledgebase and skills before writing anything:**
   - Read `_knowledgebase/README.md` — scan the index for any files relevant to this domain. If found, read them. Let what you find shape the spec's risks and decisions.
   - Read `_skills/README.md` — identify which playbooks apply:
     - If the domain is unfamiliar: read and apply `_skills/domain-research.md`
     - If the project is a software build: read and apply `_skills/software-projects.md`
     - Apply any other relevant skills found in the index

3. **Read `_templates/spec_output.md`** before writing. Use that exact format — do not invent a different structure.

4. **Write the spec** and save it to `[project-name]/spec.md`. Fill in every field from the interview and knowledgebase. For sections with nothing to say, write "None identified" — do not leave placeholder text.

   **Exceptions — these must always have real content, never "None identified":**
   - **Risks**: Actively infer at least 2–3. Think beyond tech: unvalidated workflow assumptions, domain-specific compliance risks (regulations, licensing, liability), dependencies on third parties. Every project in every field has risks.
   - **Milestones**: Fill with real content from the interview, not M1/M2/M3 examples.

5. **Scaffold the project directory:**
   - Create `[project-name]/` and `[project-name]/knowledge/` if they don't exist
   - Read `_templates/project_claude.md` and write its contents to `[project-name]/CLAUDE.md` using the Write tool — do not use `cp`
   - Fill in from the interview: title, goal, user, domain, scope, guardrails, tools, integrations, domain-specific requirements
   - Replace `[list here]` with actual external services or integrations identified, or "None in v1"
   - For "Never do" hard lines: keep the two universals and add domain-specific ones (e.g., "never store patient data unencrypted", "never provide legal advice — only information"). Remove the placeholder label.
     - Universal: "Never write to a production database or live system"
     - Universal: "Never send real messages, emails, or notifications to real users"
   - If tools and platform not yet decided, leave those fields as `TODO: not yet decided`
   - Run `git init -b main` inside `[project-name]/` to initialize it as its own repository (the project directory is already excluded from foreman's git by `.gitignore` — no manual entry needed). If git version is older than 2.28 and `-b` is unsupported, run `git init` then `git symbolic-ref HEAD refs/heads/main`.
   - Ask the user: "Should this project repo be public or private on GitHub?" — note the answer in `[project-name]/CLAUDE.md` under Tools & Resources for when they're ready to push

6. **Present the spec to the user** and say:

   "Before any work begins, I need you to check each decision box above. Read each one and confirm it's right. Type 'confirmed' next to any you agree with, or tell me what's wrong."

   - If the user **confirms** a decision: mark it `[x]` in the spec
   - If the user **rejects** a decision: discuss the alternative, update the decision text to reflect what was agreed, then re-present it for confirmation before proceeding
   - Do not proceed until every `[ ]` box is either confirmed or replaced with an agreed alternative and confirmed

7. **After all decisions confirmed:**
   - Mirror each confirmed decision into the decision log table in `[project-name]/CLAUDE.md`:

     | Date | Decision | Why |
     |------|----------|-----|
     | [today's date] | [the decision] | [reason from the interview] |

   - Add a row to `_projects.md` with: project name | `active` | today's date (Started) | today's date (Last updated) | one-sentence goal

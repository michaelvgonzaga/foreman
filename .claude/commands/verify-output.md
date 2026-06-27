You are running the Layer 2 verification process. This happens before any output is marked complete.

## Step 1 — Define the success criteria (do this first, before evaluating anything)

If the project has a `spec.md`, read it now — do not work from memory. If there is no spec.md (e.g., you are verifying the spec itself), derive criteria from the original user request and any explicit constraints stated in the conversation.

Then state out loud — define as many criteria as the task requires, minimum 3:

"A perfect result for this task would:
1. [criterion]
2. [criterion]
3. [criterion]
[add more if the task is complex]"

## Step 2 — Self-review

Check the output against each criterion. For each one, mark:
- PASS — clearly met
- PARTIAL — mostly there but something's off
- FAIL — not met

**PARTIAL counts as FAIL for the purpose of marking work complete.** Do not ship a PARTIAL — treat it the same as a FAIL and fix it before proceeding.

List specific evidence for anything that is not a clear PASS.

## Step 3 — Spawn the critic

Use the Agent tool with `subagent_type: "fork"`. The fork already has full conversation context. Pass this exact prompt — fill in the bracketed criteria before sending:

"You are a critic. Your only job is to find what's wrong with the most recent output in this conversation — not to validate it, not to run any verification process. Be precise and blunt.

Review the output against every criterion defined in Step 1 above. List them all here:
1. [criterion from Step 1]
2. [criterion from Step 1]
3. [criterion from Step 1 — add as many as were defined]

Scope your critique to: correctness, completeness against the spec, and anything that would break or mislead. Ignore style preferences.

Report: what passes, what fails, what's missing. Be specific. No flattery. Do not run any workflow steps — just critique."

Wait for the fork to return before proceeding.

## Step 4 — Reconcile and fix

- If self-review and critic agree something is wrong: fix it in the actual output (edit the files, rewrite the section) before showing the user.
- If the critic flags something the self-review missed: fix it and note what was caught.
- If they disagree and you cannot resolve it: flag the specific discrepancy for the user to decide — do not silently pick one side.
- If the output cannot be fixed without a fundamentally different approach: stop, tell the user what's broken and why, and ask how to proceed — do not present a broken result as done.

## Step 5 — Report to user

Present:
- What passed
- What was fixed (and what the critic caught that you missed)
- Any open questions the user needs to decide

Do not present output as "done" until Steps 3 and 4 are complete.

## Step 6 — Capture what was learned

After the user accepts the output, proactively scan what was done and identify candidates. Present them directly — do not ask the user to think of them:

"Here's what I think is worth capturing from this work:

**Knowledgebase candidates** (add to `_knowledgebase/[topic].md` and update `_knowledgebase/README.md`):
- [specific domain fact or finding, or "none"]

**Skills candidates** (add to `_skills/[skill-name].md` and update `_skills/README.md`):
- [prompt pattern or approach that worked well, or "none"]

Should I add any of these?"

If the user confirms, create or update the relevant file and add the entry to the index table in the matching README.

# Release Notes

**Works well for:** Auto-generating release notes for Foreman itself or any project inside Foreman, based on git commits since the last tag
**Reference implementation:** Foreman framework (2026-06-28)
**Confidence:** High

## The pattern

### Step 1 — Get commits since last release

```bash
# Get the previous tag
PREV=$(git -C <repo-path> describe --tags --abbrev=0 <new-tag>^ 2>/dev/null || echo "")

# Get all commits since then
if [ -z "$PREV" ]; then
  git -C <repo-path> log --oneline
else
  git -C <repo-path> log "$PREV"..<new-tag> --oneline
fi

# Also get files changed
git -C <repo-path> diff "$PREV"..<new-tag> --stat
```

### Step 2 — Categorize commits

Group commits into buckets based on message patterns:

| Bucket | Keywords to look for |
|--------|---------------------|
| New features | `add`, `new`, `create`, `introduce`, `implement` |
| Fixes | `fix`, `bug`, `error`, `broken`, `correct`, `resolve` |
| Improvements | `update`, `improve`, `enhance`, `refactor`, `optimize` |
| Removals | `remove`, `delete`, `drop`, `deprecate` |
| Docs | `readme`, `docs`, `document`, `comment` |
| Other | anything that doesn't fit above |

### Step 3 — Write the notes

Use this structure:

```markdown
## What's new in v<version>

### ✨ New
- <feature> — <one line description>

### 🛠 Fixed
- <fix> — <one line description>

### 📈 Improved
- <improvement> — <one line description>

### 🗑 Removed
- <removal> — <one line description>

### 📝 Docs
- <doc change>
```

Skip any section that has no entries. Never include the Co-Authored-By lines from commit messages.

For Foreman itself, also note which commands or skills changed:
- If a command file changed → mention the command name (`/absorb`, `/new-project`, etc.)
- If a skill file changed → mention the skill name
- If a template changed → note it affects all new projects

For projects, focus on what the user can now do differently, not what files changed.

### Step 4 — One-liner title

Write a short title (under 60 chars) that captures the most important thing in this release:

- Good: `v1.2.0 — Public/private model, foreman-ai rename`
- Bad: `v1.2.0 — Various updates and fixes`

## When to use it

- **Automatically after every project commit** — wired into `CLAUDE.md` guardrails; checks if unreleased commits have accumulated and surfaces a reminder to run `/brew-release`. Does not generate notes unprompted — just flags that a release may be due.
- Automatically during `/brew-release` — called in Step 7 to generate the GitHub release body
- When the user asks "write release notes", "what changed since last release", or "generate changelog"
- When completing a project milestone and wanting to document progress

## When NOT to use it

- When there are no commits since the last tag (nothing to document)
- When the user has already written release notes manually — don't overwrite them

## Rules

- Never invent changes not reflected in the commits
- Never include internal tooling noise (Co-Authored-By, merge commits, version bumps) as standalone items
- If a commit message is too vague to categorize ("fix stuff", "updates"), include it under Other rather than guessing
- Keep each bullet to one line — details belong in the commit, not the release notes

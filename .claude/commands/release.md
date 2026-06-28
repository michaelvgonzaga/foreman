You are running the `/release` command. Cut a GitHub release for any Foreman project — update CHANGELOG.md, tag it, push, and create a GitHub release. No Homebrew required. For Homebrew formula distribution, use `/brew-release` instead.

## Step 1 — Gather info

Ask the user (one at a time if unclear):

1. **Project repo path** — the local path to the project being released. If you are already inside a project directory (has a `spec.md` and `CLAUDE.md`), use it without asking.
2. **Version number** — run `git -C <path> describe --tags --abbrev=0 2>/dev/null` to find the latest tag. Suggest the next patch bump (e.g. `v1.0.3` → `v1.0.4`). If no tags exist, suggest `v1.0.0`. Show the suggestion and let the user confirm or override.

Do not proceed until you have both.

## Step 2 — Pre-flight checks

```bash
# Repo must be clean
git -C <project-path> status --porcelain

# Tag must not already exist
git -C <project-path> tag | grep "^v<version>$"

# Remote must be reachable
git -C <project-path> remote get-url origin
```

Stop with a clear error if any check fails. Do not release a dirty repo or a duplicate tag.

## Step 3 — Generate release notes

Apply `_skills/release-notes.md` to generate categorized notes from commits since the previous tag:

```bash
PREV=$(git -C <project-path> describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -z "$PREV" ]; then
  git -C <project-path> log --oneline
else
  git -C <project-path> log "$PREV"..HEAD --oneline
fi
```

Use the skill's categorization rules (New / Fixed / Improved / Removed / Docs). Skip internal tracking commits (M1/M2/M3 milestones, gate results, Co-Authored-By lines). Focus on what the user can now do differently.

## Step 4 — Preview and confirm

Show the user:

```
Proposed release notes for v<version>:

---
<formatted release notes>
---

Tag: v<version>
Repo: <owner>/<repo>

Publish? (yes to proceed, or give edits)
```

Wait for explicit confirmation. Apply any edits the user gives before continuing.

## Step 5 — Update CHANGELOG.md

Check whether `CHANGELOG.md` exists in the project root:

```bash
ls <project-path>/CHANGELOG.md
```

**If it exists:** Prepend the new entry after the `# Changelog` header (before the previous `## [x.y.z]` entry).

**If it does not exist:** Create it with this header, then the new entry:

```markdown
# Changelog

All notable changes to this project are documented here.

## [<version>] — <date>

### ✨ New
...

### 🛠 Fixed
...
```

Use today's date. Only include sections that have entries — skip empty ones.

## Step 6 — Commit CHANGELOG.md

```bash
git -C <project-path> add CHANGELOG.md
git -C <project-path> commit -m "Release v<version>"
```

## Step 7 — Tag and push

```bash
git -C <project-path> tag v<version>
git -C <project-path> push origin main
git -C <project-path> push origin v<version>
```

## Step 8 — Create GitHub release

Get the owner/repo from the remote URL (handles both SSH and HTTPS formats):

```bash
git -C <project-path> remote get-url origin
# SSH:   git@github.com:owner/repo.git  → owner/repo
# HTTPS: https://github.com/owner/repo.git → owner/repo
```

Then create the release:

```bash
gh release create v<version> \
  --repo <owner>/<repo> \
  --title "v<version> — <one-line summary from release notes>" \
  --notes "<confirmed release notes>"
```

## Step 9 — Summary

Print:

```
Released v<version>

  GitHub release: https://github.com/<owner>/<repo>/releases/tag/v<version>
  CHANGELOG.md updated and committed

To install / update:
  git clone https://github.com/<owner>/<repo>.git   ← fresh install
  git pull                                            ← update existing clone
```

## Rules

- Never release a dirty repo — always check first.
- Never skip the user preview in Step 4 — they must confirm before any tag or push.
- Never invent release notes — only categorize what is in the commits.
- If any step fails, stop and report the exact error. Do not continue past a failure.
- For Homebrew formula distribution (tap + SHA256 + formula update), use `/brew-release` instead.

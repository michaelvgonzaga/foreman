Cut a Homebrew release — tag, compute SHA256, update the formula, push both repos.

## Step 1 — Gather info

Ask the user (one at a time if unclear):

1. **Project repo path** — the local path to the project being released (e.g. `/Users/x/myapp`). If there's only one obvious project in the current working tree, use it without asking.
2. **Homebrew tap repo path** — the local path to the `homebrew-<name>` tap repo (e.g. `/Users/x/homebrew-myapp`). Infer it from the project name if possible.
3. **Version number** — get release pre-flight data:

```bash
# With 4orman-tools (preferred — latestTag, suggestedNext, commitsSince, isDirty in one call):
4orman-tools release-info <project-path>
# Fallback:
git -C <project-path> describe --tags --abbrev=0 2>/dev/null
```

Use `suggestedNext` as the default. Show it and let the user confirm or override.

Do not proceed until you have all three.

## Step 2 — Pre-flight checks

Run and stop on any failure:
- **Dirty repo** — use `isDirty` from `4orman-tools release-info` (if used in Step 1), or `git -C <project-path> status --porcelain`
- **Tag already exists** — `4orman-tools tag-exists <project-path> <version>` (preferred), or `git -C <project-path> tag | grep "^v<version>$"`
- `git -C <tap-path> status` — tap not found

## Step 3 — Tag the release

```bash
git -C <project-path> tag v<version>
git -C <project-path> push origin v<version>
```

## Step 4 — Compute SHA256

Get owner/repo (needed to build the tarball URL):

```bash
# With 4orman-tools (preferred — parses SSH and HTTPS automatically):
4orman-tools repo-info <project-path>
# Fallback:
git -C <project-path> remote get-url origin
# SSH format:  git@github.com:owner/repo.git  → owner/repo
# HTTPS format: https://github.com/owner/repo.git → owner/repo
```

Compute the SHA256 (use owner/repo from the repo-info call above):

```bash
# With 4orman-tools (preferred — fetches, computes SHA256, retries once on empty-file hash):
4orman-tools tarball-sha <owner> <repo> v<version>
# Fallback (wait 5s for GitHub to generate tarball, then hash):
sleep 5 && curl -sL https://github.com/<owner>/<repo>/archive/refs/tags/v<version>.tar.gz | shasum -a 256
# If fallback returns empty-file hash (e3b0c44...), wait 10s and retry once.
```

## Step 5 — Update the formula

Read the current formula state to know what to change:

```bash
# With 4orman-tools (preferred — parses url, sha256, version in one call):
4orman-tools formula-info <tap-path> <formula-name>
# Fallback: read the .rb file directly
```

Update three fields in the formula:
- `url` → `https://github.com/<owner>/<repo>/archive/refs/tags/v<version>.tar.gz`
- `sha256` → the value from Step 4
- `version` → `<version>`

Leave everything else — `head`, `depends_on`, `def install`, `def caveats`, `test` — exactly as-is.

## Step 6 — Push the tap repo

```bash
git -C <tap-path> add Formula/<name>.rb
git -C <tap-path> commit -m "Release v<version>"
git -C <tap-path> push
```

## Step 7 — Create GitHub release

Apply the `release-notes` skill (`_skills/release-notes.md`) to auto-generate categorized notes from commits since the previous tag. Then ask the user: **"Here are the auto-generated release notes — any additions or changes before I publish?"**

Wait for confirmation, then write the notes to a temp file and create the release:

```bash
# With 4orman-tools (preferred — avoids heredoc/quote escaping):
# Write notes to $NOTES_FILE, then:
4orman-tools gh-release <owner> <repo> v<version> "v<version> — <summary>" $NOTES_FILE
# Fallback:
gh release create v<version> \
  --repo <owner>/<repo> \
  --title "v<version> — <one line summary from release-notes skill>" \
  --notes-file $NOTES_FILE
```

## Step 8 — Confirm

Print a summary:

```
Released v<version>

  GitHub release:  https://github.com/<owner>/<repo>/releases/tag/v<version>
  Tap formula:     updated and pushed

Install / upgrade:
  brew tap <owner>/<tap-short-name>   ← first time only
  brew install <name>                 ← fresh install
  brew upgrade <name>                 ← existing install
```

Where `<tap-short-name>` is the tap name without `homebrew-` prefix (e.g. `homebrew-myapp` → `myapp`).

## Rules

- Never release a dirty repo — always check first.
- Never skip the SHA256 — compute it fresh every time, do not reuse a previous value.
- Never modify anything in the formula except `url`, `sha256`, and `version`.
- If any step fails, stop and report the exact error. Do not continue past a failure.

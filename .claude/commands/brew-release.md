Cut a Homebrew release — tag, compute SHA256, update the formula, push both repos.

## Step 1 — Gather info

Ask the user (one at a time if unclear):

1. **Project repo path** — the local path to the project being released (e.g. `/Users/x/myapp`). If there's only one obvious project in the current working tree, use it without asking.
2. **Homebrew tap repo path** — the local path to the `homebrew-<name>` tap repo (e.g. `/Users/x/homebrew-myapp`). Infer it from the project name if possible.
3. **Version number** — suggest the next patch bump from the latest git tag. Show the current latest tag so the user can confirm or override.

Do not proceed until you have all three.

## Step 2 — Pre-flight checks

Run and stop on any failure:
- `git -C <project-path> status --porcelain` — dirty repo
- `git -C <project-path> tag | grep "^v<version>$"` — tag exists
- `git -C <tap-path> status` — tap not found

## Step 3 — Tag the release

```bash
git -C <project-path> tag v<version>
git -C <project-path> push origin v<version>
```

## Step 4 — Compute SHA256

```bash
git -C <project-path> remote get-url origin
# SSH format:  git@github.com:owner/repo.git  → owner/repo
# HTTPS format: https://github.com/owner/repo.git → owner/repo
```

GitHub needs a few seconds to generate the tarball after a tag is pushed. Wait 5 seconds then compute:

```bash
sleep 5
curl -sL https://github.com/<owner>/<repo>/archive/refs/tags/v<version>.tar.gz | shasum -a 256
```

If shasum returns the empty-file hash (`e3b0c44...`), wait 10s and retry once.

## Step 5 — Update the formula

Find the formula file in the tap repo:

```bash
ls <tap-path>/Formula/*.rb
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

Wait for confirmation, then create the GitHub release:

```bash
gh release create v<version> \
  --repo <owner>/<repo> \
  --title "v<version> — <one line summary from release-notes skill>" \
  --notes "<release notes from release-notes skill, edited by user if needed>"
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

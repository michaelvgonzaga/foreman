You are running the `/brew-release` command. Your job is to cut a Homebrew release for a project — tag it, compute the SHA256, update the formula, and push both repos.

## Step 1 — Gather info

Ask the user (one at a time if unclear):

1. **Project repo path** — the local path to the project being released (e.g. `/Users/x/myapp`). If there's only one obvious project in the current working tree, use it without asking.
2. **Homebrew tap repo path** — the local path to the `homebrew-<name>` tap repo (e.g. `/Users/x/homebrew-myapp`). Infer it from the project name if possible.
3. **Version number** — suggest the next patch bump from the latest git tag. Show the current latest tag so the user can confirm or override.

Do not proceed until you have all three.

## Step 2 — Pre-flight checks

Run these and stop with a clear error if any fail:

```bash
# Confirm project repo is clean
git -C <project-path> status --porcelain
```

If there are uncommitted changes, tell the user and stop. Do not release a dirty repo.

```bash
# Confirm the tag doesn't already exist
git -C <project-path> tag | grep "^v<version>$"
```

If the tag exists, tell the user and stop.

```bash
# Confirm the tap repo exists and is a git repo
git -C <tap-path> status
```

If the tap repo isn't found, tell the user and stop.

## Step 3 — Tag the release

```bash
git -C <project-path> tag v<version>
git -C <project-path> push origin v<version>
```

## Step 4 — Compute SHA256

```bash
curl -sL https://github.com/<owner>/<repo>/archive/refs/tags/v<version>.tar.gz | shasum -a 256
```

Get the owner/repo from the project's git remote:

```bash
git -C <project-path> remote get-url origin
```

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

## Step 7 — Confirm

Print a summary:

```
Released v<version>

  Project tag:  https://github.com/<owner>/<repo>/releases/tag/v<version>
  Tap formula:  updated and pushed

Install with:
  brew tap <owner>/<tap-short-name>
  brew install <name>
```

Where `<tap-short-name>` is the tap name without `homebrew-` prefix (e.g. `homebrew-myapp` → `myapp`).

## Rules

- Never release a dirty repo — always check first.
- Never skip the SHA256 — compute it fresh every time, do not reuse a previous value.
- Never modify anything in the formula except `url`, `sha256`, and `version`.
- If any step fails, stop and report the exact error. Do not continue past a failure.

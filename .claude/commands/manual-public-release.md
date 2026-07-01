Manual public release — pauses for explicit confirmation before each push, tag, and formula update. Includes Homebrew formula update if the project has one. Use this when you want to review each step before it runs.

## Step 1 — Gather info

Get project path (ask if unclear). Then:

```bash
4orman-tools release-info <project-path>
4orman-tools repo-info <project-path>
4orman-tools formula-info /opt/homebrew/Library/Taps/<owner>/homebrew-<repo> <name> 2>/dev/null
```

Show `suggestedNext` and ask the user to confirm or override the version.

Check `isDirty` — show dirty files and ask: "Commit these first, or release from current state?" Abort if they choose to commit first.

## Step 2 — CHANGELOG preview

Generate release notes using the `release-notes` skill. Show the draft notes and ask: "Any changes before I continue?"

Apply edits if requested.

## Step 3 — Tag (confirm before running)

Show: `Will run: git tag v<version> && git push origin v<version>` — ask "OK?" before running.

## Step 4 — GitHub release (confirm before running)

Show the release title and notes. Ask "Publish this release?" before running `4orman-tools gh-release`.

## Step 5 — Homebrew formula (if formula exists, confirm before running)

Compute SHA256:
```bash
4orman-tools tarball-sha <owner> <repo> v<version>
```

Show the three formula fields that will change (url, sha256, version). Ask "Update and push formula?" before running.

## Step 6 — Summary

Print:
```
✓ v<version> released

  GitHub: https://github.com/<owner>/<repo>/releases/tag/v<version>
  [if formula:] Homebrew: brew upgrade <name>
```

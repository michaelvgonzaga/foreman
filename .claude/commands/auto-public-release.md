Fully automated public release. Shows a single plan, gets one confirmation, then runs all steps without further pauses. Includes Homebrew formula update if the project has one.

## Step 1 — Gather info

Get project path (ask if unclear). Then:

```bash
4orman-tools release-info <project-path>
4orman-tools repo-info <project-path>
4orman-tools formula-info /opt/homebrew/Library/Taps/<owner>/homebrew-<repo> <name> 2>/dev/null
```

Use `suggestedNext` as the version. Check `isDirty` — abort if dirty.

Detect whether a Homebrew formula exists for this project. If `formula-info` returns a valid url field, a formula exists.

## Step 2 — One-time plan

Show exactly this before doing anything:

```
Auto public release plan for <name> v<version>:

  1. Tag v<version> and push to github.com/<owner>/<repo>
  2. Create GitHub release with auto-generated notes
  [if formula exists:]
  3. Compute tarball SHA256
  4. Update formula url + sha256 + version
  5. Commit and push tap repo
  6. GitHub release created at github.com/<owner>/<repo>/releases/tag/v<version>

Proceed? [y/N]
```

Wait for the user to type y. If anything else, abort.

## Step 3 — Execute (no further pauses)

Run all steps from `/release` Steps 2–8 and, if formula exists, all steps from `/brew-release` Steps 4–8. Do not ask for confirmation between steps. Show each step as it runs with a one-line status.

## Step 4 — Summary

Print:
```
✓ v<version> released

  GitHub: https://github.com/<owner>/<repo>/releases/tag/v<version>
  [if formula:] Homebrew: brew upgrade <name>
```

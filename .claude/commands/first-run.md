First-run wizard. Complete each step in order before moving to the next.

## Step 1 — Dependencies

Check all required tools:

```bash
# With foreman-tools (preferred — claude, git, gh in one call):
foreman-tools doctor
# Fallback:
echo "claude: $(command -v claude >/dev/null 2>&1 && echo OK || echo MISSING)"
echo "git:    $(command -v git >/dev/null 2>&1 && echo OK || echo MISSING)"
echo "gh:     $(command -v gh >/dev/null 2>&1 && echo OK || echo MISSING)"
```

For any that are MISSING, give the shortest fix and stop:
- **claude** → Install Claude Code: https://claude.ai/code
- **git** → `brew install git`
- **gh** → `brew install gh`

Do not continue until all three show OK. Tell the user to type `/first-run` again after installing.

## Step 2 — GitHub authentication

```bash
# With foreman-tools (preferred):
foreman-tools gh-user
# Fallback:
gh auth status 2>&1
```

If `authenticated` is false (or fallback exits non-zero): tell the user to type `! gh auth login` in this prompt — the `!` prefix runs it in the terminal so the browser flow works correctly. Wait for them to confirm it completed, then re-check before continuing.

If already authenticated, continue silently.

## Step 3 — Per-machine automation

Run `/setup-automation`.

This installs the memory-sync and auto-push Stop hooks into `~/.claude/settings.json`. It is required once per machine and does not travel with the framework.

## Step 4 — Existing projects

Ask the user (one question only): "Do you have existing Foreman projects on GitHub from another machine?"

- Yes → run `/restore-projects`
- No → continue

## Step 5 — Memory restore

Ask the user (one question only): "Are you migrating from another machine and want to restore your Claude memory?"

- Yes → run `/sync-memory restore`
- No → continue

## Step 6 — Plugins

Run `/setup` to install available public plugins.

## Step 7 — Done

Delete the first-run marker: `rm -f <foreman-root>/.first-run`

Tell the user: "You're set up. Run `/new-project` to start your first project."

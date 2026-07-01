First-run wizard. Complete each step in order before moving to the next.

## Step 0 — Mode selection

Ask the user exactly this, before anything else:

> "Welcome to Foreman. Are you setting up as a **Power User** (log in with your GitHub account) or **Guest** (try it without an account)?
>
> **Power User** — your projects, customizations, and essential session knowledge are saved to your own private GitHub repos. Everything travels with you to any machine. Recommended.
>
> **Guest** — everything stays local. Nothing is saved to GitHub. You can upgrade to Power User any time by running `/first-run` again."

- **Guest** → skip Steps 2, 4, 5, 6. Continue from Step 3. Remind the user at the end: "Run `/first-run` again when you're ready to connect your GitHub account — your knowledge and projects will sync from that point forward."
- **Power User** → continue with all steps below.

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

## Step 5 — Pinned Knowledge restore

Get the user's GitHub username and derive their foreman-knowledge repo, then restore:

```bash
GH_USER=$(gh api user --jq .login 2>/dev/null)
FOREMAN_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/foreman")
KREPO=/tmp/fk-restore
git clone "git@github.com:${GH_USER}/foreman-knowledge.git" "$KREPO" 2>/dev/null || git -C "$KREPO" pull --ff-only 2>/dev/null
if [ -f "$KREPO/pinned/claude-md-guardrails.json" ]; then
  cat "$KREPO/pinned/claude-md-guardrails.json"  | foreman-tools cache-store "$FOREMAN_ROOT/CLAUDE.md" guardrails
  cat "$KREPO/pinned/roadmap-state.json"          | foreman-tools cache-store "$FOREMAN_ROOT/ROADMAP.md" state
  cat "$KREPO/pinned/skills-readme-outline.json"  | foreman-tools cache-store "$FOREMAN_ROOT/_skills/README.md" outline
  echo "Pinned knowledge restored — session starts warm."
else
  echo "No foreman-knowledge repo found at github.com/${GH_USER}/foreman-knowledge — skipping. Create it with /knowledge-sync push after your first session."
fi
```

## Step 6 — Memory restore

Ask the user (one question only): "Are you migrating from another machine and want to restore your Claude memory?"

- Yes → run `/sync-memory restore`
- No → continue

## Step 7 — Plugins

Run `/setup` to install available public plugins.

## Step 8 — Done

Delete the first-run marker: `rm -f <foreman-root>/.first-run`

Tell the user: "You're set up. Run `/new-project` to start your first project."

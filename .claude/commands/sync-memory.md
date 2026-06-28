You are running the `/sync-memory` command. Claude Code memory is machine-local — it lives in `~/.claude/` and does NOT travel with Foreman, your account, or a fresh machine. This command makes it portable by syncing it to a **private** GitHub repo (`<your-account>/foreman-memory`), so a new device can pull your accumulated memory down after installing Foreman.

Argument: `backup` (default) or `restore`.

## Step 0 — Locate this session's memory directory

Memory is stored per working directory, encoded by replacing `/` with `-`:

```bash
gh auth status        # must be authenticated
OWNER="$(gh api user -q .login)"
MEM="$HOME/.claude/projects/$(pwd | sed 's#/#-#g')/memory"
echo "memory dir: $MEM"
```

(When launched via `foreman-ai`, `pwd` is the Foreman workspace, so this resolves to that session's memory.)

## backup — push local memory up

```bash
mkdir -p "$MEM" && cd "$MEM"
[ -d .git ] || { git init -q -b main; printf '.DS_Store\n' > .gitignore; }
# Create the private repo on first run if it doesn't exist, and wire the remote.
git remote get-url origin >/dev/null 2>&1 || \
  gh repo create "$OWNER/foreman-memory" --private --source=. --remote=origin 2>/dev/null || \
  git remote add origin "https://github.com/$OWNER/foreman-memory.git"
git add -A
git commit -q -m "Memory sync $(date +%Y-%m-%d)" || echo "nothing to commit"
git push -q -u origin main
```

Report what was pushed (changed files). The repo is **private** — confirm that before pushing if it had to be created.

## restore — pull memory down onto this machine

```bash
mkdir -p "$(dirname "$MEM")"
if [ -d "$MEM/.git" ]; then
  cd "$MEM"
  git fetch origin --quiet
  git pull --ff-only            # skip + warn if dirty or diverged; never clobber local memory
elif [ -d "$MEM" ] && [ -n "$(ls -A "$MEM" 2>/dev/null)" ]; then
  echo "⚠ $MEM already has files but isn't a clone — back them up, then re-run, or merge by hand."
else
  git clone "https://github.com/$OWNER/foreman-memory.git" "$MEM"
fi
```

After a restore, tell the user memory is now available and will be loaded next session (the `MEMORY.md` index is read at session start).

## Rules

- The memory repo MUST be private — it can contain personal/work context. Never make it public.
- Never put secrets (keys, tokens, passwords) in memory files; this command pushes them to GitHub.
- restore is fast-forward only — never overwrite or force-merge local memory; if it conflicts, surface it and stop.
- Memory files may contain machine-specific absolute paths (e.g. `/Users/<you>/...`). If usernames/home paths differ across your machines, those references won't resolve — note this; the facts still carry over, the paths may need a glance.
- This sync is opt-in and manual. To keep it current, run `/sync-memory backup` after meaningful memory changes and `/sync-memory restore` when setting up a new machine.

# Foreman Help

Print the following exactly:

---

**Foreman commands**

| Command | What it does |
|---------|-------------|
| `/help` | Show this list |
| `/new-project` | Start a new project — spec interview, scaffolding, and sign-off before any work begins |
| `/verify-output` | Verify any output before marking it done — self-review + independent critic agent |
| `/setup` | Install available plugins from the public list and your private repos |
| `/export-plugin <name>` | Package a plugin as a zip file to share with anyone |
| `/install-plugin <path>` | Install a plugin from a zip file |
| `/brew-release` | Cut a Homebrew release — tag, SHA256, update formula, push both repos |

**Plugin files**

| File | What it is |
|------|------------|
| `plugins.public.yml` | Public plugins anyone can install — add your public plugins here |
| `plugins.local.yml` | Your private repos — git-ignored, never pushed (create from `.example`) |

**First time here?**
Run `/setup` then `/new-project`.

---

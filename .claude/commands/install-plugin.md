# Install Plugin

Install a plugin from a zip file exported by `/export-plugin`.

## Input

The user provides a path to a `.zip` file. The path can be absolute or relative to the Foreman root.

## Steps

**1. Validate the zip**

- Verify the file exists and has a `.zip` extension
- Run `unzip -l <path>` to inspect its contents
- Identify the top-level directory name inside the zip — this becomes the plugin name
- If there is no consistent top-level directory (files are loose at the root of the zip), stop and tell the user: "This zip doesn't look like a Foreman plugin export. Expected a single top-level directory."

**2. Check for conflicts**

If a directory with that name already exists in the Foreman root:
- Tell the user: "Plugin '<name>' is already installed at <name>/. Installing will overwrite it."
- Ask: "Overwrite? (yes/no)"
- If no: stop. If yes: proceed.

**3. Install**

Run from the Foreman root:

```bash
unzip -o <path> -d .
```

**4. Confirm**

Print:

```
Installed: <name>/
Source: <zip filename>

Plugin is ready. If it has a CLAUDE.md, read it before use.
```

**5. Clean up (optional)**

Ask: "Delete the zip file now that it's installed? (yes/no)"
- If yes: tell the user the path so they can delete it — do not delete files yourself.
- If no: done.

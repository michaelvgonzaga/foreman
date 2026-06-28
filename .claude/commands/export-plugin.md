# Export Plugin

Package a plugin directory as a zip file that anyone can install into their Foreman instance via `/install-plugin`.

## Steps

**1. Identify the plugin**

The user will provide a plugin name (directory name). If not provided, list all available plugin directories in the Foreman root (root-level dirs that don't start with `_` or `.`) and ask which to export.

**2. Verify the directory exists**

If `<name>/` does not exist in the Foreman root, stop and tell the user.

**3. Create the zip**

Run from the Foreman root:

```bash
zip -r <name>-plugin.zip <name>/ \
  -x "*/.git/*" \
  -x "*/.git" \
  -x "*.env" \
  -x "*/.env*" \
  -x "*/__pycache__/*" \
  -x "*/*.pyc" \
  -x "*/.DS_Store" \
  -x "*/node_modules/*"
```

Save the zip to the Foreman root directory.

**4. Confirm and instruct**

Print:

```
Exported: <name>-plugin.zip (<size>)

To share: send this file to anyone with a Foreman instance.
To install: they drop it anywhere, then run /install-plugin <path-to-zip>
```

Do not suggest uploading to any external service.

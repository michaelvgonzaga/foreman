Suppress foreman-tools hook activity from the terminal.

```bash
echo 1 > ~/.foreman/foreman-quiet && echo "foreman-tools hook activity: silent"
```

Hooks still run and inject ground-truth context into compaction — only the terminal notification is suppressed.

Use `/foreman-watch` to make hook activity visible again.

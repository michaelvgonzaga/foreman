Show foreman-tools hook activity in the terminal.

```bash
echo 0 > ~/.foreman/foreman-quiet && echo "foreman-tools hook activity: visible"
```

After running this, each compaction shows a terminal notification:
`foreman-tools session-snapshot v<version> — next: <current step>`

Use `/foreman-quiet` to suppress it.

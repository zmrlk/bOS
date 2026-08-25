# Context Bus (archived locator)

Live bus is `state/context-bus.jsonl`.

Write **only** via:

```bash
bash scripts/context-bus-append.sh <from> <to> <type> <priority> "<content>" [ttl_days]
```

Do not `echo >>` jsonl. Do not hand-edit this file. TTL is a **read filter** in SessionStart, not a rewrite kernel.

# bOS on Grok

Read `AGENTS.md` first. SessionStart/UserPromptSubmit stdout is ignored here.

Every turn, if they exist and are non-empty: Read `state/ping.md` then delete it after handling; Read `state/handoff.md` when starting work. Ping is next-turn only. Mid-generation inject does not exist.

Do not nag. Rituals only on request.

Bus write: `bash scripts/context-bus-append.sh` only. Never `echo >>` jsonl.

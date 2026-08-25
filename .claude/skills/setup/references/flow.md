---
name: Setup
description: "Detection-first onboarding. Use when profile.md is missing or empty, or the user says /setup."
user_invocable: true
command: /setup
---

# /setup

Scan first (`scripts/profile-scan.sh` if present), then confirm, then at most 5 gap questions. Value before interrogation. Language = first user message.

Welcome honesty: counts from `bash scripts/bos-roster.sh`, not marketing.

Full flow, resume file, review mode: `references/flow.md`.

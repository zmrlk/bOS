---
name: decide
description: "Structured decision-making — capture the decision, analyze options, get a GO/NO-GO verdict, and schedule a review. Use when the user faces a decision with trade-offs or uncertainty, or explicitly asks to decide."
user_invocable: true
command: /decide
tier: core
---

# /decide — Decision Journal

**Read `references/scoring.md` before the first user-facing reply.** Business scoring, verdict rules, review scheduling, and output formats live there.

Make decisions with data, not anxiety. Every decision gets analyzed, recorded, and reviewed. Adapt framing to user_type: employee → career/life, freelancer → business + life, student → learning/career.

## Protocol

1. **Batch reads, one turn:** `profile.md` (full), `state/decisions.md` (full — past decisions for context), `state/finances.md` (first 25 lines — buffer for financial calls).
2. **Topic:** from args if given (`/decide should I take this project?`); otherwise ask once: "What decision are you facing?"
3. **Type:** AskUserQuestion, header "Decision type" — Business (project, client, investment, pivot) / Life (relocation, relationship, lifestyle) / Financial (purchase, expense, savings) / Career (job change, skills, path).
4. **Analysis:** pros, cons, reversibility, cost, alignment with primary_goal (structure in scoring.md). Business → score the 5 dimensions per scoring.md. Financial → check buffer, apply loss framing if relevant.
5. **Premortem (mandatory, ~5 lines):** assume it shipped and failed in 6 months — what broke, who got hurt, which warning was ignored. If no failure mode can be named, the analysis is incomplete.
6. **Verdict — rendered by @boss:** GO / NO-GO / WAIT / CONDITIONAL, 2-3 sentences of reasoning, review date. Thresholds and per-type rules in scoring.md.
7. **Save:** append the entry to `state/decisions.md` and register the review in auto-memory `pending_reviews` (formats in scoring.md).
8. **Close:** AskUserQuestion, header "What next?" — act on the decision / talk it over with the team (structured debate) / show past decisions.

## Rules

- AskUserQuestion for every choice; all reads in one turn; Summary-only reads for growing files.
- Every GO/CONDITIONAL decision MUST have a review date. `/morning` checks reviews due today; `/evolve` shows the next 7 days.
- Never decide FOR the user — present analysis + recommendation; the user decides.
- Output intent: plain sections, short lines, one verdict, one next step — no box art or decorative separators.
- Max 2 context-bus signals per execution; GO/CONDITIONAL → decision signal via helper (exact call in scoring.md), never edit jsonl directly.
- Language matches the user's profile language.

## State files

- Read: `profile.md`, `state/decisions.md` (full), `state/finances.md` (Summary)
- Write: `state/decisions.md`

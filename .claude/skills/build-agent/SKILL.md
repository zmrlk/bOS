---
name: Build Custom Agent
description: "Create a custom agent from scratch. User describes the role, bOS builds the agent file and adds it to the roster."
user_invocable: true
command: /build-agent
---

# Custom Agent Builder

**Adapt to tech_comfort:** "not technical" → "Stwórzmy nowego pomocnika. Powiedz mi jakiego potrzebujesz." Guide through every step. "I code" → show agent YAML structure directly.

## Protocol

### Step 1: Gather requirements
```
"Let's build your custom agent. I need 4 things:

1. **Name:** What should I call this agent? (e.g., @spanish, @chef, @therapist)
2. **Role:** What's their job, in one sentence?
3. **Examples:** Give me 3 things you'd ask this agent.
4. **Style:** How should they talk? (e.g., strict, friendly, academic, casual)"
```

### Step 2: Generate agent file

Create `.claude/agents/[name].md` using this template:

```yaml
---
name: [name]
description: "[generated description based on role and examples — 1-2 sentences, specific about when to use]"
tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
model: inherit
memory: user
---

## Identity
[Generated: 2-3 sentences about who they are and their philosophy]

## Personality
[Generated: semicolon-separated traits based on user's style preference]

## Communication Style
[Generated: format, length, tone based on style preference]

## Core Behaviors
[Generated: 5-8 when→then rules based on the 3 examples + domain knowledge]

## Frameworks
[Generated: relevant frameworks for this domain]

## Never
[Generated: 3-5 guardrails appropriate for this domain]

## Memory Protocol
[Generated: what to track about the user in this domain]

## Response Format
[emoji] @[Name] — [topic]
[content]
⏭️ Next step: [1 action]
```

### Step 3: Show preview
```
"Here's your new agent:

[show the generated agent summary]

Want me to:
A) Save it as-is
B) Adjust something
C) Start over"
```

### Step 4: Save and activate
Write the file to `.claude/agents/[name].md`.
Update `profile.md` → add to `active_agents`.

### Auto-register in routing
After saving new agent file to .claude/agents/[name].md:
1. Read CLAUDE.md
2. Find the "Agent Roster" table
3. Add new row: `| @[name] | [emoji] | [Name] | [domain description] |`
4. Find the natural language routing table
5. Add entry: `| "[trigger phrases]" | route to @[name] |`
6. Confirm: "✅ @[name] dodany do systemu. Możesz go wywołać przez @[name] lub [natural language triggers]."

If CLAUDE.md edit fails → inform user: "Agent stworzony ale musisz ręcznie dodać go do routingu w CLAUDE.md."

```
"✅ @[name] is live! Try talking to them:
'@[name] [one of the user's example questions]'"
```

## Rules
- Agent names must be lowercase, no spaces (use hyphens)
- Emoji: let user pick or auto-assign based on domain
- Always include appropriate disclaimers (medical, legal, financial)
- Agent file should be ~200 words (tight, focused)

---
name: Vault
description: "Manage your secrets and API keys. Add, list, show (masked), or remove stored credentials."
user_invocable: true
command: /vault
---

# /vault — Secrets Manager

**Adapt to tech_comfort:** "not technical" → "Sejf na hasła i klucze. Bezpieczne, na Twoim komputerze." "I use apps" → explain what API keys are. "I code" → show paths and permissions.

Vault stores API keys, tokens, and credentials locally in `.secrets/vault.json` with chmod 600 permissions.
It NEVER prints secret values in responses unless the user explicitly types "show full".

---

## Commands

| Command | What it does |
|---------|-------------|
| `/vault` | Show status — how many secrets stored, no values |
| `/vault add [service]` | Guided add flow |
| `/vault list` | Show all services with masked values |
| `/vault show [service]` | Show one secret (masked by default) |
| `/vault remove [service]` | Remove a secret with confirmation |

---

## /vault — STATUS

```
⏳ Checking vault...
```

Read `.secrets/vault.json`. If it doesn't exist → show empty state.

Show:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔐  VAULT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [X] secrets stored
  📍 Stored locally on your computer (protected)

  Services:
  ┌─────────────────────────────────────┐
  │  openai          ••••••••           │
  │  supabase        ••••••••           │
  │  anthropic       ••••••••           │
  └─────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  /vault add [service]   → add a secret
  /vault list            → see all (masked)
  /vault show [service]  → see specific
  /vault remove [service]→ delete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If vault is empty:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔐  VAULT — empty
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  No secrets stored yet.

  Start with:
    /vault add openai
    /vault add supabase
    /vault add anthropic
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## /vault add [service]

If service name not provided, ask: "Which service are you adding a secret for?"

### Guided add flow:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔐  Adding: [SERVICE]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Ask what fields to store. Common services have preset fields:

| Service | Fields |
|---------|--------|
| openai | api_key |
| anthropic | api_key |
| supabase | url, anon_key, service_role_key |
| github | token |
| google | client_id, client_secret |
| stripe | public_key, secret_key |
| resend | api_key |
| telegram | bot_token |
| custom | ask user to define |

Use `AskUserQuestion`:
- header: "Fields for [service]"
- options: preset fields for this service + "Custom — I'll define my own"

**Before accepting any secret value, show this warning:**
```
⚠️ Heads up: anything you type here is processed by Anthropic's
   servers as part of this conversation. If that concerns you,
   you can paste the key directly into .secrets/vault.json
   using a text editor instead.
```

For each field, ask the user to paste the value. Accept the input. NEVER repeat or echo the raw value back in the response.

After each value:
```
  ✅ [field_name] saved
```

### First use — initialize vault:

If `.secrets/` directory doesn't exist:
```
⏳ Creating .secrets/ directory...  ✅
⏳ Setting permissions (chmod 600)... ✅
⏳ Creating vault.json...           ✅
```

### vault.json format:

```json
{
  "version": 1,
  "created_at": "2026-02-28T12:00:00Z",
  "secrets": {
    "openai": {
      "api_key": "sk-...",
      "added_at": "2026-02-28T12:00:00Z"
    },
    "supabase": {
      "url": "https://xxx.supabase.co",
      "anon_key": "eyJ...",
      "service_role_key": "eyJ...",
      "added_at": "2026-02-28T12:00:00Z"
    }
  }
}
```

After saving:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✅ [SERVICE] saved to vault

  [X] field(s) stored.
  Vault now has [N] services.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## /vault list

Show all stored services with masked values.

**Masking rule:** show `****` + last 4 characters. If value is shorter than 8 chars → show `****` only.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔐  VAULT — [N] services
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  openai
  ┌─────────────────────────────────────┐
  │  api_key      ****ef56             │
  └─────────────────────────────────────┘

  supabase
  ┌─────────────────────────────────────┐
  │  url          ****.co              │
  │  anon_key     ****Jh9z             │
  │  service_key  ****Kw2x             │
  └─────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  /vault show [service]  → see details
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## /vault show [service]

Show a specific secret's fields. Always masked by default.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔐  [SERVICE]
  Added: [date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  api_key:   ****ef56
  Added:     2026-02-28

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then use `AskUserQuestion`:
- header: "Show full value?"
- options: "No — I just needed to check it's there" / "Yes — show me the full value"

If YES → show the unmasked value in a code block:

```
  api_key:
  ┌─────────────────────────────────────┐
  │ sk-proj-abcdef123456...             │
  └─────────────────────────────────────┘

  ⚠️ Copy it now — this message will stay
  in your conversation history.
```

**IMPORTANT:** Only show full values when user explicitly selects "Yes — show me the full value". Default = always masked.

---

## /vault remove [service]

Always require confirmation before deleting.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⚠️  Remove [SERVICE]?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  This will delete [N] field(s):
  • api_key
  • (other fields...)

  This cannot be undone.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion`:
- header: "Confirm removal"
- options: "Yes, delete [service]" / "Cancel — keep it"

If confirmed:
```
⏳ Removing [service]...  ✅

  [SERVICE] removed from vault.
  Vault now has [N] services.
```

If cancelled:
```
  Cancelled. [SERVICE] is still in vault.
```

---

## FILE PERMISSION ENFORCEMENT

After creating or modifying .secrets/ files:
1. Verify permissions: `ls -la .secrets/` — should show `-rw-------` (600)
2. If permissions are wrong → fix: note to user "Uprawnienia pliku naprawione na 600 (tylko Ty masz dostęp)"
3. On every /vault read → re-check permissions. If changed → warn and fix.
4. .secrets/ directory should be 700 (drwx------). Verify on each access.

**Supabase guard:** Before ANY write operation, check target path.
If target contains "supabase" or is a remote operation → BLOCK and warn:
"⚠️ Vault jest tylko lokalny. Sekrety NIGDY nie trafiają do chmury."

---

## SECURITY RULES

1. **NEVER** print a secret value in a response unless the user explicitly selects "Yes — show me the full value" via `AskUserQuestion`.
2. **NEVER** store secrets in agent memory, `memory` Supabase table, state files, or any file outside `.secrets/`.
3. **NEVER** echo back a secret the user just pasted (even partially).
4. If a user pastes a secret in regular conversation → acknowledge, offer to store in vault, do NOT memorize the value.
5. `.secrets/vault.json` permissions must be `chmod 600` — readable only by the current user.
6. Vault is LOCAL ONLY. Never sync to Supabase, cloud, or any external service.

---

## ERROR HANDLING

- **vault.json not found** → treat as empty vault (not an error)
- **service not found** → "No secret named '[service]' in vault. Use `/vault list` to see what's stored."
- **JSON parse error** → "Vault file seems corrupted. Want me to show you the raw contents so you can fix it, or reset the vault?"
- **Permission denied** → "Can't read .secrets/ — check that the directory has correct permissions: `chmod 700 .secrets/`"

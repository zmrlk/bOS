#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  bOS — Update Script
#  Replaces system files, preserves your data.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# ── Detect paths ──────────────────────────────

NEW_BOS="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=0
EXISTING_BOS=""
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        *) [ -z "$EXISTING_BOS" ] && EXISTING_BOS="$arg" ;;
    esac
done

if [ -z "$EXISTING_BOS" ]; then
    echo ""
    echo -e "${BOLD}bOS Update${NC}"
    echo ""
    echo "Usage:  bash update.sh /path/to/your/existing/bOS [--dry-run]"
    echo ""
    echo "Example:"
    echo "  bash ~/Downloads/bOS/update.sh ~/Desktop/bOS"
    echo ""
    exit 1
fi

# Resolve to absolute path
EXISTING_BOS="$(cd "$EXISTING_BOS" 2>/dev/null && pwd)" || {
    echo -e "${RED}Error: Folder not found: $1${NC}"
    exit 1
}

# ── Validate ──────────────────────────────────

if [ "$NEW_BOS" = "$EXISTING_BOS" ]; then
    echo -e "${RED}Error: New and existing bOS are the same folder.${NC}"
    echo "Extract the new bOS to a DIFFERENT location first."
    exit 1
fi

if [ ! -f "$NEW_BOS/VERSION" ]; then
    echo -e "${RED}Error: No VERSION file in $NEW_BOS. Is this a valid bOS release?${NC}"
    exit 1
fi

if [ ! -f "$NEW_BOS/CLAUDE.md" ]; then
    echo -e "${RED}Error: No CLAUDE.md in $NEW_BOS. Is this a valid bOS release?${NC}"
    exit 1
fi

if [ ! -f "$EXISTING_BOS/CLAUDE.md" ]; then
    echo -e "${RED}Error: No CLAUDE.md in $EXISTING_BOS. Is this a valid bOS installation?${NC}"
    exit 1
fi

NEW_VERSION=$(cat "$NEW_BOS/VERSION" | tr -d '[:space:]')
OLD_VERSION="unknown"
if [ -f "$EXISTING_BOS/VERSION" ]; then
    OLD_VERSION=$(cat "$EXISTING_BOS/VERSION" | tr -d '[:space:]')
fi

if [ "$NEW_VERSION" = "$OLD_VERSION" ]; then
    echo ""
    echo -e "${GREEN}Already up to date (v${OLD_VERSION}).${NC}"
    exit 0
fi

# ── Show plan ─────────────────────────────────

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  bOS Update: ${OLD_VERSION} → ${NEW_VERSION}${NC}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}PRESERVE (your data):${NC}"
echo "    profile.md"
echo "    state/*.md (tasks, finances, habits...)"
echo "    memory/ (durable cross-CLI memory)"
echo "    .secrets/"
echo ""
echo -e "  ${YELLOW}UPDATE (system files):${NC}"
echo "    CLAUDE.md, AGENTS.md"
echo "    .claude/agents/  .claude/skills/  .claude/hooks/"
echo "    .claude/settings.json"
echo "    .agents/  .codex/  .grok/  scripts/  config/"
echo "    VERSION, README.md, PRIVACY.md"
echo "    profile-template.md"
echo "    state/SCHEMAS.md, templates/state/, templates/memory/, templates/demo/"
echo "    examples/"
echo ""
echo "  Note: customized skills/agents/hooks are overwritten"
echo "  (a copy goes to the backup folder first)."
echo ""

if [ "$DRY_RUN" -eq 1 ]; then
    echo -e "  ${YELLOW}DRY RUN${NC} — nothing was copied, nothing was changed."
    echo "  Run again without --dry-run to apply."
    exit 0
fi

read -p "  Continue? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy] ]]; then
    echo "  Cancelled."
    exit 0
fi

echo ""

# ── Backup ────────────────────────────────────

BACKUP_DIR="$EXISTING_BOS/state/.backup/pre-update-${OLD_VERSION}-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Everything the updater may touch gets backed up first — the same list the
# rollback below restores. User data (state/, profile.md, .secrets/) is never
# touched by apply, so it needs no restore; profile.md is backed up anyway.
SYSTEM_ITEMS="CLAUDE.md AGENTS.md README.md PRIVACY.md HONESTY.md SECURITY.md VERSION profile-template.md update.sh .gitignore .gitattributes state/SCHEMAS.md state/context-bus.md .claude/settings.json .claude/agents .claude/skills .claude/hooks .agents .codex .grok scripts config examples templates tests docs .github"

backup_item() {
    local item="$1"
    [ -e "$EXISTING_BOS/$item" ] || return 0
    mkdir -p "$BACKUP_DIR/$(dirname "$item")"
    cp -R -P "$EXISTING_BOS/$item" "$BACKUP_DIR/$item"
}
if [ -f "$EXISTING_BOS/profile.md" ]; then
    cp "$EXISTING_BOS/profile.md" "$BACKUP_DIR/profile.md"
fi
for item in $SYSTEM_ITEMS; do backup_item "$item"; done

rollback() {
    echo ""
    echo -e "  ${YELLOW}Rolling back from $BACKUP_DIR ...${NC}"
    for item in $SYSTEM_ITEMS; do
        if [ -e "$BACKUP_DIR/$item" ]; then
            rm -rf "${EXISTING_BOS:?}/$item"
            mkdir -p "$EXISTING_BOS/$(dirname "$item")"
            cp -R -P "$BACKUP_DIR/$item" "$EXISTING_BOS/$item"
        elif [ -e "$EXISTING_BOS/$item" ]; then
            # Item did not exist before this update (e.g. templates/, tests/,
            # docs/ on an older install) — a true rollback removes it.
            rm -rf "${EXISTING_BOS:?}/$item"
        fi
    done
    # Restore the git index if the boundary migration already ran: the files
    # are untouched on disk, so re-adding them recreates the identical index.
    if [ -f "$BACKUP_DIR/untracked-state.txt" ] && [ -d "$EXISTING_BOS/.git" ]; then
        # `git add` has no --quiet; a stray flag here would abort the whole
        # rollback under set -e and leave the index half-restored.
        ( cd "$EXISTING_BOS" && while IFS= read -r f; do
            if [ -n "$f" ] && [ -e "$f" ]; then
              git add -f -- "$f" >/dev/null 2>&1 || echo "  (could not re-stage $f)"
            fi
          done < "$BACKUP_DIR/untracked-state.txt" ) || true
        rm -f "$BACKUP_DIR/untracked-state.txt"
        echo -e "  ${GREEN}✓${NC} git index restored (untracked files re-staged)."
    fi
    echo -e "  ${GREEN}✓${NC} Rolled back. Your installation is as it was before the update."
}

echo -e "  ${GREEN}✓${NC} Backup created: state/.backup/pre-update-${OLD_VERSION}-..."

# Any failure during apply (set -e) triggers an automatic rollback — the
# installation is never left half-updated.
on_apply_error() {
    echo -e "  ${RED}✗ Update failed mid-apply.${NC}"
    rollback
    exit 1
}
trap on_apply_error ERR

# ── Copy system files ─────────────────────────

# CLAUDE.md + AGENTS.md (shared contract)
cp "$NEW_BOS/CLAUDE.md" "$EXISTING_BOS/CLAUDE.md"
echo -e "  ${GREEN}✓${NC} CLAUDE.md"
if [ -f "$NEW_BOS/AGENTS.md" ]; then
    cp "$NEW_BOS/AGENTS.md" "$EXISTING_BOS/AGENTS.md"
    echo -e "  ${GREEN}✓${NC} AGENTS.md"
fi

# VERSION
cp "$NEW_BOS/VERSION" "$EXISTING_BOS/VERSION"
echo -e "  ${GREEN}✓${NC} VERSION"

# Agents
if [ -d "$NEW_BOS/.claude/agents" ]; then
    mkdir -p "$EXISTING_BOS/.claude/agents"
    cp -r "$NEW_BOS/.claude/agents/"* "$EXISTING_BOS/.claude/agents/"
    echo -e "  ${GREEN}✓${NC} .claude/agents/"
fi

# Skills
if [ -d "$NEW_BOS/.claude/skills" ]; then
    mkdir -p "$EXISTING_BOS/.claude/skills"
    cp -r "$NEW_BOS/.claude/skills/"* "$EXISTING_BOS/.claude/skills/"
    echo -e "  ${GREEN}✓${NC} .claude/skills/"

    # Orphan check: skills present locally but absent from this release.
    # Never delete silently — list them and ask once.
    ORPHANS=""
    for d in "$EXISTING_BOS/.claude/skills"/*/; do
        name=$(basename "$d")
        if [ ! -d "$NEW_BOS/.claude/skills/$name" ]; then
            ORPHANS="$ORPHANS $name"
        fi
    done
    if [ -n "$ORPHANS" ]; then
        echo ""
        echo -e "  ${YELLOW}These skills are not part of v${NEW_VERSION}:${NC}$ORPHANS"
        echo "  (your own custom skills belong here too — keep them!)"
        read -p "  Remove the ones listed above? [y/N] " rm_orphans
        if [[ "$rm_orphans" =~ ^[Yy] ]]; then
            for name in $ORPHANS; do
                cp -r "$EXISTING_BOS/.claude/skills/$name" "$BACKUP_DIR/removed-skill-$name" 2>/dev/null
                rm -rf "$EXISTING_BOS/.claude/skills/$name"
                echo -e "  ${GREEN}✓${NC} removed $name (backup in state/.backup/)"
            done
        else
            echo "  Kept. They stay untouched."
        fi
    fi
fi

# Codex/agents symlink layer (mirrors .claude/skills for AGENTS.md hosts)
if [ -d "$NEW_BOS/.agents" ]; then
    mkdir -p "$EXISTING_BOS/.agents"
    cp -R "$NEW_BOS/.agents/"* "$EXISTING_BOS/.agents/" 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} .agents/ (symlink layer)"
fi

# Hooks (the scripts settings.json points at)
if [ -d "$NEW_BOS/.claude/hooks" ]; then
    mkdir -p "$EXISTING_BOS/.claude/hooks"
    cp -r "$NEW_BOS/.claude/hooks/"* "$EXISTING_BOS/.claude/hooks/"
    chmod +x "$EXISTING_BOS/.claude/hooks/"*.sh 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} .claude/hooks/"
fi

# Settings
if [ -f "$NEW_BOS/.claude/settings.json" ]; then
    cp "$NEW_BOS/.claude/settings.json" "$EXISTING_BOS/.claude/settings.json"
    echo -e "  ${GREEN}✓${NC} .claude/settings.json"
fi

# Helper scripts (bus append, roster)
if [ -d "$NEW_BOS/scripts" ]; then
    mkdir -p "$EXISTING_BOS/scripts"
    cp -r "$NEW_BOS/scripts/"* "$EXISTING_BOS/scripts/"
    chmod +x "$EXISTING_BOS/scripts/"*.sh 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} scripts/"
fi

# Cross-CLI configs
for d in .codex .grok config; do
    if [ -d "$NEW_BOS/$d" ]; then
        mkdir -p "$EXISTING_BOS/$d"
        cp -r "$NEW_BOS/$d/"* "$EXISTING_BOS/$d/"
        echo -e "  ${GREEN}✓${NC} $d/"
    fi
done

# Docs and dotfiles that the piecemeal copies above do not cover.
# .gitignore is load-bearing: it is what keeps user state out of git (P0).
for f in README.md PRIVACY.md HONESTY.md SECURITY.md .gitignore .gitattributes; do
    if [ -f "$NEW_BOS/$f" ]; then
        cp "$NEW_BOS/$f" "$EXISTING_BOS/$f"
        echo -e "  ${GREEN}✓${NC} $f"
    fi
done
for d in docs .github; do
    if [ -d "$NEW_BOS/$d" ]; then
        mkdir -p "$EXISTING_BOS/$d"
        cp -R "$NEW_BOS/$d/"* "$EXISTING_BOS/$d/" 2>/dev/null || true
        echo -e "  ${GREEN}✓${NC} $d/"
    fi
done

# Profile template (reference, not user data)
if [ -f "$NEW_BOS/profile-template.md" ]; then
    cp "$NEW_BOS/profile-template.md" "$EXISTING_BOS/profile-template.md"
    echo -e "  ${GREEN}✓${NC} profile-template.md"
fi

# State schemas (reference, not user data)
if [ -f "$NEW_BOS/state/SCHEMAS.md" ]; then
    cp "$NEW_BOS/state/SCHEMAS.md" "$EXISTING_BOS/state/SCHEMAS.md"
    echo -e "  ${GREEN}✓${NC} state/SCHEMAS.md"
fi

# Blank state templates (user's live state/ is NEVER touched)
if [ -d "$NEW_BOS/templates/state" ]; then
    mkdir -p "$EXISTING_BOS/templates/state"
    cp -r "$NEW_BOS/templates/state/"* "$EXISTING_BOS/templates/state/"
    echo -e "  ${GREEN}✓${NC} templates/state/"
fi

# Memory schema/examples only (user's live memory/ is NEVER touched)
if [ -d "$NEW_BOS/templates/memory" ]; then
    mkdir -p "$EXISTING_BOS/templates/memory"
    cp -r "$NEW_BOS/templates/memory/"* "$EXISTING_BOS/templates/memory/"
    echo -e "  ${GREEN}✓${NC} templates/memory/"
fi

# Demo fixture for /setup (only ever copied into state/ by demo.sh, with consent)
if [ -d "$NEW_BOS/templates/demo" ]; then
    mkdir -p "$EXISTING_BOS/templates/demo"
    cp -r "$NEW_BOS/templates/demo/"* "$EXISTING_BOS/templates/demo/"
    echo -e "  ${GREEN}✓${NC} templates/demo/"
fi

# Test suite (used for the post-update self-test)
if [ -d "$NEW_BOS/tests" ]; then
    mkdir -p "$EXISTING_BOS/tests"
    cp -r "$NEW_BOS/tests/"* "$EXISTING_BOS/tests/"
    echo -e "  ${GREEN}✓${NC} tests/"
fi

# Examples (supabase schemas, n8n templates, ntfy hooks, sample skills)
if [ -d "$NEW_BOS/examples" ]; then
    mkdir -p "$EXISTING_BOS/examples"
    cp -r "$NEW_BOS/examples/"* "$EXISTING_BOS/examples/"
    echo -e "  ${GREEN}✓${NC} examples/"
fi

# update.sh itself
cp "$NEW_BOS/update.sh" "$EXISTING_BOS/update.sh"

# ── Update profile.md version ─────────────────

if [ -f "$EXISTING_BOS/profile.md" ]; then
    # The profile carries the version in a markdown table
    # (| **bOS version** | x.y.z |); older profiles used a bare key.
    PROFILE_BUMPED=0
    sed_inplace() {
        sed -i '' "$1" "$EXISTING_BOS/profile.md" 2>/dev/null || \
        sed -i "$1" "$EXISTING_BOS/profile.md" 2>/dev/null || return 1
    }
    if grep -q "bOS version" "$EXISTING_BOS/profile.md"; then
        sed_inplace "s/| \*\*bOS version\*\* | .* |/| **bOS version** | ${NEW_VERSION} |/" && PROFILE_BUMPED=1
    fi
    if grep -q "bos_version:" "$EXISTING_BOS/profile.md"; then
        sed_inplace "s/bos_version: .*/bos_version: ${NEW_VERSION}/" && PROFILE_BUMPED=1
    fi
    [ "$PROFILE_BUMPED" = "1" ] && echo -e "  ${GREEN}✓${NC} profile.md → version ${NEW_VERSION}"
fi

trap - ERR

# ── Data-boundary migration (v0.13.1+) ────────
# Older installs tracked state/*.md in git. The new .gitignore alone does not
# untrack an already-indexed file — do it explicitly, WITHOUT deleting data.
if [ -d "$EXISTING_BOS/.git" ]; then
    LEGACY=$( cd "$EXISTING_BOS" && git ls-files state/ 2>/dev/null \
        | grep -vE '^state/(SCHEMAS\.md|context-bus\.md|\.gitkeep)$' || true )
    if [ -n "$LEGACY" ]; then
        echo ""
        echo -e "  ${YELLOW}Data boundary:${NC} these personal files are still tracked by git:"
        echo "$LEGACY" | sed 's/^/    /'
        echo "  They stay on disk — only git stops tracking them."
        read -p "  Untrack them now? [Y/n] " do_untrack
        if [[ ! "$do_untrack" =~ ^[Nn] ]]; then
            # Record what we untrack so a later rollback can restore the index
            # exactly — otherwise "as it was" would leave staged deletions.
            printf '%s\n' "$LEGACY" > "$BACKUP_DIR/untracked-state.txt"
            ( cd "$EXISTING_BOS" && echo "$LEGACY" | while IFS= read -r f; do
                [ -n "$f" ] && git rm --cached --quiet "$f" 2>/dev/null
              done )
            echo -e "  ${GREEN}✓${NC} Untracked. Commit the change when convenient — your data is intact."
        else
            echo -e "  ${YELLOW}Skipped — your personal state stays in the git index.${NC}"
        fi
    fi
fi

# ── Post-update self-test ─────────────────────

if [ -f "$EXISTING_BOS/tests/run.sh" ]; then
    echo ""
    echo -e "  Running post-update self-test ..."
    if ( cd "$EXISTING_BOS" && bash tests/run.sh >/tmp/bos-update-test.log 2>&1 ); then
        echo -e "  ${GREEN}✓${NC} Self-test passed ($(grep -o '[0-9]* passed' /tmp/bos-update-test.log | head -1))."
    else
        echo -e "  ${RED}✗ Self-test FAILED.${NC} Log: /tmp/bos-update-test.log"
        read -p "  Roll back to the pre-update state? [Y/n] " do_rb
        if [[ ! "$do_rb" =~ ^[Nn] ]]; then
            rollback
            exit 1
        fi
        echo -e "  ${YELLOW}Kept the updated (failing) files — backup remains in state/.backup/.${NC}"
    fi
fi

# ── Done ──────────────────────────────────────

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  ${GREEN}bOS updated: ${OLD_VERSION} → ${NEW_VERSION}${NC}"
echo ""
echo -e "  Your data is safe:"
echo -e "    ${GREEN}✓${NC} profile.md — your content untouched (only the bos_version field is bumped)"
echo -e "    ${GREEN}✓${NC} state/ — untouched"
echo -e "    ${GREEN}✓${NC} memory/ — untouched"
echo -e "    ${GREEN}✓${NC} .secrets/ — untouched"
echo ""
echo -e "  Open bOS in Claude Code and say hi."
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

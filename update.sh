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
EXISTING_BOS="$1"

if [ -z "$EXISTING_BOS" ]; then
    echo ""
    echo -e "${BOLD}bOS Update${NC}"
    echo ""
    echo "Usage:  bash update.sh /path/to/your/existing/bOS"
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
echo "    .secrets/"
echo ""
echo -e "  ${YELLOW}UPDATE (system files):${NC}"
echo "    CLAUDE.md"
echo "    .claude/agents/"
echo "    .claude/skills/"
echo "    .claude/settings.json"
echo "    VERSION, README.md, PRIVACY.md"
echo "    profile-template.md"
echo "    state/SCHEMAS.md"
echo "    supabase/"
echo ""

read -p "  Continue? [Y/n] " confirm
if [[ "$confirm" =~ ^[Nn] ]]; then
    echo "  Cancelled."
    exit 0
fi

echo ""

# ── Backup ────────────────────────────────────

BACKUP_DIR="$EXISTING_BOS/state/.backup/pre-update-${OLD_VERSION}-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -f "$EXISTING_BOS/profile.md" ]; then
    cp "$EXISTING_BOS/profile.md" "$BACKUP_DIR/profile.md"
fi
cp "$EXISTING_BOS/CLAUDE.md" "$BACKUP_DIR/CLAUDE.md"
if [ -f "$EXISTING_BOS/VERSION" ]; then
    cp "$EXISTING_BOS/VERSION" "$BACKUP_DIR/VERSION"
fi

echo -e "  ${GREEN}✓${NC} Backup created: state/.backup/pre-update-${OLD_VERSION}-..."

# ── Copy system files ─────────────────────────

# CLAUDE.md
cp "$NEW_BOS/CLAUDE.md" "$EXISTING_BOS/CLAUDE.md"
echo -e "  ${GREEN}✓${NC} CLAUDE.md"

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
fi

# Settings
if [ -f "$NEW_BOS/.claude/settings.json" ]; then
    cp "$NEW_BOS/.claude/settings.json" "$EXISTING_BOS/.claude/settings.json"
    echo -e "  ${GREEN}✓${NC} .claude/settings.json"
fi

# README, PRIVACY
for f in README.md PRIVACY.md; do
    if [ -f "$NEW_BOS/$f" ]; then
        cp "$NEW_BOS/$f" "$EXISTING_BOS/$f"
        echo -e "  ${GREEN}✓${NC} $f"
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

# Supabase schemas
if [ -d "$NEW_BOS/supabase" ]; then
    mkdir -p "$EXISTING_BOS/supabase"
    cp -r "$NEW_BOS/supabase/"* "$EXISTING_BOS/supabase/"
    echo -e "  ${GREEN}✓${NC} supabase/"
fi

# Templates
if [ -d "$NEW_BOS/templates" ]; then
    mkdir -p "$EXISTING_BOS/templates"
    cp -r "$NEW_BOS/templates/"* "$EXISTING_BOS/templates/"
    echo -e "  ${GREEN}✓${NC} templates/"
fi

# update.sh itself
cp "$NEW_BOS/update.sh" "$EXISTING_BOS/update.sh"

# ── Update profile.md version ─────────────────

if [ -f "$EXISTING_BOS/profile.md" ]; then
    # Update bos_version field if it exists
    if grep -q "bos_version:" "$EXISTING_BOS/profile.md"; then
        sed -i '' "s/bos_version: .*/bos_version: ${NEW_VERSION}/" "$EXISTING_BOS/profile.md" 2>/dev/null || \
        sed -i "s/bos_version: .*/bos_version: ${NEW_VERSION}/" "$EXISTING_BOS/profile.md" 2>/dev/null || true
        echo -e "  ${GREEN}✓${NC} profile.md → bos_version: ${NEW_VERSION}"
    fi
fi

# ── Done ──────────────────────────────────────

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}  ${GREEN}bOS updated: ${OLD_VERSION} → ${NEW_VERSION}${NC}"
echo ""
echo -e "  Your data is safe:"
echo -e "    ${GREEN}✓${NC} profile.md — untouched"
echo -e "    ${GREEN}✓${NC} state/ — untouched"
echo -e "    ${GREEN}✓${NC} .secrets/ — untouched"
echo ""
echo -e "  Open bOS in Claude Code and say hi."
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

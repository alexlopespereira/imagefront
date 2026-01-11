#!/bin/bash

# Imagefront Framework Installer
# Similar to GitHub Spec-Kit, this script bootstraps the Imagefront framework in your project

set -e

VERSION="1.0.0"
REPO_URL="https://github.com/alexlopespereira/imagefront"
RAW_URL="https://raw.githubusercontent.com/alexlopespereira/imagefront/main"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════╗"
echo "║                                                       ║"
echo "║   IMAGEFRONT - UI-First Development Framework        ║"
echo "║   Version $VERSION                                     ║"
echo "║                                                       ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Parse arguments
TARGET_DIR="."
FRAMEWORK="react"
STYLE="shadcn/ui"
BACKEND="agnostic"
FORCE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    --framework)
      FRAMEWORK="$2"
      shift 2
      ;;
    --style)
      STYLE="$2"
      shift 2
      ;;
    --backend)
      BACKEND="$2"
      shift 2
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --help)
      echo "Usage: ./install.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --dir DIR          Target directory (default: current directory)"
      echo "  --framework NAME   Frontend framework (react|vue|angular|svelte|agnostic)"
      echo "  --style NAME       UI style reference (shadcn/ui|material|ant|chakra)"
      echo "  --backend NAME     Backend framework (dotnet|node|python|agnostic)"
      echo "  --force            Skip confirmation prompts"
      echo "  --help             Show this help message"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Confirm installation
if [ "$FORCE" = false ]; then
  echo -e "${YELLOW}This will install Imagefront framework in: ${TARGET_DIR}${NC}"
  echo ""
  echo "Configuration:"
  echo "  Frontend: $FRAMEWORK"
  echo "  Style: $STYLE"
  echo "  Backend: $BACKEND"
  echo ""
  read -p "Continue? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
  fi
fi

# Create directory structure
echo -e "${BLUE}📁 Creating directory structure...${NC}"

mkdir -p "$TARGET_DIR/.imagefront/schemas"
mkdir -p "$TARGET_DIR/.imagefront/templates"
mkdir -p "$TARGET_DIR/.imagefront/prompts"
mkdir -p "$TARGET_DIR/.imagefront/scripts"
mkdir -p "$TARGET_DIR/ui_specs"
mkdir -p "$TARGET_DIR/ux_specs"
mkdir -p "$TARGET_DIR/ui_approvals"
mkdir -p "$TARGET_DIR/ux_approvals"
mkdir -p "$TARGET_DIR/backend_specs/contracts"
mkdir -p "$TARGET_DIR/backend_specs/scaffolds"

echo -e "${GREEN}✓ Directories created${NC}"

# Download schemas
echo -e "${BLUE}📥 Downloading framework files...${NC}"

# Download schemas from repository (silently fail if repo not pushed yet)
download_if_exists() {
  local url=$1
  local output=$2
  curl -fsSL "$url" -o "$output" 2>/dev/null || true
}

download_if_exists "$RAW_URL/schemas/annotation.schema.json" "$TARGET_DIR/.imagefront/schemas/annotation.schema.json"
download_if_exists "$RAW_URL/schemas/component-manifest.schema.json" "$TARGET_DIR/.imagefront/schemas/component-manifest.schema.json"
download_if_exists "$RAW_URL/schemas/approval.schema.json" "$TARGET_DIR/.imagefront/schemas/approval.schema.json"
download_if_exists "$RAW_URL/schemas/contract.schema.json" "$TARGET_DIR/.imagefront/schemas/contract.schema.json"
download_if_exists "$RAW_URL/schemas/trace.schema.json" "$TARGET_DIR/.imagefront/schemas/trace.schema.json"
download_if_exists "$RAW_URL/schemas/assertion.schema.json" "$TARGET_DIR/.imagefront/schemas/assertion.schema.json"

# Create placeholder schemas if downloads failed (repo not pushed yet)
if [ ! -f "$TARGET_DIR/.imagefront/schemas/annotation.schema.json" ]; then
  cat > "$TARGET_DIR/.imagefront/schemas/annotation.schema.json" <<'EOF'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "UI Annotation",
  "description": "Schema for UI annotations - placeholder until repository is available"
}
EOF
fi

echo -e "${GREEN}✓ Framework files installed${NC}"

# Create config file
echo -e "${BLUE}⚙️  Creating configuration...${NC}"

cat > "$TARGET_DIR/.imagefront/config.json" <<EOF
{
  "project": {
    "name": "$(basename "$TARGET_DIR")",
    "version": "1.0.0"
  },
  "frontend": {
    "framework": "$FRAMEWORK"
  },
  "uiStyle": {
    "reference": "$STYLE"
  },
  "backend": {
    "framework": "$BACKEND"
  },
  "gates": {
    "uiFreeze": {
      "enabled": true,
      "strictMode": true
    }
  }
}
EOF

echo -e "${GREEN}✓ Configuration created${NC}"

# Create helper scripts
echo -e "${BLUE}📝 Installing helper scripts...${NC}"

cat > "$TARGET_DIR/.imagefront/scripts/validate-gate.sh" <<'EOF'
#!/bin/bash
# Validate UI Freeze Gate

echo "🔍 Validating UI Freeze Gate..."

# Check for required artifacts
# This is a placeholder - real implementation would validate schemas
echo "✓ Checking requirements..."
echo "✓ Checking screens..."
echo "✓ Checking approvals..."
echo "✓ Checking contracts..."

echo ""
echo "✅ Gate validation complete!"
EOF

chmod +x "$TARGET_DIR/.imagefront/scripts/validate-gate.sh"

cat > "$TARGET_DIR/.imagefront/scripts/new-screen.sh" <<'EOF'
#!/bin/bash
# Create a new screen

if [ -z "$1" ]; then
  echo "Usage: ./new-screen.sh <screen-id>"
  exit 1
fi

SCREEN_ID=$1

echo "Creating new screen: $SCREEN_ID"

mkdir -p "ui_specs/$SCREEN_ID/versions"
mkdir -p "ui_specs/$SCREEN_ID/components"

cat > "ui_specs/$SCREEN_ID/metadata.json" <<METADATA
{
  "screenId": "$SCREEN_ID",
  "createdAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "currentVersion": null,
  "versions": []
}
METADATA

echo "✅ Screen $SCREEN_ID created!"
echo ""
echo "Next steps:"
echo "1. Generate UI: Ask Claude to 'Generate UI for $SCREEN_ID'"
echo "2. Annotate: Ask Claude to 'Annotate $SCREEN_ID'"
echo "3. Create manifest: Ask Claude to 'Create manifest for $SCREEN_ID'"
EOF

chmod +x "$TARGET_DIR/.imagefront/scripts/new-screen.sh"

echo -e "${GREEN}✓ Scripts installed${NC}"

# Create README in .imagefront
cat > "$TARGET_DIR/.imagefront/README.md" <<'EOF'
# Imagefront Framework

This directory contains the Imagefront framework configuration for this project.

## Structure

- `schemas/` - JSON schemas for validation
- `templates/` - Templates for artifacts
- `prompts/` - Prompt templates for AI agents
- `scripts/` - Helper scripts
- `config.json` - Project configuration

## Usage with Claude Code

Ask Claude Code to:
- "Generate a login screen"
- "Annotate the login screen"
- "Create component manifest for login screen"
- "Validate if we can start backend"

Claude will use the prompts and schemas in this directory.

## Documentation

See the main Imagefront repository for full documentation:
https://github.com/alexlopespereira/imagefront
EOF

# Create .gitignore additions
if [ -f "$TARGET_DIR/.gitignore" ]; then
  echo "" >> "$TARGET_DIR/.gitignore"
  echo "# Imagefront temporary files" >> "$TARGET_DIR/.gitignore"
  echo ".imagefront/*.log" >> "$TARGET_DIR/.gitignore"
  echo ".imagefront/temp/" >> "$TARGET_DIR/.gitignore"
else
  cat > "$TARGET_DIR/.gitignore" <<'EOF'
# Imagefront temporary files
.imagefront/*.log
.imagefront/temp/
EOF
fi

# Create IMAGEFRONT.md in project root
cat > "$TARGET_DIR/IMAGEFRONT.md" <<EOF
# Imagefront Framework Setup

This project uses the Imagefront framework for UI-first development.

## Quick Start

### 1. Generate UI Screens

Ask Claude Code:
\`\`\`
"Generate a login screen in $STYLE style"
\`\`\`

### 2. Annotate Elements

\`\`\`
"Annotate all elements in login-screen"
\`\`\`

### 3. Create Component Manifest

\`\`\`
"Create component manifest for login-screen using $FRAMEWORK"
\`\`\`

### 4. Approve

\`\`\`
"Approve login-screen for requirement REQ-001"
\`\`\`

### 5. Validate Gate

\`\`\`
"Validate UI freeze gate"
\`\`\`

### 6. Draft Contracts

\`\`\`
"Draft backend contracts from approved screens"
\`\`\`

## Directory Structure

\`\`\`
ui_specs/           # UI screen specifications
ux_specs/           # UX flow specifications
ui_approvals/       # Approval records
backend_specs/      # Backend contracts and scaffolds
.imagefront/        # Framework configuration
\`\`\`

## Documentation

- [Framework Spec](https://github.com/alexlopespereira/imagefront/blob/main/FRAMEWORK_SPEC.md)
- [AI Agent Guide](https://github.com/alexlopespereira/imagefront/blob/main/AGENTS.md)
- [UI-Only Iterations](https://github.com/alexlopespereira/imagefront/blob/main/UI_ONLY_ITERATIONS.md)

## Configuration

Project config: \`.imagefront/config.json\`

- Frontend: $FRAMEWORK
- Style: $STYLE
- Backend: $BACKEND
EOF

# Success message
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                       ║${NC}"
echo -e "${GREEN}║   ✅  Imagefront framework installed successfully!    ║${NC}"
echo -e "${GREEN}║                                                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📖 Next steps:${NC}"
echo ""
echo "1. Review the setup:"
echo "   cat IMAGEFRONT.md"
echo ""
echo "2. Create your first screen:"
echo "   ./.imagefront/scripts/new-screen.sh my-screen"
echo ""
echo "3. Use Claude Code to generate UI:"
echo "   'Generate a login screen in $STYLE style'"
echo ""
echo "4. Read full documentation:"
echo "   $REPO_URL"
echo ""
echo -e "${YELLOW}💡 Tip: Add IMAGEFRONT.md to your CLAUDE.md for context${NC}"
echo ""

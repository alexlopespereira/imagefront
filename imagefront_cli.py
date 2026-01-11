#!/usr/bin/env python3
"""
Imagefront CLI - UI-First Development Framework
Similar to GitHub Spec-Kit's 'specify' command

Usage:
    uvx --from git+https://github.com/seu-usuario/imagefront.git imagefront init <project>
    uvx --from git+https://github.com/seu-usuario/imagefront.git imagefront init . --framework react
"""

import argparse
import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional
import shutil

VERSION = "1.0.0"

BANNER = """
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║   IMAGEFRONT - UI-First Development Framework        ║
║   Version {version}                                   ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
""".format(version=VERSION)


class Colors:
    """ANSI color codes"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'  # No Color


def print_color(message: str, color: str = Colors.NC):
    """Print colored message"""
    print(f"{color}{message}{Colors.NC}")


def create_directory_structure(base_path: Path):
    """Create Imagefront directory structure"""
    directories = [
        ".imagefront/schemas",
        ".imagefront/templates",
        ".imagefront/prompts",
        ".imagefront/scripts",
        "ui_specs",
        "ux_specs",
        "ui_approvals",
        "ux_approvals",
        "backend_specs/contracts",
        "backend_specs/scaffolds",
    ]

    print_color("📁 Creating directory structure...", Colors.BLUE)

    for dir_path in directories:
        full_path = base_path / dir_path
        full_path.mkdir(parents=True, exist_ok=True)

    print_color("✓ Directories created", Colors.GREEN)


def create_config_file(base_path: Path, framework: str, style: str, backend: str):
    """Create .imagefront/config.json"""
    config = {
        "project": {
            "name": base_path.name if base_path.name else "my-app",
            "version": "1.0.0",
            "description": "Project initialized with Imagefront framework"
        },
        "aiProviders": {
            "imageGeneration": {
                "primary": "dall-e-3",
                "dalle": {
                    "apiKey": "${OPENAI_API_KEY}",
                    "model": "dall-e-3",
                    "quality": "hd",
                    "size": "1792x1024"
                }
            },
            "annotation": {
                "provider": "gpt-4-vision",
                "apiKey": "${OPENAI_API_KEY}"
            }
        },
        "uiStyle": {
            "reference": style,
            "colorScheme": "light",
            "dimensions": {
                "width": 1920,
                "height": 1080
            }
        },
        "frontend": {
            "framework": framework,
            "typescript": True
        },
        "backend": {
            "framework": backend
        },
        "gates": {
            "uiFreeze": {
                "enabled": True,
                "strictMode": True,
                "requiredArtifacts": [
                    "ui-image",
                    "annotations",
                    "component-manifest",
                    "approval"
                ]
            }
        },
        "directories": {
            "uiSpecs": "ui_specs",
            "uxSpecs": "ux_specs",
            "uiApprovals": "ui_approvals",
            "uxApprovals": "ux_approvals",
            "backendSpecs": "backend_specs"
        }
    }

    config_path = base_path / ".imagefront" / "config.json"
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)

    print_color("✓ Configuration created", Colors.GREEN)


def create_readme(base_path: Path, framework: str, style: str):
    """Create IMAGEFRONT.md in project root"""
    readme_content = f"""# Imagefront Framework Setup

This project uses the Imagefront framework for UI-first development.

## Installed Configuration

- **Frontend Framework:** {framework}
- **UI Style:** {style}
- **Installed:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Quick Start Guide

### 1. Generate Your First UI Screen

Ask Claude Code or your AI assistant:

```
"Generate a login screen in {style} style"
```

Claude will:
- Use AI image generation (DALL-E) to create the UI mockup
- Save it to `ui_specs/login-screen/versions/YYYY-MM-DD-v1.png`
- Create metadata file

### 2. Annotate UI Elements

```
"Annotate all elements in the login screen"
```

Claude will:
- Use GPT-4 Vision to identify all UI elements
- Create structured annotations (JSON)
- Generate human-readable map (Markdown)

### 3. Create Component Manifest

```
"Create component manifest for login-screen using {framework}"
```

Claude will:
- Derive components from annotations
- Define props, state, events, API calls
- Validate against schema

### 4. Approve for Implementation

```
"Approve login-screen for requirement REQ-001"
```

Creates approval record with evidence (annotation IDs).

### 5. Validate UI Freeze Gate

```
"Can we start implementing the backend?"
```

Claude validates:
- All screens have images + annotations + manifests
- All approvals are frozen
- All API calls are documented in contracts

### 6. Draft Backend Contracts

```
"Draft backend contracts from all approved screens"
```

Generates `backend_specs/contracts.draft.md` with all API endpoints.

## Directory Structure

```
.
├── .imagefront/           # Framework configuration
│   ├── config.json       # Your configuration
│   ├── schemas/          # JSON schemas
│   ├── templates/        # Templates
│   └── prompts/          # AI prompts
├── ui_specs/             # UI specifications
│   └── <screen-id>/
│       ├── versions/     # Versioned images + annotations
│       └── components/   # Component manifests
├── ux_specs/             # UX flow specs
├── ui_approvals/         # Approval records
├── backend_specs/        # Backend contracts
└── IMAGEFRONT.md         # This file
```

## Workflow Phases

1. **UI Generation** - Create mockups with AI
2. **Annotation** - Identify and document elements
3. **Manifest** - Define component specifications
4. **Approval** - Freeze UI for implementation
5. **Gate Validation** - Ensure completeness
6. **Backend Contracts** - Define API contracts
7. **Implementation** - Build the actual code

## Commands via Claude Code

All interactions happen through natural language with Claude Code:

- `"Create a dashboard screen"`
- `"Annotate the dashboard"`
- `"Create manifest for dashboard"`
- `"Approve dashboard for REQ-042"`
- `"Validate gate"`
- `"Draft contracts"`

## Documentation

- [Framework Specification](https://github.com/seu-usuario/imagefront/blob/main/FRAMEWORK_SPEC.md)
- [AI Agent Integration](https://github.com/seu-usuario/imagefront/blob/main/AGENTS.md)
- [UI-Only Iterations](https://github.com/seu-usuario/imagefront/blob/main/UI_ONLY_ITERATIONS.md)

## Helper Scripts

```bash
# Create new screen structure
./.imagefront/scripts/new-screen.sh my-new-screen

# Validate UI freeze gate
./.imagefront/scripts/validate-gate.sh
```

## Tips

1. **Add to CLAUDE.md**: Copy this file or add reference to CLAUDE.md for better context
2. **Commit everything**: All artifacts (images, annotations, approvals) should be in git
3. **Use UI freeze**: Don't start backend until gate passes
4. **Iterate freely**: UI changes are cheap, so iterate until perfect

## Support

For issues or questions, see: https://github.com/seu-usuario/imagefront
"""

    readme_path = base_path / "IMAGEFRONT.md"
    with open(readme_path, 'w') as f:
        f.write(readme_content)

    print_color("✓ IMAGEFRONT.md created", Colors.GREEN)


def create_helper_scripts(base_path: Path):
    """Create helper shell scripts"""

    # new-screen.sh
    new_screen_script = """#!/bin/bash
# Create a new screen structure

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
  "versions": [],
  "status": "draft"
}
METADATA

echo "✅ Screen structure created!"
echo ""
echo "Next: Ask Claude to 'Generate UI for $SCREEN_ID'"
"""

    script_path = base_path / ".imagefront" / "scripts" / "new-screen.sh"
    with open(script_path, 'w') as f:
        f.write(new_screen_script)
    os.chmod(script_path, 0o755)

    print_color("✓ Helper scripts created", Colors.GREEN)


def init_command(args):
    """Initialize Imagefront in a project"""

    print_color(BANNER, Colors.BLUE)

    # Determine target directory
    if args.project_name == '.' or args.here:
        base_path = Path.cwd()
    else:
        base_path = Path.cwd() / args.project_name
        base_path.mkdir(exist_ok=True)

    # Check if directory is not empty
    if list(base_path.iterdir()) and not args.force:
        print_color(f"⚠️  Directory {base_path} is not empty.", Colors.YELLOW)
        response = input("Continue anyway? (y/N): ")
        if response.lower() != 'y':
            print("Installation cancelled.")
            sys.exit(0)

    print_color(f"\n📍 Installing Imagefront in: {base_path}", Colors.CYAN)
    print_color(f"   Framework: {args.framework}", Colors.CYAN)
    print_color(f"   Style: {args.style}", Colors.CYAN)
    print_color(f"   Backend: {args.backend}\n", Colors.CYAN)

    # Create structure
    create_directory_structure(base_path)
    create_config_file(base_path, args.framework, args.style, args.backend)
    create_readme(base_path, args.framework, args.style)
    create_helper_scripts(base_path)

    # TODO: Download actual schemas, templates, and prompts from repo
    # For now, create placeholders
    print_color("📥 Schemas, templates, and prompts would be downloaded here", Colors.BLUE)

    # Success message
    print_color("\n" + "="*60, Colors.GREEN)
    print_color("✅  Imagefront framework installed successfully!", Colors.GREEN)
    print_color("="*60 + "\n", Colors.GREEN)

    print_color("📖 Next steps:\n", Colors.BLUE)
    print(f"1. cd {base_path if base_path != Path.cwd() else '.'}")
    print("2. cat IMAGEFRONT.md")
    print("3. Ask Claude Code: 'Generate a login screen'")
    print("")
    print_color("💡 Tip: Add IMAGEFRONT.md reference to CLAUDE.md for better context\n", Colors.YELLOW)


def main():
    """Main CLI entry point"""
    parser = argparse.ArgumentParser(
        description="Imagefront - UI-First Development Framework",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument('--version', action='version', version=f'imagefront {VERSION}')

    subparsers = parser.add_subparsers(dest='command', help='Commands')

    # Init command
    init_parser = subparsers.add_parser('init', help='Initialize Imagefront in a project')
    init_parser.add_argument('project_name', nargs='?', default='.',
                            help='Project name or . for current directory')
    init_parser.add_argument('--here', action='store_true',
                            help='Initialize in current directory')
    init_parser.add_argument('--framework', default='react',
                            choices=['react', 'vue', 'angular', 'svelte', 'solid', 'agnostic'],
                            help='Frontend framework (default: react)')
    init_parser.add_argument('--style', default='shadcn/ui',
                            help='UI style reference (default: shadcn/ui)')
    init_parser.add_argument('--backend', default='agnostic',
                            choices=['dotnet', 'node', 'python', 'java', 'agnostic'],
                            help='Backend framework (default: agnostic)')
    init_parser.add_argument('--force', action='store_true',
                            help='Skip confirmation prompts')

    args = parser.parse_args()

    if args.command == 'init':
        init_command(args)
    else:
        parser.print_help()


if __name__ == '__main__':
    main()

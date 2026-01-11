# Imagefront Installation Guide

Imagefront can be installed in your project using simple commands.

---

## Quick Install (Recommended)

### Option 1: Using `uvx` 

```bash
# Install in a new project directory
uvx --from git+https://github.com/seu-usuario/imagefront.git imagefront init my-app

# Install in current directory
uvx --from git+https://github.com/seu-usuario/imagefront.git imagefront init .

# Or use --here flag
uvx --from git+https://github.com/seu-usuario/imagefront.git imagefront init --here
```

### Option 2: Using Bash Script

```bash
# Download and run install script
curl -fsSL https://raw.githubusercontent.com/seu-usuario/imagefront/main/install.sh | bash

# Or with options
curl -fsSL https://raw.githubusercontent.com/seu-usuario/imagefront/main/install.sh | bash -s -- --framework react --style shadcn/ui
```

---

## Installation Options

### Framework Selection

```bash
# React (default)
imagefront init . --framework react

# Vue.js
imagefront init . --framework vue

# Angular
imagefront init . --framework angular

# Svelte
imagefront init . --framework svelte

# Framework-agnostic
imagefront init . --framework agnostic
```

### UI Style Reference

```bash
# shadcn/ui (default)
imagefront init . --style shadcn/ui

# Material Design
imagefront init . --style material

# Ant Design
imagefront init . --style ant-design

# Chakra UI
imagefront init . --style chakra

# Custom
imagefront init . --style custom
```

### Backend Framework

```bash
# .NET
imagefront init . --backend dotnet

# Node.js
imagefront init . --backend node

# Python
imagefront init . --backend python

# Framework-agnostic (default)
imagefront init . --backend agnostic
```

---

## What Gets Installed

After running `imagefront init`, your project will have:

```
your-project/
├── .imagefront/              # Framework configuration
│   ├── config.json          # Your configuration
│   ├── schemas/             # JSON schemas for validation
│   │   ├── annotation.schema.json
│   │   ├── component-manifest.schema.json
│   │   ├── approval.schema.json
│   │   ├── contract.schema.json
│   │   ├── trace.schema.json
│   │   └── assertion.schema.json
│   ├── templates/           # Templates for artifacts
│   │   ├── config.template.json
│   │   ├── screen-metadata.json
│   │   ├── approval-template.json
│   │   ├── contracts-template.md
│   │   └── scenario-metadata.json
│   ├── prompts/             # AI prompt templates
│   │   ├── generate-ui.md
│   │   ├── annotate-ui.md
│   │   ├── create-component-manifest.md
│   │   ├── draft-contracts.md
│   │   ├── scaffold-backend.md
│   │   └── generate-ux-sequence.md
│   └── scripts/             # Helper scripts
│       ├── new-screen.sh
│       └── validate-gate.sh
├── ui_specs/                # UI specifications (created empty)
├── ux_specs/                # UX flows (created empty)
├── ui_approvals/            # Approval records (created empty)
├── ux_approvals/            # UX approvals (created empty)
├── backend_specs/           # Backend contracts (created empty)
│   ├── contracts/
│   └── scaffolds/
├── IMAGEFRONT.md            # Quick reference guide
└── .gitignore               # Updated with Imagefront entries
```

---

## Post-Installation

### 1. Review Configuration

```bash
cat .imagefront/config.json
```

Customize as needed:
- AI provider API keys (use environment variables)
- UI dimensions
- Gate rules
- Directory paths

### 2. Add to Claude Code Context

Add reference to `IMAGEFRONT.md` in your `CLAUDE.md`:

```markdown
# CLAUDE.md

## Project Setup

This project uses Imagefront framework for UI-first development.

See [IMAGEFRONT.md](IMAGEFRONT.md) for workflow and commands.
```

### 3. Create Your First Screen

```bash
# Using helper script
./.imagefront/scripts/new-screen.sh login-screen

# Or ask Claude directly
"Create a login screen"
```

---

## Usage Workflow

### Phase 1: Generate UI

Ask Claude Code:
```
"Generate a login screen in shadcn/ui style"
```

Claude will:
- Use the prompt template from `.imagefront/prompts/generate-ui.md`
- Call DALL-E API to generate the image
- Save to `ui_specs/login-screen/versions/YYYY-MM-DD-v1.png`
- Create metadata

### Phase 2: Annotate Elements

```
"Annotate all elements in login-screen"
```

Claude will:
- Use GPT-4 Vision to analyze the image
- Follow `.imagefront/prompts/annotate-ui.md`
- Create structured JSON validated against `schemas/annotation.schema.json`
- Generate human-readable `.map.md` file

### Phase 3: Create Component Manifest

```
"Create component manifest for login-screen using React"
```

Claude will:
- Read annotations
- Follow `.imagefront/prompts/create-component-manifest.md`
- Define components, props, state, events
- Validate against `schemas/component-manifest.schema.json`

### Phase 4: Approve

```
"Approve login-screen for requirement REQ-001"
```

Creates approval record in `ui_approvals/REQ-001/`.

### Phase 5: Validate Gate

```
"Can we start the backend?"
```

Claude validates:
- All screens have required artifacts
- All approvals are frozen
- Contracts are drafted

### Phase 6: Draft Contracts

```
"Draft backend contracts from approved screens"
```

Generates `backend_specs/contracts.draft.md`.

---

## Requirements

### For Python Installation (uvx)
- Python 3.8+
- `uv` package manager

### For Bash Installation
- Bash 4.0+
- `curl` or `wget`

### For AI Features
- OpenAI API key (for DALL-E and GPT-4V)
- Or Anthropic API key (for Claude Vision)
- Claude Code or similar AI coding assistant

---

## Environment Variables

Set these in your environment or `.env`:

```bash
# OpenAI (for DALL-E + GPT-4V)
export OPENAI_API_KEY="sk-..."

# Anthropic (for Claude Vision)
export ANTHROPIC_API_KEY="sk-ant-..."

# Midjourney (optional)
export MIDJOURNEY_API_KEY="..."
```

---

## Updating Imagefront

### Update schemas, templates, prompts:

```bash
# Re-run init with --force
uvx --from git+https://github.com/seu-usuario/imagefront.git imagefront init . --force

# Or manually download files
curl -O https://raw.githubusercontent.com/seu-usuario/imagefront/main/.imagefront/schemas/annotation.schema.json
```

---

## Uninstalling

To remove Imagefront from your project:

```bash
# Remove framework files
rm -rf .imagefront

# Remove generated directories (careful - this deletes your work!)
# rm -rf ui_specs ux_specs ui_approvals ux_approvals backend_specs

# Remove documentation
rm IMAGEFRONT.md
```

**Note:** Keep `ui_specs/`, `ux_specs/`, etc. as they contain your actual work!

---

## Troubleshooting

### Issue: `uvx` not found

**Solution:** Install `uv`:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Issue: Permission denied on scripts

**Solution:** Make scripts executable:
```bash
chmod +x .imagefront/scripts/*.sh
```

### Issue: API keys not working

**Solution:** Check environment variables:
```bash
echo $OPENAI_API_KEY
```

---

## Support

- **Documentation:** [GitHub README](https://github.com/seu-usuario/imagefront)
- **Issues:** [GitHub Issues](https://github.com/seu-usuario/imagefront/issues)
- **Discussions:** [GitHub Discussions](https://github.com/seu-usuario/imagefront/discussions)

---


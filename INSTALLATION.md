# Imagefront Framework - Installation Guide

Complete guide for installing and configuring the Imagefront framework.

---

## Prerequisites

- **Bash** (Linux/macOS) or **PowerShell** (Windows)
- **Python 3.8+** (for image generation scripts)
- **Git** (optional, for version control)
- **Google API Key** (for Imagen/Nano Banana image generation - recommended)

---

## Installation

### Linux/macOS (Bash)

```bash
# Install in current directory
curl -fsSL https://raw.githubusercontent.com/alexlopespereira/imagefront/main/install.sh | bash

# Or with options
curl -fsSL https://raw.githubusercontent.com/alexlopespereira/imagefront/main/install.sh | bash -s -- \
  --framework react \
  --style "shadcn/ui" \
  --backend dotnet
```

### Windows (PowerShell)

```powershell
# Install in current directory
iwr -useb https://raw.githubusercontent.com/alexlopespereira/imagefront/main/install.ps1 | iex

# Or with options
.\install.ps1 -Framework react -Style "shadcn/ui" -Backend dotnet
```

### Installation Options

| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `--framework` / `-Framework` | react, vue, angular, svelte, solid, agnostic | react | Frontend framework |
| `--style` / `-Style` | shadcn/ui, material, fluent, ant-design, chakra | shadcn/ui | UI style reference |
| `--backend` / `-Backend` | dotnet, node, python, java, agnostic | agnostic | Backend framework |
| `--dir` / `-TargetDir` | path | current directory | Installation directory |
| `--force` / `-Force` | flag | false | Skip confirmation prompts |

---

## Post-Installation Setup

### 1. Install Python Dependencies

```bash
pip install -r requirements.txt
```

This installs:
- `google-generativeai` - For Google Imagen 3 (Nano Banana) image generation - **PRIMARY**
- `replicate` - For Flux and Stable Diffusion models (alternative)
- `python-dotenv` - For environment variable management
- `requests`, `Pillow` - For image processing

### 2. Configure API Keys

```bash
# Copy template
cp .env.template .env

# Edit .env file
nano .env  # or your preferred editor
```

Add your API key:
```env
GOOGLE_API_KEY=your-actual-google-api-key-here
```

**Getting a Google API Key (Recommended):**
1. Go to https://aistudio.google.com/apikey
2. Create a new API key
3. Copy and paste into `.env` file

**Alternative - Replicate API Token:**
1. Go to https://replicate.com/account/api-tokens
2. Create a new API token
3. Add to `.env` file: `REPLICATE_API_TOKEN=your-token`
4. Use `--model flux` or `--model stable-diffusion` when running the script

**Important:** Never commit `.env` to git (it's already in `.gitignore`)

### 3. Verify Installation

```bash
# Check directory structure
ls -la .imagefront/

# Test Python script
python .imagefront/scripts/generate-ui-image.py --help
```

---

## Quick Start

### Generate Your First UI Screen

```bash
python .imagefront/scripts/generate-ui-image.py \
  login-screen \
  "A modern login screen with email and password fields, a login button, and a forgot password link"
```

This will:
- Generate a UI image using Google Imagen 3 (Nano Banana)
- Save to `ui_specs/login-screen/versions/YYYY-MM-DD-v1.png`
- Create metadata file `ui_specs/login-screen/metadata.json`

### Using Claude Code

Ask Claude Code to run the script:

```
You: "Run generate-ui-image.py to create a dashboard screen with charts and tables"

Claude: [Executes the Python script]
        ✅ UI mockup generated!
        → ui_specs/dashboard/versions/2026-01-11-v1.png
```

---

## Directory Structure After Installation

```
your-project/
├── .imagefront/              # Framework configuration
│   ├── schemas/             # JSON validation schemas
│   ├── scripts/             # Python helper scripts
│   │   └── generate-ui-image.py
│   ├── AGENTS.md            # AI agent integration guide
│   ├── UI_ONLY_ITERATIONS.md
│   └── FRAMEWORK_SPEC.md
├── ui_specs/                # UI screen specifications
├── ux_specs/                # UX flow specifications
├── ui_approvals/            # Approval records
├── ux_approvals/            # UX approval records
├── backend_specs/           # Backend contracts
├── requirements.txt         # Python dependencies
├── .env.template           # API key template
├── .env                    # Your API keys (git-ignored)
└── IMAGEFRONT.md           # Quick reference guide
```

---

## Alternative Image Generation Models

### Using Replicate (Flux/Stable Diffusion)

```bash
# Install Replicate
pip install replicate

# Add to .env
REPLICATE_API_TOKEN=your-replicate-token

# Generate with Flux
python .imagefront/scripts/generate-ui-image.py \
  dashboard \
  "Admin dashboard with charts" \
  --model flux
```


---

## Troubleshooting

### Python not found

**Solution:** Install Python 3.8+
```bash
# macOS
brew install python3

# Ubuntu/Debian
sudo apt install python3 python3-pip

# Windows
# Download from https://python.org
```

### OpenAI API Error: Invalid API Key

**Solution:** Check your `.env` file
```bash
cat .env  # Should show OPENAI_API_KEY=sk-...
```

### Permission denied: generate-ui-image.py

**Solution:** Make script executable
```bash
chmod +x .imagefront/scripts/generate-ui-image.py
```

### ModuleNotFoundError: No module named 'openai'

**Solution:** Install dependencies
```bash
pip install -r requirements.txt
```

---

## Uninstallation

To remove Imagefront from a project:

```bash
# Remove all Imagefront files
rm -rf .imagefront/ ui_specs/ ux_specs/ ui_approvals/ ux_approvals/ backend_specs/
rm IMAGEFRONT.md requirements.txt .env.template .env
```

Or keep generated UIs and specs:
```bash
# Remove only framework files
rm -rf .imagefront/ IMAGEFRONT.md requirements.txt .env.template .env
```

---

## Next Steps

1. Read **[IMAGEFRONT.md](IMAGEFRONT.md)** - Quick reference in your project
2. Read **[.imagefront/AGENTS.md](.imagefront/AGENTS.md)** - How Claude Code uses this framework
3. Read **[.imagefront/UI_ONLY_ITERATIONS.md](.imagefront/UI_ONLY_ITERATIONS.md)** - UI-first workflow
4. Generate your first screen with `generate-ui-image.py`
5. Ask Claude Code to annotate and create manifests

---

## Support

- **Issues:** https://github.com/alexlopespereira/imagefront/issues
- **Documentation:** https://github.com/alexlopespereira/imagefront
- **OpenAI Help:** https://help.openai.com

# Test Installation Guide

## Prerequisites

1. Commit and push the changes to GitHub:
```bash
git add install.sh README.md
git commit -m "fix: convert to bash-only installation, remove Python packaging"
git push origin main
```

## Test in voiceapp Project

### Option 1: Direct Install (Recommended for Testing)

```bash
cd C:\Projects\prototype_realtime_voice\voiceapp

# Install Imagefront framework
curl -fsSL https://raw.githubusercontent.com/alexlopespereira/imagefront/main/install.sh | bash
```

### Option 2: With Custom Options

```bash
cd C:\Projects\prototype_realtime_voice\voiceapp

# Install with custom settings
curl -fsSL https://raw.githubusercontent.com/alexlopespereira/imagefront/main/install.sh | bash -s -- \
  --framework react \
  --style "shadcn/ui" \
  --backend python
```

### Option 3: Download and Inspect First

```bash
cd C:\Projects\prototype_realtime_voice\voiceapp

# Download the script
curl -fsSL https://raw.githubusercontent.com/alexlopespereira/imagefront/main/install.sh -o install.sh

# Inspect it (optional)
cat install.sh

# Run it
chmod +x install.sh
./install.sh --framework react --style "shadcn/ui" --backend python
```

## What Should Happen

After installation, you should see:

1. **Directory Structure Created:**
   ```
   voiceapp/
   ├── .imagefront/
   │   ├── config.json
   │   ├── schemas/
   │   ├── templates/
   │   ├── prompts/
   │   └── scripts/
   ├── ui_specs/
   ├── ux_specs/
   ├── ui_approvals/
   ├── ux_approvals/
   ├── backend_specs/
   └── IMAGEFRONT.md
   ```

2. **Success Message:**
   ```
   ╔═══════════════════════════════════════════════════════╗
   ║                                                       ║
   ║   ✅  Imagefront framework installed successfully!    ║
   ║                                                       ║
   ╚═══════════════════════════════════════════════════════╝
   ```

3. **Next Steps Displayed:**
   - Review IMAGEFRONT.md
   - Create first screen
   - Use Claude Code

## Verify Installation

```bash
# Check directory structure
ls -la .imagefront/

# Check config
cat .imagefront/config.json

# Read the guide
cat IMAGEFRONT.md

# Try helper script
./.imagefront/scripts/new-screen.sh test-screen
```

## Troubleshooting

### If curl fails:
- Check internet connection
- Verify the repository is public
- Make sure you pushed to main branch

### If you get "Git operation failed":
- This error is from the OLD uvx method
- Use the new curl method instead

### If schemas are placeholder:
- This is normal if you haven't pushed yet
- They will download automatically after you push

## Clean Up Test

If you want to remove the installation and test again:

```bash
rm -rf .imagefront/ ui_specs/ ux_specs/ ui_approvals/ ux_approvals/ backend_specs/ IMAGEFRONT.md
```

## Expected vs Old Error

**OLD ERROR (uvx method):**
```
× Failed to resolve `--with` requirement
╰─▶ Git operation failed
```

**NEW SUCCESS (bash method):**
```
✅  Imagefront framework installed successfully!
```

# Imagefront Quick Reference

## Image Generation Models

### Primary: Google Imagen 3 (Nano Banana)
- **Default model** - no need to specify
- Requires: `GOOGLE_API_KEY` in `.env`
- Get key: https://aistudio.google.com/apikey

```bash
python .imagefront/scripts/generate-ui-image.py <screen-id> "<description>"
```

### Alternatives

**Flux (Replicate - Fast):**
```bash
python .imagefront/scripts/generate-ui-image.py <screen-id> "<description>" --model flux
```
Requires: `REPLICATE_API_TOKEN` in `.env`

**Stable Diffusion (Replicate):**
```bash
python .imagefront/scripts/generate-ui-image.py <screen-id> "<description>" --model stable-diffusion
```
Requires: `REPLICATE_API_TOKEN` in `.env`

## Common Commands

```bash
# Generate UI
python .imagefront/scripts/generate-ui-image.py \
  login-screen \
  "Modern login with email and password" \
  --style shadcn/ui

# With alternative model
python .imagefront/scripts/generate-ui-image.py \
  dashboard \
  "Admin dashboard with charts" \
  --model flux

# Different style
python .imagefront/scripts/generate-ui-image.py \
  profile \
  "User profile page" \
  --style material
```

## Supported Styles
- `shadcn/ui` (default)
- `material`
- `fluent`
- `ant-design`
- `chakra`

## Script Parameters
- `screen-id` - Screen identifier (kebab-case)
- `prompt` - Description of UI to generate
- `--model` - Model: `imagen`, `flux`, `stable-diffusion`
- `--style` - UI style reference
- `--size` - Image dimensions (default: 1792x1024)
- `--output-dir` - Output directory (default: ui_specs)

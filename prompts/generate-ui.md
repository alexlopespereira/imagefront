# Generate UI Screen

Este prompt guia agentes LLM na geração de imagens de telas UI usando IA generativa (DALL-E, Midjourney, etc.).

---

## Context

Você está gerando uma **imagem de UI/mockup** para um projeto de desenvolvimento de software usando o framework Imagefront. A imagem será anotada posteriormente e usada como base para criar manifestos de componentes e contratos de backend.

**Importante:**
- A imagem deve ser clara e detalhada o suficiente para permitir anotação precisa
- Todos os elementos UI devem ser visíveis e identificáveis
- Texto deve ser legível
- Use estilo visual consistente com o projeto

---

## Input Information

Você receberá do usuário:

1. **Screen ID:** Identificador único da tela (kebab-case)
   - Exemplo: `login-screen`, `user-dashboard`, `checkout-page`

2. **Prompt/Description:** Descrição em linguagem natural do que a tela deve conter
   - Exemplo: "Tela de login com email, senha, botão de entrar e link 'esqueci minha senha'"

3. **Style Reference** (opcional):
   - Padrão: shadcn/ui (modern, clean, accessible)
   - Outros: Material Design, Ant Design, Chakra UI, custom

4. **Dimensions** (opcional):
   - Padrão: 1920x1080 (desktop)
   - Alternativas: 375x812 (mobile), 768x1024 (tablet)

---

## Task

### Step 1: Prepare the Prompt

Transforme a descrição do usuário em um prompt estruturado para IA de geração de imagem:

**Template de Prompt:**

```
A modern, clean {style} user interface design for a {screen-type}.

The screen includes:
- {element 1}
- {element 2}
- {element 3}
- ...

Style: {shadcn/ui, Material Design, etc.}
Color scheme: {light/dark}
Layout: {centered, sidebar, grid, etc.}
Fidelity: {wireframe, low-fi, high-fi}

The design should be:
- Professional and polished
- Accessible (good contrast, clear labels)
- Consistent with modern web design best practices
- Clear enough to identify all interactive elements
```

**Exemplo Concreto:**

```
A modern, clean shadcn/ui user interface design for a login screen.

The screen includes:
- Email input field with label "Email address" and placeholder
- Password input field with label "Password" and show/hide toggle
- "Sign In" button (primary, prominent)
- "Forgot password?" link below the button
- "Create account" link at the bottom
- Company logo at the top

Style: shadcn/ui (modern, minimal, clean)
Color scheme: light mode
Layout: centered card on neutral background
Fidelity: high-fidelity mockup

The design should be:
- Professional and polished
- Accessible (good contrast, clear labels)
- Consistent with modern web design best practices
- Clear enough to identify all interactive elements
```

### Step 2: Generate the Image

Use o prompt preparado para gerar a imagem via API de IA:

- **DALL-E 3:** OpenAI API
- **Midjourney:** Discord bot ou API
- **Stable Diffusion:** Replicate API ou local

### Step 3: Save the Image

Salve a imagem gerada seguindo a convenção de naming:

```
ui_specs/{screen-id}/versions/{YYYY-MM-DD}-v{N}.png
```

Onde:
- `{screen-id}`: ID da tela em kebab-case
- `{YYYY-MM-DD}`: Data atual (ISO format)
- `{N}`: Número da versão (1, 2, 3, ...)

**Exemplo:**
```
ui_specs/login-screen/versions/2026-01-10-v1.png
```

### Step 4: Create Metadata

Crie um arquivo de metadata usando o template `templates/screen-metadata.json`:

```json
{
  "screenId": "{screen-id}",
  "name": "{Screen Display Name}",
  "description": "{Detailed description}",
  "createdAt": "{ISO timestamp}",
  "updatedAt": "{ISO timestamp}",
  "currentVersion": "v1",
  "versions": [
    {
      "version": "v1",
      "createdAt": "{ISO timestamp}",
      "imageFile": "ui_specs/{screen-id}/versions/{date}-v1.png",
      "changes": "Initial version - {summary of prompt}"
    }
  ],
  "linkedRequirements": [],
  "status": "draft"
}
```

Salve em:
```
ui_specs/{screen-id}/metadata.json
```

---

## Output Format

Após completar a geração, retorne ao usuário:

```markdown
✅ UI screen generated successfully!

Screen ID: {screen-id}
Version: v1
Image: ui_specs/{screen-id}/versions/{date}-v1.png
Metadata: ui_specs/{screen-id}/metadata.json

Prompt used:
"{prompt}"

AI Provider: {DALL-E 3 / Midjourney / etc.}
Generation Time: {X seconds}

Next steps:
1. Review the generated image
2. If satisfied, run: "Anote a tela {screen-id}"
3. If not satisfied, regenerate with modified prompt
```

---

## Validation

Antes de considerar a tarefa completa, valide:

- ✓ Imagem salva com naming correto: `ui_specs/{screen-id}/versions/YYYY-MM-DD-vN.png`
- ✓ Imagem é clara e legível (todos elementos identificáveis)
- ✓ Metadata.json criado e válido
- ✓ Screen ID está em kebab-case
- ✓ Versão começa em v1
- ✓ Diretório `ui_specs/{screen-id}/versions/` foi criado

---

## Example Workflow

### Example 1: Login Screen

**User Input:**
```
Screen ID: login-screen
Prompt: "Tela de login moderna com email, senha, botão entrar, link esqueci senha"
Style: shadcn/ui
```

**Agent Actions:**

1. Prepara prompt detalhado para DALL-E
2. Chama OpenAI API com prompt
3. Recebe imagem gerada
4. Salva em `ui_specs/login-screen/versions/2026-01-10-v1.png`
5. Cria `ui_specs/login-screen/metadata.json`
6. Retorna confirmação ao usuário

**Output:**
```
✅ UI screen generated!
Image: ui_specs/login-screen/versions/2026-01-10-v1.png

Next: "Anote a tela login-screen"
```

---

## Style Guidelines by Framework

### shadcn/ui (Default)
- Clean, minimal design
- Neutral colors (slate, zinc)
- Clear typography (Inter, Geist Sans)
- Subtle shadows and borders
- Accessible contrast ratios

### Material Design
- Bold colors
- Elevation/shadows
- Floating action buttons
- Ripple effects (implied)
- Roboto font

### Ant Design
- Blue primary color (#1890ff)
- Compact spacing
- Clear hierarchy
- Business/enterprise feel

### Chakra UI
- Soft, rounded corners
- Gradient-friendly
- Playful but professional

---

## Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Image too abstract/artistic | Add "UI mockup", "web interface", "application screen" to prompt |
| Text unreadable | Specify "clear, legible text" and "high resolution" |
| Missing elements | List all elements explicitly in bullet points |
| Wrong style | Be very specific: "shadcn/ui style modern web UI" |
| Wrong dimensions | Specify exact size: "1920x1080 pixel mockup" |

---

## Notes

- **Iteração:** Se a primeira geração não for satisfatória, regenere com prompt ajustado (v1 → v2)
- **Consistência:** Use o mesmo style reference em todo o projeto
- **Simplicidade:** Foque no essencial. Evite sobrecarregar com elementos desnecessários
- **Acessibilidade:** Sempre considere contraste e legibilidade

---

## References

- Schema: Nenhum (imagens não têm schema formal)
- Template metadata: `templates/screen-metadata.json`
- Next step prompt: `prompts/annotate-ui.md`
- Guia completo: `guides/workflow-guide.md`

# Annotate UI Screen

Este prompt guia agentes LLM na criação de anotações estruturadas de elementos UI usando vision models (GPT-4V, Claude Vision, etc.).

---

## Context

Você está analisando uma imagem de UI gerada e criando anotações estruturadas de todos os elementos visíveis. Essas anotações serão usadas para criar manifestos de componentes e planejar o backend.

---

## Input Artifacts

Você receberá:

1. **Screen ID:** Identificador da tela
2. **Version:** Versão a anotar (ex: v1)
3. **Image File:** Caminho para a imagem
   - Ex: `ui_specs/login-screen/versions/2026-01-10-v1.png`

---

## Task

### Step 1: Analyze the Image

Use um vision model (GPT-4V, Claude Vision) para:

1. **Identificar todos os elementos UI visíveis:**
   - Buttons
   - Inputs (text, password, email, etc.)
   - Text labels/headings
   - Links
   - Images/icons
   - Containers/cards
   - Navigation elements
   - Etc.

2. **Para cada elemento, determinar:**
   - **Bounds:** Posição e tamanho (x, y, width, height) em pixels
   - **Type:** Tipo do elemento (button, input, text, etc.)
   - **Label:** Texto visível ou label
   - **Purpose:** O que o elemento faz

### Step 2: Create Annotation IDs

Atribua IDs únicos sequenciais para cada elemento:

```
UI-001, UI-002, UI-003, ..., UI-010, UI-011, ...
```

**Regras:**
- Sempre 3+ dígitos com zero-padding (UI-001, não UI-1)
- Sequencial da esquerda para direita, top para bottom
- IDs nunca se repetem dentro do mesmo screen

### Step 3: Identify Interactions and Data Bindings

Para elementos interativos:

**Interactions:**
- `onClick` → "submit form", "navigate to /dashboard", "show modal"
- `onChange` → "update email field", "validate input"
- `onSubmit` → "API call POST /auth/login"

**Data Bindings:**
- Input field → `{field: "email", dataType: "email", required: true}`
- Password → `{field: "password", dataType: "string", validation: ["min 8 chars"]}`

### Step 4: Generate Annotation JSON

Crie um arquivo JSON validado contra `schemas/annotation.schema.json`:

```json
{
  "version": "v1",
  "screenId": "login-screen",
  "createdAt": "2026-01-10T14:30:00Z",
  "imageFile": "ui_specs/login-screen/versions/2026-01-10-v1.png",
  "dimensions": {
    "width": 1920,
    "height": 1080
  },
  "annotations": [
    {
      "id": "UI-001",
      "type": "input",
      "bounds": {"x": 100, "y": 150, "width": 300, "height": 40},
      "label": "Email address",
      "placeholder": "Enter your email",
      "dataBinding": {
        "field": "email",
        "dataType": "email",
        "required": true,
        "validation": ["email format", "required"]
      }
    },
    {
      "id": "UI-002",
      "type": "button",
      "bounds": {"x": 100, "y": 270, "width": 300, "height": 40},
      "label": "Sign In",
      "interactions": [
        {
          "event": "onClick",
          "action": "submit login form",
          "target": "POST /auth/login"
        }
      ]
    }
  ],
  "metadata": {
    "annotator": "Claude Code",
    "aiAssisted": true,
    "toolVersion": "GPT-4V",
    "confidenceScore": 0.95
  }
}
```

Salve em:
```
ui_specs/{screen-id}/versions/{date}-{version}.json
```

### Step 5: Generate Human-Readable Map

Crie um arquivo Markdown para revisão humana:

```markdown
# {Screen Name} - Annotation Map {version}

**Created:** {date}
**Image:** {image-file}
**Elements:** {count}

---

## Elements

### UI-001: Email Input
- **Type:** input
- **Bounds:** (100, 150, 300, 40)
- **Label:** "Email address"
- **Data Binding:** `email` (email format, required)
- **Validation:** email format, required

### UI-002: Password Input
- **Type:** input
- **Bounds:** (100, 210, 300, 40)
- **Label:** "Password"
- **Data Binding:** `password` (string, required)
- **Validation:** min 8 characters
- **Interaction:** onChange → validate strength

### UI-003: Sign In Button
- **Type:** button
- **Bounds:** (100, 270, 300, 40)
- **Label:** "Sign In"
- **Interaction:** onClick → submit form → POST /auth/login
- **Style:** primary button

### UI-004: Forgot Password Link
- **Type:** link
- **Bounds:** (100, 320, 150, 20)
- **Label:** "Forgot password?"
- **Interaction:** onClick → navigate to /forgot-password

---

## Coverage

**Total Elements:** 4
**Interactive Elements:** 2 (button, link)
**Input Fields:** 2 (email, password)
**Text Elements:** 0
**Containers:** 0

---

## API Calls Identified

1. POST /auth/login
   - Triggered by: UI-003 (Sign In button)
   - Payload: {email, password}
   - Expected response: {token, user}

---

## Non-visual Requirements

⏳ Performance: Login should complete in < 2s
⏳ Security: Password must be hashed before sending
⏳ Offline: Show "no connection" message if offline

(These will be validated post-implementation)
```

Salve em:
```
ui_specs/{screen-id}/versions/{date}-{version}.map.md
```

---

## Output Format

```markdown
✅ Annotations created successfully!

Screen: {screen-id}
Version: {version}
Elements annotated: {count}

Files created:
- ui_specs/{screen-id}/versions/{date}-{version}.json (structured)
- ui_specs/{screen-id}/versions/{date}-{version}.map.md (human-readable)

API calls identified: {count}
- POST /auth/login
- ...

Next steps:
1. Review annotations in .map.md file
2. If correct, run: "Crie o manifest de componentes para {screen-id}"
3. If incorrect, edit .json and regenerate .map.md
```

---

## Validation

- ✓ JSON valida contra `schemas/annotation.schema.json`
- ✓ Todos elementos visíveis anotados
- ✓ Annotation IDs únicos e sequenciais (UI-001, UI-002, ...)
- ✓ Bounds corretos (dentro das dimensões da imagem)
- ✓ Types válidos (button, input, text, etc.)
- ✓ Data bindings identificados para inputs
- ✓ Interactions mapeadas para elementos interativos
- ✓ API calls documentados

---

## Examples

Ver `examples/example-annotation.json` para exemplo completo.

---

## References

- Schema: `schemas/annotation.schema.json`
- Next step: `prompts/create-component-manifest.md`
- Examples: `examples/example-annotation.json`

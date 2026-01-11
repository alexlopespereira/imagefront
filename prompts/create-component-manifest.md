# Create Component Manifest

Este prompt guia agentes LLM na criação de manifestos de componentes derivados de annotations.

---

## Context

Você está transformando anotações UI em uma especificação técnica de componentes de frontend. O manifest define quais componentes precisam ser criados, suas props, state, events e API calls.

---

## Input Artifacts

1. **Annotation File:** `ui_specs/{screen-id}/versions/{date}-{version}.json`
2. **Screen ID e Version**
3. **Framework Target:** (react, vue, angular, svelte, agnostic)

---

## Task

### Step 1: Analyze Annotations

Leia o arquivo de annotations e agrupe elementos relacionados em componentes lógicos:

**Example Grouping:**
- Email Input (UI-001) + Password Input (UI-002) + Sign In Button (UI-003) → `LoginForm` component
- Forgot Password Link (UI-004) → parte do `LoginForm` ou standalone
- Logo/Header (UI-005) → `Header` component ou `Logo` component

**Princípios:**
- Componentes devem ser **coesos** (elementos relacionados juntos)
- Componentes devem ser **reutilizáveis** quando possível
- Respeitar hierarquia visual (containers englobam children)

### Step 2: Define Component Structure

Para cada componente identificado:

#### Props
- Dados que o componente recebe de fora
- Ex: `onSubmit: (data) => void`, `initialEmail: string`

#### State
- Dados que o componente gerencia internamente
- Ex: `email: string`, `password: string`, `isLoading: boolean`

#### Events
- Ações que o componente dispara
- Ex: `onSubmit`, `onChange`, `onError`

#### API Calls
- Chamadas de backend que o componente faz
- Extrair de `interactions.target` nas annotations
- Ex: `POST /auth/login`

### Step 3: Create Component Manifest JSON

Estrutura completa validada contra `schemas/component-manifest.schema.json`:

```json
{
  "version": "v1",
  "screenId": "login-screen",
  "framework": "react",
  "createdAt": "2026-01-10T15:00:00Z",
  "derivedFrom": "ui_specs/login-screen/versions/2026-01-10-v1.json",

  "components": [
    {
      "id": "LoginForm",
      "name": "LoginForm",
      "type": "form",
      "description": "Login form with email/password inputs",
      "path": "components/forms/LoginForm.tsx",

      "props": [
        {
          "name": "onSuccess",
          "type": "(user: User) => void",
          "required": false,
          "description": "Callback when login succeeds"
        },
        {
          "name": "redirectUrl",
          "type": "string",
          "required": false,
          "defaultValue": "/dashboard",
          "description": "Where to redirect after login"
        }
      ],

      "state": [
        {
          "name": "email",
          "type": "string",
          "initialValue": "",
          "description": "User's email address"
        },
        {
          "name": "password",
          "type": "string",
          "initialValue": "",
          "description": "User's password"
        },
        {
          "name": "isLoading",
          "type": "boolean",
          "initialValue": false,
          "description": "Loading state during login"
        },
        {
          "name": "error",
          "type": "string | null",
          "initialValue": null,
          "description": "Error message if login fails"
        }
      ],

      "events": [
        {
          "name": "onSubmit",
          "handler": "handleLogin",
          "description": "Called when form is submitted",
          "parameters": [
            {"name": "e", "type": "FormEvent"}
          ]
        },
        {
          "name": "onEmailChange",
          "handler": "handleEmailChange",
          "parameters": [
            {"name": "value", "type": "string"}
          ]
        }
      ],

      "apiCalls": [
        {
          "endpoint": "/auth/login",
          "method": "POST",
          "description": "Authenticate user",
          "requestSchema": {
            "email": "string",
            "password": "string"
          },
          "responseSchema": {
            "token": "string",
            "user": {
              "id": "string",
              "email": "string",
              "name": "string"
            }
          },
          "authentication": false
        }
      ],

      "annotationRefs": ["UI-001", "UI-002", "UI-003"]
    }
  ],

  "routing": {
    "path": "/login",
    "params": [],
    "guards": []
  },

  "dataRequirements": [
    {
      "entity": "User",
      "fields": ["id", "email", "name"],
      "operations": ["read"]
    }
  ]
}
```

Salve em:
```
ui_specs/{screen-id}/components/{version}.json
```

### Step 4: Validate

Valide o manifest gerado:

```bash
# Usando validator (exemplo Node.js)
ajv validate -s schemas/component-manifest.schema.json \
             -d ui_specs/login-screen/components/v1.json
```

**Checklist:**
- ✓ JSON válido
- ✓ Valida contra schema
- ✓ Todos `annotationRefs` existem no arquivo de annotations
- ✓ Todos API calls extraídos das interactions
- ✓ Props, state, events fazem sentido para o framework escolhido

---

## Output Format

```markdown
✅ Component manifest created!

Screen: {screen-id}
Version: {version}
Framework: {framework}

Components defined: {count}
1. {ComponentName} ({type})
   - Props: {count}
   - State: {count}
   - Events: {count}
   - API calls: {count}

File: ui_specs/{screen-id}/components/{version}.json

API calls to implement:
- POST /auth/login
- ...

Next steps:
1. Review manifest for completeness
2. Approve this screen: "Aprove a tela {screen-id} para REQ-XXX"
3. Or iterate: generate new version if changes needed
```

---

## Framework-Specific Considerations

### React
- Props: TypeScript interfaces
- State: useState hooks
- Events: event handlers (onClick, onChange)
- Naming: PascalCase for components

### Vue
- Props: defineProps
- State: ref/reactive
- Events: emit
- Naming: PascalCase or kebab-case

### Angular
- Props: @Input decorators
- State: class properties
- Events: @Output EventEmitters
- Naming: PascalCase + Component suffix

### Agnostic
- Generic descriptions
- No framework-specific syntax
- Focus on data flow and logic

---

## Component Design Principles

1. **Single Responsibility:** Each component has one clear purpose
2. **Composition:** Large components break down into smaller ones
3. **Reusability:** Common patterns extracted to shared components
4. **Controlled vs Uncontrolled:** Prefer controlled components (state managed by parent)
5. **Accessibility:** Include aria labels, roles (from annotations.accessibility)

---

## Common Patterns

### Form Component
```
Props: onSubmit, initialValues
State: field values, validation errors, isLoading
Events: onSubmit, onChange
API Calls: form submission endpoint
```

### List Component
```
Props: items, renderItem, onItemClick
State: selectedItem, isLoading
Events: onSelect, onRefresh
API Calls: GET items list
```

### Modal/Dialog
```
Props: isOpen, onClose, title
State: internal form state
Events: onConfirm, onCancel
```

---

## Validation

- ✓ Manifest valida contra `schemas/component-manifest.schema.json`
- ✓ Todos `annotationRefs` são IDs válidos
- ✓ API calls extraídos de `annotations[].interactions[].target`
- ✓ Props e state são apropriados para o framework
- ✓ Component names seguem convenções (PascalCase)
- ✓ No duplicate component IDs

---

## Examples

Ver `examples/example-manifest.json` para exemplo completo.

---

## References

- Schema: `schemas/component-manifest.schema.json`
- Input: `prompts/annotate-ui.md` (annotations criadas antes)
- Next: `templates/approval-template.json` (aprovar a tela)
- Examples: `examples/example-manifest.json`

# UI_ONLY_ITERATIONS.md — Iterações apenas de Frontend (antes do Backend)

Este documento define como executar iterações de desenvolvimento focadas **somente no frontend** (protótipos gerados por IA), mantendo rastreabilidade e preparando o pacote para iniciar o backend.

---

## 1) O que é "UI-only"

UI-only é uma fase onde:
- Imagens de telas são geradas e refinadas
- Anotações e manifests são produzidos
- Vídeos de fluxo são simulados e aprovados
- Requisitos são esclarecidos e estabilizados

**Sem implementar backend real**.

### Objetivo

O objetivo é convergir em UX + entendimento do problema **antes do custo do backend**.

### Benefícios

- ✅ **Feedback rápido** de stakeholders sobre UX
- ✅ **Requisitos claros** antes de escrever código
- ✅ **Redução de retrabalho** (mudanças em UI são mais baratas que em backend)
- ✅ **Aprovações documentadas** com evidência visual
- ✅ **Contratos de API definidos** antes de implementar
- ✅ **Time frontend e backend podem trabalhar em paralelo** (depois do freeze)

---

## 2) Artefatos obrigatórios por tela

Para cada `screen_id` em escopo, manter:

### Imagem versionada

```
ui_specs/<screen_id>/versions/YYYY-MM-DD-vN.png
ui_specs/<screen_id>/current.png (symlink ou cópia para versão atual)
```

**Exemplo:**
```
ui_specs/login-screen/versions/2026-01-10-v1.png
ui_specs/login-screen/versions/2026-01-11-v2.png
ui_specs/login-screen/current.png → v2.png
```

### Anotações

```
ui_specs/<screen_id>/versions/YYYY-MM-DD-vN.json
ui_specs/<screen_id>/versions/YYYY-MM-DD-vN.map.md
```

**vN.json** - Anotações estruturadas validadas contra `schemas/annotation.schema.json`:
- Elementos UI identificados (buttons, inputs, text, etc.)
- Bounds (x, y, width, height)
- Labels e descriptions
- Data bindings
- Interactions (onClick, onChange, etc.)

**vN.map.md** - Versão humanizada para revisão:
```markdown
# Login Screen - Annotation Map v1

## Elements

### UI-001: Email Input
- Type: input
- Bounds: (100, 150, 300, 40)
- Label: "Email address"
- Data: binds to `email` field
- Validation: email format

### UI-002: Password Input
- Type: input
- Bounds: (100, 210, 300, 40)
- Label: "Password"
- Data: binds to `password` field
- Validation: min 8 characters

### UI-003: Login Button
- Type: button
- Bounds: (100, 270, 300, 40)
- Label: "Sign In"
- Interaction: onClick → POST /auth/login

...
```

### Manifesto de componentes (shadcn/ui ou framework escolhido)

```
ui_specs/<screen_id>/components/vN.json
```

Validado contra `schemas/component-manifest.schema.json`:

- Lista de componentes necessários
- Props de cada componente
- State management
- Events e handlers
- API calls necessários
- Dependências entre componentes

**Exemplo:**
```json
{
  "version": "v1",
  "screenId": "login-screen",
  "framework": "react",
  "components": [
    {
      "id": "LoginForm",
      "name": "LoginForm",
      "type": "form",
      "props": [
        {"name": "onSubmit", "type": "function", "required": true}
      ],
      "state": [
        {"name": "email", "type": "string", "initialValue": ""},
        {"name": "password", "type": "string", "initialValue": ""},
        {"name": "isLoading", "type": "boolean", "initialValue": false}
      ],
      "events": [
        {"name": "onSubmit", "handler": "handleLogin"}
      ],
      "apiCalls": [
        {
          "endpoint": "/auth/login",
          "method": "POST",
          "description": "Authenticate user"
        }
      ]
    }
  ]
}
```

### Aprovações por requisito + evidência

```
ui_approvals/<REQ_ID>/<screen_id>.approval.json
```

Validado contra `schemas/approval.schema.json`:

```json
{
  "reqId": "REQ-001",
  "screenId": "login-screen",
  "version": "v2",
  "status": "frozen",
  "approver": {
    "name": "Product Owner",
    "role": "PO",
    "email": "po@example.com"
  },
  "approvedAt": "2026-01-11T14:30:00Z",
  "frozenAt": "2026-01-11T14:30:00Z",
  "comments": "Approved for implementation. Botão 'Esqueci minha senha' adicionado conforme feedback.",
  "evidence": {
    "annotationIds": ["UI-001", "UI-002", "UI-003", "UI-004"],
    "manifestVersion": "v2",
    "imageVersion": "v2"
  }
}
```

**Estados possíveis:**
- `pending` - Aguardando revisão
- `approved` - Aprovado mas ainda pode ser modificado
- `rejected` - Rejeitado, precisa refazer
- `frozen` - Aprovado e congelado para implementação (não pode mais mudar sem re-approval)

---

## 3) Artefatos obrigatórios por fluxo (cenário AC-*)

Para cenários principais (Acceptance Criteria), manter:

### Vídeo versionado (ou sequência de frames)

```
ux_specs/<scenario_id>/versions/YYYY-MM-DD-vN.mp4
ux_specs/<scenario_id>/current.mp4
```

Pode ser:
- Vídeo gerado por IA (Runway, Pika)
- Animação de transições entre screens
- Storyboard com frames estáticos
- GIF animado

### Golden Trace e Assertions

```
ux_specs/<scenario_id>/traces/vN.trace.yml
ux_specs/<scenario_id>/traces/vN.assert.yml
```

**vN.trace.yml** - Sequência de passos do fluxo:

```yaml
scenarioId: user-registration-flow
version: v1
description: "User registers, verifies email, and completes profile"
createdAt: "2026-01-10T10:00:00Z"

steps:
  - stepId: 1
    screen: signup-screen
    action:
      type: navigate
      target: /signup
      description: "User navigates to signup page"
    expectedState:
      url: /signup
      elementStates:
        emailInput: visible
        passwordInput: visible

  - stepId: 2
    screen: signup-screen
    action:
      type: input
      target: UI-001
      value: "user@example.com"
      description: "User enters email"

  - stepId: 3
    screen: signup-screen
    action:
      type: input
      target: UI-002
      value: "SecurePass123!"
      description: "User enters password"

  - stepId: 4
    screen: signup-screen
    action:
      type: click
      target: UI-005
      description: "User clicks 'Create Account' button"
    apiCalls:
      - endpoint: POST /auth/register
        requestPayload:
          email: "user@example.com"
          password: "SecurePass123!"
        expectedResponseCode: 201

  - stepId: 5
    screen: verify-email-screen
    action:
      type: navigate
      target: /verify-email
      description: "User is redirected to email verification"
    expectedState:
      url: /verify-email
      message: "Check your email for verification code"
```

**vN.assert.yml** - Assertions para validar o fluxo:

```yaml
scenarioId: user-registration-flow
version: v1

assertions:
  - id: ASSERT-001
    stepId: 1
    type: element_visible
    condition: "signup form is visible"
    expected: true
    severity: blocker

  - id: ASSERT-002
    stepId: 4
    type: api_response
    condition: "POST /auth/register returns 201"
    expected: 201
    severity: blocker

  - id: ASSERT-003
    stepId: 5
    type: navigation
    condition: "user redirected to /verify-email"
    expected: "/verify-email"
    severity: blocker

  - id: ASSERT-004
    stepId: 5
    type: text_content
    condition: "verification message shown"
    expected: "Check your email"
    severity: critical
```

### Aprovação de sequências de frames (quando aprovado)

```
ux_approvals/<REQ_ID>/<scenario_id>.approval.json
```

Similar a UI approvals, mas para flows:

```json
{
  "reqId": "AC-001",
  "scenarioId": "user-registration-flow",
  "version": "v1",
  "status": "frozen",
  "approver": {...},
  "approvedAt": "2026-01-10T16:00:00Z",
  "evidence": {
    "traceVersion": "v1",
    "assertionVersion": "v1",
    "videoVersion": "v1"
  }
}
```

---

## 4) Contratos "draft" para o backend (obrigatório)

Mesmo sem backend, cada tela deve gerar um rascunho de contrato:

```
backend_specs/contracts.draft.md
```

### Conteúdo mínimo

```markdown
# Backend API Contracts (Draft)

Version: 1.0
Status: Draft
Created: 2026-01-10
Last Updated: 2026-01-11

---

## Authentication Service

### POST /auth/login

**Description:** Authenticate user with email and password

**Request:**
```json
{
  "email": "string (email format, required)",
  "password": "string (min 8 chars, required)"
}
```

**Response 200 OK:**
```json
{
  "token": "string (JWT)",
  "user": {
    "id": "string (UUID)",
    "email": "string",
    "name": "string"
  }
}
```

**Response 401 Unauthorized:**
```json
{
  "error": "Invalid credentials"
}
```

**Response 400 Bad Request:**
```json
{
  "error": "Validation failed",
  "details": [
    {"field": "email", "message": "Invalid email format"},
    {"field": "password", "message": "Password too short"}
  ]
}
```

**Validations:**
- Email must be valid format
- Password min 8 characters
- Rate limit: 5 attempts per minute

**Derived from:**
- Screen: login-screen (v2)
- Component: LoginForm
- Annotation: UI-003 (Login Button)

---

### POST /auth/register

**Description:** Register new user account

**Request:**
```json
{
  "email": "string (email format, required)",
  "password": "string (min 8 chars, required)",
  "confirmPassword": "string (must match password, required)"
}
```

**Response 201 Created:**
```json
{
  "userId": "string (UUID)",
  "message": "Account created. Check your email for verification."
}
```

**Response 409 Conflict:**
```json
{
  "error": "Email already registered"
}
```

**Validations:**
- Email unique
- Password min 8 chars, must contain number and special char
- Password and confirmPassword must match

**Derived from:**
- Screen: signup-screen (v1)
- Component: SignupForm
- Annotation: UI-005 (Create Account Button)

---

## User Service

### GET /users/me

**Description:** Get current authenticated user profile

**Request:**
- Headers: `Authorization: Bearer {token}`

**Response 200 OK:**
```json
{
  "id": "string (UUID)",
  "email": "string",
  "name": "string",
  "avatar": "string (URL, nullable)",
  "createdAt": "string (ISO 8601)"
}
```

**Response 401 Unauthorized:**
```json
{
  "error": "Invalid or expired token"
}
```

**Derived from:**
- Screen: profile-screen (v1)
- Component: UserProfile

---

## Data Models

### User
```json
{
  "id": "UUID",
  "email": "string",
  "password": "string (hashed)",
  "name": "string",
  "avatar": "string (nullable)",
  "emailVerified": "boolean",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### Session
```json
{
  "id": "UUID",
  "userId": "UUID",
  "token": "string (JWT)",
  "expiresAt": "datetime"
}
```
```

---

## 5) Requisitos não visuais

Requisitos como "offline", "performance", "segurança", etc. raramente são evidentes em imagem.

Durante UI-only:
- Listar em coverage report `vN.map.md` como "Non-visual requirements"
- Definir como serão testados depois (ex.: integração, e2e, contract tests, offline harness)

### Exemplo em vN.map.md

```markdown
# Login Screen - Coverage Report v2

## Visual Requirements

✅ REQ-001: User can enter email and password
✅ REQ-002: User can click "Sign In" button
✅ REQ-003: User can click "Forgot password" link

## Non-visual Requirements

⏳ REQ-004: Login must complete in < 2 seconds
   - Validation method: Performance test (Lighthouse, k6)
   - Status: Planned (to be tested post-implementation)

⏳ REQ-005: Form works offline (cached credentials)
   - Validation method: Offline mode test harness
   - Status: Planned (requires service worker implementation)

⏳ REQ-006: Password must be encrypted in transit
   - Validation method: HTTPS enforcement test
   - Status: Planned (infrastructure requirement)
```

---

## 6) Gate para iniciar backend ("UI freeze")

### Recomendação de critério de prontidão:

#### Checklist por Requisito

Para cada requisito em escopo:

- [ ] Pelo menos 1 tela aprovada com evidência visual (annotation IDs)
- [ ] Approval record com status `frozen`
- [ ] Component manifest existe e valida contra schema
- [ ] Todos API calls do manifest estão documentados em `contracts.draft.md`

#### Checklist por Cenário (AC-*)

Para cada cenário principal:

- [ ] Vídeo/storyboard de fluxo existe
- [ ] Golden trace existe e valida contra schema
- [ ] Assertions existem e validam contra schema
- [ ] Approval de UX flow com status `frozen`

#### Checklist de Contratos

- [ ] `backend_specs/contracts.draft.md` existe
- [ ] Todos endpoints têm request/response schemas
- [ ] Todos data models estão definidos
- [ ] Validações e error codes documentados
- [ ] Cada endpoint tem `derivedFrom` apontando para screen/component

#### Checklist de Ambiguidades

- [ ] Arquivo `assumptions.md` existe (se houver ambiguidades)
- [ ] Ambiguidades críticas estão registradas e aguardando decisão
- [ ] Não há bloqueadores técnicos não resolvidos

### Comando de Validação

```bash
# Agente AI ou script deve executar:
validate-ui-freeze-gate --strict
```

**Output esperado:**

```
🔍 Validating UI Freeze Gate...

✅ Requirements Coverage
   REQ-001: login-screen (v2) - FROZEN
   REQ-002: signup-screen (v1) - FROZEN
   REQ-003: dashboard-screen (v3) - FROZEN
   Total: 3/3 (100%)

✅ Scenarios Coverage
   AC-001: user-registration-flow (v1) - FROZEN
   AC-002: user-login-flow (v1) - FROZEN
   Total: 2/2 (100%)

✅ Contracts Completeness
   Endpoints documented: 15/15
   Models defined: 8/8
   All API calls covered: ✓

✅ Cross-artifact Validation
   No broken references
   All annotation IDs exist
   All manifests valid

🎉 UI Freeze Gate: PASS

Status: OPEN FOR BACKEND IMPLEMENTATION

Next steps:
1. Finalize contracts (contracts.draft.md → contracts.final.md)
2. Create backend scaffolds
3. Implement business logic
4. Run integration tests
```

### Quando o Gate Falha

```
❌ UI Freeze Gate: FAIL

Issues found:

📋 Requirements Coverage
   ❌ REQ-004: no screen associated
   ❌ REQ-005: profile-screen approval status is 'pending' (expected 'frozen')

📋 Contracts
   ❌ Endpoint POST /users/update-profile referenced in manifest but not in contracts

📋 Cross-artifact
   ❌ annotation ID UI-999 referenced in manifest but doesn't exist

Actions required:
1. Create screen for REQ-004 or mark as non-visual
2. Freeze profile-screen approval
3. Add POST /users/update-profile to contracts.draft.md
4. Fix or remove UI-999 reference in manifest

Run: validate-ui-freeze-gate --fix-suggestions
```

---

## 7) Workflow Completo - Exemplo Prático

### Cenário: Criar funcionalidade de "Login"

#### Passo 1: Gerar UI

```
User: "Gere uma tela de login no estilo shadcn/ui"

Agent: [Gera imagem]
       ui_specs/login-screen/versions/2026-01-10-v1.png ✓
       ui_specs/login-screen/metadata.json ✓
```

#### Passo 2: Anotar

```
User: "Anote todos os elementos da tela de login"

Agent: [Usa GPT-4V para identificar elementos]
       ui_specs/login-screen/versions/2026-01-10-v1.json ✓
       ui_specs/login-screen/versions/2026-01-10-v1.map.md ✓

       Elementos identificados:
       - UI-001: Email Input
       - UI-002: Password Input
       - UI-003: Login Button
       - UI-004: Forgot Password Link
```

#### Passo 3: Criar Manifest

```
User: "Crie o manifest de componentes"

Agent: [Deriva componentes das annotations]
       ui_specs/login-screen/components/v1.json ✓

       Componentes:
       - LoginForm (props: onSubmit, state: email/password/isLoading)
       - Button (shadcn/ui)
       - Input (shadcn/ui)

       API calls identificados:
       - POST /auth/login
```

#### Passo 4: Aprovar

```
User: "Aprove para o requisito REQ-001"

Agent: [Cria approval record]
       ui_approvals/REQ-001/login-screen.approval.json ✓

       Status: approved
       Evidence: UI-001, UI-002, UI-003, UI-004, manifest v1
```

#### Passo 5: Iterar (Feedback)

```
User: "Adicione um link 'Criar conta' abaixo do botão de login"

Agent: [Gera v2 da imagem com modificação]
       ui_specs/login-screen/versions/2026-01-11-v2.png ✓
       [Atualiza annotations]
       ui_specs/login-screen/versions/2026-01-11-v2.json ✓
       (+ UI-005: Create Account Link)
       [Atualiza manifest]
       ui_specs/login-screen/components/v2.json ✓

User: "Re-aprove esta versão"

Agent: [Atualiza approval para v2 e status frozen]
       ui_approvals/REQ-001/login-screen.approval.json ✓
       Status: frozen
```

#### Passo 6: Draftar Contratos

```
User: "Crie os contratos de backend"

Agent: [Extrai API calls de todos manifests]
       [Cria schemas de request/response]
       backend_specs/contracts.draft.md ✓

       Endpoints:
       - POST /auth/login
       - POST /auth/register (do signup-screen)
       - POST /auth/forgot-password
```

#### Passo 7: Validar Gate

```
User: "Podemos iniciar o backend?"

Agent: [Executa validação de gate]

       ✅ All requirements covered
       ✅ All screens frozen
       ✅ All contracts documented
       ✅ No broken references

       🎉 UI Freeze Gate: PASS
       Status: READY FOR BACKEND
```

#### Passo 8: Scaffold Backend

```
User: "Faça scaffold do backend em .NET"

Agent: [Gera estrutura]
       backend_specs/scaffolds/auth-service/
         Controllers/AuthController.cs ✓
         Models/LoginRequest.cs ✓
         Models/LoginResponse.cs ✓
         Services/IAuthService.cs ✓
         README.md ✓

       Next: Implement business logic in AuthService
```

---

## 8) Benefícios do UI-Only Workflow

### Para Product Owners
- ✅ Visualizar features antes de investir em backend
- ✅ Aprovar UX rapidamente
- ✅ Rastrear o que foi aprovado com evidência

### Para Designers
- ✅ Iterar designs sem depender de código
- ✅ Documentar componentes e padrões
- ✅ Validar accessibility e usability

### Para Desenvolvedores Frontend
- ✅ Começar implementação enquanto backend é planejado
- ✅ Contratos de API claros desde o início
- ✅ Mocks prontos para desenvolver

### Para Desenvolvedores Backend
- ✅ Requisitos bem definidos
- ✅ Contratos de API aprovados antes de codificar
- ✅ Menos mudanças depois de começar

### Para QA
- ✅ Golden traces e assertions prontos para testes E2E
- ✅ Cenários de aceitação claros
- ✅ Cobertura visual documentada

---

## 9) Anti-Patterns (Evitar)

### ❌ Implementar backend antes de UI freeze
- Resulta em retrabalho quando UI muda
- Contratos de API instáveis

### ❌ Não versionar artefatos
- Perda de histórico
- Impossível rastrear mudanças

### ❌ Aprovar sem evidência
- Aprovações sem annotation IDs
- Difícil validar cobertura

### ❌ Pular anotações e ir direto para manifest
- Manifest sem base sólida
- Difícil manter consistência

### ❌ Não validar schemas
- Artefatos inconsistentes
- Falhas na validação de gate

### ❌ Não documentar requisitos não-visuais
- Performance, security, offline capabilities esquecidos
- Descobertos tarde demais

---

## 10) Ferramentas Recomendadas

### Para Geração de UI
- **DALL-E 3** (OpenAI)
- **Midjourney** (Discord bot)
- **Stable Diffusion** (local ou Replicate)

### Para Anotação
- **GPT-4 Vision** (OpenAI)
- **Claude Vision** (Anthropic)
- **Gemini Vision** (Google)
- **Manual:** Figma + export JSON

### Para Validação
- **AJV** (JavaScript/Node.js)
- **jsonschema** (Python)
- **NJsonSchema** (.NET)

### Para Geração de Vídeos UX
- **Runway ML** (AI video generation)
- **Pika** (video AI)
- **After Effects** + export MP4

### Para Scaffold
- **Yeoman** (templates)
- **Plop** (micro-generators)
- **Custom scripts** em Python/Node.js

---

## 11) Conclusão

UI-Only Iterations permitem:

1. ✅ **Validar UX** antes de investir em backend
2. ✅ **Reduzir retrabalho** com aprovações antecipadas
3. ✅ **Paralelizar trabalho** (frontend e backend)
4. ✅ **Documentar contratos** antes de implementar
5. ✅ **Manter rastreabilidade** total

### Quando Transicionar para Backend

Quando o **UI Freeze Gate** passar:
- Todas UIs aprovadas e frozen
- Contratos drafted
- UX flows documentados
- Nenhum artefato faltante

**Então** é seguro iniciar backend implementation.

---

Para mais detalhes:
- [FRAMEWORK_SPEC.md](FRAMEWORK_SPEC.md)
- [AGENTS.md](AGENTS.md)
- [guides/workflow-guide.md](guides/workflow-guide.md)
- [guides/validation-rules.md](guides/validation-rules.md)

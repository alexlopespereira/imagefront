# AGENTS.md — AI Agent Integration Guide

Este documento define como agentes de IA (Claude Code, ChatGPT, etc.) devem trabalhar com o framework Imagefront para desenvolvimento assistido por IA.

---

## Overview

Agentes de IA são fundamentais no workflow do Imagefront. Eles auxiliam em:

1. **Geração de UI** via prompts estruturados para DALL-E, Midjourney, etc.
2. **Anotação automática** de elementos UI usando vision models
3. **Criação de manifestos** de componentes derivados de annotations
4. **Drafting de contratos** backend baseados em API calls identificados
5. **Validação de gates** e completude de artefatos
6. **Scaffolding** de estruturas de código backend

---

## UI-Only Iterations Mode (mandatory support)

Este framework suporta **iterações UI-only**, onde a equipe gera e aprova protótipos de UI (imagens + anotações + manifestos de componentes) **antes** de implementar qualquer backend.

### Goals
- Rapidamente explorar e convergir em UX/UI e entendimento de requisitos
- Manter rastreabilidade e aprovações mesmo sem backend
- Produzir artefatos prontos para backend quando o projeto transicionar para implementação

### What is allowed during UI-only mode

Agentes **PODEM**:
- Gerar imagens de UI e versões
- Produzir anotações (`vN.json`), coverage reports (`vN.map.md`), e manifestos de componentes (`components/vN.json`)
- Criar sequências UX de frames (versions) e golden traces/assertions (mesmo que alguns assertions sejam placeholders)
- Atualizar specs de requisitos para clarificar comportamento e IDs

Agentes **NÃO PODEM**:
- Implementar endpoints/business logic de backend (exceto stubs/mocks explicitamente solicitados)
- Criar código backend "fake" que finge ser implementação real
- Marcar requisitos não-visuais como validados (eles só podem ser planejados)

### Backend planning outputs (mandatory)

Durante UI-only mode, agentes **DEVEM** ainda produzir **artefatos de planejamento de backend** para trabalho futuro:

- Para cada screen, propor um conjunto candidato de contratos de API:
  - endpoints (método/path), sketches de request/response DTOs
  - regras de validação e casos de erro
- Armazenar como drafts (não implementados), ex:
  `/backend_specs/contracts.draft.md`

### Approvals still apply (mandatory)

Mesmo em UI-only mode:
- Aprovações por requisito **DEVEM** ser mantidas em `/ui_approvals/<REQ_ID>/`
- Aprovações **DEVEM** incluir evidência via `evidence` (referenciando annotation IDs ou screen versions)

### Non-visual requirements handling (mandatory)

Em UI-only mode, qualquer requisito que não pode ser evidenciado visualmente **DEVE** ser listado em "Non-visual requirements" no coverage report com um método de validação planejado (testes a serem escritos depois).

### Transition rule: "UI freeze" gate (recommended)

Antes de iniciar implementação de backend, o time **DEVERIA** estabelecer um UI freeze para o escopo relevante:
- Imagens aprovadas + anotações + manifestos de componentes existem para cada requisito em escopo
- Sequências UX aprovadas + golden traces existem para cenários-chave (AC-*)
- Contratos candidatos são drafted para cada flow de tela

---

## Workflow por Fase

### Fase 1: UI Ideation (Geração Inicial)

**Objetivo:** Gerar protótipos iniciais de UI

#### Comandos típicos:
```
User: "Gere uma tela de login moderna"
Agent: [Lê prompts/generate-ui.md]
       [Gera imagem via DALL-E usando prompt estruturado]
       [Salva em ui_specs/login-screen/versions/2026-01-10-v1.png]
       [Cria metadata.json inicial]
```

#### Template de prompt usado:
- `prompts/generate-ui.md`

#### Outputs gerados:
- `ui_specs/<screen-id>/versions/YYYY-MM-DD-vN.png`
- `ui_specs/<screen-id>/metadata.json`

#### Validações:
- ✓ Imagem salva com naming convention correto
- ✓ Metadata contém screen-id, version, createdAt, prompt usado

---

### Fase 2: UI Annotation (Identificação de Elementos)

**Objetivo:** Anotar elementos da UI gerada

#### Comandos típicos:
```
User: "Anote todos os elementos desta tela"
Agent: [Lê prompts/annotate-ui.md]
       [Usa GPT-4V ou Claude Vision para identificar elementos]
       [Cria annotations seguindo schemas/annotation.schema.json]
       [Gera arquivo humanizado .map.md]
```

#### Template de prompt usado:
- `prompts/annotate-ui.md`

#### Outputs gerados:
- `ui_specs/<screen-id>/versions/YYYY-MM-DD-vN.json` (annotations)
- `ui_specs/<screen-id>/versions/YYYY-MM-DD-vN.map.md` (human-readable)

#### Validações:
- ✓ Annotations validam contra `schemas/annotation.schema.json`
- ✓ Todos elementos visíveis identificados
- ✓ Bounds (x, y, width, height) corretos
- ✓ Types apropriados (button, input, text, etc.)
- ✓ Data bindings identificados quando relevante

---

### Fase 3: Component Manifest Creation

**Objetivo:** Transformar anotações em especificações de componentes

#### Comandos típicos:
```
User: "Crie o manifest de componentes para esta tela"
Agent: [Lê prompts/create-component-manifest.md]
       [Deriva componentes das annotations]
       [Identifica props, state, events, API calls necessários]
       [Valida contra schemas/component-manifest.schema.json]
```

#### Template de prompt usado:
- `prompts/create-component-manifest.md`

#### Outputs gerados:
- `ui_specs/<screen-id>/components/vN.json`

#### Validações:
- ✓ Manifest valida contra `schemas/component-manifest.schema.json`
- ✓ Todos annotation IDs referenciados existem
- ✓ API calls necessários identificados
- ✓ Props e state definidos apropriadamente
- ✓ Events mapeados para interactions das annotations

---

### Fase 4: UI Approval

**Objetivo:** Registrar aprovação formal de UI

#### Comandos típicos:
```
User: "Aprove esta tela para o requisito REQ-001"
Agent: [Usa templates/approval-template.json como base]
       [Preenche campos: reqId, screenId, version, approver, timestamp]
       [Adiciona evidence: annotation IDs, manifest version]
       [Valida contra schemas/approval.schema.json]
       [Salva em ui_approvals/REQ-001/]
```

#### Template usado:
- `templates/approval-template.json`

#### Outputs gerados:
- `ui_approvals/<REQ_ID>/<screen-id>.approval.json`

#### Validações:
- ✓ Approval valida contra `schemas/approval.schema.json`
- ✓ Evidence references existem (annotation IDs válidos)
- ✓ Status apropriado (pending/approved/rejected/frozen)
- ✓ Approver information completa

---

### Fase 5: UI Freeze Gate Validation

**Objetivo:** Verificar que todos artefatos obrigatórios estão presentes

#### Comandos típicos:
```
User: "Valide se podemos iniciar o backend"
Agent: [Lê guides/validation-rules.md]
       [Para cada requisito em escopo:]
       [  - Verifica imagem existe]
       [  - Verifica annotations existem e validam]
       [  - Verifica manifest existe e valida]
       [  - Verifica approval com status frozen]
       [  - Verifica API calls estão em contracts.draft.md]
       [Gera relatório de validação]
```

#### Guia usado:
- `guides/validation-rules.md`

#### Outputs gerados:
- Relatório de validação (console, markdown, ou JSON)

#### Checklist verificado:

**Por screen:**
- ✓ UI image existe (`ui_specs/<screen-id>/versions/YYYY-MM-DD-vN.png`)
- ✓ Annotation file existe e valida contra schema
- ✓ Map file (.map.md) existe
- ✓ Component manifest existe e valida contra schema
- ✓ Approval record existe com status "frozen"

**Cross-artifact:**
- ✓ Annotation IDs referenciados em manifest existem
- ✓ API calls em manifests estão presentes em contracts.draft.md
- ✓ Screens referenciados em UX flows têm versões válidas
- ✓ Nenhuma referência quebrada

**Contracts:**
- ✓ `backend_specs/contracts.draft.md` existe
- ✓ Todos endpoints têm request/response schemas
- ✓ Validações e error codes documentados

---

### Fase 6: Backend Contract Drafting

**Objetivo:** Criar especificações de API backend

#### Comandos típicos:
```
User: "Crie os contratos de backend baseados nas telas aprovadas"
Agent: [Lê prompts/draft-contracts.md]
       [Agrega todos API calls de todos component manifests]
       [Agrupa por serviço lógico]
       [Cria request/response schemas]
       [Documenta validações e error cases]
       [Usa templates/contracts-template.md como base]
       [Valida contra schemas/contract.schema.json]
```

#### Templates usados:
- `prompts/draft-contracts.md`
- `templates/contracts-template.md`

#### Outputs gerados:
- `backend_specs/contracts.draft.md`

#### Validações:
- ✓ Contracts validam contra `schemas/contract.schema.json`
- ✓ Todos API calls dos manifests estão documentados
- ✓ Request/response schemas definidos
- ✓ Cada endpoint tem `derivedFrom` apontando para screens/components

---

### Fase 7: UX Sequence Generation (Optional)

**Objetivo:** Criar sequências de fluxo UX

#### Comandos típicos:
```
User: "Crie um fluxo UX para registro de usuário"
Agent: [Lê prompts/generate-ux-sequence.md]
       [Identifica screens envolvidas]
       [Cria storyboard ou vídeo]
       [Define golden trace com steps]
       [Cria assertions para cada step]
```

#### Template usado:
- `prompts/generate-ux-sequence.md`

#### Outputs gerados:
- `ux_specs/<scenario-id>/versions/YYYY-MM-DD-vN.mp4` (ou frames)
- `ux_specs/<scenario-id>/traces/vN.trace.yml`
- `ux_specs/<scenario-id>/traces/vN.assert.yml`

#### Validações:
- ✓ Trace valida contra `schemas/trace.schema.json`
- ✓ Assertions validam contra `schemas/assertion.schema.json`
- ✓ Todos screens referenciados no trace existem
- ✓ API calls esperados estão em contracts

---

### Fase 8: Backend Scaffolding (Post UI-Freeze)

**Objetivo:** Gerar estrutura de código backend

#### Comandos típicos:
```
User: "Faça scaffold do backend em .NET"
Agent: [Lê prompts/scaffold-backend.md]
       [Lê backend_specs/contracts.draft.md (ou final)]
       [Gera estrutura de pastas]
       [Cria controllers/models/services stubs]
       [Documenta TODOs para implementação]
```

#### Template usado:
- `prompts/scaffold-backend.md`

#### Outputs gerados:
- `backend_specs/scaffolds/<service-name>/...` (estrutura de código)
- Controllers, Models, DTOs, README

#### Validações:
- ✓ Todos endpoints dos contracts têm controller methods
- ✓ Todos models dos contracts têm classes/DTOs
- ✓ README documenta próximos passos

---

## Common Agent Patterns

### Pattern 1: Iterative UI Refinement

```
User: "A tela de login precisa de um botão 'Esqueci minha senha'"

Agent: [Lê screen atual: ui_specs/login-screen/versions/2026-01-10-v1.png]
       [Gera nova versão v2 com a modificação]
       [Salva em ui_specs/login-screen/versions/2026-01-11-v2.png]
       [Copia annotations de v1 e adiciona nova annotation para o botão]
       [Atualiza component manifest v2]
       [Sugere re-approval]
```

### Pattern 2: Batch Screen Generation

```
User: "Gere as telas de signup, verify-email e profile-setup"

Agent: [Para cada tela:]
       [  - Gera imagem]
       [  - Cria annotations]
       [  - Cria manifest]
       [  - Cria metadata]
       [Sugere criar UX sequence ligando as 3 telas]
```

### Pattern 3: Contract Review and Update

```
User: "Revise os contratos e adicione autenticação JWT"

Agent: [Lê backend_specs/contracts.draft.md]
       [Adiciona header Authorization em endpoints que precisam]
       [Adiciona endpoint POST /auth/token]
       [Adiciona modelos JWTToken, LoginRequest, LoginResponse]
       [Documenta error 401 Unauthorized]
       [Atualiza contracts.draft.md]
```

### Pattern 4: Error Recovery

```
Agent tenta validar gate e encontra erro:

Agent: "❌ Gate validation failed for login-screen:
        - Missing annotation file
        - Component manifest references non-existent annotation ID 'UI-999'

        I can fix this automatically. Should I:
        1. Generate missing annotation file
        2. Fix manifest to remove invalid reference
        3. Both"

User: "Both"

Agent: [Executa correções]
       [Re-valida gate]
       [Reporta sucesso]
```

---

## Agent Integration with Claude Code

### Recommended Workflow

1. **User provides natural language request**
   ```
   "Crie uma dashboard administrativa com tabela de usuários e gráficos"
   ```

2. **Agent identifies phase and template**
   - Phase: UI Ideation (Fase 1)
   - Template: `prompts/generate-ui.md`

3. **Agent executes structured prompt**
   - Lê template
   - Injeta contexto (estilo shadcn/ui, dimensões, etc.)
   - Chama DALL-E ou similar
   - Salva artefatos

4. **Agent validates output**
   - Verifica naming convention
   - Valida contra schema (se aplicável)
   - Checa references cruzadas

5. **Agent reports back to user**
   ```
   "✅ Dashboard screen generated:
   - Image: ui_specs/admin-dashboard/versions/2026-01-10-v1.png
   - Metadata: ui_specs/admin-dashboard/metadata.json

   Next steps:
   1. Review the image
   2. Run annotation: 'Anote esta tela'
   3. Create manifest: 'Crie o manifest de componentes'"
   ```

### Prompt Context Injection

Quando um agente lê um template de prompt (ex: `prompts/generate-ui.md`), ele deve:

1. **Substituir placeholders**
   - `{screen-id}` → ID atual
   - `{style}` → Preferência (ex: shadcn/ui)
   - `{existing-patterns}` → Padrões já usados no projeto

2. **Adicionar contexto de artefatos existentes**
   ```
   Existing screens in this project:
   - login-screen (v2)
   - signup-screen (v1)
   - dashboard (v3)

   Common components used:
   - Button (shadcn/ui style)
   - Input (with label and error message)
   - Card (with header and content)
   ```

3. **Incluir constraints e validações**
   ```
   This screen must:
   - Follow naming: kebab-case
   - Use version: v1 (first version)
   - Dimensions: 1920x1080
   - Validate against: schemas/annotation.schema.json (for annotations)
   ```

---

## Error Handling for Agents

### Common Errors and Recovery

| Error | Cause | Recovery |
|-------|-------|----------|
| Schema validation failed | Artefato não conforme ao schema | Re-gerar artefato seguindo schema |
| Missing reference | Annotation ID não existe | Criar annotation ou remover referência |
| Gate validation failed | Artefatos obrigatórios faltando | Listar faltantes e gerar cada um |
| API call not in contracts | Manifest tem API call não documentado | Adicionar endpoint em contracts.draft.md |
| Version conflict | Versão já existe | Incrementar versão (v2 → v3) |

### Agent Error Reporting Template

```
❌ Error: {error-type}

Context:
- File: {file-path}
- Line/Field: {location}

Issue:
{description}

Suggestion:
{suggested-fix}

Would you like me to:
[ ] Fix automatically
[ ] Show me the problematic content
[ ] Skip and continue
```

---

## Agent Capabilities Matrix

| Capability | Phase | Required Tools | Schemas Used |
|-----------|-------|----------------|--------------|
| Generate UI | 1 | DALL-E/Midjourney | - |
| Annotate UI | 2 | GPT-4V/Claude Vision | annotation.schema.json |
| Create Manifest | 3 | LLM reasoning | component-manifest.schema.json |
| Approve UI | 4 | File I/O | approval.schema.json |
| Validate Gate | 5 | File I/O + validation | All schemas |
| Draft Contracts | 6 | LLM reasoning | contract.schema.json |
| Generate UX Flow | 7 | Video gen APIs (optional) | trace.schema.json, assertion.schema.json |
| Scaffold Backend | 8 | Code generation | contract.schema.json |

---

## Best Practices for Agents

1. **Always validate before saving**
   - Use JSON Schema validators
   - Check cross-references
   - Verify naming conventions

2. **Maintain version history**
   - Never overwrite existing versions
   - Always increment version number
   - Preserve old versions for audit

3. **Be explicit about assumptions**
   ```
   "Assuming shadcn/ui style based on project patterns.
    Override with --style flag if needed."
   ```

4. **Suggest next steps**
   ```
   "Screen generated successfully.
    Next: run 'Anote esta tela' to add annotations."
   ```

5. **Report progress for long operations**
   ```
   ⏳ Generating UI (step 1/4)...
   ⏳ Annotating elements (step 2/4)...
   ⏳ Creating manifest (step 3/4)...
   ⏳ Validating artifacts (step 4/4)...
   ✅ Complete!
   ```

---

## Testing Agent Integration

### Validation Checklist

- [ ] Agent can read all prompt templates
- [ ] Agent can generate artifacts that validate against schemas
- [ ] Agent can perform cross-artifact validation
- [ ] Agent can detect and report errors clearly
- [ ] Agent suggests appropriate next steps
- [ ] Agent maintains version history correctly
- [ ] Agent follows naming conventions

### Test Scenarios

1. **Happy path:** Generate → Annotate → Manifest → Approve → Validate
2. **Error recovery:** Invalid annotation ID → Detect → Fix → Re-validate
3. **Iterative refinement:** v1 → v2 → v3 with incremental changes
4. **Batch operations:** Generate 5 screens in one request
5. **Gate validation:** Missing artifacts → List → Generate → Pass

---

## Conclusion

Agents de IA são essenciais para o sucesso do framework Imagefront. Eles devem:

- ✅ Seguir templates de prompts estruturados
- ✅ Validar todos artefatos contra schemas
- ✅ Manter rastreabilidade entre artefatos
- ✅ Suportar modo UI-only obrigatoriamente
- ✅ Enforçar UI freeze gate antes de backend
- ✅ Reportar erros claramente e sugerir fixes
- ✅ Preservar histórico de versões

Para detalhes técnicos, veja:
- [guides/ai-integration.md](guides/ai-integration.md)
- [FRAMEWORK_SPEC.md](FRAMEWORK_SPEC.md)
- [UI_ONLY_ITERATIONS.md](UI_ONLY_ITERATIONS.md)

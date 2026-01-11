# Guia Prático de Delegação: Claude Code → Antigravity

Este guia demonstra como o Claude Code delega tarefas simples para o assistente do Antigravity, economizando sua quota de tokens.

## Como Funciona

1. **Você faz uma solicitação** ao Claude Code
2. **Claude Code analisa** se a tarefa é simples/repetitiva
3. **Se sim**: Delega para Antigravity via `antigravity chat`
4. **Se não**: Processa diretamente com Claude Code

## Comandos de Delegação

### Sintaxe Básica

```bash
antigravity chat --mode <modo> [opções] "descrição da tarefa"
```

### Modos Disponíveis

| Modo | Uso | Exemplo |
|------|-----|---------|
| `agent` | Tarefas autônomas complexas | Criar PR, rodar testes, refatorar |
| `edit` | Edição direta de código | Adicionar função, corrigir typo |
| `ask` | Perguntas e consultas | "Quais arquivos usam a API X?" |

### Opções Úteis

| Opção | Descrição | Quando Usar |
|-------|-----------|-------------|
| `--add-file <path>` | Adiciona arquivo como contexto | Quando a tarefa precisa entender código específico |
| `--reuse-window` | Usa janela existente do Antigravity | Para tarefas rápidas sem precisar nova janela |
| `--new-window` | Abre nova janela | Para tarefas que não devem interferir com trabalho atual |

## Exemplos Práticos de Delegação

### 1. Operações Git Simples

**Criar commit convencional:**
```bash
antigravity chat --mode agent "Stage all changes and create a conventional commit with message 'feat: add user authentication module'"
```

**Criar PR de atualização de dependências:**
```bash
antigravity chat --mode agent --add-file package.json "Update all devDependencies to latest versions, run tests, and create a PR titled 'chore: update dev dependencies'"
```

**Merge de branch:**
```bash
antigravity chat --mode agent "Merge branch 'feature/auth' into main using rebase strategy"
```

### 2. Formatação e Linting

**Formatar código:**
```bash
antigravity chat --mode agent "Run prettier on all TypeScript files and commit with message 'style: format code with prettier'"
```

**Corrigir problemas de linting:**
```bash
antigravity chat --mode agent "Run ESLint --fix on src directory and report any remaining issues that require manual intervention"
```

### 3. Geração de Boilerplate

**Criar model/interface:**
```bash
antigravity chat --mode agent "Create a new Product model with fields: id (string), name (string), price (number), inStock (boolean), createdAt (Date). Follow the pattern used in existing models."
```

**Gerar testes básicos:**
```bash
antigravity chat --mode agent --add-file src/utils/formatDate.ts "Create a test file for formatDate.ts with basic test cases covering valid dates, invalid dates, and edge cases"
```

### 4. Documentação

**Atualizar README:**
```bash
antigravity chat --mode edit --add-file README.md "Add a 'Contributing' section with guidelines for pull requests, code style, and testing requirements"
```

**Gerar CHANGELOG:**
```bash
antigravity chat --mode agent "Generate CHANGELOG.md entry for version 1.2.0 based on git commits since last release tag"
```

### 5. Testes e Builds

**Rodar testes:**
```bash
antigravity chat --mode agent "Run npm test, analyze results, and create a summary report of coverage and any failing tests"
```

**Build e validação:**
```bash
antigravity chat --mode agent "Run production build, check for errors/warnings, and report bundle size compared to previous build"
```

### 6. Navegação e Organização

**Encontrar arquivos:**
```bash
antigravity chat --mode ask "Which files import the UserService class?"
```

**Organizar imports:**
```bash
antigravity chat --mode agent "Organize all imports in TypeScript files alphabetically and remove unused imports"
```

## Como Claude Code Decide Delegar

### ✅ Delega Automaticamente Para:

- PRs de rotina (bump versão, deps)
- Commits com mensagens convencionais
- Formatação/linting
- Geração de boilerplate
- Testes automatizados
- Atualizações de documentação

### ❌ NUNCA Delega:

- Decisões arquiteturais
- Debug complexo
- Code review de segurança
- Otimização de performance
- Design de novas features

## Fluxo de Exemplo

**Você pede:**
> "Claude, preciso criar um PR para atualizar as dependências do projeto"

**Claude Code analisa:**
```
Tarefa: Atualização de dependências
Tipo: Operacional/Repetitiva ✓
Bem definida: Sim ✓
Requer reasoning complexo: Não ✓
→ Decisão: DELEGAR para Antigravity
```

**Claude Code executa:**
```bash
antigravity chat --mode agent --add-file package.json \
  "Update all devDependencies to latest compatible versions, run npm test to ensure nothing breaks, and create a PR titled 'chore(deps): update dev dependencies' with a summary of updated packages"
```

**Resultado:**
- ✅ Antigravity atualiza dependências
- ✅ Roda testes
- ✅ Cria PR automaticamente
- ✅ Claude Code economizou ~5,000-10,000 tokens

## Medindo Economia de Tokens

### Antes (sem delegação):
```
Tarefa: Criar PR de atualização de deps
Claude Code tokens usados: ~15,000
- Leitura de package.json: 2,000
- Análise de dependências: 3,000
- Atualização de arquivos: 4,000
- Execução de testes: 3,000
- Criação de PR: 3,000
```

### Depois (com delegação):
```
Tarefa: Criar PR de atualização de deps
Claude Code tokens usados: ~500
- Análise da tarefa: 200
- Delegação via Bash: 100
- Verificação de resultado: 200

Antigravity tokens usados: 0 (usa quota separada do Gemini)
```

**Economia: ~97% de tokens do Claude Code**

## Dicas de Uso

1. **Seja específico**: Quanto mais clara a instrução, melhor o resultado
   - ❌ "Update dependencies"
   - ✅ "Update devDependencies to latest versions, run tests, create PR"

2. **Use --add-file**: Forneça contexto quando necessário
   - ❌ `antigravity chat "fix the user model"`
   - ✅ `antigravity chat --add-file src/models/User.ts "add email validation"`

3. **Escolha o modo certo**:
   - Tarefas multi-step → `--mode agent`
   - Edições diretas → `--mode edit`
   - Consultas → `--mode ask`

4. **Combine com --reuse-window**: Para tarefas rápidas sequenciais
   ```bash
   antigravity chat --mode agent --reuse-window "task 1"
   antigravity chat --mode agent --reuse-window "task 2"
   ```

## Troubleshooting

### Problema: Comando não retorna output

**Causa**: `antigravity chat` abre interface gráfica no Antigravity
**Solução**: Isso é esperado - o assistente do Antigravity executará a tarefa na sua interface

### Problema: "Tarefa não foi completada"

**Causa**: Instrução muito vaga ou contexto insuficiente
**Solução**: Refaça com instrução mais específica e use `--add-file` para contexto

### Problema: "Claude Code não está delegando automaticamente"

**Causa**: CLAUDE.md pode não estar sendo lido
**Solução**: Mencione explicitamente: "Delegue isso para o Antigravity"

## Referência Rápida

```bash
# Git operations
antigravity chat --mode agent "commit message: feat: add feature X"
antigravity chat --mode agent "create PR for current branch"
antigravity chat --mode agent "merge branch X into Y"

# Code formatting
antigravity chat --mode agent "format all .ts files with prettier"
antigravity chat --mode agent "fix all ESLint errors in src/"

# Testing
antigravity chat --mode agent "run tests and report failures"
antigravity chat --mode agent "run build and check for errors"

# Documentation
antigravity chat --mode edit --add-file README.md "add section X"
antigravity chat --mode agent "update CHANGELOG for version X"

# Code generation
antigravity chat --mode agent "create interface X with fields Y, Z"
antigravity chat --mode agent "generate test for function X"

# Queries
antigravity chat --mode ask "which files import module X?"
antigravity chat --mode ask "what is the structure of the API layer?"
```

## Próximos Passos

Agora que a delegação está configurada:

1. ✅ Teste com tarefas simples primeiro
2. ✅ Observe a economia de tokens
3. ✅ Ajuste as regras de delegação conforme necessário
4. ✅ Expanda para tarefas mais complexas gradualmente

**Lembre-se**: O objetivo é **você** economizar tokens do Claude Code, delegando trabalho operacional para o Antigravity (que usa Gemini 3 Flash).

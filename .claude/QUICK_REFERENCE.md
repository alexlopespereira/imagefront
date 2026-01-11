# 🚀 Quick Reference: Otimização de Tokens Claude Code

## Estratégia Dual de Otimização

### 🔄 Quando Usar Cada Abordagem

```
Tarefa Operacional (sem retorno necessário)
    ↓
    ANTIGRAVITY
    (95% economia, usa Gemini)

Tarefa Simples (precisa retorno)
    ↓
    HAIKU SUB-AGENT
    (90% economia, usa Claude Haiku)

Tarefa Complexa (reasoning profundo)
    ↓
    SONNET DIRETO
    (processamento normal)
```

---

## 📋 Decision Tree Rápida

### Você precisa do resultado imediatamente?

**❌ NÃO** → Use **Antigravity**
```bash
antigravity chat --mode agent "task"
```

**✅ SIM** → Continue abaixo ↓

### A tarefa requer reasoning complexo?

**❌ NÃO** → Use **Haiku Sub-Agent**
```markdown
Task tool com model="haiku"
```

**✅ SIM** → Use **Sonnet Direto**
```markdown
Processa normalmente (sem delegação)
```

---

## 🎯 Exemplos Práticos por Cenário

### Cenário 1: Criar PR de Dependências

**❓ Questão:** Preciso verificar se testes passaram antes de criar PR?

- **NÃO** → Antigravity
  ```bash
  antigravity chat --mode agent --add-file package.json \
    "Update devDependencies, run tests, create PR"
  ```

- **SIM** → Haiku Sub-Agent
  ```markdown
  Você (Claude Code): "Use Task tool com model='haiku' e
  subagent_type='general-purpose' para atualizar deps e
  reportar status dos testes antes de criar PR"
  ```

### Cenário 2: Buscar Código

**❓ Questão:** "Onde está implementada a função validateUser?"

**Resposta:** Use **Haiku Explore Agent**
```markdown
Task tool com:
- subagent_type="Explore"
- model="haiku"
- prompt="Find where validateUser function is defined"
```

**NÃO use:** Múltiplas chamadas Grep/Glob diretas

### Cenário 3: Formatar Código

**❓ Questão:** "Preciso ver o resultado da formatação agora?"

- **NÃO** → Antigravity
  ```bash
  antigravity chat --mode agent "Format all .ts files with Prettier"
  ```

- **SIM** → Haiku Bash Agent
  ```markdown
  Task tool com model="haiku" e subagent_type="Bash"
  ```

### Cenário 4: Debug de Bug Complexo

**❓ Questão:** Bug envolve race condition e lógica complexa?

**Resposta:** **Sonnet Direto** (NUNCA delegue)
```markdown
Claude Code processa diretamente com raciocínio profundo
```

### Cenário 5: Gerar Boilerplate

**❓ Questão:** "Crie interface User com id, name, email"

**Resposta:** **Antigravity**
```bash
antigravity chat --mode agent \
  "Create User interface with id (string), name (string), email (string)"
```

### Cenário 6: Commit e Push

**❓ Questão:** "Preciso confirmar que push foi bem-sucedido?"

- **NÃO** → Antigravity
  ```bash
  antigravity chat --mode agent "Commit all and push to origin"
  ```

- **SIM** → Haiku Bash Agent
  ```markdown
  Task tool com model="haiku" para executar git push e retornar status
  ```

---

## 🧮 Tabela de Custos (Tokens Aproximados)

| Tarefa | Antigravity | Haiku | Sonnet |
|--------|-------------|-------|--------|
| PR simples | ~0* | ~500 | ~10,000 |
| Busca código | N/A | ~300 | ~5,000 |
| Format código | ~0* | ~200 | ~3,000 |
| Debug simples | N/A | ~800 | ~8,000 |
| Debug complexo | ❌ | ❌ | ~20,000 |
| Commit git | ~0* | ~150 | ~2,000 |
| Generate boilerplate | ~0* | ~400 | ~5,000 |

\* Antigravity usa quota do Gemini, não do Claude

---

## 📊 Matriz de Decisão Completa

| Tarefa | Retorno Imediato? | Complexidade | Use | Economia |
|--------|-------------------|--------------|-----|----------|
| PR deps | ❌ | Baixa | Antigravity | 95% |
| PR deps | ✅ | Baixa | Haiku | 90% |
| Busca código | ✅ | Baixa | Haiku Explore | 90% |
| Format | ❌ | Baixa | Antigravity | 95% |
| Format | ✅ | Baixa | Haiku Bash | 90% |
| Commit | ❌ | Baixa | Antigravity | 95% |
| Commit + verify | ✅ | Baixa | Haiku Bash | 90% |
| Boilerplate | ❌ | Baixa | Antigravity | 95% |
| Boilerplate + verify | ✅ | Baixa | Haiku | 90% |
| Debug simples | ✅ | Média | Haiku | 90% |
| Debug complexo | ✅ | Alta | Sonnet | 0% |
| Arquitetura | ✅ | Alta | Sonnet | 0% |
| Segurança | ✅ | Alta | Sonnet | 0% |
| Performance | ✅ | Alta | Sonnet | 0% |

---

## 🔧 Comandos de Delegação

### Antigravity CLI

```bash
# Basic
antigravity chat --mode agent "task"

# Com arquivo de contexto
antigravity chat --mode agent --add-file file.ts "task"

# Reusar janela (tarefas sequenciais)
antigravity chat --mode agent --reuse-window "task"

# Edição direta
antigravity chat --mode edit --add-file file.ts "change X to Y"

# Pergunta
antigravity chat --mode ask "question?"
```

### Task Tool com Haiku

```markdown
# Explore agent (buscas)
Task tool:
- subagent_type: "Explore"
- model: "haiku"
- prompt: "Find X in codebase"

# General-purpose agent (tarefas variadas)
Task tool:
- subagent_type: "general-purpose"
- model: "haiku"
- prompt: "Do X and report Y"

# Bash agent (comandos git, npm, etc)
Task tool:
- subagent_type: "Bash"
- model: "haiku"
- prompt: "Run X command and verify Y"
```

---

## ✅ Checklist de Otimização

Antes de processar tarefa, pergunte:

1. **[ ]** Preciso do resultado agora?
   - ❌ → Antigravity
   - ✅ → Continue

2. **[ ]** É tarefa simples/repetitiva?
   - ✅ → Haiku
   - ❌ → Continue

3. **[ ]** Requer reasoning complexo?
   - ✅ → Sonnet
   - ❌ → Haiku (padrão)

4. **[ ]** É crítico (segurança/arquitetura)?
   - ✅ → Sonnet (NUNCA delegue)
   - ❌ → Pode usar Haiku

---

## 🎓 Exemplos de Diálogos Otimizados

### ❌ ANTES (Sem Otimização)

**Usuário:** "Busque onde está a função login"

**Claude Code:**
```
1. Grep por "function login" → 3,000 tokens
2. Grep por "login =" → 3,000 tokens
3. Grep por "const login" → 3,000 tokens
4. Lê arquivos encontrados → 5,000 tokens
Total: ~14,000 tokens
```

### ✅ DEPOIS (Com Otimização)

**Usuário:** "Busque onde está a função login"

**Claude Code:**
```
Task tool com Explore agent + Haiku:
- Busca completa em uma chamada
- Retorna resultados organizados
Total: ~300 tokens
```

**Economia: 97%**

---

### ❌ ANTES (Sem Otimização)

**Usuário:** "Crie PR para atualizar deps"

**Claude Code:**
```
1. Lê package.json → 2,000 tokens
2. Analisa deps desatualizadas → 3,000 tokens
3. Atualiza package.json → 2,000 tokens
4. Roda npm install → 1,000 tokens
5. Roda testes → 3,000 tokens
6. Cria commit → 2,000 tokens
7. Cria PR → 2,000 tokens
Total: ~15,000 tokens
```

### ✅ DEPOIS (Com Otimização)

**Usuário:** "Crie PR para atualizar deps"

**Claude Code:**
```
Delega para Antigravity:
antigravity chat --mode agent --add-file package.json \
  "Update deps, run tests, create PR"
Total: ~500 tokens (Claude Code)
       + 0 tokens quota Claude (usa Gemini)
```

**Economia: 97% + quota preservada**

---

## 📈 Métricas de Sucesso

### Antes da Otimização (Baseline)
```
100 tarefas/semana:
- 30 simples (PRs, commits) → 30 × 10k = 300k tokens
- 50 médias (buscas, boilerplate) → 50 × 5k = 250k tokens
- 20 complexas (debug, arquitetura) → 20 × 20k = 400k tokens
TOTAL: 950,000 tokens/semana
```

### Depois da Otimização (Dual Strategy)
```
100 tarefas/semana:
- 30 simples (delegadas Antigravity) → 30 × 500 = 15k tokens
- 50 médias (Haiku sub-agents) → 50 × 500 = 25k tokens
- 20 complexas (Sonnet direto) → 20 × 20k = 400k tokens
TOTAL: 440,000 tokens/semana
```

**Economia: 53% (~510k tokens/semana)**

---

## 🚨 Regras de Ouro

1. **NUNCA delegue segurança** → Sempre Sonnet direto
2. **NUNCA delegue arquitetura** → Sempre Sonnet direto
3. **SEMPRE use Haiku para buscas** → Nunca múltiplos Grep/Glob
4. **SEMPRE use Antigravity para fire-and-forget** → Economize 95%
5. **SEMPRE verifique se precisa retorno** → Isso decide Antigravity vs Haiku

---

## 🔍 Troubleshooting

### "Claude Code não está delegando automaticamente"

**Solução:** Mencione explicitamente no pedido:
- "Use Antigravity para isso"
- "Delegue para Haiku sub-agent"
- "Use Explore agent com Haiku"

### "Antigravity não retorna resultado"

**Esperado:** Antigravity executa em GUI, não no console.
**Solução:** Use Haiku sub-agent se precisa resultado imediato.

### "Tarefa foi delegada mas deveria ser Sonnet"

**Solução:** Ajuste CLAUDE.md adicionando a tarefa na lista de "NEVER delegate"

---

## 📚 Links Úteis

- **[CLAUDE.md](../CLAUDE.md)** - Configuração completa
- **[delegation-guide.md](delegation-guide.md)** - Guia detalhado Antigravity
- **[SETUP_SUMMARY.md](SETUP_SUMMARY.md)** - Resumo da configuração

---

**Última atualização:** 2026-01-11
**Versão:** 1.0 - Dual Strategy (Antigravity + Haiku Sub-Agents)

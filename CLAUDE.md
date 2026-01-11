# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Status

This is a newly initialized repository named "imagefront". There will be no development code specific to a given application in this repository. This is a generic framework for building image frontends of other application, this is not an instance of an end user application.

## Project Setup

The repository currently contains:
- README.md (minimal placeholder)
- .gitignore (Visual Studio/.NET template)

## Otimização de Tokens

### Delegação Automática
- Use `model="haiku"` no Task tool para tarefas que não exigem reasoning complexo
- PRs, commits, bumps de versão devem usar sub-agentes leves
- Pesquisas de código devem usar Task tool com Explore ao invés de múltiplas chamadas Grep



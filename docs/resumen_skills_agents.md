# 🤖 Guía Completa: Sistema de Skills y AGENTS.md para IA

> **Fuentes**: [Prowler Cloud](https://github.com/prowler-cloud/prowler) | [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots) | [Agent Skills Spec](https://agentskills.io)

---

## 📋 Conceptos Fundamentales

### ¿Qué es el AGENTS.md?
- Archivo Markdown que **solo los agentes de IA deben entender** (no es el README para humanos)
- Proporciona **contexto cultural del proyecto**: arquitectura, convenciones, tecnologías
- Indica **cómo debe comportarse** la IA y qué skills tiene disponibles

### El Problema del Contexto Excesivo
> ⚠️ **Cuanto más contexto tiene un agente, más puede alucinar**

| Problema | Solución |
|----------|----------|
| AGENTS.md muy grande | Dividir en múltiples archivos (250-500 líneas máx) |
| Mucho contexto cargado siempre | Usar Skills que se cargan bajo demanda |
| Modelos ignoran skills | Forzar auto-invocación con tabla explícita |

---

## 🏗️ Arquitectura Real (Prowler)

### Estructura de Archivos
```
📁 proyecto/
├── 📄 AGENTS.md                    ← Root principal
├── 📁 skills/
│   ├── 📄 setup.sh                 ← Instala en todas las herramientas
│   ├── 📁 typescript/
│   │   └── 📄 SKILL.md
│   ├── 📁 react-19/
│   │   └── 📄 SKILL.md
│   ├── 📁 nextjs-15/
│   │   └── 📄 SKILL.md
│   ├── 📁 prowler-api/
│   │   └── 📄 SKILL.md
│   └── 📁 prowler-compliance/
│       ├── 📄 SKILL.md
│       ├── 📁 assets/              ← Templates, ejemplos
│       └── 📁 references/          ← Links a docs locales
├── 📁 api/
│   └── 📄 AGENTS.md                ← Específico para API
├── 📁 ui/
│   └── 📄 AGENTS.md                ← Específico para UI
├── 📁 .claude/
│   ├── 📄 CLAUDE.md                ← Copia de AGENTS.md
│   └── 📁 skills/ → symlink
├── 📁 .gemini/
│   ├── 📄 GEMINI.md
│   └── 📁 skills/ → symlink
├── 📁 .codex/
│   └── 📁 skills/ → symlink
└── 📁 .github/
    └── 📄 copilot-instructions.md  ← Para GitHub Copilot
```

---

## 📄 Estructura del AGENTS.md

### Secciones Recomendadas

```markdown
# Repository Guidelines

## How to Use This Guide
- Start here for cross-project norms
- Each component has an `AGENTS.md` with specific guidelines
- Component docs override this file when guidance conflicts

## Available Skills

### Generic Skills (Any Project)
| Skill | Description | URL |
|-------|-------------|-----|
| `typescript` | Const types, flat interfaces, utility types | [SKILL.md](skills/typescript/SKILL.md) |
| `react-19` | No useMemo/useCallback, React Compiler | [SKILL.md](skills/react-19/SKILL.md) |
| `nextjs-15` | App Router, Server Actions, streaming | [SKILL.md](skills/nextjs-15/SKILL.md) |

### Project-Specific Skills
| Skill | Description | URL |
|-------|-------------|-----|
| `mi-proyecto-api` | Patrones específicos de mi API | [SKILL.md](skills/mi-proyecto-api/SKILL.md) |

### Auto-invoke Skills
> ⚠️ CRÍTICO: Sin esto, los modelos tratan las skills como sugerencias

When performing these actions, ALWAYS invoke the corresponding skill FIRST:

| Action | Skill |
|--------|-------|
| Writing React components | `react-19` |
| App Router / Server Actions | `nextjs-15` |
| Creating/modifying API | `mi-proyecto-api` |
| Writing tests with pytest | `pytest` |
| Creating a PR | `mi-proyecto-pr` |

---

## Project Overview
[Descripción del proyecto, componentes, tech stack]

## Development Guidelines
[Comandos, convenciones de código, etc.]

## Commit & Pull Request Guidelines
[Formato de commits, proceso de PR]
```

---

## ⚡ Anatomía de una Skill

### Formato SKILL.md Completo

```markdown
---
name: nextjs-15
description: >
  Next.js 15 App Router patterns.
  Trigger: When working in Next.js App Router (app/), Server Components vs 
  Client Components, Server Actions, Route Handlers, caching/revalidation.
license: Apache-2.0
metadata:
  author: tu-nombre
  version: "1.0"
  scope: [root, ui]              # Dónde aplica: root, ui, api, sdk
  auto_invoke: "App Router / Server Actions"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch, WebSearch, Task
---

## When to Use
- Building pages with App Router
- Creating Server Actions
- Data fetching patterns

## Critical Patterns

[Las reglas más importantes que la IA DEBE conocer]

## Code Examples

```typescript
// Ejemplo mínimo y enfocado
```

## Commands

```bash
npm run dev
npm run build
```

## Resources
- **Templates**: See [assets/](assets/) for examples
- **Documentation**: See [references/](references/) for local docs
```

### Campos del Frontmatter

| Campo | Requerido | Descripción |
|-------|-----------|-------------|
| `name` | ✅ | Identificador (lowercase, guiones) |
| `description` | ✅ | Qué hace + cuándo triggerear |
| `license` | ✅ | Licencia del proyecto |
| `metadata.author` | ✅ | Autor |
| `metadata.version` | ✅ | Versión semántica como string |
| `metadata.scope` | ❌ | `[root]`, `[ui]`, `[api]`, etc. |
| `metadata.auto_invoke` | ❌ | Keywords para auto-invocación |
| `allowed-tools` | ❌ | Herramientas permitidas |

### Estructura de Skills Complejas

```
📁 skills/mi-skill-compleja/
├── 📄 SKILL.md              # Archivo principal (requerido)
├── 📁 assets/               # Opcional
│   ├── template.py          # Templates de código
│   ├── schema.json          # Esquemas
│   └── example_config.yml   # Configuraciones ejemplo
└── 📁 references/           # Opcional
    └── docs.md              # Links a documentación LOCAL
```

---

## 🤖 Subagentes (Orquestador)

### Funcionamiento
```
┌─────────────────────┐
│    ORQUESTADOR      │ ← Contexto principal + decide qué subagentes crear
│     (Agente)        │
└──────────┬──────────┘
           │ Genera N subagentes
     ┌─────┴─────┬─────────────┐
     ▼           ▼             ▼
┌─────────┐  ┌─────────┐  ┌─────────┐
│   SA1   │  │   SA2   │  │   SA3   │  ← Contexto independiente cada uno
│ Task A  │  │ Task B  │  │ Task C  │
└────┬────┘  └────┬────┘  └────┬────┘
     │            │            │
     └────────────┴────────────┘
                  │
                  ▼ Devuelven SOLO un resumen
          ┌─────────────────────┐
          │     ORQUESTADOR     │ ← No se "ensucia" con todo el trabajo
          └─────────────────────┘
```

### Ventajas
- Tareas en **paralelo** (editar 500 archivos)
- El contexto del orquestador **no se contamina**
- Solo recibe **resúmenes** de lo que hicieron los subagentes

---

## 🔧 Script de Setup Multi-Plataforma

### Soporte de Herramientas

| Herramienta | Carpeta | Archivo MD | Skills Nativas |
|-------------|---------|------------|----------------|
| Claude Code | `.claude/` | `CLAUDE.md` | ✅ Symlink |
| Gemini CLI | `.gemini/` | `GEMINI.md` | ✅ Symlink |
| Codex (OpenAI) | `.codex/` | `AGENTS.md` (nativo) | ✅ Symlink |
| GitHub Copilot | `.github/` | `copilot-instructions.md` | ❌ Solo archivo |

### setup.sh Simplificado

```bash
#!/bin/bash
# skills/setup.sh - Configura skills para todos los AI assistants

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Funciones de setup
setup_claude() {
    mkdir -p "$REPO_ROOT/.claude"
    ln -sf "$SCRIPT_DIR" "$REPO_ROOT/.claude/skills"
    cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.claude/CLAUDE.md"
    echo "✓ Claude configurado"
}

setup_gemini() {
    mkdir -p "$REPO_ROOT/.gemini"
    ln -sf "$SCRIPT_DIR" "$REPO_ROOT/.gemini/skills"
    cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.gemini/GEMINI.md"
    echo "✓ Gemini configurado"
}

setup_codex() {
    mkdir -p "$REPO_ROOT/.codex"
    ln -sf "$SCRIPT_DIR" "$REPO_ROOT/.codex/skills"
    echo "✓ Codex configurado (usa AGENTS.md nativo)"
}

setup_copilot() {
    mkdir -p "$REPO_ROOT/.github"
    cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.github/copilot-instructions.md"
    echo "✓ GitHub Copilot configurado"
}

# Ejecutar todas
setup_claude
setup_gemini
setup_codex
setup_copilot

echo "✅ Skills configuradas para todos los AI assistants"
```

---

## �️ Configuración de Permisos (Gentleman.Dots)

### settings.json para Claude

```json
{
  "permissions": {
    "deny": [
      "Read(.env)",
      "Read(.env.*)",
      "Read(**/secrets/**)",
      "Read(**/credentials.json)"
    ],
    "ask": [
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(git push --force:*)",
      "Bash(git reset --hard:*)"
    ],
    "allow": [
      "Read", "Edit", "Write", "Glob", "Grep",
      "Bash(git status:*)", "Bash(git diff:*)", "Bash(git add:*)",
      "Bash(npm:*)", "Bash(npx:*)", "Bash(pnpm:*)",
      "Bash(python:*)", "Bash(pip:*)",
      "Bash(docker:*)", "Bash(gh:*)",
      "WebFetch", "WebSearch"
    ]
  }
}
```

---

## 💡 Mejores Prácticas

### DO ✅
- Empezar con los patrones más críticos
- Usar tablas para decision trees
- Mantener ejemplos de código mínimos y enfocados
- Incluir sección Commands con comandos copy-paste
- Usar `scope` para categorizar skills
- Forzar auto-invocación con tabla explícita

### DON'T ❌
- Agregar sección Keywords (el agente busca en frontmatter, no en body)
- Duplicar contenido de docs existentes (referenciar en su lugar)
- Incluir explicaciones largas (linkear a docs)
- Agregar troubleshooting (mantener enfocado)
- Usar URLs web en references (usar paths locales)
- Confiar en que el agente cargue skills automáticamente

---

## 📊 Skills Disponibles (Prowler - Referencia)

### Genéricas (Cualquier Proyecto)
| Skill | Descripción |
|-------|-------------|
| `typescript` | Const types, flat interfaces, utility types |
| `react-19` | No useMemo/useCallback, React Compiler |
| `nextjs-15` | App Router, Server Actions, streaming |
| `tailwind-4` | cn() utility, no var() en className |
| `playwright` | Page Object Model, MCP workflow, selectors |
| `pytest` | Fixtures, mocking, markers, parametrize |
| `django-drf` | ViewSets, Serializers, Filters |
| `zod-4` | New API (z.email(), z.uuid()) |
| `zustand-5` | Persist, selectors, slices |
| `ai-sdk-5` | UIMessage, streaming, LangChain |

### Específicas del Proyecto
| Skill | Descripción |
|-------|-------------|
| `prowler` | Project overview, component navigation |
| `prowler-api` | Django + RLS + JSON:API patterns |
| `prowler-ui` | Next.js + shadcn conventions |
| `prowler-test-*` | Testing para cada componente |
| `prowler-compliance` | Compliance framework structure |
| `prowler-pr` | Pull request conventions |
| `skill-creator` | Create new AI agent skills |

---

## 🎯 Resumen Ejecutivo

| Concepto | Propósito |
|----------|-----------|
| **AGENTS.md** | Contexto cultural + lista de skills + auto-invoke |
| **Skills** | Instrucciones específicas cargadas bajo demanda |
| **Scopes** | Definir dónde aplica cada skill (root, ui, api) |
| **Auto-invoke table** | ⚠️ OBLIGATORIO para que funcionen las skills |
| **Subagentes** | Paralelizar tareas sin contaminar contexto |
| **setup.sh** | Sincronizar skills entre herramientas |

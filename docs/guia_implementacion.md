# 🚀 Guía de Implementación: Skills y AGENTS.md en Proyectos Existentes

Esta guía te llevará paso a paso para implementar el sistema de Skills y AGENTS.md en tus proyectos.

---

## 📋 Checklist Rápido

- [ ] **Paso 1**: Crear estructura de carpetas
- [ ] **Paso 2**: Crear AGENTS.md root
- [ ] **Paso 3**: Crear skills genéricas que uses frecuentemente
- [ ] **Paso 4**: Crear skills específicas de tu proyecto
- [ ] **Paso 5**: Configurar script de setup multi-herramienta
- [ ] **Paso 6**: (Opcional) Crear AGENTS.md por componente

---

## Paso 1: Crear Estructura de Carpetas

```powershell
# En la raíz de tu proyecto
mkdir skills
mkdir skills\skill-creator
mkdir .claude
mkdir .gemini
mkdir .github
```

### Estructura Final Esperada
```
📁 tu-proyecto/
├── 📄 AGENTS.md
├── 📁 skills/
│   ├── 📄 setup.sh
│   ├── 📁 skill-creator/
│   │   └── 📄 SKILL.md
│   ├── 📁 [tus-skills]/
│   │   └── 📄 SKILL.md
├── 📁 .claude/
├── 📁 .gemini/
└── 📁 .github/
```

---

## Paso 2: Crear AGENTS.md Root

Crea `AGENTS.md` en la raíz de tu proyecto:

```markdown
# [Nombre del Proyecto] - Repository Guidelines

## How to Use This Guide
- Start here for cross-project norms
- Each component may have its own `AGENTS.md` with specific guidelines
- Component docs override this file when guidance conflicts

---

## Available Skills

### Generic Skills
| Skill | Description | URL |
|-------|-------------|-----|
| `skill-creator` | Create new AI agent skills | [SKILL.md](skills/skill-creator/SKILL.md) |

### Project-Specific Skills
| Skill | Description | URL |
|-------|-------------|-----|
<!-- Agregar aquí tus skills específicas -->

---

### Auto-invoke Skills

> ⚠️ **CRÍTICO**: Sin esta tabla, los modelos tratan las skills como sugerencias

When performing these actions, ALWAYS invoke the corresponding skill FIRST:

| Action | Skill |
|--------|-------|
| Creating new skills | `skill-creator` |
<!-- Agregar aquí más acciones y skills -->

---

## Project Overview

[Descripción breve del proyecto]

### Tech Stack
| Component | Technology |
|-----------|------------|
| Frontend | [Tu stack] |
| Backend | [Tu stack] |
| Database | [Tu stack] |

### Directory Structure
```
tu-proyecto/
├── src/          # Código fuente
├── tests/        # Tests
├── docs/         # Documentación
└── skills/       # AI Skills
```

---

## Development Guidelines

### Setup
```bash
# Comandos de instalación
npm install
```

### Code Quality
```bash
# Linting, formatting, tests
npm run lint
npm run test
```

---

## Commit & Pull Request Guidelines

Follow conventional-commit style: `<type>[scope]: <description>`

**Types:** `feat`, `fix`, `docs`, `chore`, `perf`, `refactor`, `style`, `test`
```

---

## Paso 3: Crear Skill Creator (Meta-Skill)

Crea `skills/skill-creator/SKILL.md`:

```markdown
---
name: skill-creator
description: >
  Creates new AI agent skills.
  Trigger: When user asks to create a new skill, add agent instructions, or document patterns for AI.
license: MIT
metadata:
  author: [tu-nombre]
  version: "1.0"
  scope: [root]
  auto_invoke: "Creating new skills"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## Skill Structure

```
skills/{skill-name}/
├── SKILL.md              # Required
├── assets/               # Optional - templates, examples
└── references/           # Optional - links to local docs
```

## SKILL.md Template

```markdown
---
name: {skill-name}
description: >
  {Description}.
  Trigger: {When to use}.
license: MIT
metadata:
  author: [tu-nombre]
  version: "1.0"
  scope: [root, ui, api]
  auto_invoke: "{keywords}"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use
- [Cuándo usar esta skill]

## Critical Patterns
[Reglas importantes]

## Code Examples
```code
[Ejemplos mínimos]
```

## Commands
```bash
[Comandos comunes]
```
```

## Checklist
- [ ] Skill name follows conventions (lowercase, hyphens)
- [ ] Description includes trigger keywords
- [ ] Added to AGENTS.md Available Skills table
- [ ] Added to AGENTS.md Auto-invoke table
```

---

## Paso 4: Crear Skills Específicas

### Ejemplo: Skill para tu Frontend

Crea `skills/mi-proyecto-ui/SKILL.md`:

```markdown
---
name: mi-proyecto-ui
description: >
  UI patterns and conventions for [Mi Proyecto].
  Trigger: When creating/modifying React components, pages, or UI elements.
license: MIT
metadata:
  author: [tu-nombre]
  version: "1.0"
  scope: [ui]
  auto_invoke: "React components / UI"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## Directory Structure

```
src/
├── components/
│   ├── ui/           # Componentes reutilizables
│   └── features/     # Componentes de features
├── pages/            # Páginas
├── hooks/            # Custom hooks
└── lib/              # Utilidades
```

## Component Pattern

```tsx
// components/ui/Button.tsx
interface ButtonProps {
  variant?: 'primary' | 'secondary';
  children: React.ReactNode;
}

export function Button({ variant = 'primary', children }: ButtonProps) {
  return (
    <button className={`btn btn-${variant}`}>
      {children}
    </button>
  );
}
```

## Naming Conventions
- Components: PascalCase (`MyComponent.tsx`)
- Hooks: camelCase con `use` prefix (`useMyHook.ts`)
- Utils: camelCase (`myUtil.ts`)

## Commands

```bash
npm run dev
npm run build
npm run test
```
```

### Ejemplo: Skill para Testing

Crea `skills/mi-proyecto-tests/SKILL.md`:

```markdown
---
name: mi-proyecto-tests
description: >
  Testing patterns for [Mi Proyecto].
  Trigger: When writing tests, creating test files, or debugging test failures.
license: MIT
metadata:
  author: [tu-nombre]
  version: "1.0"
  scope: [root]
  auto_invoke: "Writing tests"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## Test File Location
- Unit tests: junto al archivo (`MyComponent.test.tsx`)
- E2E tests: `tests/e2e/`

## Test Pattern

```typescript
import { describe, it, expect } from 'vitest';

describe('MyComponent', () => {
  it('should render correctly', () => {
    // Arrange
    const props = { title: 'Test' };
    
    // Act
    const result = render(<MyComponent {...props} />);
    
    // Assert
    expect(result).toMatchSnapshot();
  });
});
```

## Commands

```bash
npm run test           # Run all tests
npm run test:watch     # Watch mode
npm run test:coverage  # Coverage report
```
```

---

## Paso 5: Crear Script de Setup

Crea `skills/setup.sh`:

```bash
#!/bin/bash
# skills/setup.sh - Configura skills para todos los AI assistants

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🤖 Configurando AI Skills..."
echo "============================"

# Claude Code
setup_claude() {
    echo "Configurando Claude..."
    mkdir -p "$REPO_ROOT/.claude"
    
    # Crear symlink a skills (eliminar si existe)
    rm -rf "$REPO_ROOT/.claude/skills" 2>/dev/null || true
    ln -sf "$SCRIPT_DIR" "$REPO_ROOT/.claude/skills"
    
    # Copiar AGENTS.md como CLAUDE.md
    cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.claude/CLAUDE.md"
    echo "  ✓ .claude/skills -> skills/"
    echo "  ✓ AGENTS.md -> .claude/CLAUDE.md"
}

# Gemini CLI
setup_gemini() {
    echo "Configurando Gemini..."
    mkdir -p "$REPO_ROOT/.gemini"
    
    rm -rf "$REPO_ROOT/.gemini/skills" 2>/dev/null || true
    ln -sf "$SCRIPT_DIR" "$REPO_ROOT/.gemini/skills"
    
    cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.gemini/GEMINI.md"
    echo "  ✓ .gemini/skills -> skills/"
    echo "  ✓ AGENTS.md -> .gemini/GEMINI.md"
}

# Codex (OpenAI)
setup_codex() {
    echo "Configurando Codex..."
    mkdir -p "$REPO_ROOT/.codex"
    
    rm -rf "$REPO_ROOT/.codex/skills" 2>/dev/null || true
    ln -sf "$SCRIPT_DIR" "$REPO_ROOT/.codex/skills"
    echo "  ✓ .codex/skills -> skills/"
    echo "  ✓ Codex usa AGENTS.md nativo"
}

# GitHub Copilot
setup_copilot() {
    echo "Configurando GitHub Copilot..."
    mkdir -p "$REPO_ROOT/.github"
    
    cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.github/copilot-instructions.md"
    echo "  ✓ AGENTS.md -> .github/copilot-instructions.md"
}

# Ejecutar todos
setup_claude
setup_gemini
setup_codex
setup_copilot

SKILL_COUNT=$(find "$SCRIPT_DIR" -maxdepth 2 -name "SKILL.md" | wc -l)
echo ""
echo "✅ $SKILL_COUNT skills configuradas para todos los AI assistants!"
echo ""
echo "Nota: Reinicia tu AI assistant para cargar las skills."
```

### Para Windows (PowerShell)

Crea `skills/setup.ps1`:

```powershell
# skills/setup.ps1 - Configura skills para AI assistants (Windows)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

Write-Host "🤖 Configurando AI Skills..." -ForegroundColor Cyan
Write-Host "============================"

# Claude Code
function Setup-Claude {
    Write-Host "Configurando Claude..." -ForegroundColor Yellow
    $claudeDir = Join-Path $RepoRoot ".claude"
    New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
    
    # Copiar skills (en Windows usamos junction o copia)
    $skillsTarget = Join-Path $claudeDir "skills"
    if (Test-Path $skillsTarget) { Remove-Item -Recurse -Force $skillsTarget }
    Copy-Item -Recurse $ScriptDir $skillsTarget
    
    # Copiar AGENTS.md
    Copy-Item (Join-Path $RepoRoot "AGENTS.md") (Join-Path $claudeDir "CLAUDE.md")
    Write-Host "  ✓ Claude configurado" -ForegroundColor Green
}

# Gemini CLI
function Setup-Gemini {
    Write-Host "Configurando Gemini..." -ForegroundColor Yellow
    $geminiDir = Join-Path $RepoRoot ".gemini"
    New-Item -ItemType Directory -Force -Path $geminiDir | Out-Null
    
    $skillsTarget = Join-Path $geminiDir "skills"
    if (Test-Path $skillsTarget) { Remove-Item -Recurse -Force $skillsTarget }
    Copy-Item -Recurse $ScriptDir $skillsTarget
    
    Copy-Item (Join-Path $RepoRoot "AGENTS.md") (Join-Path $geminiDir "GEMINI.md")
    Write-Host "  ✓ Gemini configurado" -ForegroundColor Green
}

# GitHub Copilot
function Setup-Copilot {
    Write-Host "Configurando GitHub Copilot..." -ForegroundColor Yellow
    $githubDir = Join-Path $RepoRoot ".github"
    New-Item -ItemType Directory -Force -Path $githubDir | Out-Null
    
    Copy-Item (Join-Path $RepoRoot "AGENTS.md") (Join-Path $githubDir "copilot-instructions.md")
    Write-Host "  ✓ GitHub Copilot configurado" -ForegroundColor Green
}

# Ejecutar
Setup-Claude
Setup-Gemini
Setup-Copilot

$skillCount = (Get-ChildItem -Path $ScriptDir -Recurse -Filter "SKILL.md").Count
Write-Host ""
Write-Host "✅ $skillCount skills configuradas!" -ForegroundColor Green
Write-Host "Nota: Reinicia tu AI assistant para cargar las skills." -ForegroundColor Cyan
```

---

## Paso 6: (Opcional) AGENTS.md por Componente

Si tienes un monorepo, crea AGENTS.md específicos:

### `frontend/AGENTS.md`
```markdown
# Frontend Guidelines

## Available Skills
| Skill | Description | URL |
|-------|-------------|-----|
| `mi-proyecto-ui` | React components | [SKILL.md](../skills/mi-proyecto-ui/SKILL.md) |

### Auto-invoke Skills
| Action | Skill |
|--------|-------|
| Creating React components | `mi-proyecto-ui` |

## Tech Stack
- React 18
- TypeScript
- Tailwind CSS

## Directory Structure
[...]
```

### `backend/AGENTS.md`
```markdown
# Backend Guidelines

## Available Skills
| Skill | Description | URL |
|-------|-------------|-----|
| `mi-proyecto-api` | API patterns | [SKILL.md](../skills/mi-proyecto-api/SKILL.md) |

### Auto-invoke Skills
| Action | Skill |
|--------|-------|
| Creating endpoints | `mi-proyecto-api` |

## Tech Stack
- Node.js
- Express/Fastify
- PostgreSQL

## Directory Structure
[...]
```

---

## 🔄 Flujo de Trabajo Diario

### Cuando necesites crear una nueva skill:

1. Decirle al agente: "Lee la skill `skill-creator` y crea una nueva skill para [X]"
2. El agente creará la estructura correcta
3. Recordar agregar la skill a AGENTS.md (tabla Available Skills + Auto-invoke)
4. Ejecutar `./skills/setup.sh` para sincronizar

### Cuando agregues una skill:

```markdown
<!-- En AGENTS.md, agregar a Available Skills -->
| `nueva-skill` | Descripción | [SKILL.md](skills/nueva-skill/SKILL.md) |

<!-- Y agregar a Auto-invoke -->
| Action relacionada | `nueva-skill` |
```

---

## ✅ Verificación Final

Después de implementar, verifica:

1. [ ] `AGENTS.md` existe en la raíz
2. [ ] `skills/` tiene al menos `skill-creator/SKILL.md`
3. [ ] Tabla **Auto-invoke** tiene entradas
4. [ ] `setup.sh` corre sin errores
5. [ ] `.claude/`, `.gemini/`, `.github/` se crearon correctamente

### Test Rápido

Preguntarle al agente:
> "¿Qué skills tienes disponibles para este proyecto?"

Debería listar las skills de tu AGENTS.md.

---

## 📚 Recursos

- [Agent Skills Spec](https://agentskills.io)
- [Prowler Cloud (Ejemplo)](https://github.com/prowler-cloud/prowler)
- [Gentleman.Dots (Configs)](https://github.com/Gentleman-Programming/Gentleman.Dots)

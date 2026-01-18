# 🚀 Implementation Guide: Skills and AGENTS.md in Existing Projects

This guide will walk you step by step to implement the Skills and AGENTS.md system in your projects.

---

## 📋 Quick Checklist

- [ ] **Step 1**: Create folder structure
- [ ] **Step 2**: Create root AGENTS.md
- [ ] **Step 3**: Create generic skills you use frequently
- [ ] **Step 4**: Create project-specific skills
- [ ] **Step 5**: Configure multi-tool setup script
- [ ] **Step 6**: (Optional) Create AGENTS.md per component

---

## Step 1: Create Folder Structure

```powershell
# In your project root
mkdir skills
mkdir skills\skill-creator
mkdir .claude
mkdir .gemini
mkdir .github
```

### Expected Final Structure
```
📁 your-project/
├── 📄 AGENTS.md
├── 📁 skills/
│   ├── 📄 setup.sh
│   ├── 📁 skill-creator/
│   │   └── 📄 SKILL.md
│   ├── 📁 [your-skills]/
│   │   └── 📄 SKILL.md
├── 📁 .claude/
├── 📁 .gemini/
└── 📁 .github/
```

---

## Step 2: Create Root AGENTS.md

Create `AGENTS.md` in your project root:

```markdown
# [Project Name] - Repository Guidelines

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
<!-- Add your specific skills here -->

---

### Auto-invoke Skills

> ⚠️ **CRITICAL**: Without this table, models treat skills as suggestions

When performing these actions, ALWAYS invoke the corresponding skill FIRST:

| Action | Skill |
|--------|-------|
| Creating new skills | `skill-creator` |
<!-- Add more actions and skills here -->

---

## Project Overview

[Brief project description]

### Tech Stack
| Component | Technology |
|-----------|------------|
| Frontend | [Your stack] |
| Backend | [Your stack] |
| Database | [Your stack] |

### Directory Structure
```
your-project/
├── src/          # Source code
├── tests/        # Tests
├── docs/         # Documentation
└── skills/       # AI Skills
```

---

## Development Guidelines

### Setup
```bash
# Installation commands
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

## Step 3: Create Skill Creator (Meta-Skill)

Create `skills/skill-creator/SKILL.md`:

```markdown
---
name: skill-creator
description: >
  Creates new AI agent skills.
  Trigger: When user asks to create a new skill, add agent instructions, or document patterns for AI.
license: MIT
metadata:
  author: [your-name]
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
  author: [your-name]
  version: "1.0"
  scope: [root, ui, api]
  auto_invoke: "{keywords}"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use
- [When to use this skill]

## Critical Patterns
[Important rules]

## Code Examples
```code
[Minimal examples]
```

## Commands
```bash
[Common commands]
```
```

## Checklist
- [ ] Skill name follows conventions (lowercase, hyphens)
- [ ] Description includes trigger keywords
- [ ] Added to AGENTS.md Available Skills table
- [ ] Added to AGENTS.md Auto-invoke table
```

---

## Step 4: Create Specific Skills

### Example: Skill for your Frontend

Create `skills/my-project-ui/SKILL.md`:

```markdown
---
name: my-project-ui
description: >
  UI patterns and conventions for [My Project].
  Trigger: When creating/modifying React components, pages, or UI elements.
license: MIT
metadata:
  author: [your-name]
  version: "1.0"
  scope: [ui]
  auto_invoke: "React components / UI"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## Directory Structure

```
src/
├── components/
│   ├── ui/           # Reusable components
│   └── features/     # Feature components
├── pages/            # Pages
├── hooks/            # Custom hooks
└── lib/              # Utilities
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
- Hooks: camelCase with `use` prefix (`useMyHook.ts`)
- Utils: camelCase (`myUtil.ts`)

## Commands

```bash
npm run dev
npm run build
npm run test
```
```

### Example: Skill for Testing

Create `skills/my-project-tests/SKILL.md`:

```markdown
---
name: my-project-tests
description: >
  Testing patterns for [My Project].
  Trigger: When writing tests, creating test files, or debugging test failures.
license: MIT
metadata:
  author: [your-name]
  version: "1.0"
  scope: [root]
  auto_invoke: "Writing tests"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## Test File Location
- Unit tests: alongside the file (`MyComponent.test.tsx`)
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

## Step 5: Create Setup Script

Create `skills/setup.sh`:

```bash
#!/bin/bash
# skills/setup.sh - Configure skills for all AI assistants

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🤖 Configuring AI Skills..."
echo "============================"

# Claude Code
setup_claude() {
    echo "Configuring Claude..."
    mkdir -p "$REPO_ROOT/.claude"
    
    # Create symlink to skills (remove if exists)
    rm -rf "$REPO_ROOT/.claude/skills" 2>/dev/null || true
    ln -sf "$SCRIPT_DIR" "$REPO_ROOT/.claude/skills"
    
    # Copy AGENTS.md as CLAUDE.md
    cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.claude/CLAUDE.md"
    echo "  ✓ .claude/skills -> skills/"
    echo "  ✓ AGENTS.md -> .claude/CLAUDE.md"
}

# Gemini CLI
setup_gemini() {
    echo "Configuring Gemini..."
    mkdir -p "$REPO_ROOT/.gemini"
    
    rm -rf "$REPO_ROOT/.gemini/skills" 2>/dev/null || true
    ln -sf "$SCRIPT_DIR" "$REPO_ROOT/.gemini/skills"
    
    cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.gemini/GEMINI.md"
    echo "  ✓ .gemini/skills -> skills/"
    echo "  ✓ AGENTS.md -> .gemini/GEMINI.md"
}

# Codex (OpenAI)
setup_codex() {
    echo "Configuring Codex..."
    mkdir -p "$REPO_ROOT/.codex"
    
    rm -rf "$REPO_ROOT/.codex/skills" 2>/dev/null || true
    ln -sf "$SCRIPT_DIR" "$REPO_ROOT/.codex/skills"
    echo "  ✓ .codex/skills -> skills/"
    echo "  ✓ Codex uses native AGENTS.md"
}

# GitHub Copilot
setup_copilot() {
    echo "Configuring GitHub Copilot..."
    mkdir -p "$REPO_ROOT/.github"
    
    cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.github/copilot-instructions.md"
    echo "  ✓ AGENTS.md -> .github/copilot-instructions.md"
}

# Run all
setup_claude
setup_gemini
setup_codex
setup_copilot

SKILL_COUNT=$(find "$SCRIPT_DIR" -maxdepth 2 -name "SKILL.md" | wc -l)
echo ""
echo "✅ $SKILL_COUNT skills configured for all AI assistants!"
echo ""
echo "Note: Restart your AI assistant to load the skills."
```

### For Windows (PowerShell)

Create `skills/setup.ps1`:

```powershell
# skills/setup.ps1 - Configure skills for AI assistants (Windows)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

Write-Host "🤖 Configuring AI Skills..." -ForegroundColor Cyan
Write-Host "============================"

# Claude Code
function Setup-Claude {
    Write-Host "Configuring Claude..." -ForegroundColor Yellow
    $claudeDir = Join-Path $RepoRoot ".claude"
    New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
    
    # Copy skills (on Windows we use junction or copy)
    $skillsTarget = Join-Path $claudeDir "skills"
    if (Test-Path $skillsTarget) { Remove-Item -Recurse -Force $skillsTarget }
    Copy-Item -Recurse $ScriptDir $skillsTarget
    
    # Copy AGENTS.md
    Copy-Item (Join-Path $RepoRoot "AGENTS.md") (Join-Path $claudeDir "CLAUDE.md")
    Write-Host "  ✓ Claude configured" -ForegroundColor Green
}

# Gemini CLI
function Setup-Gemini {
    Write-Host "Configuring Gemini..." -ForegroundColor Yellow
    $geminiDir = Join-Path $RepoRoot ".gemini"
    New-Item -ItemType Directory -Force -Path $geminiDir | Out-Null
    
    $skillsTarget = Join-Path $geminiDir "skills"
    if (Test-Path $skillsTarget) { Remove-Item -Recurse -Force $skillsTarget }
    Copy-Item -Recurse $ScriptDir $skillsTarget
    
    Copy-Item (Join-Path $RepoRoot "AGENTS.md") (Join-Path $geminiDir "GEMINI.md")
    Write-Host "  ✓ Gemini configured" -ForegroundColor Green
}

# GitHub Copilot
function Setup-Copilot {
    Write-Host "Configuring GitHub Copilot..." -ForegroundColor Yellow
    $githubDir = Join-Path $RepoRoot ".github"
    New-Item -ItemType Directory -Force -Path $githubDir | Out-Null
    
    Copy-Item (Join-Path $RepoRoot "AGENTS.md") (Join-Path $githubDir "copilot-instructions.md")
    Write-Host "  ✓ GitHub Copilot configured" -ForegroundColor Green
}

# Run
Setup-Claude
Setup-Gemini
Setup-Copilot

$skillCount = (Get-ChildItem -Path $ScriptDir -Recurse -Filter "SKILL.md").Count
Write-Host ""
Write-Host "✅ $skillCount skills configured!" -ForegroundColor Green
Write-Host "Note: Restart your AI assistant to load the skills." -ForegroundColor Cyan
```

---

## Step 6: (Optional) AGENTS.md per Component

If you have a monorepo, create specific AGENTS.md files:

### `frontend/AGENTS.md`
```markdown
# Frontend Guidelines

## Available Skills
| Skill | Description | URL |
|-------|-------------|-----|
| `my-project-ui` | React components | [SKILL.md](../skills/my-project-ui/SKILL.md) |

### Auto-invoke Skills
| Action | Skill |
|--------|-------|
| Creating React components | `my-project-ui` |

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
| `my-project-api` | API patterns | [SKILL.md](../skills/my-project-api/SKILL.md) |

### Auto-invoke Skills
| Action | Skill |
|--------|-------|
| Creating endpoints | `my-project-api` |

## Tech Stack
- Node.js
- Express/Fastify
- PostgreSQL

## Directory Structure
[...]
```

---

## 🔄 Daily Workflow

### When you need to create a new skill:

1. Tell the agent: "Read the `skill-creator` skill and create a new skill for [X]"
2. The agent will create the correct structure
3. Remember to add the skill to AGENTS.md (Available Skills + Auto-invoke tables)
4. Run `./skills/setup.sh` to sync

### When you add a skill:

```markdown
<!-- In AGENTS.md, add to Available Skills -->
| `new-skill` | Description | [SKILL.md](skills/new-skill/SKILL.md) |

<!-- And add to Auto-invoke -->
| Related action | `new-skill` |
```

---

## ✅ Final Verification

After implementing, verify:

1. [ ] `AGENTS.md` exists at root
2. [ ] `skills/` has at least `skill-creator/SKILL.md`
3. [ ] **Auto-invoke** table has entries
4. [ ] `setup.sh` runs without errors
5. [ ] `.claude/`, `.gemini/`, `.github/` were created correctly

### Quick Test

Ask the agent:
> "What skills do you have available for this project?"

It should list the skills from your AGENTS.md.

---

## 📚 Resources

- [Agent Skills Spec](https://agentskills.io)
- [Prowler Cloud (Example)](https://github.com/prowler-cloud/prowler)
- [Gentleman.Dots (Configs)](https://github.com/Gentleman-Programming/Gentleman.Dots)

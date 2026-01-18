# 🤖 Complete Guide: Skills and AGENTS.md System for AI

> **Sources**: [Prowler Cloud](https://github.com/prowler-cloud/prowler) | [Gentleman.Dots](https://github.com/Gentleman-Programming/Gentleman.Dots) | [Agent Skills Spec](https://agentskills.io)

---

## 📋 Fundamental Concepts

### What is AGENTS.md?
- Markdown file that **only AI agents should understand** (not the README for humans)
- Provides **project cultural context**: architecture, conventions, technologies
- Indicates **how the AI should behave** and what skills are available

### The Excessive Context Problem
> ⚠️ **The more context an agent has, the more it can hallucinate**

| Problem | Solution |
|---------|----------|
| AGENTS.md too large | Split into multiple files (250-500 lines max) |
| Too much context always loaded | Use Skills that load on demand |
| Models ignore skills | Force auto-invocation with explicit table |

---

## 🏗️ Real Architecture (Prowler)

### File Structure
```
📁 project/
├── 📄 AGENTS.md                    ← Main root file
├── 📁 skills/
│   ├── 📄 setup.sh                 ← Installs in all tools
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
│       ├── 📁 assets/              ← Templates, examples
│       └── 📁 references/          ← Links to local docs
├── 📁 api/
│   └── 📄 AGENTS.md                ← Specific for API
├── 📁 ui/
│   └── 📄 AGENTS.md                ← Specific for UI
├── 📁 .claude/
│   ├── 📄 CLAUDE.md                ← Copy of AGENTS.md
│   └── 📁 skills/ → symlink
├── 📁 .gemini/
│   ├── 📄 GEMINI.md
│   └── 📁 skills/ → symlink
├── 📁 .codex/
│   └── 📁 skills/ → symlink
└── 📁 .github/
    └── 📄 copilot-instructions.md  ← For GitHub Copilot
```

---

## 📄 AGENTS.md Structure

### Recommended Sections

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
| `my-project-api` | My API specific patterns | [SKILL.md](skills/my-project-api/SKILL.md) |

### Auto-invoke Skills
> ⚠️ CRITICAL: Without this, models treat skills as suggestions

When performing these actions, ALWAYS invoke the corresponding skill FIRST:

| Action | Skill |
|--------|-------|
| Writing React components | `react-19` |
| App Router / Server Actions | `nextjs-15` |
| Creating/modifying API | `my-project-api` |
| Writing tests with pytest | `pytest` |
| Creating a PR | `my-project-pr` |

---

## Project Overview
[Project description, components, tech stack]

## Development Guidelines
[Commands, code conventions, etc.]

## Commit & Pull Request Guidelines
[Commit format, PR process]
```

---

## ⚡ Anatomy of a Skill

### Complete SKILL.md Format

```markdown
---
name: nextjs-15
description: >
  Next.js 15 App Router patterns.
  Trigger: When working in Next.js App Router (app/), Server Components vs 
  Client Components, Server Actions, Route Handlers, caching/revalidation.
license: Apache-2.0
metadata:
  author: your-name
  version: "1.0"
  scope: [root, ui]              # Where it applies: root, ui, api, sdk
  auto_invoke: "App Router / Server Actions"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch, WebSearch, Task
---

## When to Use
- Building pages with App Router
- Creating Server Actions
- Data fetching patterns

## Critical Patterns

[The most important rules the AI MUST know]

## Code Examples

```typescript
// Minimal and focused example
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

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | ✅ | Identifier (lowercase, hyphens) |
| `description` | ✅ | What it does + when to trigger |
| `license` | ✅ | Project license |
| `metadata.author` | ✅ | Author |
| `metadata.version` | ✅ | Semantic version as string |
| `metadata.scope` | ❌ | `[root]`, `[ui]`, `[api]`, etc. |
| `metadata.auto_invoke` | ❌ | Keywords for auto-invocation |
| `allowed-tools` | ❌ | Allowed tools |

### Complex Skills Structure

```
📁 skills/my-complex-skill/
├── 📄 SKILL.md              # Main file (required)
├── 📁 assets/               # Optional
│   ├── template.py          # Code templates
│   ├── schema.json          # Schemas
│   └── example_config.yml   # Example configurations
└── 📁 references/           # Optional
    └── docs.md              # Links to LOCAL documentation
```

---

## 🤖 Subagents (Orchestrator)

### How It Works
```
┌─────────────────────┐
│    ORCHESTRATOR     │ ← Main context + decides what subagents to create
│      (Agent)        │
└──────────┬──────────┘
           │ Generates N subagents
     ┌─────┴─────┬─────────────┐
     ▼           ▼             ▼
┌─────────┐  ┌─────────┐  ┌─────────┐
│   SA1   │  │   SA2   │  │   SA3   │  ← Independent context each
│ Task A  │  │ Task B  │  │ Task C  │
└────┬────┘  └────┬────┘  └────┬────┘
     │            │            │
     └────────────┴────────────┘
                  │
                  ▼ Returns ONLY a summary
          ┌─────────────────────┐
          │     ORCHESTRATOR    │ ← Doesn't get "polluted" with all the work
          └─────────────────────┘
```

### Advantages
- Tasks run in **parallel** (edit 500 files)
- Orchestrator context **doesn't get contaminated**
- Only receives **summaries** of what subagents did

---

## 🔧 Multi-Platform Setup Script

### Tool Support

| Tool | Folder | MD File | Native Skills |
|------|--------|---------|---------------|
| Claude Code | `.claude/` | `CLAUDE.md` | ✅ Symlink |
| Gemini CLI | `.gemini/` | `GEMINI.md` | ✅ Symlink |
| Codex (OpenAI) | `.codex/` | `AGENTS.md` (native) | ✅ Symlink |
| GitHub Copilot | `.github/` | `copilot-instructions.md` | ❌ File only |

### Simplified setup.sh

```bash
#!/bin/bash
# skills/setup.sh - Configure skills for all AI assistants

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Setup functions
setup_claude() {
    mkdir -p "$REPO_ROOT/.claude"
    ln -sf "$SCRIPT_DIR" "$REPO_ROOT/.claude/skills"
    cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.claude/CLAUDE.md"
    echo "✓ Claude configured"
}

setup_gemini() {
    mkdir -p "$REPO_ROOT/.gemini"
    ln -sf "$SCRIPT_DIR" "$REPO_ROOT/.gemini/skills"
    cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.gemini/GEMINI.md"
    echo "✓ Gemini configured"
}

setup_codex() {
    mkdir -p "$REPO_ROOT/.codex"
    ln -sf "$SCRIPT_DIR" "$REPO_ROOT/.codex/skills"
    echo "✓ Codex configured (uses native AGENTS.md)"
}

setup_copilot() {
    mkdir -p "$REPO_ROOT/.github"
    cp "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/.github/copilot-instructions.md"
    echo "✓ GitHub Copilot configured"
}

# Run all
setup_claude
setup_gemini
setup_codex
setup_copilot

echo "✅ Skills configured for all AI assistants"
```

---

## 🛡️ Permission Configuration (Gentleman.Dots)

### settings.json for Claude

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

## 💡 Best Practices

### DO ✅
- Start with the most critical patterns
- Use tables for decision trees
- Keep code examples minimal and focused
- Include Commands section with copy-paste commands
- Use `scope` to categorize skills
- Force auto-invocation with explicit table

### DON'T ❌
- Add Keywords section (agent searches frontmatter, not body)
- Duplicate content from existing docs (reference instead)
- Include lengthy explanations (link to docs)
- Add troubleshooting (keep focused)
- Use web URLs in references (use local paths)
- Trust that the agent will load skills automatically

---

## 📊 Available Skills (Prowler - Reference)

### Generic (Any Project)
| Skill | Description |
|-------|-------------|
| `typescript` | Const types, flat interfaces, utility types |
| `react-19` | No useMemo/useCallback, React Compiler |
| `nextjs-15` | App Router, Server Actions, streaming |
| `tailwind-4` | cn() utility, no var() in className |
| `playwright` | Page Object Model, MCP workflow, selectors |
| `pytest` | Fixtures, mocking, markers, parametrize |
| `django-drf` | ViewSets, Serializers, Filters |
| `zod-4` | New API (z.email(), z.uuid()) |
| `zustand-5` | Persist, selectors, slices |
| `ai-sdk-5` | UIMessage, streaming, LangChain |

### Project-Specific
| Skill | Description |
|-------|-------------|
| `prowler` | Project overview, component navigation |
| `prowler-api` | Django + RLS + JSON:API patterns |
| `prowler-ui` | Next.js + shadcn conventions |
| `prowler-test-*` | Testing for each component |
| `prowler-compliance` | Compliance framework structure |
| `prowler-pr` | Pull request conventions |
| `skill-creator` | Create new AI agent skills |

---

## 🎯 Executive Summary

| Concept | Purpose |
|---------|---------|
| **AGENTS.md** | Cultural context + skill list + auto-invoke |
| **Skills** | Specific instructions loaded on demand |
| **Scopes** | Define where each skill applies (root, ui, api) |
| **Auto-invoke table** | ⚠️ MANDATORY for skills to work |
| **Subagents** | Parallelize tasks without contaminating context |
| **setup.sh** | Sync skills between tools |

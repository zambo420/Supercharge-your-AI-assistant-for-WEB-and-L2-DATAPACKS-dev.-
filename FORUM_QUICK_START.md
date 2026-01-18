# 🤖 AI Skills Starter Kit - Forum Quick Start

> **Supercharge your AI assistant (Claude, Gemini, Copilot)**

## ⚡ Installation in 2 Minutes

### 1. Download and copy

Copy the `Supercharge-your-AI-assistant-for-WEB-and-L2-DATAPACKS-dev.-/` folder to your project root.

### 2. Rename and structure

```
your-project/
├── skills/                      # Rename skills_reutilizables → skills
│   ├── skill-creator/
│   ├── react-19/               # Copy the ones you need
│   ├── typescript/
│   └── setup.ps1               # Copy from templates/
├── AGENTS.md                    # Copy from templates/AGENTS.md.template
└── src/                         # Your code
```

### 3. Edit AGENTS.md

Customize with your skills:

```markdown
## Available Skills

| Skill | Description | File |
|-------|-------------|------|
| `react-19` | React 19 patterns | [SKILL.md](skills/react-19/SKILL.md) |

## Auto-invoke Skills

| Action | Skill |
|--------|-------|
| Working with React components | `react-19` |
```

### 4. Sync

```powershell
.\skills\setup.ps1
```

### 5. Done!

Restart your AI assistant and start working.

---

## 📦 Included Skills (56 Total)

### Frontend
- `react-19` - React 19, hooks, RSC
- `typescript` - TypeScript patterns
- `tailwind-4` - TailwindCSS v4
- `vite` - Build configuration
- `zustand-5` - State management
- `nextjs-15` - Next.js 15
- `i18next` - Internationalization
- `react-router` - React Router v7

### Backend
- `zod-4` - Validation schemas
- `ioredis` - Redis caching
- `jwt` - JWT authentication
- `django-drf` - Django REST Framework

### Testing & AI
- `playwright` - E2E testing
- `pytest` - Python testing
- `ai-sdk-5` - Vercel AI SDK

### Utilities
- `skill-creator` - Create new skills
- `java-ant-build` - Apache Ant build system
- `jira-epic` - Create Jira epics
- `jira-task` - Create Jira tasks

### L2J/Game Server (33 skills)
- `gameserver-data` - XMLs, multisells, spawns, NPCs
- `gameserver-config` - Server configuration files
- `authserver-config` - Login server configuration
- `client-files` - Client textures, L2Text, system
- `lucera2-core` - L2J core patterns, base classes
- `lucera2-handlers` - Admin/user commands, bypass
- `lucera2-services` - Community Board, ACP, Buffer
- `lucera2-scripts` - Quests, NPCs, bosses, events
- `lucera2-network` - Network packets
- `lucera2-geodata` - Pathfinding, line of sight
- `lucera2-ai` - NPC AI, monster behavior
- `lucera2-zones` - Zone scripts, restrictions
- `lucera2-achievements` - Achievement system
- `lucera2-phantoms` - Fake players (bots)
- `lucera2-data` - XML/SQL parsers, holders
- `lucera2-authserver` - Login server Java code
- `lucera2-olympiad` - Olympiad, heroes, nobles
- `lucera2-residences` - Castles, clan halls, siege
- `lucera2-skills-effects` - Skill effects, conditions
- `lucera2-telegram` - Telegram bot integration
- `lucera2-events-pvp` - TvT, GvG, CTF events
- `lucera2-seasonal-events` - Holiday events
- `lucera2-npc-instances` - Custom NPC types
- `lucera2-items-inventory` - Items, inventory
- `lucera2-clans-alliances` - Clans, wars
- `lucera2-voting-ranking` - Voting rewards
- `lucera2-siege-duel` - Siege, duel mechanics
- `lucera2-pets-summons` - Pets, servitors
- `lucera2-promo-rewards` - Promo codes, daily rewards
- `lucera2-item-handlers` - Item handlers
- `lucera2-instances-dungeons` - Instance dungeons
- `lucera2-minigames` - Lottery, Fishing
- `lucera2-autofarm` - AutoFarm bot system
- `lucera2-party-matching` - Party finder
- `lucera2-cursed-weapons` - Zariche, Akamanah
- `lucera2-vip-premium` - VIP/premium accounts
- `lucera2-extjar-projects` - Creating .ext.jar projects

---

## 🎯 The Magic Trick

The **Auto-invoke** table is the key:

```markdown
## Auto-invoke Skills

| Action | Skill |
|--------|-------|
| Creating React components | `react-19` |
| Adding TypeScript types | `typescript` |
| Writing E2E tests | `playwright` |
```

**Without this table, AI ignores skills.** With it, they load automatically.

---

## 📁 Important Files

| File | Purpose |
|------|---------|
| `AGENTS.md` | Main agent configuration |
| `skills/setup.ps1` | Syncs to .claude/.gemini/.github |
| `skills/*/SKILL.md` | Each skill definition |

---

## 💡 Tips

1. **One place only**: Keep all skills in `skills/`
2. **Auto-invoke**: Without this table, it won't work
3. **setup.ps1**: Run after every change
4. **Restart**: AI needs restart to load changes

---

## 🔧 Create Your Own Skill

```markdown
---
name: my-skill
description: My skill description
---

## When to Use
- When to use this skill

## Key Patterns
- Important patterns

## Code Examples
\`\`\`typescript
// Code example
\`\`\`
```

Add to AGENTS.md and run `.\skills\setup.ps1`.

---

## 🤝 Compatibility

- ✅ Claude Code (Antigravity)
- ✅ Gemini CLI
- ✅ GitHub Copilot
- ✅ Cursor
- ✅ Any AI that supports AGENTS.md

---

## 📚 More Info

See `README.md` for complete guide and detailed documentation.

---

**Credits**: Based on [agentskills.io](https://agentskills.io)

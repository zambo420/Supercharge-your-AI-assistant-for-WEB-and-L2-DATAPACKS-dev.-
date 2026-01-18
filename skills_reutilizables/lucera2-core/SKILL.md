---
name: lucera2-core
description: >
  Core L2J/Lucera patterns, package structure, and base class inheritance.
  Trigger: When working with gameserver core, l2.gameserver packages, or extending base L2 classes.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [gameserver, core]
  auto_invoke: "L2J core, gameserver, base classes"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Working with `l2/gameserver/` packages
- Extending base classes (Player, NPC, GameObject, etc.)
- Understanding the server architecture
- Modifying core game mechanics

---

## Package Structure

```
l2/
├── gameserver/
│   ├── model/              # Game objects (Player, NPC, Item, etc.)
│   │   ├── Player.java
│   │   ├── instances/      # Instance types
│   │   ├── items/          # Item classes
│   │   └── quest/          # Quest-related classes
│   ├── network/            # Packet handling
│   │   ├── clientpackets/  # Client → Server
│   │   └── serverpackets/  # Server → Client
│   ├── data/               # Data parsers (XML, SQL)
│   ├── skills/             # Skill system
│   ├── handler/            # Internal handlers
│   ├── scripts/            # Script engine
│   └── Config.java         # Server configuration
├── authserver/             # Login server
└── commons/                # Shared utilities
```

---

## Critical Patterns

### Base Classes Hierarchy

```
GameObject
├── Creature
│   ├── Playable
│   │   ├── Player
│   │   └── Summon
│   └── NpcInstance
│       ├── MonsterInstance
│       ├── RaidBossInstance
│       └── MerchantInstance
└── ItemInstance
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Packets | Camel case with direction | `RequestAction`, `SystemMessage` |
| Models | PascalCase + Instance suffix | `NpcInstance`, `PlayerInstance` |
| Handlers | Action + Handler suffix | `ItemHandler`, `SkillHandler` |
| Config | UPPER_SNAKE_CASE | `MAX_PLAYERS`, `RATE_XP` |

---

## Common Operations

### Getting Player Reference

```java
// From event/handler context
Player player = ...;

// Player properties
int objectId = player.getObjectId();
String name = player.getName();
int level = player.getLevel();
```

### Sending Packets

```java
// Send system message
player.sendPacket(new SystemMessage(SystemMessageId.MESSAGE_ID));

// Send HTML to player
player.sendPacket(new NpcHtmlMessage(npcObjectId).setHtml(htmlContent));
```

### Working with Items

```java
// Check if player has item
boolean hasItem = player.getInventory().getItemByItemId(itemId) != null;

// Add item to player
player.getInventory().addItem("reason", itemId, count, player, null);

// Destroy item
player.getInventory().destroyItemByItemId("reason", itemId, count, player, null);
```

---

## Config Access

```java
// Access configuration values
import l2.gameserver.Config;

int maxPlayers = Config.MAXIMUM_ONLINE_USERS;
double xpRate = Config.RATE_XP;
boolean featureEnabled = Config.CUSTOM_FEATURE_ENABLED;
```

---

## Thread Safety

- Use `synchronized` blocks for shared state
- Prefer `ConcurrentHashMap` over `HashMap`
- Be careful with player collections during iteration

```java
// Safe iteration
List<Player> playersCopy = new ArrayList<>(World.getWorld().getAllPlayers());
for (Player player : playersCopy) {
    // Process player
}
```

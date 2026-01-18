---
name: gameserver-config
description: >
  Working with server configuration files: rates, features, PvP settings, etc.
  Trigger: When editing config files in gameserver/config/
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [gameserver, config, settings]
  auto_invoke: "server config, rates, pvp settings, feature toggle"
allowed-tools: Read, Edit, Write, Glob, Grep
---

## When to Use

- Editing server rates (XP, SP, Drop, Adena)
- Configuring PvP/PK settings
- Toggling features (Community Board, Olympiad, etc.)
- Network configuration
- Database settings

---

## Directory Structure

```
gameserver/config/
├── server.properties         # Main server config (network, database)
├── rates.properties          # XP, SP, drop rates
├── pvp.properties            # PvP and PK settings
├── feature.properties        # Feature toggles
├── olympiad.properties       # Olympiad settings
├── siege.properties          # Siege settings
├── clans.properties          # Clan settings
├── community.properties      # Community Board
├── services.properties       # Services (Buffer, Teleporter)
├── bosses.properties         # Boss spawn times
├── geodata.properties        # Geodata settings
└── log4j.xml                 # Logging configuration
```

---

## Common Configuration Files

### server.properties

```properties
# Server Network
gameserver.port = 7777
gameserver.host = 0.0.0.0

# Database
database.driver = com.mysql.jdbc.Driver
database.url = jdbc:mysql://localhost/l2jdb
database.user = root
database.password = password

# Server Info
server.name = L2Avalon
server.id = 1
```

### rates.properties

```properties
# Experience and SP
rate.xp = 50
rate.sp = 50

# Drop rates
rate.drop.items = 50
rate.drop.adena = 100
rate.drop.spoil = 50

# Quest rewards
rate.quest.reward.xp = 50
rate.quest.reward.sp = 50
rate.quest.reward.adena = 50
```

### pvp.properties

```properties
# PvP Settings
pvp.karma.min.increase = 100
pvp.karma.static.increase = -1
pvp.karma.decrease.rate = 1

# PK Settings  
pk.flag.timeout = 30

# Zone PvP
battle.zone.pvp.count = true
fun.zone.pvp.count = false
```

---

## Feature Toggles

### feature.properties

```properties
# Community Board
community.board.enabled = true
community.board.bbs.default = _bbshome

# Olympiad
olympiad.enabled = true
olympiad.start.time = 18:00

# Siege
siege.enabled = true
siege.start.day = 7 # Sunday

# Premium
premium.enabled = true

# AutoFarm
autofarm.enabled = true
autofarm.free = false
```

---

## Authserver Config

```
authserver/config/
├── authserver.properties     # Login server settings
├── banned_ip.cfg             # Banned IPs
└── database.properties       # Auth database
```

### authserver.properties

```properties
# Network
authserver.port = 2106
authserver.host = 0.0.0.0

# Security
auto.create.accounts = true
login.wrong.attemps = 3
ban.time = 600

# Connection
gameserver.connection.port = 9014
```

---

## Common Tasks

### Change XP/SP Rates

Edit `gameserver/config/rates.properties`:
```properties
rate.xp = 100
rate.sp = 100
```

### Enable/Disable Community Board

Edit `gameserver/config/feature.properties`:
```properties
community.board.enabled = true
```

### Configure PvP Karma

Edit `gameserver/config/pvp.properties`:
```properties
pvp.karma.static.increase = 500
```

### Change Server Port

Edit `gameserver/config/server.properties`:
```properties
gameserver.port = 7778
```

---

## Config Reload Commands

Some configs can be reloaded in-game without restart:

| Admin Command | Reloads |
|---------------|---------|
| `//reload configs` | Most configs |
| `//reload npc` | NPC data |
| `//reload spawn` | Spawn data |
| `//reload multisell` | Multisell data |
| `//reload skills` | Skill data |

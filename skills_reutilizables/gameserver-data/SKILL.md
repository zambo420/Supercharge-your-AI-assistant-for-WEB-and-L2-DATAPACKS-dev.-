---
name: gameserver-data
description: >
  Working with server data files: XMLs, multisells, spawns, NPCs, zones, instances.
  Trigger: When editing game data files in gameserver/data/
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [gameserver, data, xml]
  auto_invoke: "multisell, spawn, npc xml, zone xml, instance xml, html dialog"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Editing NPC definitions (npc/*.xml)
- Creating/editing multisell lists (multisell/*.xml)
- Configuring spawn points (spawn/*.xml)
- Editing zone definitions (zone/*.xml)
- Creating instance definitions (instances/*.xml)
- Editing NPC dialogs and Community Board HTML

---

## Directory Structure

```
gameserver/data/
├── html-en/                     # NPC dialogs and Community Board
│   ├── admin/                   # Admin command dialogs
│   ├── default/                 # Default NPC dialogs by ID
│   └── scripts/services/community/  # Community Board pages
├── multisell/                   # Shop item lists
├── npc/                         # NPC/monster definitions
├── spawn/                       # Spawn locations
├── zone/                        # Zone definitions (battle, peace, etc.)
├── instances/                   # Instance definitions
├── stats/                       # Item/weapon/armor stats
├── skills/                      # Skill definitions
└── items/                       # Item templates
```

---

## NPC Definition Format

```xml
<list xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="npc.xsd">
    <npc id="30001" type="L2Npc" name="Trader" title="Weapons Dealer">
        <set name="level" val="70"/>
        <set name="hp" val="2444"/>
        <set name="mp" val="1345"/>
        <set name="radius" val="11"/>
        <set name="height" val="23"/>
    </npc>
</list>
```

---

## Multisell Format

```xml
<list>
    <item id="1">
        <ingredient id="57" count="1000000"/>  <!-- Adena -->
        <production id="6656" count="1"/>      <!-- Output item -->
    </item>
</list>
```

Negative IDs (-1001, -1002) are used for Community Board multisells.

---

## Spawn Format

```xml
<list>
    <spawn name="Giran Guards">
        <group>
            <npc id="30001" max="1" type="L2Npc">
                <territory>
                    <add loc="82968;148609;-3464"/>
                </territory>
            </npc>
        </group>
    </spawn>
</list>
```

---

## Zone Format

```xml
<zone name="[zone_name]" type="battle_zone">
    <set name="default" val="false"/>
    <polygon>
        <coords loc="x1 y1 zmin zmax"/>
        <coords loc="x2 y2 zmin zmax"/>
        <coords loc="x3 y3 zmin zmax"/>
        <coords loc="x4 y4 zmin zmax"/>
    </polygon>
</zone>
```

### Zone Types

| Type | Purpose |
|------|---------|
| `peace_zone` | No PvP allowed |
| `battle_zone` | Attack without Ctrl |
| `no_landing_zone` | Wyvern cannot land |
| `jail` | Jail area |
| `siege` | Siege area |
| `water` | Swimming zone |
| `fun` | Fun/arena zone |

---

## Instance Definition

```xml
<instance id="900" name="Instance Name" maxChannels="1" collapseIfEmpty="5" timelimit="60">
    <geodata map="17_21"/>
    <level min="1" max="85"/>
    <return loc="x y z"/>
    <teleport loc="x y z"/>
    <zones>
        <zone name="[zone_name]" active="true"/>
    </zones>
    <spawns>
        <spawn mobId="12345" count="1" type="L2Npc">
            <coords loc="x y z"/>
        </spawn>
    </spawns>
</instance>
```

---

## HTML Dialog Format

NPC dialogs use a special L2 HTML format:

```html
<html><body>
<title>NPC Name</title>
<center><br>

Welcome message!<br><br>

<button value="Option 1" action="bypass -h npc_%objectId%_Action1" width=200 height=25>
<button value="Option 2" action="bypass -h npc_%objectId%_Action2" width=200 height=25>

</center>
</body></html>
```

### Variable Substitutions

| Variable | Description |
|----------|-------------|
| `%objectId%` | NPC object ID |
| `%player_name%` | Player name |
| `%player_level%` | Player level |

---

## Common Tasks

### Add New NPC

1. Create XML in `data/npc/yourfile.xml`
2. Add spawn in `data/spawn/yourfile.xml`
3. Create dialog in `data/html-en/default/NPCID.htm`

### Create New Zone

1. Add zone to `data/zone/battle_zone.xml` (or appropriate file)
2. Define polygon coordinates
3. Reference in instance XML if needed

### Create Multisell Shop

1. Add multisell file in `data/multisell/`
2. Use negative ID for Community Board access
3. Reference via `bypass _bbsmultisell:-ID`

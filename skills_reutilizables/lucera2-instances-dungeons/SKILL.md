---
name: lucera2-instances-dungeons
description: >
  Instance dungeons: reflections, boss instances, private dungeons.
  Trigger: When working with instance dungeons, reflections, or boss instances.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [instances, dungeons]
  auto_invoke: "instance, dungeon, reflection, Frintezza, Kamaloka"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating instance dungeons
- Working with reflections (private instances)
- Implementing boss instances
- Managing instance entry/exit

---

## Directory Structure

```
instances/                           # Instance scripts (20 files)
├── Frintezza.java                   # Frintezza dungeon (35KB)
├── GvGInstance.java                 # GvG battle instance
└── ...

l2/gameserver/model/entity/
└── Reflection.java                  # Reflection (instance) class (29KB)

l2/gameserver/templates/
└── InstantZone.java                 # Instance zone template (20KB)

l2/gameserver/instancemanager/
└── ReflectionManager.java           # Reflection management

l2/gameserver/data/xml/holder/
└── InstantZoneHolder.java           # Instance data holder
```

---

## Reflection (Instance) System

```java
// Create a new instance
Reflection ref = new Reflection();
ref.setName("My Dungeon");
ref.setInstancedZoneId(instantZoneId);

// Register and start
ReflectionManager.getInstance().add(ref);

// Teleport player into instance
player.setReflection(ref);
player.teleToLocation(ref.getTeleportLoc());
```

---

## Instance Script Pattern

```java
package instances;

import l2.gameserver.model.entity.Reflection;
import l2.gameserver.model.Player;
import l2.gameserver.scripts.ScriptFile;

public class MyInstance extends Reflection implements ScriptFile {
    
    private static final int INSTANCE_ID = 123;
    
    public MyInstance() {
        super();
    }
    
    @Override
    public void onPlayerEnter(Player player) {
        super.onPlayerEnter(player);
        
        // Setup for player
        player.sendMessage("Welcome to the dungeon!");
        
        // Start instance timer
        startCollapseTimer(3600000); // 1 hour
    }
    
    @Override
    public void onPlayerExit(Player player) {
        super.onPlayerExit(player);
        
        // Check if empty
        if (getPlayers().isEmpty()) {
            collapse();
        }
    }
    
    public void spawnBoss() {
        // Spawn boss NPC
        NpcInstance boss = addSpawnWithoutRespawn(BOSS_NPC_ID, BOSS_LOC, 0);
        boss.addListener(new BossDeathListener());
    }
    
    private class BossDeathListener implements OnDeathListener {
        @Override
        public void onDeath(Creature actor, Creature killer) {
            // Boss killed, spawn rewards
            spawnRewardChest();
            startCollapseTimer(300000); // 5 min to exit
        }
    }
}
```

---

## Instance Entry

```java
// Check entry conditions
InstantZone iz = InstantZoneHolder.getInstance().getInstantZone(instanceId);
if (iz.canEnter(player)) {
    // Create or get existing instance
    Reflection ref = player.getActiveReflection();
    if (ref == null) {
        ref = new MyInstance();
        ref.init(iz);
        player.setReflection(ref);
    }
    
    // Teleport player
    player.teleToLocation(iz.getTeleportCoord(), ref);
}
```

---

## Instance Collapse

```java
// Set collapse timer
ref.startCollapseTimer(timeMs);

// Manual collapse
ref.collapse();

// Collapse with message
ref.announceToPlayers("Instance will collapse in 5 minutes!");
ref.startCollapseTimer(300000);
```

---

## Instance Spawning

```java
// Spawn NPC in instance
NpcInstance npc = ref.addSpawnWithoutRespawn(npcId, loc, 0);

// Spawn with respawn
ref.addSpawn(npcId, loc, respawnTime);

// Spawn doors
ref.getDoor(doorId).openMe();
ref.getDoor(doorId).closeMe();
```

---

## Configuration (instantzone.xml)

```xml
<instance id="123" name="My Dungeon">
    <timelimit>3600</timelimit>
    <minLevel>80</minLevel>
    <maxLevel>85</maxLevel>
    <minParty>2</minParty>
    <maxParty>7</maxParty>
    <teleportCoord x="-12345" y="12345" z="-3000" />
    <return x="82635" y="148798" z="-3464" />
</instance>
```

---

## Best Practices

1. **Cleanup**: Always handle instance collapse
2. **Timers**: Set reasonable time limits
3. **Respawn**: Use proper respawn for monsters
4. **Doors**: Manage door states correctly
5. **Listeners**: Remove listeners on exit

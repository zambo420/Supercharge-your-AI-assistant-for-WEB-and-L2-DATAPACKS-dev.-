---
name: lucera2-zones
description: >
  Zone system: zone types, zone listeners, auto-buff zones, restriction zones.
  Trigger: When working with game zones, zone scripts, or area-based mechanics.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [zones]
  auto_invoke: "zones, zone scripts, auto-buff zone, PvP zone, siege zone"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating custom zone behaviors
- Implementing zone restrictions
- Working with siege/castle zones
- Creating auto-buff or reward zones
- Setting up level/class limited areas

---

## Directory Structure

```
zones/                           # Zone scripts (49 files)
├── AutoBuffZone.java            # Auto-apply buffs in zone
├── CapacityRestrictZone.java    # Limit players in zone
├── KillRewardZone.java          # Reward for kills in zone
├── LevelLimitZone.java          # Level restrictions
├── ClassIdLimitZone.java        # Class restrictions
├── ItemProhibitZone.java        # Item use restrictions
├── ProhibitSkillsZone.java      # Skill use restrictions
├── HwidLimitedZone.java         # HWID limit
├── IpLimitedZone.java           # IP limit
└── ...
```

---

## Zone Types

| Type | Description |
|------|-------------|
| `PEACE_ZONE` | No PvP allowed |
| `BATTLE_ZONE` | PvP enabled |
| `SIEGE` | Castle/fortress siege |
| `MONSTER_TRACK` | Monster track event |
| `NO_RESTART` | Can't restart here |
| `NO_SUMMON` | Can't summon |
| `FISHING` | Fishing allowed |
| `SCRIPT` | Custom script zone |

---

## Zone Script Pattern

```java
package zones;

import l2.gameserver.listener.zone.OnZoneEnterLeaveListener;
import l2.gameserver.model.Creature;
import l2.gameserver.model.Player;
import l2.gameserver.model.Zone;
import l2.gameserver.scripts.ScriptFile;

public class MyCustomZone implements ScriptFile {
    
    private static final String ZONE_NAME = "[my_zone]";
    
    private static ZoneListener _listener;
    
    @Override
    public void onLoad() {
        Zone zone = ZoneHolder.getInstance().getZoneByName(ZONE_NAME);
        if (zone != null) {
            _listener = new ZoneListener();
            zone.addListener(_listener);
        }
    }
    
    @Override
    public void onReload() {
        onShutdown();
        onLoad();
    }
    
    @Override
    public void onShutdown() {
        Zone zone = ZoneHolder.getInstance().getZoneByName(ZONE_NAME);
        if (zone != null && _listener != null) {
            zone.removeListener(_listener);
        }
    }
    
    private class ZoneListener implements OnZoneEnterLeaveListener {
        
        @Override
        public void onZoneEnter(Zone zone, Creature creature) {
            if (!creature.isPlayer()) {
                return;
            }
            Player player = creature.getPlayer();
            player.sendMessage("You entered " + ZONE_NAME);
            // Apply effects, restrictions, etc.
        }
        
        @Override
        public void onZoneLeave(Zone zone, Creature creature) {
            if (!creature.isPlayer()) {
                return;
            }
            Player player = creature.getPlayer();
            player.sendMessage("You left " + ZONE_NAME);
            // Remove effects, restore state, etc.
        }
    }
}
```

---

## Auto-Buff Zone Example

```java
public class AutoBuffZone implements ScriptFile {
    
    private static final int[] BUFFS = {1204, 1068, 1040}; // Skill IDs
    
    private class BuffZoneListener implements OnZoneEnterLeaveListener {
        
        @Override
        public void onZoneEnter(Zone zone, Creature creature) {
            if (!creature.isPlayer()) {
                return;
            }
            Player player = creature.getPlayer();
            
            for (int skillId : BUFFS) {
                Skill skill = SkillTable.getInstance().getInfo(skillId, 1);
                if (skill != null) {
                    skill.getEffects(player, player, false, false);
                }
            }
            player.sendMessage("You have been buffed!");
        }
        
        @Override
        public void onZoneLeave(Zone zone, Creature creature) {
            // Optional: remove buffs on leave
        }
    }
}
```

---

## Kill Reward Zone Example

```java
public class KillRewardZone implements ScriptFile {
    
    private class KillListener implements OnPlayerKillPlayerListener {
        
        @Override
        public void onPlayerKillPlayer(Player killer, Player victim) {
            Zone zone = ZoneHolder.getInstance().getZoneByName("[pvp_arena]");
            
            if (zone.checkIfInZone(killer)) {
                // Give reward
                killer.addItem("pvp_reward", REWARD_ITEM_ID, 1, null, true);
                killer.sendMessage("You received a reward for your kill!");
            }
        }
    }
}
```

---

## Zone Restriction Example

```java
// Level restriction
public class LevelLimitZone implements OnZoneEnterLeaveListener {
    
    private static final int MIN_LEVEL = 40;
    private static final int MAX_LEVEL = 85;
    
    @Override
    public void onZoneEnter(Zone zone, Creature creature) {
        if (!creature.isPlayer()) {
            return;
        }
        Player player = creature.getPlayer();
        int level = player.getLevel();
        
        if (level < MIN_LEVEL || level > MAX_LEVEL) {
            player.teleToClosestTown();
            player.sendMessage("Your level is not allowed in this zone!");
        }
    }
}
```

---

## Zone Properties

Zones are defined in XML:
```xml
<zone name="[my_zone]" type="SCRIPT">
    <territory>
        <add x="100000" y="100000" zmin="-5000" zmax="5000" />
        <add x="100500" y="100000" zmin="-5000" zmax="5000" />
        <add x="100500" y="100500" zmin="-5000" zmax="5000" />
        <add x="100000" y="100500" zmin="-5000" zmax="5000" />
    </territory>
    <set name="entering_message_no" value="1234" />
    <set name="leaving_message_no" value="1235" />
</zone>
```

---

## Common Zone Operations

### Check If In Zone

```java
boolean inZone = player.isInZone(ZoneType.PEACE_ZONE);
boolean inNamedZone = player.isInZone("[zone_name]");
```

### Get Zone

```java
Zone zone = ZoneHolder.getInstance().getZoneByName("[zone_name]");
Zone zone = player.getZone(ZoneType.PEACE_ZONE);
```

### Iterate Players in Zone

```java
Zone zone = ZoneHolder.getInstance().getZoneByName("[zone_name]");
for (Player player : zone.getInsidePlayers()) {
    // Process player
}
```

---

## Best Practices

1. **Clean listeners**: Always remove listeners in `onShutdown()`
2. **Null checks**: Check if zone exists before adding listeners
3. **Player only**: Check `isPlayer()` before casting to Player
4. **Performance**: Keep listener logic lightweight
5. **Messages**: Provide feedback when entering/leaving

---
name: lucera2-seasonal-events
description: >
  Seasonal/holiday events: Christmas, Halloween, L2Day, and special events.
  Trigger: When working with seasonal events, holiday events, or time-limited events.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [events, seasonal]
  auto_invoke: "christmas, halloween, seasonal event, holiday event, L2Day"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Implementing seasonal/holiday events
- Modifying Christmas, Halloween, etc.
- Creating time-limited events
- Working with event NPCs and rewards

---

## Directory Structure

```
events/                              # Event scripts
├── Christmas/                       # Christmas event (3 files)
│   ├── Christmas.java
│   ├── SantaTrader.java
│   └── SantaClaus.java
├── Halloween/                       # Halloween event (3 files)
│   ├── Halloween.java
│   ├── HalloweenNpc.java
│   └── HalloweenZombies.java
├── SavingSnowman/                   # Snowman event (6 files)
├── TheFallHarvest/                  # Harvest event (5 files)
├── MasterOfEnchanting/              # Enchant event
├── glitmedal/                       # Medal event
├── heart/                           # Valentine event
├── l2day/                           # L2Day celebration
├── Attendance/                      # Daily attendance (2 files)
└── AdventureHelper/                 # Adventure helper
```

---

## Seasonal Event Pattern

```java
package events.Christmas;

import l2.gameserver.scripts.Functions;
import l2.gameserver.scripts.ScriptFile;

public class Christmas extends Functions implements ScriptFile {
    
    private static boolean _active = false;
    private static final int START_MONTH = Calendar.DECEMBER;
    private static final int START_DAY = 15;
    private static final int END_MONTH = Calendar.JANUARY;
    private static final int END_DAY = 5;
    
    @Override
    public void onLoad() {
        if (isEventPeriod()) {
            startEvent();
        }
    }
    
    private boolean isEventPeriod() {
        Calendar now = Calendar.getInstance();
        int month = now.get(Calendar.MONTH);
        int day = now.get(Calendar.DAY_OF_MONTH);
        
        // December 15 - January 5
        return (month == START_MONTH && day >= START_DAY) ||
               (month == END_MONTH && day <= END_DAY);
    }
    
    public static void startEvent() {
        _active = true;
        
        // Spawn Santa NPCs
        spawnSantas();
        
        // Enable special drops
        enableChristmasDrops();
        
        // Announce
        Announcements.getInstance().announceToAll("Christmas event has started!");
    }
    
    public static void stopEvent() {
        _active = false;
        despawnSantas();
        disableChristmasDrops();
    }
    
    private static void spawnSantas() {
        // Spawn Santa in major towns
        SimpleSpawner spawner = new SimpleSpawner(SANTA_NPC_ID);
        spawner.setLoc(GIRAN_LOC);
        spawner.doSpawn(true);
        _spawns.add(spawner);
    }
}
```

---

## Event Drops

```java
// Add special drops during event
public class ChristmasDropListener implements OnKillListener {
    
    private static final int[] CHRISTMAS_ITEMS = {5556, 5557, 5558};
    private static final double DROP_CHANCE = 0.05; // 5%
    
    @Override
    public void onKill(Creature actor, Creature victim) {
        if (!Christmas.isActive()) return;
        if (!victim.isMonster()) return;
        if (!actor.isPlayer()) return;
        
        if (Rnd.chance(DROP_CHANCE * 100)) {
            int itemId = CHRISTMAS_ITEMS[Rnd.get(CHRISTMAS_ITEMS.length)];
            ((MonsterInstance)victim).dropItem(actor.getPlayer(), itemId, 1);
        }
    }
}
```

---

## Halloween Event Example

```java
package events.Halloween;

public class Halloween extends Functions implements ScriptFile {
    
    // Transform random players into zombies
    public static void zombieOutbreak() {
        List<Player> players = new ArrayList<>(World.getPlayers());
        int count = Math.min(10, players.size());
        
        Collections.shuffle(players);
        
        for (int i = 0; i < count; i++) {
            Player p = players.get(i);
            // Transform to zombie
            p.setTransformation(ZOMBIE_TRANSFORM_ID);
            p.sendMessage("You have become a zombie!");
        }
    }
    
    // Special Halloween NPC
    public void pumpkinTrade(String[] args) {
        Player player = getSelf();
        
        // Exchange pumpkins for rewards
        int pumpkins = player.getInventory().getCountOf(PUMPKIN_ID);
        if (pumpkins >= 10) {
            player.getInventory().destroyItemByItemId("Halloween", PUMPKIN_ID, 10, player, null);
            player.addItem("Halloween", REWARD_ID, 1, player, true);
        }
    }
}
```

---

## Daily Attendance System

```java
package events.Attendance;

public class Attendance implements ScriptFile {
    
    public void checkAttendance(Player player) {
        long lastAttendance = player.getVar("last_attendance", 0L);
        long now = System.currentTimeMillis();
        
        if (now - lastAttendance > DAY_MS) {
            // New day, give reward
            int streak = player.getVar("attendance_streak", 0) + 1;
            player.setVar("attendance_streak", streak);
            player.setVar("last_attendance", now);
            
            giveAttendanceReward(player, streak);
        }
    }
    
    private void giveAttendanceReward(Player player, int day) {
        // Rewards scale with streak
        int rewardId = DAILY_REWARDS[Math.min(day - 1, DAILY_REWARDS.length - 1)];
        player.addItem("Attendance", rewardId, 1, player, true);
    }
}
```

---

## Event NPCs

```java
// Santa Claus NPC
public class SantaClaus extends Functions {
    
    public void Chat(String[] args) {
        Player player = getSelf();
        
        StringBuilder html = new StringBuilder();
        html.append("<html><body>");
        html.append("Ho Ho Ho! Merry Christmas!<br><br>");
        html.append("<button action=\"bypass -h npc_%objectId%_exchangeSnow\" value=\"Exchange Snowflakes\" .../>");
        html.append("<button action=\"bypass -h npc_%objectId%_specialBuff\" value=\"Christmas Blessing\" .../>");
        html.append("</body></html>");
        
        show(html.toString(), player, getNpc());
    }
    
    public void exchangeSnow(String[] args) {
        Player player = getSelf();
        
        if (player.getInventory().destroyItemByItemId("Christmas", SNOWFLAKE_ID, 100, player, null)) {
            player.addItem("Christmas", SPECIAL_REWARD_ID, 1, player, true);
            player.sendMessage("You received a special Christmas gift!");
        } else {
            player.sendMessage("You need 100 snowflakes!");
        }
    }
}
```

---

## Configuration

```properties
# Seasonal events config
CHRISTMAS_EVENT_ENABLED = true
CHRISTMAS_START_MONTH = 12
CHRISTMAS_START_DAY = 15
CHRISTMAS_END_MONTH = 1
CHRISTMAS_END_DAY = 5

HALLOWEEN_EVENT_ENABLED = true
HALLOWEEN_START_MONTH = 10
HALLOWEEN_START_DAY = 25
HALLOWEEN_END_MONTH = 11
HALLOWEEN_END_DAY = 5
```

---

## Best Practices

1. **Auto-activate**: Check dates on server start
2. **Announcements**: Announce event start/end
3. **Unique rewards**: Use event-specific items
4. **Time limits**: Clear event items after event ends
5. **Atmosphere**: Add NPCs, decorations, music
6. **Database**: Track player participation

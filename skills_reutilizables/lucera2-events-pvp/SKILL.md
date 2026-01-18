---
name: lucera2-events-pvp
description: >
  PvP events: TvT, GvG, CTF, custom events, and event framework.
  Trigger: When working with PvP events, team battles, or custom events.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [events, pvp]
  auto_invoke: "TvT, GvG, CTF, pvp event, team event"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating new PvP events
- Modifying existing events (TvT, GvG)
- Working with event rewards
- Implementing team-based mechanics
- Managing event scheduling

---

## Directory Structure

```
events/                              # Event scripts
├── TvT/                             # Team vs Team (4 files)
│   ├── TvT.java
│   └── TvTEvent.java
├── TvT2/                            # Advanced TvT (24 files)
│   ├── TvT2.java
│   └── ...
├── TvTArena/                        # TvT Arena (9 files)
├── GvG/                             # Guild vs Guild (4 files)
│   ├── GvGEvent.java
│   └── GvGInstance.java
├── Finder/                          # Finder event (4 files)
├── DropEvent/                       # Drop multiplier event
├── VipDropEvent/                    # VIP drop event
└── StraightHands/                   # Custom event

l2/gameserver/model/entity/events/   # Event framework (60 files)
├── GlobalEvent.java                 # Base event class
├── EventType.java                   # Event types
├── EventWrapper.java                # Event wrapper
├── impl/                            # Event implementations (23 files)
├── actions/                         # Event actions (13 files)
└── objects/                         # Event objects (18 files)
```

---

## Event Framework

### Base Event Structure

```java
// All events extend GlobalEvent or use event wrapper
public class MyEvent extends GlobalEvent {
    
    @Override
    public void startEvent() {
        // Initialize event
        spawnNPCs();
        announceStart();
        scheduleEnd();
    }
    
    @Override
    public void stopEvent() {
        // Clean up
        despawnNPCs();
        giveRewards();
        announceEnd();
    }
    
    @Override
    public void reCalcNextTime(boolean onInit) {
        // Schedule next event
    }
}
```

---

## TvT Event Pattern

```java
package events.TvT;

import l2.gameserver.scripts.Functions;
import l2.gameserver.scripts.ScriptFile;

public class TvT extends Functions implements ScriptFile {
    
    private static boolean _active = false;
    private static List<Player> _teamRed = new ArrayList<>();
    private static List<Player> _teamBlue = new ArrayList<>();
    
    // Registration
    public void register(String[] args) {
        Player player = getSelf();
        if (player == null) return;
        
        if (_teamRed.size() <= _teamBlue.size()) {
            _teamRed.add(player);
            player.sendMessage("You joined Red Team!");
        } else {
            _teamBlue.add(player);
            player.sendMessage("You joined Blue Team!");
        }
    }
    
    // Start event
    public static void startEvent() {
        _active = true;
        
        // Teleport teams
        for (Player p : _teamRed) {
            p.teleToLocation(RED_SPAWN);
            p.setTeam(TeamType.RED);
        }
        for (Player p : _teamBlue) {
            p.teleToLocation(BLUE_SPAWN);
            p.setTeam(TeamType.BLUE);
        }
        
        // Schedule end
        ThreadPoolManager.getInstance().schedule(() -> stopEvent(), EVENT_DURATION);
    }
    
    // End event
    public static void stopEvent() {
        _active = false;
        
        // Calculate winner
        int redKills = countKills(_teamRed);
        int blueKills = countKills(_teamBlue);
        
        List<Player> winners = redKills > blueKills ? _teamRed : _teamBlue;
        
        // Give rewards
        for (Player p : winners) {
            p.addItem("TvT_Reward", REWARD_ID, REWARD_COUNT, p, true);
        }
        
        // Clean up
        for (Player p : getAllPlayers()) {
            p.setTeam(TeamType.NONE);
            p.teleToLocation(RETURN_LOC);
        }
        
        _teamRed.clear();
        _teamBlue.clear();
    }
}
```

---

## GvG Event Pattern

```java
// Guild vs Guild uses instances
public class GvGInstance extends Reflection {
    
    private Party _teamA;
    private Party _teamB;
    private int _scoreA;
    private int _scoreB;
    
    public GvGInstance(Party teamA, Party teamB) {
        super();
        _teamA = teamA;
        _teamB = teamB;
        setName("GvG Arena");
    }
    
    @Override
    public void onPlayerEnter(Player player) {
        // Setup player for battle
        player.setReflection(this);
    }
    
    public void onKill(Player killer, Player victim) {
        if (_teamA.containsMember(killer)) {
            _scoreA++;
        } else {
            _scoreB++;
        }
        
        checkWinner();
    }
}
```

---

## Event Registration NPC

```java
// NPC dialog for event registration
public void showEventDialog() {
    StringBuilder html = new StringBuilder();
    html.append("<html><body>");
    html.append("<center><b>TvT Event</b></center><br>");
    
    if (TvT.isRegistrationOpen()) {
        html.append("Registration is OPEN!<br>");
        html.append("<button action=\"bypass -h npc_%objectId%_register\" value=\"Register\" .../>");
    } else {
        html.append("Registration is CLOSED<br>");
    }
    
    html.append("</body></html>");
    show(html.toString(), player, npc);
}
```

---

## Event Scheduling

```java
// Schedule event at specific times
public void scheduleEvent() {
    Calendar cal = Calendar.getInstance();
    cal.set(Calendar.HOUR_OF_DAY, 20); // 8 PM
    cal.set(Calendar.MINUTE, 0);
    
    long delay = cal.getTimeInMillis() - System.currentTimeMillis();
    if (delay < 0) {
        delay += 24 * 60 * 60 * 1000; // Next day
    }
    
    ThreadPoolManager.getInstance().schedule(() -> startEvent(), delay);
}
```

---

## Event Listeners

```java
// Listen for kills in event
public class EventKillListener implements OnPlayerKillPlayerListener {
    
    @Override
    public void onPlayerKillPlayer(Player killer, Player victim) {
        if (TvT.isActive() && TvT.isParticipant(killer)) {
            TvT.onKill(killer, victim);
        }
    }
}
```

---

## Configuration

```properties
# Event config
TVT_EVENT_ENABLED = true
TVT_MIN_PLAYERS = 10
TVT_MAX_PLAYERS = 50
TVT_REGISTRATION_TIME = 10  # minutes
TVT_BATTLE_TIME = 20        # minutes
TVT_REWARD_ID = 57
TVT_REWARD_COUNT = 10000
```

---

## Best Practices

1. **Clean up**: Always remove players from event on end/crash
2. **Persistence**: Handle server restart during events
3. **Balance**: Match team sizes
4. **Restrictions**: Block certain skills/items during events
5. **Announcements**: Keep players informed of event status
6. **Rewards**: Give rewards only to active participants

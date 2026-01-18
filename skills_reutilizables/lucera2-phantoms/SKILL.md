---
name: lucera2-phantoms
description: >
  Fake players (phantoms/bots) system: phantom config, factory, AI, and spawn management.
  Trigger: When working with phantom/fake players, bot simulation, or player population.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [phantoms]
  auto_invoke: "phantoms, fake players, bots, player simulation"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Configuring phantom player system
- Modifying fake player behaviors
- Working with phantom spawn management
- Creating custom phantom AI
- Setting up phantom appearance/equipment

---

## Directory Structure

```
phantoms/                        # Phantom system (42 files)
├── PhantomConfig.java           # Configuration
├── PhantomFactory.java          # Phantom creation
├── PhantomLoader.java           # Spawn management
├── PhantomUtils.java            # Utilities
├── Phantoms.java                # Main script
├── action/                      # Phantom actions (7 files)
│   ├── PhantomAction.java
│   ├── PhantomActionChat.java
│   ├── PhantomActionMove.java
│   └── ...
├── ai/                          # Phantom AI (4 files)
│   ├── PhantomAI.java
│   └── ...
├── data/                        # Data holders (11 files)
│   ├── PhantomName.java
│   ├── PhantomTitle.java
│   └── ...
├── model/                       # Phantom models (6 files)
│   ├── PhantomPlayer.java
│   └── ...
└── template/                    # Phantom templates (5 files)
    ├── PhantomTemplate.java
    └── ...
```

---

## Key Classes

| Class | Purpose |
|-------|---------|
| `PhantomConfig` | System configuration |
| `PhantomFactory` | Creates phantom instances |
| `PhantomLoader` | Manages spawn waves |
| `PhantomPlayer` | Fake player model |
| `PhantomAI` | Phantom behavior logic |
| `PhantomTemplate` | Appearance/stats template |

---

## Phantom Configuration

```java
// PhantomConfig.java
public class PhantomConfig {
    public static boolean ENABLED = true;
    public static int MAX_PHANTOMS = 100;
    public static int SPAWN_DELAY = 5000;        // ms
    public static int RESPAWN_DELAY = 60000;     // ms
    public static String NAME_PREFIX = "";
    public static boolean RANDOM_EQUIPMENT = true;
}
```

---

## Creating Phantom

```java
// Using PhantomFactory
PhantomPlayer phantom = PhantomFactory.getInstance().create(template);

// Set properties
phantom.setName("FakePlayer001");
phantom.setTitle("Knight");
phantom.setClassId(ClassId.DARK_AVENGER);
phantom.setLevel(80);

// Spawn in world
phantom.spawnMe(x, y, z);
```

---

## Phantom Template

```java
// PhantomTemplate defines phantom appearance
public class PhantomTemplate {
    private int _classId;
    private int _minLevel;
    private int _maxLevel;
    private int[] _weaponIds;
    private int[] _armorIds;
    private Location[] _spawnLocations;
    
    public PhantomPlayer create() {
        PhantomPlayer phantom = new PhantomPlayer();
        phantom.setClassId(_classId);
        phantom.setLevel(Rnd.get(_minLevel, _maxLevel));
        // ... setup equipment
        return phantom;
    }
}
```

---

## Phantom Actions

### Movement Action

```java
package phantoms.action;

public class PhantomActionMove extends PhantomAction {
    
    private Location _destination;
    
    @Override
    public void perform(PhantomPlayer phantom) {
        if (_destination != null) {
            phantom.moveToLocation(_destination, 0, true);
        }
    }
}
```

### Chat Action

```java
public class PhantomActionChat extends PhantomAction {
    
    private String _message;
    
    @Override
    public void perform(PhantomPlayer phantom) {
        if (_message != null) {
            phantom.broadcastPacket(new Say2(phantom.getObjectId(), 
                Say2.ChatType.ALL, phantom.getName(), _message));
        }
    }
}
```

---

## Phantom AI

```java
package phantoms.ai;

public class PhantomAI {
    
    private PhantomPlayer _phantom;
    private PhantomAction _currentAction;
    
    public PhantomAI(PhantomPlayer phantom) {
        _phantom = phantom;
    }
    
    public void think() {
        // Choose next action
        if (_phantom.isMoving()) {
            return; // Wait for movement to complete
        }
        
        // Random behavior
        int rnd = Rnd.get(100);
        if (rnd < 30) {
            // Move to random location
            _currentAction = new PhantomActionMove(getRandomLocation());
        } else if (rnd < 40) {
            // Chat
            _currentAction = new PhantomActionChat(getRandomPhrase());
        } else {
            // Idle
            _currentAction = new PhantomActionIdle();
        }
        
        _currentAction.perform(_phantom);
    }
    
    private Location getRandomLocation() {
        Location cur = _phantom.getLoc();
        return Location.findPointToStay(cur, 100, 500);
    }
}
```

---

## Spawn Management

```java
// PhantomLoader handles wave spawning
public class PhantomLoader implements ScriptFile {
    
    @Override
    public void onLoad() {
        if (!PhantomConfig.ENABLED) {
            return;
        }
        
        // Schedule spawn waves
        ThreadPoolManager.getInstance().schedule(new SpawnWaveTask(), 
            PhantomConfig.SPAWN_DELAY);
    }
    
    private class SpawnWaveTask implements Runnable {
        @Override
        public void run() {
            int currentCount = PhantomFactory.getInstance().getActiveCount();
            int toSpawn = PhantomConfig.MAX_PHANTOMS - currentCount;
            
            for (int i = 0; i < toSpawn; i++) {
                PhantomFactory.getInstance().spawnRandom();
            }
            
            // Schedule next wave
            ThreadPoolManager.getInstance().schedule(this, 
                PhantomConfig.RESPAWN_DELAY);
        }
    }
}
```

---

## Phantom Name/Title Data

```java
// Names and titles are loaded from data files
// data/phantoms/names.txt
// data/phantoms/titles.txt

public class PhantomName {
    private static List<String> _names = new ArrayList<>();
    
    public static void load() {
        // Load from file
    }
    
    public static String getRandom() {
        return _names.get(Rnd.get(_names.size()));
    }
}
```

---

## Admin Commands

```
//phantom_spawn [count]     - Spawn phantoms
//phantom_despawn           - Remove all phantoms
//phantom_list              - List active phantoms
//phantom_info [name]       - Show phantom info
```

---

## Best Practices

1. **Performance**: Limit phantom count based on server capacity
2. **Realistic behavior**: Vary actions and timing
3. **Equipment variety**: Use random equipment sets
4. **Name uniqueness**: Ensure no duplicate names
5. **Clean despawn**: Remove phantoms on server shutdown
6. **Detection prevention**: Make behavior human-like

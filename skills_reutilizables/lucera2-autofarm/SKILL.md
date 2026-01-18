---
name: lucera2-autofarm
description: >
  AutoFarm bot system: automated farming, auto-attack, auto-skill.
  Trigger: When working with autofarm, bot farming, or automated combat.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [autofarm, bot]
  auto_invoke: "autofarm, auto farm, bot, automated farming"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Configuring autofarm system
- Adding new autofarm modes
- Modifying farm behavior
- Working with farm tasks

---

## Directory Structure

```
l2/gameserver/model/actor/player/    # AutoFarm tasks (7 files)
├── BaseFarmTask.java                 # Base class (16KB)
├── AutoPhysicalFarmTask.java         # Melee farming
├── AutoArcherFarmTask.java           # Archer farming
├── AutoMagicFarmTask.java            # Magic farming
├── AutoHealFarmTask.java             # Healer support
├── AutoSummonFarmTask.java           # Summoner farming (7KB)
└── AutoFarmEndTask.java              # Cleanup task

l2/gameserver/taskmanager/
└── AutoFarmManager.java              # Farm manager (5KB)
```

---

## AutoFarm Architecture

```
AutoFarmManager
    └── BaseFarmTask (abstract)
        ├── AutoPhysicalFarmTask
        ├── AutoArcherFarmTask
        ├── AutoMagicFarmTask
        ├── AutoHealFarmTask
        └── AutoSummonFarmTask
```

---

## Enabling AutoFarm

```java
// Enable autofarm for player
Player player = ...;
AutoFarmManager.getInstance().startFarm(player);

// Disable autofarm
AutoFarmManager.getInstance().stopFarm(player);

// Check if farming
boolean isFarming = AutoFarmManager.getInstance().isFarming(player);
```

---

## BaseFarmTask Pattern

```java
package l2.gameserver.model.actor.player;

public abstract class BaseFarmTask implements Runnable {
    
    protected final Player _player;
    protected Creature _target;
    
    public BaseFarmTask(Player player) {
        _player = player;
    }
    
    @Override
    public void run() {
        if (!canContinue()) {
            stop();
            return;
        }
        
        // Find target
        _target = findTarget();
        if (_target == null) {
            return;
        }
        
        // Execute farm action
        doFarmAction();
        
        // Schedule next tick
        scheduleNext();
    }
    
    protected boolean canContinue() {
        return _player.isOnline() && 
               !_player.isDead() && 
               !_player.isInCombat();
    }
    
    protected abstract Creature findTarget();
    protected abstract void doFarmAction();
    
    protected void scheduleNext() {
        ThreadPoolManager.getInstance().schedule(this, 1000);
    }
}
```

---

## Physical Farm Task

```java
public class AutoPhysicalFarmTask extends BaseFarmTask {
    
    @Override
    protected Creature findTarget() {
        // Find nearest attackable monster
        return World.getAroundNpc(_player)
            .filter(npc -> npc.isMonster())
            .filter(npc -> !npc.isDead())
            .filter(npc -> _player.isInRange(npc, 1000))
            .findFirst()
            .orElse(null);
    }
    
    @Override
    protected void doFarmAction() {
        if (_target == null || _target.isDead()) {
            return;
        }
        
        // Move to target if needed
        if (!_player.isInRange(_target, 40)) {
            _player.moveToLocation(_target.getLoc(), 0, true);
            return;
        }
        
        // Attack
        _player.doAttack(_target);
    }
}
```

---

## Magic Farm Task

```java
public class AutoMagicFarmTask extends BaseFarmTask {
    
    private Skill _mainSkill;
    
    @Override
    protected void doFarmAction() {
        if (_target == null || _target.isDead()) {
            return;
        }
        
        // Get best offensive skill
        _mainSkill = getBestSkill();
        
        if (_mainSkill != null && _mainSkill.checkCondition(_player, _target, false)) {
            _player.doCast(_mainSkill, _target, false);
        } else {
            // Fall back to auto-attack
            _player.doAttack(_target);
        }
    }
    
    private Skill getBestSkill() {
        return _player.getAllSkills().stream()
            .filter(s -> s.isOffensive())
            .filter(s -> !s.isDisabled())
            .max(Comparator.comparingInt(Skill::getPower))
            .orElse(null);
    }
}
```

---

## AutoFarm Manager

```java
public class AutoFarmManager {
    
    private Map<Integer, BaseFarmTask> _activeFarms = new ConcurrentHashMap<>();
    
    public void startFarm(Player player) {
        if (_activeFarms.containsKey(player.getObjectId())) {
            return;
        }
        
        // Determine farm type based on class
        BaseFarmTask task = createTaskForClass(player);
        _activeFarms.put(player.getObjectId(), task);
        
        // Start farming
        ThreadPoolManager.getInstance().execute(task);
        player.sendMessage("AutoFarm started!");
    }
    
    public void stopFarm(Player player) {
        BaseFarmTask task = _activeFarms.remove(player.getObjectId());
        if (task != null) {
            task.stop();
            player.sendMessage("AutoFarm stopped!");
        }
    }
    
    private BaseFarmTask createTaskForClass(Player player) {
        if (player.isMageClass()) {
            return new AutoMagicFarmTask(player);
        } else if (player.getClassId().isOfType(ClassType.Archer)) {
            return new AutoArcherFarmTask(player);
        } else {
            return new AutoPhysicalFarmTask(player);
        }
    }
}
```

---

## Configuration

```properties
# AutoFarm config
AUTOFARM_ENABLED = true
AUTOFARM_RADIUS = 1000
AUTOFARM_TICK_MS = 1000
AUTOFARM_FREE_DURATION = 3600  # 1 hour free per day
AUTOFARM_VIP_ONLY = false
```

---

## Best Practices

1. **Performance**: Limit farm tick rate
2. **Restrictions**: Disable in PvP zones
3. **Balance**: Limit to avoid abuse
4. **VIP**: Consider VIP-only feature
5. **Cleanup**: Stop on logout/death

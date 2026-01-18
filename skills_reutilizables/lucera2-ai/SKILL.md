---
name: lucera2-ai
description: >
  AI behavior system for NPCs, monsters, and custom entities.
  Trigger: When working with NPC AI, monster behavior, custom AI scripts, or entity intelligence.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [ai, behavior]
  auto_invoke: "AI, NPC behavior, monster AI, fighter AI, mystic AI"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating custom NPC behaviors
- Modifying monster attack patterns
- Implementing special AI mechanics
- Working with minions and followers
- Creating event-specific AI

---

## Directory Structure

```
ai/                              # AI scripts (180 files)
├── Antharas.java                # Epic boss AI
├── Valakas.java                 # Epic boss AI
├── UniversalFighter.java        # Base fighter AI
├── UniversalMystic.java         # Base mystic AI
├── custom/                      # Custom AI scripts
├── door/                        # Door AI
├── events/                      # Event-specific AI
├── freya/                       # Freya instance AI
├── isle_of_prayer/              # IOC AI scripts
├── moveroute/                   # Movement route AI
├── primeval_isle/               # Primeval isle AI
└── residences/                  # Castle/fortress AI

l2/gameserver/ai/                # Core AI classes (34 files)
├── DefaultAI.java               # Default AI implementation
├── CharacterAI.java             # Base character AI
├── PlayableAI.java              # Player/summon AI
└── ...
```

---

## AI Base Classes

| Class | Purpose |
|-------|---------|
| `DefaultAI` | Base AI for most NPCs |
| `Fighter` | Melee combat AI |
| `Mystic` | Ranged/magic AI |
| `CharacterAI` | Core AI logic |
| `PlayableAI` | Player/summon AI |

---

## AI Script Pattern

Location: `ai/` directory

```java
package ai;

import l2.gameserver.ai.Fighter;
import l2.gameserver.model.Creature;
import l2.gameserver.model.instances.NpcInstance;

public class MyCustomAI extends Fighter {
    
    public MyCustomAI(NpcInstance actor) {
        super(actor);
    }
    
    @Override
    protected void onEvtAttacked(Creature attacker, int damage) {
        super.onEvtAttacked(attacker, damage);
        // Custom attack response
    }
    
    @Override
    protected void onEvtAggression(Creature target, int aggro) {
        super.onEvtAggression(target, aggro);
        // Custom aggro behavior
    }
    
    @Override
    protected boolean thinkActive() {
        // Called periodically when NPC is active
        NpcInstance actor = getActor();
        
        // Custom logic here
        if (actor.getCurrentHpPercents() < 50) {
            // Low health behavior
        }
        
        return super.thinkActive();
    }
}
```

---

## AI Events

| Event | Method | When Called |
|-------|--------|-------------|
| Attacked | `onEvtAttacked()` | NPC receives damage |
| Aggression | `onEvtAggression()` | Aggro list updated |
| Spawn | `onEvtSpawn()` | NPC spawns |
| Dead | `onEvtDead()` | NPC dies |
| See Spell | `onEvtSeeSpell()` | Skill used nearby |
| Think | `thinkActive()` | Periodic AI check |
| Arrived | `onEvtArrived()` | Movement completed |

---

## Fighter vs Mystic

### Fighter AI (Melee)

```java
public class MyFighter extends Fighter {
    @Override
    protected boolean createNewTask() {
        // Choose attack target
        Creature target = prepareTarget();
        if (target == null) {
            return false;
        }
        
        // Move to target and attack
        return chooseTaskAndStayInRange(target);
    }
}
```

### Mystic AI (Ranged)

```java
public class MyMystic extends Mystic {
    @Override
    protected boolean createNewTask() {
        Creature target = prepareTarget();
        if (target == null) {
            return false;
        }
        
        // Cast spells from range
        if (canUseSkill(SKILL_ID)) {
            addTaskCast(target, SKILL_ID);
            return true;
        }
        
        return chooseTaskAndStayInRange(target);
    }
}
```

---

## Common AI Operations

### Get Actor (NPC)

```java
NpcInstance actor = getActor();
```

### Target Selection

```java
// Get best target from aggro list
Creature target = prepareTarget();

// Get random target
Creature randomTarget = actor.getAggroList().getRandomHated();

// Get most hated target
Creature mostHated = actor.getAggroList().getMostHated();
```

### Skill Usage

```java
// Check if can use skill
if (canUseSkill(SKILL_ID)) {
    addTaskCast(target, SKILL_ID);
}

// Use skill with chance
if (Rnd.chance(30)) { // 30% chance
    actor.doCast(SkillTable.getInstance().getInfo(SKILL_ID, 1), target, false);
}
```

### Movement

```java
// Move to location
addTaskMove(location, true);

// Move to target
addTaskAttack(target);

// Random movement
Location rndLoc = Location.findPointToStay(actor, 100, 300);
addTaskMove(rndLoc, true);
```

---

## Special AI Patterns

### Minion Heal Leader

```java
// In minion AI
NpcInstance leader = actor.getLeader();
if (leader != null && leader.getCurrentHpPercents() < 50) {
    addTaskCast(leader, HEAL_SKILL_ID);
}
```

### Phase-Based Boss

```java
@Override
protected void onEvtAttacked(Creature attacker, int damage) {
    super.onEvtAttacked(attacker, damage);
    
    NpcInstance actor = getActor();
    double hpPercent = actor.getCurrentHpPercents();
    
    if (hpPercent < 50 && !_phase2Started) {
        _phase2Started = true;
        // Start phase 2
        actor.broadcastPacket(new NpcSay(actor, "Phase 2 begins!"));
    }
}
```

### Teleport Away

```java
if (actor.getCurrentHpPercents() < 10) {
    Location safeLoc = new Location(x, y, z);
    actor.teleToLocation(safeLoc);
}
```

---

## Registering AI

AI is usually auto-registered when NPC spawns based on AI type in NPC data.

For custom AI:
```xml
<!-- In npc data XML -->
<npc id="12345" ... >
    <ai type="ai.MyCustomAI" />
</npc>
```

---

## Best Practices

1. **Performance**: Avoid expensive operations in `thinkActive()`
2. **Null checks**: Always check if actor/target is null
3. **State tracking**: Use flags for multi-phase behaviors
4. **Range checks**: Verify distances before attacking
5. **Clean up**: Override `onEvtDead()` to clean timers/tasks

---
name: lucera2-skills-effects
description: >
  Skill system: skill classes, effects, conditions, stat functions.
  Trigger: When creating or modifying skills, effects, or skill conditions.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [skills, effects]
  auto_invoke: "skill effects, skill classes, effect types, skill conditions"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating new skill effects
- Modifying existing effect behaviors
- Adding skill conditions
- Working with stat modifications
- Implementing custom skill classes

---

## Directory Structure

```
l2/gameserver/skills/                # Skill system (171 files)
├── SkillsEngine.java                # Skill loading engine
├── DocumentSkill.java               # Skill XML parser
├── DocumentBase.java                # Base XML parser
├── EffectType.java                  # Effect type enum
├── AbnormalEffect.java              # Visual effects
├── effects/                         # Effect implementations (91 files)
│   ├── EffectBuff.java
│   ├── EffectHeal.java
│   ├── EffectStun.java
│   └── ...
└── skillclasses/                    # Skill class implementations (68 files)
    ├── Heal.java
    ├── PDam.java
    ├── MDam.java
    └── ...

l2/gameserver/stats/                 # Stat system
├── Formulas.java                    # Damage/heal formulas
├── Stats.java                       # Stat types
├── conditions/                      # Skill conditions (88 files)
├── funcs/                           # Stat functions (18 files)
└── triggers/                        # Skill triggers
```

---

## Effect Types

| Category | Examples |
|----------|----------|
| Buff/Debuff | `EffectBuff`, `EffectDebuffImmunity` |
| Damage | `EffectDamOverTime`, `EffectHPDamPercent` |
| Healing | `EffectHeal`, `EffectHealOverTime`, `EffectManaHeal` |
| Control | `EffectStun`, `EffectParalyze`, `EffectSleep`, `EffectFear` |
| Transform | `EffectTransformation`, `EffectGrow` |
| Movement | `EffectImmobilize`, `EffectRoot`, `EffectKnock` |
| Special | `EffectCubic`, `EffectSymbol`, `EffectInvisible` |

---

## Creating Custom Effect

Location: `l2/gameserver/skills/effects/`

```java
package l2.gameserver.skills.effects;

import l2.gameserver.model.Effect;
import l2.gameserver.stats.Env;

public class EffectMyCustom extends Effect {
    
    public EffectMyCustom(Env env, EffectTemplate template) {
        super(env, template);
    }
    
    @Override
    public void onStart() {
        super.onStart();
        // Called when effect starts
        getEffected().sendMessage("Effect started!");
    }
    
    @Override
    public void onExit() {
        super.onExit();
        // Called when effect ends
        getEffected().sendMessage("Effect ended!");
    }
    
    @Override
    public boolean onActionTime() {
        // Called periodically (based on effect period)
        // Return false to stop effect
        if (getEffected().isDead()) {
            return false;
        }
        
        // Do periodic action
        double heal = calc() * 10;
        getEffected().setCurrentHp(getEffected().getCurrentHp() + heal);
        
        return true; // Continue effect
    }
}
```

---

## Skill Class Pattern

Location: `l2/gameserver/skills/skillclasses/`

```java
package l2.gameserver.skills.skillclasses;

import l2.gameserver.model.Creature;
import l2.gameserver.model.Skill;
import l2.gameserver.stats.Env;

public class MySkillClass extends Skill {
    
    public MySkillClass(StatsSet set) {
        super(set);
    }
    
    @Override
    public void useSkill(Creature activeChar, List<Creature> targets) {
        for (Creature target : targets) {
            if (target == null) {
                continue;
            }
            
            // Calculate effect
            double power = getPower();
            
            // Apply effect
            target.reduceCurrentHp(power, activeChar, this, true, true, false, true);
            
            // Apply attached effects
            getEffects(activeChar, target, false);
        }
    }
}
```

---

## Skill Conditions

Location: `l2/gameserver/stats/conditions/`

```java
package l2.gameserver.stats.conditions;

import l2.gameserver.stats.Env;

public class ConditionPlayerHp extends Condition {
    
    private final int _hpPercent;
    
    public ConditionPlayerHp(int hpPercent) {
        _hpPercent = hpPercent;
    }
    
    @Override
    protected boolean testImpl(Env env) {
        return env.character.getCurrentHpPercents() <= _hpPercent;
    }
}
```

---

## Stat Functions

```java
// Get stat value
double pAtk = player.getPAtk(target);
double mAtk = player.getMAtk(target, skill);
double pDef = target.getPDef(player);
double mDef = target.getMDef(player, skill);

// Modify stats via funcs
public class FuncMyBonus extends Func {
    @Override
    public double calc(Env env) {
        return env.value * 1.10; // 10% bonus
    }
}
```

---

## Important Effect Methods

| Method | When Called |
|--------|-------------|
| `onStart()` | Effect begins |
| `onExit()` | Effect ends |
| `onActionTime()` | Periodic tick |
| `getEffected()` | Get target creature |
| `getEffector()` | Get caster creature |
| `calc()` | Calculate effect power |
| `getSkill()` | Get source skill |
| `getPeriod()` | Get effect duration |

---

## Effect Template

Effects are defined in skill XML:
```xml
<effect name="EffectBuff" time="300" val="50">
    <add stat="pAtk" val="50" />
    <add stat="mAtk" val="20" />
</effect>
```

---

## Common Stats

| Stat | Description |
|------|-------------|
| `pAtk` | Physical Attack |
| `mAtk` | Magical Attack |
| `pDef` | Physical Defense |
| `mDef` | Magical Defense |
| `pAtkSpd` | Attack Speed |
| `mAtkSpd` | Cast Speed |
| `runSpd` | Run Speed |
| `pCritRate` | Critical Rate |
| `mCritRate` | Magic Critical Rate |

---

## Best Practices

1. **Null checks**: Always verify effected/effector
2. **Dead check**: Stop effects on dead targets
3. **Balance**: Test effect values carefully
4. **Clean up**: Override `onExit()` to clean up
5. **Thread safety**: Effects can be called concurrently

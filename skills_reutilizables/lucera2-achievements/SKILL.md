---
name: lucera2-achievements
description: >
  Achievement system: conditions, metrics, counters, and UI.
  Trigger: When working with achievement system, achievement conditions, or achievement rewards.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [achievements]
  auto_invoke: "achievements, achievement conditions, achievement metrics"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating new achievements
- Adding achievement conditions
- Working with achievement metrics/counters
- Modifying achievement UI
- Implementing achievement rewards

---

## Directory Structure

```
achievements/                    # Achievement system (50 files)
├── Achievement.java             # Achievement definition
├── AchievementCondition.java    # Condition types
├── AchievementCounter.java      # Counter/progress tracking
├── AchievementInfo.java         # Achievement info/levels
├── AchievementMetricListeners.java  # Event listeners
├── AchievementMetricType.java   # Metric types
├── AchievementUI.java           # UI rendering
└── Achievements.java            # Main achievement handler
```

---

## Key Classes

| Class | Purpose |
|-------|---------|
| `Achievement` | Single achievement definition |
| `AchievementCondition` | Requirements to complete |
| `AchievementCounter` | Progress tracking per player |
| `AchievementInfo` | Achievement categories/levels |
| `AchievementMetricListeners` | Event hooks (kill, quest, etc.) |
| `AchievementUI` | HTML UI generation |
| `Achievements` | Main manager + voiced command |

---

## Achievement Metric Types

| Metric | Description | Trigger |
|--------|-------------|---------|
| `KILL` | Kill monsters | `onKill()` |
| `PVP_KILL` | Kill players | `onPvPPkKill()` |
| `DEATH` | Player deaths | `onDeath()` |
| `QUEST_COMPLETE` | Quest completion | `onQuestStateChange()` |
| `OLY_COMPETITION` | Olympiad matches | `onOlyCompetitionCompleted()` |
| `GAIN_EXP` | Experience gained | `onGainExpSp()` |
| `PLAYER_ENTER` | Login count | `onPlayerEnter()` |

---

## Achievement Pattern

### Achievement Definition

```java
// In data/achievements.xml or similar
<achievement id="1" name="Monster Slayer" category="combat">
    <level stage="1" count="100" reward_id="57" reward_count="1000" />
    <level stage="2" count="500" reward_id="57" reward_count="5000" />
    <level stage="3" count="1000" reward_id="57" reward_count="10000" />
    <condition type="kill" />
    <metric type="KILL" />
</achievement>
```

### Condition Types

```java
// Achievement conditions (inner classes in AchievementCondition.java)
public class AchSelfLevelInRange extends AchievementCondition {
    // Player level must be in range
}

public class AchSelfIsHero extends AchievementCondition {
    // Player must be hero
}

public class AchSelfIsNoble extends AchievementCondition {
    // Player must be noble
}

public class AchievementConditionNpcIdInList extends AchievementCondition {
    // Target NPC must be in list
}
```

---

## Counter System

### Increment Counter

```java
// Called automatically by metric listeners
AchievementCounter.getInstance().increment(player, achievementId, count);

// Example from kill listener
public void onKill(Creature actor, Creature victim) {
    if (actor.isPlayer()) {
        Player player = actor.getPlayer();
        Achievement ach = Achievements.getInstance().get(achievementId);
        
        if (ach.getCondition().check(player, victim)) {
            AchievementCounter.getInstance().increment(player, achievementId, 1);
        }
    }
}
```

### Check Progress

```java
// Get player's current progress
int current = AchievementCounter.getInstance().getCount(player, achievementId);
int required = achievement.getCurrentLevelInfo(player).getRequiredCount();

boolean completed = current >= required;
```

---

## Creating Custom Condition

```java
package achievements;

public class AchievementCondition {
    
    // Add new condition type
    public static class MyCustomCondition extends AchievementCondition {
        
        private int _requiredValue;
        
        public MyCustomCondition(int value) {
            _requiredValue = value;
        }
        
        @Override
        public boolean check(Player player, Object target) {
            // Custom logic
            return player.getSomething() >= _requiredValue;
        }
    }
}
```

---

## UI System

```java
// AchievementUI.java generates HTML for Community Board
public class AchievementUI {
    
    public static String generateAchievementList(Player player, int category) {
        StringBuilder html = new StringBuilder();
        html.append("<html><body>");
        
        for (Achievement ach : Achievements.getInstance().getByCategory(category)) {
            int current = AchievementCounter.getInstance().getCount(player, ach.getId());
            int required = ach.getCurrentLevelInfo(player).getRequiredCount();
            
            html.append("<table>");
            html.append("<tr><td>").append(ach.getName()).append("</td>");
            html.append("<td>").append(current).append("/").append(required).append("</td></tr>");
            html.append("</table>");
        }
        
        html.append("</body></html>");
        return html.toString();
    }
}
```

---

## Voiced Command

The achievement system includes a voiced command:

```java
// Registered as "achievements" or "ach"
// bypass -h user_achievements
```

---

## Database Storage

Achievements are stored in player-specific tables:
```sql
CREATE TABLE character_achievements (
    char_id INT,
    achievement_id INT,
    current_count INT,
    current_level INT,
    PRIMARY KEY (char_id, achievement_id)
);
```

---

## Adding New Achievement

1. **Define achievement** in data/XML file
2. **Create condition** if needed (or use existing)
3. **Choose metric type** (KILL, QUEST, etc.)
4. **Set rewards** per level
5. **Test** increments and completion

---

## Best Practices

1. **Unique IDs**: Use unique achievement IDs
2. **Clear conditions**: Make achievement requirements clear
3. **Balanced rewards**: Scale rewards with difficulty
4. **UI feedback**: Show progress to players
5. **Database cleanup**: Clean deleted character data

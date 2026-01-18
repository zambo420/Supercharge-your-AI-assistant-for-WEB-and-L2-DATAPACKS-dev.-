---
name: lucera2-olympiad
description: >
  Olympiad system: competitions, heroes, nobles, stadiums.
  Trigger: When working with Olympiad system, hero system, or noble management.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [olympiad]
  auto_invoke: "olympiad, hero, noble, competition, stadium"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Working with Olympiad competitions
- Modifying hero/noble system
- Configuring Olympiad rewards
- Working with stadiums
- Customizing Olympiad rules

---

## Directory Structure

```
l2/gameserver/model/entity/oly/      # Olympiad system (35 files)
├── OlyController.java               # Main controller
├── Competition.java                 # Match logic
├── CompetitionController.java       # Match management
├── HeroController.java              # Hero system
├── NoblesController.java            # Noble management
├── Stadium.java                     # Arena management
├── StadiumPool.java                 # Stadium allocation
├── Participant.java                 # Player participation
├── ParticipantPool.java             # Participant queue
└── participants/                    # Participant types
```

---

## Key Classes

| Class | Purpose |
|-------|---------|
| `OlyController` | Main Olympiad controller, scheduling |
| `Competition` | Individual match logic |
| `CompetitionController` | Match lifecycle management |
| `HeroController` | Hero status, rewards, diaries |
| `NoblesController` | Noble points, rankings |
| `Stadium` | Arena instance management |
| `ParticipantPool` | Registration queue |

---

## Olympiad States

```java
public enum CompetitionState {
    LOADING,      // Loading data
    REGISTRATION, // Players can register
    PREPARATION,  // Preparing match
    BATTLE,       // Match in progress
    FINISHED      // Match ended
}
```

---

## Registering for Olympiad

```java
// Check if can register
if (OlyController.getInstance().isRegistrationOpen()) {
    // Register player
    ParticipantPool.getInstance().registerNoClassBased(player);
}

// Check registration status
boolean isRegistered = ParticipantPool.getInstance().isRegistered(player);
```

---

## Hero System

```java
// Check if player is hero
boolean isHero = player.isHero();

// Get hero data
HeroController.getInstance().getHeroByObjId(player.getObjectId());

// Add hero diary entry
HeroController.getInstance().addHeroDiary(objId, action, param);
```

---

## Noble System

```java
// Check noble status
boolean isNoble = player.isNoble();

// Get Olympiad points
int points = NoblesController.getInstance().getOlympiadPoints(player);

// Get competition count
int matches = NoblesController.getInstance().getCompetitionsCount(player);
```

---

## Competition Flow

1. **Registration Opens** - Players register via NPC
2. **Match Preparation** - Players teleported to stadium
3. **Battle** - 3-minute fight
4. **Results** - Winner gets points, loser loses points
5. **Teleport Back** - Players returned to original location

```java
// Competition life cycle
CompetitionController controller = new CompetitionController(participants);
controller.startCompetition();
// ... battle happens ...
controller.finishCompetition(winner);
```

---

## Season Management

```java
// Check current period
OlyController.getInstance().getCurrentPeriod();

// End season (calculate heroes)
OlyController.getInstance().endSeason();

// Start new season
OlyController.getInstance().startNewSeason();
```

---

## Configuration

Key config values in `Config.java`:
```java
ALT_OLY_START_TIME          // Start hour
ALT_OLY_MIN                 // Start minute
ALT_OLY_CPERIOD             // Competition period
ALT_OLY_BATTLE              // Battle duration
ALT_OLY_WPERIOD             // Weekly period
ALT_OLY_VPERIOD             // Validation period
ALT_OLY_MAX_POINTS          // Max points
ALT_OLY_WINNER_POINTS       // Points for winning
ALT_OLY_LOSER_POINTS        // Points for losing
```

---

## Stadium System

```java
// Get available stadium
Stadium stadium = StadiumPool.getInstance().getStadium();

// Teleport players to stadium
stadium.teleportPlayers(participants);

// Release stadium after match
StadiumPool.getInstance().releaseStadium(stadium);
```

---

## Best Practices

1. **Thread safety**: Olympiad uses many concurrent operations
2. **State checks**: Always verify competition state before actions
3. **Database sync**: Save data regularly
4. **Balance**: Test point changes carefully
5. **Clean up**: Ensure stadiums are released after matches

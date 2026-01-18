---
name: lucera2-siege-duel
description: >
  Siege and duel events: castle siege, clan hall siege, duels.
  Trigger: When working with siege mechanics, duel system, or territory wars.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [siege, duel]
  auto_invoke: "siege, duel, castle siege, clan hall siege, territory war"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Working with castle siege mechanics
- Implementing clan hall sieges
- Modifying duel system
- Working with territory wars
- Managing siege NPCs and guards

---

## Directory Structure

```
l2/gameserver/model/entity/events/impl/  # Siege/duel events (23 files)
├── SiegeEvent.java                       # Base siege event
├── CastleSiegeEvent.java                 # Castle siege
├── ClanHallSiegeEvent.java               # Clan hall siege
├── ClanHallAuctionEvent.java             # Clan hall auction
├── DuelEvent.java                        # Duel base
├── PlayerVsPlayerDuelEvent.java          # 1v1 duel
├── PartyVsPartyDuelEvent.java            # Party duel
└── ...

l2/gameserver/instancemanager/
├── SiegeManager.java                     # Siege management
└── sepulchers/                           # Sepulcher sieges

l2/gameserver/dao/
├── SiegeClanDAO.java                     # Siege clan data
└── SiegePlayerDAO.java                   # Siege player data
```

---

## Siege Event Lifecycle

```
NONE → REGISTRATION → BATTLE → FINISHED → NONE
```

1. **Registration**: Clans sign up as attacker/defender
2. **Battle**: Siege in progress
3. **Finished**: Winner determined, castle transferred

---

## Castle Siege

```java
// Get siege event
Castle castle = ResidenceHolder.getInstance().getResidence(Castle.class, castleId);
SiegeEvent siege = castle.getSiegeEvent();

// Check state
boolean inProgress = siege.isInProgress();
boolean inRegistration = siege.isRegistrationOpen();

// Register attacker
siege.addAttacker(clan);

// Register defender
siege.addDefender(clan);

// Start siege
siege.startEvent();

// End siege
siege.stopEvent(winner);
```

---

## Siege Participants

```java
// Get attackers
List<SiegeClan> attackers = siege.getAttackerClans();

// Get defenders
List<SiegeClan> defenders = siege.getDefenderClans();

// Get siege clan info
SiegeClan siegeClan = siege.getAttackerClan(clan);
int numFlags = siegeClan.getFlags().size();

// Check player participation
boolean isParticipant = siege.containsPlayer(player);
boolean isAttacker = siege.getAttackerClan(player.getClan()) != null;
```

---

## Siege Flags

```java
// Spawn siege flag
SiegeFlagInstance flag = new SiegeFlagInstance(player, templateId, lifetime);
flag.spawnMe(x, y, z);
siegeClan.addFlag(flag);

// Destroy flag
flag.deleteMe();
siegeClan.removeFlag(flag);

// Check flag distance
boolean nearFlag = player.isInRange(flag, 200);
```

---

## Castle Artifacts

```java
// Get artifacts
List<ArtefactInstance> artifacts = castle.getArtefacts();

// Check if captured
for (ArtefactInstance art : artifacts) {
    if (art.getCapturer() != null) {
        // Artifact captured by getCapturer()
    }
}
```

---

## Duel System

```java
// Create 1v1 duel
DuelEvent duel = new PlayerVsPlayerDuelEvent(player1, player2);

// Create party duel
DuelEvent duel = new PartyVsPartyDuelEvent(party1, party2);

// Start duel
duel.startEvent();

// End duel
duel.finishDuel(winner);

// Cancel duel
duel.cancelDuel();
```

---

## Duel States

```java
public enum DuelState {
    NONE,
    REQUEST,        // Waiting for accept
    PREPARATION,    // Preparing (teleporting, etc.)
    BATTLE,         // Duel in progress
    FINISHED        // Duel ended
}

// Check duel state
DuelState state = duel.getState();
```

---

## Duel Restrictions

```java
// In DuelEvent
@Override
public boolean canUseSkill(Skill skill) {
    // Block resurrection skills
    if (skill.getSkillType() == SkillType.RESURRECT) {
        return false;
    }
    return true;
}

@Override
public boolean canUseItem(ItemInstance item) {
    // Block potions during duel
    if (item.isPotion()) {
        return false;
    }
    return true;
}
```

---

## Siege Guards

```java
// Spawn siege guards
SiegeGuardManager.getInstance().spawnGuards(castle);

// Deploy hired guards
castle.spawnMercenaries();

// Remove guards
SiegeGuardManager.getInstance().removeGuards(castle);
```

---

## Configuration

```properties
# Siege config
CASTLE_SIEGE_DURATION = 7200        # 2 hours
SIEGE_FLAG_MAX_COUNT = 5
SIEGE_MIN_PARTICIPANTS = 5

# Duel config
DUEL_REQUEST_TIMEOUT = 30000
DUEL_ARENA_ENABLED = true
DUEL_PARTY_ALLOWED = true
```

---

## Best Practices

1. **State checks**: Always verify siege/duel state
2. **Clean up**: Remove temporary objects on end
3. **Broadcast**: Announce important events
4. **Doors**: Manage door states during siege
5. **Respawn**: Handle respawn locations correctly

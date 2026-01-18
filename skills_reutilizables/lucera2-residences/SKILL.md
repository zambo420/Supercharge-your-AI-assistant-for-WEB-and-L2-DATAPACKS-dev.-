---
name: lucera2-residences
description: >
  Residence system: castles, clan halls, fortresses, siege.
  Trigger: When working with castles, clan halls, fortresses, or siege mechanics.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [residences, siege]
  auto_invoke: "castle, clan hall, fortress, siege, residence"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Working with castle/fortress systems
- Modifying clan hall mechanics
- Implementing siege features
- Working with residence functions (MP regen, teleport, etc.)
- Managing residence ownership

---

## Directory Structure

```
l2/gameserver/model/entity/residence/  # Residence system
├── Residence.java                      # Base residence class
├── Castle.java                         # Castle implementation
├── ClanHall.java                       # Clan hall implementation
├── ResidenceFunction.java              # Functions (HP regen, etc.)
└── ResidenceType.java                  # Type enum

l2/gameserver/model/instances/residences/  # Residence NPCs
├── CastleBlacksmithInstance.java
├── ClanhallManagerInstance.java
├── SiegeGuardInstance.java
└── ...

ai/residences/                          # Residence AI scripts
├── clanhall/
├── castle/
└── fortress/
```

---

## Residence Types

| Type | Description |
|------|-------------|
| `Castle` | Major territory control, taxes |
| `ClanHall` | Clan-owned building |
| `Fortress` | Smaller territory control |
| `Dominion` | Territory war control |

---

## Castle System

```java
// Get castle by ID
Castle castle = ResidenceHolder.getInstance().getResidence(Castle.class, castleId);

// Check ownership
Clan owner = castle.getOwner();
boolean owned = owner != null;

// Get castle tax rate
int taxRate = castle.getTaxPercent();

// Set tax rate
castle.setTaxPercent(player, newRate);
```

---

## Clan Hall System

```java
// Get clan hall
ClanHall ch = ResidenceHolder.getInstance().getResidence(ClanHall.class, hallId);

// Check if auctionable
boolean canAuction = ch.getSiegeEvent().isAuctionable();

// Get rent cost
long rent = ch.getRentalFee();
```

---

## Residence Functions

```java
// Function types
public enum FunctionType {
    HP_REGEN,      // HP regeneration
    MP_REGEN,      // MP regeneration
    XP_REGEN,      // XP bonus
    TELEPORT,      // Teleport function
    RESTORE_EXP,   // Exp restoration
    SUPPORT,       // Support magic
    ITEM_CREATE,   // Item creation
    CURTAIN,       // Curtains
    PLATFORM       // Elevator platforms
}

// Check if function active
boolean hasFunction = residence.getFunction(FunctionType.HP_REGEN) != null;

// Get function level
int level = residence.getFunction(FunctionType.HP_REGEN).getLevel();
```

---

## Siege System

```java
// Get siege event
SiegeEvent siege = castle.getSiegeEvent();

// Check if siege active
boolean inSiege = siege.isInProgress();

// Register for siege
siege.addAttacker(clan);
siege.addDefender(clan);

// Start siege
siege.startEvent();

// End siege
siege.stopEvent();
```

---

## Siege Participants

```java
// Get attackers
List<SiegeClan> attackers = siege.getAttackerClans();

// Get defenders
List<SiegeClan> defenders = siege.getDefenderClans();

// Check player's side
boolean isAttacker = siege.getAttackerClan(player.getClan()) != null;
boolean isDefender = siege.getDefenderClan(player.getClan()) != null;
```

---

## Artifacts and Flags

```java
// Castle artifacts (holy artifacts)
ArtefactInstance artifact = castle.getArtefacts().get(0);

// Capture artifact
boolean captured = artifact.onAction(player, false);

// Siege flags
SiegeFlagInstance flag = new SiegeFlagInstance(player, flagNpcId, flagLife);
flag.spawnMe();
```

---

## Residence Ownership Transfer

```java
// Change castle owner
castle.changeOwner(newClan);

// Update clan reputation
clan.incReputation(1000, false, "CastleCapture");

// Announce new owner
castle.getSiegeEvent().announce(SystemMessage.CASTLE_SIEGE_HAS_ENDED);
```

---

## Configuration

```java
// Castle config values
CASTLE_TAX_MIN = 0;
CASTLE_TAX_MAX = 15;
CASTLE_SIEGE_DURATION = 7200; // 2 hours

// Clan hall config
CH_RENT_FEE_MULTIPLIER = 1.0;
```

---

## Best Practices

1. **Siege state**: Always check siege state before operations
2. **Clan permissions**: Verify clan leader rights for functions
3. **Database sync**: Save residence data on changes
4. **Event announcements**: Notify players of siege events
5. **Function costs**: Validate adena before applying functions

---
name: lucera2-clans-alliances
description: >
  Clan and alliance system: clan management, ranks, privileges, wars.
  Trigger: When working with clans, alliances, clan wars, or clan reputation.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [clans, alliances]
  auto_invoke: "clan, alliance, clan war, clan reputation, clan skills"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Working with clan management
- Modifying alliance systems
- Implementing clan wars
- Working with clan reputation
- Managing clan skills and levels

---

## Directory Structure

```
l2/gameserver/model/pledge/          # Clan system (11 files)
├── Clan.java                        # Main clan class (50KB)
├── Alliance.java                    # Alliance management
├── SubUnit.java                     # Clan subunits (academy, knights)
├── UnitMember.java                  # Clan member
├── Privilege.java                   # Clan privileges
├── RankPrivs.java                   # Rank privileges
└── entry/                           # Clan entry system

services/                            # Clan services
├── ClanBuffService.java             # Clan buffs
├── ClanHelperService.java           # Clan helper
├── ClanRename.java                  # Rename clan
├── ClanReputationSell.java          # Sell reputation
├── ClanSkillSell.java               # Sell clan skills
└── ClanUpgrade.java                 # Upgrade clan level
```

---

## Clan Operations

### Get Clan

```java
// Get player's clan
Clan clan = player.getClan();

// Get clan by ID
Clan clan = ClanTable.getInstance().getClan(clanId);

// Get clan by name
Clan clan = ClanTable.getInstance().getClanByName(clanName);
```

### Create/Delete Clan

```java
// Create clan
Clan clan = ClanTable.getInstance().createClan(player, clanName);

// Dissolve clan
ClanTable.getInstance().deleteClanFromDb(clan);
```

### Clan Level

```java
// Get level
int level = clan.getLevel();

// Level up clan
if (clan.canLevelUp()) {
    clan.levelUp();
}
```

---

## Clan Members

```java
// Get leader
Player leader = clan.getLeader().getPlayer();

// Get all members
for (UnitMember member : clan.getAllMembers()) {
    Player p = member.getPlayer();
}

// Add member
clan.addMember(player);

// Remove member
clan.removeMember(memberId);

// Check membership
boolean isMember = player.getClanId() == clan.getClanId();
```

---

## Clan Privileges

```java
// Privilege types
public enum Privilege {
    CL_JOIN_CLAN,           // Invite members
    CL_GIVE_TITLE,          // Give titles
    CL_VIEW_WAREHOUSE,      // View warehouse
    CL_MANAGE_RANKS,        // Manage ranks
    CL_CLAN_WAR,            // Declare war
    CL_DISMISS,             // Kick members
    CL_REGISTER_CREST,      // Register crest
    CL_MASTER_PLEDGE,       // Edit pledge
    CL_MANAGE_CREST,        // Manage crests
    // ...
}

// Check privilege
boolean canInvite = player.hasClanPrivilege(Privilege.CL_JOIN_CLAN);
```

---

## Clan Reputation

```java
// Get reputation
int rep = clan.getReputationScore();

// Add reputation
clan.incReputation(1000, false, "Quest Reward");

// Deduct reputation
clan.incReputation(-500, false, "War Defeat");
```

---

## Clan Sub-Units

```java
// SubUnit types
public static final int MAIN_CLAN = 0;
public static final int ROYAL_GUARD_1 = 100;
public static final int ROYAL_GUARD_2 = 200;
public static final int KNIGHT_ORDER_1 = 1001;
public static final int KNIGHT_ORDER_2 = 1002;
public static final int ACADEMY = -1;

// Create subunit
clan.createSubUnit(player, KNIGHT_ORDER_1, leaderName, unitName);

// Get subunit
SubUnit unit = clan.getSubUnit(KNIGHT_ORDER_1);
```

---

## Clan Wars

```java
// Declare war
clan.startClanWar(enemyClan);

// End war
clan.stopClanWar(enemyClan);

// Check war status
boolean atWar = clan.isAtWarWith(enemyClanId);

// Get wars
Set<Clan> wars = clan.getWarList();
```

---

## Alliances

```java
// Create alliance
Alliance alliance = new Alliance(allianceName, clan);
clan.setAllyId(alliance.getAllyId());

// Join alliance
clan.setAllyId(alliance.getAllyId());
alliance.addAllianceMember(clan);

// Leave alliance
alliance.removeAllianceMember(clan);
clan.setAllyId(0);

// Get alliance members
for (Clan c : alliance.getMembers()) {
    // ...
}
```

---

## Configuration

```properties
# Clan config
CLAN_CREATE_LEVEL = 10
CLAN_CREATE_COST = 10000
CLAN_MAX_MEMBERS = 140
CLAN_ALLY_PENALTY = 86400000  # 24 hours
```

---

## Best Practices

1. **Leader checks**: Verify clan leader for sensitive operations
2. **Privilege checks**: Always check privileges before actions
3. **Database sync**: Broadcast changes to clan members
4. **War limits**: Respect max simultaneous wars
5. **Online status**: Handle offline member operations

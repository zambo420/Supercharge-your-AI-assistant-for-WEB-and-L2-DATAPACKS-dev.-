---
name: lucera2-cursed-weapons
description: >
  Cursed weapons: Zariche, Akamanah, special effects and mechanics.
  Trigger: When working with cursed weapons, Zariche, or Akamanah.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [cursed, weapons]
  auto_invoke: "cursed weapon, Zariche, Akamanah"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Working with cursed weapon mechanics
- Modifying Zariche or Akamanah behavior
- Implementing cursed weapon events
- Managing weapon acquisition/loss

---

## Directory Structure

```
l2/gameserver/instancemanager/
└── CursedWeaponsManager.java         # Main manager (29KB)

l2/gameserver/model/
└── CursedWeapon.java                  # Weapon class

Related NPCs and scripts for cursed weapon drops
```

---

## Cursed Weapons

| Weapon | ID | Effect |
|--------|-----|--------|
| Zariche | 8190 | Blade of Death - PvP focused |
| Akamanah | 8689 | Demon Sword - Monster kill focused |

---

## CursedWeaponsManager

```java
// Get manager instance
CursedWeaponsManager cwm = CursedWeaponsManager.getInstance();

// Check if item is cursed weapon
boolean isCursed = cwm.isCursed(itemId);

// Get cursed weapon by ID
CursedWeapon cw = cwm.getCursedWeapon(itemId);

// Get current owner
Player owner = cw.getPlayer();

// Check if weapon is active
boolean isActive = cw.isActive();
```

---

## CursedWeapon Class

```java
public class CursedWeapon {
    
    private int _itemId;
    private Player _player;
    private int _playerKarma;
    private int _playerPkKills;
    private long _endTime;
    private int _stageKills;
    
    // Activate weapon on player
    public void activate(Player player, ItemInstance item) {
        _player = player;
        
        // Save original stats
        _playerKarma = player.getKarma();
        _playerPkKills = player.getPkKills();
        
        // Apply cursed effects
        player.setCursedWeaponEquippedId(_itemId);
        player.setKarma(9999999);
        player.setPkKills(0);
        
        // Give special skills
        giveSkills();
        
        // Start timer
        _endTime = System.currentTimeMillis() + DURATION;
        
        // Transform appearance
        player.setTransformationId(CURSED_TRANSFORM);
        
        // Announce
        Announcements.getInstance().announceToAll(
            player.getName() + " has obtained " + getName() + "!"
        );
    }
    
    // Deactivate weapon
    public void deactivate(boolean removeItem) {
        if (_player == null) return;
        
        // Restore original stats
        _player.setKarma(_playerKarma);
        _player.setPkKills(_playerPkKills);
        _player.setCursedWeaponEquippedId(0);
        
        // Remove skills
        removeSkills();
        
        // Remove transform
        _player.setTransformationId(0);
        
        // Remove item if needed
        if (removeItem) {
            _player.getInventory().destroyItemByItemId("CursedWeapon", _itemId, 1, _player, null);
        }
        
        _player = null;
    }
}
```

---

## Weapon Acquisition

```java
// When monster drops cursed weapon
public void onMonsterDrop(Player killer, MonsterInstance monster) {
    CursedWeapon cw = CursedWeaponsManager.getInstance().getCursedWeapon(ZARICHE_ID);
    
    if (!cw.isActive() && Rnd.chance(DROP_CHANCE)) {
        // Create item
        ItemInstance item = ItemFunctions.createItem(ZARICHE_ID);
        
        // Give to player
        killer.getInventory().addItem(item);
        
        // Activate cursed weapon
        cw.activate(killer, item);
    }
}
```

---

## Weapon Transfer (PvP Kill)

```java
// When cursed weapon holder dies to another player
public void onOwnerDeath(Player owner, Player killer) {
    CursedWeapon cw = CursedWeaponsManager.getInstance().getCursedWeapon(owner.getCursedWeaponEquippedId());
    
    // Deactivate from old owner
    cw.deactivate(false);
    
    // Transfer to killer
    ItemInstance item = owner.getInventory().getItemByItemId(cw.getItemId());
    owner.getInventory().transferItem("CursedWeapon", item, 1, killer.getInventory());
    
    // Activate on new owner
    cw.activate(killer, killer.getInventory().getItemByItemId(cw.getItemId()));
}
```

---

## Stage System

```java
// Cursed weapons get stronger with kills
public void onKill(Player victim) {
    _stageKills++;
    
    // Every 10 kills, increase power
    if (_stageKills % 10 == 0) {
        upgradeStage();
    }
}

private void upgradeStage() {
    int stage = _stageKills / 10;
    
    // Increase weapon stats
    _player.addSkill(STAGE_SKILLS[Math.min(stage, MAX_STAGE)]);
    _player.sendSkillList();
    
    _player.sendMessage("Your cursed weapon grows stronger!");
}
```

---

## Restrictions

```java
// Cursed weapon holders cannot:
- Use stores/manufacture
- Drop/trade the weapon
- Enter Olympiad
- Enter peace zones (forced warp out)
- Use siege/residence features
- Transform (already transformed)
```

---

## Configuration

```properties
# Cursed weapon config
CURSED_WEAPON_DURATION = 604800000  # 7 days
CURSED_WEAPON_DROP_CHANCE = 0.0001
CURSED_WEAPON_ANNOUNCE = true
CURSED_WEAPON_PVP_ONLY = true
```

---

## Best Practices

1. **Persistence**: Save weapon state to DB
2. **Transfer**: Handle weapon transfer on PvP death
3. **Timeout**: Force drop after time expires
4. **Restrictions**: Block restricted actions
5. **Announcements**: Inform server of weapon activity

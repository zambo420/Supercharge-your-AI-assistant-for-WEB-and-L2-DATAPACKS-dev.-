---
name: lucera2-pets-summons
description: >
  Pet and summon system: pet evolution, feeding, servitors, cubics.
  Trigger: When working with pets, summons, servitors, or cubics.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [pets, summons]
  auto_invoke: "pet, summon, servitor, cubic, pet evolution"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Working with pet mechanics
- Implementing pet evolution
- Modifying summon/servitor behavior
- Working with cubics
- Pet feeding and inventory

---

## Directory Structure

```
l2/gameserver/model/instances/           # Pet/summon instances
├── PetInstance.java                      # Pet class (23KB)
├── PetBabyInstance.java                  # Baby pet
├── SummonInstance.java                   # Summon class
└── TamedBeastInstance.java               # Tamed beasts

services/petevolve/                       # Pet evolution (7 files)
├── wolfevolve.java                       # Wolf evolution
├── fenrir.java                           # Fenrir evolution
├── exchange.java                         # Pet exchange
└── ...

l2/gameserver/skills/effects/
└── EffectCubic.java                      # Cubic system

l2/gameserver/data/xml/holder/
└── PetDataHolder.java                    # Pet templates
```

---

## Pet Operations

### Spawn Pet

```java
// Summon pet from collar
ItemInstance collar = player.getInventory().getItemByItemId(PET_COLLAR_ID);
PetInstance pet = PetInstance.restore(collar, player);
pet.spawnMe(player.getLoc());
player.setSummon(pet);
```

### Unsummon Pet

```java
// Unsummon without store
pet.unSummon();

// Store pet to database and unsummon
pet.store();
pet.unSummon();
```

### Pet Info

```java
// Get pet
PetInstance pet = player.getPet();

// Pet stats
int level = pet.getLevel();
long exp = pet.getExp();
int maxHp = pet.getMaxHp();
int hunger = pet.getCurrentFeed();
```

---

## Pet Feeding

```java
// Feed pet
public void feedPet(Player player, int foodId) {
    PetInstance pet = player.getPet();
    if (pet == null) return;
    
    ItemInstance food = player.getInventory().getItemByItemId(foodId);
    if (food != null) {
        int feedValue = PetDataHolder.getInstance().getFeedBattle(pet.getNpcId(), foodId);
        pet.setCurrentFeed(pet.getCurrentFeed() + feedValue);
        player.getInventory().destroyItem("PetFeed", food, 1, player, null);
    }
}

// Auto-feed task (in PetInstance)
private class FeedTask implements Runnable {
    @Override
    public void run() {
        if (getCurrentFeed() <= 0) {
            // Pet is starving
            unSummon();
        } else {
            // Decrease hunger
            setCurrentFeed(getCurrentFeed() - 1);
        }
    }
}
```

---

## Pet Evolution

```java
package services.petevolve;

public class wolfevolve extends Functions implements ScriptFile {
    
    public void evolve(String[] args) {
        Player player = getSelf();
        PetInstance pet = player.getPet();
        
        if (pet == null || pet.getNpcId() != WOLF_ID) {
            player.sendMessage("You need a Wolf pet!");
            return;
        }
        
        if (pet.getLevel() < 55) {
            player.sendMessage("Pet must be level 55!");
            return;
        }
        
        // Check items
        if (!player.getInventory().destroyItemByItemId("Evolve", EVOLUTION_STONE, 1, player, null)) {
            player.sendMessage("You need an Evolution Stone!");
            return;
        }
        
        // Create new evolved pet
        ItemInstance newCollar = ItemFunctions.createItem(FENRIR_COLLAR_ID);
        // Transfer exp/level
        newCollar.setEnchantLevel(pet.getLevel());
        
        // Remove old pet
        pet.unSummon();
        player.getInventory().destroyItem("Evolve", pet.getControlItem(), player, null);
        
        // Give new collar
        player.getInventory().addItem(newCollar);
        player.sendMessage("Your Wolf evolved into Fenrir!");
    }
}
```

---

## Summons/Servitors

```java
// Summon is created by skill
public class Summon extends Skill {
    @Override
    public void useSkill(Creature activeChar, List<Creature> targets) {
        Player player = activeChar.getPlayer();
        
        // Create summon
        SummonInstance summon = new SummonInstance(
            IdFactory.getInstance().getNextId(),
            NpcHolder.getInstance().getTemplate(summonNpcId),
            player,
            this
        );
        
        summon.spawnMe(player.getLoc());
        player.setSummon(summon);
    }
}

// Servitor operations
SummonInstance summon = player.getSummon();
summon.doAttack(target);
summon.doCast(skill, target, false);
summon.unSummon();
```

---

## Cubics

```java
// Cubic effect from skill
public class EffectCubic extends Effect {
    
    @Override
    public void onStart() {
        Player player = (Player) getEffected();
        
        // Remove existing cubic of same type
        player.removeCubic(_cubicId);
        
        // Add new cubic
        CubicInstance cubic = new CubicInstance(player, _cubicId, _cubicLevel, _cubicPower);
        player.addCubic(cubic);
        
        // Start cubic AI
        cubic.startAction();
    }
    
    @Override
    public void onExit() {
        Player player = (Player) getEffected();
        player.removeCubic(_cubicId);
    }
}
```

---

## Pet Inventory

```java
// Pet has its own inventory
PetInventory petInv = pet.getInventory();

// Give item to pet
petInv.addItem(item);

// Transfer item to player
ItemInstance transferred = petInv.transferItem("Transfer", item, 1, player.getInventory());
```

---

## Best Practices

1. **Cleanup**: Always properly unsummon pets/summons
2. **Hunger**: Handle pet starvation
3. **Level sync**: Keep pet level visible in UI
4. **Database**: Save pet state on changes
5. **Death**: Handle pet death and resurrection

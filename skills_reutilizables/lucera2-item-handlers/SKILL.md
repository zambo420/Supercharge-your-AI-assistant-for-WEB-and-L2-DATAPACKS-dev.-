---
name: lucera2-item-handlers
description: >
  Item handlers: item use actions, item skills, consumables.
  Trigger: When working with item handlers, item use effects, or consumables.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [items, handlers]
  auto_invoke: "item handler, item use, consumable, item action"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating item use handlers
- Implementing consumable effects
- Working with item-activated skills
- Managing special item actions

---

## Directory Structure

```
handler/items/                        # Script item handlers (26 files)
├── BeastShot.java                    # Beast shots
├── SoulShots.java                    # Soul/beast shots
├── ScrollOfEscape.java               # Teleport scrolls
├── Potions.java                      # Potions
├── Books.java                        # Skill books
└── ...

l2/gameserver/handler/items/          # Core item handlers
├── IItemHandler.java                 # Handler interface
├── ItemHandler.java                  # Handler registry
└── impl/                             # Implementations
    └── ...
```

---

## Item Handler Pattern

```java
package handler.items;

import l2.gameserver.handler.items.IItemHandler;
import l2.gameserver.model.items.ItemInstance;
import l2.gameserver.model.Playable;
import l2.gameserver.model.Player;

public class MyItemHandler implements IItemHandler {
    
    private static final int[] ITEM_IDS = {1234, 1235, 1236};
    
    @Override
    public int[] getItemIds() {
        return ITEM_IDS;
    }
    
    @Override
    public boolean useItem(Playable playable, ItemInstance item, boolean ctrl) {
        if (!playable.isPlayer()) {
            return false;
        }
        
        Player player = (Player) playable;
        
        // Check conditions
        if (player.isInCombat()) {
            player.sendMessage("Cannot use in combat!");
            return false;
        }
        
        // Apply effect based on item ID
        switch (item.getItemId()) {
            case 1234:
                applyEffect1(player);
                break;
            case 1235:
                applyEffect2(player);
                break;
        }
        
        // Consume item
        if (!player.getInventory().destroyItem("ItemUse", item, 1, player, null)) {
            return false;
        }
        
        return true;
    }
    
    private void applyEffect1(Player player) {
        player.setCurrentHp(player.getMaxHp());
        player.sendMessage("Full HP restored!");
    }
}
```

---

## Registering Handler

```java
// In script onLoad()
@Override
public void onLoad() {
    ItemHandler.getInstance().registerItemHandler(new MyItemHandler());
}

// In script onReload()
@Override
public void onReload() {
    // Re-register handlers
    ItemHandler.getInstance().registerItemHandler(new MyItemHandler());
}
```

---

## Common Item Handlers

### Scroll of Escape

```java
public class ScrollOfEscape implements IItemHandler {
    
    @Override
    public boolean useItem(Playable playable, ItemInstance item, boolean ctrl) {
        Player player = (Player) playable;
        
        // Check restrictions
        if (player.isInCombat() || player.isInOlympiadMode()) {
            player.sendPacket(SystemMessage.getSystemMessage(SystemMessageId.CANNOT_ESCAPE));
            return false;
        }
        
        // Start teleport with animation
        player.abortCast(true, true);
        player.getAI().setIntention(CtrlIntention.AI_INTENTION_IDLE);
        
        // 5 second cast time
        player.doCast(SkillTable.getInstance().getInfo(ESCAPE_SKILL_ID, 1), player, false);
        
        // Consume scroll
        player.getInventory().destroyItem("Escape", item, 1, player, null);
        
        return true;
    }
}
```

### Potions

```java
public class Potions implements IItemHandler {
    
    @Override
    public boolean useItem(Playable playable, ItemInstance item, boolean ctrl) {
        Player player = (Player) playable;
        
        // Get potion skill from item
        Skill skill = item.getTemplate().getSkills()[0];
        
        // Apply effect
        skill.getEffects(player, player, false, false);
        
        // Consume
        player.getInventory().destroyItem("Potion", item, 1, player, null);
        
        // Play animation
        player.broadcastPacket(new MagicSkillUse(player, player, skill.getId(), 1, 0, 0));
        
        return true;
    }
}
```

### Skill Books

```java
public class Books implements IItemHandler {
    
    @Override
    public boolean useItem(Playable playable, ItemInstance item, boolean ctrl) {
        Player player = (Player) playable;
        
        int skillId = item.getTemplate().getItemSkillId();
        int skillLevel = item.getTemplate().getItemSkillLevel();
        
        // Check if can learn
        if (player.getKnownSkill(skillId) != null) {
            player.sendMessage("You already know this skill!");
            return false;
        }
        
        // Learn skill
        player.addSkill(SkillTable.getInstance().getInfo(skillId, skillLevel));
        player.sendSkillList();
        
        // Consume book
        player.getInventory().destroyItem("SkillBook", item, 1, player, null);
        
        player.sendMessage("Skill learned!");
        return true;
    }
}
```

---

## Item XML Configuration

```xml
<!-- Item with handler -->
<item id="1234" handler="handler.items.MyItemHandler">
    <set name="type" val="EtcItem" />
    <set name="name" val="Special Item" />
    <set name="is_tradable" val="false" />
    <set name="is_droppable" val="false" />
</item>
```

---

## Best Practices

1. **Null checks**: Always validate playable/player
2. **Consume last**: Consume item after success
3. **Cooldown**: Implement item use cooldowns
4. **Broadcast**: Send appropriate packets
5. **Restrictions**: Check combat/event states

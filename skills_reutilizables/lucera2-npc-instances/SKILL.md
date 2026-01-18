---
name: lucera2-npc-instances
description: >
  Custom NPC instance classes: specialized NPC behaviors and dialogs.
  Trigger: When creating or modifying custom NPC types or specialized NPC behaviors.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [npc, instances]
  auto_invoke: "custom NPC, NPC instance, specialized NPC, NPC dialog"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating new NPC types
- Modifying NPC dialogs and behaviors
- Implementing specialized NPC functionality
- Working with merchant, trainer, or gate keeper NPCs

---

## Directory Structure

```
npc/model/                           # Custom NPC instances (74 files)
├── ClassMasterInstance.java         # Class change NPC
├── UniversalNpcInstance.java        # Multi-purpose NPC
├── NewbieGuideInstance.java         # Newbie helper
├── FreyaDeaconKeeperInstance.java   # Freya instance
├── KamalokaGuardInstance.java       # Kamaloka entry
└── ...

l2/gameserver/model/instances/       # Core NPC instances (76 files)
├── NpcInstance.java                 # Base NPC class
├── MonsterInstance.java             # Monster base
├── MerchantInstance.java            # Shop NPC
├── VillageMasterInstance.java       # Class change
├── GuardInstance.java               # Guard NPC
├── DoorInstance.java                # Doors
├── PetInstance.java                 # Pets
├── SummonInstance.java              # Summons
└── ...
```

---

## NPC Instance Hierarchy

```
NpcInstance (base)
├── MonsterInstance
│   ├── RaidBossInstance
│   ├── MinionInstance
│   └── FestivalMonsterInstance
├── MerchantInstance
│   ├── FishermanInstance
│   └── ManorManagerInstance
├── VillageMasterInstance
├── OlympiadManagerInstance
├── TrainerInstance
└── Custom instances...
```

---

## Creating Custom NPC Instance

```java
package npc.model;

import l2.gameserver.model.Player;
import l2.gameserver.model.instances.NpcInstance;
import l2.gameserver.templates.npc.NpcTemplate;

public class MyCustomNpcInstance extends NpcInstance {
    
    public MyCustomNpcInstance(int objectId, NpcTemplate template) {
        super(objectId, template);
    }
    
    @Override
    public void onBypassFeedback(Player player, String command) {
        if (command.startsWith("my_action")) {
            handleMyAction(player, command);
            return;
        }
        
        super.onBypassFeedback(player, command);
    }
    
    @Override
    public void showChatWindow(Player player, int val, Object... arg) {
        // Custom dialog
        String html = getHtmlPath(val, player);
        html = html.replace("%npcname%", getName());
        
        showChatWindow(player, html);
    }
    
    private void handleMyAction(Player player, String command) {
        // Custom action logic
        player.sendMessage("Custom action executed!");
    }
}
```

---

## Universal NPC Pattern

```java
// UniversalNpcInstance.java - multi-purpose NPC
public class UniversalNpcInstance extends NpcInstance {
    
    @Override
    public void onBypassFeedback(Player player, String command) {
        if (command.startsWith("teleport:")) {
            handleTeleport(player, command);
        } else if (command.startsWith("buffer:")) {
            handleBuffer(player, command);
        } else if (command.startsWith("service:")) {
            handleService(player, command);
        } else {
            super.onBypassFeedback(player, command);
        }
    }
    
    private void handleTeleport(Player player, String command) {
        String[] coords = command.substring(9).split(",");
        int x = Integer.parseInt(coords[0]);
        int y = Integer.parseInt(coords[1]);
        int z = Integer.parseInt(coords[2]);
        
        player.teleToLocation(x, y, z);
    }
}
```

---

## Class Master Pattern

```java
// ClassMasterInstance.java
public class ClassMasterInstance extends NpcInstance {
    
    @Override
    public void showChatWindow(Player player, int val, Object... arg) {
        if (val == 0) {
            showMainPage(player);
        }
    }
    
    private void showMainPage(Player player) {
        StringBuilder html = new StringBuilder();
        html.append("<html><body>");
        html.append("<center><b>Class Master</b></center><br>");
        
        if (player.getClassId().level() < 3) {
            html.append("You can change your class!<br>");
            html.append("<button action=\"bypass -h npc_%objectId%_change_class\" value=\"Change Class\" .../>");
        } else {
            html.append("You have reached the highest class.");
        }
        
        html.append("</body></html>");
        showChatWindow(player, html.toString());
    }
    
    @Override
    public void onBypassFeedback(Player player, String command) {
        if (command.equals("change_class")) {
            changeClass(player);
            return;
        }
        super.onBypassFeedback(player, command);
    }
}
```

---

## Merchant NPC Pattern

```java
// MerchantInstance.java
public class MerchantInstance extends NpcInstance {
    
    @Override
    public void onBypassFeedback(Player player, String command) {
        if (command.startsWith("Buy")) {
            int listId = Integer.parseInt(command.substring(3).trim());
            showShopWindow(player, listId, true);
        } else if (command.startsWith("Sell")) {
            showShopWindow(player, 0, false);
        }
        super.onBypassFeedback(player, command);
    }
    
    protected void showShopWindow(Player player, int listId, boolean isBuy) {
        // Get trade list
        NpcTradeList list = TradeController.getInstance().getBuyList(listId);
        
        // Send shop window
        player.sendPacket(new ShopPreviewList(list, player));
    }
}
```

---

## Registering Custom NPC

In NPC XML data:
```xml
<npc id="50001" type="npc.model.MyCustomNpcInstance" name="My NPC" title="Custom">
    <set name="level" value="70" />
    <set name="aggro" value="0" />
    <!-- ... -->
</npc>
```

---

## Common NPC Methods

| Method | Purpose |
|--------|---------|
| `showChatWindow()` | Display dialog |
| `onBypassFeedback()` | Handle button clicks |
| `onAction()` | Handle targeting |
| `onActionShift()` | Handle shift+click |
| `getHtmlPath()` | Get HTML file path |
| `onSpawn()` | Called when spawned |
| `onDecay()` | Called when disappearing |

---

## HTML Dialog Pattern

```html
<!-- data/html-en/npc/my_npc/50001.htm -->
<html><body>
<center><b>%npcname%</b></center>
<br>
Welcome, %player_name%!<br>
<br>
<a action="bypass -h npc_%objectId%_Chat 1">Option 1</a><br>
<a action="bypass -h npc_%objectId%_service">Do Service</a><br>
<button action="bypass -h npc_%objectId%_buffer:full" value="Full Buff" width=100 height=25 />
</body></html>
```

---

## Best Practices

1. **Extend correctly**: Choose right parent class
2. **Call super**: Don't forget `super.onBypassFeedback()`
3. **Null checks**: Always validate player
4. **HTML paths**: Use consistent HTML naming
5. **Type in XML**: Register type in NPC data

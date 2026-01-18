---
name: lucera2-items-inventory
description: >
  Item system: inventory, warehouse, item instances, equipment.
  Trigger: When working with items, inventory, equipment, or item management.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [items, inventory]
  auto_invoke: "items, inventory, equipment, warehouse, item instance"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Working with player inventory
- Managing item creation/removal
- Implementing item effects
- Working with warehouse systems
- Equipment manipulation

---

## Directory Structure

```
l2/gameserver/model/items/           # Item system (38 files)
├── ItemInstance.java                # Item object
├── Inventory.java                   # Base inventory
├── PcInventory.java                 # Player inventory
├── PetInventory.java                # Pet inventory
├── Warehouse.java                   # Warehouse base
├── PcWarehouse.java                 # Player warehouse
├── ClanWarehouse.java               # Clan warehouse
├── ItemContainer.java               # Container base
├── ItemInfo.java                    # Item info transfer
├── TradeItem.java                   # Trade item
└── listeners/                       # Item listeners

l2/gameserver/templates/item/        # Item templates (39 files)
├── ItemTemplate.java                # Base template
├── WeaponTemplate.java              # Weapon
├── ArmorTemplate.java               # Armor
├── EtcItemTemplate.java             # Etc items
└── ...
```

---

## Item Operations

### Adding Items

```java
// Add item to player
player.addItem("reason", itemId, count, player, true);

// With source object
player.addItem("quest_reward", itemId, count, null, true);

// Silent (no message)
player.getInventory().addItem(itemId, count);
```

### Removing Items

```java
// Remove by item ID
player.getInventory().destroyItemByItemId("reason", itemId, count, player, null);

// Remove specific item instance
player.getInventory().destroyItem("reason", item, player, null);

// Check before remove
if (player.getInventory().getCountOf(itemId) >= count) {
    player.getInventory().destroyItemByItemId("purchase", itemId, count, player, null);
}
```

### Checking Items

```java
// Get item count
long count = player.getInventory().getCountOf(itemId);

// Check if has item
boolean hasItem = player.getInventory().getItemByItemId(itemId) != null;

// Get specific item
ItemInstance item = player.getInventory().getItemByItemId(itemId);
```

---

## Inventory Slots

```java
// Equipment slots
public enum Inventory {
    PAPERDOLL_UNDER,      // Underwear
    PAPERDOLL_HEAD,       // Helmet
    PAPERDOLL_FACE,       // Face accessory
    PAPERDOLL_HAIR,       // Hair accessory
    PAPERDOLL_NECK,       // Necklace
    PAPERDOLL_RHAND,      // Right hand (weapon)
    PAPERDOLL_LHAND,      // Left hand (shield)
    PAPERDOLL_REAR,       // Right earring
    PAPERDOLL_LEAR,       // Left earring
    PAPERDOLL_GLOVES,     // Gloves
    PAPERDOLL_CHEST,      // Chest armor
    PAPERDOLL_LEGS,       // Leg armor
    PAPERDOLL_FEET,       // Boots
    PAPERDOLL_BACK,       // Cloak
    PAPERDOLL_RFINGER,    // Right ring
    PAPERDOLL_LFINGER,    // Left ring
    PAPERDOLL_RBRACELET,  // Right bracelet
    PAPERDOLL_LBRACELET,  // Left bracelet
    // ... etc
}

// Get equipped item
ItemInstance weapon = player.getInventory().getPaperdollItem(Inventory.PAPERDOLL_RHAND);
```

---

## Equipping Items

```java
// Equip item
player.getInventory().equipItem(item);

// Unequip item
player.getInventory().unEquipItem(item);

// Check if can equip
boolean canEquip = item.getTemplate().checkCondition(player, item, true);

// Get all equipped items
ItemInstance[] equipped = player.getInventory().getPaperdoll();
```

---

## Warehouse Operations

```java
// Get player warehouse
Warehouse warehouse = player.getWarehouse();

// Deposit item
warehouse.addItem("deposit", item, player, null);

// Withdraw item
warehouse.destroyItem("withdraw", item, player, null);

// Get clan warehouse
ClanWarehouse clanWh = player.getClan().getWarehouse();
```

---

## Item Templates

```java
// Get item template
ItemTemplate template = ItemHolder.getInstance().getTemplate(itemId);

// Check item type
boolean isWeapon = template instanceof WeaponTemplate;
boolean isArmor = template instanceof ArmorTemplate;

// Get item properties
String name = template.getName();
int weight = template.getWeight();
long price = template.getReferencePrice();
ItemGrade grade = template.getGrade();
```

---

## Item Enchanting

```java
// Get enchant level
int enchant = item.getEnchantLevel();

// Set enchant level
item.setEnchantLevel(enchant + 1);

// Update database
item.updateDatabase();

// Notify client
player.sendPacket(new InventoryUpdate().addModifiedItem(item));
```

---

## Item Augmentation

```java
// Get augmentation
Augmentation aug = item.getAugmentation();

// Set augmentation
item.setAugmentation(new Augmentation(augId, augSkill));

// Remove augmentation
item.removeAugmentation();
```

---

## Item Listeners

```java
// Listen for equip/unequip
public class MyEquipListener implements OnEquipListener {
    
    @Override
    public void onEquip(int slot, ItemInstance item, Player player) {
        // Item equipped
        player.sendMessage("You equipped " + item.getName());
    }
    
    @Override
    public void onUnequip(int slot, ItemInstance item, Player player) {
        // Item unequipped
    }
}

// Register listener
player.getInventory().addListener(new MyEquipListener());
```

---

## Trade System

```java
// Create trade item
TradeItem tradeItem = new TradeItem(item, count, price);

// Start trade
player.setTransactionRequester(partner);
partner.setTransactionRequester(player);

// Execute trade
player.getInventory().transferItem(item, count, partner.getInventory());
```

---

## Best Practices

1. **Validation**: Always validate item exists before operations
2. **Database sync**: Call `updateDatabase()` after changes
3. **Client update**: Send `InventoryUpdate` packet
4. **Weight check**: Verify weight limit before adding
5. **Stack check**: Handle stackable vs non-stackable items
6. **Transaction**: Use inventory locks for trades

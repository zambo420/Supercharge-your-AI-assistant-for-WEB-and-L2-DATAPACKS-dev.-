---
name: lucera2-services
description: >
  Custom services: Community Board, ACP, Buffer, ItemBroker, and other game services.
  Trigger: When creating or modifying services in the services/ directory, or working with Community Board pages.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [services]
  auto_invoke: "services, Community Board, ACP, Buffer, ItemBroker"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating new game services
- Modifying existing services (Buffer, ACP, etc.)
- Working with Community Board pages and handlers
- Implementing NPC-based services

---

## Directory Structure

```
services/
├── community/              # Community Board
│   ├── CommunityBoard.java # Main CB handler
│   ├── ClanCommunity.java  # Clan pages
│   ├── RegionCommunity.java
│   ├── ManageFavorites.java
│   ├── ManageMemo.java
│   ├── PrivateMail.java
│   └── custom/             # Custom CB handlers
├── ACP.java                # Auto Consume Potions
├── Buffer.java             # NPC Buffer
├── ItemBroker.java         # Item trading
├── CommandClassMaster.java # Class change
└── ... (150+ files)
```

---

## Service Pattern

### Basic Service Structure

```java
package services;

import l2.gameserver.model.Player;
import l2.gameserver.model.instances.NpcInstance;
import l2.gameserver.scripts.Functions;

public class MyService extends Functions {
    
    // Called via bypass: bypass -h npc_%objectId%_myAction
    public void myAction(String[] args) {
        Player player = getSelf();      // Get player
        NpcInstance npc = getNpc();     // Get NPC (if applicable)
        
        if (player == null) {
            return;
        }
        
        // Service logic here
        show("My service response", player, npc);
    }
}
```

### Service with HTML Dialog

```java
public void showDialog(String[] args) {
    Player player = getSelf();
    NpcInstance npc = getNpc();
    
    StringBuilder html = new StringBuilder();
    html.append("<html><body>");
    html.append("<center>");
    html.append("<br>Welcome to My Service!<br>");
    html.append("<button action=\"bypass -h npc_%objectId%_doAction\" value=\"Execute\" width=100 height=25 />");
    html.append("</center>");
    html.append("</body></html>");
    
    show(html.toString(), player, npc);
}
```

---

## Community Board Pages

### HTML File Location

```
gameserver/data/html-en/scripts/services/community/pages/
├── index.htm           # CB Home page
├── gmshop/             # GM Shop pages
│   ├── index.htm
│   ├── weapons.htm
│   └── ...
└── custom/             # Custom pages
```

### CB HTML Template

```html
<html>
<body>
<br>
<center>
<table width=610 border=0 cellpadding=0 cellspacing=0>
<tr>
<td><center><font color="LEVEL">Page Title</font></center></td>
</tr>
</table>
<br>

<!-- Navigation buttons -->
<table>
<tr>
<td><button action="bypass _bbspage:gmshop/index" value="Home" width=100 height=25 back="L2UI_ct1.button_df" fore="L2UI_ct1.button_df" /></td>
<td><button action="bypass _bbspage:gmshop/weapons" value="Weapons" width=100 height=25 back="L2UI_ct1.button_df" fore="L2UI_ct1.button_df" /></td>
</tr>
</table>

<!-- Content -->
<br>
<table width=610>
<tr>
<td>Content goes here...</td>
</tr>
</table>

</center>
</body>
</html>
```

### CB Bypass Commands in HTML

```html
<!-- Load another CB page -->
<button action="bypass _bbspage:folder/pagename" value="Button Text" ... />

<!-- Open multisell -->
<button action="bypass _bbsmultisell:-1001" value="Shop" ... />

<!-- Multisell + return to page -->
<button action="bypass _bbsmultisell:-1001;_bbspage:gmshop/index" value="Buy" ... />

<!-- Call voiced command from CB -->
<button action="bypass -h user_acp" value="Open ACP" ... />

<!-- Link to web URL -->
<button action="bypass _bbslink:https://example.com" value="Website" ... />
```

---

## Key Services Reference

### ACP (Auto Consume Potions)

Location: `services/ACP.java`

```java
// Called via: bypass -h user_acp
// Shows HP/MP/CP potion auto-consume configuration
```

### Buffer

Location: `services/Buffer.java`

```java
// NPC-based buffer service
// Provides buff templates, custom buff schemes
// Uses: bypass -h npc_%objectId%_buff
```

### ItemBroker

Location: `services/ItemBroker.java`

```java
// Item auction/trading system
// Uses custom HTML pages and bypass commands
```

---

## HTML Placeholders

| Placeholder | Replaced With |
|-------------|---------------|
| `%objectId%` | NPC object ID |
| `%player_name%` | Player name |
| `%player_level%` | Player level |
| `%player_class%` | Player class |
| `%player_adena%` | Player adena count |

---

## Best Practices

1. **Extend Functions**: Services should extend `l2.gameserver.scripts.Functions`
2. **Null checks**: Always check `getSelf()` and `getNpc()` for null
3. **HTML paths**: Use correct paths relative to `data/html-en/`
4. **Bypass consistency**: Use consistent naming for bypass commands
5. **Error handling**: Provide user feedback for invalid operations
6. **Logging**: Log important service actions

---

## Common Operations

### Send HTML to Player

```java
// From service (extends Functions)
show(htmlContent, player, npc);

// Or directly
player.sendPacket(new NpcHtmlMessage(5).setHtml(htmlContent));
```

### Read HTML File

```java
String html = HtmCache.getInstance().getHtml("scripts/services/myservice.htm", player);
```

### Replace Placeholders

```java
html = html.replace("%player_name%", player.getName());
html = html.replace("%objectId%", String.valueOf(npc.getObjectId()));
```

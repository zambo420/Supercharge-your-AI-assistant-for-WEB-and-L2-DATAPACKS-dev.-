---
name: lucera2-handlers
description: >
  Admin commands, voiced commands (user_*), bypass handlers, and BBS commands.
  Trigger: When creating or modifying admin commands, voiced commands, bypass handlers, or Community Board commands.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [handlers, commands]
  auto_invoke: "admin commands, voiced commands, bypass, _bbs commands, user_ commands"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating admin commands (`//command`)
- Creating voiced commands (`user_command`)
- Working with bypass handlers (`bypass -h`)
- Implementing BBS/Community Board commands (`_bbs*`)

---

## Directory Structure

```
handler/
├── admincommands/          # //admin commands (29 files)
│   ├── AdminAdmin.java
│   ├── AdminTeleport.java
│   └── ...
├── usercommands/           # Voiced commands (user_*)
│   └── ClanWarsList.java
├── bypass/                 # Bypass handlers
│   └── Bypass.java
├── items/                  # Item handlers
└── petition/               # Petition system
```

---

## Command Types

| Type | Format | Handler Location | Example |
|------|--------|------------------|---------|
| Admin | `//command` | `handler/admincommands/` | `//teleport` |
| Voiced | `user_command` | `handler/usercommands/` or `services/` | `user_acp` |
| NPC Bypass | `bypass -h npc_%objectId%_Action` | NPC scripts | `bypass -h npc_%objectId%_Chat 1` |
| BBS Command | `bypass _bbscommand` | `services/community/` | `bypass _bbspage:gmshop` |

---

## Admin Command Pattern

Location: `handler/admincommands/Admin*.java`

```java
package handler.admincommands;

import l2.gameserver.handler.admincommands.IAdminCommandHandler;
import l2.gameserver.model.Player;

public class AdminExample implements IAdminCommandHandler {
    
    private static final String[] ADMIN_COMMANDS = {"admin_example", "admin_example2"};
    
    @Override
    public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar) {
        String command = comm.toString();
        
        if (command.equals("admin_example")) {
            // Command logic here
            activeChar.sendMessage("Example command executed!");
            return true;
        }
        
        return false;
    }
    
    @Override
    public Enum<?>[] getAdminCommandList() {
        // Return enum values matching ADMIN_COMMANDS
        return Commands.values();
    }
    
    private enum Commands {
        admin_example,
        admin_example2
    }
}
```

---

## Voiced Command Pattern

Location: `services/*.java` (registered as voiced command)

```java
package services;

import l2.gameserver.handler.voicecommands.IVoicedCommandHandler;
import l2.gameserver.handler.voicecommands.VoicedCommandHandler;
import l2.gameserver.model.Player;
import l2.gameserver.scripts.ScriptFile;

public class MyVoicedCommand implements IVoicedCommandHandler, ScriptFile {
    
    private static final String[] COMMANDS = {"mycommand"};
    
    @Override
    public boolean useVoicedCommand(String command, Player player, String args) {
        if (command.equals("mycommand")) {
            // Command logic
            player.sendMessage("My command executed!");
            return true;
        }
        return false;
    }
    
    @Override
    public String[] getVoicedCommandList() {
        return COMMANDS;
    }
    
    // ScriptFile methods for auto-registration
    @Override
    public void onLoad() {
        VoicedCommandHandler.getInstance().registerHandler(this);
    }
    
    @Override
    public void onReload() {}
    
    @Override
    public void onShutdown() {}
}
```

**Usage in HTML:**
```html
<button action="bypass -h user_mycommand">Execute</button>
```

---

## Bypass Handler Pattern

```java
// In NPC script or service
public void onBypassFeedback(Player player, String command) {
    if (command.startsWith("action_")) {
        String action = command.substring(7); // Remove "action_"
        handleAction(player, action);
    }
}
```

---

## BBS (Community Board) Commands

Location: `services/community/*.java`

### Common BBS Commands

| Command | Handler | Description |
|---------|---------|-------------|
| `_bbshome` | CommunityBoard | Home page |
| `_bbspage:path` | CommunityBoard | Load custom page |
| `_bbsmultisell:id` | CommunityBoard | Open multisell |
| `_bbsgetfav` | ManageFavorites | Get favorites |
| `_bbslink:url` | CommunityBoard | Open web link |

### BBS Bypass Pattern

```html
<!-- Navigate to page -->
<button action="bypass _bbspage:gmshop/weapons">Weapons</button>

<!-- Open multisell -->
<button action="bypass _bbsmultisell:-1001;_bbspage:gmshop/index">Buy & Return</button>

<!-- Call voiced command -->
<button action="bypass -h user_acp">Open ACP</button>
```

### Custom BBS Handler

```java
package services.community.custom;

import l2.gameserver.handler.bbs.ICommunityBoardHandler;
import l2.gameserver.model.Player;

public class MyCustomBBSHandler implements ICommunityBoardHandler {
    
    @Override
    public String[] getBypassCommands() {
        return new String[]{"_bbsmycustom"};
    }
    
    @Override
    public void onBypassCommand(Player player, String bypass) {
        // Handle _bbsmycustom command
        // Show HTML, process action, etc.
    }
}
```

---

## Registration

### Admin Commands
Registered via enum in handler class, loaded by server on startup.

### Voiced Commands
Register in `onLoad()` method:
```java
VoicedCommandHandler.getInstance().registerHandler(this);
```

### BBS Handlers
Register in CommunityBoard configuration or via script loader.

---

## Best Practices

1. **Permission checks**: Always verify player permissions for admin commands
2. **Null checks**: Check if player or target is null before operations
3. **Feedback**: Send messages to player about command results
4. **Logging**: Log admin actions for security
5. **HTML escaping**: Sanitize user input in bypass parameters

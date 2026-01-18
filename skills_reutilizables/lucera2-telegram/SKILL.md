---
name: lucera2-telegram
description: >
  Telegram bot integration: commands, monitoring, notifications.
  Trigger: When working with Telegram bot features or server monitoring.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [telegram, monitoring]
  auto_invoke: "telegram, bot, monitoring, notifications"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Configuring Telegram bot integration
- Adding new Telegram commands
- Implementing server monitoring
- Sending notifications to Telegram

---

## Directory Structure

```
l2/gameserver/handler/telegram/      # Telegram system (65 files)
├── TelegramApi.java                 # API communication
├── TelegramBot.java                 # Bot main class
├── TelegramBotProperties.java       # Configuration
├── TelegramCommandHandler.java      # Command handling
├── TelegramCommandRegistry.java     # Command registration
├── TelegramMonitoring.java          # Server monitoring
├── ITelegramCommandHandler.java     # Command interface
├── impl/                            # Command implementations (50 files)
│   ├── TelegramOnline.java
│   ├── TelegramStatus.java
│   └── ...
└── model/                           # Data models (8 files)
    ├── TelegramMessage.java
    └── TelegramUpdate.java
```

---

## Configuration

```properties
# config/telegram.properties
TELEGRAM_BOT_ENABLED = true
TELEGRAM_BOT_TOKEN = your_bot_token
TELEGRAM_BOT_USERNAME = YourBotName
TELEGRAM_ADMIN_CHAT_ID = 123456789
TELEGRAM_NOTIFY_ON_START = true
TELEGRAM_NOTIFY_ON_SHUTDOWN = true
```

---

## Creating Telegram Command

```java
package l2.gameserver.handler.telegram.impl;

import l2.gameserver.handler.telegram.ITelegramCommandHandler;
import l2.gameserver.handler.telegram.model.TelegramMessage;
import l2.gameserver.handler.telegram.TelegramApi;

public class TelegramMyCommand implements ITelegramCommandHandler {
    
    @Override
    public String getCommand() {
        return "/mycommand";
    }
    
    @Override
    public String getDescription() {
        return "My custom command description";
    }
    
    @Override
    public void handle(TelegramMessage message) {
        String chatId = message.getChatId();
        String[] args = message.getArgs();
        
        // Process command
        String response = "Hello from L2 Server!";
        
        // Send response
        TelegramApi.getInstance().sendMessage(chatId, response);
    }
    
    @Override
    public boolean isAdminOnly() {
        return false; // Set true for admin-only commands
    }
}
```

---

## Registering Commands

```java
// In TelegramCommandRegistry.java or bot initialization
TelegramCommandRegistry.getInstance().register(new TelegramMyCommand());
```

---

## Sending Notifications

```java
// Send to admin chat
TelegramApi.getInstance().sendMessage(
    Config.TELEGRAM_ADMIN_CHAT_ID,
    "Server notification: Something happened!"
);

// Send to specific chat
TelegramApi.getInstance().sendMessage(chatId, "Your message");

// Send with formatting
String message = "*Bold* message with _italic_ text";
TelegramApi.getInstance().sendMessage(chatId, message, true); // parse markdown
```

---

## Server Monitoring

```java
// TelegramMonitoring.java sends periodic updates
public class TelegramMonitoring {
    
    public void sendStatusUpdate() {
        StringBuilder sb = new StringBuilder();
        sb.append("🖥 *Server Status*\n");
        sb.append("Players: ").append(World.getPlayers().size()).append("\n");
        sb.append("Uptime: ").append(getUptime()).append("\n");
        sb.append("Memory: ").append(getMemoryUsage()).append("\n");
        
        TelegramApi.getInstance().sendToAdmins(sb.toString());
    }
}
```

---

## Common Commands

| Command | Description |
|---------|-------------|
| `/online` | Show online players count |
| `/status` | Show server status |
| `/restart` | Restart server (admin) |
| `/announce` | Send in-game announce (admin) |
| `/ban` | Ban player (admin) |
| `/unban` | Unban player (admin) |
| `/kick` | Kick player (admin) |

---

## Message Models

```java
// TelegramMessage contains
public class TelegramMessage {
    private String chatId;
    private String text;
    private String username;
    private String[] args;
    
    public String getCommand() { ... }
    public String[] getArgs() { ... }
}
```

---

## Event Notifications

```java
// Notify on player login
PlayerListener.addOnEnter(player -> {
    TelegramApi.getInstance().sendToAdmins(
        String.format("Player %s logged in", player.getName())
    );
});

// Notify on siege
siege.addListener(event -> {
    TelegramApi.getInstance().sendToAdmins(
        String.format("Siege of %s has started!", castle.getName())
    );
});
```

---

## Best Practices

1. **Rate limiting**: Don't spam Telegram API
2. **Error handling**: Handle API errors gracefully
3. **Admin verification**: Verify admin rights for sensitive commands
4. **Formatting**: Use Markdown for better readability
5. **Logging**: Log all admin commands

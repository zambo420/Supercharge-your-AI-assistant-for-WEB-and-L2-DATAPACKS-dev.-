---
name: lucera2-network
description: >
  Network packet handling: client/server packets, packet structure, telnet, auth communication.
  Trigger: When working with network packets, client/server communication, or protocol handling.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [network, packets]
  auto_invoke: "network packets, clientpackets, serverpackets, telnet, protocol"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating or modifying client packets (received from client)
- Creating or modifying server packets (sent to client)
- Working with auth server communication
- Implementing telnet commands
- Understanding network protocol structure

---

## Directory Structure

```
l2/gameserver/network/
├── l2/                         # Main packet handling (1099 files)
│   ├── c2s/                    # Client → Server packets
│   ├── s2c/                    # Server → Client packets
│   └── Components.java         # Packet components
├── authcomm/                   # Auth server communication (24 files)
│   ├── as2gs/                  # Auth → Game packets
│   └── gs2as/                  # Game → Auth packets
├── telnet/                     # Telnet interface (44 files)
│   ├── commands/               # Telnet commands
│   └── TelnetServer.java
└── pfilter/                    # Packet filtering (12 files)
```

---

## Packet Types

| Direction | Package | Description |
|-----------|---------|-------------|
| Client → Server | `network.l2.c2s` | Request packets from client |
| Server → Client | `network.l2.s2c` | Response/update packets to client |
| Auth → Game | `network.authcomm.as2gs` | Login server to game server |
| Game → Auth | `network.authcomm.gs2as` | Game server to login server |

---

## Client Packet Pattern

Location: `l2/gameserver/network/l2/c2s/`

```java
package l2.gameserver.network.l2.c2s;

import l2.gameserver.model.Player;
import l2.gameserver.network.l2.GameClient;

public class RequestAction extends L2GameClientPacket {
    
    private int _actionId;
    
    @Override
    protected void readImpl() {
        // Read data from client
        _actionId = readD(); // Read 4-byte integer
    }
    
    @Override
    protected void runImpl() {
        // Process the packet
        Player player = getClient().getActiveChar();
        if (player == null) {
            return;
        }
        
        // Handle the action
        handleAction(player, _actionId);
    }
}
```

---

## Server Packet Pattern

Location: `l2/gameserver/network/l2/s2c/`

```java
package l2.gameserver.network.l2.s2c;

import l2.gameserver.model.Player;
import l2.gameserver.network.l2.GameClient;

public class SystemMessage extends L2GameServerPacket {
    
    private int _messageId;
    private String _text;
    
    public SystemMessage(int messageId) {
        _messageId = messageId;
    }
    
    public SystemMessage addString(String text) {
        _text = text;
        return this;
    }
    
    @Override
    protected void writeImpl() {
        writeC(0x64);           // Packet opcode
        writeD(_messageId);     // Message ID
        writeS(_text);          // String parameter
    }
}
```

---

## Read/Write Methods

### Reading (Client Packets)

| Method | Size | Description |
|--------|------|-------------|
| `readC()` | 1 byte | Read byte |
| `readH()` | 2 bytes | Read short |
| `readD()` | 4 bytes | Read int |
| `readQ()` | 8 bytes | Read long |
| `readF()` | 8 bytes | Read double |
| `readS()` | variable | Read string (null-terminated) |
| `readB(size)` | variable | Read byte array |

### Writing (Server Packets)

| Method | Size | Description |
|--------|------|-------------|
| `writeC(val)` | 1 byte | Write byte |
| `writeH(val)` | 2 bytes | Write short |
| `writeD(val)` | 4 bytes | Write int |
| `writeQ(val)` | 8 bytes | Write long |
| `writeF(val)` | 8 bytes | Write double |
| `writeS(str)` | variable | Write string |
| `writeB(arr)` | variable | Write byte array |

---

## Sending Packets

```java
// Send to single player
player.sendPacket(new SystemMessage(SystemMessageId.MESSAGE));

// Send to multiple players
for (Player p : players) {
    p.sendPacket(new MyPacket());
}

// Broadcast to all
World.getInstance().getPlayers().forEach(p -> p.sendPacket(new MyPacket()));
```

---

## Common Packets Reference

| Packet | Direction | Purpose |
|--------|-----------|---------|
| `NpcHtmlMessage` | Server | Send HTML dialog to player |
| `SystemMessage` | Server | Send system message |
| `CreatureSay` | Server | Send chat message |
| `StatusUpdate` | Server | Update HP/MP/CP bars |
| `UserInfo` | Server | Update player info |
| `RequestBypassToServer` | Client | Bypass command from HTML |
| `RequestAction` | Client | Action request |

---

## Best Practices

1. **Null checks**: Always check if player is null before processing
2. **Packet order**: Some packets must be sent in order
3. **Thread safety**: Packets may be processed in different threads
4. **Validation**: Validate all data read from client
5. **Opcode uniqueness**: Each packet type has unique opcode

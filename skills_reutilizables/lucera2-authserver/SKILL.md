---
name: lucera2-authserver
description: >
  Login/Authentication server: account management, IP bans, game server communication.
  Trigger: When working with login server, authentication, or account management.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [authserver]
  auto_invoke: "login server, auth server, authentication, account management"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Working with login server code
- Implementing account management
- Managing IP bans
- Handling game server registration
- Working with authentication/encryption

---

## Directory Structure

```
l2/authserver/                   # Auth server (83 files)
├── AuthServer.java              # Main server class
├── Config.java                  # Auth server config
├── AccountManager.java          # Account operations
├── ClientManager.java           # Client connections
├── GameServerManager.java       # Game server registry
├── IpBanManager.java            # IP ban system
├── Shutdown.java                # Graceful shutdown
├── ThreadPoolManager.java       # Thread management
├── accounts/                    # Account classes (4 files)
│   ├── Account.java
│   └── SessionKey.java
├── crypt/                       # Encryption (7 files)
│   ├── PasswordCrypt.java
│   ├── LoginCrypt.java
│   └── ScrambledKeyPair.java
├── database/                    # Database access (2 files)
├── network/                     # Network handling (53 files)
│   ├── l2/                      # Login protocol
│   │   ├── L2LoginClient.java
│   │   ├── L2LoginPacketHandler.java
│   │   ├── c2s/                 # Client packets
│   │   └── s2c/                 # Server packets
│   └── gameservercon/           # Game server connection
└── utils/                       # Utilities (2 files)
```

---

## Auth Server Flow

```
[Client] → [AuthServer] → [Authenticate] → [GameServerList] → [PlayOk] → [GameServer]
```

1. Client connects to AuthServer
2. AuthServer sends Init packet (with crypt key)
3. Client sends login credentials
4. AuthServer verifies account
5. AuthServer sends game server list
6. Client chooses server
7. AuthServer sends PlayOk to GameServer
8. Client connects to GameServer

---

## Main Classes

### AuthServer.java

```java
package l2.authserver;

public class AuthServer {
    
    private static AuthServer _instance;
    
    public static AuthServer getInstance() {
        return _instance;
    }
    
    public static void main(String[] args) {
        _instance = new AuthServer();
        _instance.start();
    }
    
    private void start() {
        // Load config
        Config.load();
        
        // Initialize database
        DatabaseFactory.getInstance();
        
        // Start listening for connections
        L2LoginServer.getInstance().start();
        
        // Register game servers
        GameServerManager.getInstance().load();
    }
}
```

---

## Account Management

```java
package l2.authserver;

public class AccountManager {
    
    // Create new account
    public boolean createAccount(String login, String password) {
        String hashedPass = PasswordCrypt.getInstance().hash(password);
        
        // Insert to database
        return AccountDAO.getInstance().insert(login, hashedPass);
    }
    
    // Verify login
    public Account authenticate(String login, String password) {
        Account account = AccountDAO.getInstance().getByLogin(login);
        
        if (account == null) {
            return null; // Account not found
        }
        
        if (account.isBanned()) {
            return null; // Account banned
        }
        
        String hashedPass = PasswordCrypt.getInstance().hash(password);
        if (!account.getPassword().equals(hashedPass)) {
            return null; // Wrong password
        }
        
        return account;
    }
    
    // Ban account
    public void banAccount(String login, long duration) {
        Account account = AccountDAO.getInstance().getByLogin(login);
        if (account != null) {
            account.setBanExpireTime(System.currentTimeMillis() + duration);
            AccountDAO.getInstance().update(account);
        }
    }
}
```

---

## IP Ban Management

```java
package l2.authserver;

public class IpBanManager {
    
    private Map<String, Long> _bannedIps = new ConcurrentHashMap<>();
    
    // Check if IP is banned
    public boolean isBanned(String ip) {
        Long banEnd = _bannedIps.get(ip);
        if (banEnd == null) {
            return false;
        }
        
        if (System.currentTimeMillis() > banEnd) {
            _bannedIps.remove(ip);
            return false;
        }
        
        return true;
    }
    
    // Ban IP
    public void banIp(String ip, long duration) {
        _bannedIps.put(ip, System.currentTimeMillis() + duration);
        // Also save to database
        IpBanDAO.getInstance().insert(ip, duration);
    }
    
    // Unban IP
    public void unbanIp(String ip) {
        _bannedIps.remove(ip);
        IpBanDAO.getInstance().delete(ip);
    }
}
```

---

## Game Server Registration

```java
package l2.authserver;

public class GameServerManager {
    
    private Map<Integer, GameServerInfo> _gameServers = new HashMap<>();
    
    // Register game server
    public void registerGameServer(int id, GameServerInfo info) {
        _gameServers.put(id, info);
    }
    
    // Get server list for client
    public List<GameServerInfo> getServerList(Account account) {
        List<GameServerInfo> list = new ArrayList<>();
        
        for (GameServerInfo server : _gameServers.values()) {
            if (server.isOnline()) {
                // Add server with character count for this account
                int charCount = getCharacterCount(account, server.getId());
                server.setCharCount(charCount);
                list.add(server);
            }
        }
        
        return list;
    }
}
```

---

## Encryption

```java
package l2.authserver.crypt;

public class LoginCrypt {
    
    private static final byte[] STATIC_BLOWFISH_KEY = { ... };
    
    // Decrypt client packet
    public boolean decrypt(byte[] data, int offset, int size) {
        // Blowfish decrypt
        // XOR operation
        // Checksum verification
        return true;
    }
    
    // Encrypt server packet
    public void encrypt(byte[] data, int offset, int size) {
        // Add checksum
        // XOR operation
        // Blowfish encrypt
    }
}

public class PasswordCrypt {
    
    // Hash password (usually SHA or MD5 + salt)
    public String hash(String password) {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hash = md.digest(password.getBytes());
        return Base64.getEncoder().encodeToString(hash);
    }
}
```

---

## Auth Server Config

```java
// config/authserver.properties
LOGIN_PORT=2106
LOGIN_BIND_ADDRESS=*
ACCEPT_NEW_GAMESERVER=false
AUTO_CREATE_ACCOUNTS=false
FLOOD_PROTECTION=true
FAST_CONNECTION_LIMIT=15
NORMAL_CONNECTION_TIME=700
FAST_CONNECTION_TIME=350
MAX_CONNECTION_PER_IP=50
```

---

## Login Protocol Packets

### Client → Server

| Packet | Description |
|--------|-------------|
| `RequestAuthLogin` | Login request with credentials |
| `RequestServerLogin` | Select game server |
| `RequestServerList` | Request server list |
| `RequestGGAuth` | GameGuard auth |

### Server → Client

| Packet | Description |
|--------|-------------|
| `Init` | Send crypt key and protocol |
| `LoginOk` | Login successful, session key |
| `LoginFail` | Login failed with reason |
| `ServerList` | List of game servers |
| `PlayOk` | Ok to connect to game server |
| `PlayFail` | Cannot connect to game server |

---

## Best Practices

1. **Security**: Never log passwords, use proper hashing
2. **Rate limiting**: Implement login attempt limits
3. **IP bans**: Auto-ban after failed attempts
4. **Encryption**: Keep encryption keys secure
5. **Logging**: Log all authentication events
6. **Cleanup**: Clean expired bans/sessions regularly

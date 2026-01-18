---
name: authserver-config
description: >
  Working with Login/Auth server configuration and setup.
  Trigger: When editing authserver config files or managing account creation.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [authserver, login, config]
  auto_invoke: "auth config, login server, account creation, banned ips"
allowed-tools: Read, Edit, Write, Glob, Grep
---

## When to Use

- Editing authserver configuration
- Managing database connections for accounts
- Configuring banned IPs
- Setting up account creation
- Network configuration for login server

---

## Directory Structure

```
authserver/
├── config/
│   ├── authserver.properties     # Main auth server config
│   ├── database.properties       # Database connection
│   └── banned_ip.cfg             # Banned IP addresses
├── sql/
│   ├── accounts.sql              # Account table structure
│   └── server_list.sql           # Game servers list
├── log/                          # Log files
├── server.jar                    # Auth server JAR
├── StartAuthServer.bat           # Windows startup
├── StartAuthServer.sh            # Linux startup
└── CreateAccount.bat             # Account creation tool
```

---

## Configuration Files

### authserver.properties

```properties
# Network Configuration
authserver.port = 2106
authserver.host = 0.0.0.0

# Security
auto.create.accounts = true
login.wrong.attemps = 3
ban.time = 600

# Connection to Gameserver
gameserver.connection.port = 9014
gameserver.connection.host = 127.0.0.1

# Session
session.timeout = 60000

# Flood Protection
flood.protection.enabled = true
flood.protection.fast.connection.limit = 15
flood.protection.normal.connection.limit = 700
```

### database.properties

```properties
# Database Configuration
database.driver = com.mysql.cj.jdbc.Driver
database.url = jdbc:mysql://localhost:3306/l2jauth?useSSL=false&serverTimezone=UTC
database.user = root
database.password = your_password
database.pool.min = 2
database.pool.max = 10
```

### banned_ip.cfg

```
# Banned IP Addresses
# One IP per line, supports wildcards

# 192.155.1.*
# 10.0.0.1
```

---

## Database Tables

### accounts

```sql
CREATE TABLE accounts (
    login VARCHAR(45) NOT NULL,
    password VARCHAR(45) NOT NULL,
    access_level INT DEFAULT 0,
    last_server INT DEFAULT 1,
    last_ip VARCHAR(20),
    last_active BIGINT DEFAULT 0,
    PRIMARY KEY (login)
);
```

### servers

```sql
CREATE TABLE servers (
    id INT AUTO_INCREMENT,
    name VARCHAR(45),
    host VARCHAR(45),
    port INT,
    age_limit INT DEFAULT 0,
    pvp TINYINT DEFAULT 0,
    max_online INT DEFAULT 1000,
    status TINYINT DEFAULT 0,
    PRIMARY KEY (id)
);
```

---

## Common Tasks

### Create New Account

```batch
# Windows
CreateAccount.bat

# Or via SQL
INSERT INTO accounts (login, password) 
VALUES ('username', SHA1('password'));
```

### Change Access Level (Admin)

```sql
UPDATE accounts SET access_level = 100 WHERE login = 'admin';
```

Access levels:
| Level | Description |
|-------|-------------|
| 0 | Normal player |
| 1 | VIP |
| 100 | Full admin |
| -100 | Banned |

### Ban IP Address

Add to `config/banned_ip.cfg`:
```
123.33.67.89
```

### Connect Multiple Game Servers

Edit `servers` table:
```sql
INSERT INTO servers (name, host, port, max_online) 
VALUES ('Server 1', '192.555.1.100', 7777, 1000);

INSERT INTO servers (name, host, port, max_online) 
VALUES ('Server 2', '192.555.1.101', 7778, 500);
```

---

## Startup Scripts

### StartAuthServer.bat (Windows)

```batch
@echo off
java -Xmx256m -jar server.jar
pause
```

### StartAuthServer.sh (Linux)

```bash
#!/bin/bash
java -Xmx256m -jar server.jar
```

---

## Ports

| Port | Purpose |
|------|---------|
| 2106 | Client connections (login) |
| 9014 | Gameserver connections |

---

## Troubleshooting

### "Cannot connect to login server"
- Check port 2106 is open
- Verify `authserver.host` setting
- Check firewall rules

### "Account not found"
- Verify `auto.create.accounts = true` or create manually
- Check database connection

### Gameserver not appearing
- Verify gameserver is registered in `servers` table
- Check port 9014 communication
- Verify `gameserver.connection.host` matches

---
name: lucera2-data
description: >
  Data system: XML/SQL parsers, holders, HTML templates, config loading.
  Trigger: When working with data files, XML parsing, SQL data access, or config loading.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [data]
  auto_invoke: "data parser, XML holder, SQL DAO, HTML template, config loading"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating data parsers for XML files
- Working with SQL data access (DAO)
- Implementing data holders
- Loading HTML templates
- Managing configuration files

---

## Directory Structure

```
l2/gameserver/data/              # Data parsers (101 files)
├── BoatHolder.java              # Parsed data holder
├── StringHolder.java            # String messages
├── htm/                         # HTML template handling
│   ├── HtmCache.java            # HTML caching
│   └── HtmContext.java          # Template context
└── xml/                         # XML parsers (97 files)
    ├── holder/                  # Data holders
    │   ├── NpcHolder.java
    │   ├── ItemHolder.java
    │   └── ...
    └── parser/                  # XML document parsers
        ├── NpcParser.java
        └── ...

l2/gameserver/dao/               # SQL data access (32 files)
├── CharacterDAO.java
├── ItemsDAO.java
├── SkillsDAO.java
└── ...

l2/gameserver/tables/            # Legacy data tables
├── SkillTable.java
└── ...
```

---

## XML Data Flow

```
[XML File] → [Parser] → [Holder] → [Usage]
```

1. **XML File**: `data/npc/12345.xml`
2. **Parser**: `NpcParser.java` reads and parses
3. **Holder**: `NpcHolder.java` stores parsed data
4. **Usage**: `NpcHolder.getInstance().getTemplate(12345)`

---

## XML Parser Pattern

```java
package l2.gameserver.data.xml.parser;

import org.w3c.dom.*;
import l2.gameserver.data.xml.holder.MyHolder;

public class MyParser extends AbstractFileParser<MyHolder> {
    
    private static final MyParser _instance = new MyParser();
    
    public static MyParser getInstance() {
        return _instance;
    }
    
    protected MyParser() {
        super(MyHolder.getInstance());
    }
    
    @Override
    public File getXMLDir() {
        return new File("data/my_data/");
    }
    
    @Override
    public boolean isIgnored(File f) {
        return false;
    }
    
    @Override
    public String getDTDFileName() {
        return "my_data.dtd";
    }
    
    @Override
    protected void readData(Element rootElement) throws Exception {
        for (Element element : XmlUtils.getChildrenByName(rootElement, "item")) {
            int id = Integer.parseInt(element.getAttribute("id"));
            String name = element.getAttribute("name");
            int value = Integer.parseInt(element.getAttribute("value"));
            
            MyData data = new MyData(id, name, value);
            getHolder().addData(data);
        }
    }
}
```

---

## Data Holder Pattern

```java
package l2.gameserver.data.xml.holder;

import java.util.*;

public class MyHolder extends AbstractHolder {
    
    private static final MyHolder _instance = new MyHolder();
    
    public static MyHolder getInstance() {
        return _instance;
    }
    
    private Map<Integer, MyData> _data = new HashMap<>();
    
    public void addData(MyData data) {
        _data.put(data.getId(), data);
    }
    
    public MyData getData(int id) {
        return _data.get(id);
    }
    
    public Collection<MyData> getAllData() {
        return _data.values();
    }
    
    @Override
    public int size() {
        return _data.size();
    }
    
    @Override
    public void clear() {
        _data.clear();
    }
}
```

---

## DAO Pattern (SQL)

```java
package l2.gameserver.dao;

import java.sql.*;
import l2.commons.db.DatabaseFactory;

public class MyDAO {
    
    private static final MyDAO _instance = new MyDAO();
    
    public static MyDAO getInstance() {
        return _instance;
    }
    
    private static final String SELECT_SQL = 
        "SELECT * FROM my_table WHERE char_id = ?";
    private static final String INSERT_SQL = 
        "INSERT INTO my_table (char_id, value) VALUES (?, ?)";
    private static final String UPDATE_SQL = 
        "UPDATE my_table SET value = ? WHERE char_id = ?";
    
    public MyData load(int charId) {
        try (Connection con = DatabaseFactory.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT_SQL)) {
            
            ps.setInt(1, charId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new MyData(
                        rs.getInt("char_id"),
                        rs.getInt("value")
                    );
                }
            }
        } catch (SQLException e) {
            _log.error("Error loading data", e);
        }
        return null;
    }
    
    public void save(MyData data) {
        try (Connection con = DatabaseFactory.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(UPDATE_SQL)) {
            
            ps.setInt(1, data.getValue());
            ps.setInt(2, data.getCharId());
            
            if (ps.executeUpdate() == 0) {
                // No rows updated, insert new
                insert(data);
            }
        } catch (SQLException e) {
            _log.error("Error saving data", e);
        }
    }
}
```

---

## HTML Cache

```java
import l2.gameserver.cache.HtmCache;

// Get HTML content
String html = HtmCache.getInstance().getNotNull(
    "scripts/services/my_service.htm", 
    player
);

// With language support
String html = HtmCache.getInstance().getNotNull(
    "scripts/services/my_service.htm",
    player.getLang()
);

// Replace placeholders
html = html.replace("%player_name%", player.getName());
html = html.replace("%value%", String.valueOf(value));
```

---

## Config Loading

```java
import l2.gameserver.Config;

// Access config values (defined in Config.java)
boolean enabled = Config.MY_FEATURE_ENABLED;
int value = Config.MY_FEATURE_VALUE;
double rate = Config.MY_FEATURE_RATE;

// Config is loaded from:
// config/server.properties
// config/rates.properties
// config/events.properties
// etc.
```

---

## Common Data Tables

| Table | Holder | Description |
|-------|--------|-------------|
| NPCs | `NpcHolder` | NPC templates |
| Items | `ItemHolder` | Item templates |
| Skills | `SkillTable` | Skill definitions |
| Recipes | `RecipeHolder` | Craft recipes |
| Spawns | `SpawnHolder` | NPC spawn locations |
| Zones | `ZoneHolder` | Zone definitions |

---

## Data Loading Order

On server startup:
1. Config files
2. XML data (NPCs, Items, Skills, etc.)
3. SQL data (characters, clans, etc.)
4. Scripts

```java
// In GameServer.java startup sequence
Config.load();
NpcParser.getInstance().load();
ItemParser.getInstance().load();
SkillsParser.getInstance().load();
// ... etc
```

---

## Best Practices

1. **Singleton**: Use singleton pattern for holders
2. **Caching**: Cache frequently accessed data
3. **Lazy loading**: Load on first access if possible
4. **Connection pooling**: Use DatabaseFactory for SQL
5. **Error handling**: Log and handle parse errors gracefully
6. **Clear on reload**: Implement `clear()` for hot reload

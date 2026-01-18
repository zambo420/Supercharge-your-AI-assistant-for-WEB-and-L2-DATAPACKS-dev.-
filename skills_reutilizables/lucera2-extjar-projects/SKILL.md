---
name: lucera2-extjar-projects
description: >
  Creating .ext.jar extension projects: custom scripts, instances, services.
  Trigger: When creating new .ext.jar projects or custom script JARs.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [extjar, projects, compilation]
  auto_invoke: "ext.jar, new project, custom jar, script project"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating new `.ext.jar` extension projects
- Adding custom scripts without modifying core JARs
- Setting up IntelliJ IDEA for Lucera2 development
- Compiling custom instances, services, or handlers

---

## What are .ext.jar files?

Extension JARs that load dynamically into the Lucera2 server:

| JAR Type | Purpose | Modifiable |
|----------|---------|------------|
| `server.jar` | Core gameserver | ❌ NO |
| `scripts.jar` | Base scripts | ❌ NO |
| `*.ext.jar` | Custom extensions | ✅ YES |

The server loads all `.ext.jar` files from the scripts directory at startup.

---

## Project Structure

```
MyProject/
├── src/
│   ├── instances/           # Reflection-based instances
│   │   └── MyInstance.java
│   └── services/            # Bypass command handlers
│       └── MyService.java
├── lib/
│   ├── server.jar           # Copy from datapack
│   └── scripts.jar          # Copy from datapack
├── build.xml                # Ant build script
└── README.md
```

---

## build.xml Template

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project name="MyProject" default="build" basedir=".">
    
    <property name="src.dir" value="src"/>
    <property name="build.dir" value="build"/>
    <property name="lib.dir" value="lib"/>
    <property name="jar.name" value="MyProject.ext.jar"/>
    <property name="java.source" value="1.8"/>
    <property name="java.target" value="1.8"/>
    
    <path id="project.classpath">
        <fileset dir="${lib.dir}">
            <include name="**/*.jar"/>
        </fileset>
    </path>
    
    <target name="clean">
        <delete dir="${build.dir}"/>
        <delete file="${jar.name}"/>
    </target>
    
    <target name="init">
        <mkdir dir="${build.dir}"/>
    </target>
    
    <target name="compile" depends="init">
        <javac srcdir="${src.dir}" destdir="${build.dir}"
               source="${java.source}" target="${java.target}"
               encoding="UTF-8" debug="true" includeantruntime="false">
            <classpath refid="project.classpath"/>
        </javac>
    </target>
    
    <target name="build" depends="compile">
        <jar destfile="${jar.name}" basedir="${build.dir}"/>
        <echo message="Created: ${jar.name}"/>
    </target>
    
    <target name="rebuild" depends="clean, build"/>
    
</project>
```

---

## Service Class Pattern (for bypass commands)

Services MUST extend `Functions` to access `getSelf()`:

```java
package services;

import l2.gameserver.model.Player;
import l2.gameserver.scripts.Functions;

public class MyService extends Functions {
    
    // Method name = bypass command name
    // NO arguments (not String[] args)
    public void myCommand() {
        Player player = this.getSelf();  // Use this.getSelf()
        if (player == null) {
            return;
        }
        
        // Your logic here
        player.sendMessage("Command executed!");
    }
}
```

**Bypass usage:**
```
bypass -h scripts_services.MyService:myCommand
```

---

## Instance Class Pattern (for reflections)

Instances extend `Reflection` and implement `ScriptFile`:

```java
package instances;

import l2.gameserver.model.Player;
import l2.gameserver.model.entity.Reflection;
import l2.gameserver.scripts.ScriptFile;
import l2.gameserver.utils.Location;

public class MyInstance extends Reflection implements ScriptFile {
    
    private static final Location SPAWN_LOC = new Location(x, y, z);
    
    @Override
    public void onPlayerEnter(Player player) {
        super.onPlayerEnter(player);
        player.sendMessage("Welcome!");
    }
    
    @Override
    public void onPlayerExit(Player player) {
        super.onPlayerExit(player);
        if (getPlayers().isEmpty()) {
            startCollapseTimer(60000);
        }
    }
    
    public void start(Player player) {
        setName("My Instance - " + player.getName());
        setTeleportLoc(SPAWN_LOC);
        setReturnLoc(SPAWN_LOC);
        startCollapseTimer(3600000); // 1 hour
        
        player.setReflection(this);
        player.teleToLocation(SPAWN_LOC, this);
    }
    
    @Override public void onLoad() {}
    @Override public void onReload() {}
    @Override public void onShutdown() {}
}
```

---

## IntelliJ IDEA Setup

### 1. Open Project
File → Open → Select project folder

### 2. Configure Project Structure
File → Project Structure (Ctrl+Alt+Shift+S):
- **Project SDK**: Java 8+
- **Project language level**: 8
- **Modules**: Mark `src` as Sources Root

### 3. Add Libraries
Right-click `lib/` → Add as Library

### 4. Run Ant Build
- View → Tool Windows → Ant
- Click + → Select `build.xml`
- Double-click `build`

---

## Common Errors

### "Cannot locate declared field X.npc"
**Cause**: Calling service method from wrong class (e.g., from Reflection instead of Functions)
**Solution**: Create separate service class that extends Functions

### "non-static method getSelf() cannot be referenced from static context"
**Cause**: Using `Functions.getSelf()` instead of `this.getSelf()`
**Solution**: Use `this.getSelf()` in classes that extend Functions

### "No such method X.methodName()"
**Cause**: Wrong bypass path or method signature
**Solution**: Verify package name matches bypass path:
- `package services;` → `bypass -h scripts_services.ClassName:method`
- `package instances;` → `bypass -h scripts_instances.ClassName:method`

---

## Deployment

1. Copy `MyProject.ext.jar` to server's scripts directory
2. Restart server OR use `//reload scripts`
3. Test bypass command in game

---

## Best Practices

1. **Package naming**: Use `services` for bypass handlers, `instances` for reflections
2. **No args**: Service methods have no parameters
3. **this.getSelf()**: Always use instance method, not static
4. **ScriptFile**: Implement for proper loading/unloading
5. **Separate concerns**: Instance logic in one class, commands in another

---

## Important: TransformationName Clears Title

⚠️ **CharInfo.java Limitation** (lines 131-133):

When `player.getTransformationName() != null`, the `CharInfo` packet **forces title to empty string**:

```java
if (player.getTransformationName() != null ...) {
    this._title = "";  // Title is cleared!
}
```

**Workaround**: Don't use `setTransformationName()` if you need to display a custom title. Instead, put all info in the title only:

```java
// Instead of:
player.setTransformationName("Player1");  // This clears title!
player.setTitle("PvP: 0");

// Use:
player.setTitle("Kills: 0");  // Only use title
player.broadcastPacket(new L2GameServerPacket[]{new NickNameChanged((Creature)player)});
```

---

## Enabling Attack Without Ctrl (PvP Sans Ctrl)

To allow players to attack without holding Ctrl (like in battle_zone), create a `GlobalEvent` subclass:

```java
package instances;

import l2.gameserver.model.Creature;
import l2.gameserver.model.entity.events.GlobalEvent;

public class MyPvPEvent extends GlobalEvent {
    
    public MyPvPEvent() {
        super(999, "MyPvPEvent");
    }
    
    @Override
    public boolean canAttack(Creature attacker, Creature target, Skill skill, boolean force) {
        // Return true to allow attack without Ctrl
        return attacker.isPlayer() && target.isPlayer();
    }
    
    @Override
    public void reCalcNextTime(boolean onInit) {}
    
    @Override
    protected long startTimeMillis() { return 0; }
}
```

**Usage in your instance:**
```java
// On player enter
player.addEvent(myPvPEvent);

// On player exit
player.removeEvent(myPvPEvent);
```

This works because `Playable.isCtrlAttackable()` checks:
```java
for (GlobalEvent event : player.getEvents()) {
    if (event.canAttack(this, creature, null, bl)) {
        return true;  // Attack allowed!
    }
}
```


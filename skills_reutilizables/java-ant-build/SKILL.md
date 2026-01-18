---
name: java-ant-build
description: >
  Apache Ant build system for compiling Java code and creating JAR files.
  Trigger: When building the project, compiling code, or managing JAR files.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [build]
  auto_invoke: "ant build, compile, JAR, build system"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Building the project with Ant
- Compiling Java files
- Creating or updating JAR files
- Troubleshooting build issues

---

## Ant Commands

### Basic Commands

```bash
# Full build
ant build

# Clean build (removes old files first)
ant clean build

# Compile only (no JAR creation)
ant compile

# Just clean
ant clean

# Show available targets
ant -p
```

### Specific Targets

```bash
# Compile game server
ant compile-gameserver

# Compile scripts (quests, services, etc.)
ant compile-scripts

# Build specific JAR
ant jar-gameserver
ant jar-scripts
```

---

## Build File Location

```
project-root/
├── build.xml           # Main Ant build file
├── build.properties    # Build configuration
├── lib/                # External JARs/dependencies
└── dist/               # Output JARs (after build)
```

---

## Common Build Targets

| Target | Description |
|--------|-------------|
| `build` | Full build - compile + create JARs |
| `clean` | Remove compiled files and JARs |
| `compile` | Compile all Java source files |
| `compile-gameserver` | Compile only gameserver code |
| `compile-scripts` | Compile scripts (quests, services) |
| `jar` | Create all JAR files |
| `dist` | Create distribution package |

---

## JAR Structure

```
dist/
├── gameserver.jar      # Game server core
├── authserver.jar      # Login server
├── scripts.jar         # Scripts (quests, services, etc.)
├── commons.jar         # Shared utilities
└── lib/                # Dependencies
```

---

## Build Properties

Example `build.properties`:

```properties
# Java version
source.version=1.8
target.version=1.8

# Directories
src.dir=.
lib.dir=lib
build.dir=build
dist.dir=dist

# Compilation options
debug=true
deprecation=false
optimize=false
```

---

## Troubleshooting

### Common Errors

| Error | Solution |
|-------|----------|
| `javac: file not found` | Check Java is in PATH |
| `package does not exist` | Missing dependency in lib/ |
| `cannot find symbol` | Check imports, compile order |
| `target X not found` | Check build.xml for target name |

### Check Java Version

```bash
# Check Java version
java -version

# Check JAVA_HOME
echo %JAVA_HOME%
```

### Clean Rebuild

```bash
# Full clean rebuild
ant clean
ant build

# Or single command
ant clean build
```

---

## Adding New Scripts

When adding new Java files:

1. **Create the Java file** in appropriate package
2. **Compile scripts**: `ant compile-scripts`
3. **Rebuild JAR**: `ant jar-scripts` or `ant build`
4. **Restart server** to load new scripts

---

## IDE Integration

### Eclipse
- Import as Ant project
- Right-click `build.xml` > Run As > Ant Build

### IntelliJ IDEA
- Open project folder
- View > Tool Windows > Ant
- Add `build.xml` to Ant tool window

---

## Best Practices

1. **Clean build**: Do `ant clean build` after major changes
2. **Incremental**: Use `ant compile` for quick checks
3. **Check output**: Review console for warnings/errors
4. **Backup JARs**: Keep copies of working JARs
5. **Version control**: Don't commit build/ or dist/ folders

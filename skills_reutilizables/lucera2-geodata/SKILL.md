---
name: lucera2-geodata
description: >
  Geodata system: pathfinding, line of sight, collision detection, movement calculation.
  Trigger: When working with geodata, pathfinding, player/NPC movement, or collision.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [geodata, pathfinding]
  auto_invoke: "geodata, pathfinding, GeoEngine, movement, collision, line of sight"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Working with pathfinding algorithms
- Checking line of sight between objects
- Calculating valid movement positions
- Optimizing geodata loading
- Debugging movement issues

---

## Directory Structure

```
l2/gameserver/geodata/
├── GeoEngine.java              # Main geodata engine (82KB)
├── GeoMove.java                # Movement calculations
├── PathFind.java               # Pathfinding algorithm
├── PathFindBuffers.java        # Path buffer management
├── GeoCollision.java           # Collision interface
├── GeoOptimizer.java           # Geodata optimization
└── GeoUtils.java               # Utility functions
```

---

## Key Classes

| Class | Purpose |
|-------|---------|
| `GeoEngine` | Main geodata API - line of sight, height, etc. |
| `GeoMove` | Movement validation and calculation |
| `PathFind` | A* pathfinding implementation |
| `PathFindBuffers` | Memory management for path calculations |
| `GeoOptimizer` | Block matching and optimization |

---

## GeoEngine Methods

### Check Line of Sight

```java
import l2.gameserver.geodata.GeoEngine;

// Check if target is visible from origin
boolean canSee = GeoEngine.canSeeTarget(creature, target, false);

// Check with coordinates
boolean visible = GeoEngine.canSeeCoord(
    creature,           // Origin
    targetX, targetY, targetZ,  // Target coords
    false              // Use geodata
);
```

### Get Height

```java
// Get height at specific coordinates
int height = GeoEngine.getHeight(x, y, z, geoIndex);

// Get spawn height (for spawning NPCs)
int spawnZ = GeoEngine.getSpawnHeight(x, y, z, originZ, geoIndex);
```

### Check Movement

```java
// Can move from A to B?
boolean canMove = GeoEngine.canMoveToCoord(
    fromX, fromY, fromZ,
    toX, toY, toZ,
    geoIndex
);

// Move check with path
Location dest = GeoEngine.moveCheck(
    fromX, fromY, fromZ,
    toX, toY, toZ,
    geoIndex
);
```

---

## Pathfinding

```java
import l2.gameserver.geodata.PathFind;

// Find path between two points
List<Location> path = PathFind.findPath(
    fromX, fromY, fromZ,
    toX, toY, toZ,
    creature,
    geoIndex
);

// Check if path exists
boolean hasPath = path != null && !path.isEmpty();
```

---

## GeoIndex

The `geoIndex` parameter specifies the reflection/instance:

```java
// Normal world
int geoIndex = 0;

// In instance/reflection
int geoIndex = reflection.getGeoIndex();

// From player
int geoIndex = player.getGeoIndex();
```

---

## Coordinate System

| Axis | Description |
|------|-------------|
| X | East-West (positive = East) |
| Y | North-South (positive = South) |
| Z | Height (up/down) |

### World to Geo Coordinates

```java
// World coordinates are larger than geo coordinates
int geoX = x >> 4;  // Divide by 16
int geoY = y >> 4;  // Divide by 16

// Geo back to world
int worldX = geoX << 4;
int worldY = geoY << 4;
```

---

## Geo File Format

Geodata files are stored in:
```
gameserver/geodata/XX_YY.l2j
```

Where XX and YY are region coordinates (10-26 range).

### Block Types

| Type | Description |
|------|-------------|
| FLAT | Single height for entire block |
| COMPLEX | Multiple height layers |
| MULTILAYER | Complex multi-level terrain |

---

## Common Operations

### Spawn Location Validation

```java
// Find valid spawn point near location
Location loc = GeoEngine.findPointToStay(x, y, z, minRadius, maxRadius, geoIndex);
```

### Move Behind Target

```java
// Calculate position behind target
Location behindPos = GeoEngine.getPointInFront(target, -100); // 100 units behind
```

### Check Door/Wall Collision

```java
// Check if there's an obstacle
boolean blocked = !GeoEngine.canSeeTarget(from, to, false);
```

---

## Best Practices

1. **Use geoIndex**: Always pass correct geoIndex for instances
2. **Cache results**: Pathfinding is expensive, cache when possible
3. **Fallback**: Have fallback for missing geodata regions
4. **Height validation**: Always validate Z coordinate after movement
5. **Performance**: Limit pathfinding distance to avoid lag

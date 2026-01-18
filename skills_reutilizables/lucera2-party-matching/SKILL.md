---
name: lucera2-party-matching
description: >
  Party matching: party finder, command channel, group recruitment.
  Trigger: When working with party finder, matching rooms, or command channels.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [party, matching]
  auto_invoke: "party finder, matching room, command channel, party matching"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Working with party finder system
- Implementing matching rooms
- Managing command channels
- Creating group recruitment features

---

## Directory Structure

```
l2/gameserver/model/matching/        # Matching system (4 files)
├── MatchingRoom.java                 # Base room class (7KB)
├── PartyMatchingRoom.java            # Party room
└── CCMatchingRoom.java               # Command Channel room

l2/gameserver/instancemanager/
└── MatchingRoomManager.java          # Room management (4KB)
```

---

## Matching Room Types

| Type | Purpose | Max Members |
|------|---------|-------------|
| `PartyMatchingRoom` | Regular party finder | 9 |
| `CCMatchingRoom` | Command channel recruitment | Multiple parties |

---

## Creating Matching Room

```java
// Create party matching room
PartyMatchingRoom room = new PartyMatchingRoom(
    leader,           // Room leader
    minLevel,         // Minimum level
    maxLevel,         // Maximum level
    maxMembers,       // Max members
    lootType,         // Loot distribution
    topic             // Room description
);

// Register room
MatchingRoomManager.getInstance().addMatchingRoom(room);

// Player requests to join
room.addMember(player);
```

---

## MatchingRoom Base Class

```java
public abstract class MatchingRoom {
    
    protected Player _leader;
    protected Set<Player> _members = new CopyOnWriteArraySet<>();
    protected int _minLevel;
    protected int _maxLevel;
    protected int _maxMembers;
    protected String _topic;
    
    public boolean addMember(Player player) {
        if (_members.size() >= _maxMembers) {
            player.sendPacket(SystemMessage.PARTY_ROOM_FULL);
            return false;
        }
        
        if (player.getLevel() < _minLevel || player.getLevel() > _maxLevel) {
            player.sendPacket(SystemMessage.LEVEL_NOT_MATCH);
            return false;
        }
        
        _members.add(player);
        player.setMatchingRoom(this);
        
        // Notify all members
        broadcastPacket(new ExManagePartyRoomMember(player, this, 1));
        
        return true;
    }
    
    public void removeMember(Player player, boolean kicked) {
        _members.remove(player);
        player.setMatchingRoom(null);
        
        // Notify
        broadcastPacket(new ExManagePartyRoomMember(player, this, 0));
        
        if (kicked) {
            player.sendPacket(SystemMessage.KICKED_FROM_PARTY_ROOM);
        }
    }
    
    public void disband() {
        for (Player member : _members) {
            member.setMatchingRoom(null);
            member.sendPacket(SystemMessage.PARTY_ROOM_DISBANDED);
        }
        _members.clear();
        MatchingRoomManager.getInstance().removeMatchingRoom(this);
    }
}
```

---

## Party Matching Room

```java
public class PartyMatchingRoom extends MatchingRoom {
    
    private Party _party;
    private int _lootType;
    
    public PartyMatchingRoom(Player leader, int minLvl, int maxLvl, 
                             int maxMembers, int lootType, String topic) {
        _leader = leader;
        _minLevel = minLvl;
        _maxLevel = maxLvl;
        _maxMembers = maxMembers;
        _lootType = lootType;
        _topic = topic;
        
        // Leader is first member
        _members.add(leader);
        leader.setMatchingRoom(this);
    }
    
    @Override
    public boolean addMember(Player player) {
        if (!super.addMember(player)) {
            return false;
        }
        
        // Also add to party if exists
        if (_party != null && !_party.containsMember(player)) {
            _party.addMember(player);
        }
        
        return true;
    }
}
```

---

## Command Channel Matching

```java
public class CCMatchingRoom extends MatchingRoom {
    
    private CommandChannel _commandChannel;
    
    @Override
    public boolean addMember(Player player) {
        // For CC, we add entire parties
        if (!player.isInParty()) {
            player.sendPacket(SystemMessage.MUST_BE_IN_PARTY);
            return false;
        }
        
        Party party = player.getParty();
        
        // Add party to command channel
        if (_commandChannel == null) {
            _commandChannel = new CommandChannel(_leader);
        }
        
        _commandChannel.addParty(party);
        
        // All party members join room
        for (Player member : party.getMembers()) {
            _members.add(member);
            member.setMatchingRoom(this);
        }
        
        return true;
    }
}
```

---

## Matching Room Manager

```java
public class MatchingRoomManager {
    
    private List<MatchingRoom> _rooms = new CopyOnWriteArrayList<>();
    
    public void addMatchingRoom(MatchingRoom room) {
        _rooms.add(room);
    }
    
    public void removeMatchingRoom(MatchingRoom room) {
        _rooms.remove(room);
    }
    
    public List<MatchingRoom> getMatchingRooms(int minLevel, int maxLevel) {
        return _rooms.stream()
            .filter(r -> r.getMinLevel() <= maxLevel)
            .filter(r -> r.getMaxLevel() >= minLevel)
            .collect(Collectors.toList());
    }
    
    public MatchingRoom getPlayerRoom(Player player) {
        return player.getMatchingRoom();
    }
}
```

---

## Client Packets

| Packet | Direction | Purpose |
|--------|-----------|---------|
| `RequestListPartyMatchingWaitingRoom` | C→S | List rooms |
| `RequestPartyMatchingConfig` | C→S | Create/edit room |
| `RequestManagePartyRoom` | C→S | Join/leave/kick |
| `ExListPartyMatchingWaitingRoom` | S→C | Room list |
| `ExManagePartyRoomMember` | S→C | Member update |

---

## Best Practices

1. **Sync**: Keep room and party in sync
2. **Cleanup**: Disband on leader logout
3. **Limits**: Enforce level restrictions
4. **Broadcast**: Update all members on changes
5. **Packets**: Send correct client packets

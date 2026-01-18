---
name: lucera2-scripts
description: >
  Quest scripts, NPC AI, boss scripts, events, and instances.
  Trigger: When creating or modifying quests, NPC scripts, boss behaviors, events, or instance dungeons.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [scripts, quests, npc, bosses, events]
  auto_invoke: "quests, NPC scripts, boss scripts, events, instances"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating or modifying quests
- Working with NPC AI scripts
- Implementing boss mechanics
- Creating events
- Designing instance dungeons

---

## Directory Structure

```
├── quests/               # Quest scripts (377 files)
│   ├── _001_LettersOfLove.java
│   ├── _255_Tutorial.java
│   └── _XXX_QuestName.java
├── npc/                  # NPC AI scripts (123 files)
│   └── model/
├── bosses/               # Boss scripts (50 files)
│   ├── AntharasManager.java
│   ├── ValakasManager.java
│   └── ...
├── events/               # Event scripts (78 files)
│   ├── AprilFoolsDay/
│   ├── Christmas/
│   └── ...
├── instances/            # Instance dungeons (20 files)
│   ├── Kamaloka.java
│   └── ...
└── ai/                   # AI behaviors (180 files)
```

---

## Quest Script Pattern

### Naming Convention

```
_XXX_QuestName.java
```
- `XXX`: Quest ID (3 digits, zero-padded)
- `QuestName`: CamelCase quest name

### Basic Quest Structure

```java
package quests;

import l2.gameserver.model.instances.NpcInstance;
import l2.gameserver.model.Player;
import l2.gameserver.model.quest.Quest;
import l2.gameserver.model.quest.QuestState;
import l2.gameserver.scripts.ScriptFile;

public class _999_MyQuest extends Quest implements ScriptFile {
    
    // Quest items
    private static final int QUEST_ITEM = 12345;
    
    // NPCs
    private static final int START_NPC = 30001;
    private static final int END_NPC = 30002;
    
    // Monsters
    private static final int MONSTER = 20001;
    
    public _999_MyQuest() {
        super(true); // Party quest = true
        
        // Register NPCs
        addStartNpc(START_NPC);
        addTalkId(START_NPC, END_NPC);
        
        // Register monsters
        addKillId(MONSTER);
        
        // Register quest items
        addQuestItem(QUEST_ITEM);
    }
    
    @Override
    public String onEvent(String event, QuestState st, NpcInstance npc) {
        String htmltext = event;
        Player player = st.getPlayer();
        
        if (event.equals("start_quest")) {
            st.setCond(1);
            st.setState(STARTED);
            st.playSound(SOUND_ACCEPT);
            htmltext = "30001-02.htm";
        }
        
        return htmltext;
    }
    
    @Override
    public String onTalk(NpcInstance npc, QuestState st) {
        String htmltext = "noquest";
        int npcId = npc.getNpcId();
        int cond = st.getCond();
        
        if (npcId == START_NPC) {
            if (cond == 0) {
                htmltext = "30001-01.htm"; // Quest offer
            } else if (cond == 1) {
                htmltext = "30001-03.htm"; // In progress
            }
        }
        
        return htmltext;
    }
    
    @Override
    public String onKill(NpcInstance npc, QuestState st) {
        if (st.getCond() == 1) {
            st.giveItems(QUEST_ITEM, 1);
            if (st.getQuestItemsCount(QUEST_ITEM) >= 10) {
                st.setCond(2);
                st.playSound(SOUND_MIDDLE);
            } else {
                st.playSound(SOUND_ITEMGET);
            }
        }
        return null;
    }
    
    // ScriptFile methods
    @Override
    public void onLoad() {}
    
    @Override
    public void onReload() {}
    
    @Override
    public void onShutdown() {}
}
```

---

## Quest State Methods

| Method | Description |
|--------|-------------|
| `st.getCond()` | Get current condition |
| `st.setCond(n)` | Set condition |
| `st.setState(STARTED)` | Set quest state |
| `st.getQuestItemsCount(id)` | Count items |
| `st.giveItems(id, count)` | Give items |
| `st.takeItems(id, count)` | Remove items |
| `st.giveAdena(count)` | Give adena |
| `st.addExpAndSp(exp, sp)` | Give exp/sp |
| `st.playSound(sound)` | Play sound |
| `st.exitQuest(repeatable)` | Complete quest |

---

## Quest HTML Files

Location: `data/html-en/quests/_XXX_QuestName/`

```html
<html><body>NPC Name:<br><br>
Quest dialog text here.
<a action="bypass -h Quest _999_MyQuest start_quest">Accept Quest</a>
</body></html>
```

---

## Boss Script Pattern

```java
package bosses;

import l2.gameserver.model.instances.RaidBossInstance;
import l2.gameserver.scripts.ScriptFile;

public class MyBossManager implements ScriptFile {
    
    private static final int BOSS_ID = 25001;
    
    @Override
    public void onLoad() {
        // Initialize boss spawn, timers, etc.
    }
    
    // Boss mechanics, phases, minions, etc.
}
```

---

## Event Script Pattern

Location: `events/EventName/EventName.java`

```java
package events.EventName;

import l2.gameserver.scripts.ScriptFile;
import l2.gameserver.scripts.Functions;

public class EventName extends Functions implements ScriptFile {
    
    private static boolean _active = false;
    
    @Override
    public void onLoad() {
        // Check if event should be active based on date/time
    }
    
    public void startEvent() {
        _active = true;
        // Spawn NPCs, initialize event
    }
    
    public void stopEvent() {
        _active = false;
        // Cleanup, despawn NPCs
    }
}
```

---

## Instance Script Pattern

```java
package instances;

import l2.gameserver.instancemanager.ReflectionManager;
import l2.gameserver.model.Player;
import l2.gameserver.model.Reflection;

public class MyInstance extends Reflection {
    
    private static final int INSTANCE_ID = 100;
    
    public MyInstance(Player player) {
        super();
        setName("My Instance");
        setInstancedZoneId(INSTANCE_ID);
    }
    
    @Override
    public void onCreate() {
        super.onCreate();
        // Spawn mobs, set up instance
    }
    
    @Override
    public void onPlayerEnter(Player player) {
        super.onPlayerEnter(player);
        // Player entered instance
    }
}
```

---

## Common Constants

```java
// Quest states
public static final int CREATED = 0;
public static final int STARTED = 1;
public static final int COMPLETED = 2;

// Sounds
public static final String SOUND_ACCEPT = "ItemSound.quest_accept";
public static final String SOUND_MIDDLE = "ItemSound.quest_middle";
public static final String SOUND_FINISH = "ItemSound.quest_finish";
public static final String SOUND_ITEMGET = "ItemSound.quest_itemget";
public static final String SOUND_FANFARE = "ItemSound.quest_fanfare_2";
```

---

## Best Practices

1. **Quest IDs**: Use unique IDs, check existing quests
2. **NPC registration**: Register all NPCs in constructor
3. **Clean up**: Remove quest items on completion
4. **HTML paths**: Match folder name to quest class name
5. **Testing**: Test all quest paths and edge cases
6. **Localization**: Support multiple languages in HTML

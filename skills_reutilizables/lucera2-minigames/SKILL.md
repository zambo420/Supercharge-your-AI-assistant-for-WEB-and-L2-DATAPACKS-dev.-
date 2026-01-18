---
name: lucera2-minigames
description: >
  Mini-games: Lottery, Fishing Championship, Sepulchers, Monster Race.
  Trigger: When working with mini-games, lottery, fishing events, or sepulchers.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [minigames, lottery]
  auto_invoke: "lottery, fishing championship, sepulcher, monster race, mini-game"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Working with lottery system
- Implementing fishing championship
- Modifying Four Sepulchers
- Working with Monster Race
- Creating new mini-games

---

## Directory Structure

```
l2/gameserver/instancemanager/games/     # Mini-games (8 files)
├── LotteryManager.java                   # Lottery system (21KB)
└── FishingChampionShipManager.java       # Fishing event (18KB)

l2/gameserver/instancemanager/sepulchers/ # Sepulchers (17 files)
├── FourSepulchers.java                    # Main sepulcher script
├── SepulcherActivityRunner.java           # Activity management
├── event/                                 # Sepulcher events
├── model/                                 # Sepulcher models
└── spawn/                                 # Spawn management

l2/gameserver/model/entity/
└── MonsterRace.java                       # Monster racing (20KB)
```

---

## Lottery System

```java
// LotteryManager provides lottery functionality
LotteryManager lottery = LotteryManager.getInstance();

// Get current lottery ID
int lotteryId = lottery.getId();

// Get jackpot
long jackpot = lottery.getPrize();

// Buy ticket
lottery.buyTicket(player, numbers);

// Check if player won
int prize = lottery.checkTicket(player, ticketItemId);
```

---

## Lottery Ticket Purchase

```java
public void buyLotteryTicket(Player player, int[] numbers) {
    // Validate numbers (1-20, 5 unique)
    if (!validateNumbers(numbers)) {
        player.sendMessage("Invalid numbers!");
        return;
    }
    
    // Check cost
    if (!player.reduceAdena("Lottery", TICKET_COST, player, true)) {
        return;
    }
    
    // Create ticket item
    ItemInstance ticket = ItemFunctions.createItem(TICKET_ID);
    ticket.setEnchantLevel(encodeNumbers(numbers));
    player.getInventory().addItem(ticket);
    
    player.sendMessage("Lottery ticket purchased!");
}
```

---

## Fishing Championship

```java
// FishingChampionShipManager handles fishing events
FishingChampionShipManager fishing = FishingChampionShipManager.getInstance();

// Register fish catch
fishing.catchFish(player, fishId, fishLength);

// Get current winner
Fisher winner = fishing.getWinner();

// Check player rank
int rank = fishing.getPlayerRank(player);
```

---

## Four Sepulchers

```java
// FourSepulchers manages the Four Sepulchers dungeon
public class FourSepulchers {
    
    // Entry NPCs
    private static final int[] HALL_GATEKEEPER = {31925, 31926, 31927, 31928};
    
    // Check if can enter
    public boolean canEnter(Player player) {
        // Must have hallowed urn
        return player.getInventory().getItemByItemId(HALLOWED_URN) != null;
    }
    
    // Start sepulcher run
    public void enterSepulcher(Player player, int sepulcherId) {
        // Consume urn
        player.getInventory().destroyItemByItemId("Sepulcher", HALLOWED_URN, 1, player, null);
        
        // Teleport to sepulcher
        player.teleToLocation(SEPULCHER_SPAWN[sepulcherId]);
        
        // Start timer
        startSepulcherTimer(player, sepulcherId);
    }
}
```

---

## Monster Race

```java
// MonsterRace handles the Monster Race Track
MonsterRace race = MonsterRace.getInstance();

// Get race state
RaceState state = race.getCurrentRaceState();

// Get runners
NpcInstance[] runners = race.getRunners();

// Place bet
race.placeBet(player, laneNumber, betAmount);

// Get race history
List<HistoryInfo> history = race.getHistory();
```

---

## Creating Custom Mini-Game

```java
package services;

public class MyMiniGame extends Functions implements ScriptFile {
    
    private static boolean _active = false;
    private static List<Player> _participants = new ArrayList<>();
    
    public void register(String[] args) {
        Player player = getSelf();
        
        if (!_active) {
            player.sendMessage("Event not active!");
            return;
        }
        
        if (_participants.contains(player)) {
            player.sendMessage("Already registered!");
            return;
        }
        
        // Check fee
        if (!player.reduceAdena("MiniGame", FEE, player, true)) {
            return;
        }
        
        _participants.add(player);
        player.sendMessage("Registered for mini-game!");
    }
    
    public static void startGame() {
        _active = true;
        
        // Announce
        Announcements.getInstance().announceToAll("Mini-game starting!");
        
        // Schedule game logic
        ThreadPoolManager.getInstance().schedule(() -> runGame(), 60000);
    }
    
    private static void runGame() {
        // Game logic here
        Player winner = selectRandomWinner();
        
        // Give prize
        winner.addItem("MiniGame", PRIZE_ID, PRIZE_COUNT, winner, true);
        
        // Cleanup
        _participants.clear();
        _active = false;
    }
}
```

---

## Best Practices

1. **Scheduling**: Use proper schedulers for timed events
2. **Persistence**: Save game state to database
3. **Cleanup**: Handle server restart gracefully
4. **Announcements**: Keep players informed
5. **Fairness**: Ensure random selection is fair

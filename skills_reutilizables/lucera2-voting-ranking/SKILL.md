---
name: lucera2-voting-ranking
description: >
  Voting and ranking services: MMORPG voting sites, top lists, player rankings.
  Trigger: When working with voting rewards, server rankings, or top lists.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [voting, ranking]
  auto_invoke: "voting, L2Top, MMOTop, ranking, top players"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Implementing voting rewards
- Integrating MMORPG voting sites
- Working with player/clan rankings
- Managing top lists (PvP, PK, clan)

---

## Directory Structure

```
services/                            # Voting/ranking services
├── L2HopZoneService.java            # L2HopZone voting
├── L2JBrazilService.java            # L2JBrazil voting
├── L2TopZoneService.java            # L2TopZone voting
├── MMOTopVote.java                  # MMOTop voting
├── TopClanService.java              # Top clans ranking
├── TopPvPPKService.java             # Top PvP/PK ranking
└── RaidBossStatusService.java       # Raid boss status

l2/gameserver/taskmanager/
└── L2TopRuManager.java              # L2Top.ru voting
```

---

## Voting Service Pattern

```java
package services;

public class MyVoteService extends Functions implements ScriptFile {
    
    private static final String API_URL = "https://voting-site.com/api/";
    private static final String API_KEY = Config.VOTE_API_KEY;
    
    // Check if player voted
    public static boolean hasVoted(Player player) {
        try {
            String url = API_URL + "check?ip=" + player.getIP() + "&key=" + API_KEY;
            HttpURLConnection conn = (HttpURLConnection) new URL(url).openConnection();
            
            BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            String response = reader.readLine();
            reader.close();
            
            return response.contains("voted=true");
        } catch (Exception e) {
            _log.error("Vote check failed", e);
            return false;
        }
    }
    
    // Give vote reward
    public static void giveReward(Player player) {
        // Check last vote time
        long lastVote = player.getVar("last_vote", 0L);
        if (System.currentTimeMillis() - lastVote < 12 * 3600 * 1000) {
            player.sendMessage("You can vote again in " + getTimeRemaining(lastVote));
            return;
        }
        
        if (hasVoted(player)) {
            player.addItem("Vote", REWARD_ITEM_ID, REWARD_COUNT, player, true);
            player.setVar("last_vote", System.currentTimeMillis());
            player.sendMessage("Thank you for voting!");
        } else {
            player.sendMessage("Please vote first at " + VOTE_LINK);
        }
    }
}
```

---

## Top Players Ranking

```java
package services;

public class TopPvPPKService extends Functions implements ScriptFile {
    
    private static List<TopRecord> _topPvP = new ArrayList<>();
    private static List<TopRecord> _topPK = new ArrayList<>();
    
    public void updateTop() {
        _topPvP.clear();
        _topPK.clear();
        
        // Query database
        try (Connection con = DatabaseFactory.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT char_name, pvpkills, pkkills, online FROM characters ORDER BY pvpkills DESC LIMIT 20")) {
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                _topPvP.add(new TopRecord(
                    rs.getString("char_name"),
                    rs.getInt("pvpkills"),
                    rs.getBoolean("online")
                ));
            }
        }
    }
    
    public String showTopPvP(Player player) {
        StringBuilder html = new StringBuilder();
        html.append("<html><body><center><b>Top PvP Players</b></center><br>");
        html.append("<table>");
        
        int rank = 1;
        for (TopRecord record : _topPvP) {
            html.append("<tr>");
            html.append("<td>").append(rank++).append("</td>");
            html.append("<td>").append(record.getName()).append("</td>");
            html.append("<td>").append(record.getKills()).append(" kills</td>");
            html.append("</tr>");
        }
        
        html.append("</table></body></html>");
        return html.toString();
    }
}
```

---

## Top Clans Ranking

```java
public class TopClanService extends Functions {
    
    public void showTopClans(Player player) {
        List<Clan> clans = ClanTable.getInstance().getClans();
        
        // Sort by reputation
        clans.sort((c1, c2) -> c2.getReputationScore() - c1.getReputationScore());
        
        StringBuilder html = new StringBuilder();
        html.append("<html><body><center><b>Top Clans</b></center><br>");
        
        int rank = 1;
        for (Clan clan : clans.subList(0, Math.min(20, clans.size()))) {
            html.append(rank++).append(". ")
                .append(clan.getName())
                .append(" - Rep: ").append(clan.getReputationScore())
                .append("<br>");
        }
        
        html.append("</body></html>");
        show(html.toString(), player);
    }
}
```

---

## Raid Boss Status

```java
public class RaidBossStatusService extends Functions {
    
    public void showBossStatus(Player player) {
        StringBuilder html = new StringBuilder();
        html.append("<html><body><center><b>Raid Boss Status</b></center><br>");
        
        for (RaidBossSpawnManager.RaidBossInfo info : RaidBossSpawnManager.getInstance().getRaidBossInfo()) {
            html.append(info.getName()).append(" - ");
            
            if (info.isAlive()) {
                html.append("<font color=\"00FF00\">ALIVE</font>");
            } else {
                html.append("<font color=\"FF0000\">DEAD</font> (respawn: ")
                    .append(info.getRespawnTime()).append(")");
            }
            html.append("<br>");
        }
        
        html.append("</body></html>");
        show(html.toString(), player);
    }
}
```

---

## Configuration

```properties
# Voting config
VOTE_REWARD_ENABLED = true
VOTE_REWARD_ITEM_ID = 57
VOTE_REWARD_COUNT = 10000
VOTE_COOLDOWN_HOURS = 12
VOTE_API_KEY = your_api_key
L2TOPZONE_API_KEY = xxx
L2HOPZONE_API_KEY = xxx
```

---

## Best Practices

1. **Rate limiting**: Respect voting site API limits
2. **Caching**: Cache rankings, update periodically
3. **IP tracking**: Track votes by IP, not just account
4. **Error handling**: Handle API failures gracefully
5. **Announcements**: Announce top rankings periodically

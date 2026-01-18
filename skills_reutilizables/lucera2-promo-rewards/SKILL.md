---
name: lucera2-promo-rewards
description: >
  Promo codes and daily rewards: promo code system, daily rewards, attendance.
  Trigger: When working with promo codes, daily rewards, or attendance systems.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [promo, rewards]
  auto_invoke: "promo code, daily reward, attendance, one day reward"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Implementing promo code system
- Working with daily rewards
- Managing attendance rewards
- Creating time-limited rewards

---

## Directory Structure

```
services/
├── PromoCodeService.java            # Promo code handling

l2/gameserver/model/entity/oneDayReward/  # Daily rewards (20 files)
├── OneDayReward.java                  # Reward definition
├── OneDayRewardStore.java             # Storage
├── OneDayRewardStatus.java            # Status tracking
├── OneDayDistributionType.java        # Distribution types
└── requirement/                       # Requirements (14 files)

l2/gameserver/data/xml/holder/
└── OneDayRewardHolder.java            # Reward data

l2/gameserver/dao/
├── PromoCodeDAO.java                  # Promo database
├── PromoCodeLimitDAO.java             # Usage limits
├── PromoCodeUserDAO.java              # User tracking
└── CharacterOneDayRewardDAO.java      # Daily reward tracking
```

---

## Promo Code System

```java
package services;

public class PromoCodeService extends Functions {
    
    public void redeemCode(Player player, String code) {
        // Check if code exists
        PromoCode promo = PromoCodeHolder.getInstance().getPromoCode(code);
        if (promo == null) {
            player.sendMessage("Invalid promo code!");
            return;
        }
        
        // Check expiration
        if (promo.isExpired()) {
            player.sendMessage("This promo code has expired!");
            return;
        }
        
        // Check usage limit
        if (promo.isLimitReached()) {
            player.sendMessage("This promo code has reached its limit!");
            return;
        }
        
        // Check if already used by player
        if (PromoCodeUserDAO.getInstance().hasUsed(player.getObjectId(), code)) {
            player.sendMessage("You have already used this code!");
            return;
        }
        
        // Give rewards
        for (PromoReward reward : promo.getRewards()) {
            player.addItem("PromoCode", reward.getItemId(), reward.getCount(), player, true);
        }
        
        // Mark as used
        PromoCodeUserDAO.getInstance().markUsed(player.getObjectId(), code);
        promo.incrementUsage();
        
        player.sendMessage("Promo code redeemed successfully!");
    }
}
```

---

## PromoCode Model

```java
public class PromoCode {
    private String _code;
    private long _startTime;
    private long _endTime;
    private int _maxUses;
    private int _currentUses;
    private List<PromoReward> _rewards;
    
    public boolean isExpired() {
        long now = System.currentTimeMillis();
        return now < _startTime || now > _endTime;
    }
    
    public boolean isLimitReached() {
        return _maxUses > 0 && _currentUses >= _maxUses;
    }
}
```

---

## Daily Reward System

```java
// OneDayReward.java
public class OneDayReward {
    private int _id;
    private int _itemId;
    private long _itemCount;
    private OneDayRewardRequirement _requirement;
    private OneDayDistributionType _distribution;
    
    public boolean canReceive(Player player) {
        return _requirement.check(player);
    }
    
    public void giveReward(Player player) {
        player.addItem("OneDayReward", _itemId, _itemCount, player, true);
    }
}
```

---

## Requirement Types

```java
// l2/gameserver/model/entity/oneDayReward/requirement/
public abstract class OneDayRewardRequirement {
    public abstract boolean check(Player player);
}

// Examples:
class LevelRequirement extends OneDayRewardRequirement {
    private int _minLevel;
    
    @Override
    public boolean check(Player player) {
        return player.getLevel() >= _minLevel;
    }
}

class OnlineTimeRequirement extends OneDayRewardRequirement {
    private long _minOnlineMs;
    
    @Override
    public boolean check(Player player) {
        return player.getOnlineTime() >= _minOnlineMs;
    }
}

class KillMonstersRequirement extends OneDayRewardRequirement {
    private int _count;
    
    @Override
    public boolean check(Player player) {
        return player.getVarInt("daily_kills", 0) >= _count;
    }
}
```

---

## Attendance System

```java
public class AttendanceReward {
    
    public void checkAttendance(Player player) {
        long lastCheck = player.getVar("attendance_time", 0L);
        long now = System.currentTimeMillis();
        
        // Reset at midnight
        if (!isSameDay(lastCheck, now)) {
            int streak = player.getVar("attendance_streak", 0) + 1;
            if (streak > 30) streak = 1; // Monthly reset
            
            player.setVar("attendance_streak", streak);
            player.setVar("attendance_time", now);
            
            giveAttendanceReward(player, streak);
        }
    }
    
    private void giveAttendanceReward(Player player, int day) {
        AttendanceReward reward = AttendanceHolder.getInstance().getReward(day);
        if (reward != null) {
            player.addItem("Attendance", reward.getItemId(), reward.getCount(), player, true);
            player.sendMessage("Day " + day + " attendance reward received!");
        }
    }
}
```

---

## Configuration

```xml
<!-- data/oneDayReward.xml -->
<rewards>
    <reward id="1" item_id="57" count="10000">
        <requirement type="level" min="20" />
        <distribution type="DAILY" />
    </reward>
    <reward id="2" item_id="6673" count="1">
        <requirement type="online_time" min_minutes="60" />
        <distribution type="DAILY" />
    </reward>
</rewards>
```

---

## Best Practices

1. **Unique codes**: Generate secure random codes
2. **Time zones**: Handle time zone differences
3. **Expiration**: Clean expired promo codes
4. **Tracking**: Log all code redemptions
5. **Limits**: Enforce per-player and global limits

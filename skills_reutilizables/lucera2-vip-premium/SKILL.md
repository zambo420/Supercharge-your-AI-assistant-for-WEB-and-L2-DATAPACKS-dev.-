---
name: lucera2-vip-premium
description: >
  VIP and premium system: rate bonuses, premium accounts, VIP features.
  Trigger: When working with VIP, premium accounts, or rate bonuses.
license: MIT
metadata:
  author: lucera2-team
  version: "1.0"
  scope: [vip, premium]
  auto_invoke: "VIP, premium, rate bonus, premium account"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Working with VIP/premium system
- Implementing rate bonuses
- Managing premium features
- Creating VIP benefits

---

## Directory Structure

```
l2/gameserver/instancemanager/
└── VipManager.java                   # VIP management (4KB)

services/
├── RateBonus.java                    # Rate bonus service (19KB)
└── StarterPremiumAccount.java        # Starter premium

l2/gameserver/dao/
└── AccountBonusDAO.java              # Bonus database (8KB)
```

---

## VIP System

```java
// VipManager provides VIP functionality
VipManager vip = VipManager.getInstance();

// Check VIP status
boolean isVip = vip.isVip(player);
int vipLevel = vip.getVipLevel(player);

// Get VIP expiry
long expiryTime = vip.getVipExpiry(player);

// Add VIP time
vip.addVipTime(player, 30 * 24 * 3600 * 1000L); // 30 days
```

---

## Premium Account

```java
// Check premium status
boolean isPremium = player.hasPremiumAccount();

// Get premium bonuses
double xpBonus = player.getPremiumBonus(BonusType.EXP);
double spBonus = player.getPremiumBonus(BonusType.SP);
double dropBonus = player.getPremiumBonus(BonusType.DROP);

// Add premium
AccountBonusDAO.getInstance().addPremium(
    player.getAccountName(),
    System.currentTimeMillis() + 30 * DAY_MS,  // 30 days
    PremiumType.GOLD
);
```

---

## Rate Bonus Service

```java
package services;

public class RateBonus extends Functions {
    
    // Premium types
    public enum PremiumType {
        BRONZE(1.25, 1.25, 1.25),  // 25% bonus
        SILVER(1.50, 1.50, 1.50),  // 50% bonus
        GOLD(2.00, 2.00, 2.00);    // 100% bonus
        
        private final double expRate;
        private final double spRate;
        private final double dropRate;
        
        PremiumType(double exp, double sp, double drop) {
            expRate = exp;
            spRate = sp;
            dropRate = drop;
        }
    }
    
    public void buyPremium(String[] args) {
        Player player = getSelf();
        NpcInstance npc = getNpc();
        
        int days = Integer.parseInt(args[0]);
        PremiumType type = PremiumType.valueOf(args[1]);
        
        // Calculate cost
        long cost = calculateCost(days, type);
        
        // Check payment
        if (!player.reduceAdena("Premium", cost, player, true)) {
            player.sendMessage("Not enough adena!");
            return;
        }
        
        // Activate premium
        activatePremium(player, days, type);
        
        player.sendMessage("Premium activated for " + days + " days!");
    }
    
    private void activatePremium(Player player, int days, PremiumType type) {
        long duration = days * 24 * 3600 * 1000L;
        long expiry = System.currentTimeMillis() + duration;
        
        // Save to database
        AccountBonusDAO.getInstance().savePremium(
            player.getAccountName(),
            expiry,
            type.expRate,
            type.spRate,
            type.dropRate
        );
        
        // Apply immediately
        player.setPremiumBonus(BonusType.EXP, type.expRate);
        player.setPremiumBonus(BonusType.SP, type.spRate);
        player.setPremiumBonus(BonusType.DROP, type.dropRate);
    }
}
```

---

## VIP Levels

```java
// VIP level benefits
public enum VipLevel {
    VIP_0(1.0, 1.0, 1.0, 0),      // No bonus
    VIP_1(1.1, 1.1, 1.1, 5),      // 10% bonus, 5% shop discount
    VIP_2(1.25, 1.25, 1.25, 10), // 25% bonus, 10% shop discount
    VIP_3(1.5, 1.5, 1.5, 15),    // 50% bonus, 15% shop discount
    VIP_4(2.0, 2.0, 2.0, 20);    // 100% bonus, 20% shop discount
    
    public final double expBonus;
    public final double dropBonus;
    public final double adenaBonus;
    public final int shopDiscount;
}
```

---

## VIP Perks

```java
// VIP-only features
public boolean canUseFeature(Player player, VipFeature feature) {
    int vipLevel = VipManager.getInstance().getVipLevel(player);
    
    switch (feature) {
        case AUTOFARM:
            return vipLevel >= 1;
        case PREMIUM_TELEPORT:
            return vipLevel >= 2;
        case SKIP_QUEUE:
            return vipLevel >= 1;
        case EXTRA_WAREHOUSE:
            return vipLevel >= 3;
        case NO_DROPS_ON_DEATH:
            return vipLevel >= 4;
        default:
            return false;
    }
}
```

---

## AccountBonusDAO

```java
public class AccountBonusDAO {
    
    public void savePremium(String account, long expiry, 
                           double expRate, double spRate, double dropRate) {
        try (Connection con = DatabaseFactory.getInstance().getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "REPLACE INTO account_bonus (account, expiry, exp_rate, sp_rate, drop_rate) VALUES (?,?,?,?,?)")) {
            ps.setString(1, account);
            ps.setLong(2, expiry);
            ps.setDouble(3, expRate);
            ps.setDouble(4, spRate);
            ps.setDouble(5, dropRate);
            ps.executeUpdate();
        }
    }
    
    public AccountBonus loadPremium(String account) {
        // Load from database
        // Return null if expired
    }
}
```

---

## Configuration

```properties
# Premium config
PREMIUM_RATE_EXP = 2.0
PREMIUM_RATE_SP = 2.0
PREMIUM_RATE_DROP = 1.5
PREMIUM_RATE_ADENA = 2.0
VIP_AUTOFARM_UNLIMITED = true
VIP_QUEUE_PRIORITY = true
```

---

## Best Practices

1. **Account-based**: Save by account, not character
2. **Expiry check**: Check expiry on login
3. **Notification**: Warn before expiry
4. **Fair play**: Don't make P2W advantages
5. **Database sync**: Persist changes immediately

---
name: ioredis
description: >
  ioredis Redis client patterns for caching and sessions.
  Trigger: When working with Redis, caching, session management, or pub/sub.
license: MIT
metadata:
  author: L2Website
  version: "1.0"
  scope: [backend]
  auto_invoke: "Redis / Caching / Sessions"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Setting up Redis connection
- Implementing caching
- Managing user sessions
- Pub/sub messaging
- Rate limiting storage

## Connection Setup

```typescript
// src/config/redis.ts
import Redis from 'ioredis';

const redis = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: Number(process.env.REDIS_PORT) || 6379,
  password: process.env.REDIS_PASSWORD,
  db: Number(process.env.REDIS_DB) || 0,
  retryStrategy: (times) => Math.min(times * 50, 2000),
});

redis.on('connect', () => console.log('Redis connected'));
redis.on('error', (err) => console.error('Redis error:', err));

export { redis };
```

## Basic Operations

```typescript
import { redis } from '@/config/redis';

// String operations
await redis.set('key', 'value');
await redis.set('key', 'value', 'EX', 3600); // 1 hour TTL
const value = await redis.get('key');
await redis.del('key');

// Check existence
const exists = await redis.exists('key');

// Increment
await redis.incr('counter');
await redis.incrby('counter', 5);
```

## Caching Pattern

```typescript
// src/services/CacheService.ts
import { redis } from '@/config/redis';

export class CacheService {
  static async get<T>(key: string): Promise<T | null> {
    const data = await redis.get(key);
    return data ? JSON.parse(data) : null;
  }

  static async set(key: string, value: unknown, ttlSeconds = 3600): Promise<void> {
    await redis.set(key, JSON.stringify(value), 'EX', ttlSeconds);
  }

  static async del(key: string): Promise<void> {
    await redis.del(key);
  }

  static async invalidatePattern(pattern: string): Promise<void> {
    const keys = await redis.keys(pattern);
    if (keys.length > 0) {
      await redis.del(...keys);
    }
  }
}

// Usage
const characters = await CacheService.get<Character[]>('characters:all');
if (!characters) {
  const data = await CharacterService.findAll();
  await CacheService.set('characters:all', data, 300); // 5 min
}
```

## Session Storage

```typescript
// src/middleware/session.ts
import { redis } from '@/config/redis';

const SESSION_TTL = 86400; // 24 hours

export async function setSession(userId: number, sessionData: object): Promise<string> {
  const sessionId = crypto.randomUUID();
  const key = `session:${sessionId}`;
  
  await redis.set(key, JSON.stringify({ userId, ...sessionData }), 'EX', SESSION_TTL);
  
  return sessionId;
}

export async function getSession(sessionId: string): Promise<object | null> {
  const data = await redis.get(`session:${sessionId}`);
  return data ? JSON.parse(data) : null;
}

export async function destroySession(sessionId: string): Promise<void> {
  await redis.del(`session:${sessionId}`);
}
```

## Hash Operations

```typescript
// For structured data
await redis.hset('user:123', { name: 'John', level: '50' });
await redis.hget('user:123', 'name');
await redis.hgetall('user:123');
await redis.hincrby('user:123', 'level', 1);
```

## Key Naming Convention

```
prefix:entity:id:suffix

Examples:
- session:abc123
- cache:characters:all
- user:123:profile
- ratelimit:ip:192.168.1.1
```

## Commands

```bash
# No npm commands - Redis is external service
# Check Redis connection
redis-cli ping
```

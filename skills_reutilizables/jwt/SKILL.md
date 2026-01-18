---
name: jwt
description: >
  JSON Web Token patterns for authentication.
  Trigger: When working with JWT tokens, authentication, token verification, or refresh tokens.
license: MIT
metadata:
  author: L2Website
  version: "1.0"
  scope: [backend]
  auto_invoke: "Authentication / JWT / Tokens"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating authentication tokens
- Verifying tokens in middleware
- Implementing refresh tokens
- Managing token expiration
- Decoding token payloads

## Token Generation

```typescript
// src/utils/jwt.ts
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET!;
const ACCESS_TOKEN_EXPIRY = '15m';
const REFRESH_TOKEN_EXPIRY = '7d';

interface TokenPayload {
  userId: number;
  username: string;
  role: string;
}

export function generateAccessToken(payload: TokenPayload): string {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: ACCESS_TOKEN_EXPIRY });
}

export function generateRefreshToken(payload: { userId: number }): string {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: REFRESH_TOKEN_EXPIRY });
}

export function verifyToken<T>(token: string): T {
  return jwt.verify(token, JWT_SECRET) as T;
}

export function decodeToken<T>(token: string): T | null {
  return jwt.decode(token) as T | null;
}
```

## Authentication Middleware

```typescript
// src/middleware/auth.ts
import { Request, Response, NextFunction } from 'express';
import { verifyToken, TokenPayload } from '@/utils/jwt';

declare global {
  namespace Express {
    interface Request {
      user?: TokenPayload;
    }
  }
}

export function authMiddleware(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, error: 'No token provided' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = verifyToken<TokenPayload>(token);
    req.user = payload;
    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      return res.status(401).json({ success: false, error: 'Token expired' });
    }
    return res.status(401).json({ success: false, error: 'Invalid token' });
  }
}
```

## Login Flow

```typescript
// src/controllers/AuthController.ts
import { generateAccessToken, generateRefreshToken } from '@/utils/jwt';

export class AuthController {
  static async login(req: Request, res: Response) {
    const { username, password } = req.body;

    // Validate credentials
    const user = await UserService.validateCredentials(username, password);
    if (!user) {
      return res.status(401).json({ success: false, error: 'Invalid credentials' });
    }

    // Generate tokens
    const accessToken = generateAccessToken({
      userId: user.id,
      username: user.username,
      role: user.role,
    });
    const refreshToken = generateRefreshToken({ userId: user.id });

    // Set refresh token in httpOnly cookie
    res.cookie('refreshToken', refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    });

    res.json({
      success: true,
      data: { accessToken, user: { id: user.id, username: user.username } },
    });
  }
}
```

## Refresh Token Flow

```typescript
export class AuthController {
  static async refresh(req: Request, res: Response) {
    const refreshToken = req.cookies.refreshToken;
    
    if (!refreshToken) {
      return res.status(401).json({ success: false, error: 'No refresh token' });
    }

    try {
      const payload = verifyToken<{ userId: number }>(refreshToken);
      const user = await UserService.findById(payload.userId);
      
      if (!user) {
        return res.status(401).json({ success: false, error: 'User not found' });
      }

      const newAccessToken = generateAccessToken({
        userId: user.id,
        username: user.username,
        role: user.role,
      });

      res.json({ success: true, data: { accessToken: newAccessToken } });
    } catch (error) {
      res.status(401).json({ success: false, error: 'Invalid refresh token' });
    }
  }
}
```

## Role-Based Authorization

```typescript
export function requireRole(...allowedRoles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ success: false, error: 'Not authenticated' });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ success: false, error: 'Insufficient permissions' });
    }

    next();
  };
}

// Usage
router.delete('/user/:id', authMiddleware, requireRole('admin'), deleteUser);
```

## Commands

```bash
# No specific commands
```

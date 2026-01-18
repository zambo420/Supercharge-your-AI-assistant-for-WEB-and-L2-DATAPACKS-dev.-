---
name: vite
description: >
  Vite build tool patterns and configuration.
  Trigger: When configuring Vite, creating plugins, optimizing builds, or working with vite.config.ts.
license: MIT
metadata:
  author: L2Website
  version: "1.0"
  scope: [frontend]
  auto_invoke: "Vite configuration / Build / Dev server"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Configuring vite.config.ts
- Adding Vite plugins
- Optimizing build performance
- Setting up aliases and environment variables
- Configuring dev server

## Configuration Pattern

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import svgr from 'vite-plugin-svgr';
import tailwindcss from '@tailwindcss/vite';
import path from 'path';

export default defineConfig({
  plugins: [
    react(),
    svgr(),
    tailwindcss(),
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@pages': path.resolve(__dirname, './src/pages'),
      '@hooks': path.resolve(__dirname, './src/hooks'),
      '@lib': path.resolve(__dirname, './src/lib'),
    },
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3001',
        changeOrigin: true,
      },
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          router: ['react-router-dom'],
        },
      },
    },
  },
});
```

## Environment Variables

```typescript
// .env files
// .env              - All environments
// .env.local        - Local overrides (gitignored)
// .env.development  - Development
// .env.production   - Production

// Access in code (must start with VITE_)
const apiUrl = import.meta.env.VITE_API_URL;
const isDev = import.meta.env.DEV;
const isProd = import.meta.env.PROD;

// Type definitions
// src/vite-env.d.ts
interface ImportMetaEnv {
  readonly VITE_API_URL: string;
  readonly VITE_APP_TITLE: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
```

## Common Plugins

```typescript
// React
import react from '@vitejs/plugin-react';

// SVG as components
import svgr from 'vite-plugin-svgr';

// TailwindCSS v4
import tailwindcss from '@tailwindcss/vite';

// Bundle analyzer
import { visualizer } from 'rollup-plugin-visualizer';
```

## Commands

```bash
npm run dev       # Development server
npm run build     # Production build
npm run preview   # Preview production build
```

---
name: i18next
description: >
  i18next internationalization patterns for React.
  Trigger: When adding translations, creating language files, or using useTranslation hook.
license: MIT
metadata:
  author: L2Website
  version: "1.0"
  scope: [frontend]
  auto_invoke: "Translations / i18n / Multi-language"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Adding new translations
- Creating translation files
- Using useTranslation hook
- Setting up language switching
- Configuring i18next

## Configuration Pattern

```typescript
// src/i18n/index.ts
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

import en from './locales/en.json';
import es from './locales/es.json';

i18n
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: en },
      es: { translation: es },
    },
    lng: 'en',
    fallbackLng: 'en',
    interpolation: {
      escapeValue: false,
    },
  });

export default i18n;
```

## Translation Files

```json
// src/i18n/locales/en.json
{
  "nav": {
    "home": "Home",
    "characters": "Characters",
    "rankings": "Rankings"
  },
  "common": {
    "loading": "Loading...",
    "error": "An error occurred",
    "retry": "Retry"
  },
  "auth": {
    "login": "Login",
    "logout": "Logout",
    "register": "Register"
  }
}
```

## Usage in Components

```tsx
import { useTranslation } from 'react-i18next';

export function NavBar() {
  const { t, i18n } = useTranslation();

  const changeLanguage = (lng: string) => {
    i18n.changeLanguage(lng);
  };

  return (
    <nav>
      <a href="/">{t('nav.home')}</a>
      <a href="/characters">{t('nav.characters')}</a>
      
      <button onClick={() => changeLanguage('en')}>EN</button>
      <button onClick={() => changeLanguage('es')}>ES</button>
    </nav>
  );
}
```

## Translation with Variables

```tsx
// JSON
{ "welcome": "Welcome, {{name}}!" }

// Component
{t('welcome', { name: user.name })}
```

## Pluralization

```json
{
  "items": "{{count}} item",
  "items_plural": "{{count}} items"
}
```

```tsx
{t('items', { count: 5 })} // "5 items"
```

## Translation Keys Convention

- Use dot notation: `section.subsection.key`
- Keep keys descriptive: `auth.login.button` not `btn1`
- Group by feature/page

## Commands

```bash
# No specific commands - translations are JSON files
```

---
name: react-router
description: >
  React Router v7 patterns for navigation and routing.
  Trigger: When creating routes, navigation, route parameters, or protected routes.
license: MIT
metadata:
  author: L2Website
  version: "1.0"
  scope: [frontend]
  auto_invoke: "Routing / Navigation / Routes"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

## When to Use

- Creating new routes
- Setting up navigation
- Working with route parameters
- Creating protected routes
- Handling redirects

## Router Setup

```tsx
// src/App.tsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Layout } from '@/components/Layout';
import { HomePage } from '@/pages/HomePage';
import { CharactersPage } from '@/pages/CharactersPage';
import { NotFoundPage } from '@/pages/NotFoundPage';

export function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<HomePage />} />
          <Route path="characters" element={<CharactersPage />} />
          <Route path="character/:id" element={<CharacterDetailPage />} />
          <Route path="*" element={<NotFoundPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
```

## Layout with Outlet

```tsx
// src/components/Layout.tsx
import { Outlet } from 'react-router-dom';
import { NavBar } from './NavBar';
import { Footer } from './Footer';

export function Layout() {
  return (
    <div className="min-h-screen flex flex-col">
      <NavBar />
      <main className="flex-1">
        <Outlet />
      </main>
      <Footer />
    </div>
  );
}
```

## Navigation

```tsx
import { Link, NavLink, useNavigate } from 'react-router-dom';

// Link - basic navigation
<Link to="/characters">View Characters</Link>

// NavLink - with active state
<NavLink 
  to="/characters"
  className={({ isActive }) => isActive ? 'text-blue-500' : ''}
>
  Characters
</NavLink>

// Programmatic navigation
const navigate = useNavigate();
navigate('/characters');
navigate(-1); // Go back
navigate('/login', { replace: true }); // Replace history
```

## Route Parameters

```tsx
import { useParams, useSearchParams } from 'react-router-dom';

// URL: /character/123
function CharacterDetail() {
  const { id } = useParams<{ id: string }>();
  return <div>Character ID: {id}</div>;
}

// URL: /characters?page=2&sort=level
function CharacterList() {
  const [searchParams, setSearchParams] = useSearchParams();
  const page = searchParams.get('page') || '1';
  
  const nextPage = () => {
    setSearchParams({ page: String(Number(page) + 1) });
  };
}
```

## Protected Routes

```tsx
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '@/hooks/useAuth';

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated } = useAuth();
  const location = useLocation();

  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return <>{children}</>;
}

// Usage
<Route 
  path="/dashboard" 
  element={
    <ProtectedRoute>
      <DashboardPage />
    </ProtectedRoute>
  } 
/>
```

## Route Location State

```tsx
// Pass state
navigate('/character/123', { state: { from: 'rankings' } });

// Read state
const location = useLocation();
const from = location.state?.from;
```

## Commands

```bash
# No specific commands
```

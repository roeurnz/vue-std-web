# Vue 3.5.22 + TypeScript 7 + Tailwind CSS 4 + ShadCN (latest) + Vite 7 + vue-router 4.5.1 — Project structure

This document describes a comprehensive, production-ready project structure for a Vue 3 application (Vue 3.5.22) using TypeScript 7, Vite 7, Tailwind CSS 4 and the latest ShadCN UI stack with `vue-router` 4.5.1. It focuses on clean separation of concerns, API consumption patterns, routing and layout strategy, and developer ergonomics.

---

## Goals

* Scalable folder layout that supports a growing codebase
* Opinionated places for API calls, state, composables, and UI primitives
* Router layout system that supports nested layouts and route-level auth
* Axios-based API layer with typed request/response and token handling
* Easy to extend with features like i18n, testing, analytics

---

## Top-level folder layout

```
my-vue-app/
├── .vscode/
├── public/
│   └── favicon.ico
├── src/
│   ├── assets/
│   ├── components/         # Small, reusable UI components (dumb)
│   ├── composables/        # Reusable composition functions (useX)
│   ├── layouts/            # App layouts (MainLayout, AuthLayout, EmptyLayout)
│   ├── pages/              # Page-level components (routed)
│   ├── router/             # Router & route definitions
│   ├── services/           # API clients, repositories, 3rd-party integrations
│   ├── stores/             # Pinia stores (or alternative)
│   ├── styles/             # Tailwind entry, global CSS, variables
│   ├── utils/              # Utilities, helpers, constants
│   ├── types/              # Shared TypeScript types/interfaces
│   ├── hooks/              # (alias for composables if preferred)
│   ├── plugins/            # Vue plugins initializers (i18n, toast, etc.)
│   ├── app.vue
│   └── main.ts
├── tests/
├── .env
├── index.html
├── package.json
├── tsconfig.json
├── vite.config.ts
└── tailwind.config.cjs
```

---

## Project scaffolding notes

* **Styling**: Tailwind CSS 4 is used as the utility framework. Keep a single `styles/tailwind.css` entry where Tailwind directives (`@tailwind base; @tailwind components; @tailwind utilities;`) live. Import it once in `main.ts`.

* **UI primitives**: Use ShadCN (Vue port or integrate React-style components if you adopt a compatible library). Create a `components/ui/` folder for shared atomic components (Button, Input, Card) that wrap ShadCN primitives and provide consistent props/variants.

* **TypeScript**: Keep `types/` small and explicit. Use `src/types/api.d.ts` or `models/` for domain models.

* **State**: Use Pinia for state management. Keep stores small (single responsibility) and typed.

---

## `package.json` (example)

```json
{
  "name": "my-vue-app",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint --ext .ts,.tsx,.vue src",
    "format": "prettier --write ."
  },
  "dependencies": {
    "vue": "3.5.22",
    "vue-router": "4.5.1",
    "pinia": "^3.0.0",
    "axios": "^1.5.0",
    "dayjs": "^1.11.0",
    "shadcn-ui": "latest-or-appropriate", // adapt if a Vue port exists
    "@headlessui/vue": "^1.8.0",
    "@heroicons/vue": "^2.0.18"
  },
  "devDependencies": {
    "typescript": "7.0.0",
    "vite": "7.0.0",
    "tailwindcss": "4.0.0",
    "postcss": "8.0.0",
    "autoprefixer": "10.0.0",
    "eslint": "8.0.0",
    "eslint-plugin-vue": "9.0.0",
    "prettier": "2.0.0"
  }
}
```

> Adjust package versions to the most suitable available at install time.

---

## Key config files (snippets)

### `tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "lib": ["ESNext", "DOM"],
    "jsx": "preserve",
    "strict": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "baseUrl": "./",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src/**/*.ts","src/**/*.d.ts","src/**/*.vue"]
}
```

### `vite.config.ts` (basic)

```ts
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  }
})
```

### `tailwind.config.cjs`

```js
module.exports = {
  content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
  theme: {
    extend: {}
  },
  plugins: []
}
```

---

## `src/main.ts`

```ts
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from '@/router'
import App from '@/app.vue'
import '@/styles/tailwind.css'

const app = createApp(App)
app.use(createPinia())
app.use(router)
// register global plugins e.g. i18n, toast, analytics here

app.mount('#app')
```

---

## Router strategy (src/router)

Structure:

```
src/router/
├── index.ts           # createRouter + route registration
├── routes.ts          # route definitions & lazy imports
└── guards.ts          # navigation guards (auth, permissions, etc.)
```

### `routes.ts` example

```ts
import { RouteRecordRaw } from 'vue-router'

export const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: () => import('@/layouts/MainLayout.vue'),
    children: [
      { path: '', name: 'Home', component: () => import('@/pages/HomePage.vue') },
      { path: 'dashboard', name: 'Dashboard', component: () => import('@/pages/DashboardPage.vue'), meta: { requiresAuth: true } }
    ]
  },
  {
    path: '/auth',
    component: () => import('@/layouts/AuthLayout.vue'),
    children: [
      { path: 'login', name: 'Login', component: () => import('@/pages/auth/LoginPage.vue') },
      { path: 'register', name: 'Register', component: () => import('@/pages/auth/RegisterPage.vue') }
    ]
  },
  { path: '/:pathMatch(.*)*', name: 'NotFound', component: () => import('@/pages/NotFound.vue') }
]
```

### `index.ts` (router)

```ts
import { createRouter, createWebHistory } from 'vue-router'
import { routes } from './routes'
import { setupGuards } from './guards'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

setupGuards(router)

export default router
```

### `guards.ts` (auth guard pattern)

```ts
import type { Router } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

export function setupGuards(router: Router) {
  router.beforeEach(async (to, from, next) => {
    const auth = useAuthStore()
    const requiresAuth = to.meta?.requiresAuth

    if (requiresAuth && !auth.isAuthenticated) {
      return next({ name: 'Login', query: { redirect: to.fullPath } })
    }

    next()
  })
}
```

---

## API layer (src/services/api)

Keep a single axios instance with interceptors for auth token and error handling, and create small repository wrappers for different resources.

```
src/services/
├── api/
│   ├── axios.ts        # configured axios instance
│   ├── auth.ts         # auth endpoints wrapper
│   └── users.ts        # users endpoints wrapper
└── repositories/       # optional higher-level wrappers
```

### `axios.ts` example

```ts
import axios from 'axios'
import { getAuthToken, clearAuthToken } from '@/utils/auth'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api',
  timeout: 15000
})

api.interceptors.request.use(config => {
  const token = getAuthToken()
  if (token && config.headers) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

api.interceptors.response.use(
  res => res,
  err => {
    if (err.response?.status === 401) {
      clearAuthToken()
      // optionally emit a global event or redirect
    }
    return Promise.reject(err)
  }
)

export default api
```

### `auth.ts` example

```ts
import api from './axios'

export const authApi = {
  login: (payload: { email: string; password: string }) => api.post('/auth/login', payload),
  me: () => api.get('/auth/me'),
  logout: () => api.post('/auth/logout')
}
```

---

## Composables (src/composables)

Examples:

* `useFetch.ts` — tiny wrapper returning `loading`, `error`, `data`
* `useAuth.ts` — login/logout helpers wired to auth store
* `useDebounce.ts`, `useLocalStorage.ts`

`useFetch` sample:

```ts
import { ref } from 'vue'

export function useFetch<T = unknown>(fn: () => Promise<T>) {
  const loading = ref(false)
  const error = ref<Error | null>(null)
  const data = ref<T | null>(null)

  async function execute() {
    loading.value = true
    error.value = null
    try {
      data.value = await fn()
    } catch (e) {
      error.value = e as Error
    } finally {
      loading.value = false
    }
  }

  return { data, loading, error, execute }
}
```

---

## Stores (Pinia)

Example `src/stores/auth.ts`:

```ts
import { defineStore } from 'pinia'
import { authApi } from '@/services/api/auth'
import { ref } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null as null | Record<string, any>)
  const token = ref<string | null>(null)

  async function login(payload: { email: string; password: string }) {
    const res = await authApi.login(payload)
    token.value = res.data.token
    user.value = res.data.user
    // persist token
  }

  function logout() {
    token.value = null
    user.value = null
    // clear persisted token
  }

  return { user, token, login, logout, get isAuthenticated() { return !!token.value } }
})
```

---

## Components & UI organization

```
src/components/
├── ui/                # design system primitives (Button.vue, Input.vue)
├── layout/            # header, footer, sidebar components
└── common/            # moderate-size components (Table, Modal, Form)
```

* Keep `ui` primitives unopinionated and small
* Provide a `variants.ts` or `classNames` helper if you use variant props across components

---

## Pages & Layouts

* Pages are route endpoints: `src/pages/*` (e.g., `pages/HomePage.vue`, `pages/ProfilePage.vue`)
* Layouts live in `src/layouts/` and used as route components to wrap pages with common chrome

Example `MainLayout.vue` responsibilities:

* Render top nav, sidebar, footer
* Provide `<slot />` for page content
* Add keyboard shortcuts, global modals

---

## Utils & Constants

Examples:

* `utils/format.ts` — date, currency helpers
* `utils/http.ts` — helper for building query strings
* `utils/classNames.ts` — small helper to merge css classes

Keep utils pure and typed.

---

## Types

Keep a `src/types/` folder with `api.ts`, `models.ts`, `router.d.ts` if needed for route meta typing.

---

## Testing & CI

* Add `vitest` for unit tests
* Add `cypress` or `playwright` for E2E
* Setup GitHub Actions to run lint/tests on PR

---

## Example dev workflow when consuming API

1. Create typed API wrapper in `services/api`.
2. Create a Pinia store that uses the wrapper to fetch and mutate data.
3. Create a page component that imports the store or a composable which orchestrates loading.
4. Use route `meta` and `guards` to protect pages.
5. Use optimistic UI updates sparingly; prefer revalidation after server mutation.

---

## Recommended conventions

* File names: `kebab-case` for files, `PascalCase.vue` for components
* Exports: Prefer default export for `.vue` components; named exports for composables and stores
* Keep components < 300 lines when possible
* Keep composables single-responsibility and test them

---

## Helpful dev tips

* Use `vite`'s alias `@` to avoid long relative imports
* Centralize environment variables (VITE_API_BASE_URL) and never commit secrets
* Use strict TypeScript with `unknown` and `asserts` when parsing API responses
* Use a design token file for colors and sizes if customizing Tailwind

---

If you'd like, I can also:

* generate a ready-to-copy `vite` + `tsconfig` + `tailwind` starter with basic files
* scaffold Axios interceptors and a sample `LoginPage.vue` + `MainLayout.vue`

Tell me which of the above you want scaffolded next and I will add the actual file contents.

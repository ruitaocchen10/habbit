# Habbit User Authentication Spec

## Table of Contents

- [Overview](#overview)
- [Authentication Methods](#authentication-methods)
- [User Flows](#user-flows)
  - [Sign-In (OAuth)](#sign-in-oauth)
  - [Session Restoration on Launch](#session-restoration-on-launch)
  - [Sign-Out](#sign-out)
- [App State Machine](#app-state-machine)
- [Architecture & Components](#architecture--components)
- [Deep Link Handling](#deep-link-handling)
- [Session Lifecycle Events](#session-lifecycle-events)
- [Error Handling](#error-handling)
- [Profile Creation](#profile-creation)
- [Security Considerations](#security-considerations)

---

## Overview

Authentication in Habbit is handled entirely via **Supabase Auth**. Users sign in with a third-party OAuth provider (Google or Apple). There are no passwords or email/magic-link flows. A valid Supabase `Session` is the single source of truth for whether the user is authenticated.

---

## Authentication Methods

| Method          | Provider   | Notes                                     |
|-----------------|------------|-------------------------------------------|
| OAuth (Google)  | Google     | Opens system browser; redirects back via deep link |
| OAuth (Apple)   | Apple      | Uses Sign in with Apple; redirects back via deep link |

Both flows follow the same pattern: Supabase opens an OAuth URL in the system browser, the provider authenticates the user, and then redirects back to the app via a custom URL scheme, which Supabase uses to exchange tokens and establish a session.

---

## User Flows

### Sign-In (OAuth)

1. User taps **Continue with Google** or **Continue with Apple** on `LoginView`.
2. `AuthManager.signIn(provider:)` is called, which invokes `SupabaseService.client.auth.signInWithOAuth(provider:redirectTo:)`.
3. Supabase opens the provider's OAuth page in the system browser.
4. After the user authenticates, the provider redirects to `Config.oauthRedirectURL` (a custom deep link URL).
5. iOS delivers the URL to `habbitApp` via `onOpenURL`.
6. `AuthManager.handle(url:)` calls `SupabaseService.client.auth.session(from: url)` to exchange the code for a session.
7. The auth state change listener (`listenToAuthChanges`) receives a `.signedIn` event and sets `session`.
8. `ContentView` detects `authManager.isAuthenticated == true` and shows `HomeView`.

```
User taps sign-in
    → signInWithOAuth (opens browser)
    → OAuth provider authenticates
    → Redirects to oauthRedirectURL
    → onOpenURL → handle(url:)
    → session(from: url) → session established
    → authStateChanges: .signedIn
    → session set → HomeView shown
```

### Session Restoration on Launch

1. App launches; `AuthManager.init()` calls `loadCurrentSession()`.
2. `SupabaseService.client.auth.session` is awaited — returns the stored session if valid, throws if none.
3. If a session exists: `session` is set and `isLoading = false` → `HomeView` shown.
4. If no session (throws): `session = nil`, `isLoading = false` → `LoginView` shown.

```
App launches
    → loadCurrentSession()
    → client.auth.session
        ├─ valid session  → session set → HomeView
        └─ no session     → session nil → LoginView
```

### Sign-Out

1. User triggers sign-out (e.g. from a settings screen).
2. `AuthManager.signOut()` calls `SupabaseService.client.auth.signOut()`.
3. The auth state change listener receives `.signedOut`, sets `session = nil`.
4. `ContentView` detects `authManager.isAuthenticated == false` and shows `LoginView`.

---

## App State Machine

`ContentView` renders one of three states based on `AuthManager`:

| State           | Condition                              | UI Shown        |
|-----------------|----------------------------------------|-----------------|
| **Loading**     | `authManager.isLoading == true`        | `ProgressView`  |
| **Unauthenticated** | `isLoading == false`, `session == nil` | `LoginView`     |
| **Authenticated**   | `isLoading == false`, `session != nil` | `HomeView`      |

Transitions:

```
[Loading] ──────────────────→ [Authenticated]
    └──────────────────────→ [Unauthenticated]

[Unauthenticated] ──sign-in──→ [Authenticated]
[Authenticated]   ──sign-out─→ [Unauthenticated]
```

---

## Architecture & Components

### `AuthManager.swift` — Auth State Container

An `@Observable` class that lives at the app level and is injected into the SwiftUI environment.

| Property / Method           | Purpose                                                                 |
|-----------------------------|-------------------------------------------------------------------------|
| `session: Session?`         | The active Supabase session; `nil` when signed out                      |
| `isLoading: Bool`           | `true` while the initial session check is in progress                   |
| `errorMessage: String?`     | Surfaces auth errors to the UI                                          |
| `isAuthenticated: Bool`     | Computed from `session != nil`                                          |
| `loadCurrentSession()`      | Reads the stored session on launch; sets `isLoading = false` when done  |
| `listenToAuthChanges()`     | Async stream that updates `session` on every auth state event           |
| `signIn(provider:)`         | Initiates OAuth sign-in via the system browser                          |
| `signOut()`                 | Signs the user out and clears the session                               |
| `handle(url:)`              | Processes the deep link URL to complete the OAuth exchange              |

### `LoginView.swift` — Sign-In Screen

Displays app branding and two OAuth buttons (Google, Apple). Reads `authManager.errorMessage` and shows it below the buttons if present. Each button calls `authManager.signIn(provider:)` in a `Task`.

### `ContentView.swift` — Auth Gate

The root view that switches between `ProgressView`, `LoginView`, and `HomeView` based on `AuthManager` state. Reads `AuthManager` from the environment.

### `habbitApp.swift` — App Entry Point

- Creates the `AuthManager` `@State` instance (lives for the app's lifetime).
- Injects it into the environment via `.environment(authManager)`.
- Attaches `.onOpenURL` to route deep links to `authManager.handle(url:)`.

### `SupabaseService.swift` — Supabase Client

Holds the shared `SupabaseClient` singleton used for all backend calls, including auth.

### `Config.swift` — Credentials & Config

Contains `oauthRedirectURL` — the custom URL scheme registered in the app that OAuth providers redirect to after authentication. This file is excluded from version control.

---

## Deep Link Handling

The app registers a custom URL scheme (defined in `Config.oauthRedirectURL`) that OAuth providers use as the redirect target after authentication.

**Flow:**
1. Supabase passes this URL as the `redirectTo` parameter in `signInWithOAuth`.
2. iOS intercepts the redirect and delivers it to `habbitApp` via `.onOpenURL { url in authManager.handle(url: url) }`.
3. `handle(url:)` calls `client.auth.session(from: url)`, which extracts tokens from the URL and stores the session.

The URL scheme must be registered in the Xcode project's Info plist / URL Types for iOS to route it to the app.

---

## Session Lifecycle Events

`AuthManager.listenToAuthChanges()` listens to `client.auth.authStateChanges` and handles these events:

| Event               | Action             | When it occurs                                      |
|---------------------|--------------------|-----------------------------------------------------|
| `.initialSession`   | Set `session`      | First event on stream start; reflects current state |
| `.signedIn`         | Set `session`      | After successful sign-in or deep link exchange      |
| `.tokenRefreshed`   | Set `session`      | Supabase auto-refreshes the access token            |
| `.userUpdated`      | Set `session`      | User profile data changed                           |
| `.signedOut`        | Set `session = nil`| After `signOut()` is called                         |
| `.passwordRecovery` | Set `session = nil`| Password reset flow (not actively used)             |
| All others          | Ignored (`break`)  |                                                     |

---

## Error Handling

Errors are surfaced through `AuthManager.errorMessage: String?`.

- Set to `nil` at the start of each `signIn` / `signOut` call.
- Set to `error.localizedDescription` if the call throws.
- `LoginView` renders the error message in red below the OAuth buttons when non-nil.
- `handle(url:)` also sets `errorMessage` if token exchange fails.

---

## Profile Creation

When a user signs up for the first time via OAuth, Supabase Auth creates a row in `auth.users`. A database trigger automatically creates a corresponding row in the `profiles` table with the new `auth.users.id` as the primary key.

See `specs/data-schema.md` → [`profiles`](data-schema.md#profiles) for the full schema.

---

## Security Considerations

- **No passwords stored client-side.** Authentication is delegated entirely to Google / Apple and Supabase Auth.
- **Credentials excluded from version control.** The Supabase URL and anon key live in `Config.swift`, which is git-ignored.
- **Row Level Security (RLS).** All Supabase tables enforce RLS policies that require a valid JWT (from the Supabase session). Unauthenticated requests are rejected at the database level.
- **Token refresh.** Supabase automatically refreshes access tokens; the app reacts via the `.tokenRefreshed` auth event to keep `session` current.
- **Short-lived access tokens.** The session object contains a JWT access token with a limited lifetime. The anon key is only used to initialize the client, not for user-level operations.

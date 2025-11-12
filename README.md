# inDriver / Uber Clone (Flutter)

**Author:** Neyen Sessarego — https://github.com/neyen-s

Educational / portfolio project: a clone of **Uber / InDriver** (client + driver).  
Full-stack project (Flutter frontend + custom backend). Built to demonstrate experience in Flutter, Clean Architecture, and socket-based features.

---

## Status
- **Main branch:** `main`  
- **Status:** In development (most features implemented).  
  Tests and CI are being added.

---

## Key features
- Authentication (sign up / sign in) and session management.
- Roles: **Client** and **Driver**.
- Map with initial camera position and location updates.
- Trip requests and driver assignment via sockets.
- Profile editing (including image upload).
- Driver car info page (brand, color, plate).
- Token expiration handling and refresh strategy (client-side logic).
- Clean Architecture (feature-first): `presentation` (Bloc + Formz), `domain`, `data`.
- Dependency injection using `GetIt`.

---

## Tech stack
- Flutter (Dart)
- State management: Bloc
- Form validation: Formz (`^0.8.0`)
- DI: GetIt
- Sockets: socket.io (client)
- Maps: Google Maps (set up API key)
- Backend: custom REST API (local for now)

---

## Installation / Getting started

1. Clone the repo:
```bash
git clone https://github.com/neyen-s/inDriver-uber-clone.git
cd inDriver-uber-clone

# Apartment Maintenance Web

Production-oriented Flutter Web frontend for the Apartment Maintenance NestJS API. The app uses Clean Architecture, feature-first modules, Material 3, BLoC, GetIt/Injectable, Dio, and go_router.

## Backend contract

Swagger was inspected at `http://localhost:3000/api/docs`. No backend source was present in this workspace, so the checked-in frontend uses only documented endpoints.

| Method | Path | Auth | Documented request | Purpose |
|---|---|---:|---|---|
| POST | `/auth/register` | Public | `name`, `email`, `password` | Register a resident |
| POST | `/auth/login` | Public | `email`, `password` | Authenticate |
| GET | `/auth/me` | Bearer | — | Restore current user |
| GET | `/users` | Bearer | No query parameters documented | List users |
| GET | `/users/:id` | Bearer | String path ID | User details |
| PATCH | `/users/:id` | Bearer | Swagger schema is empty | Update user |
| PATCH | `/users/:id/status` | Bearer | Swagger schema is empty | Change active status |

Swagger documents registration `201/409`, login `200/401/403`, and `/auth/me` `200/401`. It does not publish response schemas, pagination/filter query parameters, user-operation error responses, DTO validation constraints, or role guards. The client accepts direct and common `{data: ...}` response envelopes. It sends `name`, `email`, and `role` to the user update endpoint and `isActive` to the status endpoint; these fields must be confirmed in backend DTO documentation.

Because `GET /users` declares no query parameters, filtering and pagination are performed client-side. Move these operations server-side when the backend documents pagination and filters.

## Run locally

Requirements: Flutter stable with Dart 3.11 or later, and the NestJS API running on port 3000.

```sh
flutter pub get
dart run build_runner build
flutter run -d chrome --web-port 8080 \
  --dart-define=APP_ENV=development \
  --dart-define=API_BASE_URL=http://localhost:3000/api
```

The NestJS `CORS_ORIGINS` setting must include the exact browser origin, including port:

```env
CORS_ORIGINS=http://localhost:8080
```

## Environment configuration

- `APP_ENV`: `development`, `staging`, or `production`; defaults to `development`.
- `API_BASE_URL`: absolute HTTP(S) API root; defaults to `http://localhost:3000/api`.

Invalid values fail during bootstrap with an actionable error. Example staging build:

```sh
flutter build web --release \
  --dart-define=APP_ENV=staging \
  --dart-define=API_BASE_URL=https://staging.example.com/api
```

## Architecture

`lib/app` owns bootstrap, DI, routes, and theme. `lib/core` contains narrowly shared configuration, networking, storage, errors, routing policy, validation, and common widgets. Each directory under `lib/features` owns its data, domain, and presentation layers.

Domain code has no Flutter, Dio, or browser-storage dependencies. Data sources decode API responses; repositories map failures and return domain entities; use cases connect repositories to focused BLoCs/Cubits. Features never import another feature's data or presentation layer.

Authentication restores the JWT through `/auth/me`, handles inactive accounts separately through backend `403` messages, and clears the client session on logout or protected-endpoint `401`. Concurrent `401` responses are coalesced to one invalidation. No refresh flow exists because Swagger exposes no refresh endpoint.

Admin-only user navigation and redirects are a UX control only. The NestJS guards remain authoritative. Swagger currently identifies bearer-protected operations but does not document which roles may update user roles or statuses; verify and enforce this on the backend.

## Browser token security

`TokenStorage` makes persistence replaceable. The current Web implementation uses `shared_preferences`, backed by browser-readable local storage. This survives refreshes but is vulnerable if cross-site scripting occurs. The app never stores passwords and never logs tokens, authorization headers, request bodies, or responses.

If the backend later supports Secure, HttpOnly, SameSite cookies, replace the storage/auth transport without changing presentation or domain code. Strong Content Security Policy, dependency hygiene, output escaping, and HTTPS are required in production.

## Verification

```sh
dart format .
flutter analyze
flutter test
flutter build web --release \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://api.example.com/api
```

Tests use mocks and a Dio adapter; they do not require a live backend. They cover error mapping, bearer-token behavior, auth repository/session handling, AuthBloc restoration/login/logout, user filtering/pagination/mutations, authorization redirects, form validation, and shared async-state widgets.

## Deployment

Deploy the contents of `build/web` over HTTPS. Configure the host to rewrite every unknown application path to `/index.html`, otherwise refreshed deep links such as `/users/:id` will return a server 404. Do not rewrite static asset requests that actually exist. Set the production API CORS allowlist to the exact deployed frontend origin.

Future business modules should be added only after their controller/DTO/enum/guard contracts exist. Add one feature-first data/domain/presentation module and role-aware route/navigation entry per backend module; do not ship mock-backed production routes.

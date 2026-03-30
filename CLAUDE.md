# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FamilySync is a Flutter mobile app (iOS + Android + Web) — a shared family command center. It replaces scattered group chats and paper lists with a unified household hub: shared calendar, task/chore board, grocery list, announcements feed, and Kid Mode.

**Backend:** Supabase (Auth + PostgreSQL + Realtime + Storage + Edge Functions)
**State Management:** Riverpod (with code generation via `riverpod_generator`)
**Navigation:** GoRouter (declarative, deep-link ready)
**Architecture:** Feature-first Clean Architecture (data / domain / presentation layers per feature)

---

## Flutter Commands

```bash
# Run the app (debug)
flutter run

# Run on a specific device
flutter run -d <device-id>
flutter devices  # list available devices

# Build
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android App Bundle (Play Store)
flutter build ipa --release          # iOS (requires Xcode)
flutter build web --release          # Web

# Code generation (Freezed models, Riverpod providers, JSON serialization)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs  # watch mode

# Analysis & linting
flutter analyze
dart format lib/ test/

# Tests
flutter test                         # all tests
flutter test test/features/auth/     # single feature
flutter test --name "test name"      # single test by name

# Dependencies
flutter pub get
flutter pub upgrade --major-versions  # upgrade with breaking changes
flutter pub outdated                  # check outdated packages

# Clean
flutter clean && flutter pub get

# Launcher icons + splash screen
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## Project Structure

```
lib/
├── main.dart                    # Entry point — initializes Supabase, Firebase, env
├── app/
│   ├── app.dart                 # Root MaterialApp.router + ProviderScope
│   ├── router.dart              # All GoRouter routes + redirect guards
│   └── theme.dart               # Material 3 design tokens (colors, typography, spacing)
├── core/
│   ├── constants/               # App-wide constants (table names, route paths, etc.)
│   ├── extensions/              # Dart extension methods (BuildContext, String, DateTime)
│   ├── utils/                   # Pure utility functions (date formatting, validators)
│   └── errors/                  # Failure sealed classes, error handling
├── features/
│   ├── auth/
│   ├── household/
│   ├── calendar/
│   ├── tasks/
│   ├── grocery/
│   ├── feed/
│   └── kid_mode/
└── shared/
    ├── widgets/                 # Reusable components (AppButton, AppCard, Avatar, etc.)
    ├── providers/               # Global providers (supabase client, current user, household)
    └── services/                # Supabase service, FCM service, analytics service
```

Each feature follows Clean Architecture layers:
```
features/<feature>/
├── data/
│   ├── models/          # Freezed + JsonSerializable DTOs (map to/from Supabase rows)
│   ├── repositories/    # Concrete repository implementations (calls datasources)
│   └── datasources/
│       ├── remote/      # Supabase queries + realtime subscriptions
│       └── local/       # Isar database access (offline-first: grocery, tasks)
├── domain/
│   ├── entities/        # Pure Dart domain objects (no JSON/Supabase coupling)
│   ├── repositories/    # Abstract repository interfaces
│   └── usecases/        # Single-responsibility business logic classes
└── presentation/
    ├── screens/         # Full-page widgets, one per route
    ├── widgets/         # Feature-scoped UI components
    └── controllers/     # Riverpod AsyncNotifier / Notifier controllers
```

---

## Architecture Patterns

### Riverpod State Management
- Use `@riverpod` annotation (code-gen) for all providers — run `build_runner` after changes
- `AsyncNotifier` for async state with loading/error/data states
- `Notifier` for pure sync state (e.g., UI toggle state)
- Provider naming convention: `featureNameProvider` (e.g., `calendarEventsProvider`)
- Global providers live in `shared/providers/` — feature providers stay in their feature

### Navigation (GoRouter)
- All routes defined in `app/router.dart` — never use `Navigator.push` directly
- Route paths are constants in `core/constants/routes.dart`
- `redirect` guard in GoRouter checks auth state via `authStateProvider`
- Deep links (household invites) handled via `app_links` package feeding into GoRouter

### Data Flow
```
Supabase/Isar → Repository → UseCase → Controller (Riverpod) → Screen/Widget
```
- Repositories return `Either<Failure, T>` or throw typed exceptions — never raw Supabase errors
- Screens watch providers: `ref.watch(someProvider)` — handle AsyncValue with `.when()`
- Real-time: Supabase Realtime subscriptions live in remote datasources, broadcast via `StreamProvider`

### Offline-First (Grocery + Tasks)
- Isar is the source of truth for grocery list and tasks
- On app start: sync from Supabase → write to Isar
- User actions: write to Isar immediately (optimistic), then sync to Supabase
- Supabase Realtime pushes updates → overwrite Isar

### Code Generation Files
Files ending in `.g.dart` and `.freezed.dart` are generated — never edit manually.
Always run `build_runner` after modifying:
- Any class annotated with `@freezed`, `@JsonSerializable`, or `@riverpod`

---

## Backend (Supabase)

- **Project config:** stored in `.env` (via `flutter_dotenv`) — `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- **Supabase client:** accessed via `shared/providers/supabase_provider.dart`
- **Row Level Security (RLS):** every table has RLS enabled — users can only read/write rows belonging to their `household_id`
- **Key tables:** `households`, `household_members`, `calendar_events`, `tasks`, `grocery_items`, `feed_posts`
- **Realtime:** subscriptions are set up on `grocery_items` and `tasks` tables for collaborative sync
- Auth providers: Email magic link, Google SSO, Apple SSO

---

## Kid Mode

Kid Mode is a distinct UI layer — not a separate app. It is activated per member profile (role = `'child'`). Rules:
- Simplified navigation: only Tasks and Calendar tabs
- Large touch targets (minimum 56px), big icons, minimal text
- Shows only events/tasks assigned to the child's user ID
- No access to feed, grocery, or household settings
- High contrast support via `MediaQuery.highContrast`
- GoRouter redirect sends child users to `/kid` shell route

---

## Design System

All visual tokens defined in `app/theme.dart` using Material 3 (`ColorScheme.fromSeed`):
- **Seed color:** family-warm palette (amber/teal — TBD final brand color)
- **Typography:** `GoogleFonts` — headings use a friendly rounded font, body uses system default
- **Spacing:** 4px base grid — use multiples of 4 (`AppSpacing.xs = 4`, `sm = 8`, `md = 16`, `lg = 24`, `xl = 32`)
- Never hardcode colors or font sizes outside of `theme.dart`

---

## Developer Notes

- **New to Flutter (experienced in Java/Python/AWS):** Flutter widgets are like React components — `StatelessWidget` = pure function component, `ConsumerWidget` (Riverpod) = component with hooks. Think of `BuildContext` as a handle to the widget tree (like a DI container).
- **Dart null safety:** all code must be null-safe. Use `?` for nullable types, `!` only when you are certain (prefer `??` or `?.`).
- **`async/await` in Flutter:** works identically to JS/Python async. `Future<T>` = Promise/coroutine. Use `ref.watch` for reactive streams, `ref.read` for one-shot calls inside callbacks.
- **Hot reload** (`r` in terminal) reloads UI without restarting — preserves state. **Hot restart** (`R`) restarts fully. Use hot restart when adding new providers.
- **Environment:** never commit `.env` — it is gitignored. Copy `.env.example` to `.env` and fill in Supabase credentials.

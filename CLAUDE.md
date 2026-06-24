# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run the app
flutter analyze          # Static analysis / lint
flutter test             # Run all tests
flutter test test/widget_test.dart  # Run a single test file
flutter build apk        # Android release build
flutter build ios        # iOS release build
```

## Environment

The app reads credentials from `.env` (bundled as a Flutter asset). Required keys:

```
SUPABASE_URL=
SUPABASE_ANON_KEY=
ANTHROPIC_API_KEY=
GOOGLE_WEB_CLIENT_ID=   # Android only — iOS reads from GoogleService-Info.plist
```

The `.env` file is loaded in `main.dart` via `flutter_dotenv` before `Supabase.initialize`.

## Architecture

**App**: Shree Iron Works — a manufacturing operations app (orders, inventory, invoices, machines, drawings, team, suppliers) with an embedded Claude AI assistant.

### State Management: flutter_bloc (Cubits only)

All state lives in cubits under `lib/cubits/`. Screens never hold business logic; they read from and emit to cubits. Models extend `Equatable` for value equality.

Active cubits and their scope:
- `AuthCubit` — Supabase session lifecycle, mounted at root before any other cubit
- `NavigationCubit` — custom stack-based navigation (see below)
- `OrdersCubit`, `InventoryCubit`, `InvoicesCubit` — domain data
- `AgentCubit` — AI chat, holds and drives the agent system

### Auth Flow

`AuthCubit` subscribes to `AuthService.authStateChanges` (a Supabase stream). The `_AuthGate` widget in `app.dart` switches between `SignInScreen` and `_AppProviders` based on auth state. All business cubits (`OrdersCubit`, etc.) are only created after auth is confirmed, inside `_AppProviders`.

`AuthService` is a singleton (`AuthService.instance`) and supports email/password and native Google Sign-In (no browser redirect).

### Navigation

Navigation is **not** Flutter's `Navigator` route system. Instead, `NavigationCubit` maintains a `List<ScreenEntry>` stack. `_AppRoot` maps the stack to `MaterialPage` objects and hands them to a `Navigator`. All navigation calls go through the cubit:

```dart
context.read<NavigationCubit>().navigateTo(AppScreen.orders);
context.read<NavigationCubit>().back();
context.read<NavigationCubit>().showToast('Done');
```

`AppScreen` (enum in `navigation_state.dart`) is the exhaustive list of all screens. Adding a new screen requires: adding the enum value, adding a `_screenForEntry` case in `app.dart`, and adding the screen widget.

### Data Layer: Repositories → Supabase

Each domain has a repository in `lib/repositories/` that calls `Supabase.instance.client` directly. There is no custom API abstraction. Repositories return typed model instances parsed via `fromJson`. Cubits call repositories; screens never call repositories directly.

Schema lives in `supabase/schema.sql` and must be applied manually via the Supabase SQL editor.

### AI Agent System (multi-agent)

The agent system is a three-layer hierarchy under `lib/agents/`:

```
AgentCubit
  └── OrchestratorAgent        # routes user requests to sub-agents
        ├── UIAgent             # calls NavigationCubit to change screens / show toasts
        └── BusinessLogicAgent  # queries OrdersCubit / InventoryCubit / InvoicesCubit
```

`AgentService` (singleton) is the raw Anthropic SDK wrapper. It runs a tool-use loop until the model stops requesting tools, then returns the final text. `BaseAgent` provides the `run(task, history)` interface; each specialized agent defines its own `systemPrompt` and `tools`.

`AgentCubit` is injected with the other cubits at construction time so the `BusinessLogicAgent` and `UIAgent` can read live state and dispatch actions.

### Theme

All colors are centralized in `lib/core/theme/app_colors.dart` (`AppColors`). Use `AppColors.*` constants throughout — do not inline hex values.

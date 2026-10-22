[English](README.md) | [简体中文](README.zh-CN.md)

# Tinycast

A cross-platform podcast client built with Flutter, available on Android, iOS, macOS, Windows, and Linux.

## Features

- **Subscriptions**: subscribe by RSS URL with episode preview and selection, and import OPML files; subscribed feeds refresh on a configurable schedule.
- **Playback**: background playback and lock-screen controls, 0.5×–2.0× speed, configurable skip durations, continuous play, sleep timer, and a play queue.
- **Offline downloads**: download individual episodes, batches, or an entire podcast; pause, resume, and cancel downloads, with support for resuming partial downloads; configure automatic download policies and clean up cached files by type, podcast, or retention count.
- **Library**: local search, favorites, playback history, search history, and downloaded episodes.
- **Cloud sync**: after signing in with Supabase, subscriptions, playback history, favorites, and the play queue sync incrementally across devices.
- **Theming**: a custom HOCON-driven design system that follows the system light/dark mode and does not use Material `ThemeData`.

## Tech stack

Flutter + Riverpod 3 + Isar. Audio playback uses `just_audio` and `audio_service`, networking uses Dio, and cloud sync is powered by Supabase. Navigation goes through the project's custom `AppRouter`; themes are loaded from `assets/themes/*.conf` at startup.

## Getting started

Requirements: Flutter with Dart SDK `^3.9.2`.

```bash
flutter pub get

# For sign-in / cloud sync: copy the template and fill in your Supabase credentials
cp .env.example .env
./run.sh
```

`./run.sh` reads `.env` and passes the values as `--dart-define` arguments. It launches on the current desktop platform by default; pass a platform argument to target iOS or Android:

```bash
./run.sh ios
./run.sh android
```

For iOS and Android, the target device comes from `iOS_Device_ID` and `Android_Device_ID` in `.env`. Run `flutter devices` to list available devices.

Running `flutter run` directly does not read `.env`. You can also run `flutter run` without Supabase configured; the app skips cloud service initialization, and local subscriptions, playback, and downloads remain available. See [docs/guides/supabase_setup.md](docs/guides/supabase_setup.md) for details.

## Project structure

```text
lib/
├── core/           # Routing, theming, auth, sync, refresh scheduling, and logging
├── data/           # Isar database, data sources, models, repositories, download and RSS services
├── domain/         # Entities, repository interfaces, and use cases
├── presentation/   # Pages, shared widgets, and Riverpod providers
├── main.dart       # App entry point and multi-window bootstrap
├── multi_window.dart
└── window_utils.dart
assets/themes/      # colors.conf / typography.conf / styles.conf
docs/               # Database, sync, downloads, theming, and other guides
test/               # Unit, widget, and data source tests
```

After changing an Isar collection definition, regenerate the model code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Documentation

- [AGENTS.md](AGENTS.md): coding conventions, architecture rules, and the full documentation index; the root entry point for developers and AI agents
- [docs/README.md](docs/README.md): documentation index organized by task
- [docs/reference/database.md](docs/reference/database.md): Isar collection definitions, relationships, and code generation
- [docs/guides/supabase_setup.md](docs/guides/supabase_setup.md): Supabase credential setup and initialization troubleshooting
- [docs/debugging/sync_debug_guide.md](docs/debugging/sync_debug_guide.md): cloud sync triggers, logs, and troubleshooting
- [docs/guides/audio_download_usage.md](docs/guides/audio_download_usage.md): download and cache cleanup APIs
- [docs/theme/overview.md](docs/theme/overview.md): HOCON theme loading and usage
- [docs/reference/platform_permissions.md](docs/reference/platform_permissions.md): platform permissions, sandboxing, and file access

## Pre-delivery checks

Before delivering code, **you must** run the following commands and confirm they pass:

```bash
flutter analyze   # static analysis; zero warnings required
flutter test      # full test suite
```

Pass criteria:

- `flutter analyze`: final line `No issues found!`, exit code `0`; any reported issue means failure
- `flutter test`: final line `All tests passed!`, exit code `0`; `Some tests failed.` means failure

For the AI-agent end-of-session delivery gate (run the commands and record the results in the delivery summary), see [AGENTS.md](AGENTS.md#交付前检查).

### CI policy

The project currently has **no hosted CI** (no GitHub Actions or GitLab CI pipeline). Delivery verification relies on developers running the two commands above locally.

This is intentional: the project is in early iteration, and the test suite and multi-platform build matrix are not yet fully stable, so a mandatory CI gate would add excessive maintenance cost. If CI is added later, the minimal pipeline should use `flutter analyze` and `flutter test` as its pass criteria.

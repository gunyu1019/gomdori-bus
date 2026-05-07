# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter cross-platform app providing bus information for Kangwon National University students. Targets Android, iOS, and web.

- Package: `kr.ac.kangwon.kangwon_bus`
- Dart SDK: ^3.10.4, Flutter 3.18.0+

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter run -d chrome    # Run on web
flutter build apk        # Build Android APK
flutter build appbundle  # Build Android App Bundle
flutter build web        # Build web
flutter test             # Run tests
flutter analyze          # Static analysis
```

## Architecture

`lib/main.dart` is currently the single Dart entry point. The app uses Material Design with standard Flutter widget composition.

Native platform code is minimal:
- **Android**: `android/app/src/main/kotlin/.../MainActivity.kt` — extends `FlutterActivity` with no custom channels
- **iOS**: `ios/Runner/AppDelegate.swift` — extends `FlutterAppDelegate` with no custom channels

When adding features, follow this package structure under `lib/`:
- Group by feature, not by layer (e.g., `lib/bus/`, `lib/schedule/`)
- Use `lib/core/` for shared utilities and models

## Linting

Lint rules are defined via `analysis_options.yaml` (includes `package:flutter_lints/flutter.yaml`). Run `flutter analyze` before committing. Add project-specific rules directly in `analysis_options.yaml` under the `linter: rules:` key.

## Android Build Notes

The Android module (`android/`) uses Gradle with Kotlin DSL. JVM target is 17. Heap is configured to 8GB max in `android/gradle.properties` — do not reduce this. The `android/local.properties` file is developer-local and not tracked in git.
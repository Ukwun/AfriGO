# AfriGo Mobile App

Cross-platform Flutter application for the Pan-African Digital Trade Operating System.

## Tech Stack

- **Framework:** Flutter 3.35.6+
- **Language:** Dart 3.2+
- **State Management:** Riverpod
- **Navigation:** Go Router
- **Backend:** Dio (HTTP client)
- **Local Storage:** Hive
- **Authentication:** Firebase Auth
- **Real-time:** Firebase Realtime Database + Cloud Messaging

## Project Structure

Follows **Clean Architecture** pattern:

```
lib/
├── config/
│   ├── app_router.dart         // Go Router configuration
│   ├── theme.dart              // AfriGo design tokens
│   └── constants.dart          // App constants
├── presentation/               // UI Layer
│   ├── screens/                // Full-page screens
│   ├── widgets/                // Reusable components
│   └── providers/              // Riverpod state providers
├── domain/                     // Business Logic Layer
│   ├── entities/               // Data objects
│   ├── repositories/           // Repository interfaces
│   └── usecases/               // Business use cases
├── data/                       // Data Layer
│   ├── datasources/            // Remote & local data sources
│   ├── models/                 // Data models (JSON-serializable)
│   └── repositories/           // Repository implementations
└── utils/
    ├── firebase/               // Firebase helpers
    ├── formatters/             // String/date formatting
    └── validators/             // Input validation
```

## Getting Started

### Prerequisites
- Flutter 3.35.6+ (`flutter --version`)
- Dart 3.2+ (included with Flutter)
- Android Studio or Xcode for emulators
- A Firebase project (copy credentials to `lib/firebase_options.dart`)

### Installation

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate code:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Run development server:**
   ```bash
   flutter run
   ```

4. **Run on specific device:**
   ```bash
   flutter devices                    # List available devices
   flutter run -d <device-id>        # Run on specific device
   ```

## Development Commands

| Command | Purpose |
|---------|---------|
| `flutter run` | Start dev server (hot reload) |
| `flutter run -d chrome` | Run on web |
| `flutter run -d macos` | Run on macOS |
| `flutter pub get` | Install/update dependencies |
| `flutter pub upgrade` | Upgrade dependencies to latest |
| `flutter pub run build_runner build` | Generate code (freezed, json_serializable) |
| `flutter analyze` | Lint check |
| `flutter format lib/` | Auto-format code |
| `flutter test` | Run unit tests |
| `flutter test --coverage` | Generate coverage report |

## Design System

All UI components use the **AfriGo Design System** defined in `lib/config/theme.dart`:

### Colors
- **Primary Green:** `#0B6E4F` (trust, growth)
- **Accent Green:** `#10B981` (emerald highlights)
- **Navy:** `#0F172A` (enterprise, depth)
- **Error Red:** `#EF4444`

### Typography
- **Headings:** Sora (28-36px, Bold)
- **Body:** Inter (14-16px, Regular)
- **Label:** Inter (12-14px, Semi-bold)

### Animations
See `../design-system/01_ANIMATION_SYSTEM.md` for complete timing curves:
- **Event Entry:** 280ms fade + slide + scale
- **Node Completion:** 220ms scale + 600ms glow
- **Line Growth:** 400ms vertical progression
- **Tap Feedback:** 120-150ms bounce

## Firebase Configuration

Update `lib/firebase_options.dart` with your Firebase project credentials:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_KEY',
  appId: 'YOUR_WEB_APP_ID',
  projectId: 'YOUR_PROJECT_ID',
  // ... other fields
);
```

## Testing

### Unit Tests
```bash
flutter test test/
```

### Widget Tests
```bash
flutter test test/presentation/
```

### Integration Tests (mobile)
```bash
flutter test integration_test/
```

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Debugging

### Enable verbose logging
```bash
flutter run -v
```

### Launch DevTools
```bash
flutter pub global activate devtools
devtools
```

### View app logs
```bash
flutter logs
```

## Troubleshooting

**Problem:** `flutter: Command not found`
```bash
# Add Flutter to PATH (update path for your installation)
export PATH="$PATH:~/flutter/bin"
```

**Problem:** Gradle build failure on Android
```bash
flutter clean
flutter pub get
flutter run
```

**Problem:** Pod issues on iOS
```bash
cd ios
rm -rf Pods Pod.lock
cd ..
flutter pub get
flutter run
```

## Architecture Decisions

### Why Riverpod?
- Compile-time safe (no String keys)
- Built-in caching and invalidation
- Easy testing with Riverpod testing utilities
- Superior to Provider for complex state

### Why Go Router?
- Declarative routing (better than named routes)
- Deep linking support
- Parameter type-safety
- Better than GetX/auto_route

### Why Hive for local storage?
- Fast NoSQL database
- Zero-config (no serialization boilerplate)
- Low memory footprint (important for Android)
- Better for modeling than shared_preferences

### Why Clean Architecture?
- Separation of concerns (testability)
- Domain layer independent of frameworks
- Data layer swappable (switch APIs easily)
- UI layer is as thin as possible

## Team Guidelines

1. **Code Style:** Run `flutter format lib/` before every commit
2. **Linting:** Zero warnings — fix with `flutter analyze`
3. **Testing:** Every feature must have tests (80%+ coverage)
4. **Naming:** Follow Dart conventions (camelCase for everything except classes)
5. **Comments:** Document why, not what. Code should be self-explanatory
6. **Git Commits:** Use conventional commits (`feat:`, `fix:`, `refactor:`, etc.)

## Resources

- [Flutter Docs](https://flutter.dev/docs)
- [Dart Language](https://dart.dev)
- [Riverpod Docs](https://riverpod.dev)
- [Go Router Docs](https://pub.dev/packages/go_router)
- [AfriGo Design System](../design-system/)

## Support

For issues or questions:
1. Check the [troubleshooting section](#troubleshooting)
2. Search existing GitHub issues
3. Ask in team Slack: #afrigo-dev
4. Check architecture docs: `../project-docs/03_API_ARCHITECTURE.md`

---

**Last Updated:** January 2025
**Maintained by:** Mobile Team

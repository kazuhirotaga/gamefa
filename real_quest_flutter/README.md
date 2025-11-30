# Real Quest Flutter App

This is the Flutter implementation of the Real Quest Android application.

## Prerequisites

- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- Supabase Account

## Setup

1.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

2.  **Configure Supabase**:
    Update `lib/main.dart` with your Supabase URL and Anon Key.

3.  **Run the App**:
    ```bash
    flutter run
    ```

## Project Structure

- `lib/main.dart`: Entry point
- `lib/router.dart`: Navigation configuration (GoRouter)
- `lib/theme.dart`: App theme (Light/Dark)
- `lib/screens/`: UI Screens
  - `home_screen.dart`: Dashboard
  - `checkin_screen.dart`: Location & Check-in
  - `battle_screen.dart`: Game logic
  - `collection_screen.dart`: Card inventory
- `lib/models/`: Data models
- `lib/widgets/`: Reusable components

## Features Implemented (Prototype)

- Bottom Navigation
- Home Screen with Status & Quests
- Card Collection Grid
- Mock Battle Screen
- Mock Check-in Screen

## Building for Android

### Debug Run
```bash
flutter run
```

### Build APK (Release)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`


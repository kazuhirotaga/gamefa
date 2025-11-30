---
description: How to build the Flutter app for Android
---

# Android Build Workflow

This workflow describes how to build the Real Quest Flutter application for Android.

## Prerequisites

- Flutter SDK installed and in PATH
- Android Studio installed
- Android SDK Command-line Tools installed
- A connected Android device or running Emulator

## Android Studioでのビルド・実行方法

コマンドラインではなく、Android StudioのGUIを使って開発・ビルドする場合の手順です。

### 1. プロジェクトを開く
1. Android Studioを起動します。
2. **Open** をクリックし、`real_quest_flutter` フォルダを選択して開きます。
3. 初回起動時、画面右下に「Pub get」や「Kotlin migration」などの通知が出た場合は、推奨されるアクションを実行してください。

### 2. アプリの実行 (デバッグ)
1. 画面上部のツールバーにあるデバイス選択ドロップダウンから、実行したいデバイス（Pixel 10など）またはエミュレータを選択します。
2. その横にある緑色の **▶ (Run)** ボタンをクリックします。
3. 下部の **Run** タブにログが表示され、ビルド完了後にアプリが起動します。

### 3. リリースビルド (APK作成)
Android Studio内のターミナルを使用するのが最も確実です。

1. 画面下部の **Terminal** タブをクリックします。
2. 以下のコマンドを入力します：
   ```bash
   flutter build apk --release
   ```
3. 生成されたAPKファイルは `build/app/outputs/flutter-apk/app-release.apk` に保存されます。

---

## Command Line Build (CLI)

To run the app in debug mode on a connected device/emulator via terminal:

1.  Open a terminal in the project directory: `real_quest_flutter`
2.  Run the following command:
    ```bash
    flutter run
    ```
3.  Select the device if prompted.

## Release APK Build

To generate a release APK file for manual installation:

1.  Open a terminal in the project directory: `real_quest_flutter`
2.  Run the build command:
    ```bash
    flutter build apk --release
    ```
3.  The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## App Bundle Build (For Play Store)

To generate an App Bundle (.aab) for Google Play Console:

1.  Open a terminal in the project directory: `real_quest_flutter`
2.  Run the build command:
    ```bash
    flutter build appbundle --release
    ```
3.  The bundle will be generated at: `build/app/outputs/bundle/release/app-release.aab`

## Troubleshooting

- **Gradle Errors**: Run `flutter clean` then `flutter pub get` and try again.
- **SDK Issues**: Open `android/build.gradle` in Android Studio to let it sync and download necessary SDK components.

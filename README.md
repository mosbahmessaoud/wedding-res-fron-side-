# Project Name

A Flutter application for wedding res.

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.0.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (usually comes with Flutter)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)

For iOS development:

- macOS
- [Xcode](https://developer.apple.com/xcode/)
- CocoaPods

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/mosbahmessaoud/wed-res-front.git
   cd YOUR-REPO-NAME
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Set up environment variables** (if applicable)

   Create a `.env` file in the root directory:

   ```env
   API_KEY=your_api_key_here
   BASE_URL=your_base_url_here
   ```

4. **Set up Firebase** (if using Firebase)

   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Download `google-services.json` for Android and place it in `android/app/`
   - Download `GoogleService-Info.plist` for iOS and place it in `ios/Runner/`
   - Run: `flutterfire configure` (if using FlutterFire CLI)

5. **Run the app**
   ```bash
   flutter run
   ```

## Building the App

### Android

```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
flutter build ios --release
```

Open the project in Xcode to archive and distribute.

### Web

```bash
flutter build web --release
```

The web build will be available at: `build/web/`

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── screens/                  # UI screens
├── widgets/                  # Reusable widgets
├── services/                 # API services, database services
├── providers/                # State management (if using Provider)
├── utils/                    # Utility functions and constants
└── config/                   # App configuration
```

## Dependencies

Key packages used in this project:

- [provider](https://pub.dev/packages/provider) - State management
- [http](https://pub.dev/packages/http) - HTTP requests
- [shared_preferences](https://pub.dev/packages/shared_preferences) - Local storage
- [firebase_core](https://pub.dev/packages/firebase_core) - Firebase integration

See [pubspec.yaml](pubspec.yaml) for the full list of dependencies.

## Configuration

### Changing App Name

1. For Android: Update `android/app/src/main/AndroidManifest.xml`
2. For iOS: Update in Xcode project settings

### Changing Package Name

Use the [change_app_package_name](https://pub.dev/packages/change_app_package_name) package:

```bash
flutter pub run change_app_package_name:main com.new.package.name
```

### Changing App Icon

Use the [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) package:

1. Add your icon to `assets/icon/icon.png`
2. Configure in `pubspec.yaml`
3. Run: `flutter pub run flutter_launcher_icons`

## Testing

Run all tests:

```bash
flutter test
```

Run specific test file:

```bash
flutter test test/widget_test.dart
```

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Commit your changes (`git commit -m 'Add some amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

Messaoud Mosbah - [@your_twitter](https://twitter.com/) - mosbah7messaoud@gmail.com

Project Link: [https://github.com/mosbahmessaoud/wed-res-front]

## Acknowledgments

- [Flutter Documentation](https://flutter.dev/docs)
- [Pub.dev](https://pub.dev/)
- Any other resources or inspiration

## Troubleshooting

### Common Issues

**Issue**: Build fails on Android

```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter run
```

**Issue**: iOS build fails

```bash
# Solution: Update CocoaPods
cd ios
pod install --repo-update
cd ..
flutter run
```

**Issue**: Version conflict errors

```bash
# Solution: Update dependencies
flutter pub upgrade
```

## Support

If you encounter any issues or have questions:

- Contact via email : mosbah7messaoud@gmail.com
- Check the [FAQ section](#faq)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes in each version.

---

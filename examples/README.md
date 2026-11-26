# Examples

Apps that use Neba UI the way a consumer does, rather than through the documentation site. None of them is published.

## Flutter (`examples/flutter`)

A sample app for iOS, iPadOS and Android. It depends on `packages/flutter` and on the gallery in `packages/flutter/example` by path, so it shows the same demo files the documentation site shows, and the screens of a real app join them as the widgets they need are ported.

```bash
cd examples/flutter
flutter pub get
flutter run
```

### Tests

The flows in `integration_test/flows.dart` are written once and run in two places.

- **On the host**, with no device: `flutter test`. `test/app_test.dart` runs every flow at a phone's size and at a tablet's. This is what CI runs.
- **On a simulator, an emulator or a real device**: `flutter test integration_test -d <device>`, or with the driver, `flutter drive --driver test_driver/integration_test.dart --target integration_test/app_test.dart -d <device>`. `flutter devices` lists the ids.

A device can run without its window, so a test run does not take over the screen:

```bash
xcrun simctl boot "iPhone 17"
```

```bash
emulator -avd <name> -no-window -no-audio
```

`xcrun simctl boot` starts the simulator without opening the Simulator app, and `flutter devices` finds it either way. Shut it down afterwards with `xcrun simctl shutdown "iPhone 17"`, or `adb emu kill` for the emulator.

A real iPhone or iPad needs a development team to sign the app: set it once in `ios/Runner.xcodeproj` in Xcode, or pass it with `FLUTTER_XCODE_DEVELOPMENT_TEAM`. A real Android device needs USB debugging turned on.

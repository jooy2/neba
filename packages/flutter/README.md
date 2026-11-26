<img src="https://raw.githubusercontent.com/jooy2/neba/main/.github/128x128.png" alt="Neba UI" width="128" height="128" />

# Neba UI for Flutter

[![pub package](https://img.shields.io/pub/v/neba.svg)](https://pub.dev/packages/neba) [![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jooy2/neba/blob/main/LICENSE)

The Flutter package of [Neba UI](https://neba.cdget.com): the same components, the same prop vocabulary and the same translucent acrylic design language as the React package [`neba`](https://www.npmjs.com/package/neba), so a product built with both reads as one.

- **Built on `package:flutter/widgets.dart` alone.** Nothing imports Material or Cupertino, so a Neba widget sits inside a `MaterialApp`, a `CupertinoApp` or a bare `WidgetsApp` without bringing a second design system in behind it.
- **No dependencies** beyond the Flutter SDK.
- **The React tokens, computed rather than copied.** Every colour is the React stylesheet's `oklch()` value, and every derived colour is its `color-mix()`, evaluated in Dart. A test reads the stylesheet and holds the two to the same result.
- **Dark mode with no work.** The colours follow the platform's brightness, and `NebaProvider` pins them either way for a subtree.

## Installation

```yaml
dependencies:
  neba: ^1.21.0
```

Flutter 3.41 or later.

## Usage

A widget needs no setup. Put a `NebaProvider` near the root when you want defaults for a whole subtree, a pinned colour scheme or your own colours:

```dart
import 'package:neba/neba.dart';

NebaProvider(
  defaults: const NebaDefaults(size: NebaSize.lg, density: NebaDensity.compact),
  colorScheme: NebaColorScheme.system,
  child: app,
)
```

A product's own colours are a change to the base tokens, and every derived token follows:

```dart
final NebaTokens light = NebaTokens.light().withFamily(
  NebaColor.primary,
  NebaTokens.light().families[NebaColor.primary]!.copyWith(accent: const Color(0xFF00897B)),
);

NebaProvider(light: light, child: app)
```

### Languages

The few words a widget says on its own behalf, such as the label of a close button, are English unless you register another language. Eighteen come with the package:

```dart
import 'package:neba/locales.dart';

void main() {
  registerNebaMessages('ko', ko);
  runApp(const App());
}
```

A widget then speaks its own `locale`, `NebaProvider`'s default, or the app's locale, in that order.

## Documentation

Every component is documented at **[neba.cdget.com](https://neba.cdget.com)**, with the React and the Flutter API on the same page.

## Contributing

This package is `packages/flutter` in the [Neba repository](https://github.com/jooy2/neba). How to build, test and change it is in [CONTRIBUTING.md](https://github.com/jooy2/neba/blob/main/CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).

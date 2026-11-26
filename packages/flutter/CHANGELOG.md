# Changelog

The changes to `neba` on pub.dev, the Flutter package. The React package keeps its own changelog in [packages/react/CHANGELOG.md](https://github.com/jooy2/neba/blob/main/packages/react/CHANGELOG.md). Each package is released from a tag of its own, and they share version numbers from 1.21.0, the first Flutter release.

## vNext (2026--)

### Added

- **Neba UI for Flutter.** The first release of the Flutter package, at the version number of the React package's next release. It carries the same design language as the React package and is built on `package:flutter/widgets.dart` alone, with no dependencies.

- **The tokens of both themes, computed from the React stylesheet.** `NebaTokens.light()` and `NebaTokens.dark()` hold every neutral and every colour family as the stylesheet writes them, in `oklch()`, and derive the fills, washes, panels, hairlines and rings with the same `color-mix()` arithmetic. `copyWith` and `withFamily` bring a product's own colours, and the derived tokens follow.

- **`NebaProvider`, `NebaTheme` and `NebaDefaults`.** A widget works with no setup and follows the platform's brightness; `NebaProvider` sets defaults for a subtree, pins the colour scheme and the direction, and takes a product's own light and dark tokens. A platform high-contrast setting makes every sheet opaque, as the React package does under `prefers-reduced-transparency`.

- **The shared prop vocabulary and the size ladders.** `NebaSize`, `NebaColor`, `NebaDensity`, `NebaVariant`, `NebaOrientation`, `NebaSide`, `NebaAlign`, `NebaCorner`, `NebaLabelPlacement` and `NebaColorScheme` mean what they mean in the React package, and `NebaScale` holds the control heights, type sizes, icon sizes, padding, gaps and motion it uses. React's density `'default'` is `NebaDensity.standard`, because Dart reserves the word.

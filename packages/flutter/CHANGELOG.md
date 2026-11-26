# Changelog

The changes to `neba` on pub.dev, the Flutter package. The React package keeps its own changelog in [packages/react/CHANGELOG.md](https://github.com/jooy2/neba/blob/main/packages/react/CHANGELOG.md). Each package is released from a tag of its own, and they share version numbers from 1.21.0, the first Flutter release.

## vNext (2026--)

### Added

- **Neba UI for Flutter.** The first release of the Flutter package, at the version number of the React package's next release. It carries the same design language as the React package and is built on `package:flutter/widgets.dart` alone, with no dependencies.

- **The tokens of both themes, computed from the React stylesheet.** `NebaTokens.light()` and `NebaTokens.dark()` hold every neutral and every colour family as the stylesheet writes them, in `oklch()`, and derive the fills, washes, panels, hairlines and rings with the same `color-mix()` arithmetic. `copyWith` and `withFamily` bring a product's own colours, and the derived tokens follow.

- **`NebaProvider`, `NebaTheme` and `NebaDefaults`.** A widget works with no setup and follows the platform's brightness; `NebaProvider` sets defaults for a subtree, pins the colour scheme and the direction, and takes a product's own light and dark tokens. A platform high-contrast setting makes every sheet opaque, as the React package does under `prefers-reduced-transparency`.

- **The shared prop vocabulary and the size ladders.** `NebaSize`, `NebaColor`, `NebaDensity`, `NebaVariant`, `NebaOrientation`, `NebaSide`, `NebaAlign`, `NebaCorner`, `NebaLabelPlacement` and `NebaColorScheme` mean what they mean in the React package, and `NebaScale` holds the control heights, type sizes, icon sizes, padding, gaps and motion it uses. React's density `'default'` is `NebaDensity.standard`, because Dart reserves the word.

- **The words the widgets say on their own behalf, in nineteen languages.** English is built in; the other eighteen are constants in `package:neba/locales.dart` that an app registers with `registerNebaMessages('ko', ko)`, so a language that is never registered is never in the build. A tag is matched by script, then region, then language, and a widget speaks its own `locale`, then `NebaProvider`'s, then the app's. The tables are generated from the React package's, word for word.

- **The chart and code palettes.** `NebaTokens.chart` holds the eight series colours in the order they are handed out, the sequential and diverging ramps, and the ink a label wears on each colour as a `NebaInkTone`, so a product that changes `fg` or `surface` carries the labels along. `chartGrid`, `chartAxis`, `chartBaseline` and `chartGap` are a chart's chrome, and `NebaTokens.code` is a code block's `auto` palette. All of them are the React stylesheet's values, held to it by the same test as the rest.

- **`NebaBox`**, the plainest sheet: `solid`, `outline` and `text`, its corners and padding on the size ladder, a hairline in the colour's family and a sheet that stays undyed, and an elevation from 0 to 3.

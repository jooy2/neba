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

- **`NebaTransition`**, the entrance a widget that displays something plays when it is first built: a fade, a grow, a slide, a zoom, a rotate, a blink or a reveal, with the React package's defaults, a `Duration` for the timing, a `Curve` for the easing, a repeat count and `alternate`. A reader who asked the platform for less motion sees the last frame at once. `NebaBox` takes it as `transition`.

- **`NebaBox`**, the plainest sheet: `solid`, `outline` and `text`, its corners and padding on the size ladder, a hairline in the colour's family and a sheet that stays undyed, and an elevation from 0 to 3.

- **`NebaContainer`**, the gutters around a page's content: padding on `NebaBox`'s steps, a `maxWidth` held to the measure ladder or a width of your own, centred or at the start. `NebaMeasure` is the shared type for that width, the React package's `NebaMeasure` without the CSS lengths.

- **`NebaGridContainer` and `NebaGrid`**, the twelve-column layout: a row that wraps, items that span a number of columns so the gutters line up from row to row, `NebaGridSpan.auto` and `NebaGridSpan.grow` for the widths a column count cannot reach, offsets of whole columns, and the row's `justifyContent`, `alignItems` and `alignContent` with an item's own `alignSelf`. `NebaJustifyContent`, `NebaAlignItems` and `NebaAlignSelf` join the shared types. A per-breakpoint map is the React package's alone.

- **`NebaFlex`**, a row or a column with a gutter on the spacing scale: `direction` and `reverse`, `rowSpacing` and `columnSpacing` over `spacing`, the row's `justifyContent`, `alignItems` and `alignContent`, `wrap` for a row that continues on the next line, and `inline` for one only as wide as its children. Stretched children are as thick as the thickest of them, as in CSS.

- **`NebaStack`**, things laid over each other so a set reads as a pile: `horizontal`, `vertical` or a fanned `diagonal`, an `overlap` and a `drop` that take exactly the room the pile covers, `front`, a `scaleStep` and an `opacityStep` for depth, `max`, `total` and `overflow` for the ones that did not fit, a `ring` in the page's surface colour that the first sheet in each item draws around its own corners, and a `transition` dealt with `stagger`, `durationStep` and `reverse`.

- **`NebaShow`** and **`NebaBreakpoint`**: a child shown from a floor, below a ceiling, or between the two, on the React package's five breakpoints, read off the window's width. A hidden child is not built, and `NebaFlex` and `NebaGridContainer` leave a hidden `NebaShow` out entirely, gap and all, as CSS leaves out `display: none`.

- **`NebaAspectRatio`**, a box that keeps a proportion whatever width it is given: it reserves the space before its content arrives, clips what runs past it, fits an `Image` child with a `BoxFit`, and rounds its corners to the radius ladder when asked.

- **`NebaScrollArea`**, a box with a scrollbar of its own: a rail on the size ladder in the colour's family that shows while the pointer is over the area or while it scrolls, `vertical`, `horizontal` or `both`, a `height` or a `maxHeight`, a `fade` at each edge with more beyond it, a focus stop with the arrows, the page keys, Home and End while it overflows, and a name in the `locale`'s words.

- **`NebaTypography`**, text on the library's type scale: ten levels from `h1` to `overline` with the React package's sizes, leading ratios, tracking and weights, the heading level a screen reader hears and `headingLevel` to change it, a `color` that inherits when it is left out, `weight`, `align`, `lines` with an ellipsis, a `gutter`, a `style` laid over the level, a `transition`, and `NebaTypography.rich` for text in more than one style.

- **`NebaButton`**, a control that runs an action: `solid`, `outline` and `text` in the six colour families on the size ladder, padding by `density`, an `elevation` that goes up a level on hover and down one on a press, the pointer spotlight and the release afterglow, `startIcon` and `endIcon` at 1.2 times the label, `loading` with a turning ring, `readOnly`, `disabled` and `focusableWhenDisabled`, `fullWidth`, and a `semanticLabel` for a button with only an icon. With no `onPressed` it is disabled, as every Flutter button is.

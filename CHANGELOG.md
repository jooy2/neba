# Changelog

## 1.1.0 (2026-07-29)

### Setup

- **`neba/styles.css` now ships compiled.** It carries the design tokens, the real rules for every utility class the components use, and a small reset — so the whole setup is `npm install neba` and one `@import`. Tailwind is no longer a requirement on your side; it builds this package and stays a devDependency of it. About 13 kB gzipped.
- **New export: `neba/tailwind.css`.** The token sheet, for a project that already runs Tailwind v4 — it registers the package as a Tailwind source, so your own build generates the components' utilities in the same pass as your app's and a `className` you pass to a component sorts correctly against the component's own classes. If you were on the previous two-line setup, this is the line to switch to:

  ```css
  @import 'tailwindcss';
  @import 'neba/tailwind.css'; /* was: neba/styles.css */
  ```

- **The bundled reset** is Tailwind's Preflight cut down to what the components actually need — `box-sizing`, font inheritance on form controls, list markers off. It does not touch the typography of your paragraphs, headings or links, and every rule is wrapped in `:where()`, so a single type selector of your own beats it whatever the import order. It is in `neba/styles.css` only; the Tailwind path has Preflight already.
- **`react` and `react-dom` are now declared as `peerDependencies`** (`^18.0.0 || ^19.0.0`) rather than only as devDependencies, so the requirement is stated where a package manager can check it. `@types/react` is an optional peer for TypeScript consumers.

### Added

- Eighteen components: `Blockquote`, `Carousel`, `Container`, `DatePicker`, `DateRangePicker`, `DateTimePicker`, `Grid`, `GridContainer`, `Highlight`, `Icon`, `IconButton`, `Pill`, `SegmentedButton` (with `Segment`), `Shortcut`, `Statistic`, `TimePicker`, `Timeline` (with `TimelineItem`) and `Toolbar`.
- Shared types for the new layout and date work: `NebaPosition`, `NebaBreakpoint`, `NebaResponsive<T>`, `NebaWeekday`, `NebaJustifyContent`, `NebaAlignItems` and `NebaAlignSelf`.
- `Divider` takes a `thickness`, as a number of pixels or any CSS length.
- `Pill` takes `elevation`, `startIcon` / `endIcon`, `title` / `description` / `details`, `expanded` and `position`.
- `llms.txt`, for agents reading the documentation site.

### Changed

- `Select`, `DatePicker` and `DateRangePicker` hold their trigger at the width of the longest thing it could say. Choosing a shorter option no longer shrinks the field out from under the pointer that just used it.
- `Checkbox` and `RadioGroup` drop the white plate highlight. A 1px hairline is light on a cut edge at 32px and a bevel at 18px; the acrylic surface stays, only the highlight goes.
- A highlighted row in a `Select` or `Combobox` popup now takes the accent text colour as well as the soft background.

### Fixed

- `Select` and `Combobox` popups render through a portal, outside the element their `--n-*` slots were declared on, which left every `var()` in them with nothing to resolve to: a `currentColor` hairline instead of the family's, a transparent surface, and a highlighted row that did not light at all. The slots are now set on the popup itself.
- A field at the top or bottom of a scrolling `Dialog` body had its focus ring sliced off by the scroll container. The body without `dividers` now reserves the 4px the ring is drawn in and gives the space straight back, so nothing on the sheet moves.
- `Pagination` keyed its buttons by page number, so recentring the window moved the DOM nodes and the button under the pointer became a different element — its hover bloom faded out while a fresh neighbour's faded in from a centre it had no pointer position for. The row is keyed by slot now.
- `Combobox`'s input stretches to the height of the row it sits on rather than to a fixed `1lh`, which put the placeholder a pixel or two above the chips beside it.

### Documentation

- The sidebar is four sections — Guide, Components, Design and Discover more — with the component groups kept as headings inside Components, and the index page as an entry of its own rather than as the heading's link.
- The design pages moved from `guide/` to `design/`.
- This changelog is published at [/changelog](https://neba.cdget.com/changelog) in both locales.

## 1.0.0 (2026-07-26)

- First release

## 0.0.1 (2025-12-08 / Alpha)

- Alpha release (Not tested. Do not use production.)

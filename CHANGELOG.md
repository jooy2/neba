# Changelog

## 1.3.0 (2026-08-05)

### Added

- **A sixth group, Transitions: eleven `Animate*` wrappers that make anything move.** `AnimateFade`, `AnimateGrow`, `AnimateZoom`, `AnimateSlide`, `AnimateRotate` and `AnimateBlink` are the six named effects; `AnimateAppear`, `AnimateTyping`, `AnimateLighting`, `AnimateMarquee` and `AnimateHeadline` are the five that have to understand what their children are. All eleven take the same settings — `duration` and `delay` in milliseconds, `easing`, `repeat` (a count or `'infinite'`), `alternate`, `paused`, and `trigger`: `mount`, `visible` (with `once` and `threshold`), `hover`, or `manual` driven by `play`. Every one of them is switched off entirely by a `prefers-reduced-motion` preference, so none of them is ever the only thing carrying a message.
- **A `transition` prop on the components that display something** — `Box`, `Card`, `Statistic`, `Alert`, `Chip`, `Avatar`, `Icon`, `Typography` and `Blockquote`. `transition="fade"` is an entrance run once on mount, and the object form takes the details: `{ type: 'slide', from: 'left', duration: 500 }`. It is offered on no component that is pressed, because a control that moves under the pointer aiming at it is the one thing the design language rules out. Anything past a mount — a replay, a scroll trigger, a hover — is an `Animate*` component, and any component can be wrapped in one.
- `ColorPicker` — a colour chosen by eye: a saturation square, a hue rail, an optional opacity rail, a field for typing a value in, and a grid of swatches. `format` decides whether the value comes back as hex, `rgb()` or `hsl()`; `alpha` adds the fourth channel; `swatches` replaces the built-in set with the colours a product actually uses; `inline` draws the panel into the page instead of into a popup. It reads hex in all four lengths, `rgb()`/`rgba()` and `hsl()`/`hsla()` in both syntaxes, and it adds no dependency — the conversions are a hundred lines of arithmetic in `internal/color.ts`.
- The i18n table gains a `color` namespace, so the picker's square, rails, field and swatch grid — none of which have any text on them — are named in all nineteen languages. `locale` picks the language and `labels` overrides any one of them.

### Documentation

- Pages for `ColorPicker` and the eleven `Animate*` components in both locales, their props rows, their demos, cards in the component gallery, a place on the sample screen, and their entries in `llms.txt`.
- **Prop conventions gains a Motion section**, which is where the shared animation vocabulary and the rule about which components take `transition` are written down.

## 1.2.0 (2026-08-01)

### Added

- Eight components, bringing the library to fifty-seven: `Avatar`, `Breadcrumb` (with `BreadcrumbItem`), `ChatBubble`, `OtpField`, `Panes` (with `Pane`), `Spoiler`, `TextLink` and `TreeView` (with `TreeItem`). `Panes` opens a fifth group, **Layout**, alongside `Container` and `Grid`.
- **The library speaks nineteen languages on its own behalf.** Almost nothing in Neba writes text a reader sees — a Button says whatever it was handed — but a few components have to invent a string because there is nowhere else for it to come from: the sentence read out after a link that opens a new tab, the label on the button that uncovers a `Spoiler`, the word under a chat message that says it was read. Those are now one table rather than eight English defaults. `TextLink`, `Spoiler` and `ChatBubble` take a `locale`, and every string still has an override prop of its own, so an unsupported language is never a dead end. A tag resolves by script, then by region, then by language (`zh-Hant-TW` → `zh-hant`, `pt-BR` → `pt`), and a translation that fills in part of the table falls back to English one namespace at a time rather than leaving blanks.
- `Avatar` — an image that falls back to initials, to a glyph, or to a silhouette, so the slot is never an empty box. `shape` is `circle` or `square`, `delay` holds the fallback back long enough for a cached image not to flash it, and `onLoadingStatusChange` reports `idle` / `loading` / `loaded` / `error`.
- `Breadcrumb` — a trail that collapses in the middle when it is too long: `maxItems`, `itemsBeforeCollapse` and `itemsAfterCollapse` decide where, and `expandable` makes the ellipsis a button that opens the rest in place. `separator` takes `chevron`, `arrow`, `slash`, `dot` or a node of your own.
- `ChatBubble` — one message in a conversation. The avatar, the name, the time, the delivery mark, the media and the link card are each drawn only when given something, so the same component is a bare bubble or a full row. `status` runs `sending` → `sent` → `delivered` → `read`, plus `failed`; `typing` draws three dots that change colour rather than bounce.
- `OtpField` — a one-time code as one field per character. `length`, `charset` (`numeric`, `alpha`, `alphanumeric`, `any`), `mask`, and `groupSize` with a `separator` for codes written in blocks. `onComplete` fires when the last box is filled, `autoSubmit` submits the form it is in, and `onValueInvalid` reports what was rejected.
- `Panes` — regions with a draggable bar between each pair, horizontal or vertical. Each `Pane` takes `defaultSize`, `minSize` and `maxSize` as a number of pixels or any CSS length; `resizable` turns the bars off, and `onResize` / `onResizeEnd` report the split.
- `Spoiler` — content covered by a blur rather than removed, so a reader can see that something is there without reading it by accident. Controlled with `revealed` / `defaultRevealed` / `onRevealedChange`; `reversible` allows covering it again, `maxHeight` clamps it to a fade-out instead, and `blur` is the radius.
- `TextLink` — a link with no surface of its own. `underline` is `always`, `hover` or `none`, `newTab` adds the mark and the sentence a screen reader needs, `icon` overrides or drops that mark, and `render` swaps in a router's own link component.
- `TreeView` — a tree with roving focus, controlled `expanded` and `selected`, and `multiple` for checkbox-style selection. `lines` draws the guides as `none`, `simple` or `folder` — the rail runs past an expanded subtree to the next sibling and stops halfway down the last child, the way a file manager draws it, and mirrors under RTL without a second rule.

### Changed

- **The Examples section is four pages, not one.** `/examples/` no longer resolves to a page — the overview moved to [`/examples/overview`](https://neba.cdget.com/examples/overview) and three concept screens joined it. Any link you have to `/examples/` needs updating.
- The stylesheet carries a `.neba-link` rule, written as `.neba-link.neba-link` so that a host's `.prose a` or `.vp-doc a` cannot outrank the link's underline thickness, offset and colour. Like `neba-portal`, the class is a hook you can exempt from your own typography rules.

### Fixed

- The date formatter cache joined a locale and its options with a space, which is a character both halves of the key can contain. Two different requests could land on one entry and the second would be formatted with the first's options. The separator is now one that cannot appear in either.

### Documentation

- **Three concept screens**, each a whole fictional product page built only out of the library: a [landing page](https://neba.cdget.com/examples/concept-landing), an [admin dashboard](https://neba.cdget.com/examples/concept-dashboard) and a [sign-up flow](https://neba.cdget.com/examples/concept-signup).
- The home page now says what the library is rather than how it is drawn — what ships, what is tested, and what an install actually gets you.
- **Every page carries its own description.** A page's lede is read out of the source and becomes its `<meta name="description">`, so pages no longer share one sentence between them. Canonical URLs, an `hreflang` pair per locale with an `x-default`, Open Graph and Twitter cards, JSON-LD on the home page, and a `robots.txt` naming the sitemap are generated in the build.
- **A preview mounts when it is scrolled into view**, not when the page loads. A component page holds a dozen of them, and mounting all at once put the one being read behind chunks for previews far below the fold. The empty box reserves its height before and after, so nothing jumps.
- New icons and social image at 128 and 256 px, an `apple-touch-icon`, and a `theme-color`.
- Pages for the eight new components in both locales, their props rows, their demos, and their entries in `llms.txt`.

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

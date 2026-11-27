---
title: TextLink
order: 16
flutter: true
---

# TextLink

<p class="neba-lede">A link, in a sentence or on its own. It has no surface and no height of its own: what it has is the line under it, and a mark for the links that open in a new tab.</p>

<Demo src="text-link/hero" />

::: fw react

```tsx
import { TextLink } from 'neba';

<TextLink href="/components/">Components</TextLink>
<TextLink href="https://neba.cdget.com/components/" newTab>All components</TextLink>
<TextLink href="/guide/getting-started" underline="hover" color="primary">Getting started</TextLink>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaTextLink(onPressed: openComponents, child: const Text('Components'));
NebaTextLink(onPressed: openSite, newTab: true, child: const Text('All components'));
NebaTextLink(
  onPressed: openGuide,
  underline: NebaTextLinkUnderline.hover,
  color: NebaColor.primary,
  child: const Text('Getting started'),
);
```

:::

## Props

<PropsTable name="TextLink" />

::: fw react

Every other `<a>` attribute passes through. `rel` is the one exception: it is merged rather than replaced. See `newTab` below.

:::

::: fw flutter

The package opens nothing itself, so a link is a callback: `onPressed` calls the router or a URL launcher. `href` is where the link goes, for a screen reader and, on the web, the browser; it opens nothing either. With no `onPressed` the link is drawn but does nothing and takes no focus. Enter follows a link and Space does not, as in a browser.

Inside a sentence a link is a `WidgetSpan` of a `Text.rich`, set on the baseline: `WidgetSpan(alignment: PlaceholderAlignment.baseline, baseline: TextBaseline.alphabetic, child: NebaTextLink(…))`. A link set that way wraps inside its own box rather than across the sentence's lines, so keep one in running text short.

:::

`color` and `size` are the two shared axes with no default: a link inside a paragraph is the colour and the size of that paragraph. The rest of the vocabulary is in [prop conventions](../../design/prop-conventions).

::: fw react

A Tailwind utility in `className` wins over the link's own colour, its weight and its line: whether the line is drawn, its thickness, its offset and its colour. That holds with or without a variant. A class from your own stylesheet needs two classes or `!important`.

The root carries the class `neba-link`. It is the hook a stylesheet that styles `a` by name (`.prose a`, and most CSS frameworks) can exempt: `.prose a:not(.neba-link) { … }`.

:::

## Examples

### underline

`always` is the default, `hover` draws the line only under the pointer, and `none` draws none at all. Hovering changes the line, never the text colour. Reach for `none` where something else is already saying "this is a link": a nav bar, a footer, a row of them under a heading.

<Demo src="text-link/underline">

::: fw react

<<< @/.vitepress/demos/text-link/underline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/underline.dart

:::

</Demo>

### color

With no `color` the link takes whatever colour the text around it has. Passing one of the six role colours dyes the label and the line together.

<Demo src="text-link/colors">

::: fw react

<<< @/.vitepress/demos/text-link/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/colors.dart

:::

</Demo>

### size

Also unset by default, and not filled in by a `NebaProvider`: a link in a sentence is the size of the sentence. Set `size` for one standing on its own, and it takes the library's type scale with the leading a wrapping line needs.

<Demo src="text-link/sizes">

::: fw react

<<< @/.vitepress/demos/text-link/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/sizes.dart

:::

</Demo>

### newTab and icon

::: fw react

`newTab` sets `target="_blank"` and the `rel` that stops the new page reaching back through `window.opener`. It also turns `icon` on.

A `rel` of your own is merged with that rather than replacing it, so `newTab rel="nofollow"` comes out as `nofollow noopener noreferrer`. On a link that stays in the tab, your `rel` is left exactly as written. A `target` you write yourself gets the same `rel` and the same spoken sentence as `newTab`, but not the glyph: pass `icon` to draw it.

`icon` overrides that either way: `false` for a new-tab link with no mark, `true` for a same-tab link that wants one, or a node of your own to replace the glyph.

:::

::: fw flutter

`newTab` says the link leaves the app: it draws the external mark and adds "(opens in a new tab)" to what a screen reader hears. Opening the tab is `onPressed`'s, through whatever launcher the app uses.

`showIcon` overrides the glyph either way: `false` for a new-tab link with no mark, `true` for a same-tab link that wants one. `icon` replaces the glyph and turns it on.

:::

<Demo src="text-link/external">

::: fw react

<<< @/.vitepress/demos/text-link/external.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/external.dart

:::

</Demo>

### locale

`newTab` adds a line that is read out and never drawn: "(opens in a new tab)". `locale` is which language it is written in: <Fw react="a BCP 47 tag such as `ko`, `pt-BR` or `zh-Hant`" flutter="a `Locale`, by default `NebaProvider`'s and then the app's" />. A language with no translation falls back to English.

::: fw react

```tsx
<TextLink href="https://neba.cdget.com/components/" newTab locale="ko">
  모든 컴포넌트
</TextLink>
```

:::

::: fw flutter

```dart
NebaTextLink(
  onPressed: openSite,
  newTab: true,
  locale: const Locale('ko'),
  child: const Text('모든 컴포넌트'),
);
```

:::

### render

::: fw react

`render` swaps the element without changing anything else: the `Link` a router brings, most of the time. The TextLink hands its `href` to that element, and a `Link` whose type insists on an `href` of its own is given the same value, as below.

```tsx
import Link from 'next/link';

<TextLink href="/components/" render={<Link href="/components/" />}>
  Components
</TextLink>;
```

:::

::: fw flutter

A Flutter link has no element to swap. A router's navigation goes in `onPressed`.

:::

## Accessibility

- A link that opens a new tab carries the notice in its <Fw react="accessible name" flutter="semantics label" />. Set `locale` so it is read out in the page's own language.
- `underline="none"` leaves colour as the only thing marking the link, and colour alone is not enough for every reader. Use it where the surrounding layout already says what the element is.
- The focus ring is drawn even with no `color`: it falls back to the primary ring rather than disappearing.
- An `href` whose scheme is not `http`, `https`, `mailto` or `tel` is not written, so a `javascript:` address from user content <Fw react="cannot run" flutter="is not handed to a screen reader or the browser" />. A relative address, a `#fragment` and a `//host` are kept. Every component that takes an `href` follows the same rule.

---
title: Footer
order: 3
flutter: true
---

# Footer

<p class="neba-lede">The sheet at the end of a page. It renders a real <code>&lt;footer&gt;</code> (the contentinfo landmark), and decides the surface, the gutter and whether the bar stays in reach; everything in it is yours.</p>

<Demo src="footer/hero" minHeight="180" />

::: fw react

```tsx
import { Footer } from 'neba';

<Footer>© 2026 Neba</Footer>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaFooter(child: Text('© 2026 Neba'));
```

:::

## Props

<PropsTable name="Footer" />

::: fw react

Every native `<footer>` attribute passes through, apart from `color` and `title`. The shared axes are described under [prop conventions](../../design/prop-conventions).

It has no slots, so its children are laid out as you write them.

:::

::: fw flutter

`maxWidth` takes a `NebaMeasure`, a step of the ladder or a width of your own, and no per-breakpoint map. The shared axes are described under [prop conventions](../../design/prop-conventions).

It has no slots, so its child is laid out as you write it, across the footer's width. `safeArea` keeps it clear of the home indicator and a notch, with the sheet running under them. A footer at the end of a page is against the bottom of the screen once the page is scrolled to its end, so this holds for a `static` one too.

:::

## Examples

### position

::: fw react

`static` is the default, so the footer sits at the end of the document and is reached by scrolling to it. `sticky` holds it against the bottom of the window, and `fixed` takes it out of the flow. Inside a [PageLayout](./page-layout) a `fixed` footer's height is reserved, so it does not sit on top of the last paragraph.

:::

::: fw flutter

Flutter has no `position`, so it is the [PageLayout](./page-layout) the footer is handed to that reads it. `static`, the default, puts the footer at the end of the page, reached by scrolling to it. `sticky` and `fixed` both hold it against the bottom of the screen, in reach, with the content passing under its sheet and its height reserved, so it does not sit on top of the last paragraph. Outside a layout it changes nothing.

:::

### variant

The three weights say what they say everywhere. The sheet is never dyed by `color`.

<Demo src="footer/variant" minHeight="220">

::: fw react

<<< @/.vitepress/demos/footer/variant.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/footer/variant.dart

:::

</Demo>

### maxWidth

Holds the content to a measure and centres it while the sheet still spans the window. The same ladder [Container](./container) uses, <Fw react="and the same lengths of your own and per-breakpoint maps" flutter="or a width of your own" />.

<Demo src="footer/measure">

::: fw react

<<< @/.vitepress/demos/footer/measure.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/footer/measure.dart

:::

</Demo>

### divider · padded

`divider` draws a hairline along the top edge and is on by default. <Fw react="`padded={false}`" flutter="`padded: false`" /> drops the gutter for a footer that brings its own.

## Accessibility

::: fw react

- It renders `<footer>`, which is the `contentinfo` landmark unless it is inside an `<article>`, `<aside>`, `<main>`, `<nav>` or `<section>`.
- `label` names the `contentinfo` landmark in a landmark list. Inside one of those elements the footer is not a landmark, so a `label` there has nothing to name.
- Group the link columns in a `<nav>` of your own when they are navigation rather than fine print.

:::

::: fw flutter

- The footer a [PageLayout](./page-layout) was handed is the `contentInfo` region a screen reader offers as the site's information. A footer anywhere else is a group read in order and no landmark, the rule that makes only a top-level `<footer>` one.
- `label` names that region. On a footer that is no landmark it has nothing to name.
- Group the link columns in a `Semantics` of your own with `role: SemanticsRole.navigation` when they are navigation rather than fine print.

:::

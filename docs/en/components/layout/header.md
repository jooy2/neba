---
title: Header
order: 2
flutter: true
---

# Header

<p class="neba-lede">The bar across the top of a page, divided into a leading slot, a middle and a trailing one. It renders a real <code>&lt;header&gt;</code>, which at the top level of a document is the banner landmark.</p>

<Demo src="header/hero" />

::: fw react

```tsx
import { AppLogo, Button, Header } from 'neba';

<Header brand={<AppLogo name="Neba" showName />} actions={<Button size="sm">Sign in</Button>}>
  <nav>…</nav>
</Header>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaHeader(
  brand: const <Widget>[Text('Neba')],
  actions: <Widget>[
    NebaButton(onPressed: signIn, size: NebaSize.sm, child: const Text('Sign in')),
  ],
  children: navigation,
);
```

:::

## Props

<PropsTable name="Header" />

::: fw react

Every native `<header>` attribute passes through, apart from `color` and `title`, which the component uses for its own. The shared axes are described under [prop conventions](../../design/prop-conventions).

It works on its own. Inside a [PageLayout](./page-layout) it also registers itself, so a [Sidebar](./sidebar) that holds its place knows how far down the window to start.

:::

::: fw flutter

The three slots are lists, each laid out as a row of its own, so a logo and a name or a pair of buttons need no wrapper. A [Show](./show) the window's width hides and a [SidebarTrigger](./sidebar#sidebartrigger) with no drawer to open are left out of their slot, gap and all, as `display: none` leaves an element out of a flex row. `maxWidth` takes a `NebaMeasure`, a step of the ladder or a width of your own, and no per-breakpoint map. The shared axes are described under [prop conventions](../../design/prop-conventions).

It works on its own, as a bar like any other box. As the `header` of a [PageLayout](./page-layout) it is the bar the layout holds at the top while the page scrolls, and a [Sidebar](./sidebar) that holds its place starts under it. `safeArea`, which the React package does not have, keeps what is on the bar clear of the status bar and a notch, with the sheet running under them; the layout's Safe areas section says how the insets are shared out.

:::

## Examples

### brand · children · actions

The three slots. `brand` is the leading one: the logo, the product's name; `children` is the middle, usually the navigation; `actions` is the trailing one, laid out end-aligned so a row of buttons needs no wrapper of its own. A slot given nothing <Fw react="renders" flutter="builds" /> nothing.

### align

Where the middle slot sits. `start` (the default) packs it against the brand. `center` puts it on the bar's own midline rather than in the space left over, and gives the brand and the actions equal shares of the rest. `end` packs it against the actions.

<Demo src="header/align" minHeight="180">

::: fw react

<<< @/.vitepress/demos/header/align.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/header/align.dart

:::

</Demo>

### position

::: fw react

`sticky`, the default, holds the bar against the top of the window while leaving it in the flow, so nothing has to be padded out of its way. `fixed` takes it out of the flow, and a [PageLayout](./page-layout) reserves its height. `static` lets it scroll away.

:::

::: fw flutter

Flutter has no `position`, so it is the [PageLayout](./page-layout) the bar is handed to that reads it. `sticky`, the default, and `fixed` both hold the bar at the top while the page scrolls, with the content passing under its sheet and its room kept; `static` lets it scroll away. Outside a layout it changes nothing.

:::

### variant

The three weights say what they say everywhere: filled, hairline, none. `color` never dyes the bar and shows up in the hairline <Fw react="and the focus rings " flutter="" />instead.

<Demo src="header/variant" minHeight="220">

::: fw react

<<< @/.vitepress/demos/header/variant.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/header/variant.dart

:::

</Demo>

### maxWidth

Holds the row of slots to a measure and centres it while the sheet still spans the window. The same ladder [Container](./container) uses<Fw react=" (and the same lengths of your own, and the same per-breakpoint maps)" flutter=", or a width of your own" />, so a header and the Container under it line up on the same edge at every width.

<Demo src="header/measure">

::: fw react

<<< @/.vitepress/demos/header/measure.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/header/measure.dart

:::

</Demo>

### divider

`divider` draws a hairline along the bottom edge and is on by default.

## Accessibility

::: fw react

- It renders `<header>`, which is the `banner` landmark unless it is inside an `<article>`, `<aside>`, `<main>`, `<nav>` or `<section>`.
- `label` names the banner in a landmark list. Inside one of those elements the header is not a landmark, so a `label` there has nothing to name.
- The navigation in the middle slot should be a `<nav>` of your own, with its own accessible name when a page has more than one.

:::

::: fw flutter

- Flutter's semantics has no banner role. The header is a group a screen reader reads in order, and the `header` of a [PageLayout](./page-layout) with a `label` is a region by that name.
- `label` names nothing on a header anywhere else, as a header inside `<main>` is no landmark.
- Give the navigation in the middle slot a `Semantics` of its own, with `role: SemanticsRole.navigation` and a `label` when a screen has more than one.

:::

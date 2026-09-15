---
title: Header
order: 2
---

# Header

<p class="neba-lede">The bar across the top of a page, divided into a leading slot, a middle and a trailing one. It renders a real <code>&lt;header&gt;</code>, which at the top level of a document is the banner landmark.</p>

<Demo src="header/hero" />

```tsx
import { AppLogo, Button, Header } from 'neba';

<Header brand={<AppLogo name="Neba" showName />} actions={<Button size="sm">Sign in</Button>}>
  <nav>…</nav>
</Header>;
```

## Props

<PropsTable name="Header" />

Every native `<header>` attribute passes through, apart from `color` and `title`, which the component uses for its own. The shared axes are described under [prop conventions](../../design/prop-conventions).

It works on its own. Inside a [PageLayout](./page-layout) it also registers itself, so a [Sidebar](./sidebar) that holds its place knows how far down the window to start.

## Examples

### brand · children · actions

The three slots. `brand` is the leading one: the logo, the product's name; `children` is the middle, usually the navigation; `actions` is the trailing one, laid out end-aligned so a row of buttons needs no wrapper of its own. A slot given nothing renders nothing.

### align

Where the middle slot sits. `start` (the default) packs it against the brand. `center` puts it on the bar's own midline rather than in the space left over, and gives the brand and the actions equal shares of the rest. `end` packs it against the actions.

<Demo src="header/align" minHeight="180">

<<< @/.vitepress/demos/header/align.tsx

</Demo>

### position

`sticky`, the default, holds the bar against the top of the window while leaving it in the flow, so nothing has to be padded out of its way. `fixed` takes it out of the flow, and a [PageLayout](./page-layout) reserves its height. `static` lets it scroll away.

### variant

The three weights say what they say everywhere: filled, hairline, none. `color` never dyes the bar and shows up in the hairline and the focus rings instead.

<Demo src="header/variant" minHeight="220">

<<< @/.vitepress/demos/header/variant.tsx

</Demo>

### maxWidth

Holds the row of slots to a measure and centres it while the sheet still spans the window. The same ladder [Container](./container) uses (and the same lengths of your own, and the same per-breakpoint maps), so a header and the Container under it line up on the same edge at every width.

<Demo src="header/measure">

<<< @/.vitepress/demos/header/measure.tsx

</Demo>

### divider

`divider` draws a hairline along the bottom edge and is on by default.

## Accessibility

- It renders `<header>`, which is the `banner` landmark unless it is inside an `<article>`, `<aside>`, `<main>`, `<nav>` or `<section>`.
- `label` names the banner in a landmark list. Inside one of those elements the header is not a landmark, so a `label` there has nothing to name.
- The navigation in the middle slot should be a `<nav>` of your own, with its own accessible name when a page has more than one.

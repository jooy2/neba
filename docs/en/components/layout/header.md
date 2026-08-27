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

The three slots. `brand` is the leading one — the logo, the product's name; `children` is the middle, usually the navigation; `actions` is the trailing one, laid out end-aligned so a row of buttons needs no wrapper of its own. A slot given nothing renders nothing.

### align

Where the middle slot sits. `start` — the default — packs it against the brand. `center` puts it on the bar's own midline rather than in the space left over, which is why the two ends are given equal shares. `end` packs it against the actions.

<Demo src="header/align" minHeight="180">

<<< @/.vitepress/demos/header/align.tsx

</Demo>

### position

`sticky`, the default, holds the bar against the top of the window while leaving it in the flow, so nothing has to be padded out of its way. `fixed` takes it out of the flow, and a [PageLayout](./page-layout) reserves its height. `static` lets it scroll away.

### variant

The three weights say what they say everywhere: filled, hairline, none. The bar is never dyed by `color` — what is on it arrives with colours of its own — so the family shows up in the hairline and the focus rings.

<Demo src="header/variant" minHeight="220">

<<< @/.vitepress/demos/header/variant.tsx

</Demo>

### maxWidth

Holds the row of slots to a measure and centres it while the sheet still spans the window. On the same ladder [Container](./container) uses, so a header and the Container under it line up on the same edge.

<Demo src="header/measure">

<<< @/.vitepress/demos/header/measure.tsx

</Demo>

### divider

A hairline along the bottom edge, on by default. A bar pinned over a scrolling page has content passing underneath it at every moment, and a translucent sheet with nothing marking its edge reads as part of that.

## Accessibility

- It renders `<header>`, which is the `banner` landmark when it is not inside an `<article>` or a `<section>`.
- Give it a `label` when a page has more than one `<header>` in it — an article's own and the site's — or a landmark list names neither.
- The navigation in the middle slot should be a `<nav>` of your own, with its own accessible name when a page has more than one.

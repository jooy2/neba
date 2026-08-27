---
title: Footer
order: 3
---

# Footer

<p class="neba-lede">The sheet at the end of a page. It renders a real <code>&lt;footer&gt;</code> — the contentinfo landmark — and decides the surface, the gutter and whether the bar stays in reach; everything in it is yours.</p>

<Demo src="footer/hero" minHeight="180" />

```tsx
import { Footer } from 'neba';

<Footer>© 2026 Neba</Footer>;
```

## Props

<PropsTable name="Footer" />

Every native `<footer>` attribute passes through, apart from `color` and `title`. The shared axes are described under [prop conventions](../../design/prop-conventions).

It has no slots, which is the difference between it and [Header](./header): a footer's content is four columns on one site and one line on the next, and a fixed arrangement would be one every second site fights.

## Examples

### position

`static` is the default and is the opposite of Header's: a footer is the thing at the end of the document, reached by scrolling to it. `sticky` holds it against the bottom of the window, and `fixed` takes it out of the flow — inside a [PageLayout](./page-layout) its height is then reserved rather than sitting on top of the last paragraph.

### variant

The three weights say what they say everywhere. The sheet is never dyed by `color`.

<Demo src="footer/variant" minHeight="220">

<<< @/.vitepress/demos/footer/variant.tsx

</Demo>

### maxWidth

Holds the content to a measure and centres it while the sheet still spans the window, on the same ladder [Container](./container) uses.

<Demo src="footer/measure">

<<< @/.vitepress/demos/footer/measure.tsx

</Demo>

### divider · padded

`divider` draws a hairline along the top edge and is on by default: a footer is the one sheet with content directly above it and nothing below, so the line is the whole of what says the document ended. `padded={false}` drops the gutter for a footer that brings its own.

## Accessibility

- It renders `<footer>`, which is the `contentinfo` landmark when it is not inside an `<article>` or a `<section>`.
- Give it a `label` when a page has more than one `<footer>` in it.
- Group the link columns in a `<nav>` of your own when they are navigation rather than fine print.

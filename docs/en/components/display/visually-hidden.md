---
title: VisuallyHidden
order: 22
---

# VisuallyHidden

<p class="neba-lede">Content that is in the accessibility tree and not on the screen. For the words a control needs a name from when the thing a sighted reader sees is a glyph, a number or a colour.</p>

<Demo src="visually-hidden/hero" />

```tsx
import { VisuallyHidden } from 'neba';

<button type="button">
  <span aria-hidden="true">×</span>
  <VisuallyHidden>Remove</VisuallyHidden>
</button>;
```

## Props

<PropsTable name="VisuallyHidden" />

Native `<span>` attributes pass through, and `render` swaps the element. While hidden, the content sits in a 1px clipped box, so it stays in the accessibility tree and takes no room on the page.

## Examples

### visible

Takes the hiding off, so the content is drawn like anything else. A skip link sets `visible` from its own focus state, as the example below does, so it appears only while it has the focus. A `focus-visible:` class cannot take the element out of the 1px box, so it cannot do the same.

<Demo src="visually-hidden/skip-link">

<<< @/.vitepress/demos/visually-hidden/skip-link.tsx

</Demo>

### render

Renders something other than a `<span>`: a `<div>` for block content, an `<a>` for a skip link, a `<caption>` for a table that is described but not titled.

```tsx
<VisuallyHidden render={<caption />}>Revenue by quarter, in millions</VisuallyHidden>
```

## Accessibility

- The content is a normal part of the accessibility tree: it contributes to an accessible name, it is read in document order, and it can be the target of `aria-describedby`.
- Put it **inside** the control it names rather than beside it. A `<button>` takes its name from its own contents.
- Mark the glyph a sighted reader sees with `aria-hidden="true"`, as the `×` in the snippet at the top is, so it is not read out beside the hidden words.
- Do not put an interactive element in one unless `visible` can become true: a focusable control the reader cannot see is a focus that appears to go nowhere.

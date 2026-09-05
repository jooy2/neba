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

Native `<span>` attributes pass through, and `render` swaps the element.

### Why not `display: none`

There is one form of this that works, and the near misses all fail in a way nobody notices until somebody reports it.

|  | What goes wrong |
| --- | --- |
| `hidden`, `display: none` | Takes the text off the accessibility tree along with the screen: the opposite of the job |
| `opacity: 0`, `visibility: hidden` | Leaves a clickable ghost the size of the words, and a pointer finds it |
| `text-indent: -9999px` | Makes a box that wide, and a horizontal scrollbar with it |
| `font-size: 0` | Announced by some screen readers as nothing at all |

A 1px box with its contents clipped is invisible to a sighted reader and present to every other kind, which is what this renders.

This component is the other half of a pair. `aria-hidden="true"` is **visible and not announced** (the glyph in the example above), and it stays an attribute rather than becoming a component, because it belongs on the element that is already being drawn.

## Examples

### visible

Takes the hiding off, so the content is drawn like anything else. This is what a skip link needs: hidden until it has the focus, then a real control the reader can see themselves press.

`focus-visible:` cannot express that on its own, because the element has to leave the 1px box entirely, so the class that undoes it goes on the component.

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
- Do not put an interactive element in one unless `visible` can become true: a focusable control the reader cannot see is a focus that appears to go nowhere.

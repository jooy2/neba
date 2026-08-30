---
title: Anchor
order: 21
---

# Anchor

<p class="neba-lede">The list of headings on the page being read, with the one the reader is in marked. Real fragment links, so they jump to their headings whether or not the tracking is running.</p>

<Demo src="anchor/hero" />

```tsx
import { Anchor } from 'neba';

<Anchor
  items={[
    { href: '#install', label: 'Install' },
    { href: '#setup', label: 'Setup', depth: 1 }
  ]}
/>;
```

## Props

<PropsTable name="Anchor" />

Every native `<nav>` attribute passes through, apart from `color` and `children`.

### AnchorItem

<PropsTable name="AnchorItem" />

The headings are given rather than scraped out of the document. Anything that produces this list — an MDX pipeline, a CMS, a route's frontmatter — already knows the ids, and a component that went looking for them would be guessing at which headings were content and which were chrome.

## Examples

### activeHref and onActiveChange

Left alone, the list tracks the scroll: the marked row is the last heading whose top has passed the line, which reads correctly going up as well as down, and the last heading is marked once the scroll reaches the bottom. Pass `activeHref` and it stops tracking and says what it is told.

Nothing is marked while the reader is still above the first heading.

### offset

How far below the top of the scrollport a heading counts as reached. Set it to the height of a sticky header, or the heading under the bar is never the one marked.

### container

What scrolls, when it is not the document — the element a [PageLayout](../layout/page-layout) with `scroll="content"` puts the page inside, for instance.

### rail

The line down the leading edge, with the active row lit. It is a border on the row rather than a marker that travels, because nothing in the library slides under a reader who is already moving.

<Demo src="anchor/rail">

<<< @/.vitepress/demos/anchor/rail.tsx

</Demo>

### size

<Demo src="anchor/sizes">

<<< @/.vitepress/demos/anchor/sizes.tsx

</Demo>

## Accessibility

- Renders a real `<nav>` of real `<a href="#…">`s. They work with JavaScript off and they are in the link list a screen reader can pull up; the tracking is added on top rather than being load-bearing.
- The marked row carries `aria-current="location"`, which is the value for where the reader is within a set of links.
- The `<nav>` is named from `locale`, or from `label`.
- A heading with no `id` cannot be tracked, and its row is a link to nothing.

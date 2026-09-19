---
title: Sources
order: 6
---

# Sources

<p class="neba-lede">The list of things an answer was built out of. Numbered rows, each a link with the passage that matched under it, folded behind a heading that says how many there were.</p>

<Demo src="sources/hero" />

```tsx
import { Sources } from 'neba';

<Sources
  items={[
    { title: 'The design language', site: 'neba.cdget.com', href: '/design/design-language' },
    { title: 'Breakpoints', site: 'neba.cdget.com', href: '/design/breakpoints' }
  ]}
/>;
```

## Props

<PropsTable name="Sources" />

Native `<div>` attributes pass through to the root. `color`, `title` and `onChange` are excluded, since the table above spells them differently.

A [List](../display/list) would draw the rows. What it cannot do is the part that makes this a component: the rows are _numbered_, and the numbers are what an [InlineCitation](./inline-citation) in the body points at.

### SourceItem

<PropsTable name="SourceItem" />

## Examples

### collapsible

On. A list of sources is the longest thing in an answer and the least often read, and what a reader usually wants from it is to know how many there were — which is why the count sits on the header whether it is open or not.

Off, the heading is a plain line and the list is open. There is no disclosure at all in that state, so nothing is pressable.

<Demo src="sources/folding">

<<< @/.vitepress/demos/sources/folding.tsx

</Demo>

### Numbering

Rows are numbered from one, in the order they were given. A source's own `index` overrides that, which is what a list showing only the sources actually cited — out of a longer set — needs.

`numbered={false}` drops the marks. Reach for it when nothing in the body cites anything, since a number with nothing pointing at it is a number a reader looks for a meaning in.

### Links

A row with an `href` is a real [TextLink](../display/text-link), so its underline and its focus ring are the ones every other link in the library draws. A row without one is plain text: a passage from a file the reader cannot open is still a source.

Any `href` whose scheme is not `http`, `https`, `mailto` or `tel` leaves the row unlinked rather than being written out, and a `target` that leaves the tab gains `rel="noopener noreferrer"`.

### variant

`text` is the default, unlike most of the library: a list under an answer is a heading and some links, and a sheet around it is one more box in a column that already has several.

<Demo src="sources/variant">

<<< @/.vitepress/demos/sources/variant.tsx

</Demo>

## Accessibility

- An `<ol>` with `role="list"` spelled out, so Safari keeps the list semantics after Tailwind's reset takes the markers off.
- The number beside a row is `aria-hidden`: it is a pointer for the eye, and the row is already in a numbered list.
- The heading is a real button when the list folds, wired to the panel by Base UI.

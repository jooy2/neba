---
title: TextLink
order: 16
---

# TextLink

<p class="neba-lede">A link, in a sentence or on its own. It has no surface and no height of its own — what it has is the line under it, and a mark for the links that take over the window.</p>

<Demo src="text-link/hero" />

```tsx
import { TextLink } from 'neba';

<TextLink href="/components/">Components</TextLink>
<TextLink href="https://neba.cdget.com/components/" newTab>All components</TextLink>
<TextLink href="/guide/getting-started" underline="hover" color="primary">Getting started</TextLink>;
```

## Props

<PropsTable name="TextLink" />

Every other `<a>` attribute passes through, `target` and `rel` included — `newTab` only sets them when they are not already there.

`color` and `size` are the two shared axes with no default: a link inside a paragraph is the colour and the size of that paragraph. The rest of the vocabulary is in [prop conventions](../../design/prop-conventions).

The root carries the class `neba-link`. It is the hook a stylesheet that styles `a` by name — `.prose a`, and most CSS frameworks — can exempt: `.prose a:not(.neba-link) { … }`.

## Examples

### underline

`always` is the default, `hover` draws the line only under the pointer, and `none` draws none at all. Reach for `none` where something else is already saying "this is a link" — a nav bar, a footer, a row of them under a heading.

<Demo src="text-link/underline">

<<< @/.vitepress/demos/text-link/underline.tsx

</Demo>

Hovering changes the line, never the text colour. A word that changes colour under the pointer moves the reader's eye off the line they were reading.

### color

With no `color` the link takes whatever colour the text around it has. Passing one of the six role colours dyes the label and the line together.

<Demo src="text-link/colors">

<<< @/.vitepress/demos/text-link/colors.tsx

</Demo>

### size

Also unset by default — a link in a sentence is the size of the sentence. Set `size` for one standing on its own, and it takes the library's type scale with the leading a wrapping line needs.

<Demo src="text-link/sizes">

<<< @/.vitepress/demos/text-link/sizes.tsx

</Demo>

### newTab and icon

`newTab` sets `target="_blank"` and the `rel` that stops the new page reaching back through `window.opener`. It also turns `icon` on, because a window changing under the reader is the one thing about a link that cannot be seen until it has happened.

`icon` overrides that either way: `false` for a new-tab link with no mark, `true` for a same-tab link that wants one, or a node of your own to replace the glyph.

<Demo src="text-link/external">

<<< @/.vitepress/demos/text-link/external.tsx

</Demo>

### locale

`newTab` adds a line that is read out and never drawn — "(opens in a new tab)". `locale` is which language it is written in: a BCP 47 tag such as `ko`, `pt-BR` or `zh-Hant`. Tags with no translation fall back to English.

```tsx
<TextLink href="https://neba.cdget.com/components/" newTab locale="ko">
  모든 컴포넌트
</TextLink>
```

### render

`render` swaps the element without changing anything else — the `Link` a router brings, most of the time. `href` still goes on the TextLink, so it is written once.

```tsx
import Link from 'next/link';

<TextLink href="/components/" render={<Link href="/components/" />}>
  Components
</TextLink>;
```

## Accessibility

- A link that opens a new tab carries the notice in its accessible name. Set `locale` so it is read out in the page's own language.
- `underline="none"` leaves colour as the only thing marking the link, and colour alone is not enough for every reader. Use it where the surrounding layout already says what the element is.
- The focus ring is drawn even with no `color` — it falls back to the primary ring rather than disappearing.

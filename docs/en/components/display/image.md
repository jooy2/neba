---
title: Image
order: 23
---

# Image

<p class="neba-lede">A picture that holds its space while it loads, says when it is loading, and says something useful when it fails. The three things a bare <code>&lt;img&gt;</code> leaves to whoever wrote it.</p>

<Demo src="image/hero" />

```tsx
import { Image } from 'neba';

<Image src={src} alt="A ridge of hills under a low sun" ratio="16 / 9" rounded />;
```

## Props

<PropsTable name="Image" />

Native `<img>` attributes pass through to the picture itself — `loading`, `decoding`, `srcSet`, `sizes`, `referrerPolicy`. Only `width` and `height` are excluded; use `ratio` and let the box do the reserving.

### `alt` is required

By the type, which is the one place this is stricter than the tag it wraps.

A missing `alt` and an empty one mean different things — "nobody wrote this" and "this picture says nothing a reader needs" — and only the second is ever correct. Being made to type `alt=""` is being made to say which one you meant.

## Examples

### ratio

The proportion to hold while the file is still arriving, and the main reason to use this over an `<img>`. A picture with no reserved box pushes the page down when it lands, which is the single largest source of layout shift on most sites.

```tsx
<Image src={src} alt="…" ratio="16 / 9" />
<Image src={src} alt="…" ratio={1} />
```

`'auto'` is the default and opts out — right only where the space around the picture can absorb the jump.

### fit and rounded

`fit` is `object-fit`: `cover` (the default), `contain`, `fill`, `none`. `rounded` takes a step of the radius ladder, or `true` for `md`.

### placeholder and fallback

While the file is arriving, a [Skeleton](../feedback/skeleton) of the same shape stands in. Pass a node of your own, or `false` for nothing.

When it does not arrive, `fallback` is drawn instead — by default a box carrying the `alt` text. Something rather than nothing, because the browser's own torn-page glyph tells a reader the _site_ is broken rather than that one file is missing.

Changing `src` starts both over. Without that, a second file would inherit the first one's success and never show a placeholder — and a second file that failed would inherit it too.

### preview

Opens the full picture in a [Dialog](../feedback/dialog) when it is clicked.

The picture becomes a `<button>` carrying the `alt` as its name, so `Tab` reaches it and `Enter` opens it. An image only a pointer can enlarge is an image half the readers cannot enlarge.

<Demo src="image/preview">

<<< @/.vitepress/demos/image/preview.tsx

</Demo>

### onLoadingStatusChange

Called with `'loading'`, `'loaded'` or `'failed'`. Useful for swapping to a `src` you control, or for counting what did not arrive.

## Accessibility

- `alt` is the picture's accessible name. Write what the picture _says_, not what it is a picture of, and use `alt=""` when it says nothing the surrounding text does not.
- With `preview`, the button takes its name from `alt` and nothing else. Two names for one thing is a screen reader reading the same sentence twice.
- The placeholder and the fallback are not announced separately; the picture keeps its own name throughout.

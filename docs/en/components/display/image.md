---
title: Image
order: 23
---

# Image

<p class="neba-lede">A picture that holds its space while it loads, says when it is loading, and says something useful when it fails. The three things a bare <code>&lt;img&gt;</code> leaves to whoever wrote it.</p>

<Demo src="image/hero" />

```tsx
import { Image } from 'neba';

<Image src={src} alt="Terraced tea fields under morning mist" ratio="16 / 9" rounded />;
```

## Props

<PropsTable name="Image" />

Native `<img>` attributes pass through to the picture itself — `loading`, `decoding`, `srcSet`, `sizes`, `referrerPolicy`, and `width` and `height` among them.

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

`'auto'` is the default and lets the file decide, which reserves nothing on its own.

### width and height

The file's own pixel dimensions, as an `<img>` takes them. They reach the picture either way, and giving both turns an `'auto'` ratio into their proportion — so the box is reserved without anybody working out that 1200 by 800 is 3/2.

```tsx
<Image src={src} alt="…" width={1200} height={800} />
```

`ratio` is the layout's shape and these two are the picture's, so an explicit `ratio` outranks them. One on its own reserves nothing, since a proportion needs two numbers.

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

### filter

How the picture is coloured. Seven names — `grayscale`, `sepia`, `invert`, `saturate`, `mute`, `contrast`, and `none`, the default — or a CSS `filter` chain of your own for anything past them.

The treatment travels on the same clock as the picture's own fade, so a `className` that changes it under the pointer is a thumbnail that comes back to life rather than one that snaps.

<Demo src="image/filter">

<<< @/.vitepress/demos/image/filter.tsx

</Demo>

### frame

How the picture is mounted. A silhouette on its own — `frame="circle"` — or the whole arrangement written out: `shape`, `corner`, `border`, `borderColor`, `mat`, `background`, `elevation` and `feather`.

The line is drawn as an inset shadow rather than a `border`, which is what lets it follow a cut corner or a circle and what keeps it out of the layout. `mat` is the one part that takes room: it is the mount between the line and the picture.

<Demo src="image/frame">

<<< @/.vitepress/demos/image/frame.tsx

</Demo>

### watermark

A mark drawn over the picture. A string is placed once in the bottom corner; the options form takes `content`, `position`, `repeat`, `opacity`, `rotate`, `size` and `color`.

`repeat` tiles the mark across the whole picture, which is the arrangement that actually deters a screenshot. It needs text — a node cannot be drawn into the tile, and is placed once instead.

<Demo src="image/watermark">

<<< @/.vitepress/demos/image/watermark.tsx

</Demo>

### protect

Turns off the ways a picture is casually taken: the right-click menu, the drag that drops a copy into another window, the iOS long press, and the selection a Ctrl-A sweeps up. `protect` turns on all four; the options form takes `contextMenu`, `drag` and `select` separately.

A deterrent and not a lock. The file is still one request away in the network tab, and a reader who wants it will have it — what this stops is the copy that gets made without thinking about it. Turning it on to protect a secret is turning it on for the wrong reason.

<Demo src="image/protect">

<<< @/.vitepress/demos/image/protect.tsx

</Demo>

### onLoadingStatusChange

Called with `'loading'`, `'loaded'` or `'failed'`. Useful for swapping to a `src` you control, or for counting what did not arrive.

## Accessibility

- `alt` is the picture's accessible name. Write what the picture _says_, not what it is a picture of, and use `alt=""` when it says nothing the surrounding text does not.
- With `preview`, the button takes its name from `alt` and nothing else. Two names for one thing is a screen reader reading the same sentence twice.
- The placeholder and the fallback are not announced separately; the picture keeps its own name throughout.
- A failed picture with an empty `alt` has no name to fall back on, so the box says so in the page's own language. Set `locale`, or write the sentence out with `unavailableLabel`.
- A watermark is `aria-hidden` and takes no pointer events. What it says belongs in the text around the picture, or in the `alt`, where a reader who cannot see the mark still meets it.
- `protect` takes away a browser affordance rather than adding one. Nothing it turns off is a keyboard path or a screen reader path, but "open image in new tab" goes with the context menu — so turn it on where the mark on the picture is the point, and not by default.

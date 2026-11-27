---
title: Image
order: 23
flutter: true
---

# Image

<p class="neba-lede">A picture that holds its space while it loads, shows that it is loading, and shows something useful when it fails. A bare <code>&lt;img&gt;</code> leaves all three to the caller.</p>

<Demo src="image/hero" />

::: fw react

```tsx
import { Image } from 'neba';

<Image src={src} alt="Terraced tea fields under morning mist" ratio="16 / 9" rounded />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaImage(
  image: AssetImage('assets/tea.jpg'),
  alt: 'Terraced tea fields under morning mist',
  ratio: 16 / 9,
  rounded: NebaSize.md,
);
```

:::

## Props

<PropsTable name="Image" />

::: fw react

Native `<img>` attributes pass through to the picture itself: `loading`, `decoding`, `srcSet`, `sizes`, `referrerPolicy`, and `width` and `height` among them.

:::

::: fw flutter

The file is `image`, any `ImageProvider`, where React takes a URL: an asset, a file on the network or on the device and a picture already in memory are one parameter, and the provider decides how it is fetched, cached and chosen for the screen's pixel density. That is why there is no `srcSet`, `sizes` or `referrerPolicy`. The option types are `NebaImageFilter`, `NebaImageFlip`, `NebaImageLetterbox`, `NebaImagePlaceholder`, `NebaImageFrame` and `NebaImageWatermark`.

:::

### `alt` is required

::: fw react

By the type, which is the one place this is stricter than the tag it wraps.

A missing `alt` and an empty one mean different things ("nobody wrote this" and "this picture says nothing a reader needs"), and only the second is ever correct. Being made to type `alt=""` is being made to say which one you meant.

:::

::: fw flutter

By the constructor, which is the one place this is stricter than Flutter's `Image`, whose `semanticLabel` may be left out.

A missing name and an empty one mean different things ("nobody wrote this" and "this picture says nothing a reader needs"), and only the second is ever correct. Being made to type `alt: ''` is being made to say which one you meant.

:::

## Examples

### ratio

The proportion to hold while the file is still arriving, and the main reason to use this over <Fw react="an `&lt;img&gt;`" flutter="an `Image`" />. A picture with no reserved box pushes the page down when it lands, which is the single largest source of layout shift on most sites.

::: fw react

```tsx
<Image src={src} alt="…" ratio="16 / 9" />
<Image src={src} alt="…" ratio={1} />
```

`'auto'` is the default and lets the file decide, which reserves nothing on its own.

:::

::: fw flutter

```dart
NebaImage(image: image, alt: '…', ratio: 16 / 9)
NebaImage(image: image, alt: '…', ratio: 1)
```

`ratio` is a `double`, width over height. Left out, the file decides once it is in, which reserves nothing on its own.

:::

### width and height

::: fw react

The file's own pixel dimensions. They reach the picture either way, and giving both turns an `'auto'` ratio into their proportion, so the box is reserved without anybody working out that 1200 by 800 is 3/2. Together they set only that proportion, not a size: the box spans the width its container gives it, the way an `<img>` with `width: 100%` does. To keep it 320 pixels wide, give the Image that width in its `className` or `style`.

```tsx
<Image src={src} alt="…" width={1200} height={800} />
```

`ratio` is the layout's shape and these two are the picture's, so an explicit `ratio` outranks them.

One on its own is not a proportion, so it sizes the box on that axis instead. `height={200}` is a box 200 pixels tall across the width it is given, and `width={320}` is one 320 pixels wide, never wider than its container, and as tall as the picture. A number is pixels and a string is a CSS length. With a `ratio` as well, a lone `height` takes its width from the ratio.

```tsx
<Image src={src} alt="…" height={200} fit="contain" />
<Image src={src} alt="…" width={320} />
```

:::

::: fw flutter

The file's own pixel dimensions. Giving both makes them the box's proportion, so the box is reserved without anybody working out that 1200 by 800 is 3/2. Together they set only that proportion, not a size: the box spans the width it is given, unlike `Image`'s `width` and `height`. To keep it 320 pixels wide, put it in a `SizedBox(width: 320)`.

```dart
NebaImage(image: image, alt: '…', width: 1200, height: 800)
```

`ratio` is the layout's shape and these two are the picture's, so an explicit `ratio` outranks them.

One on its own is not a proportion, so it sizes the box on that axis instead, in logical pixels. `height: 200` is a box 200 pixels tall across the width it is given, and `width: 320` is one 320 pixels wide, never wider than what it is given, held at the start, and as tall as the picture. With a `ratio` as well, a lone `height` takes its width from the ratio. Given no width to fill, as in a `Row`, the box is as wide as the file it knows about.

```dart
NebaImage(image: image, alt: '…', height: 200, fit: BoxFit.contain)
NebaImage(image: image, alt: '…', width: 320)
```

The box answers a parent that measures before it lays out, such as `IntrinsicHeight`, with the size it is going to take.

:::

### fit and rounded

::: fw react

`fit` is `object-fit`: `cover` (the default), `contain`, `fill`, `none`, `scale-down`. It decides what the picture does inside a box that is not its own shape, whether `ratio`, a lone `width` or `height`, or a `className` set that box. `rounded` takes a step of the radius ladder, or `true` for `md`.

:::

::: fw flutter

`fit` is a `BoxFit`: `cover` (the default), `contain`, `fill`, `none`, `scaleDown`, and `fitWidth` and `fitHeight` besides. It decides what the picture does inside a box that is not its own shape, whether `ratio` or a lone `width` or `height` set that box. `rounded` takes a step of the radius ladder; `null`, the default, leaves the corners square.

:::

<Demo src="image/fit">

::: fw react

<<< @/.vitepress/demos/image/fit.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/fit.dart

:::

</Demo>

### position

::: fw react

Where the picture sits in its box, spelled the way `object-position` spells it: `center` (the default), `top`, `right`, `bottom`, `left`, a corner such as `top left`, or two percentages such as `'30% 20%'`. Under `cover` it decides which part of the picture survives the crop, and under `contain`, `none` and `scale-down` it decides where the empty space goes.

:::

::: fw flutter

Where the picture sits in its box, as an `Alignment`: `Alignment.center` (the default), a side such as `Alignment.topCenter`, a corner such as `Alignment.topLeft`, or a point of your own. An alignment runs from `-1` to `1`, so React's `'30% 20%'` is `Alignment(-0.4, -0.6)`. Under `cover` it decides which part of the picture survives the crop, and under the other fits it decides where the empty space goes.

:::

It is read on the picture as it is shown, so it holds through `rotate` and `flip`: <Fw react="`position=&quot;top&quot;`" flutter="`Alignment.topCenter`" /> keeps the top of what the reader sees. It is also physical rather than logical, and does not change sides on a right-to-left page.

<Demo src="image/position">

::: fw react

<<< @/.vitepress/demos/image/position.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/position.dart

:::

</Demo>

### letterbox

::: fw react

What fills the part of the box a picture leaves empty under `contain`, `none` or `scale-down`. `blur` draws the same picture behind it, covering the box and blurred, the way a video player fills the sides of a portrait clip. Any other string is a CSS `background`: a colour, a token or a gradient. `none`, the default, leaves the box transparent.

The blurred copy is the same file, so it is not a second download, and it is requested with the picture's own `loading` and fetch priority. It follows `position`, `rotate`, `flip` and `filter`, and it is only drawn under a `fit` that can leave space.

:::

::: fw flutter

What fills the part of the box a picture leaves empty under `contain`, `none` or `scaleDown`. `NebaImageLetterbox.blur` draws the same picture behind it, covering the box and blurred, the way a video player fills the sides of a portrait clip. `NebaImageLetterbox.color` takes a colour and `NebaImageLetterbox.decoration` any `Decoration`, a gradient among them. `NebaImageLetterbox.none`, the default, leaves the box transparent.

The blurred copy is drawn from the picture's own decoded file, so it is not a second download. It follows `position`, `rotate`, `flip` and `filter`, and it is only drawn under a `fit` that can leave space.

:::

<Demo src="image/letterbox">

::: fw react

<<< @/.vitepress/demos/image/letterbox.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/letterbox.dart

:::

</Demo>

### rotate and flip

`rotate` turns the picture clockwise by `0`, `90`, `180` or `270` degrees. `flip` mirrors it: `horizontal`, `vertical`, `both`, or `none`, the default. The mirror runs along the axes the picture is shown on, so <Fw react="`flip=&quot;horizontal&quot;`" flutter="`NebaImageFlip.horizontal`" /> swaps left and right whether or not the picture has been turned.

A picture on its side is laid out on its side. `width` and `height` still describe the file, so <Fw react="`width={560} height={373} rotate={90}`" flutter="`width: 560, height: 373, rotate: 90`" /> reserves a tall box, and with neither the box takes the turned shape once the file arrives. An explicit `ratio` stays as it is, and `fit` decides how the turned picture fills it. The preview opens turned and mirrored the same way.

::: fw flutter

Any other number of degrees is the nearest quarter. The turn is a `RotatedBox` around the picture and the mirror a `Transform.flip` outside it, transforms of the photograph alone inside a box that never moves: the design language allows them on a picture, which carries no label to resample, and never on a control.

:::

<Demo src="image/rotate">

::: fw react

<<< @/.vitepress/demos/image/rotate.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/rotate.dart

:::

</Demo>

### placeholder and fallback

::: fw react

While the file is arriving, a [Skeleton](../feedback/skeleton) of the same shape stands in. Pass a node of your own, or `false` for nothing.

Pass `{ src }` to stand a picture in instead: a URL, a data URI or a `Blob`, which is shown through an object URL and released when it is no longer needed. It is drawn the way the picture will be, with the same `fit`, `position`, `rotate` and `flip`, so it is meant for a small copy of the same file. `blur` softens a copy stretched up from a few pixels, by 20 pixels for `true` or by a number you give. The picture fades in over it, and it goes once that fade has run. Like the Skeleton, it fills the box, so it needs a `ratio`, or `width` and `height`. It takes the picture's `loading`, so under `loading="lazy"` it is not fetched until the reader scrolls near either.

:::

::: fw flutter

While the file is arriving, a [Skeleton](../feedback/skeleton) of the same shape stands in. Where Flutter's `Image` takes a `frameBuilder` to draw something before the first frame, `placeholder` says what: `NebaImagePlaceholder.widget` for a widget of your own, and `NebaImagePlaceholder.none` for nothing. An `image` of `null` is a picture still waiting for a file, and its placeholder stays for as long as it does.

`NebaImagePlaceholder.image` stands a picture in instead, any `ImageProvider`. It is drawn the way the picture will be, with the same `fit`, `position`, `rotate` and `flip`, so it is meant for a small copy of the same file. `blur` softens a copy stretched up from a few pixels, as a standard deviation in logical pixels: React's `blur: true` is `20`. The picture fades in over it, and it goes once that fade has run. Like the Skeleton, it fills the box, so it needs a `ratio`, or `width` and `height`.

:::

<Demo src="image/placeholder">

::: fw react

<<< @/.vitepress/demos/image/placeholder.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/placeholder.dart

:::

</Demo>

::: fw react

On a page rendered on a server, the picture is never hidden and nothing is drawn over it. The placeholder goes under the `<img>`, which shows as soon as the browser has the file, before hydration and with JavaScript off, so Largest Contentful Paint does not wait for a script. Until hydration, the placeholder also shows through any part of the box the picture leaves clear, such as the sides `contain` leaves or the transparent parts of a PNG. A picture first mounted in the browser, such as one added after the page has loaded, fades in over its placeholder.

When it does not arrive, `fallback` is drawn instead: by default a box carrying the `alt` text. Something rather than nothing, because the browser's own torn-page glyph tells a reader the _site_ is broken rather than that one file is missing.

Changing `src` starts both over. Without that, a second file would inherit the first one's success and never show a placeholder, and a second file that failed would inherit it too.

:::

::: fw flutter

A picture already in the image cache is drawn at once, with no fade and no placeholder, since nothing was ever painted without it. Any other fades in over its placeholder.

When it does not arrive, `fallback` is drawn instead, where `Image` would call its `errorBuilder`: by default a box carrying the `alt` text. Something rather than nothing, because an empty hole tells a reader the _app_ is broken rather than that one file is missing. A file that fails is not reported to `FlutterError`, since the fallback is what it is for.

A new `image` starts both over. Without that, a second file would inherit the first one's success and never show a placeholder, and a second file that failed would inherit it too. A provider equal to the last one, an `AssetImage` of the same name, is the same picture.

:::

### priority and loading

::: fw react

When a picture loads belongs to the `<img>`, and its attributes pass straight through. `loading="lazy"` waits until the reader scrolls near a picture below the fold, `decoding="async"` keeps the decode off the main thread, and `fetchPriority` moves the request up or down the network queue.

`priority` is for the picture a page is judged by, usually the largest one above the fold, which is what Largest Contentful Paint measures. It sets `loading="eager"` and a high fetch priority together, and an attribute written out still wins over it. It also draws the picture with no fade and no Skeleton, even where the Image is first mounted in the browser; a `placeholder` picture still stands beneath it. A lazy picture needs its box as much as any other, so keep `ratio`, or `width` and `height`, on it.

```tsx
<Image src={hero} alt="…" ratio="16 / 9" priority />
<Image src={thumbnail} alt="…" ratio={1} loading="lazy" />
```

:::

::: fw flutter

Flutter has no `loading`, `decoding` or `fetchPriority`: a picture is asked for when its widget is built. A picture below the fold is put off by building it lazily, in a `ListView.builder` or a sliver, and one that has to be there at once is fetched ahead with `precacheImage`.

`priority` is the part that is left: it draws the picture with no fade and no Skeleton, for the picture a screen is judged by. A `placeholder` picture still stands beneath it while it arrives.

```dart
NebaImage(image: hero, alt: '…', ratio: 16 / 9, priority: true)
```

:::

### preview

::: fw react

Opens the full picture in a [Dialog](../feedback/dialog) when it is clicked.

The picture becomes a `<button>` carrying the `alt` as its name, so `Tab` reaches it and `Enter` opens it. An image only a pointer can enlarge is an image half the readers cannot enlarge.

With `preview` on, `className` and `style` go on the button, so what sizes the picture also sizes what can be pressed.

The Dialog's code is fetched when a pointer, the focus or a finger first reaches the picture, so it is usually there by the time the press lands, and the Dialog is mounted by that press. A page whose pictures nobody reaches for never downloads it, and a server render has nothing to wait for.

:::

::: fw flutter

Opens the full picture over the page when it is pressed, on the sheet a Dialog draws: titled by the `alt`, with a × in its corner, over a scrim, faded in. The picture is the file at its own size, never enlarged, held to the sheet's width and to 70% of the window's height. It needs an `Overlay` above it, which a `WidgetsApp` with a navigator has and `Overlay.wrap` gives anything else.

The picture becomes a button carrying the `alt` as its name, so `Tab` reaches it and `Enter` or `Space` opens it. An image only a pointer can enlarge is an image half the readers cannot enlarge. Escape, the × and a press on the scrim close it, and the focus goes back to the picture. Nothing of the sheet is built until it opens.

:::

<Demo src="image/preview" frameMinHeight="560">

::: fw react

<<< @/.vitepress/demos/image/preview.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/preview.dart

:::

</Demo>

### filter

::: fw react

How the picture is coloured. Seven names (`grayscale`, `sepia`, `invert`, `saturate`, `mute`, `contrast`, and `none`, the default), or a CSS `filter` chain of your own for anything past them.

The treatment travels on the same clock as the picture's own fade, so a `className` that changes it under the pointer is a thumbnail that comes back to life rather than one that snaps.

:::

::: fw flutter

How the picture is coloured. Seven names (`NebaImageFilter.grayscale`, `sepia`, `invert`, `saturate`, `mute`, `contrast`, and `none`, the default), or `NebaImageFilter.matrix` with the twenty numbers `ColorFilter.matrix` takes for anything past them. Each name is the matrix the Filter Effects specification writes for the CSS function React's name stands for, `grayscale(1)`, `sepia(0.72)`, `invert(1)`, `saturate(1.5)`, `saturate(0.45)` and `contrast(1.25)`, so a treatment looks the same in both packages.

It is a matrix rather than any `ColorFilter` because a matrix eases: a `filter` that changes travels to the new treatment on the same clock as the picture's own fade, so a thumbnail that comes back to life under the pointer does not snap.

:::

<Demo src="image/filter">

::: fw react

<<< @/.vitepress/demos/image/filter.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/filter.dart

:::

</Demo>

### frame

::: fw react

How the picture is mounted. A silhouette on its own (`frame="circle"`), or the whole arrangement written out: `shape`, `corner`, `border`, `borderColor`, `mat`, `background`, `elevation` and `feather`.

The line is drawn as an inset shadow rather than a `border`, which is what lets it follow a rounded corner or a circle and what keeps it out of the layout. On a cut corner the diagonal is left without a line. `mat` is the one part that takes room: it is the mount between the line and the picture.

:::

::: fw flutter

How the picture is mounted, as a `NebaImageFrame`: a silhouette on its own (`NebaImageFrame(shape: NebaImageFrameShape.circle)`), or the whole arrangement written out. `corner` is a step of the radius ladder and `cornerRadius` a number of pixels; `border` is the line's width, where `1` is React's `true`; `feather` fades the edge over a number of pixels and `featherFraction` over a share of the picture's width and height, React's `'10%'`. `borderColor`, `mat`, `background` and `elevation` are React's.

The line is drawn over the picture along the outer edge of the mount, so it stays out of the layout, and it follows every edge of the silhouette, the diagonal of a cut corner included. `mat` is the one part that takes room: it is the mount between the line and the picture.

:::

<Demo src="image/frame">

::: fw react

<<< @/.vitepress/demos/image/frame.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/frame.dart

:::

</Demo>

### watermark

::: fw react

A mark drawn over the picture. A string is placed once in the bottom corner; the options form takes `content`, `position`, `repeat`, `opacity`, `rotate`, `size` and `color`.

`repeat` tiles the mark across the whole picture, which is the arrangement that actually deters a screenshot. It needs text: a node cannot be drawn into the tile, and is placed once instead. `color` takes any CSS colour, a `var(--neba-…)` token included, in either arrangement.

:::

::: fw flutter

A mark drawn over the picture, as a `NebaImageWatermark`. `NebaImageWatermark('© Neba')` is placed once in the bottom corner at the end; it also takes `position`, an `AlignmentDirectional` whose `topStart`, `topEnd`, `bottomStart`, `bottomEnd` and `center` are React's five, and `repeat`, `opacity`, `rotate`, `size` (a step of the meta ladder) or `fontSize`, and `color`.

`repeat` tiles the mark across the whole picture, which is the arrangement that actually deters a screenshot. `NebaImageWatermark.widget` places a widget of your own, a logo, once, since a widget cannot be drawn into a tile.

:::

<Demo src="image/watermark">

::: fw react

<<< @/.vitepress/demos/image/watermark.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/watermark.dart

:::

</Demo>

### protect

::: fw react

Turns off the ways a picture is casually taken: the right-click menu, the drag that drops a copy into another window, the iOS long press, and the selection a Ctrl-A sweeps up. `protect` turns on all four; the options form takes `contextMenu`, `drag` and `select` separately.

A deterrent and not a lock. The file is still one request away in the network tab, and a reader who wants it will have it: what this stops is the copy that gets made without thinking about it. Turning it on to protect a secret is turning it on for the wrong reason.

:::

::: fw flutter

A picture Flutter draws is pixels on a canvas, so on a phone or a desktop nothing offers to save it, copy it or drag it out, and a selection has nothing of it to sweep up: three of the four ways React turns off are not there to begin with. On the web, the browser's own menu over the canvas still offers to save what is under the pointer, so `protect` holds that menu off through `BrowserContextMenu` while the pointer is over the picture, and turns it back on when the pointer leaves if it was on before. That is the whole of it, so `protect` is a `bool`, with no options form. The mark is always out of a selection, protected or not.

A deterrent and not a lock. The file is still in the app's bundle or one request away, and a reader who wants it will have it: what this stops is the copy that gets made without thinking about it. Turning it on to protect a secret is turning it on for the wrong reason.

:::

<Demo src="image/protect">

::: fw react

<<< @/.vitepress/demos/image/protect.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/image/protect.dart

:::

</Demo>

### onLoadingStatusChange

::: fw react

Called with `'loading'`, `'loaded'` or `'failed'`. Useful for swapping to a `src` you control, or for counting what did not arrive.

:::

::: fw flutter

Called with `NebaImageLoadingStatus.loading`, `loaded` or `failed`, after the frame in which it changed. A picture already in the cache says `loaded` alone. Useful for swapping to an `image` you control, or for counting what did not arrive.

:::

## Accessibility

::: fw react

- `alt` is the picture's accessible name. Write what the picture _says_, not what it is a picture of, and use `alt=""` when it says nothing the surrounding text does not.
- With `preview`, the button takes its name from `alt` and nothing else, since two names for one thing is a screen reader reading the same sentence twice. A picture with `alt=""` has no name to lend, so its button and its preview are named "Enlarge image" in the `locale`'s language.
- The placeholder and the fallback are not announced separately; the picture keeps its own name throughout.
- A failed picture with an empty `alt` has no name to fall back on, so the box says so in the page's own language. Set `locale`, or write the sentence out with `unavailableLabel`.
- A watermark is `aria-hidden` and takes no pointer events. What it says belongs in the text around the picture, or in the `alt`, where a reader who cannot see the mark still meets it.
- `protect` takes away a browser affordance rather than adding one. Nothing it turns off is a keyboard path or a screen reader path, but "open image in new tab" goes with the context menu, so turn it on where the mark on the picture is the point, and not by default.

:::

::: fw flutter

- `alt` is the picture's name: a screen reader hears an image of that name. Write what the picture _says_, not what it is a picture of, and use `alt: ''` when it says nothing the surrounding text does not; the picture is then left out of the semantics tree.
- With `preview`, the button takes its name from `alt` and nothing else, since two names for one thing is a screen reader reading the same sentence twice. A picture with `alt: ''` has no name to lend, so its button and its preview are named "Enlarge image" in the `locale`'s language.
- The placeholder and the fallback are not announced separately; the picture keeps its own name throughout.
- A failed picture with an empty `alt` has no name to fall back on, so the box says so in the app's own language. Set `locale`, or write the sentence out with `unavailableLabel`.
- A watermark is out of the semantics tree, the pointer's reach and any selection. What it says belongs in the text around the picture, or in the `alt`, where a reader who cannot see the mark still meets it.
- `protect` takes away a browser affordance rather than adding one. Nothing it turns off is a keyboard path or a screen reader path, but "open image in new tab" goes with the browser's menu, so turn it on where the mark on the picture is the point, and not by default.

:::

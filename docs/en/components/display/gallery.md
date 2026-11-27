---
title: Gallery
order: 24
flutter: true
---

# Gallery

<p class="neba-lede">Arranges a set of pictures. Four layouts (a contact sheet, a masonry, a justified library and a quilt) work over one list of images and the metadata that came with them, with a viewer a click away.</p>

<Demo src="gallery/hero" />

::: fw react

```tsx
import { Gallery } from 'neba';

<Gallery
  items={[{ src, alt: 'A still alpine lake at dawn', title: 'Alpine lake', ratio: '3 / 2' }]}
  layout="justified"
  caption="hover"
  preview
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaGallery(
  items: <NebaGalleryItem>[
    NebaGalleryItem(
      image: AssetImage('assets/lake.jpg'),
      alt: 'A still alpine lake at dawn',
      title: 'Alpine lake',
      ratio: 3 / 2,
    ),
  ],
  layout: NebaGalleryLayout.justified,
  caption: NebaGalleryCaption.hover,
  preview: true,
);
```

:::

## Props

<PropsTable name="Gallery" />

::: fw react

Every other `<ul>` attribute passes through to the list. The shared axes are defined in [prop conventions](../../design/prop-conventions).

:::

::: fw flutter

`columns` is a count rather than a breakpoint map, `gap` is a number of pixels with the ladder's steps in `NebaGallery.gaps`, and `rounded` is a step or `null` for square tiles. There is no `loading`: a picture is asked for when its tile is built, so a set too long to fetch at once goes into a lazily built list in pieces. The shared axes are defined in [prop conventions](../../design/prop-conventions).

:::

### The item

<PropsTable name="NebaGalleryItem" />

`masonry` and `justified` are laid out from each item's `ratio` before any file has arrived, so the arrangement is right in the first frame and does not reflow as the pictures load. No picture is ever measured. An item with no `ratio` falls back to the Gallery's own.

An item can also carry `rotate`, `flip`, `position` and a `placeholder`, which reach its picture as they do on an [Image](./image), and `rotate` and `flip` follow it into the viewer. `ratio` stays the proportion of the file as stored, so an item turned onto its side is laid out on its side.

::: fw react

`srcSet` and `sizes` reach the tile's `<img>` as they are, so a tile drawn 300 pixels wide is sent a file near that size rather than the original. An item with no `full` hands its `srcSet` to the viewer too, which chooses a candidate for its own size.

:::

::: fw flutter

The picture is `image` and the viewer's larger file `full`, each any `ImageProvider`; a `ResizeImage` is how a tile is drawn from a file decoded at the size it is shown. `title` and `description` are strings, since a screen reader hears them in the tile's name and the viewer's counter, and `id` is any value that tells two items apart.

:::

## Examples

### layout

`grid` gives every tile the same shape, whatever shape the files are. `masonry` keeps each picture's own proportion and stacks the columns, dealing each item into the shortest one so the first row is the first three pictures rather than the first three of column one. `justified` keeps the proportions and fills every row to the edge, scaling each row to a common height: the arrangement where nothing is cropped and no space is left over. `quilted` is a grid whose tiles may take more than one cell.

::: fw react

`masonry` reads the breakpoint in JavaScript, to know how many columns it deals into. A page rendered on a server draws one deal for every width its `columns` change at and shows only the one for the reader's width, so nothing moves when it hydrates; the others are hidden and are dropped once the page is running. Crossing a breakpoint afterwards deals again, which mounts every tile afresh in its new column. `grid`, `quilted` and `justified` take their columns from CSS and never move a tile.

:::

::: fw flutter

All four are laid out by one render object that reads the width it is given, so a tile is placed in the frame it first appears in and the deal is worked out again whenever the width or the column count changes. A tile keeps its state when it moves to another column.

:::

<Demo src="gallery/layouts">

::: fw react

<<< @/.vitepress/demos/gallery/layouts.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/layouts.dart

:::

</Demo>

### columns and gap

::: fw react

`columns` is how many tiles across, and it takes a breakpoint map: `{ xs: 2, sm: 3, lg: 4 }` is the default. `grid`, `masonry` and `quilted` read it; `justified` decides for itself, row by row, from `rowHeight`.

`gap` is the space between tiles: a step of the spacing ladder, a number in pixels, or a CSS length.

:::

::: fw flutter

`columns` is how many tiles across. Left out, it is two in a window narrower than `sm`, three from `sm` and four from `lg`, read off the window as React's default map is; a count of your own that changes with the window is read off `MediaQuery`, as the first gallery below does. `grid`, `masonry` and `quilted` read it; `justified` decides for itself, row by row, from `rowHeight`.

`gap` is the space between tiles in logical pixels, `8` by default. `NebaGallery.gaps` holds the ladder's steps, so React's `gap="xs"` is `NebaGallery.gaps[NebaSize.xs]`.

:::

<Demo src="gallery/columns">

::: fw react

<<< @/.vitepress/demos/gallery/columns.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/columns.dart

:::

</Demo>

### <Fw react="fit, letterbox and loading" flutter="fit and letterbox" />

::: fw react

`fit` is how each picture fills its tile, as on an Image. `cover`, the default, crops to the tile, and `contain` or `scale-down` keep the whole picture. `letterbox` fills the space those leave, with a CSS background or, for `blur`, with the picture itself. `loading` is `lazy` by default, which waits to fetch a tile's file until the tile is near the screen. Set `loading="eager"` when the gallery is the largest thing above the fold, where a lazy first row arrives later than it should.

:::

::: fw flutter

`fit` is how each picture fills its tile, as on an Image. `BoxFit.cover`, the default, crops to the tile, and `contain` or `scaleDown` keep the whole picture. `letterbox` fills the space those leave, with a colour, a `Decoration` or, for `NebaImageLetterbox.blur`, the picture itself.

:::

<Demo src="gallery/fit">

::: fw react

<<< @/.vitepress/demos/gallery/fit.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/fit.dart

:::

</Demo>

### priority

::: fw react

How many tiles, counted from the first item, are pictures the page is judged by. Those tiles are fetched early whatever `loading` says, and drawn from the first paint with no fade and no Skeleton, as an [Image](./image) with `priority` is. When the gallery is the largest thing above the fold, give it the length of the first row and leave the rest lazy.

```tsx
<Gallery items={photos} columns={3} priority={3} />
```

:::

::: fw flutter

How many tiles, counted from the first item, are pictures the screen is judged by. Those tiles are drawn with no fade and no Skeleton, as an [Image](./image) with `priority` is. When the gallery is the first thing on the screen, give it the length of the first row.

```dart
NebaGallery(items: photos, columns: 3, priority: 3)
```

:::

### caption

`below` puts an item's `title` and `description` under the picture, `overlay` writes them across the foot of it on a gradient, and `hover` is `overlay` that arrives with the pointer, or with the focus; <Fw react="on a screen that cannot hover" flutter="with no mouse connected" /> it is always there. `none`, the default, draws neither: the words are still in the picture's `alt` and in the viewer.

Reach for `overlay` or `hover` in `justified`: a caption below the picture makes a tile taller than the row it was measured into, and rows stop lining up.

<Demo src="gallery/captions">

::: fw react

<<< @/.vitepress/demos/gallery/captions.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/captions.dart

:::

</Demo>

### hover

`hover` sets what a tile does under the pointer, and a tile whose button has the keyboard focus does the same.

`lift` raises the tile on the shadow ladder and `dim` darkens the picture. `zoom` scales the photograph inside a frame that does not move, so the tile's own edges stay exactly where they were.

::: fw flutter

The zoom is a scale of the photograph alone, inside a frame that clips it: the one scale the design language allows, because what moves is a picture with no text on it to resample, and the tile, a control, never moves. A `dim` over a `filter` is the two in a row, the filter and then the darkening.

:::

`filter`, `frame`, `watermark` and `protect` pass straight through to every tile's [Image](./image), so a gallery of greyed thumbnails or a marked proof set is one <Fw react="prop" flutter="argument" />.

<Demo src="gallery/hover">

::: fw react

<<< @/.vitepress/demos/gallery/hover.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/hover.dart

:::

</Demo>

### preview

Opens the picture full size, with the rest of the set an arrow key away. `←` and `→` move the way the arrow points, so under RTL `←` is the next picture; `Esc` closes, and the counter under the picture is announced when it changes.

::: fw react

An item's `full` is used if it has one, so a grid of thumbnails can open the file it is a thumbnail of. `watermark` and `protect` follow the picture into the viewer. The viewer's code is fetched when a pointer, the focus or a finger first reaches the gallery and the viewer is mounted by the press that opens it, so a server render has nothing to wait for.

:::

::: fw flutter

An item's `full` is used if it has one, so a grid of thumbnails can open the file it is a thumbnail of. `watermark` and `protect` follow the picture into the viewer. The viewer is the sheet an Image's preview opens on, over a scrim in the app's root `Overlay`, so the gallery needs an `Overlay` above it; nothing of it is built until a tile is pressed.

:::

<Demo src="gallery/preview" frameMinHeight="560">

::: fw react

<<< @/.vitepress/demos/gallery/preview.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gallery/preview.dart

:::

</Demo>

### onItemSelect

Called with the item and its index when a tile is chosen, whether or not there is a viewer. It is what makes a tile a control: a Gallery with neither `preview` nor this draws plain pictures with nothing to press.

## Accessibility

::: fw react

- The list is a `role="list"` named by `label`, or by the `locale`'s word for "Gallery". Name it after what the set _is_, and give two galleries on one page different names.
- A tile's button is named by its caption and its place in the set, so a reader tabbing a wall of thumbnails is told which one of how many they are on, and a voice-control user can say the words on the tile to press it. A tile with no caption drawn is named by the picture's `alt` instead.
- `masonry` is read a column at a time. `Tab` and a screen reader go down the first column before the second, so with three columns the order is 1, 4, 7 and then 2, 5, 8, which is not the order the items were given in. Where the order matters, as in a sequence of steps or a ranking, use `justified`, which keeps it row by row.
- Every `hover` treatment is also a focus treatment.
- The viewer's counter is a live region, so an arrow key says where it landed to a reader who cannot see the picture it landed on.

:::

::: fw flutter

- The list is a list in the semantics tree named by `label`, or by the `locale`'s word for "Gallery". Name it after what the set _is_, and give two galleries on one page different names.
- A tile's button is named by its caption and its place in the set, so a reader tabbing a wall of thumbnails is told which one of how many they are on, and a voice-control user can say the words on the tile to press it; the description is read after it. A tile with no caption drawn is named by the picture's `alt` instead.
- `Tab` and a screen reader take the tiles in the order of `items` in every layout, `masonry` included, whichever column a tile was dealt into.
- Every `hover` treatment is also a focus treatment.
- The viewer's counter is a live region that says what the picture is and where it is in the set, so an arrow key says where it landed to a reader who cannot see the picture it landed on.

:::

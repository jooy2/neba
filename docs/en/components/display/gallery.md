---
title: Gallery
order: 24
---

# Gallery

<p class="neba-lede">Arranges a set of pictures. Four layouts (a contact sheet, a masonry, a justified library and a quilt) work over one list of images and the metadata that came with them, with a viewer a click away.</p>

<Demo src="gallery/hero" />

```tsx
import { Gallery } from 'neba';

<Gallery
  items={[{ src, alt: 'A still alpine lake at dawn', title: 'Alpine lake', ratio: '3 / 2' }]}
  layout="justified"
  caption="hover"
  preview
/>;
```

## Props

<PropsTable name="Gallery" />

Every other `<ul>` attribute passes through to the list. The shared axes are defined in [prop conventions](../../design/prop-conventions).

### The item

<PropsTable name="NebaGalleryItem" />

`ratio` is the one worth writing down even when it feels optional. `masonry` and `justified` are laid out from it, and they are laid out before a single file has arrived: which is what makes the arrangement right in the first frame and stops a wall of forty photographs reflowing forty times as they land. No picture is ever measured.

The one thing `masonry` reads in JavaScript is the breakpoint, to know how many columns it deals into. A page rendered on a server deals into the `xs` count and deals again once it hydrates on a wider screen, and crossing a breakpoint deals again, which mounts every tile afresh in its new column. `grid`, `quilted` and `justified` take their columns from CSS and never move a tile.

An item can also carry `rotate`, `flip`, `position` and a `placeholder`, which reach its picture as they do on an [Image](./image), and `rotate` and `flip` follow it into the viewer. `ratio` stays the proportion of the file as stored, so an item turned onto its side is laid out on its side.

## Examples

### layout

`grid` gives every tile the same shape, whatever shape the files are. `masonry` keeps each picture's own proportion and stacks the columns, dealing each item into the shortest one so the first row is the first three pictures rather than the first three of column one. `justified` keeps the proportions and fills every row to the edge, scaling each row to a common height: the arrangement where nothing is cropped and no space is left over. `quilted` is a grid whose tiles may take more than one cell.

<Demo src="gallery/layouts">

<<< @/.vitepress/demos/gallery/layouts.tsx

</Demo>

### columns and gap

`columns` is how many tiles across, and it takes a breakpoint map: `{ xs: 2, sm: 3, lg: 4 }` is the default. `grid`, `masonry` and `quilted` read it; `justified` decides for itself, row by row, from `rowHeight`.

`gap` is the space between tiles: a step of the spacing ladder, a number in pixels, or a CSS length.

<Demo src="gallery/columns">

<<< @/.vitepress/demos/gallery/columns.tsx

</Demo>

### fit, letterbox and loading

`fit` is how each picture fills its tile, as on an Image. `cover`, the default, crops to the tile, and `contain` or `scale-down` keep the whole picture. `letterbox` fills the space those leave, with a CSS background or, for `blur`, with the picture itself. `loading` is `lazy` by default, which waits to fetch a tile's file until the tile is near the screen. Set `loading="eager"` when the gallery is the largest thing above the fold, where a lazy first row arrives later than it should.

<Demo src="gallery/fit">

<<< @/.vitepress/demos/gallery/fit.tsx

</Demo>

### caption

`below` puts an item's `title` and `description` under the picture, `overlay` writes them across the foot of it on a gradient, and `hover` is `overlay` that arrives with the pointer, or with the focus; on a screen that cannot hover it is always there. `none`, the default, draws neither: the words are still in the picture's `alt` and in the viewer.

Reach for `overlay` or `hover` in `justified`: a caption below the picture makes a tile taller than the row it was measured into, and rows stop lining up.

<Demo src="gallery/captions">

<<< @/.vitepress/demos/gallery/captions.tsx

</Demo>

### hover

What a tile does under the pointer, and under the keyboard focus: both, always, so a tile is never a state only a mouse can reach.

`lift` raises the tile on the shadow ladder and `dim` darkens the picture, which is how the rest of the library answers a pointer. `zoom` scales the photograph inside a frame that does not move: the one place in Neba where something is scaled, and it is allowed here because a photograph carries no text to resample and the tile's own edges stay exactly where they were.

`filter`, `frame`, `watermark` and `protect` pass straight through to every tile's [Image](./image), so a gallery of greyed thumbnails or a marked proof set is one prop.

<Demo src="gallery/hover">

<<< @/.vitepress/demos/gallery/hover.tsx

</Demo>

### preview

Opens the picture full size, with the rest of the set an arrow key away. `←` and `→` move the way the arrow points, so under RTL `←` is the next picture; `Esc` closes, and the counter under the picture is announced when it changes.

An item's `full` is used if it has one, so a grid of thumbnails can open the file it is a thumbnail of. `watermark` and `protect` follow the picture into the viewer, because a mark that came off the moment somebody enlarged the picture would not be a mark.

The viewer is fetched on demand. A Gallery that does not offer one does not carry it.

<Demo src="gallery/preview">

<<< @/.vitepress/demos/gallery/preview.tsx

</Demo>

### onItemSelect

Called with the item and its index when a tile is chosen, whether or not there is a viewer. It is what makes a tile a control: a Gallery with neither `preview` nor this draws plain pictures with nothing to press.

## Accessibility

- The list is a `role="list"` named by `label`, or by the `locale`'s word for "Gallery". Name it after what the set _is_: a page with two galleries and one name on both is a page with one name.
- A tile's button is named by its caption and its place in the set, so a reader tabbing a wall of thumbnails is told which one of how many they are on, and a voice-control user can say the words on the tile to press it. A tile with no caption drawn is named by the picture's `alt` instead.
- `masonry` is read a column at a time. `Tab` and a screen reader go down the first column before the second, so with three columns the order is 1, 4, 7 and then 2, 5, 8, which is not the order the items were given in. Where the order matters, as in a sequence of steps or a ranking, use `justified`, which keeps it row by row.
- Every hover treatment is also a focus treatment. A tile that only responds to a pointer responds to half the readers.
- The viewer's counter is a live region, so an arrow key says where it landed to a reader who cannot see the picture it landed on.

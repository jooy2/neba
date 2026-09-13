'use client';

import * as React from 'react';
import { Image } from '../image/Image.js';
import { responsiveSlots, withBaseline } from '../../internal/responsive.js';
import { useBreakpointValue } from '../../hooks/useMediaQuery.js';
import { fill, galleryMessages, useMessages } from '../../internal/i18n.js';
import {
  cx,
  hasContent,
  metaTextClasses,
  radiusClasses,
  sheetTitleClasses,
  toLength
} from '../../internal/styles.js';
import type { NebaAspectFit } from '../aspect-ratio/AspectRatio.js';
import type {
  NebaImageFilter,
  NebaImageFlip,
  NebaImageFrame,
  NebaImageLetterbox,
  NebaImagePlaceholderOptions,
  NebaImagePosition,
  NebaImageProtection,
  NebaImageRotation,
  NebaImageWatermark
} from '../image/Image.js';
import type { NebaResponsive, NebaSize, NebaSlots } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/** The parts a Gallery draws behind its root. */
export type GallerySlot = 'item' | 'image' | 'caption' | 'title' | 'description';

/**
 * How the tiles are arranged.
 *
 * Four, and they answer four different questions rather than being four looks.
 * `grid` is a contact sheet: every tile the same shape, whatever shape the
 * files are. `masonry` keeps each picture's own proportion and stacks the
 * columns. `justified` keeps the proportions *and* fills every row to the edge,
 * scaling each row to a common height — the arrangement a photograph library
 * uses, and the only one where no tile is cropped and no space is left over.
 * `quilted` is a grid whose tiles may take more than one cell, for a set where
 * some pictures matter more than others.
 */
export type NebaGalleryLayout = 'grid' | 'masonry' | 'justified' | 'quilted';

/** What a tile does when the pointer is on it. */
export type NebaGalleryHover = 'none' | 'lift' | 'dim' | 'zoom';

/** Where a tile's words go. */
export type NebaGalleryCaption = 'none' | 'below' | 'overlay' | 'hover';

export interface NebaGalleryItem {
  /** Where the picture is. */
  src: string;
  /**
   * What the picture says. Required for the reason
   * [Image](../display/image) requires it.
   */
  alt: string;
  /** A stable identity. Defaults to `src`. */
  id?: string;
  /** The first line of the caption. */
  title?: React.ReactNode;
  /** The second, one step down the scale and muted. */
  description?: React.ReactNode;
  /**
   * A larger file for the viewer, when the tile is a thumbnail. Falls back to
   * `src`, so a set that has only one size of each picture needs nothing here.
   */
  full?: string;
  /**
   * The picture's own proportion, as a number or a CSS ratio.
   *
   * `masonry` and `justified` are laid out from this, and both are laid out
   * *before* anything has loaded — which is the whole reason it is data rather
   * than a measurement. A set without it falls back to the Gallery's own
   * `ratio`, and comes out as a grid of squares in a masonry's clothing.
   *
   * It is the file's proportion as stored: an item turned onto its side with
   * `rotate` is laid out on its side without anybody working the ratio out
   * again.
   */
  ratio?: number | string;
  /**
   * Turns the picture clockwise, a quarter at a time — for the photograph that
   * was shot sideways. Follows the picture into the viewer.
   * @default 0
   */
  rotate?: NebaImageRotation;
  /** Mirrors the picture. Follows it into the viewer. @default 'none' */
  flip?: NebaImageFlip;
  /**
   * Which part of the picture a tile keeps when it crops, or where the space
   * goes when it does not.
   * @default 'center'
   */
  position?: NebaImagePosition;
  /**
   * A small copy of the picture — a URL, a data URI or a `Blob` — to stand in
   * while the tile's file arrives, instead of a Skeleton.
   */
  placeholder?: NebaImagePlaceholderOptions;
  /** How many columns the tile takes in `quilted`. @default 1 */
  cols?: number;
  /** How many rows the tile takes in `quilted`. @default 1 */
  rows?: number;
}

export interface GalleryProps extends Omit<
  React.ComponentPropsWithoutRef<'ul'>,
  'children' | 'onSelect'
> {
  /** The pictures, in the order they are drawn. */
  items: readonly NebaGalleryItem[];
  /** How the tiles are arranged. @default 'grid' */
  layout?: NebaGalleryLayout;
  /**
   * How many tiles across, per breakpoint. Read by `grid`, `masonry` and
   * `quilted`; `justified` decides for itself, row by row.
   * @default { xs: 2, sm: 3, lg: 4 }
   */
  columns?: NebaResponsive<number>;
  /**
   * The space between tiles — a step of the spacing ladder, a number in pixels,
   * or a CSS length.
   * @default 'md'
   */
  gap?: NebaSize | number | string;
  /**
   * The shape of a tile in `grid`, and what an item with no `ratio` of its own
   * falls back to everywhere else.
   * @default 1
   */
  ratio?: number | string;
  /**
   * How tall a row aims to be in `justified`, and how tall one cell is in
   * `quilted`. Rows come out near it rather than on it, because the last thing
   * a justified row does is scale to the width it actually has.
   * @default 220
   */
  rowHeight?: number;
  /** Rounds the tiles. @default 'md' */
  rounded?: NebaSize | boolean;
  /**
   * How a picture fills its tile. `cover` crops it to the tile; `contain` and
   * `scale-down` keep all of it, which is what a set of product shots on a
   * contact sheet wants, and leave space that `letterbox` fills.
   * @default 'cover'
   */
  fit?: NebaAspectFit;
  /** Passed to every tile's picture: what fills the space `fit` leaves. */
  letterbox?: NebaImageLetterbox | (string & {});
  /**
   * When the tiles' files load. `lazy` waits until a tile is near the screen,
   * so a wall of forty photographs asks for the few a reader can see rather
   * than all forty at once. Set `eager` when the gallery is the largest thing
   * above the fold, where a lazy first row arrives later than it should.
   * @default 'lazy'
   */
  loading?: 'lazy' | 'eager';
  /**
   * Where a tile's `title` and `description` go. `below` puts them under the
   * picture, `overlay` writes them across the foot of it, and `hover` is
   * `overlay` that arrives with the pointer.
   * @default 'none'
   */
  caption?: NebaGalleryCaption;
  /**
   * What a tile does under the pointer.
   *
   * `lift` and `dim` are depth and colour, which is how everything else in the
   * library answers a pointer. `zoom` is the one that scales, and it is the
   * exception the design language names: what moves is a photograph inside a
   * frame that stays exactly where it was, with no text on it to resample.
   * @default 'lift'
   */
  hover?: NebaGalleryHover;
  /**
   * Opens the picture full size when a tile is clicked, with the rest of the
   * set an arrow key away.
   *
   * The viewer is fetched on demand, so a Gallery that does not offer one does
   * not carry it.
   * @default false
   */
  preview?: boolean;
  /** Called when a tile is chosen, whether or not there is a viewer. */
  onItemSelect?: (item: NebaGalleryItem, index: number) => void;
  /** Passed to every tile's picture. */
  filter?: NebaImageFilter | (string & {});
  /** Passed to every tile's picture. */
  frame?: NebaImageFrame;
  /** Passed to every tile's picture, and to the viewer. */
  watermark?: NebaImageWatermark;
  /** Passed to every tile's picture, and to the viewer. @default false */
  protect?: boolean | NebaImageProtection;
  /** The list's accessible name. Defaults to the `locale`'s word for it. */
  label?: string;
  /**
   * Which language the viewer's buttons are named in — a BCP 47 tag such as
   * `ko`, `pt-BR` or `zh-Hant`. Unsupported tags fall back to English.
   */
  locale?: string;
  /** What is drawn when `items` is empty. Nothing at all by default. */
  empty?: React.ReactNode;
  /** Class names for the parts behind the root. */
  classNames?: NebaSlots<GallerySlot>;
}

/**
 * The viewer, fetched only if somebody turns `preview` on.
 *
 * It is a whole Dialog and the chrome around it, which is more than the gallery
 * that opens it — `Image` makes the same bargain with the same prop, and for
 * the same reason: a wall of thumbnails is the common case and a lightbox is
 * not, so the chunk arrives after the first paint on the pages that want one.
 */
const GalleryViewer = React.lazy(() =>
  import('./GalleryViewer.js').then((module) => ({ default: module.GalleryViewer }))
);

/** The default, which is also the shape most photograph grids end up. */
const defaultColumns: NebaResponsive<number> = { xs: 2, sm: 3, lg: 4 };

/**
 * The gap ladder, as lengths rather than as classes.
 *
 * A Gallery's gap reaches four different layouts — a grid's `gap`, a column
 * stack's, a flex row's, and the arithmetic a justified row does against it —
 * so it has to be a value and not a `gap-4`.
 */
const gapValues: Record<NebaSize, string> = {
  xs: '0.25rem',
  sm: '0.375rem',
  md: '0.5rem',
  lg: '0.75rem',
  xl: '1rem'
};

/**
 * A tile's proportion as the number the layouts do arithmetic on.
 *
 * A ratio is `16 / 9` as often as it is `1.78`, because that is how CSS writes
 * one and this library does not make a caller translate it.
 */
function ratioOf(value: number | string | undefined, fallback: number): number {
  if (value === undefined) return fallback;
  if (typeof value === 'number') return value > 0 ? value : fallback;

  const [width, height] = value.split('/');
  const parsed = height === undefined ? Number(width) : Number(width) / Number(height);

  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

/**
 * Whether an item is turned onto its side, whatever number its turn was written
 * as. Exported for the viewer, and deliberately left out of the barrel.
 */
export function isSideways(item: NebaGalleryItem): boolean {
  return Math.abs(Math.round((item.rotate ?? 0) / 90)) % 2 === 1;
}

/**
 * The shape an item is drawn in: its own ratio, on its side when it is turned.
 * An item with no ratio takes the Gallery's, which is the layout's shape and has
 * nothing to turn.
 */
export function shownRatioOf(item: NebaGalleryItem, fallback: number): number {
  const own = ratioOf(item.ratio, fallback);

  return item.ratio !== undefined && isSideways(item) ? 1 / own : own;
}

/**
 * The items dealt into columns, shortest column first.
 *
 * Not CSS `columns`, which fills the first column top to bottom before it
 * starts the second — so a set numbered 1 to 12 reads down the left edge, and
 * the first three pictures a reader meets are stacked on top of each other.
 * Dealt this way the first row is items 1, 2 and 3, which is the order they
 * were given in.
 *
 * The heights are the ratios rather than anything measured, which is what makes
 * this run on the server and hold still while the files arrive.
 */
function deal(ratios: readonly number[], columns: number): number[][] {
  const lanes: number[][] = Array.from({ length: columns }, () => []);
  const heights = new Array<number>(columns).fill(0);

  ratios.forEach((ratio, index) => {
    let shortest = 0;

    for (let lane = 1; lane < columns; lane += 1) {
      if (heights[lane] < heights[shortest]) shortest = lane;
    }

    lanes[shortest].push(index);
    // One unit of width over the ratio is the height that unit of width draws.
    heights[shortest] += 1 / ratio;
  });

  return lanes;
}

/**
 * What a tile does under the pointer, as the classes that say it.
 *
 * `zoom` is on the picture and the other two are on the tile, which is why this
 * is two tables rather than one.
 *
 * The focus half asks whether the tile *has* a focused button inside it rather
 * than whether the tile is focused: the tile is an `<li>`, which never takes the
 * focus, so `group-focus-visible` could never apply. A browser without `:has()`
 * falls back to `focus-within`, which also answers a click.
 */
const tileHoverClasses: Record<NebaGalleryHover, string> = {
  none: '',
  lift: 'group-hover/tile:[box-shadow:var(--neba-shadow-2)] group-has-[:focus-visible]/tile:[box-shadow:var(--neba-shadow-2)] supports-[not_selector(:has(*))]:group-focus-within/tile:[box-shadow:var(--neba-shadow-2)]',
  dim: '',
  zoom: ''
};

const pictureHoverClasses: Record<NebaGalleryHover, string> = {
  none: '',
  lift: '',
  dim: 'group-hover/tile:[filter:brightness(0.82)] group-has-[:focus-visible]/tile:[filter:brightness(0.82)] supports-[not_selector(:has(*))]:group-focus-within/tile:[filter:brightness(0.82)]',
  zoom: 'group-hover/tile:[transform:scale(1.06)] group-has-[:focus-visible]/tile:[transform:scale(1.06)] supports-[not_selector(:has(*))]:group-focus-within/tile:[transform:scale(1.06)]'
};

/** The wash a caption is written on, so the words survive a pale photograph. */
const captionScrimClasses =
  '[background:linear-gradient(to_top,color-mix(in_oklab,#000_72%,transparent),transparent)]';

/**
 * A set of pictures, arranged.
 *
 * The four layouts are the component: everything else — the captions, the
 * pointer treatment, the viewer — is the same in all of them, and choosing
 * between a contact sheet, a masonry, a justified library and a quilt is one
 * prop rather than four components.
 *
 * None of them measures anything. A tile's shape comes from the item's own
 * `ratio`, which means the whole arrangement is right in the first frame the
 * browser paints and does not move again as the files arrive — the same bargain
 * `Image`'s `ratio` makes, one level up, and the reason a gallery of forty
 * photographs does not reflow forty times.
 */
export const Gallery = React.forwardRef<HTMLUListElement, GalleryProps>(
  function Gallery(rawProps, ref) {
    const {
      items,
      layout = 'grid',
      columns,
      gap = 'md',
      ratio = 1,
      rowHeight = 220,
      rounded = 'md',
      fit = 'cover',
      letterbox,
      loading = 'lazy',
      caption = 'none',
      hover = 'lift',
      preview = false,
      onItemSelect,
      filter,
      frame,
      watermark,
      protect = false,
      label,
      locale,
      empty,
      className,
      classNames,
      style,
      ...props
    } = useStyleDefaults(rawProps, ['locale']);

    const messages = useMessages(galleryMessages, locale);
    const [openAt, setOpenAt] = React.useState<number | null>(null);

    const lanes = withBaseline(columns ?? defaultColumns, 2);
    // The one number a layout has to know in JavaScript, and only `masonry`
    // does: the columns it deals into. Every other layout reads the same value
    // out of the cascade without React hearing about the resize.
    const laneCount = Math.max(1, useBreakpointValue(lanes) ?? 2);

    const space =
      typeof gap === 'string' && gap in gapValues
        ? gapValues[gap as NebaSize]
        : (toLength(gap as number | string) ?? gapValues.md);
    const radius = rounded === false ? '' : radiusClasses[rounded === true ? 'md' : rounded];
    const fallbackRatio = ratioOf(ratio, 1);

    const open = (index: number) => {
      onItemSelect?.(items[index], index);

      if (preview) setOpenAt(index);
    };

    const tile = (item: NebaGalleryItem, index: number, tileStyle: React.CSSProperties) => {
      const words = hasContent(item.title) || hasContent(item.description);
      const shown = caption !== 'none' && words;
      const over = caption === 'overlay' || caption === 'hover';

      const picture = (
        <Image
          src={item.src}
          alt={item.alt}
          /*
           * A contact sheet is a contact sheet: in `grid` every tile takes the
           * Gallery's own `ratio` whatever shape the file is, which is the
           * whole difference between it and a masonry. `quilted` takes neither,
           * because the cell it spans has already decided.
           */
          ratio={
            layout === 'grid'
              ? ratio
              : layout === 'quilted'
                ? 'auto'
                : item.ratio === undefined || !isSideways(item)
                  ? (item.ratio ?? ratio)
                  : shownRatioOf(item, fallbackRatio)
          }
          fit={fit}
          position={item.position}
          letterbox={letterbox}
          rotate={item.rotate}
          flip={item.flip}
          placeholder={item.placeholder}
          loading={loading}
          rounded={false}
          filter={filter}
          frame={frame}
          watermark={watermark}
          protect={protect}
          className={cx('size-full', classNames?.image)}
          classNames={{
            image: cx(
              // The house fill clock, and the same one the picture's own fade
              // already runs on, so a treatment and an arrival never disagree
              // about how long a picture takes to settle.
              '[transition:opacity_var(--neba-duration-fill)_var(--neba-ease),filter_var(--neba-duration-fill)_var(--neba-ease),transform_var(--neba-duration-fill)_var(--neba-ease)]',
              'motion-reduce:[transition-duration:0ms]',
              pictureHoverClasses[hover]
            )
          }}
        />
      );

      const legend = !shown ? null : (
        <div
          className={cx(
            'min-w-0',
            over
              ? cx(
                  'pointer-events-none absolute inset-x-0 bottom-0 flex flex-col gap-0.5 p-2.5 text-white',
                  captionScrimClasses,
                  caption === 'hover'
                    ? 'opacity-0 group-hover/tile:opacity-100 group-has-[:focus-visible]/tile:opacity-100 supports-[not_selector(:has(*))]:group-focus-within/tile:opacity-100 [transition:opacity_var(--neba-duration-fill)_var(--neba-ease)]'
                    : ''
                )
              : 'flex flex-col gap-0.5 pt-1.5',
            classNames?.caption
          )}
        >
          {hasContent(item.title) ? (
            <span
              className={cx(
                'truncate font-medium',
                sheetTitleClasses.sm,
                over ? '' : 'text-(--neba-fg)',
                classNames?.title
              )}
            >
              {item.title}
            </span>
          ) : null}
          {hasContent(item.description) ? (
            <span
              className={cx(
                'truncate',
                metaTextClasses.md,
                over ? 'text-white/80' : 'text-(--neba-muted-fg)',
                classNames?.description
              )}
            >
              {item.description}
            </span>
          ) : null}
        </div>
      );

      // The frame the picture is clipped to, and the only thing a `zoom` is
      // allowed to move inside.
      const framed = (
        <span
          className={cx(
            'relative block overflow-hidden',
            radius,
            layout === 'quilted' || layout === 'justified' ? 'size-full' : '',
            '[transition:box-shadow_var(--neba-duration)_var(--neba-ease)]',
            tileHoverClasses[hover]
          )}
        >
          {picture}
          {over ? legend : null}
        </span>
      );

      const body =
        over || !shown ? (
          framed
        ) : (
          <>
            {framed}
            {legend}
          </>
        );

      return (
        <li
          key={item.id ?? item.src}
          className={cx(
            'group/tile relative m-0 min-w-0 list-none',
            layout === 'justified' ? 'flex flex-col' : '',
            classNames?.item
          )}
          style={tileStyle}
        >
          {preview || onItemSelect ? (
            <button
              type="button"
              // The picture's own words, plus where it sits: a reader tabbing a
              // wall of thumbnails is told which one of how many they are on.
              aria-label={`${item.alt} — ${fill(messages.item, { index: String(index + 1), total: String(items.length) })}`}
              className={cx(
                'block w-full text-start [outline:none]',
                preview ? 'cursor-zoom-in' : 'cursor-pointer',
                // A fallback to the primary ring: the picture declares no colour family of
                // its own, and a `var()` with nothing behind it drops the whole outline.
                'focus-visible:[outline:2px_solid_var(--n-ring,var(--neba-primary-ring))] focus-visible:[outline-offset:2px]',
                radius,
                layout === 'justified' ? 'flex-1' : ''
              )}
              onClick={() => open(index)}
            >
              {body}
            </button>
          ) : (
            body
          )}
        </li>
      );
    };

    const listClasses = cx(
      'neba-gallery m-0 list-none p-0',
      layout === 'justified' ? 'neba-gallery-justified flex flex-wrap' : '',
      layout === 'masonry' ? 'flex items-start' : '',
      layout === 'grid' || layout === 'quilted' ? 'grid' : '',
      className ?? ''
    );

    const listStyle: React.CSSProperties = {
      gap: space,
      ...responsiveSlots('cols', lanes, (value) => String(Math.max(1, Math.round(value)))),
      ...(layout === 'grid' || layout === 'quilted'
        ? { gridTemplateColumns: 'repeat(var(--n-cols), minmax(0, 1fr))' }
        : null),
      ...(layout === 'quilted' ? { gridAutoRows: `${rowHeight}px`, gridAutoFlow: 'dense' } : null),
      ...style
    };

    let children: React.ReactNode;

    if (layout === 'masonry') {
      const ratios = items.map((item) => shownRatioOf(item, fallbackRatio));

      children = deal(ratios, laneCount).map((lane, index) => (
        <li
          key={index}
          // A lane is a list item holding a list, rather than a `<div>` between
          // the `<ul>` and its `<li>`s, which is markup a screen reader reads as
          // a list with nothing in it.
          className="m-0 flex min-w-0 flex-1 list-none flex-col"
          style={{ gap: space }}
        >
          <ul className="m-0 flex list-none flex-col p-0" style={{ gap: space }}>
            {lane.map((at) => tile(items[at], at, {}))}
          </ul>
        </li>
      ));
    } else if (layout === 'justified') {
      children = items.map((item, index) => {
        const each = shownRatioOf(item, fallbackRatio);

        return tile(item, index, {
          // Grown in proportion to the picture's own width, from a basis in the
          // same proportion — which is what makes every tile in a row come out
          // the same height once the row has been stretched to the edge.
          flexGrow: each,
          flexBasis: `${each * rowHeight}px`,
          maxWidth: '100%'
        });
      });
    } else {
      children = items.map((item, index) =>
        tile(
          item,
          index,
          layout === 'quilted'
            ? {
                gridColumn: `span ${Math.max(1, Math.round(item.cols ?? 1))}`,
                gridRow: `span ${Math.max(1, Math.round(item.rows ?? 1))}`
              }
            : {}
        )
      );
    }

    if (items.length === 0 && hasContent(empty)) {
      return <>{empty}</>;
    }

    return (
      <>
        <ul
          ref={ref}
          role="list"
          aria-label={label ?? messages.label}
          className={listClasses}
          style={listStyle}
          {...props}
        >
          {children}
        </ul>

        {preview ? (
          <React.Suspense fallback={null}>
            <GalleryViewer
              items={items}
              index={openAt}
              onIndexChange={setOpenAt}
              locale={locale}
              watermark={watermark}
              protect={protect}
              messages={messages}
            />
          </React.Suspense>
        ) : null}
      </>
    );
  }
);

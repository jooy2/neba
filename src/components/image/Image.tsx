'use client';

import * as React from 'react';
import { AspectRatio } from '../aspect-ratio/AspectRatio.js';
import { Skeleton } from '../skeleton/Skeleton.js';
import { cx, metaTextValues, radiusClasses, toLength } from '../../internal/styles.js';
import type { NebaAspectFit } from '../aspect-ratio/AspectRatio.js';
import type { NebaCorner, NebaElevation, NebaSize, NebaSlots } from '../../types.js';

/** The parts an Image draws behind its root. */
export type ImageSlot = 'image' | 'placeholder' | 'fallback' | 'frame' | 'watermark';

/**
 * How the picture is coloured.
 *
 * Seven names and an escape hatch: anything else a caller wants is a CSS
 * `filter` chain, and passing one through is better than growing this list
 * until it is a photo editor. `filter="hue-rotate(40deg) contrast(1.1)"` is a
 * valid value.
 */
export type NebaImageFilter =
  'none' | 'grayscale' | 'sepia' | 'invert' | 'saturate' | 'mute' | 'contrast';

/** The silhouette a frame cuts the picture to. */
export type NebaImageFrameShape = 'rect' | 'rounded' | 'circle' | 'cut' | 'arch';

export interface NebaImageFrameOptions {
  /** @default 'rounded' */
  shape?: NebaImageFrameShape;
  /**
   * How big the corner treatment is — a step of the radius ladder, a number in
   * pixels, or a CSS length. Defaults to whatever `rounded` says, and to `md`
   * when `rounded` says nothing.
   */
  corner?: NebaSize | number | string;
  /**
   * A line around the picture. `true` is a hairline; a number is its width in
   * pixels.
   *
   * Drawn as an inset shadow rather than as a `border`, which is not a detail a
   * caller can ignore: it is what lets the line follow a cut corner or a
   * circle, and what keeps it out of the layout so the picture is the size it
   * was going to be either way.
   */
  border?: boolean | number | string;
  /** What colour that line is. Defaults to the house hairline. */
  borderColor?: string;
  /**
   * The mount: space between the line and the picture, in pixels or as a CSS
   * length. This is the one part of a frame that does take room.
   */
  mat?: number | string;
  /** What fills the mount. Defaults to the page's own surface. */
  background?: string;
  /** Drop shadow depth, on the house ladder. @default 0 */
  elevation?: NebaElevation;
  /**
   * Fades the picture's edge out over this distance instead of cutting it. A
   * number in pixels, or a CSS length — `'8%'` reads well on any size of
   * picture.
   */
  feather?: number | string;
}

/**
 * A frame is either the silhouette on its own — `frame="circle"` — or the whole
 * arrangement written out. The same shape `transition` takes, for the same
 * reason: one word covers most of it, and the rest is not worth a second prop.
 */
export type NebaImageFrame = NebaImageFrameShape | NebaImageFrameOptions;

export interface NebaImageWatermarkOptions {
  /** The mark: a line of text, or a node for a logo. */
  content: React.ReactNode;
  /** Where a single mark sits. @default 'bottom-end' */
  position?: NebaCorner | 'center';
  /**
   * Tiles the mark across the whole picture instead of placing one, which is
   * the arrangement that actually deters a screenshot. Text only — a node
   * cannot be drawn into the tile, and is placed once instead.
   * @default false
   */
  repeat?: boolean;
  /** How strongly the mark shows, from 0 to 1. @default 0.35 */
  opacity?: number;
  /** Turns the mark, in degrees. @default 0, or -24 when tiled */
  rotate?: number;
  /** Type size — a step of the meta ladder, a number in pixels, or a length. */
  size?: NebaSize | number | string;
  /** Ink. Defaults to white, which is what reads over a photograph. */
  color?: string;
}

/** A line of text, or the mark written out. */
export type NebaImageWatermark = string | NebaImageWatermarkOptions;

export interface NebaImageProtection {
  /** Suppresses the right-click menu over the picture. @default true */
  contextMenu?: boolean;
  /** Stops the picture being dragged out into another window. @default true */
  drag?: boolean;
  /** Takes the picture out of a selection, and off an iOS long press. @default true */
  select?: boolean;
}

/**
 * The four fits, written out.
 *
 * Not `object-${fit}`: Tailwind only ever sees class names that are written
 * literally, so a template literal generates nothing and the picture falls back
 * to `fill` — which is the design language's rule about per-instance values in
 * its plainest form.
 */
const objectFitClasses: Record<NebaAspectFit, string> = {
  cover: 'object-cover',
  contain: 'object-contain',
  fill: 'object-fill',
  none: 'object-none'
};

/**
 * The named filters, as the CSS they stand for.
 *
 * `mute` and `saturate` are the two that are not simply the function of the
 * same name: half saturation and half again, which are the two useful ends of
 * one dial and are much easier to reach for than the numbers.
 */
const filterValues: Record<NebaImageFilter, string> = {
  none: 'none',
  grayscale: 'grayscale(1)',
  sepia: 'sepia(0.72)',
  invert: 'invert(1)',
  saturate: 'saturate(1.5)',
  mute: 'saturate(0.45)',
  contrast: 'contrast(1.25)'
};

/** Where a single mark sits, as the box that holds it rather than as an offset. */
const markPlacement: Record<NebaCorner | 'center', string> = {
  'top-start': 'items-start justify-start',
  'top-end': 'items-start justify-end',
  'bottom-start': 'items-end justify-start',
  'bottom-end': 'items-end justify-end',
  center: 'items-center justify-center'
};

/** Where a picture is in its own life. */
type Phase = 'loading' | 'loaded' | 'failed';

/**
 * The preview's dialog, fetched only if somebody turns `preview` on.
 *
 * A Dialog was most of what an Image weighed — 23.4 kB, nearly all of it Base
 * UI's own — and `preview` is off by default. A static import puts every byte
 * of that in the bundle of a page that draws a thumbnail, so this is
 * `CodeBlock`'s arrangement with the grammars, one step smaller: the chunk is
 * fetched once, after the first paint, by the pages that asked for it. What a
 * thumbnail costs is 6.5 kB now, and the other 19.8 waits to be wanted.
 */
const PreviewDialog = React.lazy(() =>
  import('../dialog/Dialog.js').then((module) => ({ default: module.Dialog }))
);

export interface ImageProps extends Omit<
  React.ComponentPropsWithoutRef<'img'>,
  'width' | 'height' | 'children'
> {
  /** Required, and required to be right. See the note on the component. */
  alt: string;
  /**
   * The proportion to hold while the file is still arriving.
   *
   * This is the whole reason to use this over an `<img>`: a picture with no
   * reserved box is a picture that pushes the page down when it lands, which is
   * the single largest source of layout shift on most sites. `'auto'` opts out
   * and lets the file decide, which is right only when the space around it can
   * absorb the jump.
   * @default 'auto'
   */
  ratio?: number | string | 'auto';
  /** How the picture fills that box. @default 'cover' */
  fit?: NebaAspectFit;
  /** Rounds the corners at this step of the radius ladder. `false` for square. */
  rounded?: NebaSize | boolean;
  /**
   * What stands in while the file is arriving. A Skeleton of the right shape by
   * default, `false` for nothing at all.
   */
  placeholder?: React.ReactNode | false;
  /**
   * What is drawn instead when the file does not arrive.
   *
   * Something rather than nothing by default: a broken image icon is the
   * browser telling the reader that the *page* is broken, and a box that says
   * what was meant to be there is a better answer than a blank space.
   */
  fallback?: React.ReactNode;
  /** Called when the file fails. Useful for swapping a `src` you control. */
  onLoadingStatusChange?: (status: Phase) => void;
  /**
   * Opens the full picture in a Dialog when it is clicked.
   *
   * The picture becomes a button when this is on, so it is reachable by
   * keyboard — an image you can only enlarge with a pointer is an image half
   * the readers cannot enlarge.
   * @default false
   */
  preview?: boolean;
  /**
   * How the picture is coloured: a named filter, or a CSS `filter` chain of
   * your own. It travels, so a `className` that changes it on hover is a
   * treatment that fades in rather than snapping.
   * @default 'none'
   */
  filter?: NebaImageFilter | (string & {});
  /**
   * How the picture is mounted: the silhouette it is cut to, and the line, the
   * mount, the shadow and the softened edge around it.
   */
  frame?: NebaImageFrame;
  /**
   * A mark drawn over the picture — a credit line, a licence, the word DRAFT.
   *
   * A deterrent and not a lock. It is on top of the picture rather than in it,
   * so anybody who opens the network tab has the file exactly as it was served;
   * what a mark stops is the copy that gets made without thinking about it.
   */
  watermark?: NebaImageWatermark;
  /**
   * Turns off the ways a picture is casually taken: the right-click menu, the
   * drag that drops a copy into another window, the iOS long press, and the
   * selection a Ctrl-A sweeps up.
   *
   * The same deterrent, and the same caveat: the file is still one request
   * away, and a reader who wants it will have it. Turning this on to protect a
   * secret is turning it on for the wrong reason.
   * @default false
   */
  protect?: boolean | NebaImageProtection;
  /** Class names for the parts behind the root. */
  classNames?: NebaSlots<ImageSlot>;
}

/** The frame written out, whichever of the two ways it was given. */
function resolveFrame(
  frame: NebaImageFrame,
  rounded: NebaSize | boolean
): Required<Pick<NebaImageFrameOptions, 'shape'>> & NebaImageFrameOptions {
  const options = typeof frame === 'string' ? { shape: frame } : frame;
  const fallback: NebaSize | false = rounded === true ? 'md' : rounded;

  return {
    shape: 'rounded',
    corner: fallback === false ? 'md' : fallback,
    ...options
  };
}

/** A corner as a CSS length, whichever of the three ways it was written. */
function cornerLength(corner: NebaSize | number | string): string {
  if (typeof corner === 'string' && corner in radiusClasses) {
    return `var(--neba-radius-${corner})`;
  }

  return toLength(corner as number | string) ?? '0px';
}

/**
 * The silhouette, as the declarations that cut it.
 *
 * `cut` is a `clip-path` and the other four are radii, which is not an
 * arbitrary split: a radius is what a browser can also apply to the inset
 * shadow standing in for the border, and a chamfer is not. Both clip whatever
 * is inside them, so a border drawn as an inset shadow follows either.
 */
function shapeStyle(shape: NebaImageFrameShape, corner: string): React.CSSProperties {
  switch (shape) {
    case 'rect':
      return { borderRadius: '0px' };
    case 'circle':
      return { borderRadius: '50%' };
    case 'arch':
      // Half the width on each top corner, which is exactly the width between
      // them, so the browser has no reason to scale the pair down.
      return { borderRadius: `50% 50% ${corner} ${corner} / 55% 55% ${corner} ${corner}` };
    case 'cut':
      return {
        clipPath: `polygon(${corner} 0, calc(100% - ${corner}) 0, 100% ${corner}, 100% calc(100% - ${corner}), calc(100% - ${corner}) 100%, ${corner} 100%, 0 calc(100% - ${corner}), 0 ${corner})`
      };
    default:
      return { borderRadius: corner };
  }
}

/**
 * The soft edge, as a mask of two gradients intersected.
 *
 * One gradient per axis rather than one radial, because a radial fades the
 * picture to an oval and what a feathered edge is is a rectangle with its sides
 * blurred. `mask-composite` is what intersects them; the `-webkit-` pair is for
 * Safari, which spells the same property with a different value name.
 */
function featherStyle(distance: string): React.CSSProperties {
  const fade = (towards: string) =>
    `linear-gradient(to ${towards}, transparent, #000 ${distance}, #000 calc(100% - ${distance}), transparent)`;
  const mask = `${fade('right')}, ${fade('bottom')}`;

  return {
    maskImage: mask,
    maskComposite: 'intersect',
    WebkitMaskImage: mask,
    WebkitMaskComposite: 'source-in'
  } as React.CSSProperties;
}

/**
 * One tile of a repeating mark, as an SVG data URI.
 *
 * A tile rather than a wall of `<span>`s: a mark dense enough to be worth
 * having is a hundred elements on a large picture, and this is one declaration
 * that costs nothing to lay out. The SVG is written in its own units against a
 * type size of 16, so the caller's `size` scales the whole tile through
 * `background-size` and no length has to be resolved to a number here.
 */
function markTile(text: string, color: string): { uri: string; width: number; height: number } {
  // How wide the mark runs, in ems. An estimate, and it decides the space
  // between copies and nothing else: anything CJK is close to a full em where
  // the Latin average is nearer 0.6.
  let ems = 0;

  for (const character of text) {
    ems += /[ᄀ-ᇿ⺀-꓏가-퟿豈-﫿︰-﹏]/.test(character) ? 1 : 0.6;
  }

  const width = Math.max(16, Math.round(16 * (ems + 2.4)));
  const height = 52;
  const escaped = text.replace(/[&<>]/g, (character) =>
    character === '&' ? '&amp;' : character === '<' ? '&lt;' : '&gt;'
  );
  const svg =
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}">` +
    `<text x="0" y="32" font-family="system-ui, sans-serif" font-size="16" fill="${color}"` +
    ` stroke="rgba(0,0,0,0.28)" stroke-width="0.6" paint-order="stroke">${escaped}</text>` +
    `</svg>`;

  return { uri: `data:image/svg+xml,${encodeURIComponent(svg)}`, width, height };
}

/**
 * A picture that holds its space, says when it is loading and says when it
 * failed.
 *
 * An `<img>` does none of those three, and each is a real defect rather than a
 * nicety: an unsized picture shoves the page down when it lands, a slow one
 * leaves a hole with no explanation, and a broken one draws the browser's own
 * torn-page glyph, which tells a reader the site is broken rather than that one
 * file is missing.
 *
 * `alt` is required by the type, which is deliberate and is the one place this
 * component is stricter than the tag it wraps. A missing `alt` and an empty one
 * mean different things — "nobody wrote this" and "this picture says nothing a
 * reader needs" — and only the second is ever correct. Being made to type
 * `alt=""` is being made to say which one you meant.
 *
 * Everything past that is opt-in and costs nothing until it is asked for:
 * `filter` is one declaration, `frame` is one element, `watermark` is one, and
 * `preview` is a chunk that is not fetched at all unless it is on.
 */
export const Image = React.forwardRef<HTMLImageElement, ImageProps>(function Image(
  {
    alt,
    ratio = 'auto',
    fit = 'cover',
    rounded = false,
    placeholder,
    fallback,
    onLoadingStatusChange,
    preview = false,
    filter = 'none',
    frame,
    watermark,
    protect = false,
    className,
    classNames,
    style,
    src,
    ...props
  },
  ref
) {
  const [phase, setPhase] = React.useState<Phase>('loading');
  const [open, setOpen] = React.useState(false);

  const pictureRef = React.useRef<HTMLImageElement | null>(null);
  const reportRef = React.useRef(onLoadingStatusChange);

  reportRef.current = onLoadingStatusChange;

  const attach = React.useCallback(
    (node: HTMLImageElement | null) => {
      pictureRef.current = node;

      if (typeof ref === 'function') {
        ref(node);
      } else if (ref) {
        ref.current = node;
      }
    },
    [ref]
  );

  /*
   * A `src` that changes is a different picture, so it starts over. Without
   * this a second file inherits the first one's "loaded" and never shows a
   * placeholder — and a second file that fails inherits a success.
   *
   * And a picture that finished before React attached its listeners is asked
   * after the fact. A data URI decodes inside the same task the element was
   * inserted in, and anything already in the cache is done before the commit,
   * so `load` is dispatched at an element nobody is listening to yet — and the
   * picture then sits at `opacity: 0` behind its own placeholder for good,
   * which is what every data-URI example in these docs was doing. `complete`
   * is the question after the fact and `naturalWidth` is which of the two
   * answers it got; an `<img>` with no `src` is `complete` too, and is the one
   * case that really is still waiting.
   */
  React.useEffect(() => {
    const node = pictureRef.current;
    const settled: Phase | null =
      src && node?.complete ? (node.naturalWidth > 0 ? 'loaded' : 'failed') : null;

    setPhase(settled ?? 'loading');

    if (settled) {
      reportRef.current?.(settled);
    }
  }, [src]);

  const settle = (next: Phase) => {
    setPhase(next);
    onLoadingStatusChange?.(next);
  };

  const radius = rounded === false ? '' : radiusClasses[rounded === true ? 'md' : rounded];
  const tint = filter in filterValues ? filterValues[filter as NebaImageFilter] : filter;

  const guard = protect === true ? {} : protect === false ? null : protect;
  const noMenu = guard !== null && guard.contextMenu !== false;
  const noDrag = guard !== null && guard.drag !== false;
  const noSelect = guard !== null && guard.select !== false;

  const stop = (event: React.SyntheticEvent) => event.preventDefault();

  /*
   * The deterrents, as the attributes that carry them.
   *
   * `-webkit-touch-callout` is the one that is not obvious and is the one that
   * matters most on a phone: without it a long press offers "Save Image" no
   * matter what the context menu was told.
   */
  const guarded = guard
    ? {
        onContextMenu: noMenu ? stop : undefined,
        onDragStart: noDrag ? stop : undefined,
        draggable: noDrag ? false : undefined,
        className: noSelect ? 'select-none' : '',
        style: noSelect ? ({ WebkitTouchCallout: 'none' } as React.CSSProperties) : undefined
      }
    : null;

  const picture = (
    <img
      ref={attach}
      src={src}
      alt={alt}
      className={cx(
        'block size-full',
        objectFitClasses[fit],
        radius,
        // Faded in rather than swapped in: a picture that appears at full
        // strength the instant it decodes is the same jolt as one that resizes.
        //
        // Its own transition rather than the house one, which is what used to be
        // here and did nothing at all: `transitionClasses` names the four
        // properties a control answers a pointer with, and `opacity` is not one
        // of them — so the fade was written down and never ran, on a `<img>` that
        // has no background, no border and no shadow to transition either.
        // A picture settles at the fill's pace rather than an edge's, because
        // what is arriving is the whole surface.
        //
        // `filter` rides along, so a treatment a caller changes on hover — the
        // grey thumbnail that comes back to life under the pointer — travels
        // rather than snapping.
        '[transition:opacity_var(--neba-duration-fill)_var(--neba-ease),filter_var(--neba-duration-fill)_var(--neba-ease)]',
        phase === 'loaded' ? 'opacity-100' : 'opacity-0',
        guarded?.className,
        classNames?.image
      )}
      style={{ filter: tint === 'none' ? undefined : tint, ...guarded?.style }}
      onLoad={() => settle('loaded')}
      onError={() => settle('failed')}
      onContextMenu={guarded?.onContextMenu}
      onDragStart={guarded?.onDragStart}
      draggable={guarded?.draggable}
      {...props}
    />
  );

  const cover =
    phase === 'failed' ? (
      <span
        className={cx(
          'absolute inset-0 flex items-center justify-center',
          'bg-(--neba-disabled-bg) text-(--neba-muted-fg)',
          radius,
          classNames?.fallback
        )}
      >
        {fallback ?? <span className="px-2 text-center text-sm">{alt || 'Image unavailable'}</span>}
      </span>
    ) : phase === 'loading' && placeholder !== false ? (
      <span className={cx('absolute inset-0', classNames?.placeholder)}>
        {placeholder ?? <Skeleton shape="rect" className={cx('size-full', radius)} />}
      </span>
    ) : null;

  const mark = watermark === undefined ? null : renderMark(watermark, classNames?.watermark);

  // One stack — the picture with whatever is standing over it — wrapped either
  // in a box that holds a proportion or in one that does not.
  const stack = (
    <span className="relative block size-full">
      {picture}
      {cover}
      {mark}
    </span>
  );

  const shape = frame === undefined ? null : resolveFrame(frame, rounded);
  const corner = shape === null ? '0px' : cornerLength(shape.corner ?? 'md');
  const mat = shape === null ? undefined : toLength(shape.mat);
  const feather = shape === null ? undefined : toLength(shape.feather);

  const boxStyle: React.CSSProperties = {
    ...(shape === null ? null : shapeStyle(shape.shape, corner)),
    ...(feather === undefined ? null : featherStyle(feather)),
    ...(shape === null ? style : null)
  };

  const framed =
    ratio === 'auto' ? (
      <span
        className={cx(
          'relative block overflow-hidden',
          shape === null ? radius : '',
          shape === null ? className : ''
        )}
        style={boxStyle}
      >
        {stack}
      </span>
    ) : (
      // `fit` is already on the `<img>`; AspectRatio's own is for a direct
      // child, and the stack is in the way.
      <AspectRatio
        ratio={ratio}
        className={cx(
          'overflow-hidden',
          shape === null ? radius : '',
          shape === null ? className : ''
        )}
        style={boxStyle}
      >
        {stack}
      </AspectRatio>
    );

  /*
   * The mount, when there is one: the line, the space inside it, and the
   * shadow. Only drawn for a caller who asked for a frame — an Image without
   * one is exactly the two elements it has always been.
   */
  const line = shape === null ? undefined : mountLine(shape);
  const outerCorner = mat === undefined ? corner : `calc(${corner} + ${mat})`;

  /*
   * The mount, when there is one: the line, the space inside it, and the
   * shadow. Only drawn for a caller who asked for a frame — an Image without
   * one is exactly the two elements it has always been.
   *
   * The line is a layer over the picture rather than an inset shadow on the
   * box, because an inset shadow paints under the box's own content: on a frame
   * with no `mat` the picture covers the whole element, and a line drawn behind
   * it is a line nobody sees. Over the top it lands on the outermost edge,
   * which is where a frame's line belongs — around the mount, not inside it.
   */
  const mounted =
    shape === null ? (
      framed
    ) : (
      <span
        className={cx('relative block', classNames?.frame, className)}
        style={{
          ...shapeStyle(shape.shape, outerCorner),
          padding: mat,
          background: shape.background ?? (mat === undefined ? undefined : 'var(--neba-surface)'),
          boxShadow: shape.elevation ? `var(--neba-shadow-${shape.elevation})` : undefined,
          ...style
        }}
      >
        {framed}
        {line === undefined ? null : (
          <span
            aria-hidden="true"
            className="pointer-events-none absolute inset-0"
            style={{ ...shapeStyle(shape.shape, outerCorner), boxShadow: line }}
          />
        )}
      </span>
    );

  if (!preview) {
    return mounted;
  }

  return (
    <>
      <button
        type="button"
        // The accessible name is the picture's own: two names for one thing is
        // a screen reader reading the same sentence twice.
        aria-label={alt}
        className={cx(
          'block w-full cursor-zoom-in [outline:none]',
          'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:2px]',
          radius
        )}
        onClick={() => setOpen(true)}
      >
        {mounted}
      </button>

      <React.Suspense fallback={null}>
        <PreviewDialog open={open} onOpenChange={setOpen} size="xl" title={alt}>
          <span className="relative mx-auto block w-fit">
            <img
              src={src}
              alt={alt}
              className={cx('mx-auto block max-h-[70vh] w-auto max-w-full', guarded?.className)}
              style={{ filter: tint === 'none' ? undefined : tint, ...guarded?.style }}
              onContextMenu={guarded?.onContextMenu}
              onDragStart={guarded?.onDragStart}
              draggable={guarded?.draggable}
            />
            {mark}
          </span>
        </PreviewDialog>
      </React.Suspense>
    </>
  );
});

/** The frame's line, as the inset shadow that draws it — or nothing. */
function mountLine(shape: NebaImageFrameOptions): string | undefined {
  if (shape.border === undefined || shape.border === false) return undefined;

  const width = shape.border === true ? '1px' : toLength(shape.border);

  return `inset 0 0 0 ${width} ${shape.borderColor ?? 'var(--neba-line)'}`;
}

/** The mark, placed once or tiled, whichever of the two ways it was given. */
function renderMark(watermark: NebaImageWatermark, slot: string | undefined) {
  const options: NebaImageWatermarkOptions =
    typeof watermark === 'string' ? { content: watermark } : watermark;
  const {
    content,
    position = 'bottom-end',
    repeat = false,
    opacity = 0.35,
    size = 'xs',
    color = '#ffffff'
  } = options;
  const fontSize =
    typeof size === 'string' && size in metaTextValues
      ? metaTextValues[size as NebaSize]
      : (toLength(size as number | string) ?? metaTextValues.xs);
  const rotate = options.rotate ?? (repeat && typeof content === 'string' ? -24 : 0);

  if (repeat && typeof content === 'string') {
    const tile = markTile(content, color);

    return (
      <span
        aria-hidden="true"
        className={cx('pointer-events-none absolute select-none', slot)}
        // Bigger than the box and turned, so the tiling has no seam where the
        // rotation runs out. The box it sits in already clips.
        style={{
          inset: '-40%',
          opacity,
          transform: `rotate(${rotate}deg)`,
          backgroundImage: `url("${tile.uri}")`,
          backgroundSize: `calc(${fontSize} * ${tile.width / 16}) calc(${fontSize} * ${tile.height / 16})`
        }}
      />
    );
  }

  return (
    <span
      aria-hidden="true"
      className={cx(
        'pointer-events-none absolute inset-0 flex select-none p-2',
        markPlacement[position],
        slot
      )}
    >
      <span
        // The one turn the no-transform rule does not cover, because this is a
        // mark on a photograph rather than a control: nothing here is pressed,
        // and nothing here is read twice.
        style={{
          color,
          opacity,
          fontSize,
          lineHeight: 1.2,
          textShadow: '0 1px 2px rgba(0, 0, 0, 0.45)',
          transform: rotate ? `rotate(${rotate}deg)` : undefined
        }}
      >
        {content}
      </span>
    </span>
  );
}

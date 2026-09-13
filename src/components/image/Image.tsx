'use client';

import * as React from 'react';
import { AspectRatio } from '../aspect-ratio/AspectRatio.js';
import { Skeleton } from '../skeleton/Skeleton.js';
import { useStyleDefaults } from '../../internal/defaults.js';
import { imageMessages, useMessages } from '../../internal/i18n.js';
import { cx, metaTextValues, radiusClasses, toLength } from '../../internal/styles.js';
import type { NebaAspectFit } from '../aspect-ratio/AspectRatio.js';
import type { NebaCorner, NebaElevation, NebaSide, NebaSize, NebaSlots } from '../../types.js';

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

/**
 * How far the picture is turned, clockwise, in degrees.
 *
 * Quarter turns and nothing between them. A picture turned by anything else no
 * longer covers its own box, and filling the corners that leaves means
 * enlarging it by an amount a caller would then want to tune — which is a photo
 * editor, and the same line `filter` draws.
 */
export type NebaImageRotation = 0 | 90 | 180 | 270;

/**
 * Which way the picture is mirrored, along the axes it is shown on — so
 * `horizontal` swaps left and right whatever `rotate` has done to it.
 */
export type NebaImageFlip = 'none' | 'horizontal' | 'vertical' | 'both';

/**
 * Where the picture sits in its box, spelled the way `object-position` spells
 * it: a side, a corner, the centre, or two percentages across and down.
 *
 * Physical rather than logical, and on purpose. `NebaCorner` says `top-start`
 * because a mark placed on a page belongs to the page's writing direction; the
 * subject of a photograph is on the left of it in every language, so a crop
 * that keeps it must not move to the other side on a right-to-left page.
 */
export type NebaImagePosition =
  | 'center'
  | NebaSide
  | 'top left'
  | 'top right'
  | 'bottom left'
  | 'bottom right'
  | `${number}% ${number}%`;

/**
 * What fills the part of the box a picture leaves empty.
 *
 * `blur` is the picture itself, covering the box and blurred behind it — what a
 * video player does with a portrait clip in a landscape frame, and the one fill
 * that never reads as a gap. Any other string is a CSS `background`.
 */
export type NebaImageLetterbox = 'none' | 'blur';

/** The silhouette a frame cuts the picture to. */
export type NebaImageFrameShape = 'rect' | 'rounded' | 'circle' | 'cut' | 'arch';

/**
 * A picture to stand in while the file arrives, rather than a Skeleton.
 *
 * Drawn the way the picture will be — the same `fit`, `position`, `rotate`
 * and `flip` — which is what it is for: a small copy of the same file, a few
 * hundred bytes inlined as a data URI or already in memory as a `Blob`, so the
 * reader sees the picture's colours and shape before its detail.
 */
export interface NebaImagePlaceholderOptions {
  /**
   * The stand-in: a URL, a data URI, or a `Blob`. A Blob is turned into an
   * object URL for as long as it is shown and released when it is not.
   */
  src: string | Blob;
  /**
   * Blurs the stand-in, by this many pixels or by 20 for `true` — a copy
   * stretched up from a few pixels is blocky without it.
   * @default false
   */
  blur?: boolean | number;
}

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
 * The five fits, written out.
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
  none: 'object-none',
  'scale-down': 'object-scale-down'
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
/**
 * The spelling React accepts for the `fetchpriority` attribute.
 *
 * React 19 knows it as `fetchPriority` and warns about the lower-case form;
 * React 18 does not know it at all, and warns about the camel-case one while
 * writing it anyway. The attribute is the same either way, so this only decides
 * which of the two supported versions stays quiet.
 */
const FETCH_PRIORITY = Number.parseInt(React.version, 10) >= 19 ? 'fetchPriority' : 'fetchpriority';

const PreviewDialog = React.lazy(() =>
  import('../dialog/Dialog.js').then((module) => ({ default: module.Dialog }))
);

export interface ImageProps extends Omit<React.ComponentPropsWithoutRef<'img'>, 'children'> {
  /** Required, and required to be right. See the note on the component. */
  alt: string;
  /**
   * The proportion to hold while the file is still arriving.
   *
   * This is the whole reason to use this over an `<img>`: a picture with no
   * reserved box is a picture that pushes the page down when it lands, which is
   * the single largest source of layout shift on most sites. `'auto'` lets the
   * file decide — and `width` and `height` are how you tell it what the file
   * will say, so the box is right before anything has arrived.
   * @default 'auto'
   */
  ratio?: number | string | 'auto';
  /**
   * The file's own pixel dimensions, as an `<img>` takes them — or, given one
   * at a time, the size of the box.
   *
   * Together they are the platform's own answer to layout shift, and they are
   * what to reach for when the proportion is the picture's rather than the
   * layout's: `ratio` says "hold this shape whatever arrives", these two say
   * "this is what will arrive". Give both and an `'auto'` ratio becomes their
   * proportion, so the box is reserved without anybody working out that 1200 by
   * 800 is 3/2.
   *
   * One on its own is not a proportion, so it is read as the length it looks
   * like. `height={200}` is a box 200 pixels tall across whatever width it is
   * given, and `width={320}` is one 320 wide — never wider than its container —
   * and as tall as the picture makes it. A number is pixels and a string is a
   * CSS length, and `fit` decides what the picture does inside. With a `ratio`
   * as well, a lone `height` takes its width from the ratio.
   *
   * They reach the `<img>` either way.
   */
  width?: number | string;
  height?: number | string;
  /** How the picture fills that box. @default 'cover' */
  fit?: NebaAspectFit;
  /**
   * Where the picture sits in that box: which part survives a `cover` crop, and
   * where `contain`, `none` and `scale-down` leave their empty space.
   *
   * Read on the picture as it is shown, so it holds through `rotate` and
   * `flip` — `position="top"` keeps the top of what the reader sees, not the
   * top of the file.
   * @default 'center'
   */
  position?: NebaImagePosition;
  /**
   * What fills the box where `contain`, `none` or `scale-down` leave it empty:
   * `blur` for the picture itself, blurred and covering the box behind it, or a
   * CSS `background` — a colour, a token, a gradient.
   *
   * The blurred copy is the same file, so it is not a second download, and it
   * is only drawn under a `fit` that can leave space; under `cover` and `fill`
   * there is nothing for it to show through.
   * @default 'none'
   */
  letterbox?: NebaImageLetterbox | (string & {});
  /** Rounds the corners at this step of the radius ladder. `false` for square. */
  rounded?: NebaSize | boolean;
  /**
   * What stands in while the file is arriving. A Skeleton of the right shape by
   * default, a node of your own, `{ src }` for a picture — a small copy of the
   * same file, as a URL or a `Blob` — or `false` for nothing at all.
   *
   * Like the Skeleton, a stand-in fills the box, so it needs one to fill: a
   * `ratio`, or `width` and `height`.
   */
  placeholder?: React.ReactNode | false | NebaImagePlaceholderOptions;
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
   * Marks the picture a page is judged by — usually the largest thing above
   * the fold, which is what Largest Contentful Paint measures — so it is
   * fetched early and never lazily: `loading="eager"` and a high fetch
   * priority.
   *
   * Everything else about when a picture loads belongs to the `<img>` and
   * passes straight through: `loading="lazy"` for one below the fold,
   * `decoding`, `fetchPriority`. An attribute written out wins over what this
   * implies.
   * @default false
   */
  priority?: boolean;
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
   * Turns the picture clockwise, a quarter at a time.
   *
   * A picture on its side is laid out on its side: `width` and `height` still
   * describe the file, so `width={1200} height={800} rotate={90}` reserves a
   * box two wide by three tall, and a `ratio` of `'auto'` with neither takes
   * the turned shape once the file has said what it is. An explicit `ratio` is
   * the layout's and is kept, with `fit` deciding how the turned picture fills
   * it.
   * @default 0
   */
  rotate?: NebaImageRotation;
  /**
   * Mirrors the picture, along the axes it is shown on. The two props commute
   * as a reader sees them: `flip="horizontal"` swaps left and right on the
   * screen whether or not the picture has been turned.
   * @default 'none'
   */
  flip?: NebaImageFlip;
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
  /**
   * Which language the picture names its own absence in — a BCP 47 tag such as
   * `ko`, `pt-BR` or `zh-Hant`. Unsupported tags fall back to English.
   *
   * It is read for one string, and only when a file fails and there is no `alt`
   * to put in its place. `unavailableLabel` writes the words out instead.
   */
  locale?: string;
  /**
   * What the box says when the file does not arrive and `alt` is empty.
   * Defaults to the `locale`'s wording.
   */
  unavailableLabel?: string;
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

/** The file's own pixel dimensions, once something has said what they are. */
interface PixelSize {
  width: number;
  height: number;
}

/**
 * The file two `<img>` dimensions describe, or `null` where they do not.
 *
 * They arrive as `number | string` because that is what the attribute takes, so
 * `'1200'` counts and `'50%'` does not — a percentage is a length and says
 * nothing about the shape. One without the other says nothing either.
 */
function pixelSize(width?: number | string, height?: number | string): PixelSize | null {
  const w = typeof width === 'number' ? width : Number(width);
  const h = typeof height === 'number' ? height : Number(height);

  return Number.isFinite(w) && Number.isFinite(h) && w > 0 && h > 0
    ? { width: w, height: h }
    : null;
}

/**
 * A lone `width` or `height` as the length it sizes the box to: a number, or a
 * string of digits the way the attribute is written, is pixels, and anything
 * else is already a CSS length.
 */
function boxLength(value: number | string): string {
  const pixels = typeof value === 'number' ? value : value.trim() === '' ? NaN : Number(value);

  return Number.isFinite(pixels) ? `${pixels}px` : String(value);
}

/**
 * A turn as a count of quarters, whatever number arrived.
 *
 * The type holds a TypeScript caller to the four; this is for everyone else,
 * so `-90` is the `270` it means and `45` is the nearest quarter rather than a
 * picture that no longer covers its box.
 */
function quartersOf(rotate: number): 0 | 1 | 2 | 3 {
  if (!Number.isFinite(rotate)) {
    return 0;
  }

  return (((Math.round(rotate / 90) % 4) + 4) % 4) as 0 | 1 | 2 | 3;
}

/** One `<position>` component written as a percentage. */
const PERCENTAGE = /^(-?\d*\.?\d+)%$/;

/**
 * A position as fractions across and down, or `null` for anything past the
 * keywords and percentages the type offers — a length has no fraction to turn.
 *
 * The part of CSS's grammar a caller writes: a keyword says its own axis, and a
 * percentage is across when it comes first and down when it comes second.
 */
function positionFractions(position: string): [number, number] | null {
  let across = 0.5;
  let down = 0.5;

  for (const [index, word] of position.trim().toLowerCase().split(/\s+/).entries()) {
    const percentage = PERCENTAGE.exec(word);

    if (word === 'left' || word === 'right') {
      across = word === 'left' ? 0 : 1;
    } else if (word === 'top' || word === 'bottom') {
      down = word === 'top' ? 0 : 1;
    } else if (percentage !== null) {
      if (index === 0) {
        across = Number(percentage[1]) / 100;
      } else {
        down = Number(percentage[1]) / 100;
      }
    } else if (word !== 'center') {
      return null;
    }
  }

  return [across, down];
}

/**
 * A position read on the picture as it is shown, as the `object-position` of
 * the element that is actually turned and mirrored.
 *
 * `object-position` is laid out in the element's own frame, before its
 * transforms, so `top` on a picture turned upside down would keep what ends up
 * at the bottom. The mirror is undone first because it is applied on the
 * screen's axes, after the turn; then the turn, a quarter at a time. What comes
 * back is always percentages, which also makes it one spelling in every engine
 * — a string nothing could parse is handed through as it was written.
 */
function objectPosition(position: string, quarters: 0 | 1 | 2 | 3, flip: NebaImageFlip): string {
  const fractions = positionFractions(position);

  if (fractions === null) {
    return position;
  }

  let [across, down] = fractions;

  if (flip === 'horizontal' || flip === 'both') {
    across = 1 - across;
  }

  if (flip === 'vertical' || flip === 'both') {
    down = 1 - down;
  }

  for (let turn = 0; turn < quarters; turn += 1) {
    // One quarter clockwise draws the element's left edge along the top of the
    // screen, so what is across on the screen was down the element.
    [across, down] = [down, 1 - across];
  }

  const percent = (fraction: number) => `${Math.round(fraction * 10000) / 100}%`;

  return `${percent(across)} ${percent(down)}`;
}

/**
 * How far the blurred letterbox is blurred, and how far past the box it is
 * drawn. A blur fades to transparent over about two radii at the element's
 * edge, so the copy is grown by that much on every side and the box clips the
 * fringe off rather than showing the page through it.
 */
const LETTERBOX_BLUR = 24;

/** How far a stand-in with `blur: true` is blurred. */
const PLACEHOLDER_BLUR = 20;

/** Whether a placeholder is a picture to draw rather than a node to render. */
function isPlaceholderPicture(
  placeholder: React.ReactNode | NebaImagePlaceholderOptions
): placeholder is NebaImagePlaceholderOptions {
  return (
    typeof placeholder === 'object' &&
    placeholder !== null &&
    !React.isValidElement(placeholder) &&
    'src' in placeholder
  );
}

/**
 * A URL for a stand-in, whichever of the two it was given as.
 *
 * A Blob becomes an object URL in an effect rather than during the render: an
 * object URL is an allocation the document holds until it is revoked, and a
 * render React throws away would leave one behind that nothing could release.
 * The cost is a stand-in that appears a frame after the box, which is sooner
 * than any file it stands in for.
 */
function useObjectUrl(source: string | Blob | undefined): string | undefined {
  // Kept with the Blob it was made from, so a URL for the last Blob is never
  // handed out for the next one in the render before the effect has caught up.
  const [made, setMade] = React.useState<{ blob: Blob; url: string } | null>(null);

  React.useEffect(() => {
    if (typeof Blob === 'undefined' || !(source instanceof Blob)) {
      return undefined;
    }

    const url = URL.createObjectURL(source);

    // The object URL is the external system here: it is allocated in the one
    // place that can release it, and the state only carries it to the render.
    // It runs once per Blob rather than cascading.
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setMade({ blob: source, url });

    return () => URL.revokeObjectURL(url);
  }, [source]);

  if (typeof source === 'string') {
    return source;
  }

  return made !== null && made.blob === source ? made.url : undefined;
}

/**
 * The geometry of a copy of the picture drawn under it: the same turn, the same
 * mirror, and the same box grown by `bleed` on every side.
 */
function layerStyle(
  pose: React.CSSProperties,
  sideways: boolean,
  bleed: number
): React.CSSProperties {
  const grown = (length: string) => (bleed === 0 ? length : `calc(${length} + ${bleed * 2}px)`);

  if (sideways) {
    return { ...pose, width: grown('100cqh'), height: grown('100cqw') };
  }

  return {
    ...pose,
    position: 'absolute',
    top: `${-bleed}px`,
    left: `${-bleed}px`,
    width: grown('100%'),
    height: grown('100%'),
    maxWidth: 'none'
  };
}

/**
 * The turn and the mirror, as the declarations that draw them.
 *
 * The individual `rotate` and `scale` properties rather than `transform`, which
 * leaves `transform` to whoever else wants the picture — a Gallery's zoom is a
 * `transform` class, and an inline `transform` here would silently beat it.
 * They also compose in a fixed order, scale first: so on a quarter turn a
 * mirror along the screen's axis is a mirror along the picture's other one,
 * and the two are swapped here rather than making a caller think about it.
 *
 * On its side the picture is laid out at the box's height by the box's width
 * and turned into place, which is what lets `fit` work at all — `object-fit`
 * fits the element's own box, and a picture turned inside the box it was given
 * would overhang it on one axis and fall short on the other. The container
 * units read the stack the picture sits in; `maxWidth` is cleared because every
 * reset caps an `<img>` at the width of its parent, which on a tall box is
 * narrower than the length the turned picture needs.
 */
function poseStyle(quarters: 0 | 1 | 2 | 3, flip: NebaImageFlip): React.CSSProperties {
  const sideways = quarters % 2 === 1;
  const acrossX = flip === 'horizontal' || flip === 'both';
  const acrossY = flip === 'vertical' || flip === 'both';
  const mirrorX = sideways ? acrossY : acrossX;
  const mirrorY = sideways ? acrossX : acrossY;

  return {
    scale: mirrorX || mirrorY ? `${mirrorX ? -1 : 1} ${mirrorY ? -1 : 1}` : undefined,
    rotate: quarters === 0 ? undefined : `${quarters * 90}deg`,
    ...(sideways
      ? {
          position: 'absolute',
          top: '50%',
          left: '50%',
          width: '100cqh',
          height: '100cqw',
          maxWidth: 'none',
          translate: '-50% -50%'
        }
      : null)
  };
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
export const Image = React.forwardRef<HTMLImageElement, ImageProps>(function Image(rawProps, ref) {
  const {
    alt,
    ratio: ratioProp = 'auto',
    width,
    height,
    fit = 'cover',
    position,
    letterbox = 'none',
    rounded = false,
    placeholder,
    fallback,
    onLoadingStatusChange,
    preview = false,
    priority = false,
    filter = 'none',
    rotate = 0,
    flip = 'none',
    frame,
    watermark,
    protect = false,
    locale,
    unavailableLabel,
    className,
    classNames,
    style,
    src,
    ...props
  } = useStyleDefaults(rawProps, ['locale']);

  const messages = useMessages(imageMessages, locale);
  const stand = placeholder !== false && isPlaceholderPicture(placeholder) ? placeholder : null;
  const standSrc = useObjectUrl(stand?.src);
  const [phase, setPhase] = React.useState<Phase>('loading');
  const [open, setOpen] = React.useState(false);
  /*
   * What the file turned out to be, kept for the one layout that cannot know it
   * in advance: a picture on its side with nothing to say its shape, whose box
   * is the file's height by its width. Set beside the phase, so a load is still
   * one render.
   */
  const [natural, setNatural] = React.useState<PixelSize | null>(null);

  const pictureRef = React.useRef<HTMLImageElement | null>(null);
  /*
   * The newest handler, kept for the effect below rather than closed over —
   * that effect runs when `src` changes and nothing else, and a handler listed
   * beside it would restart the picture every time a caller wrote one inline.
   *
   * Written in an effect and not during the render, which is the rule
   * `useShortcut` states: a ref written while rendering is a ref that lies if
   * React throws that render away. Declared above the effect that reads it, so
   * the newest value is in place before it runs.
   */
  const reportRef = React.useRef(onLoadingStatusChange);

  React.useEffect(() => {
    reportRef.current = onLoadingStatusChange;
  });

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
    setNatural(
      settled === 'loaded' && node ? { width: node.naturalWidth, height: node.naturalHeight } : null
    );

    if (settled) {
      reportRef.current?.(settled);
    }
  }, [src]);

  const settle = (next: Phase, node: HTMLImageElement) => {
    setPhase(next);

    if (next === 'loaded') {
      setNatural({ width: node.naturalWidth, height: node.naturalHeight });
    }

    onLoadingStatusChange?.(next);
  };

  const radius = rounded === false ? '' : radiusClasses[rounded === true ? 'md' : rounded];
  const tint = filter in filterValues ? filterValues[filter as NebaImageFilter] : filter;

  const guard = protect === true ? {} : protect === false ? null : protect;
  const noMenu = guard !== null && guard.contextMenu !== false;
  const noDrag = guard !== null && guard.drag !== false;
  const noSelect = guard !== null && guard.select !== false;

  const stop = (event: React.SyntheticEvent) => event.preventDefault();

  const quarters = quartersOf(rotate);
  const sideways = quarters % 2 === 1;
  const pose = poseStyle(quarters, flip);
  const placed = position === undefined ? undefined : objectPosition(position, quarters, flip);
  /*
   * The blurred letterbox, drawn only where it can show: `cover` and `fill`
   * leave no space around the picture. What it is drawn from has to be exactly
   * what the picture is drawn from — the same candidate out of a `srcSet`, the
   * same CORS mode — or it would be a second request for a file already on its
   * way.
   */
  const blurred = letterbox === 'blur' && fit !== 'cover' && fit !== 'fill';
  const painted = letterbox !== 'none' && letterbox !== 'blur' ? letterbox : undefined;

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
      width={width}
      height={height}
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
        // Positioned, so it paints over the absolutely positioned copy under it
        // rather than beneath it.
        blurred || stand !== null ? 'relative' : '',
        guarded?.className,
        classNames?.image
      )}
      style={{
        filter: tint === 'none' ? undefined : tint,
        objectPosition: placed,
        ...pose,
        ...guarded?.style
      }}
      onLoad={(event) => settle('loaded', event.currentTarget)}
      onError={(event) => settle('failed', event.currentTarget)}
      onContextMenu={guarded?.onContextMenu}
      onDragStart={guarded?.onDragStart}
      draggable={guarded?.draggable}
      {...(priority
        ? ({
            loading: 'eager',
            [FETCH_PRIORITY]: 'high'
          } as React.ImgHTMLAttributes<HTMLImageElement>)
        : null)}
      {...props}
    />
  );

  const backdrop = blurred ? (
    <img
      src={src}
      srcSet={props.srcSet}
      sizes={props.sizes}
      loading={props.loading}
      decoding={props.decoding}
      crossOrigin={props.crossOrigin}
      referrerPolicy={props.referrerPolicy}
      alt=""
      aria-hidden="true"
      draggable={false}
      className={cx(
        'pointer-events-none block object-cover select-none',
        '[transition:opacity_var(--neba-duration-fill)_var(--neba-ease)]',
        phase === 'loaded' ? 'opacity-100' : 'opacity-0'
      )}
      style={{
        ...layerStyle(pose, sideways, LETTERBOX_BLUR * 2),
        objectPosition: placed,
        filter: `${tint === 'none' ? '' : `${tint} `}blur(${LETTERBOX_BLUR}px)`
      }}
    />
  ) : null;

  const standBlur =
    stand === null || !stand.blur ? 0 : stand.blur === true ? PLACEHOLDER_BLUR : stand.blur;

  /*
   * The picture stand-in, under the picture rather than over it: the picture
   * fades in on top of it, and it is taken away only once that fade has run, so
   * the two are never both half there with the page showing through. Gone
   * entirely when the file fails, since the fallback says that instead.
   */
  const standIn =
    stand === null || phase === 'failed' || standSrc === undefined ? null : (
      <img
        src={standSrc}
        alt=""
        aria-hidden="true"
        draggable={false}
        className={cx(
          'pointer-events-none block select-none',
          objectFitClasses[fit],
          phase === 'loaded'
            ? 'opacity-0 [transition:opacity_0ms_linear_var(--neba-duration-fill)]'
            : 'opacity-100',
          classNames?.placeholder
        )}
        style={{
          ...layerStyle(pose, sideways, standBlur * 2),
          objectPosition: placed,
          filter: standBlur === 0 ? undefined : `blur(${standBlur}px)`
        }}
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
        {fallback ?? (
          <span className="px-2 text-center text-sm">
            {alt || unavailableLabel || messages.unavailable}
          </span>
        )}
      </span>
    ) : phase === 'loading' && placeholder !== false && stand === null ? (
      <span className={cx('absolute inset-0', classNames?.placeholder)}>
        {(placeholder as React.ReactNode) ?? (
          <Skeleton shape="rect" className={cx('size-full', radius)} />
        )}
      </span>
    ) : null;

  const mark = watermark === undefined ? null : renderMark(watermark, classNames?.watermark);

  // One stack — the picture with whatever is standing over it — wrapped either
  // in a box that holds a proportion or in one that does not.
  const stack = (
    <span
      className="relative block size-full"
      // What the turned picture's container units read, and the letterbox's
      // paint. Containment only on its side: it is a change to how the stack is
      // measured, and nothing else needs it.
      style={
        sideways || painted !== undefined
          ? { containerType: sideways ? 'size' : undefined, background: painted }
          : undefined
      }
    >
      {backdrop}
      {standIn}
      {picture}
      {cover}
      {mark}
    </span>
  );

  /*
   * `width` and `height` are what the file will be, so together they are a
   * proportion — and a proportion known before the file arrives is a box that
   * does not move when it does. `'auto'` means "the picture's own shape", and
   * these two are the picture's own shape stated in advance rather than
   * discovered on load; an explicit `ratio` is the layout's shape and outranks
   * them.
   */
  const file = pixelSize(width, height);
  const declared = ratioProp === 'auto' && file !== null ? file.width / file.height : null;
  const ratio = declared === null ? ratioProp : sideways ? 1 / declared : declared;
  /*
   * A picture on its side with nothing declared is out of the flow, so nothing
   * holds the box open — and the box has to be the file's height by its width,
   * which only the file knows. It is written onto the box that is already there
   * rather than by swapping it for an AspectRatio, which would remount the
   * picture the moment it arrived.
   */
  /*
   * One dimension on its own is not a proportion, so it sizes the box on its
   * axis instead, and `fit` decides what the picture does inside. A lone height
   * leaves the width to the container, unless a `ratio` can say what it is; a
   * lone width is capped at the container's, the way a reset caps an `<img>`.
   */
  const loneWidth = height === undefined && width !== undefined ? boxLength(width) : undefined;
  const loneHeight = width === undefined && height !== undefined ? boxLength(height) : undefined;
  const sized: React.CSSProperties | null =
    loneWidth !== undefined
      ? { width: loneWidth, maxWidth: '100%' }
      : loneHeight !== undefined
        ? { height: loneHeight, ...(ratio === 'auto' ? null : { width: 'auto', maxWidth: '100%' }) }
        : null;
  // Whether the box is narrower than the container, which a frame and a
  // preview button around it then have to shrink to rather than stretch past.
  const narrowed = loneWidth !== undefined || (loneHeight !== undefined && ratio !== 'auto');

  const measured =
    ratio === 'auto' && sideways && natural !== null && loneHeight === undefined
      ? natural.height / natural.width
      : null;

  const shape = frame === undefined ? null : resolveFrame(frame, rounded);
  const corner = shape === null ? '0px' : cornerLength(shape.corner ?? 'md');
  const mat = shape === null ? undefined : toLength(shape.mat);
  const feather = shape === null ? undefined : toLength(shape.feather);

  const boxStyle: React.CSSProperties = {
    ...sized,
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
        style={measured === null ? boxStyle : { aspectRatio: measured, ...boxStyle }}
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
          width: narrowed ? 'fit-content' : undefined,
          maxWidth: narrowed ? '100%' : undefined,
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
          'block cursor-zoom-in [outline:none]',
          narrowed ? 'w-fit max-w-full' : 'w-full',
          'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:2px]',
          radius
        )}
        onClick={() => setOpen(true)}
      >
        {mounted}
      </button>

      <React.Suspense fallback={null}>
        <PreviewDialog open={open} onOpenChange={setOpen} size="xl" title={alt}>
          <span
            className={cx('relative mx-auto block', sideways ? '' : 'w-fit')}
            style={sideways ? turnedPreviewStyle(natural ?? file) : undefined}
          >
            <img
              src={src}
              alt={alt}
              className={cx(
                sideways ? 'block object-contain' : 'mx-auto block max-h-[70vh] w-auto max-w-full',
                guarded?.className
              )}
              style={{ filter: tint === 'none' ? undefined : tint, ...pose, ...guarded?.style }}
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

/**
 * The preview's box for a picture on its side.
 *
 * An `<img>` sized by its own content cannot be turned in place: it keeps the
 * footprint of the file, so a portrait turned onto its side would spill out of
 * the dialog sideways and leave a hole above and below. The box is the turned
 * shape instead, capped at the width the dialog has, at the file's own size and
 * at the height the unturned preview is allowed — so it is never enlarged past
 * what the file holds. A file nothing has measured yet gets a square, which
 * `contain` fills correctly whatever arrives.
 */
function turnedPreviewStyle(file: PixelSize | null): React.CSSProperties {
  if (file === null) {
    return { aspectRatio: '1', width: 'min(100%, 70vh)', containerType: 'size' };
  }

  const across = file.height / file.width;

  return {
    aspectRatio: `${file.height} / ${file.width}`,
    width: `min(100%, ${file.height}px, calc(70vh * ${across}))`,
    containerType: 'size'
  };
}

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

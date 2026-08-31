'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { initialsOf } from '../../internal/initials.js';
import {
  controlHeightClasses,
  controlSlots,
  controlSquareClasses,
  cx,
  gapClasses,
  hasContent,
  srOnlyClasses,
  surfaceClasses,
  toLength,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaColor, NebaElevation, NebaSize, NebaVariant } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/**
 * How the artwork is *framed*, which is the one question this component exists
 * to answer.
 *
 * - `bare` — drawn as it was given, at the height `size` asks for and whatever
 *   width that comes to. No plate, no crop, no padding. This is the default,
 *   and it is the only one that is correct for a logo that was drawn with its
 *   own background, its own margin, or the product's name set into it.
 * - `app` — an app icon: a filled tile with the artwork inset in it and the
 *   corners cut off. What a mark that was drawn as a bare glyph needs before it
 *   can sit next to anything else.
 * - `circle` — the same tile, round. For the products whose icon is a disc.
 *
 * There is no `square`. A tile with the corners left on is the one shape the
 * design language does not draw, and an `app` icon at a small size is already
 * so close to a square that a fourth value would be a value nobody could see.
 */
export type AppLogoShape = 'bare' | 'app' | 'circle';

export interface AppLogoProps extends Omit<React.ComponentPropsWithoutRef<'a'>, 'color' | 'href'> {
  /**
   * The artwork, as an image.
   *
   * Beaten by `children`, so a project that inlines its SVG and a project that
   * links a PNG use the same component. A logo file very often has the
   * product's name set into it — that is what `shape="bare"` is the default
   * for, since it keeps the file's own aspect ratio instead of squeezing a
   * wordmark into a square, and why `name` is read out rather than drawn a
   * second time beside it.
   */
  src?: string;
  /** Candidate images at other resolutions, as on any `<img>`. */
  srcSet?: string;
  /**
   * What the artwork says for a reader who cannot see it. Defaults to `name`,
   * which is almost always the right answer: a logo means the product.
   */
  alt?: string;
  /**
   * The product's name.
   *
   * One prop doing three jobs, as on Avatar: it names the artwork, it is drawn
   * as the logotype when there is no artwork at all, and its initials are what
   * a tile falls back to. It is what makes `<AppLogo name="Neba" />` — with no
   * file, no icon and no markup — still a logo.
   */
  name?: string;
  /** The initials on a tile, written out, for when the rule derived the wrong ones. */
  initials?: string;
  /**
   * Draws the name beside the artwork, as the words half of a lockup.
   *
   * Off by default, because the common case is a file that already says the
   * name. Turn it on for a bare mark — the icon in a header with the product
   * next to it — and the name stops being read out twice: what is drawn *is*
   * the accessible name from then on.
   *
   * Ignored when the name is already the whole logo, which is what a `bare`
   * logo with no artwork is.
   * @default false
   */
  showName?: boolean;
  /** @default 'bare' */
  shape?: AppLogoShape;
  /**
   * Weight of the tile behind the artwork. Nothing at all on `bare`, which
   * draws no tile.
   * @default 'solid'
   */
  variant?: NebaVariant;
  /**
   * How tall the mark is — the control heights, so a logo and the button beside
   * it in a header are the same height. On `bare` only the height is set and
   * the width is whatever the artwork's own proportions come to; on a tile both
   * are, because a tile is square.
   * @default 'md'
   */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
  /**
   * Drop shadow depth. `0` (the default) is flat: an app icon is a sticker on
   * the page, not a thing hovering over it.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * Insets the artwork from the tile's edge, the way an app icon's glyph is
   * inset from its own corners. Turn it off for a mark that was drawn to fill
   * the tile — a favicon, a photograph.
   *
   * No effect on `bare`, which has no tile to inset from, and none on a tile
   * showing initials, which are sized by their own type scale.
   * @default true
   */
  padded?: boolean;
  /**
   * An exact height for the mark, overriding `size`. A number is pixels.
   *
   * The one escape hatch this component needs: a brand's artwork is drawn at a
   * height somebody chose, and rounding it to the nearest step of a ladder is
   * how a logo ends up half a pixel off the type beside it.
   */
  height?: number | string;
  /**
   * Makes the whole lockup a link. A logo in a header is nearly always the way
   * back to the front page, and a `<span>` inside an `<a>` the caller wrote is
   * the same thing with one more element in it.
   */
  href?: string;
  /** Anything else the `<img>` needs — `loading`, `decoding`, `crossOrigin`. */
  imageProps?: Omit<React.ComponentPropsWithoutRef<'img'>, 'src' | 'srcSet' | 'alt'>;
  /**
   * Renders something other than a `<span>` — or than the `<a>` an `href` makes
   * it. `render={<Link to="/" />}` for a router's own link, `render={<h1 />}`
   * for the one page where the product's name is the page's heading.
   */
  render?: useRender.RenderProp;
  /**
   * The artwork, as markup. An inline `<svg>` is the usual one, and it is worth
   * preferring to `src`: a mark that is part of the document takes the page's
   * own colours, needs no second request, and cannot arrive late.
   */
  children?: React.ReactNode;
}

/**
 * The logotype — the name when the name is the whole logo.
 *
 * Its own ladder rather than `sheetTitleClasses`, because a heading is measured
 * against the paragraph under it and this is measured against the row it sits
 * in: roughly 55% of the mark's height at every step, which is where a word set
 * in the page's own face reads as a mark rather than as a sentence that
 * happens to be bold.
 */
const logotypeClasses: Record<NebaSize, string> = {
  xs: 'text-[0.75rem]',
  sm: 'text-[0.875rem]',
  md: 'text-[1.0625rem]',
  lg: 'text-[1.375rem]',
  xl: 'text-[1.625rem]'
};

/**
 * The letter on a tile, and deliberately larger than Avatar's initials at the
 * same step — about 55% of the tile rather than 40%.
 *
 * They look like the same problem and are not. An avatar's initials stand in
 * for a face and are read; an app icon's letter *is* the icon, drawn to fill
 * the tile the way a glyph would. Sizing it like initials gives a tile with a
 * small letter marooned in the middle of it, which reads as a fallback rather
 * than as a mark.
 */
const tileLetterClasses: Record<NebaSize, string> = {
  xs: 'text-[0.75rem]',
  sm: 'text-[0.875rem]',
  md: 'text-[1.0625rem]',
  lg: 'text-[1.3125rem]',
  xl: 'text-[1.5625rem]'
};

/**
 * The tile's corner, at ~28% rather than the ~45% the control ladder uses —
 * the same correction Avatar's squared crop makes, for the same reason: 45% of
 * a box that is as wide as it is tall is a circle, and a `shape` prop whose two
 * values look identical is a prop that does nothing.
 */
const tileRadiusClasses: Record<NebaSize, string> = {
  xs: 'rounded-[0.375rem]',
  sm: 'rounded-[0.4375rem]',
  md: 'rounded-[0.5625rem]',
  lg: 'rounded-[0.6875rem]',
  xl: 'rounded-[0.875rem]'
};

/**
 * The same three weights they mean everywhere: filled, hairline, none. A logo
 * tile *is* the thing being coloured — as on Chip, Badge and Avatar — so its
 * panel takes the tint rather than staying neutral.
 *
 * `solid` is the default here, against Avatar's `text`, and the difference is
 * what the two are for: a directory is a page of avatars and a page of
 * saturated circles is unreadable, while a product has one logo on the screen
 * and an app icon that is not filled is not an app icon.
 */
const variantClasses: Record<NebaVariant, string> = {
  solid: [
    surfaceClasses,
    'text-(--n-on-solid) bg-(--n-fill)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--n-accent) bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  text: 'text-(--n-accent) bg-(--n-soft-press) [box-shadow:var(--n-elev)]'
};

/**
 * A product's mark, at a known size, that is never an empty box.
 *
 * Four things can be the mark and exactly one of them is at a time: markup
 * handed to `children`, an image at `src`, the initials of `name` on a tile, or
 * — with no tile to put them on — the name itself, set as the logotype. That
 * last one is the point of the component: a product that has not drawn a logo
 * yet still has a logo, and swapping it for the real file later is one prop.
 *
 * What it adds over an `<img>` is the framing. A mark drawn as a bare glyph and
 * a mark drawn with its own background need opposite treatment, and which one a
 * given file is cannot be worked out from the file — so `shape` is the decision
 * a caller makes once, and everything else follows from it: `bare` keeps the
 * artwork's own proportions and draws nothing behind it, `app` and `circle`
 * inset it into a tile of the page's own colour.
 *
 * It carries no tagline and no version. A logo with a line of text under it is
 * a logo next to a [Typography], and inventing a second spelling for that would
 * give the library two of them.
 */
export const AppLogo = React.forwardRef<HTMLElement, AppLogoProps>(function AppLogo(rawProps, ref) {
  const {
    src,
    srcSet,
    alt,
    name,
    initials,
    showName = false,
    shape = 'bare',
    variant = 'solid',
    size = 'md',
    color = 'primary',
    elevation = 0,
    padded = true,
    height,
    href,
    imageProps,
    render,
    className,
    style,
    children,
    ...props
  } = useStyleDefaults(rawProps, ['size', 'variant']);

  const tile = shape !== 'bare';
  const artwork = hasContent(children) ? children : src ? 'image' : null;

  /*
   * How much of the tile the artwork is allowed to take.
   *
   * Stated as a share of the *artwork's* size rather than as padding on the
   * tile, and that is the whole point: a percentage padding resolves against
   * the containing block's width, which here is the lockup — so the same icon
   * was inset by 4px on its own and by 11px with the product's name beside it,
   * and the inset grew with the length of the name. A percentage height on the
   * artwork resolves against the tile itself, which is the box it is actually
   * being held off the edges of, and it stays right at any `height`.
   */
  const inset = tile && padded;

  // With no artwork the name *is* the mark: as the logotype on a bare logo, and
  // as its initials on a tile. Which of the two decides whether `showName` has
  // anything left to do — a bare logotype with the name drawn beside it would
  // be the name twice.
  const lettering = artwork === null;
  const logotype = lettering && !tile;
  const drawName = showName && !logotype && hasContent(name);

  const label = alt ?? name;
  const letters = initials ?? (name ? initialsOf(name) : '');

  /*
   * The name has to be in the document exactly once, and which element carries
   * it depends on what the mark turned out to be. A logotype *is* the name and
   * an image can carry it as `alt`; a glyph and a pair of initials say nothing
   * at all, so those are the cases a clipped copy is for — and whenever the
   * words are somewhere else, the mark becomes decoration rather than a second
   * reading of the same thing. This is Avatar's arrangement: "AC" read out is
   * two letters, not a product.
   */
  const imageSpeaks = artwork === 'image' && !drawName && hasContent(label);
  const markSpeaks = logotype || imageSpeaks;
  const needsClippedName = !markSpeaks && !drawName && hasContent(label);

  const box = toLength(height);
  const boxStyle = box
    ? ({ height: box, width: tile ? box : undefined } as React.CSSProperties)
    : null;

  const mark = (
    <span
      aria-hidden={markSpeaks ? undefined : true}
      className={cx(
        'flex shrink-0 items-center justify-center overflow-hidden',
        'font-semibold tracking-tight whitespace-nowrap',
        box ? '' : controlHeightClasses[size],
        tile
          ? cx(
              box ? '' : controlSquareClasses[size],
              shape === 'circle' ? 'rounded-full' : tileRadiusClasses[size],
              tileLetterClasses[size],
              variantClasses[variant]
            )
          : cx('w-auto text-(--neba-fg)', logotypeClasses[size]),
        // A glyph handed to `children` is drawn against the tile rather than
        // against a word, so it is sized off the box the way the letter is
        // instead of off the `1.2em` an icon riding on a label takes.
        '[&_svg]:w-auto [&_svg]:shrink-0',
        // Written out both ways rather than assembled, because Tailwind only
        // ever sees class names that appear literally in the source.
        inset ? '[&_svg]:h-[72%] [&_svg]:max-w-[72%]' : '[&_svg]:h-full [&_svg]:max-w-full',
        transitionClasses
      )}
      style={{ ...(tile ? controlSlots(color, elevation, variant) : null), ...boxStyle }}
    >
      {artwork === 'image' ? (
        <img
          src={src}
          srcSet={srcSet}
          // Empty rather than absent whenever the name is being said
          // somewhere else: `alt` left off is what makes a screen reader read
          // the file name out instead.
          alt={imageSpeaks ? (label ?? '') : ''}
          className={cx(
            'w-auto object-contain',
            inset ? 'h-[72%] max-w-[72%]' : 'h-full max-w-full'
          )}
          // Before the spread, so a caller can still say otherwise. Never
          // `loading="lazy"` here: a logo is the top of the page by
          // construction, and deferring it defers the thing a reader looks at
          // first.
          decoding="async"
          {...imageProps}
        />
      ) : (
        (artwork ?? (logotype ? name : letters))
      )}
    </span>
  );

  return useRender({
    render: render ?? (href ? <a /> : <span />),
    ref,
    props: {
      href,
      className: cx(
        'inline-flex max-w-full min-w-0 items-center align-middle',
        'text-(--neba-fg) no-underline select-none',
        gapClasses[size],
        href ? 'cursor-pointer rounded-(--neba-radius-sm)' : '',
        href
          ? 'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2'
          : '',
        className
      ),
      style: { '--n-ring': `var(--neba-${color}-ring)`, ...style } as React.CSSProperties,
      children: (
        <>
          {mark}

          {drawName ? (
            <span className={cx('min-w-0 truncate font-semibold', logotypeClasses[size])}>
              {name}
            </span>
          ) : null}

          {needsClippedName ? <span className={srOnlyClasses}>{label}</span> : null}
        </>
      ),
      ...props
    }
  });
});

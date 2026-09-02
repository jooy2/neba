'use client';

import * as React from 'react';
import { Avatar as BaseAvatar } from '@base-ui/react/avatar';
import { transitionProps } from '../../internal/animate.js';
import { initialsOf } from '../../internal/initials.js';
import {
  controlHeightClasses,
  controlSlots,
  controlSquareClasses,
  cx,
  hasContent,
  srOnlyClasses,
  surfaceClasses,
  transitionClasses
} from '../../internal/styles.js';
import type {
  NebaColor,
  NebaElevation,
  NebaSize,
  NebaTransition,
  NebaVariant
} from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/** What Base UI reports about the picture as it loads. */
export type AvatarLoadingStatus = 'idle' | 'loading' | 'loaded' | 'error';

/**
 * The crop, not the sheet.
 *
 * `circle` is the default, and it is the one place besides Badge where the
 * library draws something without a flat run along its edge. The reasoning is
 * Badge's: the cut acrylic edge is what says "this is a surface", and an avatar
 * is not a surface — it is a portrait laid on one. A round crop is what a
 * portrait has been for as long as there have been portraits.
 *
 * `square` cuts the corners off instead, which is what a logo or a repository
 * icon wants: those are drawn to the edges of a rectangle and a round crop eats
 * them.
 */
export type AvatarShape = 'circle' | 'square';

export interface AvatarProps extends Omit<React.ComponentPropsWithoutRef<'span'>, 'color'> {
  /**
   * The picture. Until it loads — and forever, if it fails — the fallback is
   * what is drawn, so an avatar is never an empty box.
   */
  src?: string;
  /** Candidate images at other resolutions, as on any `<img>`. */
  srcSet?: string;
  /**
   * What the picture says, for a reader who cannot see it. Defaults to `name`,
   * and to nothing at all when there is no name — an avatar next to the person's
   * own name in the row is decoration, and reading it out says the name twice.
   */
  alt?: string;
  /**
   * Who or what this is. One prop doing three jobs: it names the picture, the
   * initials are derived from it, and it is the sentence a screen reader hears
   * instead of those initials.
   *
   * The initials are the first character of the first word plus the first
   * character of the last — "Jane Doe" is `JD`, "홍길동" is `홍`. That rule is
   * wrong for some names, which is what `initials` is for.
   */
  name?: string;
  /** The initials, written out, for when the rule derived the wrong ones. */
  initials?: string;
  /**
   * The crop.
   * @default 'circle'
   */
  shape?: AvatarShape;
  /**
   * Weight of the surface behind the fallback. Invisible once a picture has
   * loaded, apart from the edge it keeps.
   * @default 'text'
   */
  variant?: NebaVariant;
  /**
   * The box the picture is drawn in — the control heights, so an avatar and the
   * button beside it in a toolbar are the same height.
   * @default 'md'
   */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
  /**
   * Drop shadow depth. `0` (the default) is flat.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * An entrance animation, run once on mount: `transition="fade"`, or an object
   * for the details. For a trigger, a replay or anything under your own
   * control, wrap it in an `Animate*` component instead.
   */
  transition?: NebaTransition;
  /**
   * How long to wait before drawing the fallback, in milliseconds. Set it to
   * roughly the time a cached image takes and the initials stop flashing up in
   * front of a picture that was about to arrive anyway.
   */
  delay?: number;
  /** Anything else the `<img>` needs — `loading`, `crossOrigin`, `referrerPolicy`. */
  imageProps?: Omit<React.ComponentPropsWithoutRef<'img'>, 'src' | 'srcSet' | 'alt'>;
  /** Called as the picture moves between `idle`, `loading`, `loaded` and `error`. */
  onLoadingStatusChange?: (status: AvatarLoadingStatus) => void;
  /**
   * The fallback, drawn instead of the initials. An icon, a logo, a single
   * emoji — whatever stands in for this particular thing when there is no
   * picture of it.
   */
  children?: React.ReactNode;
}

/**
 * The initials, sized off the box rather than off the row.
 *
 * Its own ladder and not `controlTextClasses`, because a control's label is
 * measured against the words next to it and this one is measured against the
 * circle around it: roughly 40% of the diameter at every step, which is where
 * two characters fill the width without touching the edge.
 */
const initialsTextClasses: Record<NebaSize, string> = {
  xs: 'text-[0.5625rem]',
  sm: 'text-[0.6875rem]',
  md: 'text-[0.8125rem]',
  lg: 'text-[1rem]',
  xl: 'text-[1.1875rem]'
};

/**
 * The corner of a squared avatar, at ~28% rather than the ~45% the control
 * ladder uses — the same correction `tickRadiusClasses` makes, for the same
 * reason.
 *
 * 45% of a control's *height* still leaves a long flat run along a button that
 * is four times wider than it is tall, and that run is the whole point: it is
 * what says the surface was cut rather than moulded. On a box that is as wide as
 * it is tall there is no run left — `--neba-radius-lg` on a 40px avatar is 45%
 * of both sides at once, which is a circle. A `shape` prop whose two values look
 * identical is a prop that does nothing.
 */
const avatarRadiusClasses: Record<NebaSize, string> = {
  xs: 'rounded-[0.375rem]',
  sm: 'rounded-[0.4375rem]',
  md: 'rounded-[0.5625rem]',
  lg: 'rounded-[0.6875rem]',
  xl: 'rounded-[0.875rem]'
};

/**
 * The same three weights they mean everywhere: filled, hairline, none. An avatar
 * *is* the thing being coloured, so — as on Chip and Badge — its panel takes the
 * tint rather than staying neutral.
 *
 * `text` is the default. A directory is a page of avatars, and a page of
 * saturated circles is a page nobody can read a name off.
 */
const variantClasses: Record<NebaVariant, string> = {
  solid: [surfaceClasses, 'text-(--n-on-solid) bg-(--n-fill)', '[box-shadow:var(--n-elev)]'].join(
    ' '
  ),
  outline: [
    surfaceClasses,
    'border text-(--n-accent) bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev)]'
  ].join(' '),
  text: 'text-(--n-accent) bg-(--n-soft-press) [box-shadow:var(--n-elev)]'
};

/**
 * The plate, drawn on a pseudo-element rather than as an inset shadow on the
 * box itself.
 *
 * Everywhere else in the library the two are the same thing. Here they are not:
 * an inset shadow paints above the background and *below* the content, and this
 * is the one component whose content reaches the edge — a loaded picture covers
 * the whole box and would swallow the hairline with it. On an overlay the light
 * edge sits on top of the photograph, which is what an acrylic edge does.
 *
 * The border on `outline` needs none of this: a border is outside the content
 * box, so the picture never reaches it.
 */
const plateOverlayClasses =
  'after:pointer-events-none after:absolute after:inset-0 after:rounded-[inherit]';

const plateClasses: Record<NebaVariant, string> = {
  solid: `${plateOverlayClasses} after:[box-shadow:var(--neba-plate-solid)]`,
  outline: `${plateOverlayClasses} after:[box-shadow:var(--neba-plate-glass)]`,
  text: ''
};

const baseClasses = [
  'relative inline-flex shrink-0 select-none items-center justify-center overflow-hidden',
  'align-middle font-semibold tracking-wide whitespace-nowrap leading-none',
  // A glyph handed to `children` is drawn against the circle, not against a
  // word, so it is sized off the box like the initials are rather than off the
  // `1.2em` an icon riding on a label takes.
  '[&_svg]:pointer-events-none [&_svg]:size-[55%]',
  transitionClasses
].join(' ');

/**
 * The default fallback: a shoulders-and-head silhouette, drawn here rather than
 * in `internal/icons` because Avatar is the only component that needs it.
 *
 * It exists so that `<Avatar />` with nothing at all is still an avatar. A box
 * with no picture, no name and no glyph in it is indistinguishable from a
 * component that failed to render.
 */
function PersonIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
      <path d="M12 12a4.5 4.5 0 1 0 0-9 4.5 4.5 0 0 0 0 9Z" />
      <path d="M12 14.25c-4.28 0-7.75 2.42-7.75 5.4 0 .75.6 1.35 1.35 1.35h12.8c.75 0 1.35-.6 1.35-1.35 0-2.98-3.47-5.4-7.75-5.4Z" />
    </svg>
  );
}

/**
 * A picture of a person or a thing, at a known size, that is never an empty box.
 *
 * Three things can be drawn in it and exactly one of them is at a time: the
 * picture, if `src` is given and loads; otherwise whatever stands in for it —
 * `children`, or `initials`, or the initials derived from `name`; and failing
 * all of those, a silhouette. Which one is showing is Base UI's `Avatar` to
 * decide, because "has the image loaded" is a question with four answers and a
 * race in the middle of it.
 *
 * It carries no status dot of its own. An avatar with a green mark on it is a
 * [Badge](./badge) with an avatar in it, and inventing a second spelling for
 * that would give the library two of them.
 */
export const Avatar = React.forwardRef<HTMLSpanElement, AvatarProps>(
  function Avatar(rawProps, ref) {
    const {
      src,
      srcSet,
      alt,
      name,
      initials,
      shape: shapeProp,
      variant: variantProp,
      size: sizeProp,
      color: colorProp,
      elevation: elevationProp,
      delay,
      imageProps,
      onLoadingStatusChange,
      transition,
      className,
      style,
      children,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'variant']);

    const shape = shapeProp ?? 'circle';
    const variant = variantProp ?? 'text';
    const size = sizeProp ?? 'md';
    const color = colorProp ?? 'primary';
    const elevation = elevationProp ?? 0;

    const derived = name ? initialsOf(name) : '';
    const animation = transitionProps(transition);
    const label = alt ?? name;

    // `children` beats the initials beats the silhouette. Only the last of the
    // three has nothing to say, which is what decides whether the fallback needs
    // the name spelled out beside it.
    const stand = hasContent(children) ? children : (initials ?? derived) || <PersonIcon />;
    const speaks = hasContent(children) || Boolean(initials ?? derived);

    const classNames = cx(
      baseClasses,
      controlHeightClasses[size],
      controlSquareClasses[size],
      initialsTextClasses[size],
      shape === 'circle' ? 'rounded-full' : avatarRadiusClasses[size],
      variantClasses[variant],
      plateClasses[variant],
      animation.className,
      className ?? ''
    );

    return (
      <BaseAvatar.Root
        ref={ref}
        className={classNames}
        style={{ ...controlSlots(color, elevation, variant), ...animation.style, ...style }}
        {...props}
      >
        {src ? (
          <BaseAvatar.Image
            src={src}
            srcSet={srcSet}
            // Empty rather than absent: an avatar beside the person's own name is
            // decoration, and `alt` left off is what makes a screen reader read
            // the file name out instead.
            alt={label ?? ''}
            className="size-full object-cover"
            // Before the spread, so a caller can still say otherwise. Decoding an
            // image on the main thread is what makes a list of forty avatars
            // arrive as forty small pauses; off it, they arrive.
            decoding="async"
            onLoadingStatusChange={onLoadingStatusChange}
            {...imageProps}
          />
        ) : null}

        <BaseAvatar.Fallback
          delay={src ? delay : undefined}
          className="flex size-full items-center justify-center"
        >
          {/* `JD` read out loud is two letters, not a person. When there is a name
            it becomes the fallback's accessible name and the initials are left
            as the picture they are standing in for. */}
          {label && speaks ? <span className={srOnlyClasses}>{label}</span> : null}
          <span aria-hidden={label && speaks ? true : undefined} className="contents">
            {stand}
          </span>
        </BaseAvatar.Fallback>
      </BaseAvatar.Root>
    );
  }
);

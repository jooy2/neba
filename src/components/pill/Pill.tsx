import * as React from 'react';
import {
  controlHeightClasses,
  controlSlots,
  controlTextClasses,
  focusRingClasses,
  gapClasses,
  hasContent,
  iconClasses,
  paddingXClasses,
  pressTransitionClasses,
  sheetBodyClasses,
  surfaceClasses,
  transitionClasses
} from '../../internal/styles';
import type { NebaElevation, NebaPosition, NebaSize, NebaStyleProps } from '../../types';

export interface PillProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'onClick'> {
  /**
   * Drop shadow depth. `2` here, against the `0` everything else defaults to.
   *
   * That is not an inconsistency: a Pill is defined by not being part of the
   * page. Every other surface in the library rests on the page and earns its
   * separation from the acrylic edge, so a shadow is opt-in. This one hovers
   * over whatever is underneath it, and a lozenge floating flat on the content
   * it is floating over reads as a mistake.
   * @default 2
   */
  elevation?: NebaElevation;
  /** The leading slot — a glyph, an avatar, a status dot, a small image. */
  startIcon?: React.ReactNode;
  /** The trailing slot. Outside the pressable area, so it can be a control. */
  endIcon?: React.ReactNode;
  /**
   * The second half, revealed when `expanded`.
   *
   * The pill grows downward into it rather than swapping to a different shape:
   * one object saying more, which is the whole idea being borrowed here.
   */
  details?: React.ReactNode;
  /** Whether `details` is showing. @default false */
  expanded?: boolean;
  /**
   * How it sits in the page's scroll. `fixed` pins it against the viewport and
   * centres it horizontally, which is the arrangement this shape exists for.
   * @default 'static'
   */
  position?: NebaPosition;
  /** Which edge it is held against when `position` is not `static`. @default 'top' */
  side?: 'top' | 'bottom';
  /** Passing it makes the row a real button. */
  onClick?: React.MouseEventHandler<HTMLButtonElement>;
  /** The middle: a line of text, a marquee, a pair of small readouts. */
  children?: React.ReactNode;
}

/**
 * The three weights, said the way a *control* says them — the surface takes the
 * tint, as on Button and Chip, because a Pill is the thing being coloured rather
 * than a sheet holding somebody else's content.
 */
const restClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
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
  text: `${surfaceClasses} text-(--n-accent) bg-(--n-soft)`
};

const hoverClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: 'hover:bg-(--n-fill-hover) active:bg-(--n-fill-active)',
  outline:
    'hover:bg-(--n-panel-hover) hover:[border-color:var(--n-line-hover)] active:bg-(--n-panel-press)',
  text: 'hover:bg-(--n-soft-hover) active:bg-(--n-soft-press)'
};

/**
 * Exactly half the row's height at every step — 22, 26, 32, 40 and 48px — so a
 * collapsed pill is a true stadium.
 *
 * Written as a length rather than as `rounded-full`, and the difference only
 * shows once `details` opens: `rounded-full` on a box that has grown to 80px
 * tall is a 40px corner, and a 40px corner eats the first two words of every
 * line. Pinning the radius to the *row* is what lets the lozenge grow into a
 * rounded rectangle with the same corner it always had, which is the morph this
 * shape is borrowed from.
 */
const pillRadiusClasses: Record<NebaSize, string> = {
  xs: 'rounded-[0.6875rem]',
  sm: 'rounded-[0.8125rem]',
  md: 'rounded-[1rem]',
  lg: 'rounded-[1.25rem]',
  xl: 'rounded-[1.5rem]'
};

/** Where a pinned pill hangs, and how far in from the edge. */
const positionClasses: Record<NebaPosition, Record<'top' | 'bottom', string>> = {
  static: { top: '', bottom: '' },
  sticky: { top: 'sticky top-3 z-20', bottom: 'sticky bottom-3 z-20' },
  fixed: {
    // Centred by stretching the box across the viewport and letting `mx-auto`
    // shrink it back, not by translating it half its own width. The house rule
    // against transforming a surface holds here too, and `auto` margins are
    // direction-agnostic, so the lozenge stays centred under RTL.
    top: 'fixed inset-x-0 top-3 z-30 mx-auto w-fit',
    bottom: 'fixed inset-x-0 bottom-3 z-30 mx-auto w-fit'
  }
};

/**
 * A floating lozenge holding a small amount of live information.
 *
 * The shape is a stadium, which the house radius rule otherwise forbids: every
 * control is held just short of the 50% that would make it a pill, because the
 * flat run along its top and bottom edge is what still reads as a sheet with the
 * corners cut off it. A Pill is the exception the rule is drawn against, and the
 * exception works for the same reason the rule does — this is not a sheet lying
 * on the page. It is an object hovering over it, and an object hovering over the
 * page should not look like it was cut from the same material.
 *
 * `details` is revealed by animating a measured height, exactly as an Accordion
 * panel is: nothing is transformed and no text is resampled, the pill is simply
 * a window that opens. The measurement is a `ResizeObserver` rather than a
 * hardcoded height, so a details area whose content changes — which is what live
 * information does — grows with it.
 */
export const Pill = React.forwardRef<HTMLDivElement, PillProps>(function Pill(
  {
    variant = 'solid',
    size = 'md',
    color = 'secondary',
    density = 'default',
    elevation = 2,
    startIcon,
    endIcon,
    details,
    expanded = false,
    position = 'static',
    side = 'top',
    className,
    style,
    children,
    onClick,
    ...props
  },
  ref
) {
  const detailsRef = React.useRef<HTMLDivElement>(null);
  const [detailsHeight, setDetailsHeight] = React.useState(0);

  React.useEffect(() => {
    const element = detailsRef.current;
    if (!element) {
      return;
    }

    const observer = new ResizeObserver(() => {
      setDetailsHeight(element.scrollHeight);
    });
    observer.observe(element);
    setDetailsHeight(element.scrollHeight);

    return () => observer.disconnect();
  }, [details]);

  const interactive = Boolean(onClick);
  const padX = paddingXClasses[density][size];

  const row = (
    <>
      {hasContent(startIcon) ? (
        <span className="flex h-[1lh] shrink-0 items-center">{startIcon}</span>
      ) : null}
      {hasContent(children) ? <span className="min-w-0 truncate">{children}</span> : null}
    </>
  );

  return (
    <div
      ref={ref}
      className={[
        'inline-flex max-w-full flex-col overflow-hidden align-middle',
        pillRadiusClasses[size],
        'font-medium whitespace-nowrap select-none',
        controlTextClasses[size],
        restClasses[variant],
        transitionClasses,
        pressTransitionClasses,
        iconClasses,
        interactive ? `neba-glow ${hoverClasses[variant]}` : '',
        positionClasses[position][side],
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      style={{ ...controlSlots(color, elevation, variant), ...style }}
      {...props}
    >
      <div
        className={[
          'flex shrink-0 items-center',
          controlHeightClasses[size],
          gapClasses[size],
          // With a pressable middle the padding belongs to the button, so its hit
          // area covers the whole row rather than just the words.
          interactive ? 'ps-0' : padX,
          hasContent(endIcon) ? 'pe-1' : interactive ? 'pe-0' : ''
        ].join(' ')}
      >
        {interactive ? (
          // A real `<button>` inside the shell rather than a handler on the
          // shell itself, and `endIcon` deliberately outside it — the same shape
          // Chip uses, and for the same two reasons: a `<div>` carrying a click
          // handler is invisible to a keyboard, and a `<button>` holding the
          // close button somebody put in `endIcon` is markup the browser
          // rewrites on parse.
          <button
            type="button"
            className={[
              'flex min-w-0 flex-1 cursor-pointer items-center justify-center self-stretch',
              // `inherit`, so the focus ring traces the lozenge's own corners
              // rather than drawing a second, squarer rectangle inside them.
              'rounded-[inherit]',
              gapClasses[size],
              padX,
              focusRingClasses
            ].join(' ')}
            onClick={onClick}
          >
            {row}
          </button>
        ) : (
          row
        )}

        {hasContent(endIcon) ? (
          <span className="flex h-[1lh] shrink-0 items-center">{endIcon}</span>
        ) : null}
      </div>

      {hasContent(details) ? (
        <div
          className={[
            'overflow-hidden',
            '[transition:height_var(--neba-duration)_var(--neba-ease)]',
            'motion-reduce:[transition-duration:0ms]'
          ].join(' ')}
          style={{ height: expanded ? detailsHeight : 0 }}
          // `inert` rather than `aria-hidden`: a collapsed panel is a zero-height
          // box that its content is still perfectly focusable inside, and
          // `aria-hidden` alone would leave a keyboard reader tabbing into
          // something their screen reader has been told does not exist.
          inert={!expanded}
        >
          <div
            ref={detailsRef}
            className={`whitespace-normal ${padX} pb-2 ${sheetBodyClasses[size]}`}
          >
            {details}
          </div>
        </div>
      ) : null}
    </div>
  );
});

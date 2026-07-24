import * as React from 'react';
import { Button as BaseUIButton } from '@base-ui/react/button';
import type { NebaColor, NebaDensity, NebaElevation, NebaSize, NebaStyleProps } from '../../types';

export interface ButtonProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'button'>, 'color'> {
  /**
   * Drop shadow depth. `0` (the default) is flat — the acrylic edge is what
   * separates the button from the page. Hover adds a level, press removes one.
   * @default 0
   */
  elevation?: NebaElevation;
  /** Content placed before the label. Sized in `em`, so it tracks the label. */
  startIcon?: React.ReactNode;
  /** Content placed after the label. */
  endIcon?: React.ReactNode;
  /**
   * Shows a spinner in place of `startIcon` and stops the button from
   * activating, while keeping it focusable and visually unchanged otherwise.
   */
  loading?: boolean;
  /** Inert but not dimmed — the action exists, it just is not available here. */
  readOnly?: boolean;
  /** Stretches to the width of the container. */
  fullWidth?: boolean;
  children?: React.ReactNode;
}

/**
 * Height and type scale. The steps are deliberately uneven: `md` (32px) is the
 * desktop workhorse, `xs`/`sm` are for dense toolbars and table rows, and
 * `lg`/`xl` are for the one action a screen is actually about — so the gaps
 * widen at both ends rather than marching up in equal 4px increments.
 *
 * Density never touches these, so two buttons of the same `size` always share a
 * height and rows of mixed-density controls stay aligned.
 */
const sizeClasses: Record<NebaSize, string> = {
  xs: 'h-5.5 gap-1 rounded-(--neba-radius-xs) text-[0.6875rem]',
  sm: 'h-6.5 gap-1.5 rounded-(--neba-radius-sm) text-[0.75rem]',
  md: 'h-8 gap-1.5 rounded-(--neba-radius-md) text-[0.8125rem]',
  lg: 'h-10 gap-2 rounded-(--neba-radius-lg) text-[0.9375rem]',
  xl: 'h-12 gap-2.5 rounded-(--neba-radius-xl) text-[1.0625rem]'
};

/**
 * Density is horizontal padding, and only horizontal padding. The two tracks
 * are roughly 2:1 so the difference is legible at a glance rather than a
 * two-pixel nudge.
 */
const paddingClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'px-2.5', sm: 'px-3', md: 'px-4', lg: 'px-5', xl: 'px-6' },
  compact: { xs: 'px-1.5', sm: 'px-2', md: 'px-2.5', lg: 'px-3', xl: 'px-4' }
};

/** With no label there is nothing to pad against, so the button goes square. */
const iconOnlyClasses: Record<NebaSize, string> = {
  xs: 'w-5.5 px-0',
  sm: 'w-6.5 px-0',
  md: 'w-8 px-0',
  lg: 'w-10 px-0',
  xl: 'w-12 px-0'
};

const baseClasses = [
  'relative inline-flex shrink-0 select-none items-center justify-center',
  'whitespace-nowrap align-middle font-medium leading-none',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  // No `transform` in the list, and none anywhere below: scaling a control
  // resamples its label, and a label that shimmers under the cursor undoes
  // every other bit of restraint in the design.
  // Per-property durations, in the order the property list declares them: the
  // fill drains back slowly while edges and shadows keep up with the pointer.
  // Pressing zeroes all four, so the whole button lands on the frame of the
  // click and then decays — the same asymmetry the afterglow layer uses.
  '[transition-property:background-color,border-color,box-shadow,color]',
  '[transition-duration:var(--neba-duration-fill),var(--neba-duration),var(--neba-duration),var(--neba-duration)]',
  '[transition-timing-function:var(--neba-ease)]',
  'active:[transition-duration:0ms]',
  // One `outline` shorthand rather than Tailwind's `outline-2` + colour pair:
  // the utilities route the style through `--tw-outline-style`, which any
  // `outline-none` on the element (ours or a consumer's) would zero out.
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2',
  '[&_svg]:pointer-events-none [&_svg]:size-[1.2em] [&_svg]:shrink-0'
].join(' ');

/**
 * The frosted surface: a translucent fill over a blurred backdrop, a tile of
 * noise blended into it for tooth, an angled sheen, and a hairline edge. The
 * blur makes it a sheet of something; the noise makes that something acrylic
 * rather than glass.
 */
const surfaceClasses =
  '[background-image:var(--neba-grain),var(--neba-sheen)] [background-blend-mode:overlay,normal] [backdrop-filter:var(--neba-blur)]';

const restClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: [
    surfaceClasses,
    'text-(--n-on-solid) bg-(--n-fill)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  // Not a white box with a colored border — a panel of the same frosted acrylic,
  // dyed faintly with its own accent. The hairline is mostly the glass edge
  // catching light, with just enough accent in it to name the color.
  outline: [
    surfaceClasses,
    'border text-(--n-accent) bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  // Nothing to catch the light on, and nothing to cast a shadow.
  text: 'text-(--n-accent) bg-transparent'
};

/**
 * Press is a color change plus one level *down* the elevation scale. A flat
 * button therefore stays flat and just deepens, which is the whole fix for the
 * surface reading as a key being pushed into its socket.
 */
const hoverClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: [
    'hover:bg-(--n-fill-hover)',
    'hover:[box-shadow:var(--n-elev-hover),var(--neba-plate-solid)]',
    'active:bg-(--n-fill-active)',
    'active:[box-shadow:var(--n-elev-press),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    'hover:bg-(--n-panel-hover) hover:[border-color:var(--n-line-hover)]',
    'hover:[box-shadow:var(--n-elev-hover),var(--neba-plate-glass)]',
    'active:bg-(--n-panel-press)',
    'active:[box-shadow:var(--n-elev-press),var(--neba-plate-glass)]'
  ].join(' '),
  text: 'hover:bg-(--n-soft) active:bg-(--n-soft-hover)'
};

/**
 * Read-only keeps the shape and the edge but goes flat, loses its sheen, drains
 * most of the saturation, and stops reacting. It reads as a label that happens
 * to be button-shaped, which is what a read-only action is.
 *
 * The desaturation is doing the work now that `elevation` defaults to 0: with
 * no drop shadow on a normal button either, "flat" alone says nothing.
 */
const readOnlyClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: [
    surfaceClasses,
    'cursor-default text-(--n-on-solid) bg-(--n-fill)',
    '[box-shadow:var(--neba-plate-solid)] [filter:saturate(0.55)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'cursor-default border text-(--n-accent) bg-(--n-panel)',
    '[border-color:var(--n-line)] [box-shadow:var(--neba-plate-glass)] [filter:saturate(0.55)]'
  ].join(' '),
  text: 'cursor-default text-(--n-accent) bg-transparent [filter:saturate(0.55)]'
};

/**
 * Disabled drops the color family entirely. Fading the colored surface would
 * still read as "this is the primary action", only blurrier.
 */
const disabledClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: 'cursor-not-allowed bg-(--neba-disabled-bg) text-(--neba-disabled-fg) shadow-none',
  outline:
    'cursor-not-allowed border bg-transparent text-(--neba-disabled-fg) [border-color:var(--neba-disabled-border)] shadow-none',
  text: 'cursor-not-allowed bg-transparent text-(--neba-disabled-fg) shadow-none'
};

/**
 * Maps `color` and `elevation` onto the local slots the classes above read from.
 *
 * These are inline styles rather than Tailwind arbitrary properties on purpose:
 * Tailwind only sees class names that appear literally in the source, so the
 * alternative is nine hardcoded `[--n-fill:var(--neba-primary-fill)]` classes
 * per color family. Generating the slots keeps adding a color family down to one
 * entry in `NebaColor` plus its tokens in `styles.css`.
 */
function styleSlots(
  color: NebaColor,
  elevation: NebaElevation,
  variant: NonNullable<NebaStyleProps['variant']>
): React.CSSProperties {
  // Light thrown onto a filled surface is white; onto a tinted or bare one it
  // has to be the accent, or it would wash the surface out to grey.
  const onFill = variant === 'solid';

  return {
    '--n-fill': `var(--neba-${color}-fill)`,
    '--n-fill-hover': `var(--neba-${color}-fill-hover)`,
    '--n-fill-active': `var(--neba-${color}-fill-active)`,
    '--n-on-solid': `var(--neba-${color}-on-solid)`,
    '--n-accent': `var(--neba-${color}-accent)`,
    '--n-soft': `var(--neba-${color}-soft)`,
    '--n-soft-hover': `var(--neba-${color}-soft-hover)`,
    '--n-soft-press': `var(--neba-${color}-soft-press)`,
    '--n-panel': `var(--neba-${color}-panel)`,
    '--n-panel-hover': `var(--neba-${color}-panel-hover)`,
    '--n-panel-press': `var(--neba-${color}-panel-press)`,
    '--n-line': `var(--neba-${color}-line)`,
    '--n-line-hover': `var(--neba-${color}-line-hover)`,
    '--n-ring': `var(--neba-${color}-ring)`,
    '--n-glow': onFill ? 'var(--neba-glow-on-fill)' : `var(--neba-${color}-soft)`,
    '--n-flash': onFill ? 'var(--neba-flash-on-fill)' : `var(--neba-${color}-soft-press)`,
    '--n-elev': `var(--neba-shadow-${elevation})`,
    '--n-elev-hover': `var(--neba-shadow-${Math.min(elevation + 1, 4)})`,
    '--n-elev-press': `var(--neba-shadow-${Math.max(elevation - 1, 0)})`
  } as React.CSSProperties;
}

function Spinner() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true" className="animate-spin">
      <circle cx="8" cy="8" r="6.5" stroke="currentColor" strokeOpacity="0.25" strokeWidth="2" />
      <path
        d="M14.5 8A6.5 6.5 0 0 0 8 1.5"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
      />
    </svg>
  );
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(function Button(
  {
    variant = 'solid',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    startIcon,
    endIcon,
    loading = false,
    readOnly = false,
    fullWidth = false,
    disabled = false,
    className,
    style,
    children,
    onClick,
    onPointerMove,
    ...props
  },
  ref
) {
  const iconOnly = children === undefined || children === null || children === false;
  // `disabled` and `readOnly` change how the button looks; `loading` only stops
  // it from firing.
  const inert = loading || readOnly;

  const classNames = [
    baseClasses,
    sizeClasses[size],
    iconOnly ? iconOnlyClasses[size] : paddingClasses[density][size],
    // Deliberately an if/else rather than stacked `data-*` variants: two
    // Tailwind variants of equal specificity resolve by their order in the
    // generated stylesheet, which is not something a component should depend on.
    disabled
      ? disabledClasses[variant]
      : readOnly
        ? readOnlyClasses[variant]
        : restClasses[variant],
    !disabled && !inert ? [hoverClasses[variant], 'neba-glow', 'cursor-pointer'].join(' ') : '',
    loading ? 'cursor-progress' : '',
    fullWidth ? 'w-full' : '',
    className ?? ''
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <BaseUIButton
      ref={ref}
      disabled={disabled}
      className={classNames}
      style={{ ...styleSlots(color, elevation, variant), ...style }}
      aria-disabled={inert || undefined}
      aria-busy={loading || undefined}
      data-loading={loading || undefined}
      data-readonly={readOnly || undefined}
      onClick={(event) => {
        if (inert) {
          event.preventDefault();
          event.stopPropagation();
          return;
        }
        onClick?.(event);
      }}
      onPointerMove={(event) => {
        // Feeds the two light layers in `styles.css`. Written straight to the
        // element rather than held in state: this fires at pointer rate, and a
        // `setState` here would re-render the tree on every mouse move. Reading
        // `offsetX/offsetY` costs nothing — no `getBoundingClientRect`, so no
        // forced layout. Icons carry `pointer-events: none`, so the offsets are
        // always relative to the button itself.
        const element = event.currentTarget;
        element.style.setProperty('--n-mx', `${event.nativeEvent.offsetX}px`);
        element.style.setProperty('--n-my', `${event.nativeEvent.offsetY}px`);
        onPointerMove?.(event);
      }}
      {...props}
    >
      {loading ? <Spinner /> : startIcon}
      {children}
      {endIcon}
    </BaseUIButton>
  );
});

'use client';

import * as React from 'react';
import { Button as BaseUIButton } from '@base-ui/react/button';
import { useRender } from '@base-ui/react/use-render';
import { ButtonGroupContext } from '../../internal/button-group.js';
import {
  controlHeightClasses,
  controlSlots,
  controlSquareClasses,
  controlTextClasses,
  cx,
  disabledClasses,
  focusRingClasses,
  gapClasses,
  iconClasses,
  paddingXClasses,
  pressTransitionClasses,
  radiusClasses,
  readOnlyFilterClasses,
  surfaceClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaElevation, NebaSize, NebaStyleProps } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

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
  /**
   * Renders something other than a `<button>` — an `<a href>` for an action that
   * is really a navigation, or the `Link` a router brings. Base UI's own escape
   * hatch, so it behaves here as it does on [TextLink](../display/text-link) and
   * [Typography](../display/typography).
   *
   * The surface, the sizes and the press signature are unchanged; what changes
   * is the element they are drawn on, and what it *is* to everything reading the
   * page. A link stays a link: it is announced as one, it is in the list a
   * screen reader can pull up, and a crawler follows it.
   *
   * An `<a>` has no `disabled`, so a button that has to be unavailable stays a
   * `<button>`.
   */
  render?: useRender.RenderProp;
  children?: React.ReactNode;
}

/**
 * The scales all come from `internal/styles` — a button's height *is* the
 * library's control height, and the same numbers have to hold on a TextField,
 * a Select and a Chip for a mixed row to keep its baseline.
 */
const sizeClasses: Record<NebaSize, string> = {
  xs: `${controlHeightClasses.xs} ${gapClasses.xs} ${radiusClasses.xs} ${controlTextClasses.xs}`,
  sm: `${controlHeightClasses.sm} ${gapClasses.sm} ${radiusClasses.sm} ${controlTextClasses.sm}`,
  md: `${controlHeightClasses.md} ${gapClasses.md} ${radiusClasses.md} ${controlTextClasses.md}`,
  lg: `${controlHeightClasses.lg} ${gapClasses.lg} ${radiusClasses.lg} ${controlTextClasses.lg}`,
  xl: `${controlHeightClasses.xl} ${gapClasses.xl} ${radiusClasses.xl} ${controlTextClasses.xl}`
};

/** With no label there is nothing to pad against, so the button goes square. */
const iconOnlyClasses: Record<NebaSize, string> = {
  xs: `${controlSquareClasses.xs} px-0`,
  sm: `${controlSquareClasses.sm} px-0`,
  md: `${controlSquareClasses.md} px-0`,
  lg: `${controlSquareClasses.lg} px-0`,
  xl: `${controlSquareClasses.xl} px-0`
};

const baseClasses = [
  'relative inline-flex shrink-0 select-none items-center justify-center',
  'whitespace-nowrap align-middle font-medium leading-none',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  pressTransitionClasses,
  focusRingClasses,
  iconClasses
].join(' ');

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
 * most of the saturation, and stops reacting.
 */
const readOnlyClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: [
    surfaceClasses,
    readOnlyFilterClasses,
    'cursor-default text-(--n-on-solid) bg-(--n-fill)',
    '[box-shadow:var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    readOnlyFilterClasses,
    'cursor-default border text-(--n-accent) bg-(--n-panel)',
    '[border-color:var(--n-line)] [box-shadow:var(--neba-plate-glass)]'
  ].join(' '),
  text: `${readOnlyFilterClasses} cursor-default text-(--n-accent) bg-transparent`
};

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

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  function Button(rawProps, ref) {
    const {
      variant: variantProp,
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      elevation: elevationProp,
      startIcon,
      endIcon,
      loading = false,
      readOnly = false,
      fullWidth = false,
      disabled: disabledProp,
      render,
      className,
      style,
      children,
      onClick,
      onPointerMove,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density', 'variant']);

    // A ButtonGroup sets these once for the whole set. The button's own prop still
    // wins — a group of secondary actions with one danger button in it is a real
    // thing — and with no group around it the defaults are what they always were.
    const group = React.useContext(ButtonGroupContext);
    const variant = variantProp ?? group?.variant ?? 'solid';
    const size = sizeProp ?? group?.size ?? 'md';
    const color = colorProp ?? group?.color ?? 'primary';
    const density = densityProp ?? group?.density ?? 'default';
    const elevation = elevationProp ?? group?.elevation ?? 0;
    const disabled = disabledProp ?? group?.disabled ?? false;

    const iconOnly = children === undefined || children === null || children === false;
    // `disabled` and `readOnly` change how the button looks; `loading` only stops
    // it from firing.
    const inert = loading || readOnly;

    const classNames = cx(
      baseClasses,
      sizeClasses[size],
      iconOnly ? iconOnlyClasses[size] : paddingXClasses[density][size],
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
    );

    /*
     * `render` deliberately steps around Base UI's Button rather than being handed
     * to it. Told to render a non-`<button>`, that component puts `role="button"`
     * on whatever it was given — which is right for a `<div>` and wrong for the
     * case this prop exists for: an `<a href>` under a `role="button"` stops being
     * a link to everything that reads the page, and the link list, the status bar
     * and the crawler all lose it.
     *
     * What Base UI's Button adds over a bare `<button>` is its disabled handling,
     * and `disabled` is the one thing that cannot travel to an `<a>` anyway.
     */
    return useRender({
      render: render ?? <BaseUIButton disabled={disabled} />,
      ref,
      props: {
        className: classNames,
        style: { ...controlSlots(color, elevation, variant), ...style },
        'aria-disabled': inert || undefined,
        'aria-busy': loading || undefined,
        'data-loading': loading || undefined,
        'data-readonly': readOnly || undefined,
        onClick: (event: React.MouseEvent<HTMLElement>) => {
          if (inert) {
            event.preventDefault();
            event.stopPropagation();
            return;
          }
          onClick?.(event as React.MouseEvent<HTMLButtonElement>);
        },
        onPointerMove: (event: React.PointerEvent<HTMLElement>) => {
          // Feeds the two light layers in `styles.css`. Written straight to the
          // element rather than held in state: this fires at pointer rate, and a
          // `setState` here would re-render the tree on every mouse move. Reading
          // `offsetX/offsetY` costs nothing — no `getBoundingClientRect`, so no
          // forced layout. Icons carry `pointer-events: none`, so the offsets are
          // always relative to the button itself.
          // Only where there are layers to feed. `neba-glow` is on the enabled
          // button and nothing else, so writing the two slots on a disabled,
          // loading or read-only one invalidates that element's style on every
          // pointer event to move a gradient nobody is painting.
          if (!disabled && !inert) {
            const element = event.currentTarget;

            element.style.setProperty('--n-mx', `${event.nativeEvent.offsetX}px`);
            element.style.setProperty('--n-my', `${event.nativeEvent.offsetY}px`);
          }

          onPointerMove?.(event as React.PointerEvent<HTMLButtonElement>);
        },
        ...props,
        children: (
          <>
            {loading ? <Spinner /> : startIcon}
            {children}
            {endIcon}
          </>
        )
      }
    });
  }
);

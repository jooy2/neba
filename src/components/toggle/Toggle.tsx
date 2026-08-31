'use client';

import * as React from 'react';
import { Toggle as BaseUIToggle } from '@base-ui/react/toggle';
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
  surfaceClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaElevation, NebaSize, NebaStyleProps, NebaVariant } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

export interface ToggleProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'button'>, 'color' | 'value'> {
  /**
   * How the toggle looks while it is **off**. On is always the colour family
   * asserting itself, whichever weight was asked for.
   *
   * - `solid` — a filled neutral plate that fills with the accent when it goes
   *   on. The loudest, for a toggle a screen is steered by.
   * - `outline` — a hairline panel. The default.
   * - `text` — nothing at all until it is hovered or on. What a toolbar wants.
   * @default 'outline'
   */
  variant?: NebaVariant;
  /** Whether it is on. Use with `onPressedChange` for a controlled toggle. */
  pressed?: boolean;
  /** Whether it starts on, for an uncontrolled one. @default false */
  defaultPressed?: boolean;
  onPressedChange?: (pressed: boolean) => void;
  /** Identifies the toggle inside a [ToggleGroup](./toggle-group). */
  value?: string;
  /**
   * Drop shadow depth. `0` (the default) is flat — the acrylic edge is what
   * separates the toggle from the page.
   * @default 0
   */
  elevation?: NebaElevation;
  /** Content placed before the label. Sized in `em`, so it tracks the label. */
  startIcon?: React.ReactNode;
  /** Content placed after the label. */
  endIcon?: React.ReactNode;
  /** Stretches to the width of the container. */
  fullWidth?: boolean;
  /**
   * The label. Left out, the toggle goes square around whatever icon it was
   * given — which is what a toolbar toggle is. An icon-only toggle still needs
   * an `aria-label`.
   */
  children?: React.ReactNode;
}

const sizeClasses: Record<NebaSize, string> = {
  xs: `${controlHeightClasses.xs} ${gapClasses.xs} ${radiusClasses.xs} ${controlTextClasses.xs}`,
  sm: `${controlHeightClasses.sm} ${gapClasses.sm} ${radiusClasses.sm} ${controlTextClasses.sm}`,
  md: `${controlHeightClasses.md} ${gapClasses.md} ${radiusClasses.md} ${controlTextClasses.md}`,
  lg: `${controlHeightClasses.lg} ${gapClasses.lg} ${radiusClasses.lg} ${controlTextClasses.lg}`,
  xl: `${controlHeightClasses.xl} ${gapClasses.xl} ${radiusClasses.xl} ${controlTextClasses.xl}`
};

/** With no label there is nothing to pad against, so the toggle goes square. */
const iconOnlyClasses: Record<NebaSize, string> = {
  xs: `${controlSquareClasses.xs} px-0`,
  sm: `${controlSquareClasses.sm} px-0`,
  md: `${controlSquareClasses.md} px-0`,
  lg: `${controlSquareClasses.lg} px-0`,
  xl: `${controlSquareClasses.xl} px-0`
};

const baseClasses = [
  'relative inline-flex shrink-0 cursor-pointer select-none items-center justify-center',
  'whitespace-nowrap align-middle font-medium leading-none',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  pressTransitionClasses,
  focusRingClasses,
  iconClasses
].join(' ');

/**
 * Off.
 *
 * The ink is `--neba-muted-fg` in all three, and that is the whole difference
 * from a Button: a Button in its resting state is an action waiting to be taken,
 * a toggle in its resting state is a *state that is currently false*. Accent ink
 * on an unpressed toggle would say it was on.
 */
const offClasses: Record<NebaVariant, string> = {
  solid: [
    surfaceClasses,
    'text-(--neba-muted-fg) bg-(--n-panel-hover)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]',
    'hover:bg-(--n-panel-press) hover:text-(--neba-fg)',
    'active:bg-(--n-panel-press)'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--neba-muted-fg) bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]',
    'hover:bg-(--n-panel-hover) hover:text-(--neba-fg) hover:[border-color:var(--n-line-hover)]',
    'active:bg-(--n-panel-press)'
  ].join(' '),
  text: [
    'text-(--neba-muted-fg) bg-transparent',
    'hover:bg-(--n-soft) hover:text-(--neba-fg)',
    'active:bg-(--n-soft-hover)'
  ].join(' ')
};

/**
 * On.
 *
 * The same two answers the chosen segment of a SegmentedButton gives, because
 * they are the same claim: `solid` takes the fill and the on-fill ink, the other
 * two light the sheet and leave the label in the accent. A toggle that is on is
 * not a toggle that is elevated — the depth does not change, only the colour.
 */
const onClasses: Record<NebaVariant, string> = {
  solid: [
    surfaceClasses,
    'text-(--n-on-solid) bg-(--n-fill)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]',
    'hover:bg-(--n-fill-hover)',
    'active:bg-(--n-fill-active)'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--n-accent) bg-(--n-soft)',
    '[border-color:var(--n-line-hover)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]',
    'hover:bg-(--n-soft-hover)',
    'active:bg-(--n-soft-press)'
  ].join(' '),
  text: [
    'text-(--n-accent) bg-(--n-soft)',
    'hover:bg-(--n-soft-hover)',
    'active:bg-(--n-soft-press)'
  ].join(' ')
};

/**
 * A button that stays down.
 *
 * The difference from a [Switch](./switch) is what the press *is*: a switch
 * changes a setting and the change is the point, a toggle changes the state of
 * the thing beside it — bold on the selected words, the grid on the canvas, the
 * filter on the list. The difference from a [Checkbox](./checkbox) is that this
 * one is a control rather than an answer, so it never goes in a form.
 *
 * Base UI's Toggle owns `aria-pressed` and the controlled/uncontrolled pair.
 * What is left here is the surface, and the rule that off is neutral.
 */
export const Toggle = React.forwardRef<HTMLButtonElement, ToggleProps>(
  function Toggle(rawProps, ref) {
    const {
      variant: variantProp,
      size: sizeProp,
      color: colorProp,
      density: densityProp,
      elevation: elevationProp,
      pressed,
      defaultPressed,
      onPressedChange,
      value,
      startIcon,
      endIcon,
      fullWidth = false,
      disabled: disabledProp,
      className,
      style,
      children,
      onPointerMove,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density', 'variant']);

    // A ToggleGroup and a ButtonGroup provide the same context, so a Toggle picks
    // up the set it is in either way. Its own prop still wins.
    const group = React.useContext(ButtonGroupContext);
    const variant = variantProp ?? group?.variant ?? 'outline';
    const size = sizeProp ?? group?.size ?? 'md';
    const color = colorProp ?? group?.color ?? 'primary';
    const density = densityProp ?? group?.density ?? 'default';
    const elevation = elevationProp ?? group?.elevation ?? 0;
    const disabled = disabledProp ?? group?.disabled ?? false;

    const iconOnly = children === undefined || children === null || children === false;

    return (
      <BaseUIToggle
        ref={ref}
        value={value}
        pressed={pressed}
        defaultPressed={defaultPressed}
        onPressedChange={(next) => onPressedChange?.(next)}
        disabled={disabled}
        className={(state) =>
          cx(
            baseClasses,
            sizeClasses[size],
            iconOnly ? iconOnlyClasses[size] : paddingXClasses[density][size],
            // An if/else rather than stacked `data-*` variants: two Tailwind
            // variants of equal specificity resolve by their order in the
            // generated stylesheet, and "pressed" and "disabled" would collide.
            disabled
              ? disabledClasses[variant]
              : state.pressed
                ? onClasses[variant]
                : offClasses[variant],
            disabled ? '' : 'neba-glow',
            fullWidth ? 'w-full' : '',
            className ?? ''
          )
        }
        style={{ ...controlSlots(color, elevation, variant), ...style }}
        onPointerMove={(event) => {
          // Feeds the two light layers in `styles.css`, exactly as Button does —
          // written straight to the element because this fires at pointer rate,
          // and only while `neba-glow` is on it to read them.
          if (!disabled) {
            const element = event.currentTarget;

            element.style.setProperty('--n-mx', `${event.nativeEvent.offsetX}px`);
            element.style.setProperty('--n-my', `${event.nativeEvent.offsetY}px`);
          }

          onPointerMove?.(event);
        }}
        {...props}
      >
        {startIcon}
        {children}
        {endIcon}
      </BaseUIToggle>
    );
  }
);

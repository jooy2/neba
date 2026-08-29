'use client';

import * as React from 'react';
import { actionMessages, useMessages } from '../../internal/i18n.js';
import { CloseIcon } from '../../internal/icons.js';
import { transitionProps } from '../../internal/animate.js';
import {
  chipRemoveClasses,
  controlHeightClasses,
  controlSlots,
  controlTextClasses,
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
import type { NebaElevation, NebaSize, NebaStyleProps, NebaTransition } from '../../types.js';

export interface ChipProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'span'>, 'color'> {
  /**
   * Drop shadow depth. `0` (the default) is flat. A chip is a token sitting on
   * something else, so this is raised even less often than on a Button.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * An entrance animation, run once on mount: `transition="fade"`, or an object
   * for the details. For a trigger, a replay or anything under your own
   * control, wrap it in an `Animate*` component instead.
   */
  transition?: NebaTransition;
  /** Content placed before the label — an icon, a status dot, an avatar. */
  startIcon?: React.ReactNode;
  /** Content placed after the label, before any `count`. */
  endIcon?: React.ReactNode;
  /**
   * A number set into the end of the chip. Rendered on its own small plate, so
   * "Errors 12" reads as one token with a count rather than as two words.
   */
  count?: React.ReactNode;
  /**
   * Called when the chip's delete affordance is pressed. Passing it is what
   * makes the affordance appear.
   */
  onDelete?: (event: React.MouseEvent<HTMLButtonElement>) => void;
  /**
   * Which language the delete button is named in — a BCP 47 tag such as `ko`, `pt-BR` or
   * `zh-Hant`. Unsupported tags fall back to English.
   *
   * `deleteLabel` writes the word out instead; this is for the far more common
   * case where the page already knows its own language.
   */
  locale?: string;
  /** Accessible name of the delete button. Defaults to the `locale`'s word. */
  deleteLabel?: string;
  /**
   * Marks the chip as chosen — a filter that is on. `selected` deepens the
   * surface a step rather than changing the colour family, so a row of chips
   * stays one row of chips.
   * @default false
   */
  selected?: boolean;
  /** Unavailable. Drops the colour family for neutral grey, as everywhere else. */
  disabled?: boolean;
  children?: React.ReactNode;
}

/**
 * A chip sits one step down the control ladder from everything else: a `md`
 * chip is a `sm` control — 26px, not 32px.
 *
 * This is the whole visual difference between a Chip and a Button, and it is
 * deliberate. A chip is a token *inside* a row of content, not a control the row
 * lines up against; at full control height an outline chip and an outline button
 * are the same object and a screen full of them says nothing about which one can
 * be pressed. Every other library reaches for a pill radius here, which this one
 * cannot — the flat run along a sheet's top and bottom edge is the point.
 *
 * Shifting the index rather than inventing a second set of numbers keeps a chip
 * inside the same five-step vocabulary, and keeps `xs` from falling off the
 * bottom of it.
 */
const chipScale: Record<NebaSize, NebaSize> = {
  xs: 'xs',
  sm: 'xs',
  md: 'sm',
  lg: 'md',
  xl: 'lg'
};

/**
 * The same three weights they mean everywhere: filled, hairline, none. A chip
 * *is* the thing being coloured, so unlike a Box its panel takes the tint.
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
  text: 'text-(--n-accent) bg-(--n-soft)'
};

/**
 * Selected is one step up the same ladder the chip is already on — the sheet
 * holds more light. Deliberately not a different colour family: a filter that is
 * on is still the same filter.
 */
const selectedClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: 'bg-(--n-fill-active)',
  outline: 'bg-(--n-panel-press) [border-color:var(--n-line-hover)]',
  text: 'bg-(--n-soft-press)'
};

/** Only a chip that can be pressed answers the pointer. */
const hoverClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: 'hover:bg-(--n-fill-hover) active:bg-(--n-fill-active)',
  outline:
    'hover:bg-(--n-panel-hover) hover:[border-color:var(--n-line-hover)] active:bg-(--n-panel-press)',
  text: 'hover:bg-(--n-soft-hover) active:bg-(--n-soft-press)'
};

const baseClasses = [
  // `items-center`, not `items-stretch`: everything in a chip — the icon, the
  // label, the count plate, the × — is centred on one line. The pressable label
  // asks for the height it needs with `self-stretch` instead, so making the
  // shell stretch to suit it would knock every other child off the centre line.
  'relative inline-flex max-w-full shrink-0 select-none items-center',
  'align-middle font-medium leading-none whitespace-nowrap',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  pressTransitionClasses,
  iconClasses
].join(' ');

/**
 * The label, when the chip is pressable, is its own `<button>` inside the shell
 * rather than the shell itself.
 *
 * That looks like indirection and is not: a chip can carry a delete affordance,
 * which has to be a button too, and a `<button>` inside a `<button>` is invalid
 * HTML that browsers un-nest on parse. Keeping the shell a `<span>` is what lets
 * "activate this chip" and "remove this chip" both be real, focusable buttons.
 *
 * `self-stretch` so its hit area is the full height of the chip rather than the
 * height of the words, and `rounded-[inherit]` so the focus ring traces the
 * shell's corners rather than drawing a second, squarer rectangle inside them.
 */
const labelButtonClasses = [
  'flex min-w-0 flex-1 cursor-pointer items-center justify-center self-stretch rounded-[inherit]',
  focusRingClasses
].join(' ');

/**
 * A compact token: a tag, a filter, a status, an entity plucked out of a list.
 *
 * The shell is always a `<span>`. What changes is what is inside it: a plain run
 * of content, or — when `onClick` is given — a real `<button>` wrapping that
 * content, plus a second button for `onDelete`. Both are reachable by keyboard,
 * and neither is nested inside the other.
 *
 * An inert `<span>` carrying a click handler is the single most common way a
 * component library loses its keyboard users, and a `<button>` inside a
 * `<button>` is the most common way it invents a chip that Chrome silently
 * rewrites. This shape is what avoids both.
 */
export const Chip = React.forwardRef<HTMLElement, ChipProps>(function Chip(
  {
    variant = 'outline',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    startIcon,
    endIcon,
    count,
    onDelete,
    locale,
    deleteLabel,
    transition,
    selected = false,
    disabled = false,
    className,
    style,
    children,
    onClick,
    ...props
  },
  ref
) {
  const messages = useMessages(actionMessages, locale);
  const interactive = Boolean(onClick) && !disabled;
  const step = chipScale[size];
  const animation = transitionProps(transition);

  const padX = paddingXClasses[density][step];

  const shellClasses = [
    baseClasses,
    controlHeightClasses[step],
    controlTextClasses[step],
    gapClasses[step],
    radiusClasses[step],
    // An if/else rather than stacked variants: two Tailwind classes of equal
    // specificity resolve by their order in the generated stylesheet.
    disabled ? disabledClasses[variant] : restClasses[variant],
    !disabled && selected ? selectedClasses[variant] : '',
    interactive ? hoverClasses[variant] : '',
    // With a pressable label the padding belongs to the button, so its hit area
    // covers the whole chip rather than just the words.
    interactive ? 'ps-0' : padX,
    // The delete button brings its own padding; stacking the chip's on top of it
    // would leave the × floating in the middle of a gap.
    onDelete ? 'pe-1' : interactive ? 'pe-0' : '',
    animation.className,
    className ?? ''
  ]
    .filter(Boolean)
    .join(' ');

  const label = (
    <>
      {startIcon}
      {children !== null && children !== undefined && children !== false ? (
        <span className="min-w-0 truncate">{children}</span>
      ) : null}
      {endIcon}
      {count !== null && count !== undefined && count !== false ? (
        <span
          className={[
            'ms-0.5 inline-flex shrink-0 items-center justify-center rounded-full px-1.5 py-px',
            'text-[0.85em] leading-none font-semibold tabular-nums',
            // On a filled chip the plate is a hole punched in the fill; on a
            // tinted or bare one it is the accent showing through.
            variant === 'solid'
              ? 'bg-(--neba-glow-on-fill) text-(--n-on-solid)'
              : 'bg-(--n-soft-press) text-(--n-accent)'
          ].join(' ')}
        >
          {count}
        </span>
      ) : null}
    </>
  );

  return (
    <span
      ref={ref as React.Ref<HTMLSpanElement>}
      className={shellClasses}
      style={{ ...controlSlots(color, elevation, variant), ...animation.style, ...style }}
      aria-disabled={disabled && !interactive ? true : undefined}
      {...props}
    >
      {interactive ? (
        <button
          type="button"
          aria-pressed={selected}
          className={`${labelButtonClasses} ${gapClasses[step]} ${padX}`}
          onClick={onClick as React.MouseEventHandler<HTMLButtonElement>}
        >
          {label}
        </button>
      ) : (
        label
      )}

      {onDelete ? (
        <button
          type="button"
          aria-label={deleteLabel ?? messages.remove}
          disabled={disabled}
          className={chipRemoveClasses}
          onClick={onDelete}
        >
          <CloseIcon />
        </button>
      ) : null}
    </span>
  );
});

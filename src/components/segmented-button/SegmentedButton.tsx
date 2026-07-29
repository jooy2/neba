import * as React from 'react';
import { Radio as BaseUIRadio } from '@base-ui/react/radio';
import { RadioGroup as BaseUIRadioGroup } from '@base-ui/react/radio-group';
import {
  controlHeightClasses,
  controlSlots,
  controlTextClasses,
  gapClasses,
  hasContent,
  iconClasses,
  paddingXClasses,
  surfaceClasses,
  transitionClasses
} from '../../internal/styles';
import type {
  NebaDensity,
  NebaElevation,
  NebaSize,
  NebaStyleProps,
  NebaVariant
} from '../../types';

/** A segment's value. The same restraint Tabs and Select put on theirs. */
export type SegmentValue = string | number;

/**
 * What a Segment inherits from the group around it.
 *
 * The same arrangement ButtonGroup, List, Tabs and Accordion use: `variant`,
 * `size` and `density` are properties of the *set*. A segmented button whose
 * third segment is a size out is not a segmented button.
 */
interface SegmentedButtonContextValue {
  variant: NebaVariant;
  size: NebaSize;
  density: NebaDensity;
  fullWidth: boolean;
}

const SegmentedButtonContext = React.createContext<SegmentedButtonContextValue>({
  variant: 'outline',
  size: 'md',
  density: 'default',
  fullWidth: false
});

export interface SegmentedButtonProps
  extends
    Omit<NebaStyleProps, 'variant'>,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'onChange'> {
  /**
   * Weight of the trough the segments sit in.
   *
   * - `solid` — a frosted trough with a filled tile riding in it. The loudest,
   *   and the one for a control a screen is about to be steered by.
   * - `outline` — the same trough with a hairline around it and a lit tile
   *   rather than a filled one. The default.
   * - `text` — no trough at all: the segments sit straight on the page and only
   *   the chosen one has a surface.
   * @default 'outline'
   */
  variant?: NebaVariant;
  /** The chosen segment. Use with `onValueChange` for a controlled set. */
  value?: SegmentValue | null;
  /** Which starts chosen, for an uncontrolled set. */
  defaultValue?: SegmentValue | null;
  onValueChange?: (value: SegmentValue | null) => void;
  /**
   * Drop shadow depth of the trough. `0` (the default) is flat.
   * @default 0
   */
  elevation?: NebaElevation;
  /** Disables every segment at once. */
  disabled?: boolean;
  /** Shows which one is chosen but does not let it be changed. */
  readOnly?: boolean;
  /** Identifies the value when a form is submitted. */
  name?: string;
  /** The segments share the full width, each taking an equal part of it. */
  fullWidth?: boolean;
  children?: React.ReactNode;
}

export interface SegmentProps extends Omit<
  React.ComponentPropsWithoutRef<'span'>,
  'value' | 'color'
> {
  /** Identifies the segment. What `onValueChange` reports. */
  value: SegmentValue;
  /** Content before the label. Sized in `em`, so it tracks the label. */
  startIcon?: React.ReactNode;
  /** Content after the label — a count, a status dot. */
  endIcon?: React.ReactNode;
  /** Unavailable, but still part of the set. */
  disabled?: boolean;
  children?: React.ReactNode;
}

/* ---------------------------------------------------------------------------
 * The trough and the tile
 * ------------------------------------------------------------------------- */

const troughClasses: Record<NebaVariant, string> = {
  solid: `${surfaceClasses} bg-(--n-panel) p-1 [box-shadow:var(--n-elev),var(--neba-plate-glass)]`,
  outline: `${surfaceClasses} border bg-(--n-panel) p-1 [border-color:var(--n-line)] [box-shadow:var(--n-elev),var(--neba-plate-glass)]`,
  text: ''
};

/**
 * The tile that slides.
 *
 * `solid` fills it with the colour family and puts the on-fill ink on the label;
 * the other two light the sheet instead and leave the label in the accent. All
 * three are the same object at three strengths, which is what `variant` means
 * everywhere else in the library.
 */
const tileClasses: Record<NebaVariant, string> = {
  solid: `${surfaceClasses} bg-(--n-fill) [box-shadow:var(--neba-shadow-1),var(--neba-plate-solid)]`,
  outline: `${surfaceClasses} bg-(--n-panel-press) [box-shadow:var(--neba-shadow-1),var(--neba-plate-glass)]`,
  text: `${surfaceClasses} bg-(--n-panel-press) [box-shadow:var(--neba-shadow-1),var(--neba-plate-glass)]`
};

/** What the chosen label is written in, which is the other half of the tile. */
const checkedTextClasses: Record<NebaVariant, string> = {
  solid: 'data-[checked]:text-(--n-on-solid)',
  outline: 'data-[checked]:text-(--n-accent)',
  text: 'data-[checked]:text-(--n-accent)'
};

/**
 * One choice in a segmented button.
 *
 * It has no `size`, no `color` and no `variant` of its own: all three belong to
 * the set, which is the only place they can be set once and mean the same thing
 * for every segment.
 */
export const Segment = React.forwardRef<HTMLElement, SegmentProps>(function Segment(
  { value, startIcon, endIcon, disabled = false, className, children, ...props },
  ref
) {
  const { variant, size, density, fullWidth } = React.useContext(SegmentedButtonContext);

  return (
    <BaseUIRadio.Root
      ref={ref}
      value={value}
      disabled={disabled}
      // The hook the indicator is measured from. A ref per segment would mean
      // keeping an array in step with however the caller composed them — through
      // a `.map()`, through a fragment, through a component of their own — and
      // one attribute is the version of that which cannot fall out of step.
      data-segment=""
      className={[
        // `z-10` and a stacking context of its own: the tile is painted behind
        // the segments, and without this it would cover the label it is under.
        'relative z-10 inline-flex shrink-0 cursor-pointer items-center justify-center select-none',
        'whitespace-nowrap font-medium',
        '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
        controlHeightClasses[size],
        controlTextClasses[size],
        gapClasses[size],
        paddingXClasses[density][size],
        // The one fully round shape the library allows besides Pill, and for the
        // same reason: this is not a sheet lying on the page, it is a tile riding
        // in a groove cut into one.
        'rounded-full',
        transitionClasses,
        iconClasses,
        'text-(--neba-muted-fg) hover:text-(--neba-fg)',
        checkedTextClasses[variant],
        // Inset rather than offset — an offset ring on a segment inside a trough
        // is drawn on top of its neighbours.
        'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:-2px]',
        'data-[disabled]:cursor-not-allowed data-[disabled]:text-(--neba-disabled-fg)',
        'data-[readonly]:cursor-default',
        fullWidth ? 'flex-1' : '',
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      {...props}
    >
      {hasContent(startIcon) ? (
        <span className="flex h-[1lh] shrink-0 items-center">{startIcon}</span>
      ) : null}
      {children}
      {hasContent(endIcon) ? (
        <span className="flex h-[1lh] shrink-0 items-center">{endIcon}</span>
      ) : null}
    </BaseUIRadio.Root>
  );
});

/**
 * Two or more choices in one pill, exactly one of them taken.
 *
 * Underneath it is a radio group, and that is the whole accessibility argument:
 * a segmented button *is* "exactly one of these", so it gets `role="radiogroup"`,
 * one tab stop for the set, arrow keys within it, and `aria-checked` on the one
 * that is taken. Building it out of `aria-pressed` toggles — which is what a row
 * of buttons would give — would announce four independent switches, three of
 * which happen to be off.
 *
 * The tile slides because its `left`, `top`, `width` and `height` are measured
 * off the chosen segment and animated. Nothing is transformed: the tile is an
 * empty box, and no label is resampled while it travels. That is the same
 * distinction Tabs' indicator draws, and the reason the house no-transform rule
 * survives a component whose entire point is that something moves.
 *
 * `left`, not `inset-inline-start`, for the reason Tabs gives: `offsetLeft` is a
 * distance from the left edge and stays one under RTL. Pairing a physical
 * measurement with a logical property is what would break the direction.
 */
export const SegmentedButton = React.forwardRef<HTMLDivElement, SegmentedButtonProps>(
  function SegmentedButton(
    {
      variant = 'outline',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      value: valueProp,
      defaultValue = null,
      onValueChange,
      disabled = false,
      readOnly = false,
      name,
      fullWidth = false,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const [uncontrolled, setUncontrolled] = React.useState<SegmentValue | null>(defaultValue);
    const controlled = valueProp !== undefined;
    const value = controlled ? valueProp : uncontrolled;

    const rootRef = React.useRef<HTMLDivElement>(null);
    const tileRef = React.useRef<HTMLSpanElement>(null);

    /**
     * Writes the chosen segment's box onto the tile as four custom properties.
     *
     * Written straight to the element rather than held in state, the way Button
     * writes the pointer position: a `setState` here would re-render the whole
     * set on every resize, and there is nothing in the tree that depends on the
     * numbers except four CSS declarations.
     *
     * `animate` is what separates the two callers. A value change is the thing
     * this component exists to animate; a resize is the container moving under a
     * tile that was already in the right place, and animating that is a tile
     * that lags behind the window being dragged.
     */
    const measure = React.useCallback((animate: boolean) => {
      const root = rootRef.current;
      const tile = tileRef.current;
      if (!root || !tile) {
        return;
      }

      const active = root.querySelector<HTMLElement>('[data-segment][data-checked]');
      if (!active) {
        return;
      }

      // A tile that has only just mounted has nowhere to travel *from*, so its
      // first placement is instant however it was asked for — that is what makes
      // the first choice of an empty set appear under the segment rather than
      // fly in from the left edge.
      const instant = !animate || !tile.hasAttribute('data-ready');
      if (instant) {
        tile.removeAttribute('data-ready');
      }

      // `offsetLeft`/`offsetTop` are measured from the offsetParent's padding
      // edge, and `left`/`top` on an absolutely positioned child resolve against
      // the same box — so the trough's own padding is already accounted for and
      // must not be subtracted again.
      tile.style.setProperty('--n-seg-x', `${active.offsetLeft}px`);
      tile.style.setProperty('--n-seg-y', `${active.offsetTop}px`);
      tile.style.setProperty('--n-seg-w', `${active.offsetWidth}px`);
      tile.style.setProperty('--n-seg-h', `${active.offsetHeight}px`);

      if (instant) {
        // Reading a layout property commits the four writes above while the
        // duration is still 0ms, so turning the transition back on cannot
        // animate a move that has already happened.
        void tile.offsetWidth;
      }

      tile.setAttribute('data-ready', '');
    }, []);

    // Before the browser paints, or the tile is visibly at nothing for a frame.
    React.useLayoutEffect(() => {
      measure(true);
    }, [measure, value, variant, size, density, fullWidth, children]);

    React.useEffect(() => {
      const root = rootRef.current;
      if (!root) {
        return;
      }

      const observer = new ResizeObserver(() => measure(false));
      observer.observe(root);
      return () => observer.disconnect();
    }, [measure]);

    const context = React.useMemo(
      () => ({ variant, size, density, fullWidth }),
      [variant, size, density, fullWidth]
    );

    return (
      <SegmentedButtonContext.Provider value={context}>
        <BaseUIRadioGroup
          ref={(node: HTMLDivElement | null) => {
            rootRef.current = node;
            if (typeof ref === 'function') {
              ref(node);
            } else if (ref) {
              ref.current = node;
            }
          }}
          value={value}
          onValueChange={(next) => {
            const chosen = (next ?? null) as SegmentValue | null;
            if (!controlled) {
              setUncontrolled(chosen);
            }
            onValueChange?.(chosen);
          }}
          disabled={disabled}
          readOnly={readOnly}
          name={name}
          className={[
            // `relative` is load-bearing twice over: it is what makes the trough
            // the segments' offsetParent, and what the tile is positioned in.
            'relative inline-flex items-center rounded-full',
            troughClasses[variant],
            transitionClasses,
            readOnly ? '[filter:saturate(0.55)]' : '',
            fullWidth ? 'flex w-full' : '',
            className ?? ''
          ]
            .filter(Boolean)
            .join(' ')}
          style={{ ...controlSlots(color, elevation, variant), ...style }}
          {...props}
        >
          {/* Rendered only once something is chosen. An empty set has no tile to
              slide, and mounting it on the first choice is what makes that first
              choice appear in place rather than fly in from the left edge. */}
          {value !== null && value !== undefined ? (
            <span
              ref={tileRef}
              aria-hidden="true"
              className={[
                'pointer-events-none absolute rounded-full',
                'left-(--n-seg-x) top-(--n-seg-y) h-(--n-seg-h) w-(--n-seg-w)',
                tileClasses[variant],
                '[transition-property:left,top,width,height]',
                '[transition-timing-function:var(--neba-ease)]',
                // Nothing until the first measurement has landed; the house
                // duration from then on.
                '[transition-duration:0ms] data-[ready]:[transition-duration:var(--neba-duration)]'
              ].join(' ')}
            />
          ) : null}

          {children}
        </BaseUIRadioGroup>
      </SegmentedButtonContext.Provider>
    );
  }
);

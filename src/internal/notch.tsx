import type * as React from 'react';
import { Field } from '@base-ui/react/field';
import { cx, metaTextValues, paddingXValues } from './styles.js';
import type { NebaDensity, NebaSize, NebaVariant } from '../types.js';

/**
 * A field's label on the field's own top edge, and the edge drawn around it.
 *
 * A label standing on the edge needs a gap in everything that edge is drawn
 * with — the border, the plate's top light and the focus ring — and none of
 * the three can be cut: a border is one line, a `box-shadow` is one shape and
 * an outline follows the whole box. So a notched shell drops its edge
 * (`fieldSheetClasses` in `internal/styles`) and this draws it instead, as
 * three pieces on a grid: the start, the gap under the label, and the end.
 *
 * The grid is what makes it CSS rather than a measurement. The middle column
 * is sized by the label itself, so the gap is as wide as the label in the
 * first frame the browser paints, server-rendered or not, and follows it when
 * the text changes or the font arrives late. Cutting a hole out of the shell
 * with a `clip-path` would need the label's width as a number, which only a
 * `ResizeObserver` can supply and only after the first paint.
 *
 * The first column is the corner's radius, so the gap opens where the top edge
 * stops curving. That puts the label a few pixels further in than the text
 * under it, which is the price of a radius this large: a gap cut into the
 * curve leaves the border ending in a hook.
 *
 * What the edge looks like in each state, the ring, and the resting position of
 * a `float` label are in `styles.css` under "The notch", as plain selectors.
 * They answer to the shell's hover and focus and to its control's emptiness,
 * which are three different elements, and the Tailwind form of that is not
 * something anybody should have to read. This file lays the pieces out and
 * hands the stylesheet its numbers.
 */

/** The gap on each side of the label, inside the notch. */
const gapValues: Record<NebaSize, string> = {
  xs: '0.1875rem',
  sm: '0.1875rem',
  md: '0.25rem',
  lg: '0.25rem',
  xl: '0.3125rem'
};

/**
 * The label's line box on the edge. Only its height matters: the label is
 * centred on the edge by it, and a line box as tall as the control's would
 * centre the text on nothing in particular.
 */
const floatLeadingValues: Record<NebaSize, string> = {
  xs: '0.75rem',
  sm: '0.875rem',
  md: '1rem',
  lg: '1rem',
  xl: '1.125rem'
};

/**
 * The control's own text, which is what a resting label is set in so that it
 * reads as the placeholder it stands in for. `controlTextLeadingClasses` in
 * `internal/styles` as raw lengths — keep the two in step.
 */
const restTextValues: Record<NebaSize, { size: string; leading: string }> = {
  xs: { size: '0.6875rem', leading: '0.875rem' },
  sm: { size: '0.75rem', leading: '1rem' },
  md: { size: '0.8125rem', leading: '1.25rem' },
  lg: { size: '0.9375rem', leading: '1.375rem' },
  xl: { size: '1.0625rem', leading: '1.625rem' }
};

interface NotchGeometry {
  size: NebaSize;
  density: NebaDensity;
  variant: NebaVariant;
  /**
   * How far the first line of text sits below the shell's inner edge, for a
   * shell whose text starts at the top rather than in the middle — a textarea.
   */
  firstLine?: string;
}

/**
 * The slots the stylesheet positions the label and sizes the grid with.
 *
 * Inline rather than classes for `styleSlots()`'s reason: they are numbers per
 * size and per density, and a class for each would be a ladder of arbitrary
 * values in the bundle of every page that draws a field.
 */
function notchSlots({ size, density, variant, firstLine }: NotchGeometry): React.CSSProperties {
  // An `outline` shell has a real, transparent 1px border, and the notch is
  // measured from its outer edge. The other two have none.
  const border = variant === 'outline' ? '1px' : '0px';
  const radius = `var(--neba-radius-${size})`;
  const gap = gapValues[size];
  const rest = restTextValues[size];

  return {
    '--n-notch-r': radius,
    '--n-notch-gap': gap,
    '--n-float-size': metaTextValues[size],
    '--n-float-leading': floatLeadingValues[size],
    '--n-rest-size': rest.size,
    '--n-rest-leading': rest.leading,
    '--n-rest-top':
      firstLine === undefined
        ? `calc(50% - ${rest.leading} / 2)`
        : `calc(${border} + ${firstLine})`,
    // Where the text starts, measured from where the label already is.
    '--n-rest-x': `calc(${border} + ${paddingXValues[density][size]} - ${radius} - ${gap})`
  } as React.CSSProperties;
}

export interface NotchFrameProps extends NotchGeometry {
  label: React.ReactNode;
  /** `classNames.label`, for anything in it that changes the label's width. */
  labelClassName?: string;
  /** For a frame the notch sits in, which then answers the hover and focus. */
  className?: string;
  children: React.ReactNode;
}

/**
 * The shell and the width of its label, in one cell.
 *
 * A label above a field is in the column the field stretches to, so a Select
 * whose options are all one short word is still as wide as its name. On the
 * edge the label is absolutely positioned and widens nothing, and the same
 * Select cut its own name short. The sizer is that name again at the size it
 * is drawn on the edge, with the corners and the gap on each side of it, laid
 * out at no height in the same grid cell as the shell — so the cell, and the
 * shell stretched across it, are never narrower than the notch needs.
 *
 * A string is drawn as generated content off `data-sample`, for
 * `WidthSizer`'s reason: it reserves the same width and leaves nothing for a
 * `getByText` to find twice. Only a label that is not a string is rendered a
 * second time.
 *
 * It also carries the geometry every piece inside it reads, once.
 */
export function NotchFrame({
  label,
  labelClassName,
  className,
  children,
  ...geometry
}: NotchFrameProps) {
  return (
    <span className={cx('neba-notch-frame', className)} style={notchSlots(geometry)}>
      {children}
      {typeof label === 'string' ? (
        <span
          aria-hidden="true"
          data-sample={label}
          className={cx('neba-notch-sizer font-medium', labelClassName)}
        />
      ) : (
        <span aria-hidden="true" className={cx('neba-notch-sizer font-medium', labelClassName)}>
          {label}
        </span>
      )}
    </span>
  );
}

export interface FieldNotchProps {
  label: React.ReactNode;
  variant: NebaVariant;
  disabled: boolean;
  readOnly: boolean;
  /**
   * The label comes down into the field while it is empty and idle. Only for
   * `float`, and only when nothing is drawn where it would rest.
   */
  rests: boolean;
  /**
   * The field is empty, for a component that knows it and has no control that
   * can say so itself — a multiple Combobox, whose chips are not an input.
   * Everything else leaves this out: an input says it through
   * `:placeholder-shown` and a trigger through `data-placeholder`, both of
   * which are right before any script has run.
   */
  empty?: boolean;
  /**
   * The notch sits beside the shell, in the frame, rather than inside it —
   * a Select's, whose shell is a `<button>`. It then starts at the frame's
   * edge instead of over the shell's border.
   */
  beside?: boolean;
  /** `classNames.label`. */
  labelClassName?: string;
  labelId?: string;
  htmlFor?: string;
}

/**
 * The edge and the label, inside a `NotchFrame`, as the last child of whatever
 * holds the control.
 *
 * It has to come after the control: a resting label reads the control's
 * emptiness through `~`, which only looks forward. And it has to be a child of
 * the element whose hover and focus the edge answers to, which is the shell
 * for every field but a Select — whose shell is a `<button>`, and a `<label>`
 * cannot go inside one.
 */
export function FieldNotch({
  label,
  variant,
  disabled,
  readOnly,
  rests,
  empty,
  beside = false,
  labelClassName,
  labelId,
  htmlFor
}: FieldNotchProps) {
  return (
    <span
      className={cx('neba-notch', rests && 'neba-notch-float')}
      data-variant={variant}
      data-state={disabled ? 'disabled' : readOnly ? 'read-only' : undefined}
      data-empty={empty || undefined}
      // Inside an `outline` shell the notch is laid over the transparent
      // border rather than inside it.
      style={
        !beside && variant === 'outline'
          ? ({ '--n-notch-inset': '-1px' } as React.CSSProperties)
          : undefined
      }
    >
      <span className="neba-notch-start" />
      <span className="neba-notch-gap" />
      <span className="neba-notch-end" />
      <Field.Label
        // Only when given: Base UI merges these over the id and the `for` it
        // wires up itself, and an `undefined` written here would win.
        {...(labelId === undefined ? undefined : { id: labelId })}
        {...(htmlFor === undefined ? undefined : { htmlFor })}
        className={cx(
          'neba-notch-label font-medium',
          // A resting label takes the placeholder's colour through the slot,
          // which the stylesheet sets; a disabled one keeps the disabled ink
          // wherever it is, as every other part of a disabled field does.
          disabled ? 'text-(--neba-disabled-fg)' : 'text-[var(--n-label-ink,var(--neba-fg))]',
          labelClassName
        )}
      >
        {label}
      </Field.Label>
    </span>
  );
}

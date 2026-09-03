'use client';

import * as React from 'react';
import { Checkbox as BaseUICheckbox } from '@base-ui/react/checkbox';
import { Field } from '@base-ui/react/field';
import {
  controlTextClasses,
  cx,
  hitAreaClasses,
  metaTextClasses,
  surfaceClasses,
  tickRadiusClasses,
  tickRowLeadingClasses,
  tickSizeClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaColor, NebaFieldSlot, NebaSize, NebaSlots } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/**
 * Base UI's own props, minus the ones this component owns: `className` and
 * `style` land on the field wrapper rather than on the tick, and `render` would
 * replace the tick with something that is no longer a checkbox.
 */
type BaseCheckboxProps = Omit<
  React.ComponentPropsWithoutRef<typeof BaseUICheckbox.Root>,
  'className' | 'style' | 'render' | 'children'
>;

/**
 * The parts a Checkbox draws behind its root.
 *
 * `control` is the tick itself — the bordered box that fills when checked — and
 * `indicator` is the mark inside it.
 */
export type CheckboxSlot = NebaFieldSlot | 'indicator';

export interface CheckboxProps extends BaseCheckboxProps {
  /** @default 'md' */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
  /** The text beside the tick. Wired to it by Base UI's Field. */
  label?: React.ReactNode;
  /** Helper text under the label. */
  description?: React.ReactNode;
  /** Error message below. Its presence also turns the checkbox invalid. */
  error?: React.ReactNode;
  /**
   * Forces the invalid state without a message — for when an external form
   * library owns the validity. Defaults to whether `error` has content.
   */
  invalid?: boolean;
  /** Class names for the field wrapper, not for the tick itself. */
  className?: string;
  /**
   * Class names for the parts behind that wrapper — the tick is
   * `classNames.control`.
   */
  classNames?: NebaSlots<CheckboxSlot>;
  style?: React.CSSProperties;
}

/**
 * The tick.
 *
 * Unchecked it is the same frosted panel with a hairline that an `outline`
 * Button is, at 18px. Checked it fills with the colour family — which is the one
 * place this library expresses a state by swapping the whole surface rather than
 * shifting it a step, because "on" and "off" are not two strengths of the same
 * thing.
 */
const tickBaseClasses = [
  'relative inline-flex shrink-0 items-center justify-center border',
  // The tick is 18px because it is sized against the text beside it. A finger
  // is not, and a Checkbox with no label — a table's tick column — has nothing
  // else to press. This grows the target and draws nothing.
  hitAreaClasses,
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  'active:[transition-duration:0ms]',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2'
].join(' ');

/**
 * No plate on a tick, and that is the one place this library deliberately does
 * without one.
 *
 * `--neba-plate-glass` is a 1px white line along the top edge and
 * `--neba-plate-solid` adds a full white hairline around the box. On a 32px
 * button that reads as light catching a cut edge; on an 18px square it is a
 * bevel drawn at a quarter of the object's size, and a bevel that big on
 * something that small reads as a 2008 toolbar icon rather than as acrylic.
 *
 * The surface stays — the grain, the sheen and the backdrop blur are what make
 * the box a sheet of something. It is only the highlight that goes.
 */
const restClasses = [
  surfaceClasses,
  'cursor-pointer bg-(--n-panel) [border-color:var(--n-line)]',
  'hover:bg-(--n-panel-hover) hover:[border-color:var(--n-line-hover)]',
  // `data-checked` rather than `:checked`: the visible tick is a `<span>`, and
  // the real input is hidden beside it.
  'data-[checked]:bg-(--n-fill) data-[checked]:text-(--n-on-solid)',
  'data-[checked]:[border-color:transparent]',
  'data-[checked]:hover:bg-(--n-fill-hover)',
  'data-[indeterminate]:bg-(--n-fill) data-[indeterminate]:text-(--n-on-solid)',
  'data-[indeterminate]:[border-color:transparent]'
].join(' ');

const readOnlyClasses = [
  surfaceClasses,
  'cursor-default bg-(--n-panel) [border-color:var(--n-line)]',
  '[filter:saturate(0.55)]',
  'data-[checked]:bg-(--n-fill) data-[checked]:text-(--n-on-solid)',
  'data-[checked]:[border-color:transparent]'
].join(' ');

/** Disabled drops the colour family entirely, exactly as on Button. */
const disabledTickClasses = [
  'cursor-not-allowed bg-transparent [border-color:var(--neba-disabled-border)]',
  'text-(--neba-disabled-fg) shadow-none',
  'data-[checked]:bg-(--neba-disabled-bg)',
  'data-[indeterminate]:bg-(--neba-disabled-bg)'
].join(' ');

/**
 * The mark is drawn at 70% of the box, so it never touches the corners — and it
 * is *drawn*, rather than switched on.
 *
 * The box already answers a click in colour, over `--neba-duration-fill`. The
 * mark inside it did not answer at all: it was there on one frame and gone on
 * the next, which is the one moment a checkbox has to be legible and the one
 * moment it was hardest to read. A stroke that arrives along its own length is
 * the transform-free way to say it — nothing moves, nothing is resampled, the
 * line simply is not finished yet.
 *
 * `pathLength="1"` below is what makes it one number rather than two: the tick
 * and the dash are different lengths, and normalising the path lets a single
 * `stroke-dasharray` cover both without either having to be measured.
 *
 * The `opacity` transition on the indicator itself is not decoration. Base UI
 * holds the element mounted for as long as `getAnimations()` on *that element*
 * reports something running, and that call does not look into the subtree — a
 * transition living only on the `path` would be cut off on the frame the
 * checkbox was cleared, so the mark would draw itself in and then vanish.
 */
const markClasses = [
  'flex size-[70%] items-center justify-center',
  '[transition:opacity_var(--neba-duration)_var(--neba-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0',
  '[&_path]:[stroke-dasharray:1]',
  '[&_path]:[transition:stroke-dashoffset_var(--neba-duration)_var(--neba-ease)]',
  '[&[data-starting-style]_path]:[stroke-dashoffset:1]',
  '[&[data-ending-style]_path]:[stroke-dashoffset:1]'
].join(' ');

function CheckMark() {
  return (
    <svg viewBox="0 0 12 12" fill="none" aria-hidden="true" className="size-full">
      <path
        d="M2 6.2 4.6 8.8 10 3.4"
        pathLength="1"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function DashMark() {
  return (
    <svg viewBox="0 0 12 12" fill="none" aria-hidden="true" className="size-full">
      <path
        d="M2.5 6h7"
        pathLength="1"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
      />
    </svg>
  );
}

/**
 * A single yes/no, or one member of a set of them.
 *
 * `label`, `description` and `error` are props rather than children for the same
 * reason they are on TextField: the arrangement is fixed and what a caller wants
 * to decide is what goes in each slot. `children` is not accepted at all —
 * anything a checkbox has to say belongs in one of the three.
 */
export const Checkbox = React.forwardRef<HTMLElement, CheckboxProps>(
  function Checkbox(rawProps, ref) {
    const {
      size = 'md',
      color = 'primary',
      label,
      description,
      error,
      invalid,
      disabled = false,
      readOnly = false,
      className,
      classNames,
      style,
      ...props
    } = useStyleDefaults(rawProps, ['size']);

    const hasError = error !== undefined && error !== null && error !== false && error !== '';
    const isInvalid = invalid ?? hasError;
    // Invalid re-points the whole slot family at `danger`, so the tick, the ring
    // and the message all turn over together.
    const family: NebaColor = isInvalid ? 'danger' : color;

    const slots = {
      '--n-fill': `var(--neba-${family}-fill)`,
      '--n-fill-hover': `var(--neba-${family}-fill-hover)`,
      '--n-on-solid': `var(--neba-${family}-on-solid)`,
      '--n-accent': `var(--neba-${family}-accent)`,
      '--n-panel': 'var(--neba-panel)',
      '--n-panel-hover': 'var(--neba-panel-hover)',
      '--n-line': `var(--neba-${family}-line)`,
      '--n-line-hover': `var(--neba-${family}-line-hover)`,
      '--n-ring': `var(--neba-${family}-ring)`
    } as React.CSSProperties;

    const tickClasses = [
      tickBaseClasses,
      tickSizeClasses[size],
      tickRadiusClasses[size],
      // An if/else rather than stacked variants: two Tailwind classes of equal
      // specificity resolve by their order in the generated stylesheet.
      disabled ? disabledTickClasses : readOnly ? readOnlyClasses : restClasses
    ].join(' ');

    return (
      <Field.Root
        disabled={disabled}
        invalid={isInvalid}
        className={cx('inline-flex flex-col gap-1 align-top', className ?? '')}
        style={{ ...slots, ...style }}
      >
        <div
          className={`flex items-start gap-2 ${controlTextClasses[size]} ${tickRowLeadingClasses}`}
        >
          {/* `1lh` centres the tick on the first line of the label rather than on
            the whole block, so it stays put when the label wraps to three. The
            leading is pinned on the row above so `1lh` and the label's own line
            box are the same number. */}
          <span className="flex h-[1lh] shrink-0 items-center">
            <BaseUICheckbox.Root
              ref={ref}
              className={cx(tickClasses, classNames?.control)}
              disabled={disabled}
              readOnly={readOnly}
              {...props}
            >
              <BaseUICheckbox.Indicator className={cx(markClasses, classNames?.indicator)}>
                {props.indeterminate ? <DashMark /> : <CheckMark />}
              </BaseUICheckbox.Indicator>
            </BaseUICheckbox.Root>
          </span>

          {label || description ? (
            <span className="flex min-w-0 flex-col gap-0.5">
              {label ? (
                <Field.Label
                  className={cx(
                    'leading-[1.4]',
                    disabled ? 'text-(--neba-disabled-fg)' : 'cursor-pointer text-(--neba-fg)',
                    classNames?.label
                  )}
                >
                  {label}
                </Field.Label>
              ) : null}
              {description ? (
                <Field.Description
                  className={cx(
                    metaTextClasses[size],
                    'text-(--neba-muted-fg)',
                    classNames?.description
                  )}
                >
                  {description}
                </Field.Description>
              ) : null}
            </span>
          ) : null}
        </div>

        {hasError ? (
          <Field.Error
            match
            className={cx(metaTextClasses[size], 'text-(--n-accent)', classNames?.error)}
          >
            {error}
          </Field.Error>
        ) : (
          // No message of our own, so whatever the validity has: the browser's
          // own text for a failed constraint, or the entry a Form's `errors`
          // put here. Renders nothing at all while the field is valid.
          <Field.Error
            className={cx(metaTextClasses[size], 'text-(--n-accent)', classNames?.error)}
          />
        )}
      </Field.Root>
    );
  }
);

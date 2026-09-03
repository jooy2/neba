'use client';

import * as React from 'react';
import { Radio as BaseUIRadio } from '@base-ui/react/radio';
import { RadioGroup as BaseUIRadioGroup } from '@base-ui/react/radio-group';
import { Field } from '@base-ui/react/field';
import {
  controlTextClasses,
  cx,
  hitAreaClasses,
  metaTextClasses,
  surfaceClasses,
  tickDotClasses,
  tickRowLeadingClasses,
  tickSizeClasses,
  transitionClasses
} from '../../internal/styles.js';
import type {
  NebaColor,
  NebaFieldSlot,
  NebaOrientation,
  NebaSize,
  NebaSlots
} from '../../types.js';

/**
 * What a Radio inherits from the group around it.
 *
 * A radio button is meaningless alone — it only says anything relative to its
 * siblings — so `size`, `color` and the read-only state belong to the set, not
 * to the member. Passing them on every `<Radio>` would be four chances to get
 * one of them wrong.
 */
interface RadioGroupContextValue {
  size: NebaSize;
  color: NebaColor;
  readOnly: boolean;
}

const RadioGroupContext = React.createContext<RadioGroupContextValue>({
  size: 'md',
  color: 'primary',
  readOnly: false
});

/**
 * The parts a RadioGroup draws behind its root. `control` is the element that
 * holds the options — the one carrying the row or column direction — and not
 * any single Radio, which has slots of its own.
 */
export type RadioGroupSlot = NebaFieldSlot;

/**
 * The parts one Radio draws. There is no `error`: a validity message belongs to
 * the question, and the question is the group.
 */
export type RadioSlot = Exclude<NebaFieldSlot, 'error'> | 'indicator';

export interface RadioGroupProps extends Omit<
  React.ComponentPropsWithoutRef<typeof BaseUIRadioGroup>,
  'className' | 'style' | 'render'
> {
  /** @default 'md' */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
  /**
   * Which way the options stack. Vertical by default — a column of options is
   * scannable at any length, and a row silently becomes unreadable the moment
   * one label is longer than expected.
   * @default 'vertical'
   */
  orientation?: NebaOrientation;
  /** The question the options answer. Rendered as the group's legend. */
  label?: React.ReactNode;
  /** Helper text under the label. */
  description?: React.ReactNode;
  /** Error message below the options. Its presence also turns the group invalid. */
  error?: React.ReactNode;
  /** Forces the invalid state without a message. Defaults to `!!error`. */
  invalid?: boolean;
  className?: string;
  /**
   * Class names for the parts behind the root. The element holding the options
   * is `classNames.control`; a single option is styled on the Radio itself.
   */
  classNames?: NebaSlots<RadioGroupSlot>;
  style?: React.CSSProperties;
}

export interface RadioProps extends Omit<
  React.ComponentPropsWithoutRef<typeof BaseUIRadio.Root>,
  'className' | 'style' | 'render' | 'children'
> {
  /** The text beside the dot. Wired to it by Base UI's Field. */
  label?: React.ReactNode;
  /** Helper text under the label. */
  description?: React.ReactNode;
  className?: string;
  /**
   * Class names for the parts behind the root — the dot is
   * `classNames.control`.
   */
  classNames?: NebaSlots<RadioSlot>;
  style?: React.CSSProperties;
}

/**
 * The dot. Round, and the only thing in the library that is allowed to be —
 * roundness is exactly what tells a reader "one of these" rather than "any of
 * these", and it is the one convention old enough that breaking it would cost
 * more than it bought.
 */
const dotBaseClasses = [
  'relative inline-flex shrink-0 items-center justify-center rounded-full border',
  // The same target a Checkbox gets, for the same reason: the ring is sized
  // against the label's text, and a finger is bigger than text.
  hitAreaClasses,
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  'active:[transition-duration:0ms]',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2'
].join(' ');

/**
 * No plate, for the reason Checkbox's tick has none: a 1px white hairline is
 * light on a cut edge at 32px and a bevel at 18px. The acrylic surface stays;
 * only the highlight goes.
 */
const restDotClasses = [
  surfaceClasses,
  'cursor-pointer bg-(--n-panel) [border-color:var(--n-line)]',
  'hover:bg-(--n-panel-hover) hover:[border-color:var(--n-line-hover)]',
  'data-[checked]:bg-(--n-fill) data-[checked]:text-(--n-on-solid)',
  'data-[checked]:[border-color:transparent]',
  'data-[checked]:hover:bg-(--n-fill-hover)'
].join(' ');

const readOnlyDotClasses = [
  surfaceClasses,
  'cursor-default bg-(--n-panel) [border-color:var(--n-line)]',
  '[filter:saturate(0.55)]',
  'data-[checked]:bg-(--n-fill) data-[checked]:text-(--n-on-solid)',
  'data-[checked]:[border-color:transparent]'
].join(' ');

const disabledDotClasses = [
  'cursor-not-allowed bg-transparent [border-color:var(--neba-disabled-border)] shadow-none',
  'data-[checked]:bg-(--neba-disabled-bg)'
].join(' ');

/**
 * The inner dot: `currentColor`, so it inherits the on-fill ink — and it grows
 * into the ring rather than appearing whole inside it.
 *
 * The ring answers a click in colour over `--neba-duration-fill`; the dot did
 * not answer at all, which left the one mark that says *which* option was
 * chosen as the only part of the control that jumped. It grows from nothing at
 * the centre, which is what the flex row above already puts it at.
 *
 * `width` and `height` rather than a `scale`, for the reason the house style
 * gives everywhere else: nothing in this library is resampled to say something
 * about its state. It is also what keeps the exit working — Base UI holds the
 * element mounted for as long as `getAnimations()` on it reports something
 * running, and these two are on the element itself.
 */
const indicatorClasses = [
  'rounded-full bg-current',
  '[transition:width_var(--neba-duration)_var(--neba-ease),height_var(--neba-duration)_var(--neba-ease)]',
  'data-[starting-style]:size-0 data-[ending-style]:size-0'
].join(' ');

/**
 * One option in a RadioGroup.
 *
 * It has no `size` and no `color` of its own — both come from the group, which
 * is the only place they can be set once and mean the same thing for every
 * option in the set.
 */
export const Radio = React.forwardRef<HTMLElement, RadioProps>(function Radio(
  { label, description, disabled = false, className, classNames, style, ...props },
  ref
) {
  const group = React.useContext(RadioGroupContext);
  const readOnly = props.readOnly ?? group.readOnly;

  return (
    <Field.Root disabled={disabled} className={cx('flex flex-col', className ?? '')} style={style}>
      <div
        className={`flex items-start gap-2 ${controlTextClasses[group.size]} ${tickRowLeadingClasses}`}
      >
        {/* `1lh` centres the dot on the first line of the label, and the row
            pins the leading so `1lh` is the label's line box and not the host
            page's. */}
        <span className="flex h-[1lh] shrink-0 items-center">
          <BaseUIRadio.Root
            ref={ref}
            className={cx(
              dotBaseClasses,
              tickSizeClasses[group.size],
              disabled ? disabledDotClasses : readOnly ? readOnlyDotClasses : restDotClasses,
              classNames?.control
            )}
            disabled={disabled}
            {...props}
          >
            <BaseUIRadio.Indicator
              className={cx(indicatorClasses, tickDotClasses[group.size], classNames?.indicator)}
            />
          </BaseUIRadio.Root>
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
                  metaTextClasses[group.size],
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
    </Field.Root>
  );
});

/**
 * A set of options where exactly one is chosen.
 *
 * Base UI owns the roving tab index and the arrow-key navigation, which is the
 * whole reason a radio group is a component at all rather than a `<div>` full of
 * inputs: the set takes one tab stop, and the arrows move within it.
 */
export const RadioGroup = React.forwardRef<HTMLDivElement, RadioGroupProps>(function RadioGroup(
  {
    size = 'md',
    color = 'primary',
    orientation = 'vertical',
    label,
    description,
    error,
    invalid,
    disabled = false,
    readOnly = false,
    className,
    classNames,
    style,
    children,
    ...props
  },
  ref
) {
  const hasError = error !== undefined && error !== null && error !== false && error !== '';
  const isInvalid = invalid ?? hasError;
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

  const context = React.useMemo(
    () => ({ size, color: family, readOnly }),
    [size, family, readOnly]
  );

  return (
    <RadioGroupContext.Provider value={context}>
      <Field.Root
        disabled={disabled}
        invalid={isInvalid}
        className={cx('flex flex-col gap-1.5', className ?? '')}
        style={{ ...slots, ...style }}
      >
        {label ? (
          <Field.Label
            className={cx(
              metaTextClasses[size],
              'font-medium',
              disabled ? 'text-(--neba-disabled-fg)' : 'text-(--neba-fg)',
              classNames?.label
            )}
          >
            {label}
          </Field.Label>
        ) : null}

        {description ? (
          <Field.Description
            className={cx(metaTextClasses[size], 'text-(--neba-muted-fg)', classNames?.description)}
          >
            {description}
          </Field.Description>
        ) : null}

        <BaseUIRadioGroup
          ref={ref}
          disabled={disabled}
          readOnly={readOnly}
          className={cx(
            'flex',
            orientation === 'horizontal' ? 'flex-row flex-wrap gap-x-5 gap-y-2' : 'flex-col gap-2',
            classNames?.control
          )}
          {...props}
        >
          {children}
        </BaseUIRadioGroup>

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
    </RadioGroupContext.Provider>
  );
});

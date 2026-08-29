'use client';

import * as React from 'react';
import { Radio as BaseUIRadio } from '@base-ui/react/radio';
import { RadioGroup as BaseUIRadioGroup } from '@base-ui/react/radio-group';
import { Field } from '@base-ui/react/field';
import {
  controlTextClasses,
  metaTextClasses,
  surfaceClasses,
  tickDotClasses,
  tickRowLeadingClasses,
  tickSizeClasses,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaColor, NebaOrientation, NebaSize } from '../../types.js';

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

/** The inner dot: `currentColor`, so it inherits the on-fill ink. */
const indicatorClasses = 'rounded-full bg-current';

/**
 * One option in a RadioGroup.
 *
 * It has no `size` and no `color` of its own — both come from the group, which
 * is the only place they can be set once and mean the same thing for every
 * option in the set.
 */
export const Radio = React.forwardRef<HTMLElement, RadioProps>(function Radio(
  { label, description, disabled = false, className, style, ...props },
  ref
) {
  const group = React.useContext(RadioGroupContext);
  const readOnly = props.readOnly ?? group.readOnly;

  return (
    <Field.Root
      disabled={disabled}
      className={['flex flex-col', className ?? ''].filter(Boolean).join(' ')}
      style={style}
    >
      <div
        className={`flex items-start gap-2 ${controlTextClasses[group.size]} ${tickRowLeadingClasses}`}
      >
        {/* `1lh` centres the dot on the first line of the label, and the row
            pins the leading so `1lh` is the label's line box and not the host
            page's. */}
        <span className="flex h-[1lh] shrink-0 items-center">
          <BaseUIRadio.Root
            ref={ref}
            className={[
              dotBaseClasses,
              tickSizeClasses[group.size],
              disabled ? disabledDotClasses : readOnly ? readOnlyDotClasses : restDotClasses
            ].join(' ')}
            disabled={disabled}
            {...props}
          >
            <BaseUIRadio.Indicator
              className={`${indicatorClasses} ${tickDotClasses[group.size]}`}
            />
          </BaseUIRadio.Root>
        </span>

        {label || description ? (
          <span className="flex min-w-0 flex-col gap-0.5">
            {label ? (
              <Field.Label
                className={[
                  'leading-[1.4]',
                  disabled ? 'text-(--neba-disabled-fg)' : 'cursor-pointer text-(--neba-fg)'
                ].join(' ')}
              >
                {label}
              </Field.Label>
            ) : null}
            {description ? (
              <Field.Description
                className={`${metaTextClasses[group.size]} text-(--neba-muted-fg)`}
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
        className={['flex flex-col gap-1.5', className ?? ''].filter(Boolean).join(' ')}
        style={{ ...slots, ...style }}
      >
        {label ? (
          <Field.Label
            className={[
              metaTextClasses[size],
              'font-medium',
              disabled ? 'text-(--neba-disabled-fg)' : 'text-(--neba-fg)'
            ].join(' ')}
          >
            {label}
          </Field.Label>
        ) : null}

        {description ? (
          <Field.Description className={`${metaTextClasses[size]} text-(--neba-muted-fg)`}>
            {description}
          </Field.Description>
        ) : null}

        <BaseUIRadioGroup
          ref={ref}
          disabled={disabled}
          readOnly={readOnly}
          className={[
            'flex',
            orientation === 'horizontal' ? 'flex-row flex-wrap gap-x-5 gap-y-2' : 'flex-col gap-2'
          ].join(' ')}
          {...props}
        >
          {children}
        </BaseUIRadioGroup>

        {hasError ? (
          <Field.Error match className={`${metaTextClasses[size]} text-(--n-accent)`}>
            {error}
          </Field.Error>
        ) : null}
      </Field.Root>
    </RadioGroupContext.Provider>
  );
});

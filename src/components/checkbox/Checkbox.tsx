import * as React from 'react';
import { Checkbox as BaseUICheckbox } from '@base-ui/react/checkbox';
import { Field } from '@base-ui/react/field';
import {
  controlTextClasses,
  metaTextClasses,
  surfaceClasses,
  tickRadiusClasses,
  tickSizeClasses,
  transitionClasses
} from '../../internal/styles';
import type { NebaColor, NebaSize } from '../../types';

/**
 * Base UI's own props, minus the ones this component owns: `className` and
 * `style` land on the field wrapper rather than on the tick, and `render` would
 * replace the tick with something that is no longer a checkbox.
 */
type BaseCheckboxProps = Omit<
  React.ComponentPropsWithoutRef<typeof BaseUICheckbox.Root>,
  'className' | 'style' | 'render' | 'children'
>;

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
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  'active:[transition-duration:0ms]',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2'
].join(' ');

const restClasses = [
  surfaceClasses,
  'cursor-pointer bg-(--n-panel) [border-color:var(--n-line)]',
  '[box-shadow:var(--neba-plate-glass)]',
  'hover:bg-(--n-panel-hover) hover:[border-color:var(--n-line-hover)]',
  // `data-checked` rather than `:checked`: the visible tick is a `<span>`, and
  // the real input is hidden beside it.
  'data-[checked]:bg-(--n-fill) data-[checked]:text-(--n-on-solid)',
  'data-[checked]:[border-color:transparent]',
  'data-[checked]:[box-shadow:var(--neba-plate-solid)]',
  'data-[checked]:hover:bg-(--n-fill-hover)',
  'data-[indeterminate]:bg-(--n-fill) data-[indeterminate]:text-(--n-on-solid)',
  'data-[indeterminate]:[border-color:transparent]'
].join(' ');

const readOnlyClasses = [
  surfaceClasses,
  'cursor-default bg-(--n-panel) [border-color:var(--n-line)]',
  '[box-shadow:var(--neba-plate-glass)] [filter:saturate(0.55)]',
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

/** The mark is drawn at 70% of the box, so it never touches the corners. */
const markClasses = 'flex size-[70%] items-center justify-center';

function CheckMark() {
  return (
    <svg viewBox="0 0 12 12" fill="none" aria-hidden="true" className="size-full">
      <path
        d="M2 6.2 4.6 8.8 10 3.4"
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
      <path d="M2.5 6h7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
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
export const Checkbox = React.forwardRef<HTMLElement, CheckboxProps>(function Checkbox(
  {
    size = 'md',
    color = 'primary',
    label,
    description,
    error,
    invalid,
    disabled = false,
    readOnly = false,
    className,
    style,
    ...props
  },
  ref
) {
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
      className={['inline-flex flex-col gap-1 align-top', className ?? '']
        .filter(Boolean)
        .join(' ')}
      style={{ ...slots, ...style }}
    >
      <div className={`flex items-start gap-2 ${controlTextClasses[size]}`}>
        {/* `1lh` centres the tick on the first line of the label rather than on
            the whole block, so it stays put when the label wraps to three. */}
        <span className="flex h-[1lh] shrink-0 items-center">
          <BaseUICheckbox.Root
            ref={ref}
            className={tickClasses}
            disabled={disabled}
            readOnly={readOnly}
            {...props}
          >
            <BaseUICheckbox.Indicator className={markClasses}>
              {props.indeterminate ? <DashMark /> : <CheckMark />}
            </BaseUICheckbox.Indicator>
          </BaseUICheckbox.Root>
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
              <Field.Description className={`${metaTextClasses[size]} text-(--neba-muted-fg)`}>
                {description}
              </Field.Description>
            ) : null}
          </span>
        ) : null}
      </div>

      {hasError ? (
        <Field.Error match className={`${metaTextClasses[size]} text-(--n-accent)`}>
          {error}
        </Field.Error>
      ) : null}
    </Field.Root>
  );
});

import * as React from 'react';
import { NumberField as BaseUINumberField } from '@base-ui/react/number-field';
import { Field } from '@base-ui/react/field';
import { useMessages } from '../../internal/i18n';
import { MinusIcon, PlusIcon } from '../../internal/icons';
import {
  controlHeightClasses,
  controlTextLeadingClasses,
  disabledClasses,
  fieldReadOnlyClasses,
  fieldRestClasses,
  focusWithinRingClasses,
  gapClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  stackGapClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles';
import type { NebaColor, NebaElevation, NebaStyleProps } from '../../types';

/**
 * Where the two steppers sit.
 *
 * - `end` — both at the trailing edge, the way a spinner has always looked.
 * - `split` — minus at the start, plus at the end, with the number between
 *   them. For a quantity that is nudged rather than typed.
 * - `none` — no buttons. The field is still a number field: the arrow keys,
 *   the clamping and the formatting all stay.
 *
 * There is deliberately no stacked pair of half-height chevrons. At `xs` each
 * arrow would be under three pixels tall, and a target that small is a target
 * nobody hits.
 */
export type NumberFieldSteppers = 'end' | 'split' | 'none';

export interface NumberFieldProps
  extends
    NebaStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'children'> {
  /**
   * Drop shadow depth. `0` (the default) is flat — a field is a well, not a
   * surface that floats.
   * @default 0
   */
  elevation?: NebaElevation;
  /** The number. Use with `onValueChange` for a controlled field. */
  value?: number | null;
  /** The initial number, for an uncontrolled field. */
  defaultValue?: number;
  /** Called on every change — typing, stepping, the wheel. */
  onValueChange?: (value: number | null) => void;
  /**
   * Called when the value settles: on blur after typing, on pointer release
   * after a press, and together with `onValueChange` for the keyboard.
   */
  onValueCommitted?: (value: number | null) => void;
  /** The bottom of the range. Stepping stops here. */
  min?: number;
  /** The top of the range. */
  max?: number;
  /** How far one step goes. `'any'` turns step validation off. @default 1 */
  step?: number | 'any';
  /** The step taken while Shift is held. @default 10 */
  largeStep?: number;
  /** The step taken while Alt is held. @default 0.1 */
  smallStep?: number;
  /** Whether stepping snaps to multiples of the step. @default false */
  snapOnStep?: boolean;
  /**
   * Whether the wheel changes the value while the field is focused and hovered.
   * Off by default: a page that scrolls under the pointer and a field that
   * changes under it are the same gesture, and only one of them was meant.
   * @default false
   */
  allowWheelScrub?: boolean;
  /**
   * How the number is written — currency, percent, decimal places. Passed
   * straight to `Intl.NumberFormat`, so the field shows `$1,240.00` and still
   * reports `1240`.
   */
  format?: Intl.NumberFormatOptions;
  /**
   * Which locale the number is written and parsed in. Defaults to the runtime's.
   *
   * A plain BCP 47 string also names the two steppers, since a field that reads
   * its digits in one language should not read its buttons in another.
   * `incrementLabel` and `decrementLabel` write those words out instead.
   */
  locale?: Intl.LocalesArgument;
  /** Where the steppers sit, or `none` for a field without them. @default 'end' */
  steppers?: NumberFieldSteppers;
  /** Accessible name of the increment button. Defaults to the `locale`'s word. */
  incrementLabel?: string;
  /** Accessible name of the decrement button. */
  decrementLabel?: string;
  /**
   * Label above the control, wired to it by Base UI's Field. There is no
   * floating variant on purpose: floating labels need a `transform`.
   */
  label?: React.ReactNode;
  /** Helper text below the control. */
  description?: React.ReactNode;
  /** Error message below the control. Its presence also turns the field invalid. */
  error?: React.ReactNode;
  /** Forces the invalid state without a message. Defaults to `!!error`. */
  invalid?: boolean;
  /** Content placed before the number — a currency mark, a unit, an icon. */
  startIcon?: React.ReactNode;
  /** Content placed after the number, before the steppers. */
  endIcon?: React.ReactNode;
  /** Stretches to the width of the container. */
  fullWidth?: boolean;
  /** Unavailable. */
  disabled?: boolean;
  /** The number is shown but cannot be changed. */
  readOnly?: boolean;
  /** Whether a value must be entered before the form is submitted. */
  required?: boolean;
  /** Identifies the field when a form is submitted. */
  name?: string;
  /** Placeholder shown while the field is empty. */
  placeholder?: string;
  id?: string;
}

/** The shell is a TextField's, to the pixel — see `fieldRestClasses`. */
const shellBaseClasses = [
  'group relative flex w-full cursor-text items-center',
  '[-webkit-tap-highlight-color:transparent]',
  transitionClasses,
  'focus-within:[transition-duration:0ms]',
  focusWithinRingClasses,
  iconClasses
].join(' ');

/**
 * A stepper. Square, tracking the text rather than the control, so the same
 * button works at every step of the scale without a table of its own.
 *
 * No `transform` and no `opacity` for the disabled state: a stepper that has
 * run into `min` changes colour family, the way every other inert control in
 * the library does.
 */
const stepperClasses = [
  'inline-flex size-[1.7em] shrink-0 cursor-pointer items-center justify-center',
  'rounded-(--neba-radius-xs) text-(--neba-muted-fg) select-none',
  '[&_svg]:size-[0.9em] [&_svg]:shrink-0',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  '[transition:background-color_var(--neba-duration)_var(--neba-ease),color_var(--neba-duration)_var(--neba-ease)]',
  'active:[transition-duration:0ms]',
  'hover:bg-(--n-soft) hover:text-(--n-accent)',
  'active:bg-(--n-soft-press)',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-1',
  'disabled:cursor-not-allowed disabled:bg-transparent disabled:text-(--neba-disabled-fg)'
].join(' ');

/**
 * A field that only holds a number.
 *
 * The shell is a TextField's, to the pixel, because a form where the quantity
 * box is a different height or radius from the boxes around it is a form that
 * looks assembled rather than designed. What is added on top is a real numeric
 * control: arrow keys and the steppers move by `step` (Shift for `largeStep`,
 * Alt for `smallStep`), the value clamps to `min`/`max`, and `format` writes it
 * as currency or a percentage while `value` stays a plain number.
 *
 * Base UI owns the hard parts — parsing what was typed against the locale,
 * clamping, the press-and-hold repeat on the steppers, and the hidden input
 * that submits with a form.
 */
export function NumberField({
  variant = 'outline',
  size = 'md',
  color = 'primary',
  density = 'default',
  elevation = 0,
  value,
  defaultValue,
  onValueChange,
  onValueCommitted,
  min,
  max,
  step,
  largeStep,
  smallStep,
  snapOnStep,
  allowWheelScrub = false,
  format,
  locale,
  steppers = 'end',
  incrementLabel,
  decrementLabel,
  label,
  description,
  error,
  invalid,
  startIcon,
  endIcon,
  fullWidth = false,
  disabled = false,
  readOnly = false,
  required = false,
  name,
  placeholder,
  id,
  className,
  style,
  ...props
}: NumberFieldProps) {
  // `Intl` takes more shapes than a message tag does; only a plain string names
  // anything here, and anything else falls back to English.
  const messages = useMessages(typeof locale === 'string' ? locale : undefined);
  const hasError = hasContent(error);
  const isInvalid = invalid ?? hasError;
  // Invalid re-points the whole slot family at `danger`, so the edge, the ring,
  // the caret and the message all turn over together.
  const family: NebaColor = isInvalid ? 'danger' : color;

  // The steppers bring their own padding; stacking the shell's on top of them
  // would leave the buttons floating in the middle of a gap. The shell keeps
  // the padding on whichever side has no button.
  const padX = paddingXClasses[density][size];
  const insetClasses: Record<NumberFieldSteppers, string> = {
    end: `${padX} pe-1`,
    split: 'px-1',
    none: padX
  };

  const decrement = (
    <BaseUINumberField.Decrement
      aria-label={decrementLabel ?? messages.number.decrease}
      className={stepperClasses}
    >
      <MinusIcon />
    </BaseUINumberField.Decrement>
  );

  const increment = (
    <BaseUINumberField.Increment
      aria-label={incrementLabel ?? messages.number.increase}
      className={stepperClasses}
    >
      <PlusIcon />
    </BaseUINumberField.Increment>
  );

  const showSteppers = steppers !== 'none' && !readOnly;

  return (
    <Field.Root
      disabled={disabled}
      invalid={isInvalid}
      className={[
        'flex-col align-top',
        stackGapClasses[size],
        fullWidth ? 'flex w-full' : 'inline-flex',
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      style={{ ...surfaceSlots(family, elevation), ...style }}
      {...props}
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

      {/* `contents` so the Group below is a direct child of the Field's column
          — the Root is a grouping element, not a box in the layout. */}
      <BaseUINumberField.Root
        id={id}
        name={name}
        className="contents"
        value={value}
        defaultValue={defaultValue}
        onValueChange={(next) => onValueChange?.(next)}
        onValueCommitted={(next) => onValueCommitted?.(next)}
        min={min}
        max={max}
        step={step}
        largeStep={largeStep}
        smallStep={smallStep}
        snapOnStep={snapOnStep}
        allowWheelScrub={allowWheelScrub}
        format={format}
        locale={locale}
        disabled={disabled}
        readOnly={readOnly}
        required={required}
      >
        <BaseUINumberField.Group
          className={[
            shellBaseClasses,
            controlHeightClasses[size],
            controlTextLeadingClasses[size],
            radiusClasses[size],
            gapClasses[size],
            showSteppers ? insetClasses[steppers] : padX,
            // An if/else rather than stacked variants: two Tailwind classes of
            // equal specificity resolve by their order in the generated sheet.
            disabled
              ? disabledClasses[variant]
              : readOnly
                ? fieldReadOnlyClasses[variant]
                : fieldRestClasses[variant]
          ].join(' ')}
        >
          {showSteppers && steppers === 'split' ? decrement : null}

          {startIcon ? (
            <span className="flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg)">
              {startIcon}
            </span>
          ) : null}

          <BaseUINumberField.Input
            placeholder={placeholder}
            className={[
              'min-w-0 flex-1 self-stretch bg-transparent [font:inherit] text-inherit',
              // Not `outline-none`: that utility zeroes `--tw-outline-style`,
              // and the shell's focus ring is drawn from the same family.
              '[outline:none]',
              'tabular-nums',
              // Split steppers put the number between the two buttons, so it
              // belongs in the middle rather than against an edge.
              steppers === 'split' && showSteppers ? 'text-center' : '',
              'placeholder:text-(--neba-muted-fg)',
              'caret-(--n-accent) selection:bg-(--n-soft-press)',
              'disabled:cursor-not-allowed'
            ]
              .filter(Boolean)
              .join(' ')}
          />

          {endIcon ? (
            <span className="flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg)">
              {endIcon}
            </span>
          ) : null}

          {showSteppers && steppers === 'end' ? (
            <span className="flex shrink-0 items-center gap-0.5">
              {decrement}
              {increment}
            </span>
          ) : null}
          {showSteppers && steppers === 'split' ? increment : null}
        </BaseUINumberField.Group>
      </BaseUINumberField.Root>

      {description ? (
        <Field.Description className={`${metaTextClasses[size]} text-(--neba-muted-fg)`}>
          {description}
        </Field.Description>
      ) : null}

      {hasError ? (
        <Field.Error match className={`${metaTextClasses[size]} text-(--n-accent)`}>
          {error}
        </Field.Error>
      ) : null}
    </Field.Root>
  );
}

'use client';

import * as React from 'react';
import { Field } from '@base-ui/react/field';
import { Input } from '@base-ui/react/input';
import { fieldLight, fieldSpotlightSlot, glowClasses } from '../../internal/glow.js';
import { SpinnerIcon } from '../../internal/icons.js';
import {
  controlTextLeadingClasses,
  cx,
  disabledClasses,
  fieldFocusTransitionClasses,
  fieldHeightClasses,
  fieldReadOnlyClasses,
  fieldRestClasses,
  fieldRingClasses,
  fieldSheetClasses,
  fieldSheetDisabledClasses,
  fieldSheetReadOnlyClasses,
  gapClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  readOnlyFilterClasses,
  stackGapClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import { keyHandler } from '../../internal/keys.js';
import { FieldNotch, NotchFrame } from '../../internal/notch.js';
import type {
  NebaColor,
  NebaElevation,
  NebaFieldSlot,
  NebaLabelPlacement,
  NebaShortcuts,
  NebaSize,
  NebaSlots,
  NebaStyleProps
} from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';
import { useFieldsetDisabled } from '../../internal/fieldset.js';

/** How the multiline control may be resized by the user. Ignored when single line. */
export type TextFieldResize = 'none' | 'vertical' | 'horizontal' | 'both';

/**
 * The parts a TextField draws behind its root.
 *
 * `shell` is the framed box the control sits in — the thing wearing the border,
 * the fill and the focus ring. It is a part rather than an implementation
 * detail because it, and not the `<input>`, is what a caller means by "the
 * field" when they want to change its shape.
 */
export type TextFieldSlot = NebaFieldSlot | 'shell';

/**
 * Native `<input>` attributes, minus the three that collide with the shared
 * vocabulary: `color` and `size` are Neba props here, and `onChange` is widened
 * below so the same handler types against a `<textarea>` in multiline mode.
 */
type NativeControlProps = Omit<
  React.ComponentPropsWithoutRef<'input'>,
  'color' | 'size' | 'onChange' | 'children'
>;

export interface TextFieldProps extends NebaStyleProps, NativeControlProps {
  /**
   * Drop shadow depth. `0` (the default) is flat — a field is a well, not a
   * surface that floats, so this is raised even less often than on a Button.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * Renders a `<textarea>` instead of an `<input>`. Everything else — sizing,
   * density, variants, states — stays identical, so switching a field to
   * multiline never changes how it sits in a form.
   * @default false
   */
  multiline?: boolean;
  /** Visible rows in multiline mode. One row is exactly the single-line height. */
  rows?: number;
  /**
   * Which way the user may drag the multiline control. Horizontal resizing
   * breaks a form's column, so only the vertical axis is on by default.
   * @default 'vertical'
   */
  resize?: TextFieldResize;
  /** The field's name, wired to the control by Base UI's Field. */
  label?: React.ReactNode;
  /**
   * Where the label is drawn: above the field, in a notch cut into its top
   * edge, or inside it where the placeholder would be until the field is
   * focused or filled, and in the notch from then on.
   *
   * A floating label travels on `top` and changes size on `font-size` rather
   * than on a `transform`, so no frame of it is a scaled picture of the word.
   * With a `startIcon` it stays in the notch, because the icon is where it
   * would rest.
   * @default 'top'
   */
  labelPlacement?: NebaLabelPlacement;
  /** Helper text below the control. */
  description?: React.ReactNode;
  /** Error message below the control. Its presence also turns the field invalid. */
  error?: React.ReactNode;
  /**
   * Forces the invalid state without a message — for when an external form
   * library owns the validity. Defaults to whether `error` has content.
   */
  invalid?: boolean;
  /** Content placed before the control. Sized in `em`, so it tracks the text. */
  startIcon?: React.ReactNode;
  /** Content placed after the control. */
  endIcon?: React.ReactNode;
  /**
   * Shows a spinner in place of `endIcon` and marks the field busy. Typing is
   * deliberately still allowed — a field is usually loading *because of* what
   * was typed into it.
   */
  loading?: boolean;
  /** Stretches to the width of the container. */
  fullWidth?: boolean;
  /**
   * Class names for the parts behind the root. `className` is the root — the
   * column that holds the label, the shell and the two lines under it — so the
   * control itself is reached through `classNames.control`.
   */
  classNames?: NebaSlots<TextFieldSlot>;
  /**
   * Key combinations to act on, spelled the way
   * [Shortcut](../display/shortcut) draws them — `{ 'Mod+Enter': send }`. Bound
   * to the control, so `event.currentTarget` is the `<input>` or the
   * `<textarea>` and `event.currentTarget.value` is what was typed.
   *
   * It runs *before* `onKeyDown`, which still sees every keystroke; neither
   * replaces the other. Nothing is prevented on the caller's behalf — a
   * shortcut that must not also insert a newline calls `preventDefault` itself.
   */
  shortcuts?: NebaShortcuts<HTMLInputElement | HTMLTextAreaElement>;
  onChange?: React.ChangeEventHandler<HTMLInputElement | HTMLTextAreaElement>;
}

/**
 * Type scale and radius, shared by both modes. The line height is explicit here
 * rather than `leading-none` as on Button, because in multiline mode it is what
 * decides the height of a row — and it has to agree with the single-line
 * heights below or a one-row textarea would not line up with an input.
 */
const sizeClasses: Record<NebaSize, string> = {
  xs: `${gapClasses.xs} ${radiusClasses.xs} ${controlTextLeadingClasses.xs}`,
  sm: `${gapClasses.sm} ${radiusClasses.sm} ${controlTextLeadingClasses.sm}`,
  md: `${gapClasses.md} ${radiusClasses.md} ${controlTextLeadingClasses.md}`,
  lg: `${gapClasses.lg} ${radiusClasses.lg} ${controlTextLeadingClasses.lg}`,
  xl: `${gapClasses.xl} ${radiusClasses.xl} ${controlTextLeadingClasses.xl}`
};

/**
 * Multiline cannot use a fixed height — `rows` decides it. Instead the vertical
 * padding is `(height - border - line-height) / 2`, which makes a one-row
 * textarea exactly as tall as the single-line field of the same size. The
 * `min-h-*` catches the variants that carry no border.
 *
 * These are keyed by `size` and never by `density`: density is horizontal
 * padding only, and letting it touch this would make the same `rows` produce
 * two different heights.
 */
const multilineClasses: Record<NebaSize, string> = {
  xs: 'min-h-5.5 py-[3px]',
  sm: 'min-h-6.5 py-[4px]',
  md: 'min-h-8 py-[5px]',
  lg: 'min-h-10 py-[8px]',
  xl: 'min-h-12 py-[10px]'
};

/**
 * The vertical padding above as lengths, which is where a resting label sits
 * in a textarea: on the first line rather than in the middle of five. Keep the
 * two in step.
 */
const multilinePadValues: Record<NebaSize, string> = {
  xs: '3px',
  sm: '4px',
  md: '5px',
  lg: '8px',
  xl: '10px'
};

const resizeClasses: Record<TextFieldResize, string> = {
  none: 'resize-none',
  vertical: 'resize-y',
  horizontal: 'resize-x',
  both: 'resize'
};

const shellBaseClasses = [
  // `group` so the adornments can answer the control's focus. The I-beam over
  // the whole shell, padding included, is decided with the state below: beside
  // the `cursor-not-allowed` a disabled shell takes, two cursor utilities would
  // be settled by the order Tailwind happened to emit them in.
  'group relative flex w-full',
  '[-webkit-tap-highlight-color:transparent]',
  // Same property list and durations as Button, with no `:active` override
  // because a field is not pressed. What focus does have is a duration of its
  // own: the sheet, the hairline and the ring all travel at 160ms, rather than
  // the sheet taking the fill's 340ms to catch up with the other two.
  transitionClasses,
  fieldFocusTransitionClasses,
  iconClasses
].join(' ');

/**
 * The shell, the read-only treatment and the disabled treatment are the ones
 * `internal/styles` defines for every field-shaped control — a Select's trigger
 * is drawn on exactly the same box, and the two have to be indistinguishable.
 */
const restClasses = fieldRestClasses;
const readOnlyClasses = fieldReadOnlyClasses;

export const TextField = React.forwardRef<HTMLInputElement | HTMLTextAreaElement, TextFieldProps>(
  function TextField(rawProps, ref) {
    const {
      variant = 'outline',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      multiline = false,
      rows = 3,
      resize = 'vertical',
      label,
      labelPlacement = 'top',
      description,
      error,
      invalid,
      startIcon,
      endIcon,
      loading = false,
      fullWidth = false,
      classNames,
      shortcuts,
      onKeyDown,
      readOnly = false,
      disabled: disabledProp,
      type = 'text',
      placeholder,
      className,
      style,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density', 'variant']);
    const disabled = useFieldsetDisabled(disabledProp);
    // A read-only field is a label that happens to be field-shaped, and a
    // disabled one has dropped the colour family the light would be drawn in.
    const lit = !disabled && !readOnly;

    const hasError = error !== undefined && error !== null && error !== false && error !== '';
    const isInvalid = invalid ?? hasError;
    // Invalid re-points the whole slot family at `danger`, so the edge, the ring,
    // the caret and the message all turn over together and no state needs its own
    // set of tokens.
    const family: NebaColor = isInvalid ? 'danger' : color;

    // A label on the edge takes the edge over from the shell; with no label
    // there is nothing to cut a notch for, and the shell keeps its own.
    const notched = labelPlacement !== 'top' && hasContent(label);
    const rests = notched && labelPlacement === 'float' && !hasContent(startIcon);

    const controlRef = React.useRef<HTMLElement | null>(null);
    const setControlRef = React.useCallback(
      (node: HTMLElement | null) => {
        controlRef.current = node;
        if (typeof ref === 'function') {
          ref(node as HTMLInputElement | HTMLTextAreaElement | null);
        } else if (ref) {
          ref.current = node as HTMLInputElement | HTMLTextAreaElement | null;
        }
      },
      [ref]
    );

    const shellClasses = cx(
      shellBaseClasses,
      sizeClasses[size],
      multiline
        ? `${multilineClasses[size]} items-start`
        : `${fieldHeightClasses[size]} items-center`,
      paddingXClasses[density][size],
      // The ring belongs to the shell, not to the control inside it, so it
      // traces the acrylic edge rather than a rectangle floating inside it — and
      // to the notch instead, when the notch is what draws the edge.
      notched ? '' : fieldRingClasses,
      // An if/else rather than stacked `data-*` variants: two Tailwind variants
      // of equal specificity resolve by their order in the generated stylesheet.
      disabled
        ? (notched ? fieldSheetDisabledClasses : disabledClasses)[variant]
        : readOnly
          ? notched
            ? `${fieldSheetReadOnlyClasses[variant]} ${readOnlyFilterClasses}`
            : readOnlyClasses[variant]
          : `${(notched ? fieldSheetClasses : restClasses)[variant]} ${glowClasses}`,
      disabled ? '' : 'cursor-text',
      classNames?.shell
    );

    const controlClasses = cx(
      'neba-input min-w-0 flex-1 bg-transparent [font:inherit] text-inherit',
      // Not `outline-none`: that utility zeroes `--tw-outline-style`, and the
      // shell's focus ring is drawn with the same variable family. The shorthand
      // takes the outline off this element and leaves the ring alone.
      '[outline:none]',
      'placeholder:text-(--neba-muted-fg)',
      'caret-(--n-accent) selection:bg-(--n-soft-press)',
      'disabled:cursor-not-allowed',
      multiline ? `block ${resizeClasses[resize]}` : 'self-stretch',
      // The hook a resting label reads the field's emptiness through.
      rests ? 'neba-float-control' : '',
      classNames?.control
    );

    // `1lh` keeps an adornment centred on the first line rather than on the whole
    // box, which is the only way it stays put when the control grows to 5 rows.
    const adornmentClasses =
      'inline-flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg) transition-[color] duration-(--neba-duration) group-focus-within:text-(--n-accent)';

    const shell = (
      <span
        className={shellClasses}
        // The spotlight, and only the spotlight — `fieldSpotlightSlot`
        // leaves the press flash unset on purpose, and halves the bloom —
        // and out again while the reader is typing. See `internal/glow.ts`.
        {...fieldLight<HTMLSpanElement>(lit)}
        onPointerDown={(event) => {
          // Clicking the shell's own padding should put the caret in the field,
          // the way clicking anywhere inside a native input does. Only when the
          // shell itself was hit — a click on the control or on an adornment is
          // left alone so text selection still works.
          if (event.target === event.currentTarget && !disabled) {
            event.preventDefault();
            controlRef.current?.focus();
          }
        }}
      >
        {startIcon ? <span className={adornmentClasses}>{startIcon}</span> : null}

        <Input
          ref={setControlRef}
          className={controlClasses}
          disabled={disabled}
          readOnly={readOnly}
          aria-busy={loading || undefined}
          data-loading={loading || undefined}
          // `:placeholder-shown` is how a resting label knows the field is
          // empty, and it never matches an input that has no placeholder.
          placeholder={rests ? placeholder || ' ' : placeholder}
          {...(multiline ? { render: <textarea rows={rows} /> } : { type })}
          {...props}
          // After the spread on purpose: `onKeyDown` is destructured out
          // above, so this is the caller's own handler with the shortcut map
          // in front of it rather than something written over the top of it.
          onKeyDown={keyHandler(shortcuts, onKeyDown)}
        />

        {loading ? (
          <span className={adornmentClasses}>
            <SpinnerIcon />
          </span>
        ) : endIcon ? (
          <span className={adornmentClasses}>{endIcon}</span>
        ) : null}

        {notched ? (
          <FieldNotch
            label={label}
            variant={variant}
            disabled={disabled}
            readOnly={readOnly}
            rests={rests}
            labelClassName={classNames?.label}
          />
        ) : null}
      </span>
    );

    return (
      <Field.Root
        disabled={disabled}
        invalid={isInvalid}
        className={cx(
          'flex-col align-top',
          stackGapClasses[size],
          fullWidth ? 'flex w-full' : 'inline-flex',
          className ?? ''
        )}
        style={{
          ...surfaceSlots(family, elevation),
          ...(lit ? fieldSpotlightSlot : undefined),
          ...style
        }}
      >
        {label && !notched ? (
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

        {notched ? (
          <NotchFrame
            label={label}
            size={size}
            density={density}
            variant={variant}
            firstLine={multiline ? multilinePadValues[size] : undefined}
            labelClassName={classNames?.label}
          >
            {shell}
          </NotchFrame>
        ) : (
          shell
        )}

        {description ? (
          <Field.Description
            className={cx(metaTextClasses[size], 'text-(--neba-muted-fg)', classNames?.description)}
          >
            {description}
          </Field.Description>
        ) : null}

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

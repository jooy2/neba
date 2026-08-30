'use client';

import * as React from 'react';
import { Field } from '@base-ui/react/field';
import { Input } from '@base-ui/react/input';
import {
  controlHeightClasses,
  controlTextLeadingClasses,
  disabledClasses,
  fieldReadOnlyClasses,
  fieldRestClasses,
  focusWithinRingClasses,
  gapClasses,
  iconClasses,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  stackGapClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaColor, NebaElevation, NebaSize, NebaStyleProps } from '../../types.js';

/** How the multiline control may be resized by the user. Ignored when single line. */
export type TextFieldResize = 'none' | 'vertical' | 'horizontal' | 'both';

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
  /**
   * Label above the control, wired to it by Base UI's Field. There is no
   * floating variant on purpose: floating labels need a `transform`, and
   * controls in this library never transform.
   */
  label?: React.ReactNode;
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

const resizeClasses: Record<TextFieldResize, string> = {
  none: 'resize-none',
  vertical: 'resize-y',
  horizontal: 'resize-x',
  both: 'resize'
};

const shellBaseClasses = [
  // `group` so the adornments can answer the control's focus; `cursor-text`
  // because the whole shell behaves as the field, padding included.
  'group relative flex w-full cursor-text',
  '[-webkit-tap-highlight-color:transparent]',
  // Same property list and durations as Button. There is no `:active` override
  // because a field is not pressed — but the asymmetry still applies: focus
  // lands on the frame of the click and drains back out over 340ms once the
  // variant stops matching.
  transitionClasses,
  'focus-within:[transition-duration:0ms]',
  // The ring belongs to the shell, not to the control inside it, so it traces
  // the acrylic edge rather than a rectangle floating inside it.
  focusWithinRingClasses,
  iconClasses
].join(' ');

/**
 * The shell, the read-only treatment and the disabled treatment are the ones
 * `internal/styles` defines for every field-shaped control — a Select's trigger
 * is drawn on exactly the same box, and the two have to be indistinguishable.
 */
const restClasses = fieldRestClasses;
const readOnlyClasses = fieldReadOnlyClasses;

/** Mirrors Button's spinner so the two read as the same object in motion. */
function Spinner() {
  return (
    <svg viewBox="0 0 16 16" fill="none" aria-hidden="true" className="animate-spin">
      <circle cx="8" cy="8" r="6.5" stroke="currentColor" strokeOpacity="0.25" strokeWidth="2" />
      <path
        d="M14.5 8A6.5 6.5 0 0 0 8 1.5"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
      />
    </svg>
  );
}

export const TextField = React.forwardRef<HTMLInputElement | HTMLTextAreaElement, TextFieldProps>(
  function TextField(
    {
      variant = 'outline',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      multiline = false,
      rows = 3,
      resize = 'vertical',
      label,
      description,
      error,
      invalid,
      startIcon,
      endIcon,
      loading = false,
      fullWidth = false,
      readOnly = false,
      disabled = false,
      type = 'text',
      className,
      style,
      ...props
    },
    ref
  ) {
    const hasError = error !== undefined && error !== null && error !== false && error !== '';
    const isInvalid = invalid ?? hasError;
    // Invalid re-points the whole slot family at `danger`, so the edge, the ring,
    // the caret and the message all turn over together and no state needs its own
    // set of tokens.
    const family: NebaColor = isInvalid ? 'danger' : color;

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

    const shellClasses = [
      shellBaseClasses,
      sizeClasses[size],
      multiline
        ? `${multilineClasses[size]} items-start`
        : `${controlHeightClasses[size]} items-center`,
      paddingXClasses[density][size],
      // An if/else rather than stacked `data-*` variants: two Tailwind variants
      // of equal specificity resolve by their order in the generated stylesheet.
      disabled
        ? disabledClasses[variant]
        : readOnly
          ? readOnlyClasses[variant]
          : restClasses[variant]
    ]
      .filter(Boolean)
      .join(' ');

    const controlClasses = [
      'min-w-0 flex-1 bg-transparent [font:inherit] text-inherit',
      // Not `outline-none`: that utility zeroes `--tw-outline-style`, and the
      // shell's focus ring is drawn with the same variable family. The shorthand
      // takes the outline off this element and leaves the ring alone.
      '[outline:none]',
      'placeholder:text-(--neba-muted-fg)',
      'caret-(--n-accent) selection:bg-(--n-soft-press)',
      'disabled:cursor-not-allowed',
      multiline ? `block ${resizeClasses[resize]}` : 'self-stretch'
    ].join(' ');

    // `1lh` keeps an adornment centred on the first line rather than on the whole
    // box, which is the only way it stays put when the control grows to 5 rows.
    const adornmentClasses =
      'inline-flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg) transition-[color] duration-(--neba-duration) group-focus-within:text-(--n-accent)';

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

        <span
          className={shellClasses}
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
            {...(multiline ? { render: <textarea rows={rows} /> } : { type })}
            {...props}
          />

          {loading ? (
            <span className={adornmentClasses}>
              <Spinner />
            </span>
          ) : endIcon ? (
            <span className={adornmentClasses}>{endIcon}</span>
          ) : null}
        </span>

        {description ? (
          <Field.Description
            className={[metaTextClasses[size], 'text-(--neba-muted-fg)'].join(' ')}
          >
            {description}
          </Field.Description>
        ) : null}

        {hasError ? (
          <Field.Error match className={[metaTextClasses[size], 'text-(--n-accent)'].join(' ')}>
            {error}
          </Field.Error>
        ) : (
          // No message of our own, so whatever the validity has: the browser's
          // own text for a failed constraint, or the entry a Form's `errors`
          // put here. Renders nothing at all while the field is valid.
          <Field.Error className={[metaTextClasses[size], 'text-(--n-accent)'].join(' ')} />
        )}
      </Field.Root>
    );
  }
);

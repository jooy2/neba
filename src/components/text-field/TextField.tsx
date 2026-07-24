import * as React from 'react';
import { Field } from '@base-ui/react/field';
import { Input } from '@base-ui/react/input';
import type { NebaColor, NebaDensity, NebaElevation, NebaSize, NebaStyleProps } from '../../types';

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
  xs: 'gap-1 rounded-(--neba-radius-xs) text-[0.6875rem]/[0.875rem]',
  sm: 'gap-1.5 rounded-(--neba-radius-sm) text-[0.75rem]/[1rem]',
  md: 'gap-1.5 rounded-(--neba-radius-md) text-[0.8125rem]/[1.25rem]',
  lg: 'gap-2 rounded-(--neba-radius-lg) text-[0.9375rem]/[1.375rem]',
  xl: 'gap-2.5 rounded-(--neba-radius-xl) text-[1.0625rem]/[1.625rem]'
};

/** The same heights as Button, so a field and a button share a row's baseline. */
const singleLineClasses: Record<NebaSize, string> = {
  xs: 'h-5.5',
  sm: 'h-6.5',
  md: 'h-8',
  lg: 'h-10',
  xl: 'h-12'
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

/** Horizontal padding, on the same two tracks as Button. */
const paddingClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'px-2.5', sm: 'px-3', md: 'px-4', lg: 'px-5', xl: 'px-6' },
  compact: { xs: 'px-1.5', sm: 'px-2', md: 'px-2.5', lg: 'px-3', xl: 'px-4' }
};

/** Label, description and error sit one step below the control's own text. */
const metaClasses: Record<NebaSize, string> = {
  xs: 'text-[0.625rem]',
  sm: 'text-[0.6875rem]',
  md: 'text-[0.75rem]',
  lg: 'text-[0.8125rem]',
  xl: 'text-[0.875rem]'
};

/** Gap between the label, the control and the text under it. */
const stackClasses: Record<NebaSize, string> = {
  xs: 'gap-1',
  sm: 'gap-1',
  md: 'gap-1.5',
  lg: 'gap-1.5',
  xl: 'gap-2'
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
  // Same property list and the same durations as Button. There is no `:active`
  // override because a field is not pressed — but the asymmetry still applies:
  // focus lands on the frame of the click and drains back out over 340ms once
  // the variant stops matching.
  '[transition-property:background-color,border-color,box-shadow,color]',
  '[transition-duration:var(--neba-duration-fill),var(--neba-duration),var(--neba-duration),var(--neba-duration)]',
  '[transition-timing-function:var(--neba-ease)]',
  'focus-within:[transition-duration:0ms]',
  // The ring belongs to the shell, not to the control inside it, so it traces
  // the acrylic edge rather than a rectangle floating inside it. Written as the
  // `outline` shorthand for the same reason as on Button: Tailwind's utilities
  // route the style through `--tw-outline-style`, which any `outline-none` on
  // the element would zero.
  'has-[:focus-visible]:[outline:2px_solid_var(--n-ring)] has-[:focus-visible]:outline-offset-2',
  '[&_svg]:pointer-events-none [&_svg]:size-[1.2em] [&_svg]:shrink-0'
].join(' ');

/** The frosted surface, identical to Button's — see the comment there. */
const surfaceClasses =
  '[background-image:var(--neba-grain),var(--neba-sheen)] [background-blend-mode:overlay,normal] [backdrop-filter:var(--neba-blur)]';

/**
 * The variants say the same three things they say on Button — filled, hairline,
 * bare — with one deliberate difference: `solid` does not flood the control with
 * `--n-fill`. What a field holds is user data, and a caret, a text selection and
 * a placeholder all have to stay legible on top of it, which they are not on an
 * accent fill. So `solid` here is the acrylic sheet dyed a few steps further
 * than `outline`, and the colour family shows up in the edge, the ring and the
 * caret instead.
 */
const restClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel-hover)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]',
    'hover:bg-(--n-panel-press)',
    'focus-within:bg-(--n-panel-press)'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--neba-fg) bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]',
    'hover:bg-(--n-panel-hover) hover:[border-color:var(--n-line-hover)]',
    'focus-within:bg-(--n-panel-hover) focus-within:[border-color:var(--n-ring)]'
  ].join(' '),
  // No surface until it is wanted — the field in a table cell that only looks
  // like a field once you go near it.
  text: [
    'text-(--neba-fg) bg-transparent',
    'hover:bg-(--n-soft)',
    'focus-within:bg-(--n-soft-hover)'
  ].join(' ')
};

/**
 * Read-only keeps the colour and the edge, goes flat, and drains most of the
 * saturation — the same axis Button uses. The caret and text selection stay,
 * because a read-only field is still something you copy out of.
 */
const readOnlyClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel-hover)',
    '[box-shadow:var(--neba-plate-solid)] [filter:saturate(0.55)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--neba-fg) bg-(--n-panel)',
    '[border-color:var(--n-line)] [box-shadow:var(--neba-plate-glass)] [filter:saturate(0.55)]'
  ].join(' '),
  text: 'text-(--neba-fg) bg-transparent [filter:saturate(0.55)]'
};

/** Disabled drops the colour family entirely, exactly as on Button. */
const disabledClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: 'cursor-not-allowed bg-(--neba-disabled-bg) text-(--neba-disabled-fg) shadow-none',
  outline:
    'cursor-not-allowed border bg-transparent text-(--neba-disabled-fg) [border-color:var(--neba-disabled-border)] shadow-none',
  text: 'cursor-not-allowed bg-transparent text-(--neba-disabled-fg) shadow-none'
};

/**
 * Maps `color` and `elevation` onto the local slots, for the same reason as on
 * Button: Tailwind only sees literal class names, so a per-family class would
 * have to be hardcoded once per colour.
 *
 * There is no `--n-elev-hover` / `--n-elev-press` here. A field does not rise
 * under the cursor and cannot be pressed — its states are carried by the edge,
 * the tint and the ring.
 */
function styleSlots(color: NebaColor, elevation: NebaElevation): React.CSSProperties {
  return {
    '--n-accent': `var(--neba-${color}-accent)`,
    '--n-soft': `var(--neba-${color}-soft)`,
    '--n-soft-hover': `var(--neba-${color}-soft-hover)`,
    '--n-soft-press': `var(--neba-${color}-soft-press)`,
    '--n-panel': `var(--neba-${color}-panel)`,
    '--n-panel-hover': `var(--neba-${color}-panel-hover)`,
    '--n-panel-press': `var(--neba-${color}-panel-press)`,
    '--n-line': `var(--neba-${color}-line)`,
    '--n-line-hover': `var(--neba-${color}-line-hover)`,
    '--n-ring': `var(--neba-${color}-ring)`,
    '--n-elev': `var(--neba-shadow-${elevation})`
  } as React.CSSProperties;
}

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
        : `${singleLineClasses[size]} items-center`,
      paddingClasses[density][size],
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
          stackClasses[size],
          fullWidth ? 'flex w-full' : 'inline-flex',
          className ?? ''
        ]
          .filter(Boolean)
          .join(' ')}
        style={{ ...styleSlots(family, elevation), ...style }}
      >
        {label ? (
          <Field.Label
            className={[
              metaClasses[size],
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
          <Field.Description className={[metaClasses[size], 'text-(--neba-muted-fg)'].join(' ')}>
            {description}
          </Field.Description>
        ) : null}

        {hasError ? (
          <Field.Error match className={[metaClasses[size], 'text-(--n-accent)'].join(' ')}>
            {error}
          </Field.Error>
        ) : null}
      </Field.Root>
    );
  }
);

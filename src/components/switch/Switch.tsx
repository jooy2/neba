import * as React from 'react';
import { Switch as BaseUISwitch } from '@base-ui/react/switch';
import { Field } from '@base-ui/react/field';
import { controlTextClasses, metaTextClasses, surfaceClasses } from '../../internal/styles';
import type { NebaColor, NebaSize } from '../../types';

/** Which side of the track the label sits on. */
export type SwitchLabelPlacement = 'start' | 'end';

type BaseSwitchProps = Omit<
  React.ComponentPropsWithoutRef<typeof BaseUISwitch.Root>,
  'className' | 'style' | 'render' | 'children'
>;

export interface SwitchProps extends BaseSwitchProps {
  /** @default 'md' */
  size?: NebaSize;
  /** @default 'primary' */
  color?: NebaColor;
  /** The text beside the track. Wired to it by Base UI's Field. */
  label?: React.ReactNode;
  /** Helper text under the label. */
  description?: React.ReactNode;
  /** Error message below. Its presence also turns the switch invalid. */
  error?: React.ReactNode;
  /** Forces the invalid state without a message. Defaults to `!!error`. */
  invalid?: boolean;
  /**
   * Which side the label sits on. `end` reads as a caption for the control;
   * `start` is for a settings list, where the labels form a column and every
   * switch lines up on the right.
   * @default 'end'
   */
  labelPlacement?: SwitchLabelPlacement;
  /** Class names for the field wrapper, not for the track. */
  className?: string;
  style?: React.CSSProperties;
}

/**
 * Track and thumb.
 *
 * The thumb is inset 2px on every side, so its diameter is the track's height
 * minus 4 and the `left` it travels to is `100% − 2px − diameter`. That is the
 * one number per step that has to be written out; everything else falls out of
 * `inset-y-0.5` and `aspect-square`.
 */
const trackClasses: Record<NebaSize, string> = {
  xs: 'h-3.5 w-6',
  sm: 'h-4 w-7',
  md: 'h-5 w-9',
  lg: 'h-6 w-11',
  xl: 'h-7 w-13'
};

const thumbTravelClasses: Record<NebaSize, string> = {
  xs: 'data-[checked]:left-[calc(100%-0.75rem)]',
  sm: 'data-[checked]:left-[calc(100%-0.875rem)]',
  md: 'data-[checked]:left-[calc(100%-1.125rem)]',
  lg: 'data-[checked]:left-[calc(100%-1.375rem)]',
  xl: 'data-[checked]:left-[calc(100%-1.625rem)]'
};

/**
 * A pill, and the one place in the library that is right.
 *
 * Everywhere else the radius stops short of 50% because the flat run along the
 * top and bottom edge is what reads as a sheet with its corners cut off. A
 * switch is not a sheet — it is a track something runs along, and a track with
 * corners is a track the thumb would have to climb out of.
 */
const trackBaseClasses = [
  'relative inline-flex shrink-0 border',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  'rounded-full',
  // `left` has to be in the property list here, which it is not in the shared
  // transition: this is the only component in the library where something
  // actually moves. It is the thumb, it carries no text, and it is the whole
  // point of the control.
  '[transition-property:background-color,border-color,box-shadow]',
  '[transition-duration:var(--neba-duration-fill),var(--neba-duration),var(--neba-duration)]',
  '[transition-timing-function:var(--neba-ease)]',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2'
].join(' ');

const restTrackClasses = [
  surfaceClasses,
  'cursor-pointer bg-(--n-panel) [border-color:var(--n-line)]',
  '[box-shadow:var(--neba-plate-glass)]',
  'hover:bg-(--n-panel-hover) hover:[border-color:var(--n-line-hover)]',
  'data-[checked]:bg-(--n-fill) data-[checked]:[border-color:transparent]',
  'data-[checked]:[box-shadow:var(--neba-plate-solid)]',
  'data-[checked]:hover:bg-(--n-fill-hover)'
].join(' ');

const readOnlyTrackClasses = [
  surfaceClasses,
  'cursor-default bg-(--n-panel) [border-color:var(--n-line)]',
  '[box-shadow:var(--neba-plate-glass)] [filter:saturate(0.55)]',
  'data-[checked]:bg-(--n-fill) data-[checked]:[border-color:transparent]'
].join(' ');

const disabledTrackClasses = [
  'cursor-not-allowed bg-transparent [border-color:var(--neba-disabled-border)] shadow-none',
  'data-[checked]:bg-(--neba-disabled-bg)'
].join(' ');

/**
 * The thumb is white in both states rather than taking the accent: it is the
 * light on the track, not a second coloured object, and a coloured thumb on a
 * coloured track is two things fighting for the same 16 pixels.
 */
const thumbClasses = [
  'absolute inset-y-0.5 left-0.5 aspect-square rounded-full bg-(--neba-surface)',
  '[box-shadow:var(--neba-shadow-1)]',
  '[transition:left_var(--neba-duration)_var(--neba-ease)]'
].join(' ');

/**
 * An immediate on/off.
 *
 * The difference from a Checkbox is not visual, it is temporal: a checkbox is a
 * value that gets submitted with a form, a switch takes effect the moment it
 * moves. If there is a Save button underneath, it should have been a checkbox.
 */
export const Switch = React.forwardRef<HTMLElement, SwitchProps>(function Switch(
  {
    size = 'md',
    color = 'primary',
    label,
    description,
    error,
    invalid,
    labelPlacement = 'end',
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
  const family: NebaColor = isInvalid ? 'danger' : color;

  const slots = {
    '--n-fill': `var(--neba-${family}-fill)`,
    '--n-fill-hover': `var(--neba-${family}-fill-hover)`,
    '--n-accent': `var(--neba-${family}-accent)`,
    '--n-panel': 'var(--neba-panel)',
    '--n-panel-hover': 'var(--neba-panel-hover)',
    '--n-line': `var(--neba-${family}-line)`,
    '--n-line-hover': `var(--neba-${family}-line-hover)`,
    '--n-ring': `var(--neba-${family}-ring)`
  } as React.CSSProperties;

  const track = (
    <span className="flex h-[1lh] shrink-0 items-center">
      <BaseUISwitch.Root
        ref={ref}
        className={[
          trackBaseClasses,
          trackClasses[size],
          disabled ? disabledTrackClasses : readOnly ? readOnlyTrackClasses : restTrackClasses
        ].join(' ')}
        disabled={disabled}
        readOnly={readOnly}
        {...props}
      >
        <BaseUISwitch.Thumb className={`${thumbClasses} ${thumbTravelClasses[size]}`} />
      </BaseUISwitch.Root>
    </span>
  );

  const text =
    label || description ? (
      <span
        className={[
          'flex min-w-0 flex-col gap-0.5',
          // With the label on the left it has to take the slack, or the switch
          // sits against the text instead of against the edge of the row.
          labelPlacement === 'start' ? 'flex-1' : ''
        ]
          .filter(Boolean)
          .join(' ')}
      >
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
    ) : null;

  return (
    <Field.Root
      disabled={disabled}
      invalid={isInvalid}
      className={['inline-flex flex-col gap-1 align-top', className ?? '']
        .filter(Boolean)
        .join(' ')}
      style={{ ...slots, ...style }}
    >
      <div className={`flex items-start gap-2.5 ${controlTextClasses[size]}`}>
        {labelPlacement === 'start' ? (
          <>
            {text}
            {track}
          </>
        ) : (
          <>
            {track}
            {text}
          </>
        )}
      </div>

      {hasError ? (
        <Field.Error match className={`${metaTextClasses[size]} text-(--n-accent)`}>
          {error}
        </Field.Error>
      ) : null}
    </Field.Root>
  );
});

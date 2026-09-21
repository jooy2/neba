'use client';

import * as React from 'react';
import { Switch as BaseUISwitch } from '@base-ui/react/switch';
import { Field } from '@base-ui/react/field';
import {
  controlTextClasses,
  cx,
  hitAreaClasses,
  metaTextClasses,
  surfaceClasses,
  tickRowLeadingClasses
} from '../../internal/styles.js';
import type { NebaColor, NebaFieldSlot, NebaSize, NebaSlots } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';
import { useFieldsetDisabled } from '../../internal/fieldset.js';

/** Which side of the track the label sits on. */
export type SwitchLabelPlacement = 'start' | 'end';

type BaseSwitchProps = Omit<
  React.ComponentPropsWithoutRef<typeof BaseUISwitch.Root>,
  'className' | 'style' | 'render' | 'children'
>;

/**
 * The parts a Switch draws behind its root.
 *
 * `control` is the track — the pill that fills when the switch is on — and
 * `thumb` is the disc that travels across it.
 */
export type SwitchSlot = NebaFieldSlot | 'thumb';

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
  /**
   * Class names for the parts behind that wrapper — the track is
   * `classNames.control`.
   */
  classNames?: NebaSlots<SwitchSlot>;
  style?: React.CSSProperties;
}

/**
 * Track and thumb.
 *
 * The thumb is inset 2px on every side, so its diameter is the track's height
 * minus 4 and the `inset-inline-start` it travels to is `100% − 2px − diameter`,
 * which puts "on" at the end of the line under either direction. That is the
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
  xs: 'data-[checked]:start-[calc(100%-0.75rem)]',
  sm: 'data-[checked]:start-[calc(100%-0.875rem)]',
  md: 'data-[checked]:start-[calc(100%-1.125rem)]',
  lg: 'data-[checked]:start-[calc(100%-1.375rem)]',
  xl: 'data-[checked]:start-[calc(100%-1.625rem)]'
};

/**
 * The room the row makes for a track taller than the line of text beside it.
 *
 * A tick fits inside its label's line box and a track does not: from `md` up,
 * `1lh` is 18.2, 21 and 23.8 pixels against a track of 20, 24 and 28. The
 * wrapper is that line box, so the track was drawn outside it — outside the
 * row, and outside the field — where anything that scrolls clips its top and
 * whatever sits above the row has it laid over.
 *
 * Padding rather than a taller wrapper, because a taller wrapper moves the
 * track: the wrapper starts at the top of the row, so growing it pushes the
 * track's centre below the centre of the first line, by 2.1px at `xl`. Half the
 * overflow above the line and half below leaves the track exactly where it was
 * and puts the whole of it inside the row.
 *
 * Written against `1lh` rather than as the two pixels it currently comes to, so
 * that the type scale and this stay in step by themselves. `xs` and `sm` are
 * empty because the track is shorter than the line there, and a negative
 * padding is not a thing.
 */
const trackRowPaddingClasses: Record<NebaSize, string> = {
  xs: '',
  sm: '',
  md: 'py-[calc((1.25rem-1lh)/2)]',
  lg: 'py-[calc((1.5rem-1lh)/2)]',
  xl: 'py-[calc((1.75rem-1lh)/2)]'
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
  // Wide enough already at every step; it is the height that is short of the
  // 24px a target owes a finger, and the rule grows only the axis that is.
  hitAreaClasses,
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  'rounded-full',
  // The thumb's offset has to be in the property list here, which it is not in the shared
  // transition: this is the only component in the library where something
  // actually moves. It is the thumb, it carries no text, and it is the whole
  // point of the control.
  '[transition-property:background-color,border-color,box-shadow]',
  '[transition-duration:var(--neba-duration-fill),var(--neba-duration),var(--neba-duration)]',
  '[transition-timing-function:var(--neba-ease)]',
  'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:outline-offset-2'
].join(' ');

/**
 * No plate on the track, for the reason a Checkbox's tick has none: a 1px white
 * hairline around a 20px groove is a bevel rather than light on a cut edge, and
 * a bevelled groove with a domed thumb in it is the skeuomorphic switch this
 * design language is not. The acrylic surface stays; only the highlight goes.
 *
 * `--neba-groove` and not `--neba-panel`, which is the one place a control in
 * this library turns the surface ladder over. Every other rest surface here is
 * white laid on the page, and on a light theme that made the off track lighter
 * than what it sits on — with a thumb that is `--neba-surface`, which is white.
 * A white disc on a white track is not a thumb, it is an empty pill. The groove
 * darkens instead, which is what a track is, and the thumb has something to be
 * the light on. It is read straight off the token rather than through a slot,
 * because a groove is never dyed: the family arrives when the switch is on.
 */
const restTrackClasses = [
  surfaceClasses,
  'cursor-pointer bg-(--neba-groove) [border-color:var(--n-line)]',
  'hover:bg-(--neba-groove-hover) hover:[border-color:var(--n-line-hover)]',
  'data-[checked]:bg-(--n-fill) data-[checked]:[border-color:transparent]',
  'data-[checked]:hover:bg-(--n-fill-hover)'
].join(' ');

const readOnlyTrackClasses = [
  surfaceClasses,
  'cursor-default bg-(--neba-groove) [border-color:var(--n-line)]',
  '[filter:saturate(0.55)]',
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
  'absolute inset-y-0.5 start-0.5 aspect-square rounded-full bg-(--neba-surface)',
  '[box-shadow:var(--neba-shadow-1)]',
  '[transition:inset-inline-start_var(--neba-duration)_var(--neba-ease)]'
].join(' ');

/**
 * An immediate on/off.
 *
 * The difference from a Checkbox is not visual, it is temporal: a checkbox is a
 * value that gets submitted with a form, a switch takes effect the moment it
 * moves. If there is a Save button underneath, it should have been a checkbox.
 */
export const Switch = React.forwardRef<HTMLElement, SwitchProps>(function Switch(rawProps, ref) {
  const {
    size = 'md',
    color = 'primary',
    label,
    description,
    error,
    invalid,
    labelPlacement = 'end',
    disabled: disabledProp,
    readOnly = false,
    className,
    classNames,
    style,
    ...props
  } = useStyleDefaults(rawProps, ['size']);
  const disabled = useFieldsetDisabled(disabledProp);

  const hasError = error !== undefined && error !== null && error !== false && error !== '';
  const isInvalid = invalid ?? hasError;
  const family: NebaColor = isInvalid ? 'danger' : color;

  const slots = {
    '--n-fill': `var(--neba-${family}-fill)`,
    '--n-fill-hover': `var(--neba-${family}-fill-hover)`,
    '--n-accent': `var(--neba-${family}-accent)`,
    '--n-line': `var(--neba-${family}-line)`,
    '--n-line-hover': `var(--neba-${family}-line-hover)`,
    '--n-ring': `var(--neba-${family}-ring)`
  } as React.CSSProperties;

  const track = (
    <span className="flex h-[1lh] shrink-0 items-center">
      <BaseUISwitch.Root
        ref={ref}
        className={cx(
          // `neba-switch` and `neba-switch-thumb` are hooks for the forced-colours
          // block in `styles.css`, which has no other way to find the two parts.
          'neba-switch',
          trackBaseClasses,
          trackClasses[size],
          disabled ? disabledTrackClasses : readOnly ? readOnlyTrackClasses : restTrackClasses,
          classNames?.control
        )}
        disabled={disabled}
        readOnly={readOnly}
        {...props}
      >
        <BaseUISwitch.Thumb
          className={cx(
            'neba-switch-thumb',
            thumbClasses,
            thumbTravelClasses[size],
            classNames?.thumb
          )}
        />
      </BaseUISwitch.Root>
    </span>
  );

  const text =
    label || description ? (
      <span
        className={cx(
          'flex min-w-0 flex-col gap-0.5',
          // With the label on the left it has to take the slack, or the switch
          // sits against the text instead of against the edge of the row.
          labelPlacement === 'start' ? 'flex-1' : ''
        )}
      >
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
            className={cx(metaTextClasses[size], 'text-(--neba-muted-fg)', classNames?.description)}
          >
            {description}
          </Field.Description>
        ) : null}
      </span>
    ) : null;

  return (
    <Field.Root
      disabled={disabled}
      invalid={isInvalid}
      className={cx('inline-flex flex-col gap-1 align-top', className ?? '')}
      style={{ ...slots, ...style }}
    >
      <div
        className={cx(
          'flex items-start gap-2.5',
          controlTextClasses[size],
          tickRowLeadingClasses,
          trackRowPaddingClasses[size]
        )}
      >
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
});

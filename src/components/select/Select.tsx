'use client';

import * as React from 'react';
import { Select as BaseUISelect } from '@base-ui/react/select';
import { Field } from '@base-ui/react/field';
import { CheckIcon, ChevronIcon } from '../../internal/icons.js';
import { WidthSizer } from '../../internal/sizer.js';
import {
  controlHeightClasses,
  controlTextLeadingClasses,
  cx,
  disabledClasses,
  fieldReadOnlyClasses,
  fieldRestClasses,
  focusWithinRingClasses,
  gapClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  paddingXClasses,
  popupFadeClasses,
  radiusClasses,
  stackGapClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type {
  NebaColor,
  NebaElevation,
  NebaFieldSlot,
  NebaSlots,
  NebaStyleProps
} from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/**
 * What a Select's value may be.
 *
 * Deliberately not generic over arbitrary objects. A select is a form control,
 * its value is what a form submits, and every escape from that — object values,
 * custom equality, a stringifier for the trigger — buys flexibility by making
 * the common case harder to write. Keep the identifier here and look the object
 * up on the other side.
 */
export type SelectValue = string | number;

export interface SelectOption {
  /** Submitted, and what `value` / `onValueChange` speak in. */
  value: SelectValue;
  /** Shown in the list and in the trigger. Defaults to the value itself. */
  label?: React.ReactNode;
  /** Unavailable, but still listed — the option exists, it just cannot be picked. */
  disabled?: boolean;
}

/**
 * The parts a Select draws behind its root.
 *
 * `control` is the trigger — the box the reader presses, which is a TextField's
 * shell to the pixel and is styled as one. `popup` and `item` are portalled, so
 * they render at the end of `<body>` and a descendant selector written against
 * the root will not reach them; these are the only way in.
 */
export type SelectSlot = NebaFieldSlot | 'popup' | 'item';

export interface SelectProps
  extends
    NebaStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'children'> {
  /**
   * The options, as data. There is no `<Select.Option>` to compose: what a
   * caller has is almost always an array already, and the list has to be
   * available to the trigger before the popup has ever been opened.
   */
  items: readonly SelectOption[];
  /** The chosen value. Use with `onValueChange` for a controlled select. */
  value?: SelectValue | null;
  /** The initially chosen value, for an uncontrolled select. */
  defaultValue?: SelectValue | null;
  onValueChange?: (value: SelectValue | null) => void;
  /** Shown in the trigger while nothing is chosen. */
  placeholder?: React.ReactNode;
  /**
   * Drop shadow depth of the *trigger*. The popup has its own, fixed: it
   * genuinely floats above the page, which is the one case elevation is for.
   * @default 0
   */
  elevation?: NebaElevation;
  /** Label above the trigger, wired to it by Base UI's Field. */
  label?: React.ReactNode;
  /** Helper text below the trigger. */
  description?: React.ReactNode;
  /** Error message below. Its presence also turns the select invalid. */
  error?: React.ReactNode;
  /** Forces the invalid state without a message. Defaults to `!!error`. */
  invalid?: boolean;
  /** Content placed before the value. Sized in `em`, so it tracks the text. */
  startIcon?: React.ReactNode;
  /** Stretches to the width of the container. */
  fullWidth?: boolean;
  /** Unavailable. */
  disabled?: boolean;
  /** The value is shown but cannot be changed. */
  readOnly?: boolean;
  /** Whether a value must be chosen before the form is submitted. */
  required?: boolean;
  /** Identifies the field when a form is submitted. */
  name?: string;
  id?: string;
  /**
   * Class names for the parts behind the root. `className` is the root — the
   * column holding the label, the trigger and the two lines under it — and the
   * trigger itself is `classNames.control`.
   */
  classNames?: NebaSlots<SelectSlot>;
}

/** The trigger is a TextField's shell, to the pixel. */
const triggerBaseClasses = [
  'group relative flex w-full cursor-pointer items-center select-none',
  '[-webkit-tap-highlight-color:transparent] [touch-action:manipulation]',
  transitionClasses,
  'focus-within:[transition-duration:0ms]',
  focusWithinRingClasses,
  iconClasses
].join(' ');

/**
 * The popup is the one surface in the library that is *supposed* to float, so
 * unlike everything else it carries a shadow by default — at level 3, which is
 * as far as the scale goes without hovering.
 *
 * Every `--n-*` it reads is set on the popup itself rather than inherited from
 * the Field around it. A portalled popup renders at the end of `<body>`, so it
 * is outside the element the slots were declared on, and a `var()` with nothing
 * to resolve to is not a fallback — `border-color` collapses to `currentColor`
 * (a black hairline) and `background-color` to transparent. The highlight was
 * the worst of it: `--n-soft-hover` resolved to nothing, so hovering a row did
 * not light it at all.
 */
const popupClasses = [
  surfaceClasses,
  'max-h-[min(20rem,var(--available-height))] overflow-y-auto overscroll-contain',
  'min-w-[var(--anchor-width)] border bg-(--n-panel-press) p-1',
  '[border-color:var(--n-line)]',
  '[box-shadow:var(--neba-shadow-3),var(--neba-plate-glass)]',
  '[outline:none]',
  popupFadeClasses
].join(' ');

const itemClasses = [
  'relative flex cursor-pointer items-center gap-2 select-none',
  'rounded-(--neba-radius-xs) py-1.5 pe-2 ps-7',
  transitionClasses,
  // `data-highlighted` rather than `:hover`: it is also what the arrow keys
  // move, so the mouse and the keyboard light the same row.
  'data-[highlighted]:bg-(--n-soft-hover) data-[highlighted]:text-(--n-accent)',
  'data-[selected]:text-(--n-accent) data-[selected]:font-medium',
  'data-[disabled]:cursor-not-allowed data-[disabled]:text-(--neba-disabled-fg)',
  '[outline:none]'
].join(' ');

/**
 * One value chosen from a list of them.
 *
 * The trigger is a TextField's shell wearing a chevron, on purpose: a form where
 * the select is a different height, radius or colour from the fields around it
 * is a form that looks assembled rather than designed.
 *
 * Base UI owns everything hard about this — the popup's positioning and flipping,
 * the focus trap, typeahead, the hidden input that makes it submit — and the
 * work here is the surface it all wears.
 */
export const Select = React.forwardRef<HTMLButtonElement, SelectProps>(
  function Select(rawProps, ref) {
    const {
      variant = 'outline',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      items,
      value,
      defaultValue,
      onValueChange,
      placeholder,
      label,
      description,
      error,
      invalid,
      startIcon,
      fullWidth = false,
      disabled = false,
      readOnly = false,
      required = false,
      name,
      id,
      className,
      classNames,
      style,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density', 'variant']);

    const hasError = error !== undefined && error !== null && error !== false && error !== '';
    const isInvalid = invalid ?? hasError;
    // Invalid re-points the whole slot family at `danger`, so the edge, the ring
    // and the message all turn over together.
    const family: NebaColor = isInvalid ? 'danger' : color;

    // Base UI reads this to render the chosen option's *label* in the trigger
    // rather than its raw value, which is the only way `<Select.Value>` can show
    // "Seoul" for `value="kr-11"` before the popup has ever been mounted.
    const baseItems = React.useMemo(
      () => items.map((item) => ({ label: item.label ?? String(item.value), value: item.value })),
      [items]
    );

    // Holds the trigger open at the width of the longest thing it could say, so
    // choosing a shorter option does not shrink the field out from under the
    // pointer that chose it.
    const sizerSamples = React.useMemo(
      () => [
        ...items.map((item) => item.label ?? String(item.value)),
        ...(hasContent(placeholder) ? [placeholder] : [])
      ],
      [items, placeholder]
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
        style={{ ...surfaceSlots(family, elevation), ...style }}
        {...props}
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

        <BaseUISelect.Root
          id={id}
          name={name}
          items={baseItems}
          value={value}
          defaultValue={defaultValue}
          onValueChange={(next) => onValueChange?.(next as SelectValue | null)}
          disabled={disabled}
          readOnly={readOnly}
          required={required}
        >
          <BaseUISelect.Trigger
            ref={ref}
            className={cx(
              triggerBaseClasses,
              controlHeightClasses[size],
              controlTextLeadingClasses[size],
              radiusClasses[size],
              gapClasses[size],
              paddingXClasses[density][size],
              // An if/else rather than stacked variants: two Tailwind classes of
              // equal specificity resolve by their order in the generated sheet.
              disabled
                ? disabledClasses[variant]
                : readOnly
                  ? `${fieldReadOnlyClasses[variant]} cursor-default`
                  : fieldRestClasses[variant],
              classNames?.control
            )}
          >
            {startIcon ? (
              <span className="flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg)">
                {startIcon}
              </span>
            ) : null}

            {/* The value, and under it every label it could hold. `min-w-0` on the
              column is what keeps the whole thing shrinkable when a narrow
              container asks it to be. */}
            <span className="flex min-w-0 flex-1 flex-col">
              <BaseUISelect.Value
                className={[
                  'w-full truncate text-start',
                  // The placeholder is muted the same way a TextField's is, so an
                  // empty select and an empty field read as equally empty.
                  'data-[placeholder]:text-(--neba-muted-fg)'
                ].join(' ')}
                placeholder={placeholder}
              />
              <WidthSizer samples={sizerSamples} />
            </span>

            <BaseUISelect.Icon
              className={[
                'flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg)',
                // The chevron is the one thing here that may turn: it is a
                // glyph, not a label, and nothing about it resamples.
                '[transition:rotate_var(--neba-duration)_var(--neba-ease)]',
                'data-[popup-open]:rotate-180'
              ].join(' ')}
            >
              <ChevronIcon />
            </BaseUISelect.Icon>
          </BaseUISelect.Trigger>

          <BaseUISelect.Portal>
            {/* `neba-portal` is a hook, not a style: a portalled popup leaves the
              subtree its host may have scoped a CSS reset to, and this is what
              such a host can hang the same reset off. */}
            <BaseUISelect.Positioner
              className="neba-portal z-50 [outline:none]"
              sideOffset={6}
              alignItemWithTrigger={false}
            >
              <BaseUISelect.Popup
                className={cx(
                  popupClasses,
                  radiusClasses[size],
                  controlTextLeadingClasses[size],
                  classNames?.popup
                )}
                style={surfaceSlots(family, 3)}
              >
                {items.map((item) => (
                  <BaseUISelect.Item
                    key={String(item.value)}
                    value={item.value}
                    disabled={item.disabled}
                    className={cx(itemClasses, classNames?.item)}
                  >
                    <BaseUISelect.ItemIndicator className="absolute start-1.5 flex size-4 items-center justify-center">
                      <CheckIcon />
                    </BaseUISelect.ItemIndicator>
                    <BaseUISelect.ItemText className="truncate">
                      {item.label ?? String(item.value)}
                    </BaseUISelect.ItemText>
                  </BaseUISelect.Item>
                ))}
              </BaseUISelect.Popup>
            </BaseUISelect.Positioner>
          </BaseUISelect.Portal>
        </BaseUISelect.Root>

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

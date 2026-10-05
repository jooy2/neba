'use client';

import * as React from 'react';
import { CheckboxGroup as BaseUICheckboxGroup } from '@base-ui/react/checkbox-group';
import { Field } from '@base-ui/react/field';
import { cx, metaTextClasses, optionGapClasses } from '../../internal/styles.js';
import { spacingValue } from '../../internal/grid.js';
import type {
  NebaColor,
  NebaFieldSlot,
  NebaOrientation,
  NebaSize,
  NebaSlots
} from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';
import { useFieldsetDisabled } from '../../internal/fieldset.js';
import { CheckboxGroupContext } from '../../internal/checkbox-group.js';

/**
 * The parts a CheckboxGroup draws behind its root. `control` is the element
 * that holds the checkboxes — the one carrying the row or column direction —
 * and not any single Checkbox, which has slots of its own.
 */
export type CheckboxGroupSlot = NebaFieldSlot;

export interface CheckboxGroupProps extends Omit<
  React.ComponentPropsWithoutRef<typeof BaseUICheckboxGroup>,
  'className' | 'style' | 'render'
> {
  /**
   * The size of every Checkbox inside, unless one sets its own, and the type
   * scale of the label, the description and the error.
   * @default 'md'
   */
  size?: NebaSize;
  /** The colour family of every Checkbox inside, unless one sets its own. @default 'primary' */
  color?: NebaColor;
  /**
   * Which way the checkboxes stack. Vertical by default, for RadioGroup's
   * reason: a column is scannable at any length, and a row stops being readable
   * the moment one label runs long.
   * @default 'vertical'
   */
  orientation?: NebaOrientation;
  /**
   * The gap between the checkboxes, on Tailwind's spacing scale: `3` is
   * `0.75rem`, the same step `gap-3` is. One length on both axes, so a
   * horizontal group that wraps puts its lines as far apart as its options.
   * Left out, a column follows `size` on the ladder a Form stands its fields
   * on, `3` at `md`, and a row keeps `5` along it with the column's step
   * between its lines — RadioGroup's gaps, so the two read as the same kind of
   * question.
   *
   * Not read from a `NebaProvider`: the provider's `spacing` is the gap between
   * fields, and a product that spreads its fields apart should not spread every
   * set of options with them.
   */
  spacing?: number;
  /** The question the checkboxes answer. It names the group. */
  label?: React.ReactNode;
  /** Helper text under the label. */
  description?: React.ReactNode;
  /** Error message below the checkboxes. Its presence also turns the group invalid. */
  error?: React.ReactNode;
  /** Forces the invalid state without a message. Defaults to `!!error`. */
  invalid?: boolean;
  /**
   * Shows every checkbox's state without letting it change. Base UI's group
   * has no such state, so this is handed to each Checkbox inside.
   * @default false
   */
  readOnly?: boolean;
  /**
   * The name the ticked values are submitted under. A native submit sends one
   * entry per ticked checkbox, each its `value`, and a Form's `onSubmit` is
   * handed them as an array.
   */
  name?: string;
  className?: string;
  /**
   * Class names for the parts behind the root. The element holding the
   * checkboxes is `classNames.control`; a single option is styled on the
   * Checkbox itself.
   */
  classNames?: NebaSlots<CheckboxGroupSlot>;
  style?: React.CSSProperties;
}

/**
 * A set of checkboxes that answer one question, any number of them at once.
 *
 * A column of Checkboxes in a Fieldset already works, and this is what that
 * column was missing: one value for the set — an array of the ticked
 * checkboxes' `value`s, controlled or not — a label and an error that belong to
 * the question rather than to one option, and a parent checkbox that ticks
 * every option at once. `allValues` names every option, and the Checkbox with
 * `parent` is the one that answers for all of them.
 *
 * Base UI's group owns the value and the parent's three states. What it does
 * not carry down is how each option looks, so `size`, `color`, `disabled` and
 * `readOnly` reach every Checkbox through `internal/checkbox-group.ts`, and so
 * does the `name` a native submit needs.
 */
export const CheckboxGroup = React.forwardRef<HTMLDivElement, CheckboxGroupProps>(
  function CheckboxGroup(rawProps, ref) {
    const {
      size = 'md',
      color = 'primary',
      orientation = 'vertical',
      spacing,
      label,
      description,
      error,
      invalid,
      disabled: disabledProp,
      readOnly = false,
      name,
      className,
      classNames,
      style,
      children,
      ...props
    } = useStyleDefaults(rawProps, ['size']);
    const disabled = useFieldsetDisabled(disabledProp);
    const hasError = error !== undefined && error !== null && error !== false && error !== '';
    const isInvalid = invalid ?? hasError;
    const family: NebaColor = isInvalid ? 'danger' : color;

    const context = React.useMemo(
      () => ({ size, color, invalid: isInvalid, disabled, readOnly, name }),
      [size, color, isInvalid, disabled, readOnly, name]
    );

    return (
      <CheckboxGroupContext.Provider value={context}>
        <Field.Root
          name={name}
          disabled={disabled}
          invalid={isInvalid}
          className={cx('flex flex-col gap-1.5', className ?? '')}
          style={{ '--n-accent': `var(--neba-${family}-accent)`, ...style } as React.CSSProperties}
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
              className={cx(
                metaTextClasses[size],
                'text-(--neba-muted-fg)',
                classNames?.description
              )}
            >
              {description}
            </Field.Description>
          ) : null}

          <BaseUICheckboxGroup
            ref={ref}
            disabled={disabled}
            className={cx(
              'flex',
              orientation === 'horizontal' ? 'flex-row flex-wrap' : 'flex-col',
              spacing === undefined ? optionGapClasses[orientation][size] : '',
              classNames?.control
            )}
            style={spacing === undefined ? undefined : { gap: spacingValue(spacing) }}
            {...props}
          >
            {children}
          </BaseUICheckboxGroup>

          {hasError ? (
            <Field.Error
              match
              className={cx(metaTextClasses[size], 'text-(--n-accent)', classNames?.error)}
            >
              {error}
            </Field.Error>
          ) : (
            // No message of our own, so whatever the validity has: the entry a
            // Form's `errors` put here. Renders nothing at all while the field
            // is valid.
            <Field.Error
              className={cx(metaTextClasses[size], 'text-(--n-accent)', classNames?.error)}
            />
          )}
        </Field.Root>
      </CheckboxGroupContext.Provider>
    );
  }
);

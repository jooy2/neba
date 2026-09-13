'use client';

import * as React from 'react';
import { Fieldset as BaseUIFieldset } from '@base-ui/react/fieldset';
import {
  cx,
  hasContent,
  metaTextClasses,
  sheetHeaderGapClasses,
  sheetSectionGapClasses,
  sheetTitleClasses
} from '../../internal/styles.js';
import type { NebaSize } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';
import { FieldsetDisabledContext } from '../../internal/fieldset.js';

export interface FieldsetProps extends Omit<React.ComponentPropsWithoutRef<'fieldset'>, 'color'> {
  /**
   * What the group is called. It becomes the accessible name of every control
   * inside, so it has to be a phrase that still reads correctly in front of each
   * of them — "Billing address", not "Where should we send it?".
   */
  legend?: React.ReactNode;
  /** A line under the legend. */
  description?: React.ReactNode;
  /** Disables every control inside at once, the way a `<fieldset>` always has. */
  disabled?: boolean;
  /** The type scale of the legend and the gap between the controls. @default 'md' */
  size?: NebaSize;
  children?: React.ReactNode;
}

/**
 * A group of controls that answer one question together, with a name on it.
 *
 * It draws no surface, and that is deliberate: a group of fields is a *grouping*
 * and not a sheet, and the sheet already exists — put this inside a
 * [Card](../surfaces/card) or a [Box](../surfaces/box) when one is wanted. What
 * it owns is the legend, the gap the controls stand at, and the one thing only a
 * real `<fieldset>` can do: `disabled` reaches every control inside it,
 * including ones a component three levels down rendered and never heard of it.
 *
 * The legend is a `<div>` pointed at by `aria-labelledby` rather than a
 * `<legend>` — Base UI's decision, and the one that makes the group a normal
 * flex container: a real rendered legend is lifted out of its fieldset's content
 * box by every browser, so a `gap` would put no space under it at all.
 */
export const Fieldset = React.forwardRef<HTMLFieldSetElement, FieldsetProps>(
  function Fieldset(rawProps, ref) {
    const {
      legend,
      description,
      disabled = false,
      size = 'md',
      className,
      children,
      'aria-describedby': describedBy,
      ...props
    } = useStyleDefaults(rawProps, ['size']);
    const descriptionId = React.useId();
    const hasLegend = hasContent(legend);
    const hasDescription = hasContent(description);

    return (
      <FieldsetDisabledContext.Provider value={disabled}>
        <BaseUIFieldset.Root
          ref={ref}
          disabled={disabled}
          className={cx(
            // A `<fieldset>` arrives with the browser's own border, padding and
            // margin, and none of the three is the library's. `min-w-0` is the other
            // half: a fieldset is `min-width: min-content` by default, which is what
            // makes one holding a wide table refuse to shrink.
            'm-0 flex min-w-0 flex-col border-0 p-0',
            sheetSectionGapClasses[size],
            className ?? ''
          )}
          // The description is the group's description and not part of its name.
          // Inside the legend it was both, so every control in the group was
          // introduced by a whole sentence.
          aria-describedby={
            [describedBy, hasDescription ? descriptionId : undefined].filter(Boolean).join(' ') ||
            undefined
          }
          {...props}
        >
          {hasLegend || hasDescription ? (
            <div className={`flex min-w-0 flex-col ${sheetHeaderGapClasses[size]}`}>
              {hasLegend ? (
                <BaseUIFieldset.Legend className={`p-0 font-semibold ${sheetTitleClasses[size]}`}>
                  {legend}
                </BaseUIFieldset.Legend>
              ) : null}
              {hasDescription ? (
                <span
                  id={descriptionId}
                  className={`text-(--neba-muted-fg) ${metaTextClasses[size]}`}
                >
                  {description}
                </span>
              ) : null}
            </div>
          ) : null}

          {children}
        </BaseUIFieldset.Root>
      </FieldsetDisabledContext.Provider>
    );
  }
);

'use client';

import * as React from 'react';
import { Collapsible as BaseUICollapsible } from '@base-ui/react/collapsible';
import { boxPaddingXClasses, boxPaddingYClasses } from '../box/Box.js';
import { ChevronIcon } from '../../internal/icons.js';
import {
  gapClasses,
  hasContent,
  iconClasses,
  metaTextClasses,
  radiusClasses,
  sheetBodyClasses,
  sheetHeaderGapClasses,
  sheetTitleClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaElevation, NebaStyleProps } from '../../types.js';

export interface CollapsibleProps
  extends
    NebaStyleProps,
    Omit<
      React.ComponentPropsWithoutRef<'div'>,
      // `title` is the tooltip attribute on every element; here it is the
      // heading written on the trigger, and a `ReactNode` rather than a string.
      'color' | 'title' | 'onChange'
    > {
  /** Whether the panel is showing. Pass it to drive the Collapsible yourself. */
  open?: boolean;
  /**
   * Where an uncontrolled Collapsible starts.
   * @default false
   */
  defaultOpen?: boolean;
  /** Called when the trigger opens or closes the panel. */
  onOpenChange?: (open: boolean) => void;
  /** The heading on the trigger. */
  title?: React.ReactNode;
  /** A second line under the title, one step down the type scale and muted. */
  subtitle?: React.ReactNode;
  /** Content before the title — an icon, a status dot, a count. */
  startIcon?: React.ReactNode;
  /**
   * A control pinned to the end of the header, outside the trigger.
   *
   * Deliberately outside it: a header that both folds and holds a switch has two
   * things to press, and one of them cannot be nested inside the other. The same
   * shape AccordionItem and ListItem use.
   */
  action?: React.ReactNode;
  /**
   * Replaces the header entirely with a control of your own — a Button, a Chip,
   * a line of text you made pressable.
   *
   * The element you pass *becomes* the trigger: it is handed the click handler,
   * `aria-expanded` and the `aria-controls` pointing at the panel, so nothing
   * has to be wired up. `title` and the slots around it are for the far commoner
   * case of wanting the header that is already there.
   */
  trigger?: React.ReactElement;
  /**
   * The chevron at the end of the header, turned to report the state.
   * @default true
   */
  indicator?: boolean;
  /** Unavailable. The trigger stops answering and the panel stays as it is. */
  disabled?: boolean;
  /**
   * Inner padding around the panel's content. Turn it off for something that
   * should reach the edges — a table, a picture, a list of its own.
   * @default true
   */
  padded?: boolean;
  /**
   * Drop shadow depth. `0` (the default) is flat.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * Keeps a closed panel in the DOM so the browser's own page search can find
   * and open it. Overrides `keepMounted`.
   * @default false
   */
  hiddenUntilFound?: boolean;
  /**
   * Keeps a closed panel in the DOM. For content that is expensive to build, or
   * that holds form state which should survive being folded away.
   * @default false
   */
  keepMounted?: boolean;
  /** The body. */
  children?: React.ReactNode;
}

/**
 * The three weights, said the way a *container* says them — the sheet is never
 * dyed, exactly as on Box and Accordion. A Collapsible holds other people's
 * content, and that content arrives with its own colours.
 *
 * `text` is the one to reach for inside running prose or inside a Card: a bare
 * "Show more" line owes the page no rectangle of its own.
 */
const variantClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel-hover)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--neba-fg) bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  text: 'text-(--neba-fg) bg-transparent'
};

/**
 * One section that folds, standing on its own.
 *
 * An [Accordion] is a *set* of these and owns which one of them is open; this is
 * the same fold with nothing else beside it, so what it needs is an `open` of
 * its own rather than a place in somebody's list. Reach for it for a "Show more"
 * on a form, an optional block of settings, the details under a row.
 *
 * Base UI owns the parts that are genuinely hard: the `button` / panel pairing
 * and the `aria-controls` / `aria-expanded` wiring between them, `hidden="until
 * -found"`, and measuring the panel so it has a height to animate from.
 *
 * The panel's height *is* animated, which looks like an exception to the rule
 * against moving things and is not: nothing is transformed, no text is
 * resampled, and the content does not shift relative to the panel it is in —
 * the panel is a window opening onto it. Content that appears instantly is a
 * page that jumps, which is the failure the rule exists to prevent.
 */
export const Collapsible = React.forwardRef<HTMLDivElement, CollapsibleProps>(function Collapsible(
  {
    variant = 'outline',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    open,
    defaultOpen = false,
    onOpenChange,
    title,
    subtitle,
    startIcon,
    action,
    trigger,
    indicator = true,
    disabled = false,
    padded = true,
    hiddenUntilFound = false,
    keepMounted = false,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const padX = boxPaddingXClasses[density][size];
  const padY = boxPaddingYClasses[density][size];

  return (
    <BaseUICollapsible.Root
      ref={ref}
      open={open}
      defaultOpen={defaultOpen}
      onOpenChange={(next) => onOpenChange?.(next)}
      disabled={disabled}
      className={[
        // `overflow-hidden` is what makes the panel a window rather than
        // something that spills past the sheet's own corners while it moves.
        'flex flex-col overflow-hidden',
        radiusClasses[size],
        variantClasses[variant],
        transitionClasses,
        className ?? ''
      ]
        .filter(Boolean)
        .join(' ')}
      style={{ ...surfaceSlots(color, elevation), ...style }}
      {...props}
    >
      {trigger ? (
        <BaseUICollapsible.Trigger render={trigger} />
      ) : (
        <div className="flex w-full items-center">
          <BaseUICollapsible.Trigger
            className={[
              'flex min-w-0 flex-1 cursor-pointer items-center text-start',
              padX,
              padY,
              gapClasses[size],
              transitionClasses,
              iconClasses,
              // Inset rather than offset. The sheet clips its children so the
              // panel can be a window, and `overflow: hidden` clips a
              // descendant's outline along with everything else — an offset
              // ring on a trigger that fills the top of the sheet would be
              // shaved off on three sides.
              'focus-visible:[outline:2px_solid_var(--n-ring)] focus-visible:[outline-offset:-2px]',
              'hover:bg-(--n-soft)',
              'data-[panel-open]:text-(--n-accent)',
              'disabled:cursor-not-allowed disabled:bg-transparent disabled:text-(--neba-disabled-fg)'
            ].join(' ')}
          >
            {hasContent(startIcon) ? (
              <span className="flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg)">
                {startIcon}
              </span>
            ) : null}

            <span className={`flex min-w-0 flex-1 flex-col ${sheetHeaderGapClasses[size]}`}>
              {hasContent(title) ? (
                <span className={`truncate font-semibold ${sheetTitleClasses[size]}`}>{title}</span>
              ) : null}
              {hasContent(subtitle) ? (
                <span className={`truncate text-(--neba-muted-fg) ${metaTextClasses[size]}`}>
                  {subtitle}
                </span>
              ) : null}
            </span>

            {/* Turned, not moved: the chevron is a glyph, so rotating it is the
                one allowance the no-transform rule makes. It is also the only
                thing on the header that reports the state by moving, which is
                why the header itself only changes colour. */}
            {indicator ? (
              <span
                className={[
                  'flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg)',
                  '[transition:rotate_var(--neba-duration)_var(--neba-ease)]',
                  'data-[panel-open]:rotate-180'
                ].join(' ')}
              >
                <ChevronIcon />
              </span>
            ) : null}
          </BaseUICollapsible.Trigger>

          {hasContent(action) ? (
            <span className={`flex shrink-0 items-center ${padX}`}>{action}</span>
          ) : null}
        </div>
      )}

      {/*
        `height` from Base UI's measured `--collapsible-panel-height` down to 0,
        plus `overflow-hidden` so the body is clipped rather than squashed while
        it moves — the same two lines the Accordion panel is written with.
      */}
      <BaseUICollapsible.Panel
        hiddenUntilFound={hiddenUntilFound}
        keepMounted={keepMounted}
        className={[
          'h-(--collapsible-panel-height) overflow-hidden',
          '[transition:height_var(--neba-duration)_var(--neba-ease)]',
          'motion-reduce:[transition-duration:0ms]',
          'data-[starting-style]:h-0 data-[ending-style]:h-0'
        ].join(' ')}
      >
        <div
          className={[
            'min-w-0 text-(--neba-muted-fg)',
            sheetBodyClasses[size],
            padded ? padX : '',
            // The default header already paid for the space above, so the body
            // only owes the space below it — otherwise a closed Collapsible
            // would look padded. A caller's own `trigger` has paid for nothing,
            // so there the panel owes both.
            padded ? (trigger ? padY : density === 'compact' ? 'pb-2' : 'pb-4') : ''
          ]
            .filter(Boolean)
            .join(' ')}
        >
          {children}
        </div>
      </BaseUICollapsible.Panel>
    </BaseUICollapsible.Root>
  );
});

'use client';

import * as React from 'react';
import { Accordion as BaseUIAccordion } from '@base-ui/react/accordion';
import { boxPaddingXClasses, boxPaddingYClasses } from '../box/Box.js';
import { ChevronIcon } from '../../internal/icons.js';
import {
  cx,
  focusRingClasses,
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
import type { NebaDensity, NebaElevation, NebaSize, NebaStyleProps } from '../../types.js';

/**
 * What an AccordionItem inherits from the Accordion around it.
 *
 * The same arrangement List uses, and for the same reason: a section is a
 * section *of* something, so `size`, `density` and whether the sections are
 * ruled belong to the stack rather than to any one fold in it. `List` keeps its
 * context in `List.tsx` because the two components are one file; so are these.
 */
interface AccordionContextValue {
  size: NebaSize;
  density: NebaDensity;
  dividers: boolean;
}

const AccordionContext = React.createContext<AccordionContextValue>({
  size: 'md',
  density: 'default',
  dividers: true
});

export interface AccordionProps
  extends
    NebaStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'onChange'> {
  /**
   * Drop shadow depth. `0` (the default) is flat.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * Whether more than one section may be open at once.
   *
   * `false` by default, which is the whole reason an accordion is not just a
   * stack of collapsibles: closing the last one as you open the next is what
   * keeps the page from growing under the reader.
   * @default false
   */
  multiple?: boolean;
  /** Which sections are open. Use with `onValueChange` for a controlled accordion. */
  value?: (string | number)[];
  /** Which start open, for an uncontrolled one. */
  defaultValue?: (string | number)[];
  onValueChange?: (value: (string | number)[]) => void;
  /**
   * Separates the sections with a hairline rather than with space.
   *
   * On by default, which is the other way round from List. A list of tiles is a
   * list; an accordion of tiles is a stack of cards that happen to fold, and the
   * rule is what says the sections are parts of one thing.
   * @default true
   */
  dividers?: boolean;
  /** Unavailable. Every section stops answering. */
  disabled?: boolean;
  /**
   * Keeps closed panels in the DOM so the browser's own page search can find and
   * open them. Overrides `keepMounted`.
   * @default false
   */
  hiddenUntilFound?: boolean;
  /**
   * Keeps closed panels in the DOM. For content that is expensive to build, or
   * that holds form state which should survive being folded away.
   * @default false
   */
  keepMounted?: boolean;
  children?: React.ReactNode;
}

export interface AccordionItemProps extends Omit<
  React.ComponentPropsWithoutRef<'div'>,
  'title' | 'onChange'
> {
  /**
   * Identifies the section to `value` / `defaultValue`. Base UI generates one
   * when it is left out, which is fine for an accordion nobody drives from code.
   */
  value?: string | number;
  /** The heading on the fold. */
  title?: React.ReactNode;
  /** A second line under the title, one step down the type scale and muted. */
  subtitle?: React.ReactNode;
  /** Content before the title — an icon, a status dot, a count. */
  startIcon?: React.ReactNode;
  /**
   * A control pinned to the end of the header, before the chevron.
   *
   * Deliberately outside the trigger: a header that both folds and holds a
   * switch has two things to press, and one of them cannot be nested inside the
   * other. The same shape ListItem uses.
   */
  action?: React.ReactNode;
  /** Unavailable. This section stops folding; the rest keep working. */
  disabled?: boolean;
  /** The body. */
  children?: React.ReactNode;
}

/**
 * The three weights, said the way a *container* says them — the sheet is never
 * dyed, exactly as on Box and List. An accordion holds other people's content.
 *
 * `text` is the one to reach for inside a Card: the card is already a sheet, and
 * a second bordered rectangle inside it is a second rectangle.
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
 * The rule between two sections, written as `>div+div` rather than as a class on
 * each item so it holds however the caller composed them — through a `.map()`,
 * through fragments, through a component of their own that renders an item.
 */
const dividerClasses = '[&>div+div]:border-t [&>div+div]:[border-color:var(--n-line)]';

/**
 * A section sits one step down the radius ladder from the sheet it is inside,
 * the same step a ListItem takes.
 */
const itemRadiusClasses: Record<NebaSize, string> = {
  xs: radiusClasses.xs,
  sm: radiusClasses.xs,
  md: radiusClasses.sm,
  lg: radiusClasses.sm,
  xl: radiusClasses.md
};

/**
 * A stack of sections, one of which is open.
 *
 * Base UI owns the parts that are genuinely hard: the `button` / `region`
 * pairing and the `aria-controls` / `aria-expanded` wiring between them, the
 * open set, and measuring the panel so it has a height to animate from.
 *
 * What is here is the surface, the ladders and the one motion decision. The
 * panel's height *is* animated, which looks like an exception to the rule
 * against moving things and is not: nothing is transformed, no text is resampled,
 * and the content does not shift relative to the panel it is in — the panel is
 * a window opening onto it. An accordion whose sections appear instantly is a
 * page that jumps, which is the failure the rule exists to prevent.
 */
export const Accordion = React.forwardRef<HTMLDivElement, AccordionProps>(function Accordion(
  {
    variant = 'outline',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    multiple = false,
    value,
    defaultValue,
    onValueChange,
    dividers = true,
    disabled = false,
    hiddenUntilFound = false,
    keepMounted = false,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const context = React.useMemo(() => ({ size, density, dividers }), [size, density, dividers]);

  const classNames = cx(
    'flex flex-col',
    radiusClasses[size],
    variantClasses[variant],
    transitionClasses,
    // Without dividers the sections are tiles and the sheet keeps a hair of
    // padding so a hovered header does not run into the edge. With them the
    // rules have to reach the edge, so the padding goes and the tiles square off.
    dividers ? `overflow-hidden ${dividerClasses}` : 'p-1',
    className ?? ''
  );

  return (
    <AccordionContext.Provider value={context}>
      <BaseUIAccordion.Root
        ref={ref}
        multiple={multiple}
        value={value}
        defaultValue={defaultValue}
        onValueChange={(next) => onValueChange?.(next as (string | number)[])}
        disabled={disabled}
        hiddenUntilFound={hiddenUntilFound}
        keepMounted={keepMounted}
        className={classNames}
        style={{ ...surfaceSlots(color, elevation), ...style }}
        {...props}
      >
        {children}
      </BaseUIAccordion.Root>
    </AccordionContext.Provider>
  );
});

/**
 * One section.
 *
 * The header is always a row; what is inside it is a real `<button>` covering
 * the title and the chevron, with `action` sitting outside that button as a
 * separate control. The same shape Chip and ListItem use, for the same two
 * reasons: a `<div>` carrying a click handler is invisible to a keyboard, and a
 * `<button>` inside a `<button>` is markup the browser rewrites on parse.
 */
export const AccordionItem = React.forwardRef<HTMLDivElement, AccordionItemProps>(
  function AccordionItem(
    { value, title, subtitle, startIcon, action, disabled = false, className, children, ...props },
    ref
  ) {
    const { size, density, dividers } = React.useContext(AccordionContext);

    const padX = boxPaddingXClasses[density][size];
    const padY = boxPaddingYClasses[density][size];

    return (
      <BaseUIAccordion.Item
        ref={ref}
        value={value}
        disabled={disabled}
        className={cx('flex flex-col', className ?? '')}
        {...props}
      >
        <BaseUIAccordion.Header className="m-0 flex w-full items-center [font:inherit]">
          <BaseUIAccordion.Trigger
            className={cx(
              'flex min-w-0 flex-1 cursor-pointer items-center text-start',
              padX,
              padY,
              gapClasses[size],
              transitionClasses,
              iconClasses,
              focusRingClasses,
              dividers ? '' : itemRadiusClasses[size],
              'hover:bg-(--n-soft)',
              'data-[panel-open]:text-(--n-accent)',
              'disabled:cursor-not-allowed disabled:bg-transparent disabled:text-(--neba-disabled-fg)'
            )}
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
                thing on the header that reports the open state by moving, which
                is why the header itself only changes colour. */}
            <span
              className={[
                'flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg)',
                '[transition:rotate_var(--neba-duration)_var(--neba-ease)]',
                'data-[panel-open]:rotate-180'
              ].join(' ')}
            >
              <ChevronIcon />
            </span>
          </BaseUIAccordion.Trigger>

          {hasContent(action) ? (
            <span className={`flex shrink-0 items-center ${padX}`}>{action}</span>
          ) : null}
        </BaseUIAccordion.Header>

        {/*
          `height` from Base UI's measured `--accordion-panel-height` down to 0,
          plus `overflow-hidden` so the body is clipped rather than squashed
          while it moves. Written as utilities rather than as CSS in `styles.css`
          because the Tailwind form is two legible lines, which is the bar for
          keeping something here.
        */}
        <BaseUIAccordion.Panel
          className={[
            'h-(--accordion-panel-height) overflow-hidden',
            '[transition:height_var(--neba-duration)_var(--neba-ease)]',
            'data-[starting-style]:h-0 data-[ending-style]:h-0'
          ].join(' ')}
        >
          <div
            className={[
              'text-(--neba-muted-fg)',
              sheetBodyClasses[size],
              padX,
              // The header already paid for the space above; the body only owes
              // the space below it, or every closed section would look padded.
              density === 'compact' ? 'pb-2' : 'pb-4'
            ].join(' ')}
          >
            {children}
          </div>
        </BaseUIAccordion.Panel>
      </BaseUIAccordion.Item>
    );
  }
);

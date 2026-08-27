import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { boxPaddingXClasses, boxPaddingYClasses } from '../box/Box.js';
import {
  hasContent,
  radiusClasses,
  sheetSectionGapClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaElevation, NebaPosition, NebaStyleProps } from '../../types.js';

export interface ToolbarProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * Drop shadow depth. `0` — the default — is flat even when the bar is pinned:
   * a shadow under a header is a way of saying "there is content beneath this",
   * and that is only true once the page has been scrolled. Raise it yourself, or
   * leave it flat and turn on `divider`.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * How the bar sits in the page's scroll.
   *
   * - `static` — in the flow, scrolling away with the content.
   * - `sticky` — in the flow until it reaches the edge, then held there. What an
   *   application header usually wants: it takes up its own space, so nothing
   *   underneath has to be padded around it.
   * - `fixed` — out of the flow entirely. The page needs padding of its own, or
   *   the first screenful sits behind the bar.
   * @default 'static'
   */
  position?: NebaPosition;
  /** Which edge it is held against when `position` is not `static`. @default 'top' */
  side?: 'top' | 'bottom';
  /**
   * Draws a hairline along the edge that faces the content — under a `top` bar,
   * over a `bottom` one.
   * @default false
   */
  divider?: boolean;
  /** Pinned to the start of the bar: a logo, a title, a back button. */
  start?: React.ReactNode;
  /** Pinned to the end: the actions. */
  end?: React.ReactNode;
  /**
   * Renders something other than a `<div>` — `render={<header />}`,
   * `render={<nav />}`. Base UI's own escape hatch, and worth reaching for here:
   * a page's header should be a `<header>`.
   */
  render?: useRender.RenderProp;
  /** The middle. Takes whatever width `start` and `end` leave. */
  children?: React.ReactNode;
}

/**
 * The three weights, said the way a *container* says them — the bar is never
 * dyed, exactly as on Box and Accordion. A toolbar holds other people's
 * controls, and those controls arrive with colours of their own.
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

const positionClasses: Record<NebaPosition, Record<'top' | 'bottom', string>> = {
  static: { top: '', bottom: '' },
  sticky: { top: 'sticky top-0 z-20', bottom: 'sticky bottom-0 z-20' },
  fixed: { top: 'fixed inset-x-0 top-0 z-30', bottom: 'fixed inset-x-0 bottom-0 z-30' }
};

/** The rule faces the content, so it moves to the other edge on a bottom bar. */
const dividerClasses: Record<'top' | 'bottom', string> = {
  top: 'border-b [border-color:var(--n-line)]',
  bottom: 'border-t [border-color:var(--n-line)]'
};

/**
 * A bar of controls: an application header, a page's action row, the strip along
 * the bottom of an editor.
 *
 * Three slots and a row. `start` and `end` are pinned to their ends and
 * `children` takes what is left, which is the arrangement every toolbar has ever
 * had — so it is laid out here rather than left to a caller and a spacer `<div>`
 * they have to remember.
 *
 * The one thing it does not do is take a height. A toolbar is as tall as the
 * controls in it plus its padding, and that padding is the `size`/`density` pair
 * every other surface uses — so `density="compact"` gives the dense bar without
 * a second prop meaning the same thing, and without the type scale moving.
 *
 * It has no `role="toolbar"`, deliberately. That role is a promise about
 * keyboard behaviour — one tab stop for the whole bar, arrow keys between the
 * controls in it — and a bar that claims it without implementing it is worse for
 * a keyboard reader than one that never claimed anything. What a header wants is
 * `render={<header />}`; what a genuine roving-focus toolbar wants is a
 * ButtonGroup, which is one.
 */
export const Toolbar = React.forwardRef<HTMLDivElement, ToolbarProps>(function Toolbar(
  {
    variant = 'outline',
    size = 'md',
    color = 'primary',
    density = 'default',
    elevation = 0,
    position = 'static',
    side = 'top',
    divider = false,
    start,
    end,
    render,
    className,
    style,
    children,
    ...props
  },
  ref
) {
  const classNames = [
    'flex w-full min-w-0 items-center',
    boxPaddingXClasses[density][size],
    boxPaddingYClasses[density][size],
    sheetSectionGapClasses[size],
    // A pinned bar spans an edge of the window, and a rounded corner against the
    // edge of the screen is a gap with nothing behind it. Only a bar sitting in
    // the flow is a sheet with corners.
    position === 'static' ? radiusClasses[size] : '',
    variantClasses[variant],
    divider ? dividerClasses[side] : '',
    positionClasses[position][side],
    transitionClasses,
    className ?? ''
  ]
    .filter(Boolean)
    .join(' ');

  return useRender({
    render,
    ref,
    props: {
      className: classNames,
      style: { ...surfaceSlots(color, elevation), ...style },
      children: (
        <>
          {hasContent(start) ? (
            <div className="flex min-w-0 shrink-0 items-center gap-2">{start}</div>
          ) : null}

          {/* `flex-1` even when empty, so `start` and `end` stay at their ends
              rather than collapsing together in the middle of the bar. */}
          <div className="flex min-w-0 flex-1 items-center gap-2">{children}</div>

          {hasContent(end) ? (
            <div className="flex min-w-0 shrink-0 items-center gap-2">{end}</div>
          ) : null}
        </>
      ),
      ...props
    }
  });
});

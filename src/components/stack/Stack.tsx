'use client';

import * as React from 'react';
import {
  animBaseClass,
  animationClasses,
  animationSlots,
  transitionParts
} from '../../internal/animate.js';
import { cx } from '../../internal/styles.js';
import { useStyleDefaults } from '../../internal/defaults.js';
import type { NebaSize, NebaStaggerProps, NebaTransition } from '../../types.js';

/**
 * Which way the pile grows.
 *
 * - `horizontal` — each item sits under the one before it along the inline
 *   axis. A row of faces, a row of coins.
 * - `vertical` — the same down the block axis. A pile seen from the front.
 * - `diagonal` — flows along the inline axis like `horizontal` and drops each
 *   item as it goes, which is a fanned deck: the item behind shows its corner
 *   rather than its edge. How far it drops is `drop`.
 */
export type StackDirection = 'horizontal' | 'vertical' | 'diagonal';

export interface StackProps
  extends NebaStaggerProps, Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /** Which way the pile grows. @default 'horizontal' */
  direction?: StackDirection;
  /**
   * How far each item sits **under** the one before it — a CSS length, or a
   * number of pixels — along the axis the stack flows on.
   *
   * Left out it is a fraction of `size`, roughly a third of a control at every
   * step: enough that the pile reads as a pile, and not so much that the item
   * behind is gone.
   */
  overlap?: number | string;
  /**
   * How far each item falls on the axis the stack does **not** flow along.
   * Only `diagonal` moves on two axes, so only `diagonal` reads it.
   *
   * Defaults to `overlap`, which is a shallow fan. A true forty-five degrees
   * would be the item's own width, which is the one number a stack cannot know
   * without measuring what it was handed.
   */
  drop?: number | string;
  /**
   * The size of the things being stacked, which is only ever read to work out
   * the default `overlap`. Set `overlap` and this does nothing.
   * @default 'md'
   */
  size?: NebaSize;
  /**
   * How many items are drawn before the rest become an overflow marker. Left
   * out, every one of them is drawn.
   */
  max?: number;
  /**
   * How many there are altogether, when the stack was handed only the first
   * few. Without it the count is worked out from the children, which is right
   * only when all of them were passed.
   */
  total?: number;
  /**
   * What stands in for the ones that did not fit, given how many those are.
   * Drawn as one more item at the back of the pile.
   *
   * A function rather than a node, because the number is the whole point of it:
   * `(hidden) => <Avatar initials={`+${hidden}`} />`.
   */
  overflow?: (hidden: number) => React.ReactNode;
  /**
   * Which end of the list is at the front of the pile.
   *
   * `first` — the default — puts the first child on top, so a stack read from
   * its leading edge is read front to back and the item the pile is *about*
   * comes first rather than last.
   * @default 'first'
   */
  front?: 'first' | 'last';
  /**
   * What each item is multiplied by against the one in front of it — `0.94`
   * takes six per cent off at every step, so the pile recedes.
   *
   * It is the `scale` property rather than a `transform`, which is what lets it
   * sit on the same element as an entrance without the two fighting: the
   * individual transform properties are applied before the shorthand.
   * @default 1
   */
  scaleStep?: number;
  /**
   * The same for opacity: `0.8` leaves each item four fifths as solid as the
   * one in front. It multiplies with an entrance's own fade rather than
   * replacing it.
   * @default 1
   */
  opacityStep?: number;
  /**
   * Draws a hairline in the page's own surface colour around each item.
   *
   * The one place the library draws a hard outline rather than an acrylic edge,
   * and it is not decoration: two shapes of similar tone laid over each other
   * have no edge between them at all and the pile reads as one smeared shape.
   * Written onto the items themselves, so it follows a circle round.
   * @default false
   */
  ring?: boolean;
  /**
   * How each item arrives — the library's own `transition` vocabulary, so a
   * Stack's fade and an `AnimateFade` are the same fade.
   *
   * `stagger` is what turns it into a pile being dealt rather than a pile
   * appearing: it is added to each item's delay in turn.
   */
  transition?: NebaTransition;
  /** The things being stacked. Every top-level child is one item. */
  children?: React.ReactNode;
}

/**
 * How far one item sits under the last, per step, when nobody said.
 *
 * Roughly a third of a control at every size: enough that the pile reads as a
 * pile, and not so much that the item behind it is gone.
 */
const overlapSizes: Record<NebaSize, string> = {
  xs: '0.375rem',
  sm: '0.5rem',
  md: '0.625rem',
  lg: '0.75rem',
  xl: '0.875rem'
};

/** A number is pixels; a string is already a CSS length. */
function lengthOf(value: number | string): string {
  return typeof value === 'number' ? `${value}px` : value;
}

/**
 * Things laid over each other, so the set reads as a pile rather than a row.
 *
 * The overlap is a **margin** rather than a `translate`, which is the whole
 * reason a Stack can sit in a paragraph: a translated pile draws outside a box
 * that is still the size of one item, so everything after it is laid out
 * against the wrong width. Margins make the box exactly as big as what is in
 * it, at every direction and every overlap.
 *
 * Each item is drawn into a wrapper of its own rather than cloned onto. Cloning
 * would need every child to accept a `className` and a `style` — which a
 * Tooltip around an avatar, or anything produced by a `.map()` through somebody
 * else's component, is not obliged to do. The wrapper carries the offset, the
 * depth and the entrance; the child is left exactly as it was passed.
 *
 * The one thing written onto the children is `ring`, and only because a ring
 * has to follow the shape it is around: a hairline on the wrapper of a circular
 * avatar is a square.
 */
export const Stack = React.forwardRef<HTMLDivElement, StackProps>(function Stack(rawProps, ref) {
  const {
    direction = 'horizontal',
    overlap,
    drop,
    size = 'md',
    max,
    total,
    overflow,
    front = 'first',
    scaleStep = 1,
    opacityStep = 1,
    ring = false,
    transition,
    stagger = 0,
    durationStep = 0,
    reverse = false,
    className,
    style,
    children,
    ...props
  } = useStyleDefaults(rawProps, ['size']);

  const items = React.Children.toArray(children);
  const shown = max === undefined ? items : items.slice(0, Math.max(0, max));
  const hidden = Math.max(0, (total ?? items.length) - shown.length);
  const extra = hidden > 0 ? overflow?.(hidden) : null;
  const drawn = extra === null || extra === undefined ? shown : [...shown, extra];

  const step = lengthOf(overlap ?? overlapSizes[size]);
  const fall = lengthOf(drop ?? overlap ?? overlapSizes[size]);
  // `diagonal` runs along the inline axis like `horizontal` does and drops each
  // item as it goes. The drop is a per-item margin rather than the flow's,
  // because a flow only overlaps on the axis it runs along.
  const column = direction === 'vertical';
  const drops = direction === 'diagonal';

  const parts = transitionParts(transition);
  const effectClass = parts ? `${animBaseClass} ${animationClasses[parts.effect]}` : '';

  return (
    <div
      ref={ref}
      className={cx(
        // `isolate`, so the z-order below is resolved against the stack rather
        // than against whatever the page had already stacked.
        'isolate inline-flex',
        column ? 'flex-col items-start' : 'items-start',
        // Depth three is the child itself: the item wrapper, the box holding the
        // depth cue, and then what was passed. A ring belongs there rather than
        // on a wrapper, or a circle gets a square one.
        ring ? '[&>*>*>*]:ring-2 [&>*>*>*]:ring-(--neba-surface)' : '',
        className ?? ''
      )}
      style={style}
      {...props}
    >
      {drawn.map((child, index) => {
        const order = reverse ? drawn.length - 1 - index : index;
        const slots = parts
          ? animationSlots({
              ...parts.slots,
              delay: parts.slots.delay + order * stagger,
              // Clamped, so a `durationStep` steeper than the pile is deep stops
              // at instant rather than turning the back of it into `-200ms`.
              duration: Math.max(0, parts.slots.duration + order * durationStep)
            })
          : undefined;

        return (
          <span
            key={index}
            data-neba-stack-item=""
            className={effectClass || undefined}
            style={{
              ...slots,
              // The first item starts the pile; every other one is pulled back
              // under it along the axis the stack flows on.
              ...(index === 0
                ? null
                : column
                  ? { marginBlockStart: `calc(${step} * -1)` }
                  : { marginInlineStart: `calc(${step} * -1)` }),
              // And the diagonal's other axis, which the flow cannot give: a
              // fixed margin in a row is measured from the row's own top, so it
              // has to be multiplied out per item.
              ...(drops ? { marginBlockStart: `calc(${fall} * ${index})` } : null),
              // Later children paint behind earlier ones, which is the opposite
              // of the DOM's own order — so it is stated rather than left to it.
              zIndex: front === 'first' ? drawn.length - index : index + 1
            }}
          >
            <span
              // `scale` and `opacity` and nothing else. `scale` is the
              // individual property, so an entrance animating `transform` on
              // the wrapper above composes with it instead of replacing it.
              style={{
                display: 'inline-flex',
                scale: scaleStep === 1 ? undefined : String(scaleStep ** index),
                opacity: opacityStep === 1 ? undefined : opacityStep ** index
              }}
            >
              {child}
            </span>
          </span>
        );
      })}
    </div>
  );
});

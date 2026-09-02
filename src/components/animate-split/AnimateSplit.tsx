'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import {
  animBaseClass,
  animationClasses,
  isInfinite,
  staggerChildren,
  transitionParts,
  useAnimationRun
} from '../../internal/animate.js';
import { graphemesOf, textOf, wordsOf } from '../../internal/text.js';
import { cx, srOnlyClasses } from '../../internal/styles.js';
import type {
  NebaAnimateProps,
  NebaAnimation,
  NebaSide,
  NebaStaggerProps,
  NebaTimelineProps
} from '../../types.js';

/** What a piece is. */
export type NebaSplitBy = 'word' | 'character';

export interface AnimateSplitProps
  extends
    NebaAnimateProps,
    NebaStaggerProps,
    NebaTimelineProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'children'> {
  /** The text, when it is easier to pass than to nest. Overrides `children`. */
  text?: string;
  /**
   * What one piece is. `word` is the default and the one to reach for: a
   * heading of eight words is eight boxes, and the same heading by character is
   * forty-six.
   * @default 'word'
   */
  by?: NebaSplitBy;
  /**
   * Which effect each piece arrives on — the library's own vocabulary, so a
   * split heading's fade and an `AnimateFade` are the same fade.
   * @default 'slide'
   */
  effect?: NebaAnimation;
  /** Which edge a `slide` piece comes from. @default 'bottom' */
  from?: NebaSide;
  /** How far a `slide` piece travels. @default '0.4em' */
  distance?: number | string;
  /** Where a `grow` or `zoom` piece starts, as a multiple of its final size. */
  scale?: number;
  /** How far a `rotate` piece turns from, in degrees. */
  angle?: number;
  /** Which edge a `reveal` piece is wiped from. */
  side?: NebaSide;
  /**
   * Which language the text is in, for finding the word and character
   * boundaries. A word boundary is not a space in Japanese, Thai or Chinese.
   */
  locale?: string;
  /** Renders something other than a `<div>`. Base UI's own escape hatch. */
  render?: useRender.RenderProp;
  /** The text to split. Only text is split — an element contributes its words. */
  children?: React.ReactNode;
}

/**
 * A line of text arriving a word — or a letter — at a time.
 *
 * `AnimateAppear` walked down a list a child at a time; this walks along a
 * sentence. The difference is only where the pieces come from, which is why
 * everything below the split is the same machinery: one `@keyframes` per piece,
 * held back by its place in the line.
 *
 * The whole string is in the document from the first frame — in a clipped box
 * for a screen reader, which reads it once and is not made to sit through the
 * performance — and what animates is a visible copy that is `aria-hidden`. That
 * is `AnimateTyping`'s arrangement and it is here for the same two reasons: the
 * effect costs a reader who cannot see it nothing, and a find-in-page still
 * finds the sentence rather than forty-six separate letters.
 *
 * Every piece is an `inline-block`, which is what lets it be moved at all — an
 * inline box cannot be translated up. Each keeps the space that followed it, so
 * a line still breaks between words and never inside the gap.
 */
export const AnimateSplit = React.forwardRef<HTMLDivElement, AnimateSplitProps>(
  function AnimateSplit(
    {
      text,
      by = 'word',
      effect = 'slide',
      duration = 520,
      delay = 0,
      easing,
      repeat = 1,
      alternate,
      paused,
      trigger = 'mount',
      play,
      once = true,
      threshold = 0.2,
      stagger = 45,
      durationStep = 0,
      reverse = false,
      timeline,
      range,
      from = 'bottom',
      distance = '0.4em',
      scale,
      angle,
      side,
      locale,
      render,
      className,
      style,
      children,
      ...props
    },
    ref
  ) {
    const run = useAnimationRun({
      trigger,
      play,
      once,
      threshold,
      paused,
      infinite: isInfinite(repeat)
    });

    const source = text ?? textOf(children);
    const pieces = React.useMemo(
      () => (by === 'word' ? wordsOf(source, locale) : graphemesOf(source, locale)),
      [by, source, locale]
    );

    // Read through the same table the `transition` prop reads, so an effect
    // named here and an effect named anywhere else in the library are one thing.
    const parts = transitionParts({
      type: effect,
      duration,
      delay,
      easing,
      repeat,
      alternate,
      from,
      distance,
      scale,
      angle,
      side,
      timeline,
      range
    });

    const animated = staggerChildren(
      parts
        ? pieces.map((piece, index) => (
            // `pre` rather than `pre-wrap`: the piece is one box, so there is
            // nothing inside it to wrap, and the trailing space has to survive.
            <span key={index} className="inline-block whitespace-pre">
              {piece}
            </span>
          ))
        : null,
      `${animBaseClass} ${animationClasses[effect]}`,
      parts?.slots ?? { duration, delay, repeat },
      { stagger, durationStep, reverse }
    );

    return useRender({
      render,
      ref: [ref, run.ref],
      props: {
        ...props,
        className,
        // Only the play state lives on the root. Every other slot is per piece,
        // because the delay is what the whole effect is made of.
        style: { '--n-anim-state': run.state, ...style } as React.CSSProperties,
        ...run.handlers,
        'data-neba-animation': 'split',
        'data-state': run.state,
        children: (
          <>
            <span className={cx(srOnlyClasses)}>{source}</span>
            <span aria-hidden="true">{animated}</span>
          </>
        )
      }
    });
  }
);

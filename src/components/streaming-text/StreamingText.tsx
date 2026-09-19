'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { cx, hasContent } from '../../internal/styles.js';
import type { NebaColor } from '../../types.js';

export interface StreamingTextProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * The text so far. A **string** is what this is for: it is cut into words,
   * and each one fades in as it lands. Anything else is rendered untouched,
   * with the caret and the reserved height still around it.
   */
  children?: React.ReactNode;
  /**
   * Whether more is still coming. It draws the caret and marks the block busy;
   * it does not change what is already there.
   * @default false
   */
  streaming?: boolean;
  /**
   * The block at the end while the stream runs. `false` drops it, and a node
   * replaces it — a spinner, a set of dots, a word.
   * @default true
   */
  cursor?: React.ReactNode | boolean;
  /**
   * Fades each word in as it arrives.
   *
   * On. It costs one element per word, which is the price of the effect: a
   * transition on the block as a whole would fade the *whole answer* every time
   * a token landed. Turn it off for a very long answer, or where the text is
   * being re-rendered from something other than a stream.
   * @default true
   */
  fade?: boolean;
  /**
   * How many lines of height to hold before anything has arrived, so the page
   * does not jump when the first word lands. Measured in `1lh`, which is the
   * line height this block actually has rather than a guess at one.
   *
   * The reservation is a floor and stays a floor once the text is there: a
   * height that is given up on arrival is the same jump twice.
   * @default 1
   */
  lines?: number;
  /** The caret's colour family. @default 'primary' */
  color?: NebaColor;
  /** Renders something other than a `<div>` — a `<p>`, most of the time. */
  render?: useRender.RenderProp;
}

/**
 * The tokens a string is drawn as: words, and the whitespace between them.
 *
 * The separators are kept, which is what makes the pieces add back up to the
 * original — an answer's line breaks are part of what it says, and the block is
 * `whitespace-pre-wrap` so they survive.
 */
function tokenize(text: string): string[] {
  return text.split(/(\s+)/).filter((piece) => piece !== '');
}

/**
 * Text arriving from somewhere else.
 *
 * [AnimateTyping](../transitions/animate-typing) types out a string it already
 * has: it knows the ending and is spending time on the way there. This is the
 * opposite direction — the string is being handed over a piece at a time,
 * nobody knows how long it will be, and the component's job is to make that
 * land without the page moving underneath whoever is reading it.
 *
 * Three things do that. The block holds a floor of `lines` before anything has
 * arrived, and keeps holding it afterwards, because a reservation given up on
 * arrival is the same jump twice. A caret says the text is not finished. And
 * each word fades in on its own rather than the block fading as a whole — which
 * is not a flourish: a transition on the block would replay the *entire* answer
 * every time a token landed.
 *
 * The fade needs no bookkeeping at all. Words are keyed by position, so a word
 * already on screen keeps its element and never animates again; only a new one
 * is a new element, and the last word grows a character at a time inside the
 * element it already has.
 *
 * It is deliberately **not** a live region. An answer that announced itself
 * token by token would be unusable, and one that announced itself whole on
 * every token would say the beginning again and again. Announcing a finished
 * answer is the application's decision, because only the application knows
 * whether the reader asked for this one.
 */
export const StreamingText = React.forwardRef<HTMLDivElement, StreamingTextProps>(
  function StreamingText(
    {
      children,
      streaming = false,
      cursor = true,
      fade = true,
      lines = 1,
      color = 'primary',
      render,
      className,
      style,
      ...props
    },
    ref
  ) {
    const text = typeof children === 'string' ? children : null;
    const tokens = React.useMemo(
      () => (text !== null && fade ? tokenize(text) : null),
      [text, fade]
    );

    const caret =
      streaming && cursor !== false ? (
        cursor === true ? (
          <span aria-hidden="true" className="neba-stream-caret" />
        ) : (
          cursor
        )
      ) : null;

    return useRender({
      render: render ?? <div />,
      ref,
      props: {
        'aria-busy': streaming || undefined,
        'data-streaming': streaming || undefined,
        className: cx(
          // `pre-wrap` rather than the default: an answer's own line breaks are
          // part of what it says, and collapsing them turns a list into a
          // paragraph.
          'min-h-(--n-reserve) whitespace-pre-wrap',
          className
        ),
        style: {
          '--n-reserve': `calc(${Math.max(lines, 0)} * 1lh)`,
          '--n-accent': `var(--neba-${color}-accent)`,
          ...style
        } as React.CSSProperties,
        children: (
          <>
            {tokens
              ? tokens.map((token, index) =>
                  /\s/.test(token) ? (
                    // Whitespace carries no ink, so there is nothing to fade
                    // and no element worth spending on it.
                    <React.Fragment key={index}>{token}</React.Fragment>
                  ) : (
                    <span key={index} className="neba-stream-word">
                      {token}
                    </span>
                  )
                )
              : children}
            {hasContent(caret) ? caret : null}
          </>
        ),
        ...props
      }
    });
  }
);

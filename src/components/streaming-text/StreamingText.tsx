'use client';

import * as React from 'react';
import { useRender } from '@base-ui/react/use-render';
import { segmenter } from '../../internal/format.js';
import { useLayoutEffectOnClient } from '../../internal/layout-effect.js';
import { useHydrated } from '../../internal/media.js';
import { cx, hasContent } from '../../internal/styles.js';
import type { NebaColor } from '../../types.js';

export interface StreamingTextProps extends Omit<React.ComponentPropsWithoutRef<'div'>, 'color'> {
  /**
   * The text so far. A **string** is what this is for: what arrives while it
   * streams is cut into words, and each one fades in as it lands. Anything else
   * is rendered untouched, with the caret and the reserved height still around
   * it.
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
   * On. A word that arrives during a stream costs one element, which is the
   * price of the effect: a transition on the block as a whole would fade the
   * *whole answer* every time a token landed. Text that did not arrive that
   * way costs nothing — what the block was first drawn with while not
   * streaming, what the server rendered, what was already there when a stream
   * started, and what replaces it while nothing streams are drawn as plain
   * text. Turn it off for a very long answer.
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
 * Scripts written without a space between words. Japanese, Chinese and Thai
 * split on whitespace come out as one token per paragraph, so an answer in
 * them faded in once and then arrived with nothing moving at all.
 */
const unspaced =
  /[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Thai}\p{Script=Lao}\p{Script=Khmer}\p{Script=Myanmar}]/u;

/**
 * The tokens a string is drawn as: words, and the whitespace between them.
 *
 * The separators are kept, which is what makes the pieces add back up to the
 * original — an answer's line breaks are part of what it says, and the block is
 * `whitespace-pre-wrap` so they survive.
 *
 * A run in a script with no spaces is cut again by `Intl.Segmenter`, and only
 * that run: everything else stays the split it always was, so an English
 * answer costs no segmenter at all. A runtime without one keeps the run whole,
 * which is what every runtime did before.
 */
function tokenize(text: string): string[] {
  const pieces = text.split(/(\s+)/).filter((piece) => piece !== '');
  const cut = unspaced.test(text) ? segmenter(undefined, 'word') : null;

  if (!cut) {
    return pieces;
  }

  return pieces.flatMap((piece) =>
    unspaced.test(piece) ? [...cut.segment(piece)].map((one) => one.segment) : [piece]
  );
}

const space = /\s/;

/** How many words a block holds before it is closed and never drawn again. */
const BLOCK = 64;

/** The streamed text cut into closed blocks, kept from one token to the next. */
interface Blocks {
  /** Every closed block, end to end: the part of the stream already cut. */
  closed: string;
  texts: string[];
}

/**
 * Cuts the streamed text into blocks of `BLOCK` words, picking up where the
 * last cut left off.
 *
 * A block closes at the first word that would not fit in it, and only once
 * that word exists, so the word still growing at the end is always in the
 * tail. A stream only ever adds to its end, so the closed blocks are kept and
 * only the tail is cut again; a text that does not start with them was
 * replaced, and is cut from the beginning.
 */
function cutBlocks(previous: Blocks, streamed: string): Blocks & { tail: string } {
  let { closed, texts } = streamed.startsWith(previous.closed)
    ? previous
    : { closed: '', texts: [] };
  const rest = streamed.slice(closed.length);
  let words = 0;
  let start = 0;
  let offset = 0;

  for (const token of tokenize(rest)) {
    if (!space.test(token)) {
      if (words === BLOCK) {
        const text = rest.slice(start, offset);

        texts = [...texts, text];
        closed += text;
        start = offset;
        words = 0;
      }

      words += 1;
    }

    offset += token.length;
  }

  return { closed, texts, tail: rest.slice(start) };
}

/**
 * One block of streamed words, each in an element of its own to fade in.
 *
 * Memoised on its text, which is what keeps a long answer cheap: every block
 * but the last is closed and never changes, so a token landing re-renders the
 * last sixty-four words rather than the whole answer. `joined` is a block whose
 * first word began in the plain text in front of it, and that word is drawn
 * without a fade, as the rest of it was.
 */
const StreamBlock = React.memo(function StreamBlock({
  text,
  joined
}: {
  text: string;
  joined: boolean;
}) {
  return (
    <>
      {tokenize(text).map((token, index) =>
        // Whitespace carries no ink, so there is nothing to fade and no
        // element worth spending on it.
        space.test(token) || (joined && index === 0) ? (
          <React.Fragment key={index}>{token}</React.Fragment>
        ) : (
          <span key={index} className="neba-stream-word">
            {token}
          </span>
        )
      )}
    </>
  );
});

/**
 * How much of `text` is drawn plain, given what was drawn plain before and
 * what the last render showed.
 *
 * `null` is a block that has never streamed, and draws all of it plain. A
 * stream starting keeps what was already on screen plain and fades what comes
 * after it. Once streamed, a text that goes on from what was shown keeps the
 * same plain part — the last words of an answer often land in the render that
 * ends the stream, and they fade like the rest. A text that replaces it is
 * plain again if nothing is streaming, and fades from the last whole word the
 * two had in common if something is.
 */
function settle(
  plain: string | null,
  text: string,
  streaming: boolean,
  shown: string
): string | null {
  if (plain === null) {
    return streaming ? common(shown, text) : null;
  }

  if (text.startsWith(shown)) {
    return plain;
  }

  return streaming ? common(plain, text) : null;
}

/** The longest start two strings share, cut back to the end of a whole word. */
function common(one: string, two: string): string {
  if (two.startsWith(one)) {
    return one;
  }

  let at = 0;

  while (at < one.length && one[at] === two[at]) {
    at += 1;
  }

  // A word left half plain would fade its other half in; cutting at the space
  // also never splits a surrogate pair between a text node and a span.
  while (at > 0 && !space.test(two[at - 1])) {
    at -= 1;
  }

  return two.slice(0, at);
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
 * Words are keyed by position, so a word already on screen keeps its element
 * and never animates again; only a new one is a new element, and the last word
 * grows a character at a time inside the element it already has. They are held
 * in blocks of sixty-four, and a full block is never drawn again, so a token
 * landing costs the last block rather than the whole answer.
 *
 * Only a stream is cut into words. Text the block is drawn with while nothing
 * streams — a message loaded from history, a page rendered on the server — is
 * one run of plain text, because none of it is arriving: fifty such messages
 * drawn a word to an element were fifteen thousand elements, each with an
 * animation to start.
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
    const source = text ?? '';
    const hydrated = useHydrated();

    /*
     * The part of the text drawn plain, or `null` for all of it.
     *
     * Text the block mounts with is plain unless it mounts streaming in a tree
     * that was never server-rendered, where that text is arriving now and fades
     * as it always did. The server and the render that hydrates what it sent
     * both draw it plain, which is what keeps the two the same shape:
     * `Intl.Segmenter` does not cut Japanese or Thai the same way in every
     * engine, so words cut on the server and again in the browser could
     * disagree about where the elements go.
     */
    const [plain, setPlain] = React.useState<string | null>(() =>
      streaming ? (hydrated ? '' : source) : null
    );
    // What the last committed render drew, which is what a stream starting
    // leaves plain: the text that arrives with it has not been seen yet.
    const shown = React.useRef(source);
    // The closed blocks, kept between tokens. Read and written while
    // rendering, as a cache: `cutBlocks` checks the text still starts with
    // them, so a render that was thrown away leaves nothing wrong behind.
    const blocks = React.useRef<Blocks>({ closed: '', texts: [] });

    const settled = fade ? settle(plain, source, streaming, shown.current) : plain;

    if (settled !== plain) {
      setPlain(settled);
    }

    useLayoutEffectOnClient(() => {
      shown.current = source;
    });

    let content: React.ReactNode = children;

    if (text !== null && fade && settled !== null) {
      const streamed = text.slice(settled.length);
      const cut = cutBlocks(blocks.current, streamed);
      // The stream picked up in the middle of a word the plain text had
      // started. Not in a script without spaces, where two characters side by
      // side are as likely to be two words as one.
      const last = settled.at(-1);
      const next = streamed.at(0);
      const joined =
        last !== undefined &&
        next !== undefined &&
        !space.test(last) &&
        !space.test(next) &&
        !unspaced.test(last + next);

      blocks.current = cut;
      content = [
        settled,
        ...[...cut.texts, cut.tail].map((block, index) =>
          block === '' ? null : (
            <StreamBlock key={index} text={block} joined={joined && index === 0} />
          )
        )
      ];
    }

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
            {content}
            {hasContent(caret) ? caret : null}
          </>
        ),
        ...props
      }
    });
  }
);

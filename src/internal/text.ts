/**
 * Reading a React subtree as text, and cutting that text the way a reader would
 * cut it.
 *
 * Three components need both: `AnimateTyping` reveals a string one piece at a
 * time, `AnimateScramble` settles one, and `AnimateSplit` hands each piece its
 * own animation. Three copies of a grapheme segmenter is three chances to
 * disagree about where a character ends, which on `👩‍👩‍👧` is the difference
 * between one piece and seven.
 */

/**
 * The text inside a node, and nothing about its markup.
 *
 * Only strings and numbers contribute. An element among the children is skipped
 * rather than descended into, because there is no honest way to animate half of
 * a link: what would come out is the words with the anchor thrown away.
 */
export function textOf(node: unknown): string {
  if (typeof node === 'string' || typeof node === 'number') {
    return String(node);
  }

  if (Array.isArray(node)) {
    return node.map(textOf).join('');
  }

  return '';
}

/**
 * The text split into characters the way a reader would count them.
 *
 * Not `[...text]`, and not `text.split('')`. A code point is not a character:
 * `👩‍👩‍👧` is seven of them, `한` typed on a Korean keyboard can be three, and an
 * effect that advances by code points spends four frames assembling an emoji
 * out of parts that mean nothing on their own. `Intl.Segmenter` knows where the
 * boundaries actually are; the spread is the fallback for a runtime that does
 * not have it.
 */
export function graphemesOf(text: string, locale?: string): string[] {
  if (typeof Intl !== 'undefined' && 'Segmenter' in Intl) {
    const segmenter = new Intl.Segmenter(locale, { granularity: 'grapheme' });

    return [...segmenter.segment(text)].map((segment) => segment.segment);
  }

  return [...text];
}

/**
 * The text split into words, with each word keeping the space that followed it.
 *
 * The space travels with the word rather than standing between the pieces
 * because a piece is an `inline-block`: a space of its own would be a box that
 * a line break could land inside, and the line would break in the middle of the
 * gap rather than at it.
 *
 * `Intl.Segmenter` again where it exists — a word boundary is not a space in
 * Japanese, Thai or Chinese, and splitting those on whitespace produces one
 * piece holding the whole sentence.
 */
export function wordsOf(text: string, locale?: string): string[] {
  if (typeof Intl !== 'undefined' && 'Segmenter' in Intl) {
    const segmenter = new Intl.Segmenter(locale, { granularity: 'word' });
    const pieces: string[] = [];

    for (const { segment, isWordLike } of segmenter.segment(text)) {
      if (isWordLike || pieces.length === 0) {
        pieces.push(segment);
      } else {
        // Punctuation and whitespace join the word in front of them, so a piece
        // is never a lone comma arriving on its own half a second late.
        pieces[pieces.length - 1] += segment;
      }
    }

    return pieces.filter((piece) => piece.length > 0);
  }

  return text.split(/(\s+)/).reduce<string[]>((pieces, part, index) => {
    if (index % 2 === 0) {
      if (part) pieces.push(part);
    } else if (pieces.length > 0) {
      pieces[pieces.length - 1] += part;
    }

    return pieces;
  }, []);
}

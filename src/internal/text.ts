/**
 * Reading a React subtree as text, and cutting that text the way a reader would
 * cut it.
 *
 * Three components need both: `AnimateTyping` reveals a string one piece at a
 * time, `AnimateScramble` settles one, and `AnimateSplit` hands each piece its
 * own animation. Three copies of a grapheme segmenter is three chances to
 * disagree about where a character ends, which on `👩‍👩‍👧` is the difference
 * between one piece and seven.
 *
 * The segmenter itself comes from `internal/format.ts`, memoised there with the
 * two `Intl` formatters: building one is the expensive half of using one, and
 * three effects on a page were building one each per call.
 *
 * Beside each cut is a portable one, which gives the same answer on every
 * engine. `Intl.Segmenter` does not: Firefox cuts Japanese and Thai into
 * different words from Chrome and Node, and a Firefox older than 125 has no
 * segmenter at all. That matters wherever the pieces become elements, because a
 * server and a browser that disagree about how many there are have rendered two
 * different trees, and React throws the server's away. So a render that has to
 * match the server's uses the portable cut, and the segmenter takes over once
 * the page has hydrated. The portable cut is also what a runtime without a
 * segmenter falls back to.
 */
import { segmenter } from './format.js';

/**
 * The text inside a node, and nothing about its markup.
 *
 * Strings and numbers are the text, and an element contributes the text inside
 * it: `Hello <b>world</b>` reads `Hello world`. The markup itself is dropped,
 * because there is no honest way to animate half of a link.
 */
export function textOf(node: unknown): string {
  if (typeof node === 'string' || typeof node === 'number') {
    return String(node);
  }

  if (Array.isArray(node)) {
    return node.map(textOf).join('');
  }

  if (node !== null && typeof node === 'object' && 'props' in node) {
    return textOf((node as { props: { children?: unknown } }).props.children);
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
 * boundaries actually are; `portableGraphemesOf` is the fallback for a runtime
 * that does not have it.
 */
export function graphemesOf(text: string, locale?: string): string[] {
  const cut = segmenter(locale, 'grapheme');

  if (cut) {
    return [...cut.segment(text)].map((segment) => segment.segment);
  }

  return portableGraphemesOf(text);
}

/**
 * One character as a regular expression finds it, which is close to what
 * `Intl.Segmenter` finds and the same on every engine.
 *
 * A base followed by everything that cannot stand on its own: combining marks
 * and spacing vowels, emoji modifiers and variation selectors, a zero-width
 * joiner and the pictograph it joins, and the consonant after a virama in the
 * scripts that stack one onto the next. Two regional indicators are one flag,
 * a run of Hangul jamo is one syllable, and `\r\n` is one line break.
 *
 * It is not the whole of Unicode's algorithm, and it does not need to be: where
 * it is wrong it is wrong about a rare cluster, and what it is for is agreeing
 * with itself on a server and in a browser.
 */
const CLUSTER =
  /\r\n|\p{RI}\p{RI}|[\u1100-\u115F\uA960-\uA97C]*(?:[\uAC00-\uD7A3]|[\u1160-\u11A7\uD7B0-\uD7C6])[\u1160-\u11A7\uD7B0-\uD7C6]*[\u11A8-\u11FF\uD7CB-\uD7FB]*|[\u1100-\u115F\uA960-\uA97C]+|[\s\S](?:[\u094D\u09CD\u0ACD\u0B4D\u0C4D\u0D4D\u17D2]\p{L}|[\p{Gr_Ext}\p{EMod}\p{Mc}\u0E33\u0EB3]|\u200D\p{ExtPict}|\u200D)*/gu;

/** The text split into characters, the same way on every engine. */
export function portableGraphemesOf(text: string): string[] {
  return text.match(CLUSTER) ?? [];
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
 * piece holding the whole sentence. `portableWordsOf` where it does not.
 */
export function wordsOf(text: string, locale?: string): string[] {
  const cut = segmenter(locale, 'word');

  if (cut) {
    const pieces: string[] = [];

    for (const { segment, isWordLike } of cut.segment(text)) {
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

  return portableWordsOf(text);
}

const ALONE =
  /^(?=\p{L})[\p{scx=Han}\p{scx=Hiragana}\p{scx=Katakana}\p{scx=Thai}\p{scx=Lao}\p{scx=Khmer}\p{scx=Myanmar}]/u;

/**
 * Whether a character belongs to a script written without spaces, where a run
 * of letters is not one word and a line may break inside it.
 *
 * `portableWordsOf` makes each one a piece of its own: a regular expression
 * cannot tell where a Japanese or a Thai word ends, and one character at a time
 * is never coarser than the segmenter's answer.
 */
export function standsAlone(grapheme: string): boolean {
  return ALONE.test(grapheme);
}

const LETTER = /^[\p{Alphabetic}\p{Pc}]/u;
const DIGIT = /^\p{Nd}/u;
// What keeps `don't` one word and `1,234.5` one number: only the joins every
// engine makes. Chrome cuts `e.g` and `example.com` at the full stop where
// Firefox, Safari and Node do not, so a full stop between letters is a cut
// here — the finer of the two answers.
const BETWEEN_LETTERS = /^['\u2019]$/u;
const BETWEEN_DIGITS = /^[.',;\u2019]$/u;

type ClusterKind = 'alone' | 'letter' | 'digit' | 'other';

function kindOf(cluster: string): ClusterKind {
  if (standsAlone(cluster)) return 'alone';
  if (LETTER.test(cluster)) return 'letter';
  if (DIGIT.test(cluster)) return 'digit';

  return 'other';
}

/**
 * The text split into words, the same way on every engine.
 *
 * The same shape as `wordsOf`: a word keeps the punctuation and the space that
 * follow it, and what comes before the first word is a piece of its own. Where
 * it disagrees with `Intl.Segmenter` it cuts finer, never coarser — a Japanese
 * sentence is a piece per character rather than a piece per word — so a line
 * that is cut again once the page has hydrated only ever has pieces merged, and
 * nothing that was already on screen arrives a second time.
 */
export function portableWordsOf(text: string): string[] {
  const clusters = portableGraphemesOf(text);
  const kinds = clusters.map(kindOf);
  const pieces: string[] = [];
  let inWord = false;

  clusters.forEach((cluster, index) => {
    const kind = kinds[index];
    const joins =
      kind === 'other' &&
      kinds[index - 1] === kinds[index + 1] &&
      ((kinds[index - 1] === 'letter' && BETWEEN_LETTERS.test(cluster)) ||
        (kinds[index - 1] === 'digit' && BETWEEN_DIGITS.test(cluster)));
    const inside = kind === 'letter' || kind === 'digit' || joins;

    if (pieces.length === 0 || kind === 'alone' || (inside && !inWord)) {
      pieces.push(cluster);
    } else {
      pieces[pieces.length - 1] += cluster;
    }

    inWord = inside;
  });

  return pieces;
}

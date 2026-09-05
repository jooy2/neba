/**
 * Reading a subtree as text, and cutting that text the way a reader counts it.
 *
 * The cases worth checking here are the ones a rendered component gives a vague
 * answer to. A grapheme is not a code point: `👩‍👩‍👧` is seven of them joined by
 * zero-width joiners, a flag is two, and a Korean syllable typed on a Korean
 * keyboard arrives as up to three. An effect that advances by code point spends
 * four frames assembling an emoji out of parts that mean nothing on their own,
 * and the only way to see that is to count the pieces directly.
 *
 * `wordsOf` has the same shape of question one level up: a word boundary is not
 * a space in Japanese or Thai, and the piece a punctuation mark belongs to is
 * the word in front of it rather than one of its own.
 */
import { describe, expect, it } from 'vitest';
import { graphemesOf, textOf, wordsOf } from '../../src/internal/text.js';

describe('textOf', () => {
  it('reads a string and a number', () => {
    expect(textOf('Seoul')).toBe('Seoul');
    expect(textOf(42)).toBe('42');
  });

  it('joins an array without anything between the pieces', () => {
    expect(textOf(['Se', 'oul'])).toBe('Seoul');
    expect(textOf(['a', 1, 'b'])).toBe('a1b');
  });

  /*
   * An element is skipped rather than descended into. There is no honest way to
   * animate half of a link — what would come out is the words with the anchor
   * thrown away — so the component renders its children as they are instead.
   */
  it('contributes nothing for anything that is not a string or a number', () => {
    expect(textOf(null)).toBe('');
    expect(textOf(undefined)).toBe('');
    expect(textOf(false)).toBe('');
    expect(textOf({ type: 'a', props: {} })).toBe('');
  });
});

describe('graphemesOf', () => {
  it('counts plain text one character at a time', () => {
    expect(graphemesOf('Seoul')).toEqual(['S', 'e', 'o', 'u', 'l']);
  });

  // Seven code points and one character. A spread would produce seven pieces
  // and four of them are joiners that draw nothing.
  it('keeps a joined emoji together', () => {
    expect(graphemesOf('👩‍👩‍👧')).toEqual(['👩‍👩‍👧']);
  });

  it('keeps a flag together', () => {
    expect(graphemesOf('🇰🇷')).toEqual(['🇰🇷']);
  });

  // The same syllable, composed and decomposed. Both are one character to a
  // reader, and the decomposed form is what a Korean keyboard actually sends.
  it('keeps a decomposed Hangul syllable together', () => {
    expect(graphemesOf('한')).toEqual(['한']);
    expect(graphemesOf('한')).toHaveLength(1);
  });

  it('keeps a letter and its combining accent together', () => {
    expect(graphemesOf('é')).toEqual(['é']);
  });

  it('has nothing to cut in an empty string', () => {
    expect(graphemesOf('')).toEqual([]);
  });
});

describe('wordsOf', () => {
  /*
   * The space travels with the word in front of it rather than standing between
   * the pieces: a piece is an `inline-block`, and a space of its own would be a
   * box a line break could land inside — the line would then break in the middle
   * of the gap rather than at it.
   */
  it('gives each word the space that followed it', () => {
    expect(wordsOf('one two three')).toEqual(['one ', 'two ', 'three']);
  });

  it('joins a punctuation mark to the word in front of it', () => {
    expect(wordsOf('one, two.')).toEqual(['one, ', 'two.']);
  });

  it('puts the pieces back together as the original string', () => {
    const text = 'A sentence, with punctuation.';

    expect(wordsOf(text).join('')).toBe(text);
  });

  // A word boundary is not a space here, and splitting on whitespace would
  // produce one piece holding the whole sentence.
  it('cuts a language that does not write spaces', () => {
    expect(wordsOf('東京都に住んでいます', 'ja').length).toBeGreaterThan(1);
  });

  it('has nothing to cut in an empty string', () => {
    expect(wordsOf('')).toEqual([]);
  });
});

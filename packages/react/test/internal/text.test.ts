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
import { createElement } from 'react';
import { describe, expect, it } from 'vitest';
import {
  graphemesOf,
  portableGraphemesOf,
  portableWordsOf,
  textOf,
  wordsOf
} from '../../src/internal/text.js';

describe('textOf', () => {
  it('reads a string and a number', () => {
    expect(textOf('Seoul')).toBe('Seoul');
    expect(textOf(42)).toBe('42');
  });

  it('joins an array without anything between the pieces', () => {
    expect(textOf(['Se', 'oul'])).toBe('Seoul');
    expect(textOf(['a', 1, 'b'])).toBe('a1b');
  });

  // The docs said an element's text counted, and it was dropped, so
  // `Hello <b>world</b>` was typed as `Hello `.
  it('reads the text inside an element and drops its markup', () => {
    expect(textOf(['Hello ', createElement('b', null, 'world')])).toBe('Hello world');
    expect(
      textOf(createElement('a', { href: '#' }, 'Read ', createElement('em', null, 'more')))
    ).toBe('Read more');
  });

  it('contributes nothing for a node with no text in it', () => {
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

/*
 * The portable cuts are what a server render and the render that hydrates it
 * use, because `Intl.Segmenter` gives different answers on different engines.
 * Two things are worth holding: that they keep a character together where the
 * segmenter does, and that a portable word is never coarser than a segmented
 * one, so cutting a line again after hydration only ever merges pieces.
 */
describe('portableGraphemesOf', () => {
  it('keeps the clusters the segmenter keeps together', () => {
    for (const text of ['👩‍👩‍👧', '🇰🇷🇯🇵', '한', '한', 'é', '👍🏽', '1️⃣', 'กำลัง']) {
      expect(portableGraphemesOf(text)).toEqual(graphemesOf(text));
    }
  });

  // A virama joins two consonants into one character in Devanagari, which is
  // the case a regular expression is most likely to cut in two.
  it('keeps a stacked consonant with the one before it', () => {
    expect(portableGraphemesOf('क्ष')).toEqual(['क्ष']);
  });

  it('puts the pieces back together as the original string', () => {
    const text = 'Ünïcödé 👩‍👩‍👧 한국어 नमस्ते\r\n';

    expect(portableGraphemesOf(text).join('')).toBe(text);
  });

  it('has nothing to cut in an empty string', () => {
    expect(portableGraphemesOf('')).toEqual([]);
  });
});

describe('portableWordsOf', () => {
  it('cuts a line of spaced words the way the segmenter does', () => {
    for (const text of [
      'A line arriving a word at a time',
      'Hello, world!',
      "don't stop",
      'state-of-the-art',
      '"Quoted" text',
      '1,234.5 items',
      'Привет, мир',
      '안녕하세요 세계'
    ]) {
      expect(portableWordsOf(text)).toEqual(wordsOf(text));
    }
  });

  /*
   * Every place the segmenter cuts, the portable cut cuts too. A Japanese or a
   * Thai sentence is a piece per character rather than a piece per word, so a
   * line cut again once the page has hydrated has pieces merged and none added.
   */
  it('is never coarser than the segmenter', () => {
    const boundaries = (pieces: string[]) => {
      let offset = 0;

      return pieces.map((piece) => {
        const at = offset;

        offset += piece.length;

        return at;
      });
    };

    for (const [text, locale] of [
      // Chrome cuts these at the full stop and the other engines do not.
      ['e.g. example.com', 'en'],
      ['東京都に住んでいます。', 'ja'],
      ['我爱北京天安门', 'zh'],
      ['สวัสดีครับ ยินดีต้อนรับ', 'th'],
      ['AI技術の進歩', 'ja'],
      ['中文 English 混合', 'zh']
    ]) {
      const portable = boundaries(portableWordsOf(text));

      expect(portable).toEqual(expect.arrayContaining(boundaries(wordsOf(text, locale))));
    }
  });

  it('puts the pieces back together as the original string', () => {
    const text = '  「こんにちは」と言った — 50% off! ';

    expect(portableWordsOf(text).join('')).toBe(text);
  });

  it('has nothing to cut in an empty string', () => {
    expect(portableWordsOf('')).toEqual([]);
  });
});

describe('without Intl.Segmenter', () => {
  // A Firefox before 125. The fallback is the portable cut, so on that runtime
  // the line hydrated from the server is the line it keeps.
  it('falls back to the portable cuts', () => {
    const scope = Intl as { Segmenter?: unknown };
    const original = scope.Segmenter;

    delete scope.Segmenter;

    try {
      expect(graphemesOf('👩‍👩‍👧é')).toEqual(['👩‍👩‍👧', 'é']);
      expect(wordsOf('東京 and/or more')).toEqual(portableWordsOf('東京 and/or more'));
      expect(wordsOf('東京 and/or more')).toEqual(['東', '京 ', 'and/', 'or ', 'more']);
    } finally {
      scope.Segmenter = original;
    }
  });
});

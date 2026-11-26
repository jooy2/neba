/**
 * Which samples a `WidthSizer` lays out.
 *
 * The sizer pins a control to the width of the widest thing it could say, and
 * only the widest sample does any pinning. `widestSamples` drops the samples
 * whose text is too short to be that one. What can go wrong is dropping the one that was —
 * which nothing in a rendered component would show, since no stylesheet is
 * loaded there — so the ranking is checked here, where a length is a number.
 */
import { createElement, Fragment } from 'react';
import { describe, expect, it } from 'vitest';
import { widestSamples } from '../../src/internal/sizer.js';

describe('widestSamples', () => {
  it('keeps the longest string, and drops one far shorter than it', () => {
    expect(widestSamples(['Chad', 'United Kingdom of Great Britain', 'Peru'])).toEqual([
      'United Kingdom of Great Britain'
    ]);
  });

  // A length is not a width: capitals are wider than lower case, so a string
  // somewhat shorter than the longest can still be the widest.
  it('keeps a string close enough in length to be the widest', () => {
    expect(widestSamples(['WASHINGTON DC', 'washington, d.c. area'])).toEqual([
      'WASHINGTON DC',
      'washington, d.c. area'
    ]);
  });

  // A character from these scripts is drawn about twice as wide as a Latin one.
  it('counts a character from a wide script as two', () => {
    expect(widestSamples(['서울특별시', 'Washington DC'])).toEqual(['서울특별시', 'Washington DC']);
    expect(widestSamples(['서울', 'Washington DC Metropolitan Area'])).toEqual([
      'Washington DC Metropolitan Area'
    ]);
  });

  // A node used to be kept whatever it said, so a list of labels that each
  // carried a flag laid out, and fetched, every flag on the page.
  it('ranks a node by the text among its children, however deep', () => {
    const flag = createElement('img', { alt: '' });
    const chad = createElement('span', null, flag, 'Chad');
    const britain = createElement(
      'span',
      null,
      flag,
      createElement(Fragment, null, 'United Kingdom ', createElement('b', null, 'of Great Britain'))
    );

    expect(widestSamples([chad, britain, 'Peru'])).toEqual([britain]);
  });

  it('ranks a node against the strings beside it', () => {
    const korea = createElement('em', null, 'Korea');
    const bolivia = createElement('em', null, 'Bolivia (Plurinational State of)');

    expect(widestSamples([korea, 'United Kingdom of Great Britain', bolivia])).toEqual([
      'United Kingdom of Great Britain',
      bolivia
    ]);
  });

  // Nothing in it to read: a picture, or a component drawing words of its own.
  it('keeps a node with no text, whatever the strings beside it', () => {
    const picture = createElement('img', { alt: '' });
    const spaced = createElement('span', null, ' ', createElement('img', { alt: '' }), ' ');
    const unknown = { type: 'em' };

    expect(
      widestSamples([picture, spaced, unknown as never, 'United Kingdom of Great Britain'])
    ).toEqual([picture, spaced, unknown, 'United Kingdom of Great Britain']);
  });

  it('ranks a number by its digits', () => {
    expect(widestSamples([42, 'United Kingdom of Great Britain', 1234567890123])).toEqual([
      'United Kingdom of Great Britain',
      1234567890123
    ]);
  });

  it('keeps the order it was given', () => {
    expect(widestSamples(['Saint Lucia', 'Saint Kitts and Nevis', 'Saint Martin'])).toEqual([
      'Saint Lucia',
      'Saint Kitts and Nevis',
      'Saint Martin'
    ]);
  });

  it('answers an empty list with an empty one', () => {
    expect(widestSamples([])).toEqual([]);
  });
});

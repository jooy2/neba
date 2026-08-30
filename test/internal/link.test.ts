/**
 * The `rel` a link gets when it opens somewhere other than this tab.
 *
 * Three components take a `target` — TextLink, a Menu row, a NavigationMenu
 * link — and all three go through this, so it is asserted once here rather than
 * three times through a rendered anchor. The part worth pinning is that it is a
 * *merge*: the usual reason to write a `rel` by hand is `nofollow`, and spelled
 * as a plain default the two tokens would silently disappear with it.
 */
import { describe, expect, it } from 'vitest';
import { safeRel } from '../../src/internal/link.js';

const tokens = (rel: string | undefined) => (rel ?? '').split(' ').filter(Boolean).sort();

describe('safeRel', () => {
  it('adds both tokens to a link that opens in a new tab', () => {
    // Browsers imply `noopener` for `target="_blank"`; none of them implies
    // `noreferrer`, which is the one that stops the Referer header going out.
    expect(tokens(safeRel('_blank', undefined))).toEqual(['noopener', 'noreferrer']);
  });

  it('adds them to a named target too', () => {
    // Neither is implied for one of those.
    expect(tokens(safeRel('preview', undefined))).toEqual(['noopener', 'noreferrer']);
  });

  it('keeps whatever the caller wrote', () => {
    expect(tokens(safeRel('_blank', 'nofollow'))).toEqual(['nofollow', 'noopener', 'noreferrer']);
    expect(tokens(safeRel('_blank', 'sponsored nofollow'))).toEqual([
      'nofollow',
      'noopener',
      'noreferrer',
      'sponsored'
    ]);
  });

  it('does not write a token twice', () => {
    expect(tokens(safeRel('_blank', 'noopener'))).toEqual(['noopener', 'noreferrer']);
  });

  it('leaves a rel alone on a link that stays in this tab', () => {
    expect(safeRel(undefined, 'nofollow')).toBe('nofollow');
    expect(safeRel('_self', 'nofollow')).toBe('nofollow');
    expect(safeRel(undefined, undefined)).toBeUndefined();
  });

  it('leaves the frame targets alone, which open no browsing context of their own', () => {
    expect(safeRel('_parent', undefined)).toBeUndefined();
    expect(safeRel('_top', undefined)).toBeUndefined();
  });

  it('tolerates a rel written with odd spacing', () => {
    expect(tokens(safeRel('_blank', '  nofollow   sponsored '))).toEqual([
      'nofollow',
      'noopener',
      'noreferrer',
      'sponsored'
    ]);
  });
});

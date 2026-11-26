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
import { safeHref, safeRel } from '../../src/internal/link.js';

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

/**
 * The `href` a component writes.
 *
 * React 18, inside the peer range, writes a `javascript:` URL as it is, so the
 * library refuses one itself rather than relying on the React a consumer runs.
 */
describe('safeHref', () => {
  it('keeps the four schemes a link is for', () => {
    for (const href of [
      'https://example.com',
      'http://example.com',
      'mailto:hi@example.com',
      'tel:+1234'
    ]) {
      expect(safeHref(href)).toBe(href);
    }
  });

  it('keeps an address with no scheme', () => {
    for (const href of ['/docs', 'docs/intro', '#section', '//cdn.example.com/x', '?page=2', '']) {
      expect(safeHref(href)).toBe(href);
    }
  });

  it('drops a script or data URL however it is spelled', () => {
    const tab = String.fromCharCode(9);
    const control = String.fromCharCode(1);

    for (const href of [
      'javascript:alert(1)',
      'JavaScript:alert(1)',
      '  javascript:alert(1)',
      `java${tab}script:alert(1)`,
      `${control}javascript:alert(1)`,
      'data:text/html,<script>alert(1)</script>',
      'vbscript:msgbox(1)'
    ]) {
      expect(safeHref(href)).toBeUndefined();
    }
  });

  it('passes nothing through as nothing', () => {
    expect(safeHref(undefined)).toBeUndefined();
  });
});

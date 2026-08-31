/**
 * The escaping, which is the whole job and fails silently: a comma inside a
 * cell shifts every column after it by one, and nobody notices until a
 * spreadsheet somewhere is off by a column.
 */
import { describe, expect, it } from 'vitest';
import { csvField, toCsv } from '../../src/internal/csv.js';

describe('csvField', () => {
  it('leaves a plain field alone', () => {
    expect(csvField('Seoul')).toBe('Seoul');
    expect(csvField(42)).toBe('42');
  });

  it('quotes a field holding the separator, a quote or a line break', () => {
    expect(csvField('Ada, the first')).toBe('"Ada, the first"');
    expect(csvField('say "hello"')).toBe('"say ""hello"""');
    expect(csvField('two\nlines')).toBe('"two\nlines"');
  });

  it('follows the separator it was given', () => {
    expect(csvField('a;b', ';')).toBe('"a;b"');
    expect(csvField('a;b')).toBe('a;b');
  });

  it('writes nothing for nothing', () => {
    // `String(null)` is the word "null", which is what a spreadsheet cell would
    // then hold.
    expect(csvField(null)).toBe('');
    expect(csvField(undefined)).toBe('');
    expect(csvField('')).toBe('');
  });

  it('writes a date as an instant rather than as a locale', () => {
    expect(csvField(new Date(Date.UTC(2026, 6, 27)))).toBe('2026-07-27T00:00:00.000Z');
  });
});

describe('toCsv', () => {
  it('joins fields and rows the way RFC 4180 says', () => {
    const csv = toCsv(
      [
        ['Name', 'City'],
        ['Ada', 'Seoul']
      ],
      { bom: false }
    );

    expect(csv).toBe('Name,City\r\nAda,Seoul');
  });

  it('leads with a byte-order mark by default', () => {
    // Excel reads a UTF-8 CSV without one as the local code page, so every
    // non-ASCII name in the file arrives as mojibake.
    expect(toCsv([['이름']]).charCodeAt(0)).toBe(0xfeff);
    expect(toCsv([['이름']], { bom: false }).charCodeAt(0)).not.toBe(0xfeff);
  });

  it('takes a separator of its own', () => {
    expect(toCsv([['a', 'b']], { separator: ';', bom: false })).toBe('a;b');
  });
});

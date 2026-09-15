/**
 * The first letters of a name.
 *
 * One function, shared because an Avatar with no photograph and an AppLogo with
 * no artwork both have to answer the same question — and a library with two of
 * these spells the same person's initials two ways on one page.
 */
import { describe, expect, it, vi } from 'vitest';
import { initialsOf } from '../../src/internal/initials.js';

describe('initialsOf', () => {
  it('takes the first letter of the first and last words', () => {
    expect(initialsOf('Jane Doe')).toBe('JD');
    expect(initialsOf('Ada Byron King')).toBe('AK');
  });

  it('takes one letter from one word', () => {
    expect(initialsOf('Prince')).toBe('P');
  });

  it('upper-cases the letters', () => {
    expect(initialsOf('jane doe')).toBe('JD');
  });

  // The runtime's language cannot be changed from inside a test, so a Turkish
  // one is stood in for: its locale-aware upper case turns `i` into `İ`. A
  // server rendering in English would have drawn `II` for the same name.
  it('upper-cases the same way whatever language the runtime is in', () => {
    const turkish = vi.spyOn(String.prototype, 'toLocaleUpperCase').mockImplementation(function (
      this: string
    ) {
      return this.replace(/i/g, 'İ').toUpperCase();
    });

    try {
      expect(initialsOf('ivan ilić')).toBe('II');
    } finally {
      turkish.mockRestore();
    }
  });

  it('does not care about the spacing it was given', () => {
    expect(initialsOf('  Jane   Doe  ')).toBe('JD');
    expect(initialsOf('Jane\tDoe')).toBe('JD');
  });

  it('answers nothing for a name that is not one', () => {
    expect(initialsOf('')).toBe('');
    expect(initialsOf('   ')).toBe('');
  });

  it('takes a whole character, not half of a surrogate pair', () => {
    // An emoji and most of CJK beyond the basic plane are two code units.
    // Slicing a string by index cuts one in half and draws a replacement box.
    expect(initialsOf('🌏 Earth')).toBe('🌏E');
    expect([...initialsOf('𝒥ane Doe')][0]).toBe('𝒥');
  });

  // Sliced by code point, a joined emoji lost its second half and a flag its
  // second letter.
  it('takes a whole emoji, joined or a flag', () => {
    expect(initialsOf('👩‍💻 Dev')).toBe('👩‍💻D');
    expect(initialsOf('🇰🇷 Team')).toBe('🇰🇷T');
  });

  it('reads a name written in a script with no case', () => {
    expect(initialsOf('이 주영')).toBe('이주');
    expect(initialsOf('山田 太郎')).toBe('山太');
  });

  it('keeps an accented letter whole rather than splitting off its mark', () => {
    // `NFC` first: a name typed as `e` plus a combining acute is one letter, and
    // taking the first code point of the decomposed form would take the `e`.
    expect(initialsOf('Élodie Dupont')).toBe('ÉD');
  });
});

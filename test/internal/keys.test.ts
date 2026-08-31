/**
 * The key vocabulary, read rather than drawn.
 *
 * These are the cases that made the file exist: `Shortcut` understood `Cmd`,
 * `Command`, `Meta` and `Esc` and the binding side did not, so a correct key
 * cap sat on the screen over a combination that could never fire. Every alias
 * the display table accepts has to match here too, or the label is a claim
 * nobody checked.
 *
 * The platform is whatever this browser is running on, so `Mod` is asserted
 * against `readOS()` rather than against a guess.
 */
import { describe, expect, it } from 'vitest';
import {
  canonicalKey,
  matchesShortcut,
  readOS,
  tokenize,
  type KeyPress
} from '../../src/internal/keys.js';

const mac = readOS() === 'mac';

/** A keystroke, with nothing held unless it is named. */
function press(key: string, held: Partial<KeyPress> = {}): KeyPress {
  return {
    key,
    code: key.length === 1 && key >= 'a' && key <= 'z' ? `Key${key.toUpperCase()}` : key,
    ctrlKey: false,
    metaKey: false,
    altKey: false,
    shiftKey: false,
    ...held
  };
}

/** Whatever `Mod` resolves to here. */
const mod = mac ? { metaKey: true } : { ctrlKey: true };

describe('tokenize', () => {
  it('splits on + and drops what a trailing one leaves behind', () => {
    expect(tokenize('Mod+Shift+P')).toEqual(['Mod', 'Shift', 'P']);
    expect(tokenize('Ctrl++')).toEqual(['Ctrl']);
    expect(tokenize(['Ctrl', '+'])).toEqual(['Ctrl', '+']);
  });

  it('trims around the separator', () => {
    expect(tokenize(' Mod + Enter ')).toEqual(['Mod', 'Enter']);
  });
});

describe('canonicalKey', () => {
  it('folds the spellings one key already has', () => {
    expect(['Cmd', 'Command', 'Win', 'Super'].map(canonicalKey)).toEqual([
      'meta',
      'meta',
      'meta',
      'meta'
    ]);
    expect(['Esc', 'Escape'].map(canonicalKey)).toEqual(['escape', 'escape']);
    expect(['Return', 'Enter'].map(canonicalKey)).toEqual(['enter', 'enter']);
    expect(['Up', 'ArrowUp', 'arrow up'].map(canonicalKey)).toEqual([
      'arrowup',
      'arrowup',
      'arrowup'
    ]);
  });

  it('names the space bar before the punctuation is stripped', () => {
    // `' '` is the one `KeyboardEvent.key` that would otherwise fold to nothing.
    expect(canonicalKey(' ')).toBe('space');
    expect(canonicalKey('Space')).toBe('space');
    expect(canonicalKey('Spacebar')).toBe('space');
  });

  it('leaves a key it does not know alone, lowercased', () => {
    expect(canonicalKey('F5')).toBe('f5');
    expect(canonicalKey('PageDown')).toBe('pagedown');
  });
});

describe('matchesShortcut', () => {
  it('matches the plain key', () => {
    expect(matchesShortcut(press('Enter'), 'Enter')).toBe(true);
    expect(matchesShortcut(press('Enter'), 'Return')).toBe(true);
    expect(matchesShortcut(press('Escape'), 'Esc')).toBe(true);
    expect(matchesShortcut(press('a'), 'A')).toBe(true);
  });

  it('resolves Mod to this platform', () => {
    expect(matchesShortcut(press('k', mod), 'Mod+K')).toBe(true);
    expect(matchesShortcut(press('k', mac ? { ctrlKey: true } : { metaKey: true }), 'Mod+K')).toBe(
      false
    );
  });

  it('binds every spelling Shortcut draws', () => {
    // The bug this file was written for: all four of these render a correct key
    // cap, and only the first of them used to fire.
    const held = mac ? { metaKey: true } : { ctrlKey: true };
    const spelling = mac ? ['Cmd+K', 'Command+K', 'Meta+K'] : ['Ctrl+K', 'Control+K'];

    for (const shortcut of spelling) {
      expect([shortcut, matchesShortcut(press('k', held), shortcut)]).toEqual([shortcut, true]);
    }
  });

  it('matches the modifiers exactly, so Enter and Mod+Enter never both fire', () => {
    expect(matchesShortcut(press('Enter', mod), 'Enter')).toBe(false);
    expect(matchesShortcut(press('Enter'), 'Mod+Enter')).toBe(false);
    expect(matchesShortcut(press('Enter', mod), 'Mod+Enter')).toBe(true);
  });

  it('counts Shift as a modifier that has to be named', () => {
    expect(matchesShortcut(press('P', { ...mod, shiftKey: true }), 'Mod+Shift+P')).toBe(true);
    expect(matchesShortcut(press('P', { ...mod, shiftKey: true }), 'Mod+P')).toBe(false);
  });

  it('falls back to the physical key when a modifier changed what was typed', () => {
    // Alt+K on a Mac reports a `key` of `˚`. Without the `code` fallback every
    // Alt combination in the library would quietly stop working there.
    expect(matchesShortcut({ ...press('˚'), code: 'KeyK', altKey: true }, 'Alt+K')).toBe(true);
    expect(matchesShortcut({ ...press('˚'), code: 'KeyJ', altKey: true }, 'Alt+K')).toBe(false);
  });

  it('never matches a combination it cannot read', () => {
    expect(matchesShortcut(press('k', mod), 'Hyper+K')).toBe(false);
    expect(matchesShortcut(press('k'), '')).toBe(false);
  });
});

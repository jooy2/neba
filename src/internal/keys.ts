/**
 * A key combination, read rather than drawn.
 *
 * This is in `internal/` for `button-group.ts`'s reason with a sharper edge on
 * it. `Shortcut` *draws* `Mod+K` and `CommandPalette` *binds* it, and the two
 * were written separately — so the drawing side understood `Cmd`, `Command`,
 * `Meta` and `Esc` and the binding side did not. `<Shortcut keys="Cmd+K" />`
 * put a correct key cap on the screen over a shortcut that could never fire,
 * which is the worst shape this bug can take: the label is the only evidence a
 * reader has that the key exists at all.
 *
 * So the split is by job rather than by component. Everything that decides
 * *which key a token means* is here and both sides read it. What a key *looks
 * like* — `⌘`, `⇧`, the arrow glyphs — stays in `Shortcut`, because a TextField
 * that binds `Mod+Enter` has no business carrying a table of Mac glyphs.
 *
 * Nothing here allocates at import time beyond two small object literals, and
 * the platform is worked out once for the page.
 */

import type * as React from 'react';
import type { NebaShortcuts } from '../types.js';

/** The three platforms a combination can be named for, once `auto` is resolved. */
export type ResolvedOS = 'mac' | 'windows' | 'linux';

/**
 * The tokens that name one key by more than one word.
 *
 * The aliases are the point rather than generosity: `Cmd`, `Command` and `Meta`
 * are three names one key already has, and a library that accepted only one of
 * them is a library every caller has to look up. `mod` is the entry the rest
 * exist for — the only token whose *meaning* changes with the platform rather
 * than its spelling, which is Command on a Mac and Control everywhere else.
 */
const keyAliases: Record<string, string> = {
  cmdorctrl: 'mod',
  commandorcontrol: 'mod',
  cmd: 'meta',
  command: 'meta',
  super: 'meta',
  win: 'meta',
  windows: 'meta',
  control: 'ctrl',
  option: 'alt',
  opt: 'alt',
  return: 'enter',
  esc: 'escape',
  del: 'delete',
  caps: 'capslock',
  spacebar: 'space',
  up: 'arrowup',
  down: 'arrowdown',
  left: 'arrowleft',
  right: 'arrowright'
};

/**
 * Splits the string form. Empty segments are what `'Ctrl++'` leaves behind, and
 * dropping them is why the array form exists for that case.
 */
export function tokenize(keys: string | string[]): string[] {
  if (Array.isArray(keys)) {
    return keys.map((key) => key.trim()).filter(Boolean);
  }
  return keys
    .split('+')
    .map((key) => key.trim())
    .filter(Boolean);
}

/**
 * One token reduced to the name this file knows it by.
 *
 * It also folds a real `KeyboardEvent.key`, which is what lets the two sides of
 * a comparison meet in the middle: a caller writes `Esc` and the browser
 * reports `Escape`, and both arrive here as `escape`. The space bar is the one
 * key whose `key` is punctuation, so it is named before the punctuation is
 * stripped.
 */
export function canonicalKey(token: string): string {
  if (token === ' ') {
    return 'space';
  }
  const normalized = token.toLowerCase().replace(/[\s_-]/g, '');
  return keyAliases[normalized] ?? normalized;
}

/**
 * What the browser says it is running on.
 *
 * `userAgentData.platform` is the modern spelling and `navigator.platform` the
 * deprecated one every browser still answers; the user agent string is the last
 * resort, and *last resort* is the load-bearing word. The three are asked in
 * order and the first that says anything at all is the answer — never all three
 * matched at once, which is what this used to do.
 *
 * A union of the three can only ever be wrong in one direction: towards `mac`.
 * A WebKit build on Linux or Windows reports its own platform and a *Safari on
 * macOS* user agent string, so a haystack holding both reads as a Mac, and
 * `Mod` then binds Command on a keyboard that has no Command key — with
 * `Shortcut` drawing a ⌘ over it. That is this file's own opening paragraph
 * happening again, one layer down.
 *
 * The rule is a pure function so it can be asserted on directly: the browser
 * this suite runs in only ever reports one of these combinations, and the one
 * that broke is not it.
 */
export function resolveOS(
  userAgentDataPlatform: string | undefined,
  platform: string | undefined,
  userAgent: string | undefined
): ResolvedOS {
  const source = userAgentDataPlatform || platform || userAgent || '';

  if (/mac|iphone|ipad|ipod/i.test(source)) {
    return 'mac';
  }
  if (/win/i.test(source)) {
    return 'windows';
  }
  return 'linux';
}

function detectOS(): ResolvedOS {
  if (typeof navigator === 'undefined') {
    return 'windows';
  }

  const data = (navigator as Navigator & { userAgentData?: { platform?: string } }).userAgentData;

  return resolveOS(data?.platform, navigator.platform, navigator.userAgent);
}

/**
 * The answer, once.
 *
 * `detectOS` walks three sources and runs two regular expressions over the one
 * that answered, its answer cannot change under a running page, and it is asked
 * on every render of every Shortcut and on every keystroke a bound field sees.
 * Returning the same string back is also what `useSyncExternalStore` requires of
 * a snapshot, which is how `Shortcut` reads it.
 */
let detected: ResolvedOS | null = null;

export function readOS(): ResolvedOS {
  detected ??= detectOS();

  return detected;
}

/**
 * Enough of a keyboard event to decide a combination — so one function serves
 * both a DOM `KeyboardEvent` and React's synthetic one.
 */
export interface KeyPress {
  key: string;
  code: string;
  ctrlKey: boolean;
  metaKey: boolean;
  altKey: boolean;
  shiftKey: boolean;
}

/**
 * Does this keystroke satisfy `Mod+Shift+P`?
 *
 * The modifiers are matched **exactly**, not as a subset: a shortcut names the
 * modifiers it wants, so `Enter` does not fire when `Mod+Enter` was pressed.
 * That is what makes a `shortcuts` map unambiguous — at most one entry can
 * match a keystroke, unless a caller spelled the same combination twice.
 */
export function matchesShortcut(event: KeyPress, shortcut: string): boolean {
  const tokens = tokenize(shortcut).map(canonicalKey);
  if (tokens.length === 0) {
    return false;
  }

  const wanted = { ctrl: false, meta: false, alt: false, shift: false };
  const mac = readOS() === 'mac';

  for (const token of tokens.slice(0, -1)) {
    if (token === 'mod') {
      wanted[mac ? 'meta' : 'ctrl'] = true;
    } else if (token === 'meta' || token === 'ctrl' || token === 'alt' || token === 'shift') {
      wanted[token] = true;
    } else {
      // A token in a modifier's place that names no modifier. Never matching is
      // the only honest answer: the caller wrote something this file cannot
      // read, and firing on the bare key would be worse than not firing.
      return false;
    }
  }

  return (
    event.ctrlKey === wanted.ctrl &&
    event.metaKey === wanted.meta &&
    event.altKey === wanted.alt &&
    event.shiftKey === wanted.shift &&
    sameKey(event, tokens[tokens.length - 1])
  );
}

/**
 * `event.key` first, because that is the character printed on the reader's own
 * keyboard — the whole reason a shortcut is named rather than coded.
 *
 * `event.code` is the fallback, and only for a single character, because
 * holding a modifier can change what gets typed: `Alt+K` on a Mac reports a
 * `key` of `˚`, and on a Dvorak layout `Mod+C` is not on the C key at all. A
 * combination that would otherwise silently stop working on half the keyboards
 * in the world is worth four lines.
 */
function sameKey(event: KeyPress, key: string): boolean {
  if (canonicalKey(event.key) === key) {
    return true;
  }
  if (key.length === 1) {
    if (key >= 'a' && key <= 'z') {
      return event.code === `Key${key.toUpperCase()}`;
    }
    if (key >= '0' && key <= '9') {
      return event.code === `Digit${key}`;
    }
  }
  return false;
}

/**
 * The `shortcuts` map and the caller's own `onKeyDown`, as the one handler a
 * control can carry.
 *
 * The map is checked first and every matching entry runs, so a caller who
 * spelled one combination two ways gets both rather than an arbitrary one; then
 * `onKeyDown` runs, and can read `event.defaultPrevented` to see what the map
 * decided. `undefined` when there is nothing to bind, so a field with neither
 * prop attaches no listener at all.
 */
export function keyHandler<E extends Element>(
  shortcuts: NebaShortcuts<E> | undefined,
  onKeyDown?: React.KeyboardEventHandler<E>
): React.KeyboardEventHandler<E> | undefined {
  if (!shortcuts) {
    return onKeyDown;
  }

  return (event) => {
    for (const [combination, run] of Object.entries(shortcuts)) {
      if (matchesShortcut(event, combination)) {
        run(event);
      }
    }
    onKeyDown?.(event);
  };
}

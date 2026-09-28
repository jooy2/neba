'use client';

import * as React from 'react';
import { matchesShortcut } from '../internal/keys.js';

export interface ShortcutOptions {
  /** Stop listening without unmounting — a modal is open, a field has focus. @default true */
  enabled?: boolean;
  /**
   * Ignore the key while the reader is typing into an input, a textarea, a
   * select or anything `contenteditable`.
   *
   * On by default, and it is the reason a bare `/` or `?` can be bound at all:
   * a page-wide single-letter shortcut that fires inside a search box is a
   * shortcut that eats what somebody was writing. A combination with a modifier
   * is usually meant to work everywhere, so turn this off for those.
   * @default true
   */
  ignoreWhileTyping?: boolean;
  /**
   * Call `preventDefault` when it matches — for a key the browser also has an
   * opinion about, like `Mod+K` or `Mod+S`. @default true
   */
  preventDefault?: boolean;
  /**
   * Call the handler again for every repeat of a held key. Off by default: a
   * shortcut held down a moment too long opened a panel and then opened it
   * again twenty times a second. The repeats still have their default
   * prevented, or holding `Mod+S` would save once and then open the browser's
   * own dialog. @default false
   */
  repeat?: boolean;
}

/**
 * The keys a shortcut of this hook prevented, so a second binding of the same
 * combination still runs: it is somebody *else's* `preventDefault` that says
 * the key was answered.
 */
const answered = new WeakSet<Event>();

/** The elements a reader types into, where a bare-letter shortcut must not fire. */
function isTyping(target: EventTarget | null): boolean {
  if (!(target instanceof HTMLElement)) {
    return false;
  }
  return (
    target.isContentEditable ||
    target.tagName === 'INPUT' ||
    target.tagName === 'TEXTAREA' ||
    target.tagName === 'SELECT'
  );
}

/**
 * A key combination bound on the window, spelled the way
 * [Shortcut](../components/display/shortcut) draws it — `'Mod+K'`, `'Mod+Shift+P'`,
 * `'?'`.
 *
 * This is what `CommandPalette` binds its own opener with, offered because an
 * application has more shortcuts than the library does and every one of them
 * should be spelled the way its key cap is. `Mod` is Command on a Mac and
 * Control everywhere else; the modifiers are matched exactly.
 *
 * The handler is held in a ref, so a listener is bound once per combination
 * rather than re-bound on every render that closes over new state.
 */
export function useShortcut(
  shortcut: string | false,
  handler: (event: KeyboardEvent) => void,
  options: ShortcutOptions = {}
): void {
  const {
    enabled = true,
    ignoreWhileTyping = true,
    preventDefault = true,
    repeat = false
  } = options;

  // The newest handler, kept in a ref so the listener below is bound once per
  // combination rather than re-bound on every render that closes over new
  // state. Written in an effect and not during render: a ref written while
  // rendering is a ref that lies if React throws the render away.
  const latest = React.useRef(handler);

  React.useEffect(() => {
    latest.current = handler;
  });

  React.useEffect(() => {
    if (shortcut === false || !enabled) {
      return undefined;
    }

    const onKeyDown = (event: KeyboardEvent) => {
      // Something on the way up already answered the key — a field with a
      // `Mod+K` of its own, a menu's type-ahead — and the key is theirs.
      if (event.defaultPrevented && !answered.has(event)) {
        return;
      }
      if (ignoreWhileTyping && isTyping(event.target)) {
        return;
      }
      if (!matchesShortcut(event, shortcut)) {
        return;
      }
      if (preventDefault) {
        event.preventDefault();
        answered.add(event);
      }
      if (event.repeat && !repeat) {
        return;
      }
      latest.current(event);
    };

    window.addEventListener('keydown', onKeyDown);

    return () => window.removeEventListener('keydown', onKeyDown);
  }, [shortcut, enabled, ignoreWhileTyping, preventDefault, repeat]);
}

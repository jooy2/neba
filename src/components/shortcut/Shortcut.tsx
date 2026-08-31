'use client';

import * as React from 'react';
import {
  controlHeightClasses,
  controlSlots,
  controlTextClasses,
  cx,
  paddingXClasses,
  radiusClasses,
  srOnlyClasses,
  surfaceClasses,
  transitionClasses
} from '../../internal/styles.js';
import { canonicalKey, readOS, tokenize, type ResolvedOS } from '../../internal/keys.js';
import type { NebaElevation, NebaSize, NebaStyleProps } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/**
 * Which keyboard the shortcut is being read on.
 *
 * `auto` asks the browser, which is right for a shortcut a reader is about to
 * press. The three explicit values are for documentation that has to name a
 * platform rather than the reader's own — a support page describing the Windows
 * build, a table comparing the two.
 */
export type ShortcutOS = 'auto' | ResolvedOS;

export interface ShortcutProps
  extends NebaStyleProps, Omit<React.ComponentPropsWithoutRef<'span'>, 'color' | 'children'> {
  /**
   * The keys, innermost punctuation and all.
   *
   * A string is split on `+` — `'Mod+Shift+P'` — which covers everything except
   * a shortcut whose key *is* a plus. For that one, pass the array form:
   * `keys={['Ctrl', '+']}`.
   */
  keys: string | string[];
  /**
   * Which keyboard to name the modifiers for.
   * @default 'auto'
   */
  os?: ShortcutOS;
  /**
   * What goes between two keys. Omit it for the platform's own convention: a `+`
   * on Windows and Linux, and nothing at all on macOS, where a shortcut is
   * written as a run of symbols — `⇧⌘P`, never `⇧+⌘+P`.
   */
  separator?: React.ReactNode;
  /**
   * Drop shadow depth. `0` (the default) is flat. A key cap is the one place a
   * raised surface is tempting and wrong: this is a picture of a key, not a key.
   * @default 0
   */
  elevation?: NebaElevation;
}

/**
 * What a key is called, and what it is drawn as.
 *
 * `symbol` is what a sighted reader sees and `name` is what a screen reader
 * says. They differ on exactly the keys macOS draws as glyphs — `⌘` announced by
 * its Unicode name is "place of interest sign", which is not a key anybody has
 * on their keyboard.
 */
interface KeyLabel {
  symbol: string;
  name: string;
}

const word = (text: string): KeyLabel => ({ symbol: text, name: text });

/**
 * One entry per key that is spelled differently somewhere, keyed by the token
 * with its case and spaces taken off.
 *
 * The aliases are deliberate and not generosity: `Cmd`, `Command` and `Meta` are
 * three names one key already has, and a component that accepted only one of
 * them would be a component every caller has to look up.
 *
 * `Mod` is the entry the rest exist for. It is the only token whose *meaning*
 * changes with the platform rather than just its spelling — the modifier a
 * shortcut is actually built on, which is Command on a Mac and Control
 * everywhere else. Writing `Ctrl` and hoping is what makes a documentation page
 * wrong for half its readers.
 */
const keyLabels: Record<string, Record<ResolvedOS, KeyLabel>> = {
  mod: {
    mac: { symbol: '⌘', name: 'Command' },
    windows: word('Ctrl'),
    linux: word('Ctrl')
  },
  meta: {
    mac: { symbol: '⌘', name: 'Command' },
    windows: word('Win'),
    linux: word('Super')
  },
  ctrl: {
    mac: { symbol: '⌃', name: 'Control' },
    windows: word('Ctrl'),
    linux: word('Ctrl')
  },
  alt: {
    mac: { symbol: '⌥', name: 'Option' },
    windows: word('Alt'),
    linux: word('Alt')
  },
  shift: {
    mac: { symbol: '⇧', name: 'Shift' },
    windows: word('Shift'),
    linux: word('Shift')
  },
  enter: {
    mac: { symbol: '↩', name: 'Enter' },
    windows: word('Enter'),
    linux: word('Enter')
  },
  tab: {
    mac: { symbol: '⇥', name: 'Tab' },
    windows: word('Tab'),
    linux: word('Tab')
  },
  escape: {
    mac: { symbol: '⎋', name: 'Escape' },
    windows: word('Esc'),
    linux: word('Esc')
  },
  backspace: {
    mac: { symbol: '⌫', name: 'Backspace' },
    windows: word('Backspace'),
    linux: word('Backspace')
  },
  delete: {
    mac: { symbol: '⌦', name: 'Delete' },
    windows: word('Del'),
    linux: word('Del')
  },
  capslock: {
    mac: { symbol: '⇪', name: 'Caps Lock' },
    windows: word('Caps Lock'),
    linux: word('Caps Lock')
  }
};

/**
 * The keys drawn as arrows on every platform, not just on a Mac. An arrow is not
 * a Mac convention — it is what is printed on the key.
 *
 * Only the `arrow*` spellings, because `canonicalKey` folds the bare `up` into
 * `arrowup` on the way in — the same fold that lets a binding compare a token
 * against a real `KeyboardEvent.key`.
 */
const arrowLabels: Record<string, KeyLabel> = {
  arrowup: { symbol: '↑', name: 'Arrow up' },
  arrowdown: { symbol: '↓', name: 'Arrow down' },
  arrowleft: { symbol: '←', name: 'Arrow left' },
  arrowright: { symbol: '→', name: 'Arrow right' }
};

/** Resolves one token into what to draw and what to announce. */
function labelFor(token: string, os: ResolvedOS): KeyLabel {
  const canonical = canonicalKey(token);

  const arrow = arrowLabels[canonical];
  if (arrow) {
    return arrow;
  }

  const known = keyLabels[canonical];
  if (known) {
    return known[os];
  }

  // Everything else is printed as it was written, with the one courtesy that a
  // single letter is capitalised: `keys="mod+k"` should draw a K, because that
  // is what is on the key.
  return word(token.length === 1 ? token.toUpperCase() : token);
}

/** The platform never changes under a running page, so there is nothing to subscribe to. */
function subscribe() {
  return () => {};
}

function serverOS(): ResolvedOS {
  return 'windows';
}

/**
 * `useSyncExternalStore` rather than `useEffect` plus state, and rather than
 * reading `navigator` during render.
 *
 * Reading it during render is a hydration mismatch waiting to happen: the server
 * has no `navigator`, so it would render `Ctrl` and the client would render `⌘`
 * into the same markup. This hook is the one API that tells React the two are
 * *meant* to differ — it hydrates with the server's answer and re-renders with
 * the browser's, which is exactly the sequence a Mac reader sees.
 */
function useDetectedOS(): ResolvedOS {
  return React.useSyncExternalStore(subscribe, readOS, serverOS);
}

/**
 * A key cap sits one step down the control ladder, exactly as a Chip does and
 * for the same reason: it is a token inside a line of text, not a control the
 * line lines up against.
 */
const keyScale: Record<NebaSize, NebaSize> = {
  xs: 'xs',
  sm: 'xs',
  md: 'sm',
  lg: 'md',
  xl: 'lg'
};

/**
 * The three weights, filled / hairline / none. `outline` is the default: a key
 * cap is a hairline box, which is what a key cap has looked like in every manual
 * ever printed.
 */
const variantClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: [
    surfaceClasses,
    'text-(--n-on-solid) bg-(--n-fill)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--n-accent) bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  text: 'text-(--n-accent) bg-(--n-soft)'
};

/** The width a single-letter cap is held to, so `⌘` and `K` are the same square. */
const keyMinWidthClasses: Record<NebaSize, string> = {
  xs: 'min-w-5.5',
  sm: 'min-w-6.5',
  md: 'min-w-8',
  lg: 'min-w-10',
  xl: 'min-w-12'
};

/**
 * A keyboard key, or a combination of them.
 *
 * Two things make this more than a styled `<kbd>`, and both are about the label
 * rather than the box around it.
 *
 * The first is `Mod`. A shortcut written as `Ctrl+K` is wrong for every Mac
 * reader and one written as `⌘K` is wrong for everybody else, so the token that
 * means "the modifier shortcuts are built on" resolves per platform — and `os`
 * is there for the pages that have to name a platform rather than the reader's.
 *
 * The second is that `⌘` is not a word. A screen reader reads it as "place of
 * interest sign", so every key drawn as a glyph carries its name beside it, in
 * the clipped box `srOnlyClasses` describes. What is announced is "Command K",
 * which is what the shortcut is called.
 *
 * The keys are real `<kbd>` elements; the wrapper around them is a `<span>`.
 * Nesting `<kbd>` inside `<kbd>` is allowed and would also be defensible, but a
 * `kbd` wrapper is a second box for a host stylesheet to reach into for no gain
 * — the semantics are carried by the keys themselves either way.
 */
export const Shortcut = React.forwardRef<HTMLSpanElement, ShortcutProps>(
  function Shortcut(rawProps, ref) {
    const {
      variant = 'outline',
      size = 'md',
      color = 'secondary',
      density = 'compact',
      elevation = 0,
      keys,
      os = 'auto',
      separator,
      className,
      style,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density', 'variant']);

    const detected = useDetectedOS();
    const resolved: ResolvedOS = os === 'auto' ? detected : os;

    const step = keyScale[size];
    const tokens = tokenize(keys);
    const labels = tokens.map((token) => labelFor(token, resolved));

    // macOS writes a shortcut as a run of symbols with nothing between them; the
    // other two join theirs with a `+`. A caller who passes one gets theirs.
    const joiner = separator === undefined ? (resolved === 'mac' ? null : '+') : separator;

    const keyClasses = [
      'inline-flex shrink-0 items-center justify-center',
      'font-mono font-medium leading-none whitespace-nowrap tabular-nums',
      controlHeightClasses[step],
      controlTextClasses[step],
      keyMinWidthClasses[step],
      paddingXClasses[density][step],
      radiusClasses[step],
      variantClasses[variant],
      transitionClasses
    ].join(' ');

    return (
      <span
        ref={ref}
        className={cx('inline-flex max-w-full items-center gap-1 align-middle', className ?? '')}
        style={{ ...controlSlots(color, elevation, variant), ...style }}
        {...props}
      >
        {labels.map((label, index) => (
          // The index is a legitimate key here: the list is the `keys` prop, in
          // order, and two identical keys in one shortcut are the same key.
          <React.Fragment key={index}>
            {index > 0 && joiner !== null ? (
              <span aria-hidden="true" className="text-(--neba-muted-fg)">
                {joiner}
              </span>
            ) : null}

            <kbd className={keyClasses}>
              {label.symbol === label.name ? (
                label.symbol
              ) : (
                <>
                  <span aria-hidden="true">{label.symbol}</span>
                  <span className={srOnlyClasses}>{label.name}</span>
                </>
              )}
            </kbd>
          </React.Fragment>
        ))}
      </span>
    );
  }
);

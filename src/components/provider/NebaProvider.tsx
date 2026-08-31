'use client';

import * as React from 'react';
import { DirectionProvider } from '@base-ui/react/direction-provider';
import { DefaultsContext, type NebaDefaults } from '../../internal/defaults.js';
import { useMediaQuery } from '../../internal/media.js';

/** What a reader asked for. `system` is a deferral, not a third appearance. */
export type NebaColorScheme = 'light' | 'dark' | 'system';

/** Which way the document runs. */
export type NebaDirection = 'ltr' | 'rtl';

/** What `useColorScheme` hands back. */
export interface ColorSchemeState {
  /** What was asked for, `system` included. */
  colorScheme: NebaColorScheme;
  /** What that comes out as right now — never `system`. */
  resolvedColorScheme: 'light' | 'dark';
  setColorScheme: (scheme: NebaColorScheme) => void;
  /** Light ↔ dark. From `system`, it goes to the opposite of what is showing. */
  toggleColorScheme: () => void;
}

export interface NebaProviderProps {
  children?: React.ReactNode;
  /**
   * Prop values every component under it starts from.
   *
   * `size`, `density`, `variant` and `locale` — the axes whose right value is a
   * property of the product rather than of the control. A call site still wins:
   * the order is the caller, then this, then the component's own default.
   */
  defaults?: NebaDefaults;
  /** The colour scheme. Use with `onColorSchemeChange` to control it. */
  colorScheme?: NebaColorScheme;
  /** @default 'system' */
  defaultColorScheme?: NebaColorScheme;
  onColorSchemeChange?: (scheme: NebaColorScheme) => void;
  /**
   * Where the choice is remembered, or `false` to forget it between visits.
   * @default 'neba-color-scheme'
   */
  storageKey?: string | false;
  /**
   * Which element the scheme is written on. The `<html>` element by default,
   * which is what the stylesheet and the browser's own form controls read.
   *
   * A function, called after mount, so it can name an element React itself
   * renders. Returning `null` writes nowhere at all — which is what a preview
   * embedded in someone else's page needs, and why this is not just an element.
   */
  colorSchemeElement?: () => Element | null;
  /**
   * The writing direction. Left alone when it is not given, so a document that
   * already sets `dir` on `<html>` is not fought over.
   */
  direction?: NebaDirection;
}

const ColorSchemeContext = React.createContext<ColorSchemeState | null>(null);

const DARK_QUERY = '(prefers-color-scheme: dark)';

/** Reads the remembered choice. Never throws: private mode denies the read. */
function readStored(key: string | false): NebaColorScheme | null {
  if (key === false || typeof localStorage === 'undefined') {
    return null;
  }
  try {
    const stored = localStorage.getItem(key);
    return stored === 'light' || stored === 'dark' || stored === 'system' ? stored : null;
  } catch {
    return null;
  }
}

/**
 * The script to run before the first paint, so a remembered dark page does not
 * flash white on the way in.
 *
 * The one thing a provider cannot do for you: React runs after the document has
 * been painted once, and by then the flash has happened. Inline the string this
 * returns in `<head>`, above everything:
 *
 * ```tsx
 * <script dangerouslySetInnerHTML={{ __html: colorSchemeScript() }} />
 * ```
 *
 * It reads the same key and writes the same attribute the provider does, so the
 * two cannot disagree — which is the reason it is here rather than in a
 * documentation snippet somebody copies once and never updates.
 */
export function colorSchemeScript(
  options: { storageKey?: string; defaultColorScheme?: NebaColorScheme } = {}
): string {
  const key = options.storageKey ?? 'neba-color-scheme';
  const fallback = options.defaultColorScheme ?? 'system';

  return (
    `(function(){try{var s=localStorage.getItem(${JSON.stringify(key)})||${JSON.stringify(fallback)};` +
    `if(s==='system'){s=matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light'}` +
    `document.documentElement.setAttribute('data-theme',s)}catch(e){}})()`
  );
}

/**
 * One place to set what every Neba component under it starts from.
 *
 * Three jobs, and they are together because all three are properties of the
 * *application* rather than of any control in it: the prop values a product has
 * decided on, the colour scheme a reader has chosen, and the direction the
 * document runs in. Writing `size="sm"` at four hundred call sites is the
 * problem this exists to end.
 *
 * It renders no element of its own. The colour scheme is an attribute on
 * `<html>` — which is where the stylesheet already looks, and where the
 * browser's own form controls and scrollbars look — and the direction is `dir`
 * on the same element plus Base UI's own provider, so its primitives flip their
 * keyboard and their positioning with the page.
 *
 * It is entirely optional. Every component works without it, and a page that
 * has none pays a `useContext` that returns `null` and nothing else.
 */
export function NebaProvider({
  children,
  defaults,
  colorScheme: colorSchemeProp,
  defaultColorScheme = 'system',
  onColorSchemeChange,
  storageKey = 'neba-color-scheme',
  colorSchemeElement,
  direction
}: NebaProviderProps) {
  // The remembered choice is read once, lazily: `localStorage` on a server is
  // absent and on the client is synchronous, and reading it in an effect means
  // the first paint is the wrong scheme even when the inline script was used.
  const [uncontrolled, setUncontrolled] = React.useState<NebaColorScheme>(
    () => readStored(storageKey) ?? defaultColorScheme
  );
  const colorScheme = colorSchemeProp ?? uncontrolled;

  const systemIsDark = useMediaQuery(DARK_QUERY);
  const resolved = colorScheme === 'system' ? (systemIsDark ? 'dark' : 'light') : colorScheme;

  const setColorScheme = React.useCallback(
    (next: NebaColorScheme) => {
      if (colorSchemeProp === undefined) {
        setUncontrolled(next);
      }
      if (storageKey !== false) {
        try {
          localStorage.setItem(storageKey, next);
        } catch {
          // Private mode, or a browser with storage turned off. The scheme
          // still applies for this visit; only remembering it is lost.
        }
      }
      onColorSchemeChange?.(next);
    },
    [colorSchemeProp, storageKey, onColorSchemeChange]
  );

  React.useEffect(() => {
    // Only falls back when the prop was not given: a caller who did give one
    // and got `null` back meant nowhere, not `<html>`.
    const element = colorSchemeElement ? colorSchemeElement() : document.documentElement;

    if (!element) {
      return;
    }
    element.setAttribute('data-theme', resolved);
    // `color-scheme` is what turns the browser's own furniture over — the
    // scrollbars, the form controls it still draws itself, the canvas behind
    // an overscroll. A page that changes only its own colours keeps a white
    // scrollbar down the side of a dark one.
    (element as HTMLElement).style.colorScheme = resolved;
  }, [resolved, colorSchemeElement]);

  React.useEffect(() => {
    if (!direction) {
      return;
    }
    document.documentElement.setAttribute('dir', direction);
  }, [direction]);

  const scheme = React.useMemo<ColorSchemeState>(
    () => ({
      colorScheme,
      resolvedColorScheme: resolved,
      setColorScheme,
      toggleColorScheme: () => setColorScheme(resolved === 'dark' ? 'light' : 'dark')
    }),
    [colorScheme, resolved, setColorScheme]
  );

  return (
    <DefaultsContext.Provider value={defaults ?? null}>
      <ColorSchemeContext.Provider value={scheme}>
        <DirectionProvider direction={direction ?? 'ltr'}>{children}</DirectionProvider>
      </ColorSchemeContext.Provider>
    </DefaultsContext.Provider>
  );
}

/**
 * The colour scheme, and the two ways to change it.
 *
 * `colorScheme` is what was asked for and `resolvedColorScheme` is what that
 * comes out as — the difference matters for the control that shows it, because
 * a three-way switch has to show `system` as its own position rather than as
 * whichever of the two it currently resolves to.
 */
export function useColorScheme(): ColorSchemeState {
  const state = React.useContext(ColorSchemeContext);

  if (!state) {
    throw new Error('neba: useColorScheme() needs a <NebaProvider> above it.');
  }

  return state;
}

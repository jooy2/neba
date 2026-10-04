'use client';

import * as React from 'react';
import { DirectionProvider, useDirection } from '@base-ui/react/direction-provider';
import { DefaultsContext, type NebaDefaults } from '../../internal/defaults.js';
import { useHydrated, useMediaQuery } from '../../internal/media.js';
import { DEFAULT_STORAGE_KEY } from './colorSchemeScript.js';

/** Replaced by the consumer's bundler, as it is in React and Base UI. */
declare const process: { env: { NODE_ENV?: string } };

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
   * `size`, `density`, `variant`, `locale` and `labelPlacement` — the axes whose
   * right value is a property of the product rather than of the control. A call site still wins:
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
  storageKey = DEFAULT_STORAGE_KEY,
  colorSchemeElement,
  direction
}: NebaProviderProps) {
  // The remembered choice is read past hydration rather than as the state's
  // first value: a server has no `localStorage`, so the server rendered the
  // default and the hydrating client the stored scheme, which React reports as
  // the two renders disagreeing. The inline script has already put the stored
  // scheme on `<html>` for the first paint, and the attribute below is not
  // written until the stored value has been read, so nothing flips in between.
  const hydrated = useHydrated();
  // What a provider above this one has already set. A nested provider starts
  // from it rather than from nothing: its `defaults` are merged over the outer
  // ones, it runs the same way unless told otherwise, and it leaves `<html>` to
  // the outermost provider.
  const outerDefaults = React.useContext(DefaultsContext);
  const outerScheme = React.useContext(ColorSchemeContext);
  const inheritedDirection = useDirection();
  const [chosen, setChosen] = React.useState<NebaColorScheme | null>(null);
  const stored = React.useMemo(
    () => (hydrated ? readStored(storageKey) : null),
    [hydrated, storageKey]
  );
  const colorScheme = colorSchemeProp ?? chosen ?? stored ?? defaultColorScheme;

  const systemIsDark = useMediaQuery(DARK_QUERY);
  const resolved = colorScheme === 'system' ? (systemIsDark ? 'dark' : 'light') : colorScheme;

  const setColorScheme = React.useCallback(
    (next: NebaColorScheme) => {
      if (colorSchemeProp === undefined) {
        setChosen(next);
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
    if (!hydrated) {
      return;
    }

    // Only falls back when the prop was not given: a caller who did give one
    // and got `null` back meant nowhere, not `<html>`. A nested provider has no
    // fallback at all: `<html>` belongs to the outermost one, and two providers
    // writing it fought over the page's scheme.
    const element = colorSchemeElement
      ? colorSchemeElement()
      : outerScheme === null
        ? document.documentElement
        : null;

    if (!element) {
      return;
    }
    element.setAttribute('data-theme', resolved);
    // `color-scheme` is what turns the browser's own furniture over — the
    // scrollbars, the form controls it still draws itself, the canvas behind
    // an overscroll. A page that changes only its own colours keeps a white
    // scrollbar down the side of a dark one.
    (element as HTMLElement).style.colorScheme = resolved;
  }, [hydrated, resolved, colorSchemeElement, outerScheme]);

  /*
   * `dir` is written from an effect, which is after the page has been painted
   * once — on a page the server rendered, after it has been on screen for as
   * long as the scripts took to arrive. A document that does not already run
   * the provider's way is therefore drawn the other way round first and mirrors
   * when this runs. Nothing on the screen says why, so the developer is told in
   * the console, once per mount, and a production build says nothing. Only the
   * first run asks: a `direction` that changes later is a page being switched,
   * not one that loaded the wrong way.
   */
  const checkedDirection = React.useRef(false);

  React.useEffect(() => {
    const mounting = !checkedDirection.current;
    checkedDirection.current = true;

    if (!direction) {
      return;
    }

    const served = document.documentElement.dir;

    if (process.env.NODE_ENV !== 'production' && mounting && (served || 'ltr') !== direction) {
      console.warn(
        `Neba: a NebaProvider has direction="${direction}", and <html> ${
          served ? `has dir="${served}"` : 'has no dir'
        }. The provider sets dir only once it has mounted, so the page is drawn the other way round until then and mirrors when it does. Put dir="${direction}" on <html> in the HTML itself.`
      );
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

  /*
   * Kept by value rather than by the object that was passed. The natural way to
   * write the prop is inline — `defaults={{ size: 'sm' }}` — which is a new
   * object on every render of whatever renders the provider, and a context value
   * that changes identity re-renders every component under it that reads one.
   */
  const size = defaults?.size ?? outerDefaults?.size;
  const density = defaults?.density ?? outerDefaults?.density;
  const variant = defaults?.variant ?? outerDefaults?.variant;
  const locale = defaults?.locale ?? outerDefaults?.locale;
  const labelPlacement = defaults?.labelPlacement ?? outerDefaults?.labelPlacement;
  const given = (defaults !== undefined && defaults !== null) || outerDefaults !== null;
  const defaultsValue = React.useMemo<NebaDefaults | null>(
    () => (given ? { size, density, variant, locale, labelPlacement } : null),
    [given, size, density, variant, locale, labelPlacement]
  );

  return (
    <DefaultsContext.Provider value={defaultsValue}>
      <ColorSchemeContext.Provider value={scheme}>
        <DirectionProvider direction={direction ?? inheritedDirection}>
          {children}
        </DirectionProvider>
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

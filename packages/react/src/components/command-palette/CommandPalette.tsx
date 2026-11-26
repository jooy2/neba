'use client';

import * as React from 'react';
import { useShortcut } from '../../hooks/useShortcut.js';
import { useHydrated } from '../../internal/media.js';
import type { NebaSlots, NebaStyleProps } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';
import { whenIdle } from '../../internal/idle.js';
import type { CommandPaletteSheetProps } from './CommandPaletteSheet.js';

/**
 * The parts a CommandPalette draws around its sheet.
 *
 * `className` is the sheet — the panel the search field and the rows sit on.
 * `backdrop` and `viewport` render outside it and have no other way in.
 *
 * `group` is one heading between the rows, not the rows under it: a group is
 * named by its first item's `group`, and the rows themselves are `item`.
 */
export type CommandPaletteSlot =
  'backdrop' | 'viewport' | 'input' | 'list' | 'group' | 'item' | 'empty';

/** One thing the palette can do. */
export interface CommandItem {
  /** What identifies the command. */
  value: string;
  /** What the row says, and what the query is matched against. */
  label: string;
  /** A second line under it — where the command goes, or what it changes. */
  description?: React.ReactNode;
  /** A glyph before the label. */
  icon?: React.ReactNode;
  /**
   * The keystroke that does the same thing, set at the end of the row. Written
   * the way [Shortcut](../display/shortcut) writes them, so `Mod` resolves per
   * platform. The palette does not bind it — the application does.
   */
  shortcut?: string;
  /**
   * The heading this command sits under. Commands are drawn in the order they
   * are given, and a heading is drawn each time the group changes — so a group's
   * commands have to be listed together.
   */
  group?: string;
  /**
   * Extra words the query is matched against but that are never drawn — the
   * name somebody else's product gives the same command, an abbreviation, the
   * word they would have searched for.
   */
  keywords?: readonly string[];
  /** In the list but not runnable. */
  disabled?: boolean;
  /** What running it does. */
  onSelect?: () => void;
}

export interface CommandPaletteProps extends Pick<NebaStyleProps, 'size' | 'color' | 'density'> {
  /** Everything the palette can do. */
  items: readonly CommandItem[];
  /** Whether the palette is open. Use with `onOpenChange` for a controlled one. */
  open?: boolean;
  /** Whether it starts open, for an uncontrolled one. @default false */
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /**
   * Called when a command is run, after its own `onSelect`. The palette closes
   * either way.
   */
  onSelect?: (item: CommandItem) => void;
  /**
   * The keystroke that opens the palette, bound on the window. Written the way
   * [Shortcut](../display/shortcut) writes them, so `Mod` is Command on a Mac
   * and Control everywhere else. `false` binds nothing.
   * @default 'Mod+K'
   */
  shortcut?: string | false;
  /** How wide the sheet may get. A number of pixels or any CSS length. */
  width?: number | string;
  /** How tall the list may get before it scrolls. @default 320 */
  maxHeight?: number | string;
  /**
   * Which language the placeholder, the empty line and the dialog's own name
   * are written in — a BCP 47 tag such as `ko`, `pt-BR` or `zh-Hant`.
   * Unsupported tags fall back to English.
   */
  locale?: string;
  /** The placeholder in the field. Defaults to the `locale`'s wording. */
  placeholder?: string;
  /** The line where the rows would be, when nothing matched. */
  emptyMessage?: React.ReactNode;
  /** The accessible name of the dialog, which has no visible title. */
  label?: string;
  /** Class names for the sheet. */
  className?: string;
  /**
   * Class names for the parts around it. `className` is the sheet, so the scrim
   * behind it is `classNames.backdrop`.
   */
  classNames?: NebaSlots<CommandPaletteSlot>;
}

type Sheet = React.ComponentType<CommandPaletteSheetProps>;

/**
 * The sheet, fetched on its own.
 *
 * A palette is shut until a reader asks for it, and Base UI's Dialog and
 * Autocomplete were 38.7 kB gzipped of a palette alone, every byte of it in the
 * bundle a page needs before it can draw. So the sheet is the arrangement an
 * Image makes with its viewer: a chunk of its own, asked for when the browser
 * is first idle after the palette mounts, so it is there by the time a reader
 * reaches for the key.
 */
const requestSheet = () =>
  import('./CommandPaletteSheet.js').then((module) => ({ default: module.CommandPaletteSheet }));

let sheetRequest: ReturnType<typeof requestSheet> | undefined;

/** The sheet, once the chunk has arrived, so a palette opened then draws it at once. */
let loadedSheet: Sheet | undefined;

/**
 * The one request for the sheet's chunk, shared by everything that asks. A
 * request that fails is forgotten, so the next one tries again rather than
 * failing for good.
 *
 * An object rather than a function so a test can spy on it. Exported for that,
 * and deliberately left out of the barrel.
 */
export const sheetChunk = {
  load() {
    sheetRequest ??= requestSheet().then(
      (module) => {
        loadedSheet = module.default;

        return module;
      },
      (error: unknown) => {
        sheetRequest = undefined;

        throw error;
      }
    );

    return sheetRequest;
  }
};

const LazySheet = React.lazy(() => sheetChunk.load());

/**
 * Everything an application can do, behind one field.
 *
 * The shape a keyboard-first product takes once it has more actions than a menu
 * bar can hold: a reader types what they want instead of remembering where it
 * was put. It is not a [Menu](./menu) — a menu is a short list in one place, and
 * every row is visible before you look for it. It is not a
 * [Combobox](./combobox) either: what comes back is not a value, it is
 * something happening.
 *
 * What is here is what has to be ready before the palette is: the open state
 * and the key that changes it. Everything drawn is in `CommandPaletteSheet`,
 * which is mounted by the first open and kept from then on, so it can fade out
 * as it closes. It is never mounted on a server or in the render that hydrates
 * what a server sent — a component fetched on demand suspends there, and the
 * server drew nothing for a shut dialog anyway — so a palette that starts open
 * opens once the page has hydrated.
 */
export function CommandPalette(rawProps: CommandPaletteProps) {
  const {
    open,
    defaultOpen = false,
    onOpenChange,
    shortcut = 'Mod+K',
    size = 'md',
    color = 'primary',
    density = 'default',
    ...sheetProps
  } = useStyleDefaults(rawProps, ['size', 'density', 'locale']);

  const [uncontrolled, setUncontrolled] = React.useState(defaultOpen);

  const showing = open ?? uncontrolled;

  const setOpen = React.useCallback(
    (next: boolean) => {
      if (open === undefined) setUncontrolled(next);
      onOpenChange?.(next);
    },
    [open, onOpenChange]
  );

  // Bound through the same hook an application binds its own keys with, which
  // holds the handler in a ref: a controlled caller passing an inline
  // `onOpenChange` no longer rebinds the window listener on every render. It
  // fires while typing too, since a modified key is meant to work everywhere,
  // and it calls `preventDefault` — the browser's own Mod+K is a search bar in
  // some of them, and the page asked for this key. A key a field inside the
  // page already answered is left to it, and pressing it again while the
  // palette is up does nothing rather than reporting another open.
  useShortcut(
    shortcut,
    () => {
      if (!showing) setOpen(true);
    },
    { ignoreWhileTyping: false }
  );

  // Which sheet is drawn, chosen by the first open and kept: the one already
  // fetched, or the lazy one that waits for it. Switching from one to the other
  // later would be a different component, and React would mount the dialog
  // again under the reader.
  const hydrated = useHydrated();
  const [Sheet, setSheet] = React.useState<Sheet | null>(null);
  // A palette open from its first render never faded in, and still does not.
  const [openFromStart] = React.useState(showing);

  if (Sheet === null && showing && hydrated) {
    setSheet(() => loadedSheet ?? LazySheet);
  }

  React.useEffect(
    () =>
      whenIdle(
        () => {
          // A download that fails here is tried again by the open, which is the
          // one with a reader waiting on it.
          sheetChunk.load().catch(() => {});
        },
        2000,
        200
      ),
    []
  );

  return Sheet ? (
    <React.Suspense fallback={null}>
      <Sheet
        {...sheetProps}
        open={showing}
        onOpenChange={setOpen}
        fadeIn={!openFromStart}
        size={size}
        color={color}
        density={density}
      />
    </React.Suspense>
  ) : null;
}

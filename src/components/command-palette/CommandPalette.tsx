'use client';

import * as React from 'react';
import { Autocomplete } from '@base-ui/react/autocomplete';
import { Dialog as BaseUIDialog } from '@base-ui/react/dialog';
import { Shortcut } from '../shortcut/Shortcut.js';
import { commandMessages, useMessages } from '../../internal/i18n.js';
import { searchHaystack, searchText } from '../../internal/search.js';
import {
  controlTextLeadingClasses,
  cx,
  hasContent,
  metaTextClasses,
  radiusClasses,
  surfaceClasses,
  surfaceSlots,
  toLength
} from '../../internal/styles.js';
import type { NebaSize, NebaStyleProps } from '../../types.js';

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
}

const backdropClasses = [
  'fixed inset-0 z-50 bg-(--neba-scrim)',
  '[backdrop-filter:blur(2px)]',
  '[transition:opacity_var(--neba-duration)_var(--neba-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

const popupClasses = [
  surfaceClasses,
  'relative flex w-full flex-col overflow-hidden',
  'border text-(--neba-fg) bg-(--n-panel-press)',
  '[border-color:var(--n-line)]',
  '[box-shadow:var(--neba-shadow-3),var(--neba-plate-glass)]',
  '[outline:none]',
  '[transition:opacity_var(--neba-duration)_var(--neba-ease)]',
  'data-[starting-style]:opacity-0 data-[ending-style]:opacity-0'
].join(' ');

const widthClasses: Record<NebaSize, string> = {
  xs: 'max-w-sm',
  sm: 'max-w-md',
  md: 'max-w-xl',
  lg: 'max-w-2xl',
  xl: 'max-w-3xl'
};

const inputHeights: Record<NebaSize, string> = {
  xs: 'h-9',
  sm: 'h-10',
  md: 'h-12',
  lg: 'h-14',
  xl: 'h-16'
};

const rowPadY: Record<NebaSize, string> = {
  xs: 'py-1',
  sm: 'py-1.5',
  md: 'py-2',
  lg: 'py-2.5',
  xl: 'py-3'
};

const insetX: Record<NebaSize, string> = {
  xs: 'px-2.5',
  sm: 'px-3',
  md: 'px-3.5',
  lg: 'px-4',
  xl: 'px-5'
};

const rowClasses = [
  'flex cursor-pointer items-center gap-3 select-none',
  '[transition:background-color_var(--neba-duration)_var(--neba-ease)]',
  // The highlight is Base UI's, and it is one thing rather than two: the pointer
  // and the arrow keys move the same mark, so a reader never has to work out
  // which of two highlighted rows Enter would run.
  'data-[highlighted]:bg-(--n-soft) data-[highlighted]:text-(--n-accent)',
  'data-[disabled]:cursor-not-allowed data-[disabled]:text-(--neba-disabled-fg)'
].join(' ');

/**
 * Everything a command answers to, folded into one string.
 *
 * `searchHaystack` is the same fold a DataTable's search box uses, which is the
 * point of it being shared: `cafe` finds `Café` in both, and a reader who has
 * learned what one search box does has learned what the other does.
 */
function haystackOf(item: CommandItem): string {
  return searchHaystack([item.label, item.group, ...(item.keywords ?? [])]);
}

/**
 * `Mod+K` and its friends, as a predicate over a real keyboard event.
 *
 * The same vocabulary [Shortcut](../display/shortcut) draws, read rather than
 * written — a shortcut a component displays and a shortcut it binds must be
 * spelled the same way, or the label on the screen is a claim nobody checked.
 */
function pressed(event: KeyboardEvent, shortcut: string): boolean {
  const parts = shortcut.toLowerCase().split('+');
  const key = parts[parts.length - 1];
  const wanted = new Set(parts.slice(0, -1));
  const mac = /mac|iphone|ipad/i.test(
    typeof navigator === 'undefined' ? '' : navigator.platform || navigator.userAgent
  );

  const mod = mac ? event.metaKey : event.ctrlKey;

  if (wanted.has('mod') !== mod) return false;
  if (wanted.has('shift') !== event.shiftKey) return false;
  if (wanted.has('alt') !== event.altKey) return false;
  if (!wanted.has('mod') && wanted.has('ctrl') !== event.ctrlKey) return false;
  if (!wanted.has('mod') && wanted.has('meta') !== event.metaKey) return false;

  return event.key.toLowerCase() === key;
}

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
 * Base UI's Autocomplete owns the list — the highlight the pointer and the arrow
 * keys share, `aria-activedescendant`, Enter running the highlighted row — and
 * its Dialog owns the sheet, the scrim, the focus trap and returning the focus
 * to wherever the reader was.
 */
export function CommandPalette({
  items,
  open,
  defaultOpen = false,
  onOpenChange,
  onSelect,
  shortcut = 'Mod+K',
  width,
  maxHeight = 320,
  locale,
  placeholder,
  emptyMessage,
  label,
  size = 'md',
  color = 'primary',
  density = 'default'
}: CommandPaletteProps) {
  const messages = useMessages(commandMessages, locale);

  const [uncontrolled, setUncontrolled] = React.useState(defaultOpen);
  const [query, setQuery] = React.useState('');

  const showing = open ?? uncontrolled;

  const setOpen = React.useCallback(
    (next: boolean) => {
      if (open === undefined) setUncontrolled(next);
      onOpenChange?.(next);
    },
    [open, onOpenChange]
  );

  React.useEffect(() => {
    if (shortcut === false) return undefined;

    const onKeyDown = (event: KeyboardEvent) => {
      if (!pressed(event, shortcut)) return;

      // The browser's own Mod+K is a search bar in some of them, and the page
      // asked for this key.
      event.preventDefault();
      setOpen(true);
    };

    window.addEventListener('keydown', onKeyDown);

    return () => window.removeEventListener('keydown', onKeyDown);
    // `setOpen` is memoised on the pair that decides what it does, so this
    // rebinds when the palette opens and closes and at no other time.
  }, [shortcut, setOpen]);

  // Folded once per list rather than once per comparison — `searchText`
  // normalizes, and doing that inside the filter puts a `normalize` on every
  // command for every character typed.
  const haystacks = React.useMemo(() => items.map(haystackOf), [items]);

  const filtered = React.useMemo(() => {
    const needle = searchText(query);

    return needle === '' ? items : items.filter((_, index) => haystacks[index].includes(needle));
  }, [items, haystacks, query]);

  const run = (item: CommandItem) => {
    if (item.disabled) return;

    item.onSelect?.();
    onSelect?.(item);
    setOpen(false);
  };

  const sheetWidth = toLength(width);
  const listHeight = toLength(maxHeight);

  return (
    <BaseUIDialog.Root
      open={showing}
      onOpenChange={(next) => {
        // The query is dropped on the way out rather than on the way in, so the
        // sheet never flashes the last search as it fades.
        if (!next) setQuery('');
        setOpen(next);
      }}
    >
      <BaseUIDialog.Portal>
        <BaseUIDialog.Backdrop className={`neba-portal ${backdropClasses}`} />

        <BaseUIDialog.Viewport className="neba-portal fixed inset-0 z-50 flex justify-center p-4 pt-[12vh]">
          <BaseUIDialog.Popup
            aria-label={label ?? messages.label}
            className={cx(
              popupClasses,
              radiusClasses[size],
              controlTextLeadingClasses[size],
              sheetWidth === undefined ? widthClasses[size] : '',
              'self-start'
            )}
            style={{
              ...surfaceSlots(color, 3),
              ...(sheetWidth === undefined ? null : { maxWidth: sheetWidth })
            }}
          >
            <Autocomplete.Root
              open
              mode="list"
              // Already filtered here, so that a group heading can be drawn from
              // the same array the rows come out of.
              items={filtered}
              filter={null}
              value={query}
              onValueChange={(next) => setQuery(next)}
              itemToStringValue={(item: CommandItem) => item.label}
            >
              <div
                className={`flex shrink-0 items-center border-b [border-color:var(--n-line)] ${insetX[size]}`}
              >
                <Autocomplete.Input
                  autoFocus
                  placeholder={placeholder ?? messages.search}
                  className={[
                    'min-w-0 flex-1 bg-transparent [font:inherit] text-inherit [outline:none]',
                    'placeholder:text-(--neba-muted-fg) caret-(--n-accent)',
                    inputHeights[size]
                  ].join(' ')}
                />
              </div>

              <Autocomplete.List
                className="min-h-0 flex-1 overflow-y-auto overscroll-contain p-1"
                style={{ maxHeight: listHeight }}
              >
                {(item: CommandItem, index: number) => (
                  <React.Fragment key={item.value}>
                    {item.group && item.group !== filtered[index - 1]?.group ? (
                      <div
                        role="presentation"
                        className={`${insetX[size]} pt-2 pb-1 font-medium text-(--neba-muted-fg) ${metaTextClasses[size]}`}
                      >
                        {item.group}
                      </div>
                    ) : null}

                    <Autocomplete.Item
                      index={index}
                      value={item}
                      disabled={item.disabled}
                      onClick={() => run(item)}
                      className={[
                        rowClasses,
                        radiusClasses[size],
                        insetX[size],
                        rowPadY[density === 'compact' ? 'xs' : size]
                      ].join(' ')}
                    >
                      {hasContent(item.icon) ? (
                        <span className="flex h-[1lh] shrink-0 items-center [&_svg]:size-[1.15em]">
                          {item.icon}
                        </span>
                      ) : null}

                      <span className="flex min-w-0 flex-1 flex-col">
                        <span className="truncate">{item.label}</span>
                        {hasContent(item.description) ? (
                          <span
                            className={`truncate text-(--neba-muted-fg) ${metaTextClasses[size]}`}
                          >
                            {item.description}
                          </span>
                        ) : null}
                      </span>

                      {item.shortcut ? (
                        <Shortcut size="xs" keys={item.shortcut} className="shrink-0" />
                      ) : null}
                    </Autocomplete.Item>
                  </React.Fragment>
                )}
              </Autocomplete.List>

              <Autocomplete.Empty
                className={`${insetX[size]} py-6 text-center text-(--neba-muted-fg) ${metaTextClasses[size]}`}
              >
                {emptyMessage ?? messages.empty}
              </Autocomplete.Empty>
            </Autocomplete.Root>
          </BaseUIDialog.Popup>
        </BaseUIDialog.Viewport>
      </BaseUIDialog.Portal>
    </BaseUIDialog.Root>
  );
}

'use client';

import * as React from 'react';
import { Autocomplete } from '@base-ui/react/autocomplete';
import { Dialog as BaseUIDialog } from '@base-ui/react/dialog';
import { Shortcut } from '../shortcut/Shortcut.js';
import { useLayoutEffectOnClient } from '../../internal/layout-effect.js';
import { commandMessages, useMessages } from '../../internal/i18n.js';
import { searchHaystack, searchText } from '../../internal/search.js';
import {
  controlTextLeadingClasses,
  cx,
  hasContent,
  metaTextClasses,
  popupFadeClasses,
  radiusClasses,
  surfaceClasses,
  surfaceSlots,
  toLength
} from '../../internal/styles.js';
import type { NebaColor, NebaDensity, NebaSize } from '../../types.js';
import type { CommandItem, CommandPaletteProps } from './CommandPalette.js';

/** What the palette hands the sheet, with its defaults already settled. */
export interface CommandPaletteSheetProps extends Omit<
  CommandPaletteProps,
  'open' | 'defaultOpen' | 'onOpenChange' | 'shortcut' | 'size' | 'color' | 'density'
> {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  /** Whether the first open fades in. A palette open from the start never did. */
  fadeIn: boolean;
  size: NebaSize;
  color: NebaColor;
  density: NebaDensity;
}

/** A run of rows that share a group, in the order they were given. */
interface CommandGroup {
  key: string;
  value: string | undefined;
  items: CommandItem[];
}

const backdropClasses =
  'fixed inset-0 z-(--neba-z-portal) bg-(--neba-scrim) [backdrop-filter:blur(2px)] ' +
  popupFadeClasses;

const popupClasses =
  `${surfaceClasses} relative flex w-full flex-col overflow-hidden ` +
  'border text-(--neba-fg) bg-(--n-panel-press) [border-color:var(--n-line)] ' +
  '[box-shadow:var(--neba-shadow-3),var(--neba-plate-glass)] [outline:none] ' +
  popupFadeClasses;

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

const rowClasses =
  'flex cursor-pointer items-center gap-3 select-none ' +
  '[transition:background-color_var(--neba-duration)_var(--neba-ease)] ' +
  // The highlight is Base UI's, and it is one thing rather than two: the pointer
  // and the arrow keys move the same mark, so a reader never has to work out
  // which of two highlighted rows Enter would run.
  'data-[highlighted]:bg-(--n-soft) data-[highlighted]:text-(--n-on-tint) ' +
  'data-[disabled]:cursor-not-allowed data-[disabled]:text-(--neba-disabled-fg)';

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
 * The palette's sheet: the dialog, the field and the rows.
 *
 * A file of its own so that it can be fetched on its own. Base UI's Dialog and
 * Autocomplete are most of what a palette weighs, and a palette is shut until
 * a reader asks for it — see `CommandPalette` for when it is fetched and
 * mounted. Once mounted it stays, so the sheet can fade out as it closes.
 *
 * Base UI's Autocomplete owns the list — the highlight the pointer and the arrow
 * keys share, `aria-activedescendant`, Enter running the highlighted row — and
 * its Dialog owns the sheet, the scrim, the focus trap and returning the focus
 * to wherever the reader was.
 */
export function CommandPaletteSheet({
  items,
  open,
  onOpenChange,
  fadeIn,
  onSelect,
  width,
  maxHeight = 320,
  locale,
  placeholder,
  emptyMessage,
  label,
  size,
  color,
  density,
  className,
  classNames
}: CommandPaletteSheetProps) {
  const messages = useMessages(commandMessages, locale);
  const [query, setQuery] = React.useState('');

  /*
   * The sheet is mounted by the open that needs it, so its dialog would mount
   * already open, and Base UI plays no fade for a popup that does. So it
   * mounts shut and opens a layout effect later, before anything is painted,
   * and the first open fades in as every later one does.
   */
  const [shut, setShut] = React.useState(fadeIn);

  useLayoutEffectOnClient(() => {
    // Once, on mount: the dialog has been committed shut, and now it opens.
    setShut(false);
  }, []);

  // The query is dropped on the way out rather than on the way in, so the sheet
  // never flashes the last search as it opens. It is read off `open` during
  // render rather than off one close path, because there are three — Escape or
  // the scrim, a command that runs and closes it, and a controlled `open` the
  // caller turns off — and missing one opens the next search already filtered.
  const [wasOpen, setWasOpen] = React.useState(open);

  if (open !== wasOpen) {
    setWasOpen(open);
    if (!open) setQuery('');
  }

  // Folded once per list rather than once per comparison — `searchText`
  // normalizes, and doing that inside the filter puts a `normalize` on every
  // command for every character typed. And only while the palette is up: a
  // shut one has nothing typed into it, and a page that hands it a new list on
  // every navigation should not fold each of them for nothing.
  const haystacks = React.useMemo(() => (open ? items.map(haystackOf) : null), [items, open]);

  const filtered = React.useMemo(() => {
    if (haystacks === null) {
      return items;
    }

    const needle = searchText(query);

    return needle === '' ? items : items.filter((_, index) => haystacks[index].includes(needle));
  }, [items, haystacks, query]);

  /*
   * The rows as runs of one group each, which is the shape Base UI's own groups
   * take. A heading drawn between rows was a `presentation` div inside the
   * listbox, tied to nothing, so moving into a group never said which group it
   * was; a `Group` names its options by its label. A run with no group is still
   * a run, drawn without a label. `order` is each row's place in the whole
   * list, which is what the highlight moves through.
   */
  const { groups, order } = React.useMemo(() => {
    const runs: CommandGroup[] = [];
    const places = new Map<CommandItem, number>();

    filtered.forEach((item, index) => {
      places.set(item, index);
      const last = runs[runs.length - 1];

      if (last && last.value === item.group) {
        last.items.push(item);
      } else {
        runs.push({ key: `${runs.length}:${item.group ?? ''}`, value: item.group, items: [item] });
      }
    });

    return { groups: runs, order: places };
  }, [filtered]);

  const run = (item: CommandItem) => {
    if (item.disabled) return;

    item.onSelect?.();
    onSelect?.(item);
    onOpenChange(false);
  };

  const sheetWidth = toLength(width);
  const listHeight = toLength(maxHeight);

  return (
    <BaseUIDialog.Root open={open && !shut} onOpenChange={onOpenChange}>
      <BaseUIDialog.Portal>
        <BaseUIDialog.Backdrop
          className={cx('neba-portal', backdropClasses, classNames?.backdrop)}
        />

        <BaseUIDialog.Viewport
          className={cx(
            'neba-portal fixed inset-0 z-(--neba-z-portal) flex justify-center p-4 pt-[12vh]',
            classNames?.viewport
          )}
        >
          <BaseUIDialog.Popup
            aria-label={label ?? messages.label}
            className={cx(
              popupClasses,
              radiusClasses[size],
              controlTextLeadingClasses[size],
              sheetWidth === undefined ? widthClasses[size] : '',
              'self-start',
              className
            )}
            style={{
              ...surfaceSlots(color, 3),
              ...(sheetWidth === undefined ? null : { maxWidth: sheetWidth })
            }}
          >
            <Autocomplete.Root
              open
              mode="list"
              // Already filtered here, so that the groups can be built from the
              // same array the rows come out of.
              items={groups}
              filter={null}
              value={query}
              onValueChange={(next) => setQuery(next)}
              // The list is held open, so it is the one that hears Escape, and
              // it keeps the key from the dialog around it — which then never
              // closed. What the list would have done is what the palette does.
              onOpenChange={(next, details) => {
                if (!next && details.reason === 'escape-key') onOpenChange(false);
              }}
              itemToStringValue={(item: CommandItem) => item.label}
            >
              <div
                className={`flex shrink-0 items-center border-b [border-color:var(--n-line)] ${insetX[size]}`}
              >
                <Autocomplete.Input
                  autoFocus
                  placeholder={placeholder ?? messages.search}
                  className={cx(
                    'neba-input min-w-0 flex-1 bg-transparent [font:inherit] text-inherit [outline:none]',
                    'placeholder:text-(--neba-muted-fg) caret-(--n-accent)',
                    inputHeights[size],
                    classNames?.input
                  )}
                />
              </div>

              <Autocomplete.List
                className={cx(
                  'min-h-0 flex-1 overflow-y-auto overscroll-contain p-1',
                  classNames?.list
                )}
                style={{ maxHeight: listHeight }}
              >
                {(group: CommandGroup) => (
                  <Autocomplete.Group key={group.key} items={group.items}>
                    {group.value ? (
                      <Autocomplete.GroupLabel
                        className={cx(
                          insetX[size],
                          'pt-2 pb-1 font-medium text-(--neba-muted-fg)',
                          metaTextClasses[size],
                          classNames?.group
                        )}
                      >
                        {group.value}
                      </Autocomplete.GroupLabel>
                    ) : null}

                    <Autocomplete.Collection>
                      {(item: CommandItem) => (
                        <Autocomplete.Item
                          key={item.value}
                          index={order.get(item)}
                          value={item}
                          disabled={item.disabled}
                          onClick={() => run(item)}
                          className={cx(
                            rowClasses,
                            radiusClasses[size],
                            insetX[size],
                            rowPadY[density === 'compact' ? 'xs' : size],
                            classNames?.item
                          )}
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
                      )}
                    </Autocomplete.Collection>
                  </Autocomplete.Group>
                )}
              </Autocomplete.List>

              <Autocomplete.Empty
                className={cx(
                  insetX[size],
                  'py-6 text-center text-(--neba-muted-fg)',
                  metaTextClasses[size],
                  classNames?.empty
                )}
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

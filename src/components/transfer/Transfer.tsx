'use client';

import * as React from 'react';
import { Checkbox } from '../checkbox/Checkbox.js';
import { IconButton } from '../icon-button/IconButton.js';
import { ScrollArea } from '../scroll-area/ScrollArea.js';
import { TextField } from '../text-field/TextField.js';
import { transferMessages, useMessages } from '../../internal/i18n.js';
import { ArrowRightIcon } from '../../internal/icons.js';
import { searchText } from '../../internal/search.js';
import {
  cx,
  fieldRestClasses,
  hasContent,
  metaTextClasses,
  paddingXClasses,
  radiusClasses,
  surfaceSlots,
  toLength
} from '../../internal/styles.js';
import type { NebaSize, NebaStyleProps } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/** One thing that can be on either side. */
export interface TransferItem {
  /** What identifies it, and what `value` is a list of. */
  value: string;
  /** What the row says. */
  label: React.ReactNode;
  /** In the list but not movable. */
  disabled?: boolean;
}

export interface TransferProps
  extends
    NebaStyleProps,
    Omit<React.ComponentPropsWithoutRef<'div'>, 'color' | 'defaultValue' | 'onChange'> {
  /** Everything that can be on either side, in the order the lists show it. */
  items: readonly TransferItem[];
  /** What is on the right. Use with `onValueChange` for a controlled pair. */
  value?: readonly string[];
  /** What starts on the right, for an uncontrolled one. */
  defaultValue?: readonly string[];
  onValueChange?: (value: string[]) => void;
  /** The heading over the left-hand list. Defaults to the `locale`'s word. */
  sourceLabel?: React.ReactNode;
  /** And over the right-hand one. */
  targetLabel?: React.ReactNode;
  /** Puts a filter above each list. @default false */
  searchable?: boolean;
  /** How tall each list is. A number of pixels or any CSS length. @default 220 */
  height?: number | string;
  /** Nothing can be ticked or moved. */
  disabled?: boolean;
  /**
   * Which language the headings, the buttons and the filter are written in — a
   * BCP 47 tag such as `ko`, `pt-BR` or `zh-Hant`. Unsupported tags fall back
   * to English.
   */
  locale?: string;
}

/** The heading strip over each list. */
const headerClasses = 'flex items-center gap-2 border-b [border-color:var(--neba-border)]';

const panelPadY: Record<NebaSize, string> = {
  xs: 'py-1',
  sm: 'py-1.5',
  md: 'py-2',
  lg: 'py-2.5',
  xl: 'py-3'
};

const rowPadY: Record<NebaSize, string> = {
  xs: 'py-0.5',
  sm: 'py-1',
  md: 'py-1',
  lg: 'py-1.5',
  xl: 'py-2'
};

/**
 * A row that has just been sent here.
 *
 * A press on the arrow took three rows off one list and put them in the other,
 * and both lists redrew in a single frame — so the only way to find out where
 * they went was to read the whole panel again. They fade up now, at the pace a
 * picture arrives rather than the pace a control answers a pointer, because
 * what is being said is "these are the ones that moved" and not "this one is
 * hovered".
 *
 * Keyed on the press rather than on the rows changing, which is the load-bearing
 * part: `rows` also changes on every keystroke in the search box, and a filter
 * that animates is a filter that feels slow. Typing narrows the list instantly,
 * exactly as it did.
 *
 * An `animation` rather than a transition, because there is no previous frame —
 * the row did not exist on this side until now.
 */
const arrivedClasses = '[animation:neba-anim-fade_var(--neba-duration-fill)_var(--neba-ease)_both]';

/** What a caller sees of one side, so the two panels are literally one function. */
interface PanelProps {
  title: React.ReactNode;
  rows: readonly TransferItem[];
  /** The rows that arrived on this side on the last press, and nothing else. */
  arrived: ReadonlySet<string>;
  ticked: ReadonlySet<string>;
  onTick: (value: string, ticked: boolean) => void;
  onTickAll: (ticked: boolean) => void;
  search: string;
  onSearch: (search: string) => void;
  searchable: boolean;
  disabled: boolean;
  height: string | undefined;
  emptyMessage: string;
  searchLabel: string;
  selectAllLabel: string;
  style: NebaStyleProps & { size: NebaSize };
}

function Panel({
  title,
  rows,
  arrived,
  ticked,
  onTick,
  onTickAll,
  search,
  onSearch,
  searchable,
  disabled,
  height,
  emptyMessage,
  searchLabel,
  selectAllLabel,
  style
}: PanelProps) {
  const { size, variant = 'outline', color = 'primary', density = 'default' } = style;
  const movable = rows.filter((row) => !row.disabled);
  const tickedHere = movable.filter((row) => ticked.has(row.value));
  const all = movable.length > 0 && tickedHere.length === movable.length;
  const some = tickedHere.length > 0 && !all;
  const insetX = paddingXClasses[density][size];

  return (
    <div
      className={[
        'flex min-w-0 flex-col overflow-hidden',
        fieldRestClasses[variant],
        radiusClasses[size]
      ].join(' ')}
      style={surfaceSlots(color, 0)}
    >
      <div className={`${headerClasses} ${insetX} ${panelPadY[size]}`}>
        <Checkbox
          size={size}
          color={color}
          checked={all}
          indeterminate={some}
          disabled={disabled || movable.length === 0}
          aria-label={selectAllLabel}
          onCheckedChange={(next) => onTickAll(next === true)}
        />
        <span className={`min-w-0 flex-1 truncate font-medium ${metaTextClasses[size]}`}>
          {title}
        </span>
        <span className={`shrink-0 tabular-nums text-(--neba-muted-fg) ${metaTextClasses[size]}`}>
          {tickedHere.length}/{rows.length}
        </span>
      </div>

      {searchable ? (
        <div className={`${insetX} ${panelPadY[size]}`}>
          <TextField
            size={size}
            color={color}
            density={density}
            fullWidth
            variant="text"
            disabled={disabled}
            placeholder={searchLabel}
            aria-label={searchLabel}
            value={search}
            onChange={(event) => onSearch(event.target.value)}
          />
        </div>
      ) : null}

      <ScrollArea size={size} color={color} height={height} fade>
        <div className={`flex flex-col ${insetX} ${panelPadY[size]}`}>
          {rows.length === 0 ? (
            <span className={`text-(--neba-muted-fg) ${metaTextClasses[size]} ${rowPadY[size]}`}>
              {emptyMessage}
            </span>
          ) : (
            rows.map((row) => (
              <Checkbox
                key={row.value}
                size={size}
                color={color}
                className={cx(rowPadY[size], arrived.has(row.value) ? arrivedClasses : '')}
                label={row.label}
                checked={ticked.has(row.value)}
                disabled={disabled || row.disabled}
                onCheckedChange={(next) => onTick(row.value, next === true)}
              />
            ))
          )}
        </div>
      </ScrollArea>
    </div>
  );
}

/**
 * Every row's label, folded once, keyed by the row it belongs to.
 *
 * The fold is `searchText`, the same one a DataTable and a CommandPalette use,
 * so `cafe` finds `Café` on all three. What is not the same is when it runs:
 * `normalize` is the expensive call in there, and folding inside the filter put
 * one on every row of both lists for every character typed. Built once per
 * `items` instead, which is the shape `internal/search.ts` exists to make
 * possible.
 *
 * A label that is a node rather than a string has no text to match and is left
 * out of the map: a row with no entry stays, because the alternative is a row
 * that disappears from a filter it could never satisfy.
 */
function haystacksOf(items: readonly TransferItem[]): Map<string, string> {
  const folded = new Map<string, string>();

  for (const item of items) {
    if (typeof item.label === 'string') {
      folded.set(item.value, searchText(item.label));
    }
  }

  return folded;
}

/** One side's rows, narrowed by what was typed at that side's box. */
function narrow(
  rows: readonly TransferItem[],
  query: string,
  haystacks: Map<string, string>
): readonly TransferItem[] {
  const needle = searchText(query);

  if (needle === '') return rows;

  return rows.filter((item) => {
    const haystack = haystacks.get(item.value);

    return haystack === undefined || haystack.includes(needle);
  });
}

/**
 * Two lists and the arrows between them: everything that could be chosen on one
 * side, everything that has been on the other.
 *
 * It is the shape for a choice that is *long* — the columns in a report, the
 * permissions on a role, the people on a channel — where a
 * [Combobox](./combobox) with forty chips in its field stops being readable and
 * a list of forty checkboxes gives no answer to "what did I actually pick".
 * Below about a dozen options, one of those two is the smaller component.
 *
 * The order of `items` is the order both lists show, so a row does not move when
 * it is sent across and back. What ticks are for is choosing which rows to move;
 * `value` is which side they are on, and the two are deliberately separate —
 * ticking is not choosing.
 */
export const Transfer = React.forwardRef<HTMLDivElement, TransferProps>(
  function Transfer(rawProps, ref) {
    const {
      items,
      value,
      defaultValue,
      onValueChange,
      sourceLabel,
      targetLabel,
      searchable = false,
      height = 220,
      disabled = false,
      locale,
      variant = 'outline',
      size = 'md',
      color = 'primary',
      density = 'default',
      className,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density', 'variant', 'locale']);

    const messages = useMessages(transferMessages, locale);

    const [uncontrolled, setUncontrolled] = React.useState<readonly string[]>(defaultValue ?? []);
    const selected = value ?? uncontrolled;

    const [ticked, setTicked] = React.useState<ReadonlySet<string>>(() => new Set());
    /** What the last press moved, so the side it landed on can say which. */
    const [arrived, setArrived] = React.useState<ReadonlySet<string>>(() => new Set());
    const [sourceSearch, setSourceSearch] = React.useState('');
    const [targetSearch, setTargetSearch] = React.useState('');

    const chosen = React.useMemo(() => new Set(selected), [selected]);
    const source = React.useMemo(
      () => items.filter((item) => !chosen.has(item.value)),
      [items, chosen]
    );
    const target = React.useMemo(
      () => items.filter((item) => chosen.has(item.value)),
      [items, chosen]
    );

    const commit = (next: string[]) => {
      if (value === undefined) setUncontrolled(next);
      onValueChange?.(next);
    };

    const tick = (item: string, on: boolean) => {
      setTicked((current) => {
        const next = new Set(current);

        if (on) next.add(item);
        else next.delete(item);

        return next;
      });
    };

    const tickAll = (rows: readonly TransferItem[], on: boolean) => {
      setTicked((current) => {
        const next = new Set(current);

        for (const row of rows) {
          if (row.disabled) continue;
          if (on) next.add(row.value);
          else next.delete(row.value);
        }

        return next;
      });
    };

    /**
     * Moving drops the ticks on what moved and keeps the rest. A row that has
     * arrived on the other side is not still waiting to be sent there, and a row
     * the filter was hiding was never part of this press.
     */
    const move = (moving: readonly TransferItem[], toTarget: boolean) => {
      const moved = moving.filter((item) => !item.disabled && ticked.has(item.value));

      if (moved.length === 0) return;

      const ids = new Set(moved.map((item) => item.value));
      const next = toTarget
        ? items.filter((item) => chosen.has(item.value) || ids.has(item.value)).map((i) => i.value)
        : selected.filter((item) => !ids.has(item));

      setTicked((current) => new Set([...current].filter((item) => !ids.has(item))));
      setArrived(ids);
      commit(next);
    };

    const haystacks = React.useMemo(() => haystacksOf(items), [items]);
    const sourceRows = React.useMemo(
      () => narrow(source, sourceSearch, haystacks),
      [source, sourceSearch, haystacks]
    );
    const targetRows = React.useMemo(
      () => narrow(target, targetSearch, haystacks),
      [target, targetSearch, haystacks]
    );
    const canSend = sourceRows.some((item) => !item.disabled && ticked.has(item.value));
    const canReturn = targetRows.some((item) => !item.disabled && ticked.has(item.value));
    const listHeight = toLength(height);

    const panelStyle = { variant, size, color, density };

    return (
      <div
        ref={ref}
        className={cx(
          'grid w-full items-center gap-3',
          '[grid-template-columns:minmax(0,1fr)_auto_minmax(0,1fr)]',
          className ?? ''
        )}
        {...props}
      >
        <Panel
          title={hasContent(sourceLabel) ? sourceLabel : messages.source}
          rows={sourceRows}
          arrived={arrived}
          ticked={ticked}
          onTick={tick}
          onTickAll={(on) => tickAll(sourceRows, on)}
          search={sourceSearch}
          onSearch={setSourceSearch}
          searchable={searchable}
          disabled={disabled}
          height={listHeight}
          emptyMessage={messages.empty}
          searchLabel={messages.search}
          selectAllLabel={messages.selectAll}
          style={panelStyle}
        />

        <div className="flex flex-col gap-2">
          <IconButton
            size={size}
            color={color}
            variant={variant === 'text' ? 'text' : 'outline'}
            label={messages.toTarget}
            disabled={disabled || !canSend}
            onClick={() => move(sourceRows, true)}
            icon={<ArrowRightIcon />}
          />
          <IconButton
            size={size}
            color={color}
            variant={variant === 'text' ? 'text' : 'outline'}
            label={messages.toSource}
            disabled={disabled || !canReturn}
            onClick={() => move(targetRows, false)}
            // The same glyph turned, which is the one allowance the no-transform
            // rule makes — and it is logical, so under RTL the arrows already
            // point the way the lists are laid out.
            icon={<span className="flex rotate-180">{<ArrowRightIcon />}</span>}
          />
        </div>

        <Panel
          title={hasContent(targetLabel) ? targetLabel : messages.target}
          rows={targetRows}
          arrived={arrived}
          ticked={ticked}
          onTick={tick}
          onTickAll={(on) => tickAll(targetRows, on)}
          search={targetSearch}
          onSearch={setTargetSearch}
          searchable={searchable}
          disabled={disabled}
          height={listHeight}
          emptyMessage={messages.empty}
          searchLabel={messages.search}
          selectAllLabel={messages.selectAll}
          style={panelStyle}
        />
      </div>
    );
  }
);

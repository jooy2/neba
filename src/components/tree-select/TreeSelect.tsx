'use client';

import * as React from 'react';
import { TreeItem, TreeView, type TreeViewValue } from '../tree-view/TreeView.js';
import { PickerShell, type PickerShellProps } from '../../internal/picker.js';
import { searchHaystack, searchText } from '../../internal/search.js';
import {
  actionMessages,
  commandMessages,
  comboboxMessages,
  useMessages
} from '../../internal/i18n.js';
import type { NebaSlots } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/** One node of the tree the reader is choosing from. */
export interface TreeSelectItem {
  /** What is stored when this node is chosen. Unique across the whole tree. */
  value: TreeViewValue;
  label: React.ReactNode;
  /** What a search matches against. Falls back to `label` when it is a string. */
  searchLabel?: string;
  startIcon?: React.ReactNode;
  disabled?: boolean;
  /**
   * Whether this node may itself be chosen.
   *
   * `false` makes it a heading with children under it — a "Europe" that groups
   * countries without being one. Defaults to `true` for a leaf and follows
   * `selectableBranches` for a node that has children.
   */
  selectable?: boolean;
  children?: TreeSelectItem[];
}

/** The parts a TreeSelect draws behind its root. */
export type TreeSelectSlot = 'popup' | 'tree' | 'item' | 'empty';

export interface TreeSelectProps extends PickerShellProps {
  /** The tree, as nested items. */
  items?: TreeSelectItem[];
  /** The chosen value, or values when `multiple`. */
  value?: TreeViewValue | TreeViewValue[] | null;
  defaultValue?: TreeViewValue | TreeViewValue[] | null;
  onValueChange?: (value: TreeViewValue[]) => void;
  /** Whether more than one node may be held. @default false */
  multiple?: boolean;
  /**
   * Whether a node that has children may itself be chosen.
   *
   * Off by default, which is the shape most trees actually have: the branches
   * are the taxonomy and the leaves are the answers. An item's own
   * `selectable` overrides it either way.
   * @default false
   */
  selectableBranches?: boolean;
  /** Which branches start open. */
  defaultExpanded?: TreeViewValue[];
  expanded?: TreeViewValue[];
  onExpandedChange?: (expanded: TreeViewValue[]) => void;
  /** Whether the popup is open. Use with `onOpenChange` to control it. */
  open?: boolean;
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** Shown in the trigger while nothing is chosen. */
  placeholder?: React.ReactNode;
  /** Offers the × that empties the control. @default false */
  clearable?: boolean;
  /** Accessible name of the clear button. Defaults to the `locale`'s word. */
  clearLabel?: string;
  /** Closes the popup as soon as a node is chosen. @default !multiple */
  closeOnSelect?: boolean;
  /**
   * Offers a field above the tree that filters it.
   *
   * A match keeps its ancestors, because a node with its parents cut away is a
   * node the reader cannot place — "Seoul" under nothing at all.
   * @default false
   */
  searchable?: boolean;
  searchPlaceholder?: string;
  /** BCP 47 tag deciding the strings this draws on its own behalf. */
  locale?: string;
  /** How the trigger writes what is held. Defaults to the labels, comma-joined. */
  format?: (chosen: TreeSelectItem[]) => React.ReactNode;
  /** Identifies the field when a form is submitted. One input per value. */
  name?: string;
  classNames?: NebaSlots<TreeSelectSlot>;
}

/** Every node, flattened, so a value can be looked up without walking twice. */
function flatten(items: TreeSelectItem[], into: Map<TreeViewValue, TreeSelectItem> = new Map()) {
  for (const item of items) {
    into.set(item.value, item);
    if (item.children) {
      flatten(item.children, into);
    }
  }
  return into;
}

/**
 * What every node is matched against, folded once for the whole tree.
 *
 * Once per `items` rather than once per keystroke: `normalize` is the expensive
 * call inside `searchHaystack`, and folding it inside the filter put one on
 * every node of the tree for every character typed. This is the arrangement
 * `internal/search.ts` exists to make possible, and the one a DataTable and a
 * CommandPalette already use.
 */
function haystacksOf(
  items: TreeSelectItem[],
  into: Map<TreeSelectItem, string> = new Map()
): Map<TreeSelectItem, string> {
  for (const item of items) {
    into.set(
      item,
      searchHaystack([
        item.searchLabel ?? (typeof item.label === 'string' ? item.label : String(item.value))
      ])
    );

    if (item.children) {
      haystacksOf(item.children, into);
    }
  }

  return into;
}

/**
 * Keeps the nodes that match, and every ancestor of one.
 *
 * The ancestors are the point. A tree filtered to bare matches is a list, and a
 * list of leaves is exactly what a tree was chosen over — "Seoul" with nothing
 * above it does not say which Seoul, or which taxonomy it came from.
 */
function filterTree(
  items: TreeSelectItem[],
  needle: string,
  haystacks: Map<TreeSelectItem, string>
): TreeSelectItem[] {
  if (needle === '') {
    return items;
  }

  const kept: TreeSelectItem[] = [];

  for (const item of items) {
    const children = item.children ? filterTree(item.children, needle, haystacks) : undefined;
    const hit = (haystacks.get(item) ?? '').includes(needle);

    if (hit || (children && children.length > 0)) {
      kept.push({ ...item, children: hit ? item.children : children });
    }
  }

  return kept;
}

/** Every branch value in a tree — what a search opens so its matches are visible. */
function branchValues(items: TreeSelectItem[], into: TreeViewValue[] = []): TreeViewValue[] {
  for (const item of items) {
    if (item.children && item.children.length > 0) {
      into.push(item.value);
      branchValues(item.children, into);
    }
  }
  return into;
}

/**
 * A value chosen from a tree rather than from a list.
 *
 * The gap between [Select](./select) and [TreeView](../display/tree-view): the
 * first is a flat list behind a field, the second is a hierarchy that shows
 * what it holds but has no field. A category, a folder, an org chart node and a
 * region are all chosen from a shape a flat list flattens away.
 *
 * `selectableBranches` is off by default because that is the shape most of
 * these trees have — the branches are the taxonomy and the leaves are the
 * answers, and a "Europe" that can be chosen alongside "France" is usually a
 * data model nobody meant. An item's own `selectable` overrides it either way.
 */
export const TreeSelect = React.forwardRef<HTMLButtonElement, TreeSelectProps>(
  function TreeSelect(rawProps, ref) {
    const {
      items = [],
      value: valueProp,
      defaultValue,
      onValueChange,
      multiple = false,
      selectableBranches = false,
      defaultExpanded,
      expanded: expandedProp,
      onExpandedChange,
      open: openProp,
      defaultOpen,
      onOpenChange,
      placeholder,
      clearable = false,
      clearLabel,
      closeOnSelect,
      searchable = false,
      searchPlaceholder,
      locale,
      format,
      name,
      size = 'md',
      color = 'primary',
      readOnly = false,
      disabled = false,
      classNames,
      ...shell
    } = useStyleDefaults(rawProps, ['size', 'locale']);

    const messages = useMessages(comboboxMessages, locale);
    // The word on a field somebody types a filter into is already written down
    // once, for CommandPalette. One more spelling of "Search" is one more thing
    // to translate and one more chance for the two to disagree.
    const searchMessages = useMessages(commandMessages, locale);
    const actions = useMessages(actionMessages, locale);

    const asArray = (next: TreeViewValue | TreeViewValue[] | null | undefined): TreeViewValue[] =>
      next === null || next === undefined ? [] : Array.isArray(next) ? next : [next];

    const [uncontrolledValue, setUncontrolledValue] = React.useState(() => asArray(defaultValue));
    const held = valueProp !== undefined ? asArray(valueProp) : uncontrolledValue;

    const [uncontrolledOpen, setUncontrolledOpen] = React.useState(defaultOpen ?? false);
    const open = openProp ?? uncontrolledOpen;

    const [query, setQuery] = React.useState('');

    const byValue = React.useMemo(() => flatten(items), [items]);
    const haystacks = React.useMemo(() => haystacksOf(items), [items]);
    const needle = searchText(query);
    const shown = React.useMemo(
      () => filterTree(items, needle, haystacks),
      [items, needle, haystacks]
    );

    // A search opens every branch it kept: a match folded inside a closed
    // parent is a match the reader was not shown.
    const searchExpanded = React.useMemo(
      () => (needle === '' ? undefined : branchValues(shown)),
      [needle, shown]
    );

    const [uncontrolledExpanded, setUncontrolledExpanded] = React.useState(
      () => defaultExpanded ?? []
    );
    const expanded = searchExpanded ?? expandedProp ?? uncontrolledExpanded;

    const setOpen = (next: boolean) => {
      // A read-only picker does not open. What it holds is something to read.
      if (next && (readOnly || disabled)) {
        return;
      }
      if (openProp === undefined) {
        setUncontrolledOpen(next);
      }
      if (!next) {
        setQuery('');
      }
      onOpenChange?.(next);
    };

    const commit = (next: TreeViewValue[]) => {
      if (valueProp === undefined) {
        setUncontrolledValue(next);
      }
      onValueChange?.(next);
    };

    const isSelectable = (item: TreeSelectItem) =>
      item.selectable ?? (item.children && item.children.length > 0 ? selectableBranches : true);

    const onSelectedChange = (next: TreeViewValue[]) => {
      // A branch that cannot be chosen still expands and collapses, so what
      // comes back has to be filtered rather than trusted.
      const allowed = next.filter((entry) => {
        const item = byValue.get(entry);
        return item !== undefined && isSelectable(item) && !item.disabled;
      });

      commit(multiple ? allowed : allowed.slice(-1));

      if (closeOnSelect ?? !multiple) {
        setOpen(false);
      }
    };

    const chosen = held
      .map((entry) => byValue.get(entry))
      .filter((item): item is TreeSelectItem => item !== undefined);

    const display =
      chosen.length === 0
        ? (placeholder ?? '')
        : format
          ? format(chosen)
          : chosen
              .map((item) => item.label)
              .reduce<React.ReactNode[]>(
                (all, label, index) => (index === 0 ? [label] : [...all, ', ', label]),
                []
              );

    const renderItems = (list: TreeSelectItem[]): React.ReactNode =>
      list.map((item) => (
        <TreeItem
          key={item.value}
          value={item.value}
          label={item.label}
          startIcon={item.startIcon}
          disabled={item.disabled || !isSelectable(item)}
          className={classNames?.item}
        >
          {item.children ? renderItems(item.children) : null}
        </TreeItem>
      ));

    return (
      <PickerShell
        {...shell}
        size={size}
        color={color}
        readOnly={readOnly}
        disabled={disabled}
        triggerRef={ref}
        display={display}
        empty={chosen.length === 0}
        clearable={clearable}
        onClear={() => commit([])}
        open={open}
        onOpenChange={setOpen}
        clearLabel={clearLabel ?? actions.clear}
        popupClassName={classNames?.popup}
        hiddenValues={name ? held.map((entry) => ({ name, value: String(entry) })) : undefined}
      >
        <div className="flex max-h-80 w-64 flex-col gap-2 overflow-hidden">
          {searchable ? (
            <input
              type="text"
              value={query}
              placeholder={searchPlaceholder ?? searchMessages.search}
              aria-label={searchPlaceholder ?? searchMessages.search}
              onChange={(event) => setQuery(event.currentTarget.value)}
              className="w-full shrink-0 bg-transparent px-1 py-1 [font:inherit] text-(--neba-fg) [outline:none] placeholder:text-(--neba-muted-fg)"
            />
          ) : null}

          <div className="min-h-0 flex-1 overflow-auto">
            {shown.length === 0 ? (
              <p className={`px-1 py-2 text-(--neba-muted-fg) ${classNames?.empty ?? ''}`}>
                {messages.empty}
              </p>
            ) : (
              <TreeView
                size={size}
                color={color}
                multiple={multiple}
                selected={held}
                onSelectedChange={onSelectedChange}
                expanded={expanded}
                onExpandedChange={
                  searchExpanded
                    ? () => {}
                    : (next) => {
                        if (expandedProp === undefined) {
                          setUncontrolledExpanded(next);
                        }
                        onExpandedChange?.(next);
                      }
                }
                className={classNames?.tree}
              >
                {renderItems(shown)}
              </TreeView>
            )}
          </div>
        </div>
      </PickerShell>
    );
  }
);

'use client';

import * as React from 'react';
import { ChevronIcon } from '../../internal/icons.js';
import {
  controlTextClasses,
  cx,
  gapClasses,
  hasContent,
  iconClasses,
  radiusClasses,
  surfaceClasses,
  surfaceSlots,
  transitionClasses
} from '../../internal/styles.js';
import type { NebaDensity, NebaElevation, NebaSize, NebaStyleProps } from '../../types.js';
import { useStyleDefaults } from '../../internal/defaults.js';

/**
 * How the hierarchy is drawn.
 *
 * - `none` — indentation only. The quietest, and usually right for a navigation
 *   sidebar, where the tree is two levels deep and the labels say what the
 *   structure is.
 * - `simple` — one hairline rail per level, running the full height of the
 *   group. Enough to follow a column of rows back to the branch it belongs to.
 * - `folder` — the rail plus an elbow into every row, and the rail under a last
 *   child stops at that row. The file-manager drawing, and the one to reach for
 *   when the tree is deep.
 */
export type TreeViewLines = 'none' | 'simple' | 'folder';

/** A row's identity, and what `expanded` and `selected` are lists of. */
export type TreeViewValue = string | number;

/**
 * What a TreeItem inherits from the TreeView around it.
 *
 * The same arrangement List and Accordion use, and for one more reason than
 * they have: a tree is one widget with one tab stop, so which branch is open,
 * which row is chosen and which row the tab key lands on are all properties of
 * the tree rather than of any row in it. A row that owned its own open state
 * could not be shut by pressing ArrowLeft on the row below it.
 */
interface TreeViewContextValue {
  size: NebaSize;
  density: NebaDensity;
  disabled: boolean;
  expandedKeys: ReadonlySet<string>;
  selectedKeys: ReadonlySet<string>;
  activeKey: string | null;
  toggle: (value: TreeViewValue) => void;
  select: (value: TreeViewValue) => void;
  activate: (key: string) => void;
  register: (key: string, api: TreeItemApi) => () => void;
}

/**
 * The one thing a row can do that the tree cannot reach through the DOM.
 *
 * ArrowRight opens a branch *without* choosing it — that is the difference
 * between walking a tree and picking things out of it — so the tree cannot get
 * there by pressing the row, which does both. All it has from a DOM node is the
 * key on it, and a key is not the `value` the caller passed: `2` and `'2'` are
 * the same string and different values. So each row leaves its own opener here,
 * closed over the value it actually holds.
 */
interface TreeItemApi {
  toggle: () => void;
}

const TreeViewContext = React.createContext<TreeViewContextValue>({
  size: 'md',
  density: 'default',
  disabled: false,
  expandedKeys: new Set(),
  selectedKeys: new Set(),
  activeKey: null,
  toggle: () => {},
  select: () => {},
  activate: () => {},
  register: () => () => {}
});

/**
 * Whether a row is inside a branch that is on its way shut.
 *
 * A branch has to stay in the document while it collapses or there is nothing
 * left to collapse, and for those 160ms its rows are visible but no longer
 * *there*. This is how they know: a row that reads `true` does not register
 * itself with the tree, so the tree's answer to "is the row holding the tab
 * stop still on screen" turns over on the same render that shut the branch
 * rather than a sixth of a second later. `treeRows` is the other half — the
 * `data-closing` attribute keeps the same rows out of the order the arrow keys
 * walk.
 */
const TreeClosingContext = React.createContext(false);

export interface TreeViewProps
  extends
    NebaStyleProps,
    Omit<React.ComponentPropsWithoutRef<'ul'>, 'color' | 'defaultValue' | 'onSelect'> {
  /**
   * Drop shadow depth. `0` (the default) is flat.
   * @default 0
   */
  elevation?: NebaElevation;
  /**
   * How the hierarchy is drawn between the rows.
   * @default 'simple'
   */
  lines?: TreeViewLines;
  /** Which branches are open. Use with `onExpandedChange` for a controlled tree. */
  expanded?: TreeViewValue[];
  /** Which start open, for an uncontrolled one. */
  defaultExpanded?: TreeViewValue[];
  onExpandedChange?: (expanded: TreeViewValue[]) => void;
  /**
   * Which rows are chosen. An array even when only one row may be chosen at a
   * time — the same shape Accordion's `value` takes, so turning `multiple` on
   * does not also change the type of the value.
   */
  selected?: TreeViewValue[];
  /** Which start chosen, for an uncontrolled one. */
  defaultSelected?: TreeViewValue[];
  onSelectedChange?: (selected: TreeViewValue[]) => void;
  /**
   * Whether more than one row may be chosen at a time.
   * @default false
   */
  multiple?: boolean;
  /** Unavailable. Every row stops answering. */
  disabled?: boolean;
  /** The name the tree is announced by. */
  label?: string;
  /** The top-level TreeItems. */
  children?: React.ReactNode;
}

export interface TreeItemProps extends Omit<
  React.ComponentPropsWithoutRef<'li'>,
  'color' | 'onClick'
> {
  /**
   * Identifies the row to `expanded` and `selected`. One is generated when it is
   * left out, which is fine for a tree nobody drives from code.
   */
  value?: TreeViewValue;
  /**
   * The row's text. Its own prop rather than `children`, because in a tree the
   * children are the rows underneath it.
   */
  label?: React.ReactNode;
  /** Content before the label — a folder glyph, a file type, a status dot. */
  startIcon?: React.ReactNode;
  /** Content after the label, inside the pressable area — a count, a badge. */
  endIcon?: React.ReactNode;
  /**
   * A control pinned to the end of the row.
   *
   * Deliberately outside the pressable area, the same shape ListItem uses: a
   * row that both opens and holds a menu button has two things to press.
   */
  action?: React.ReactNode;
  /** Renders the row as a link, for a tree that is navigation. */
  href?: string;
  /** Fires when the row is pressed, before it opens or is chosen. */
  onClick?: React.MouseEventHandler<HTMLElement>;
  /**
   * Forces the disclosure arrow onto a row with no children yet — the branch
   * that is fetched the first time it is opened.
   */
  expandable?: boolean;
  /** Unavailable. Its branch, if it is open, keeps working. */
  disabled?: boolean;
  /** The rows underneath this one. */
  children?: React.ReactNode;
}

/**
 * The three weights, said the way a *container* says them — the sheet is never
 * dyed, exactly as on Box, List and Accordion. A tree holds other people's
 * labels, and they arrive with their own colours.
 *
 * `text` is the one to reach for in a sidebar: the sidebar is already a surface,
 * and a second bordered rectangle inside it is a second rectangle.
 */
const variantClasses: Record<NonNullable<NebaStyleProps['variant']>, string> = {
  solid: [
    surfaceClasses,
    'text-(--neba-fg) bg-(--n-panel-hover)',
    '[box-shadow:var(--n-elev),var(--neba-plate-solid)]'
  ].join(' '),
  outline: [
    surfaceClasses,
    'border text-(--neba-fg) bg-(--n-panel)',
    '[border-color:var(--n-line)]',
    '[box-shadow:var(--n-elev),var(--neba-plate-glass)]'
  ].join(' '),
  text: 'text-(--neba-fg) bg-transparent'
};

/**
 * How far one level is set in from the one above it.
 *
 * Its own ladder rather than a step off the padding tracks, because indentation
 * is not padding: it is the width of the column a guide line is drawn in, and it
 * has to stay wide enough for an elbow to be legible at `xs` and narrow enough
 * that six levels still fit in a sidebar at `xl`.
 */
const indentValues: Record<NebaSize, string> = {
  xs: '0.875rem',
  sm: '1rem',
  md: '1.25rem',
  lg: '1.5rem',
  xl: '1.75rem'
};

/**
 * `controlHeightClasses` as raw lengths.
 *
 * The guides need a number rather than a class: an elbow is drawn at half the
 * height of the row it points at, and the rail under a last child stops there
 * too. Keep this in step with `controlHeightClasses` in `internal/styles.ts` —
 * they are the same five heights, which is what makes a tree row line up with
 * the Button next to it.
 */
const rowHeightValues: Record<NebaSize, string> = {
  xs: '1.375rem',
  sm: '1.625rem',
  md: '2rem',
  lg: '2.5rem',
  xl: '3rem'
};

/**
 * A row's horizontal padding. Its own two tracks rather than Box's, for the
 * reason List has its own vertical ones: a tree row is one line in a column of
 * dozens, and the `px-4` that gives a box air would push every label a level
 * further in than the indentation just placed it.
 */
const rowPaddingXClasses: Record<NebaDensity, Record<NebaSize, string>> = {
  default: { xs: 'px-1.5', sm: 'px-2', md: 'px-2.5', lg: 'px-3', xl: 'px-3.5' },
  compact: { xs: 'px-1', sm: 'px-1', md: 'px-1.5', lg: 'px-2', xl: 'px-2.5' }
};

/**
 * The corner of the tint under a hovered or chosen row.
 *
 * Its own ladder, for the reason a tick box and an OtpField slot have one.
 * `radiusClasses` is ~45% of a *control's* height, which is a cut corner on a
 * List row holding a label and a description and a lozenge on a tree row, which
 * is one line tall and nothing else — `md` would be 12px on a 32px box. These
 * are ~25%, which is the same amount of cut on this shape.
 */
const rowRadiusClasses: Record<NebaSize, string> = {
  xs: 'rounded-[0.3125rem]',
  sm: 'rounded-[0.375rem]',
  md: 'rounded-[0.5rem]',
  lg: 'rounded-[0.625rem]',
  xl: 'rounded-[0.75rem]'
};

/**
 * The guide drawing, which is real CSS in `styles.css`.
 *
 * It is there rather than in Tailwind for the reason the grid is: a rail is a
 * pseudo-element positioned half an indent outside its row, and the rail under a
 * last child is a different height from the rest. `[&:last-child]:[&::before]:…`
 * is expressible and nobody would want to read it. `none` needs no class at all.
 */
const linesClasses: Record<TreeViewLines, string> = {
  none: '',
  simple: 'neba-tree-simple',
  folder: 'neba-tree-folder'
};

/**
 * Every row in the tree, in the order the eye reads them.
 *
 * A branch that is shutting is still in the document — it has to be, or there
 * would be nothing left to collapse — and its rows must not be part of that
 * order for the 160ms it takes. Arrow keys are the reason: without this, the
 * row *below* a branch that was just closed is whatever was inside it.
 */
function treeRows(root: HTMLElement): HTMLElement[] {
  return Array.from(root.querySelectorAll<HTMLElement>('[role="treeitem"]')).filter(
    (row) => row.closest('[data-closing]') === null
  );
}

const keyOf = (value: TreeViewValue) => String(value);

/**
 * A tree of rows that open and shut.
 *
 * There is no Base UI primitive under this: the library has no tree, and the
 * three things a tree owes — the `tree`/`treeitem`/`group` roles, one tab stop
 * for the whole widget, and the arrow keys that walk it — are most of the
 * component.
 *
 * The keyboard is handled once, here, rather than on every row. A tree's arrow
 * keys are questions about the *tree* ("what is the next visible row", "where is
 * my parent"), and the only element that can answer them is the one holding all
 * of them. The rows the query returns are in document order, which is reading
 * order, because a shut branch is unmounted rather than hidden.
 */
export const TreeView = React.forwardRef<HTMLUListElement, TreeViewProps>(
  function TreeView(rawProps, ref) {
    const {
      variant = 'outline',
      size = 'md',
      color = 'primary',
      density = 'default',
      elevation = 0,
      lines = 'simple',
      expanded,
      defaultExpanded,
      onExpandedChange,
      selected,
      defaultSelected,
      onSelectedChange,
      multiple = false,
      disabled = false,
      label,
      className,
      style,
      children,
      onKeyDown,
      ...props
    } = useStyleDefaults(rawProps, ['size', 'density', 'variant']);

    const [uncontrolledExpanded, setUncontrolledExpanded] = React.useState<TreeViewValue[]>(
      defaultExpanded ?? []
    );
    const [uncontrolledSelected, setUncontrolledSelected] = React.useState<TreeViewValue[]>(
      defaultSelected ?? []
    );
    const [activeKey, setActiveKey] = React.useState<string | null>(null);

    const expandedValues = expanded ?? uncontrolledExpanded;
    const selectedValues = selected ?? uncontrolledSelected;

    const rootRef = React.useRef<HTMLUListElement | null>(null);
    const setRootRef = React.useCallback(
      (node: HTMLUListElement | null) => {
        rootRef.current = node;
        if (typeof ref === 'function') ref(node);
        else if (ref) ref.current = node;
      },
      [ref]
    );

    const toggle = React.useCallback(
      (value: TreeViewValue) => {
        const key = keyOf(value);
        const current = expanded ?? uncontrolledExpanded;
        const next = current.some((entry) => keyOf(entry) === key)
          ? current.filter((entry) => keyOf(entry) !== key)
          : [...current, value];

        if (expanded === undefined) setUncontrolledExpanded(next);
        onExpandedChange?.(next);
      },
      [expanded, uncontrolledExpanded, onExpandedChange]
    );

    const select = React.useCallback(
      (value: TreeViewValue) => {
        const key = keyOf(value);
        const current = selected ?? uncontrolledSelected;
        const isSelected = current.some((entry) => keyOf(entry) === key);
        // Single select never empties: pressing the chosen row again keeps it,
        // because "nothing chosen" is a state a caller cannot get back to by
        // pointing at a row. Multi-select does toggle — that is what it is for.
        const next = multiple
          ? isSelected
            ? current.filter((entry) => keyOf(entry) !== key)
            : [...current, value]
          : [value];

        if (selected === undefined) setUncontrolledSelected(next);
        onSelectedChange?.(next);
      },
      [multiple, selected, uncontrolledSelected, onSelectedChange]
    );

    const apisRef = React.useRef(new Map<string, TreeItemApi>());
    const register = React.useCallback((key: string, api: TreeItemApi) => {
      apisRef.current.set(key, api);

      return () => {
        apisRef.current.delete(key);
      };
    }, []);

    /*
     * The context is keyed on the *contents* of the two lists rather than on their
     * identity. `expanded={[...open]}` rebuilt on every render is the ordinary way
     * a controlled tree gets written, and keying on the array itself would rebuild
     * the context — and re-render every row under it — each time.
     *
     * A join rather than `JSON.stringify`: the keys are already strings, so the
     * quoting and escaping is work spent producing a longer key that answers the
     * same question. The separator is a NUL, which no key produced by `String()`
     * of a `string | number` can contain, so two different lists cannot spell one
     * key.
     */
    // Memoised on the arrays themselves as well. When a caller keeps the array
    // stable this is free; when they rebuild it every render — which is what the
    // paragraph above is about — it costs one miss and does the join anyway.
    const expandedKey = React.useMemo(
      () => expandedValues.map(keyOf).join('\u0000'),
      [expandedValues]
    );
    const selectedKey = React.useMemo(
      () => selectedValues.map(keyOf).join('\u0000'),
      [selectedValues]
    );

    const context = React.useMemo<TreeViewContextValue>(
      () => ({
        size,
        density,
        disabled,
        expandedKeys: new Set(expandedValues.map(keyOf)),
        selectedKeys: new Set(selectedValues.map(keyOf)),
        activeKey,
        toggle,
        select,
        activate: setActiveKey,
        register
      }),
      // The two lists are read inside and are deliberately not listed here: the
      // keys above change exactly when their contents do, which is the question.
      // eslint-disable-next-line react-hooks/exhaustive-deps
      [size, density, disabled, expandedKey, selectedKey, activeKey, toggle, select, register]
    );

    /*
     * The tab stop has to be somewhere, and after a branch shuts it may be on a
     * row that no longer exists. Rather than tracking every mount and unmount, the
     * tree checks what is actually rendered and moves the stop to the first row
     * whenever the one it was on has gone. It runs after every render and sets
     * state only when it has to, so it settles in a single extra pass.
     *
     * No dependency list, deliberately: a branch shutting unmounts rows without
     * changing anything this could be keyed on.
     *
     * The usual answer is the first line and costs nothing. Every rendered row
     * registers itself and unregisters on the way out, and a child's effect runs
     * before its parent's — so by the time this runs the map is exactly what is on
     * screen, and "is the tab stop still there" is a lookup rather than a
     * `querySelectorAll` over a tree that may hold thousands of rows.
     */
    // eslint-disable-next-line react-hooks/exhaustive-deps
    React.useEffect(() => {
      if (activeKey !== null && apisRef.current.has(activeKey)) return;

      const root = rootRef.current;
      if (!root) return;

      // Only when the cheap answer said no. Which row is *first* is a question
      // about document order, and the DOM is the only thing that knows it — the
      // map is in registration order, which is mount order and not the same.
      const rows = treeRows(root);
      if (rows.length === 0) return;

      setActiveKey(rows[0].dataset.nebaValue ?? null);
    });

    function handleKeyDown(event: React.KeyboardEvent<HTMLUListElement>) {
      onKeyDown?.(event);
      if (event.defaultPrevented) return;

      const root = rootRef.current;
      const target = (event.target as HTMLElement | null)?.closest?.(
        '[role="treeitem"]'
      ) as HTMLElement | null;
      if (!root || !target || !root.contains(target)) return;

      const rows = treeRows(root);
      const index = rows.indexOf(target);
      if (index === -1) return;

      const move = (row: HTMLElement | null | undefined) => {
        if (!row) return;
        event.preventDefault();
        setActiveKey(row.dataset.nebaValue ?? null);
        row.focus();
      };

      // The arrows open and shut without choosing, so they go through the row's
      // own opener rather than through a click, which would do both.
      const openBranch = (row: HTMLElement) => {
        const rowKey = row.dataset.nebaValue;
        if (rowKey) apisRef.current.get(rowKey)?.toggle();
      };

      // The direction is read off the element rather than off a prop: a caller may
      // have set `dir` three ancestors up, and ArrowRight has to mean "further in"
      // either way.
      const rtl = getComputedStyle(root).direction === 'rtl';
      const forward = rtl ? 'ArrowLeft' : 'ArrowRight';
      const back = rtl ? 'ArrowRight' : 'ArrowLeft';
      const open = target.getAttribute('aria-expanded');

      switch (event.key) {
        case 'ArrowDown':
          move(rows[index + 1]);
          break;
        case 'ArrowUp':
          move(rows[index - 1]);
          break;
        case 'Home':
          move(rows[0]);
          break;
        case 'End':
          move(rows[rows.length - 1]);
          break;
        case forward:
          // Open a shut branch; on an open one, step into it. The first child is
          // the next row in the document, which is what makes that one line.
          if (open === 'false') {
            event.preventDefault();
            openBranch(target);
          } else if (open === 'true') {
            move(rows[index + 1]);
          }
          break;
        case back:
          if (open === 'true') {
            event.preventDefault();
            openBranch(target);
          } else {
            move(target.parentElement?.closest('[role="treeitem"]') as HTMLElement | null);
          }
          break;
        // Enter is the one key that *presses* the row — it chooses it, and opens
        // it on the way, which is what pressing it with a pointer does.
        case 'Enter':
        case ' ':
          event.preventDefault();
          target.click();
          break;
        default:
          break;
      }
    }

    const classNames = cx(
      'flex list-none flex-col p-1',
      radiusClasses[size],
      variantClasses[variant],
      transitionClasses,
      linesClasses[lines],
      className
    );

    return (
      <TreeViewContext.Provider value={context}>
        <ul
          ref={setRootRef}
          role="tree"
          aria-label={label}
          aria-multiselectable={multiple || undefined}
          className={classNames}
          style={
            {
              ...surfaceSlots(color, elevation),
              '--n-tree-indent': indentValues[size],
              '--n-tree-row': rowHeightValues[size],
              ...style
            } as React.CSSProperties
          }
          onKeyDown={handleKeyDown}
          {...props}
        >
          {children}
        </ul>
      </TreeViewContext.Provider>
    );
  }
);

/**
 * One row, and everything under it.
 *
 * The `<li>` is the `treeitem` and it is what takes focus — not the row drawn
 * inside it. That is the ARIA pattern, and it is also why the disclosure arrow
 * is a plain span with a click handler rather than a button: a button inside the
 * focusable row would be a second tab stop in a widget that is supposed to have
 * exactly one, and the keyboard already opens a branch with ArrowRight.
 */
export const TreeItem = React.forwardRef<HTMLLIElement, TreeItemProps>(function TreeItem(
  {
    value,
    label,
    startIcon,
    endIcon,
    action,
    href,
    expandable,
    disabled: disabledProp = false,
    className,
    children,
    onClick,
    ...props
  },
  ref
) {
  const {
    size,
    density,
    disabled: treeDisabled,
    expandedKeys,
    selectedKeys,
    activeKey,
    toggle,
    select,
    activate,
    register
  } = React.useContext(TreeViewContext);

  const generatedId = React.useId();
  const identity = value ?? generatedId;
  const key = keyOf(identity);

  const itemRef = React.useRef<HTMLLIElement | null>(null);
  const setItemRef = React.useCallback(
    (node: HTMLLIElement | null) => {
      itemRef.current = node;
      if (typeof ref === 'function') ref(node);
      else if (ref) ref.current = node;
    },
    [ref]
  );

  // `toArray` rather than `count`: it drops the `null` that a `{when && …}`
  // leaves behind, so a branch whose children all filtered out is a leaf.
  const branch = React.Children.toArray(children);
  const isParent = expandable ?? branch.length > 0;
  const isExpanded = isParent && expandedKeys.has(key);
  const isSelected = selectedKeys.has(key);
  const disabled = disabledProp || treeDisabled;

  /*
   * The opener the tree's arrow keys reach for. The object is stable and its one
   * method is rewritten on every render, so the map the tree holds never goes
   * stale and registering does not have to run again when the row's props move.
   */
  const apiRef = React.useRef<TreeItemApi>({ toggle: () => {} });
  apiRef.current.toggle = () => {
    if (!disabled && isParent) toggle(identity);
  };

  const closing = React.useContext(TreeClosingContext);

  React.useEffect(
    () => (closing ? undefined : register(key, apiRef.current)),
    [closing, key, register]
  );

  /*
   * A branch opens and shuts at a height, the way an Accordion's panel does —
   * it used to be there on one frame and gone on the next, which on a tree deep
   * enough to need one is the whole page jumping.
   *
   * The height is a grid row going from `0fr` to `1fr` rather than a measured
   * pixel value: nothing has to be observed, a branch that gains a row while it
   * is open grows with it, and a nested branch opening inside this one is
   * carried by the same `1fr`.
   *
   * Two pieces of state and not one, because they change at different moments.
   * `mounted` is whether the rows exist at all — it goes up with the branch and
   * comes down only once the collapse has finished, which is what gives the
   * transition something to run on. `open` is the row track, and it is flipped a
   * frame *after* the mount, because a transition needs a previous value and an
   * element that has never been laid out has none.
   */
  const [branchMounted, setBranchMounted] = React.useState(isExpanded);
  const [branchOpen, setBranchOpen] = React.useState(isExpanded);
  const branchRef = React.useRef<HTMLDivElement | null>(null);

  React.useEffect(() => {
    if (isExpanded) {
      setBranchMounted(true);

      const frame = requestAnimationFrame(() => setBranchOpen(true));
      return () => cancelAnimationFrame(frame);
    }

    setBranchOpen(false);

    /*
     * A duration of zero fires no `transitionend` at all, so the branch would
     * sit shut and mounted for good — and zero is exactly what a reduced-motion
     * preference sets `--neba-duration` to, which is the reader least able to
     * afford a tree full of rows that are not there. Asked of the element
     * rather than assumed, since a consumer's own class can set it too.
     */
    const node = branchRef.current;
    const instant =
      node === null ||
      getComputedStyle(node)
        .transitionDuration.split(',')
        .every((one) => parseFloat(one) === 0);

    if (instant) setBranchMounted(false);

    return undefined;
  }, [isExpanded]);

  function handleClick(event: React.MouseEvent<HTMLElement>) {
    // Every row is inside every row above it, so a click that has been answered
    // here must not be answered again by each ancestor on the way out. This is
    // also what the arrow keys press: they call `.click()` on the `<li>`, which
    // is why the handler is here rather than on the row drawn inside it.
    event.stopPropagation();

    if (disabled) {
      event.preventDefault();
      return;
    }

    // The `<li>` is what holds the focus, and a click on something inside it
    // does not move focus there in every browser, so the row says so out loud.
    itemRef.current?.focus();
    activate(key);

    onClick?.(event);
    if (event.defaultPrevented) return;

    if (isParent) toggle(identity);
    select(identity);
  }

  const rowClassNames = cx(
    'flex min-w-0 flex-1 cursor-pointer items-center text-start',
    'h-(--n-tree-row)',
    rowPaddingXClasses[density][size],
    rowRadiusClasses[size],
    gapClasses[size],
    controlTextClasses[size],
    transitionClasses,
    iconClasses,
    // The ring is drawn on the row rather than on the `<li>` that actually has
    // focus: the `<li>` also contains the whole branch, so an outline on it
    // would trace a box around everything below the row as well.
    'group-focus-visible/tree-item:[outline:2px_solid_var(--n-ring)]',
    'group-focus-visible/tree-item:outline-offset-[-2px]',
    // An if/else rather than stacked variants: two Tailwind classes of equal
    // specificity resolve by their order in the generated stylesheet.
    disabled
      ? 'cursor-not-allowed text-(--neba-disabled-fg)'
      : isSelected
        ? 'bg-(--n-soft-press) font-medium text-(--n-accent) hover:bg-(--n-soft-press)'
        : 'hover:bg-(--n-soft)'
  );

  const body = (
    <>
      {/*
        Turned, not moved: the arrow is a glyph, so rotating it is the one
        allowance the no-transform rule makes. A leaf still draws the box, so
        every label in a branch starts on the same column.
      */}
      <span
        aria-hidden="true"
        onClick={(event) => {
          if (disabled || !isParent) return;
          // The arrow opens the branch and nothing else — it does not choose the
          // row. That is the difference between pointing at a folder and opening
          // one, and it is the only reason the arrow is a target of its own.
          event.stopPropagation();
          event.preventDefault();
          itemRef.current?.focus();
          activate(key);
          toggle(identity);
        }}
        className={cx(
          'flex h-[1lh] w-[1.15em] shrink-0 items-center justify-center',
          '[transition:rotate_var(--neba-duration)_var(--neba-ease)]',
          isParent ? 'text-(--neba-muted-fg)' : '',
          isExpanded ? 'rotate-0' : '-rotate-90 rtl:rotate-90'
        )}
      >
        {isParent ? <ChevronIcon /> : null}
      </span>

      {hasContent(startIcon) ? (
        <span className="flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg)">
          {startIcon}
        </span>
      ) : null}

      <span className="min-w-0 flex-1 truncate">{label}</span>

      {hasContent(endIcon) ? (
        <span className="flex h-[1lh] shrink-0 items-center text-(--neba-muted-fg)">{endIcon}</span>
      ) : null}
    </>
  );

  return (
    <li
      ref={setItemRef}
      role="treeitem"
      aria-expanded={isParent ? isExpanded : undefined}
      aria-selected={isSelected ? true : undefined}
      aria-disabled={disabled || undefined}
      data-neba-value={key}
      tabIndex={activeKey === key ? 0 : -1}
      // Not `outline-none`: that utility zeroes `--tw-outline-style`, the same
      // variable the row's own ring is drawn through.
      className={cx('group/tree-item relative block [outline:none]', className)}
      onClick={handleClick}
      {...props}
    >
      <div className="flex w-full items-center">
        {href && !disabled ? (
          <a
            href={href}
            // Inside the tab stop, not another one: a tree is a single widget,
            // and the arrow keys are how the rows in it are reached.
            tabIndex={-1}
            className={rowClassNames}
            aria-current={isSelected ? 'page' : undefined}
          >
            {body}
          </a>
        ) : (
          <div className={rowClassNames}>{body}</div>
        )}

        {hasContent(action) ? (
          <span
            className={cx('flex shrink-0 items-center', rowPaddingXClasses[density][size])}
            onClick={(event) => event.stopPropagation()}
          >
            {action}
          </span>
        ) : null}
      </div>

      {isParent && branchMounted && branch.length > 0 ? (
        <div
          ref={branchRef}
          // The hook `treeRows` reads to leave a shutting branch out of the
          // order the arrow keys walk. `pointer-events` goes with it: a row on
          // its way out must not answer the click that closed it.
          data-closing={isExpanded ? undefined : ''}
          className={cx(
            'grid [transition:grid-template-rows_var(--neba-duration)_var(--neba-ease)]',
            branchOpen ? '[grid-template-rows:1fr]' : '[grid-template-rows:0fr] pointer-events-none'
          )}
          onTransitionEnd={(event) => {
            // The row track and this element only — every row inside it is
            // transitioning a colour of its own on the way past.
            if (
              event.target === event.currentTarget &&
              event.propertyName === 'grid-template-rows' &&
              !isExpanded
            ) {
              setBranchMounted(false);
            }
          }}
        >
          <ul role="group" className="min-h-0 list-none overflow-hidden ps-(--n-tree-indent)">
            <TreeClosingContext.Provider value={closing || !isExpanded}>
              {children}
            </TreeClosingContext.Provider>
          </ul>
        </div>
      ) : null}
    </li>
  );
});

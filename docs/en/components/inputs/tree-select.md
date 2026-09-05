---
title: TreeSelect
order: 13
---

# TreeSelect

<p class="neba-lede">A value chosen from a tree rather than from a list. For a category, a folder, a region or an org-chart node: the things a flat list flattens away.</p>

<Demo src="tree-select/hero" />

```tsx
import { TreeSelect } from 'neba';

<TreeSelect label="Category" items={categories} value={value} onValueChange={setValue} />;
```

## Props

<PropsTable name="TreeSelect" />

### The items

<PropsTable name="TreeSelectItem" />

`value` must be unique across the whole tree, not just among siblings: it is what the component looks a node up by.

### Which one to use

| The options are                                       | Use                              |
| ----------------------------------------------------- | -------------------------------- |
| A flat list                                           | [Select](./select)               |
| A flat list you type into                             | [Combobox](./combobox)           |
| A hierarchy, and you are choosing from it             | TreeSelect                       |
| A hierarchy you are showing rather than choosing from | [TreeView](../display/tree-view) |

## Examples

### selectableBranches

Off by default, and that default carries weight: in most of these trees the branches are the taxonomy and the leaves are the answers. A "Europe" that can be chosen alongside "France" is usually a data model nobody meant.

A branch still expands and collapses when it cannot be chosen. An item's own `selectable` overrides the setting either way, which is how you get one choosable branch in a tree of headings, or one heading in a tree of choosable nodes.

### multiple

Holds any number, and the trigger writes them comma-joined unless `format` says otherwise. `closeOnSelect` follows it: a single-value TreeSelect closes on the first pick, a multiple one stays open.

### searchable

Adds a field above the tree that filters it.

**A match keeps its ancestors**, and every branch the filter kept is opened. Both halves matter: a tree filtered to bare matches is a list, and a list of leaves is exactly what a tree was chosen over. "Seoul" with nothing above it does not say which taxonomy it came from, and a match folded inside a closed parent is a match the reader was not shown.

`searchLabel` is what a node is matched against when its `label` is a node rather than a string.

### format

How the trigger writes what is held.

```tsx
format={(chosen) => (chosen.length === 1 ? chosen[0].label : `${chosen.length} categories`)}
```

### name

Submits with a form as one hidden input per value, so `multiple` arrives as a repeated field the way a `<select multiple>` does.

## Accessibility

- The popup holds a `role="tree"` of `role="treeitem"` rows, with arrow-key navigation and a single tab stop, from [TreeView](../display/tree-view).
- A branch's accessible name includes its subtree, because the row's element contains its children. Query and test by the row's own text.
- A node that cannot be chosen carries `aria-disabled` and keeps its place, so it stays on the arrow-key path.
- The popup is portalled to the end of `<body>`, with `neba-portal` on the positioner.

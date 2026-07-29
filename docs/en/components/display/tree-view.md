---
title: TreeView
order: 13
---

# TreeView

<p class="neba-lede">Shows items that belong to one another as a set of rows that open and shut. Use it for a folder listing, a navigation sidebar, or any grouped list a reader needs to fold away.</p>

<Demo src="tree-view/hero" />

```tsx
import { TreeItem, TreeView } from 'neba';

<TreeView label="Project files" lines="folder" defaultExpanded={['src']}>
  <TreeItem value="src" label="src">
    <TreeItem value="index" label="index.ts" />
  </TreeItem>
  <TreeItem value="readme" label="README.md" />
</TreeView>;
```

## Props

### TreeView

<PropsTable name="TreeView" />

`expanded` with `onExpandedChange` makes the open branches controlled; `defaultExpanded` makes them uncontrolled. `selected` and `onSelectedChange` work the same way for the selection, and both values are arrays of the rows' `value`s.

Every other `<ul>` attribute passes through to the tree. The shared axes are in [prop conventions](../../design/prop-conventions).

### TreeItem

<PropsTable name="TreeItem" />

Every other `<li>` attribute passes through to the row.

## Examples

### lines

`lines` decides how the hierarchy is drawn. `none` indents and nothing else, `simple` runs one hairline rail down each level, and `folder` adds an elbow into every row and stops the rail under the last child of a branch.

<Demo src="tree-view/lines">

<<< @/.vitepress/demos/tree-view/lines.tsx

</Demo>

### variant

The sheet is never filled with colour. Use `text` inside a [Card](../surfaces/card) or a sidebar that already has a surface.

<Demo src="tree-view/variants">

<<< @/.vitepress/demos/tree-view/variants.tsx

</Demo>

### Selecting rows

Pressing a row chooses it, and opens it if it has children. `multiple` lets more than one row be chosen at a time; without it, choosing a row replaces whatever was chosen before.

The disclosure arrow is a target of its own: it opens the branch without choosing the row.

<Demo src="tree-view/selection">

<<< @/.vitepress/demos/tree-view/selection.tsx

</Demo>

### href

A row with an `href` renders as a link, which is what a navigation tree is made of. It is not a second tab stop — the tree holds one, and the arrow keys reach the rows.

<Demo src="tree-view/navigation">

<<< @/.vitepress/demos/tree-view/navigation.tsx

</Demo>

### expandable

A shut branch is not in the DOM, so a tree that fetches its children the first time a row is opened has nothing to render yet. `expandable` draws the arrow anyway: fetch in `onExpandedChange`, then render the rows when they arrive.

```tsx
<TreeView expanded={expanded} onExpandedChange={load}>
  <TreeItem value="remote" label="Remote" expandable>
    {children.map((child) => (
      <TreeItem key={child.id} value={child.id} label={child.name} />
    ))}
  </TreeItem>
</TreeView>
```

## Accessibility

- The tree is a `tree`, every row is a `treeitem`, and a branch's children are a `group`.
- The whole tree is one tab stop. Once inside, ArrowUp and ArrowDown walk the visible rows, ArrowRight opens a shut branch and steps into an open one, ArrowLeft shuts a branch and climbs out of a leaf, Home and End jump to the ends, and Enter chooses the focused row. The arrows never change the selection.
- ArrowLeft and ArrowRight swap under RTL, so the forward arrow always means "further in".
- Pass `label` so the tree has a name; without one, a screen reader announces an unnamed tree.
- `multiple` sets `aria-multiselectable` on the tree.

---
title: TreeView
order: 13
flutter: true
---

# TreeView

<p class="neba-lede">Shows items that belong to one another as a set of rows that open and shut. Use it for a folder listing, a navigation sidebar, or any grouped list a reader needs to fold away.</p>

<Demo src="tree-view/hero" />

::: fw react

```tsx
import { TreeItem, TreeView } from 'neba';

<TreeView label="Project files" lines="folder" defaultExpanded={['src']}>
  <TreeItem value="src" label="src">
    <TreeItem value="index" label="index.ts" />
  </TreeItem>
  <TreeItem value="readme" label="README.md" />
</TreeView>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaTreeView<String>(
  label: 'Project files',
  lines: NebaTreeViewLines.folder,
  defaultExpanded: <String>['src'],
  children: <NebaTreeItem<String>>[
    NebaTreeItem<String>(
      value: 'src',
      label: Text('src'),
      children: <NebaTreeItem<String>>[
        NebaTreeItem<String>(value: 'index', label: Text('index.ts')),
      ],
    ),
    NebaTreeItem<String>(value: 'readme', label: Text('README.md')),
  ],
);
```

:::

## Props

### TreeView

<PropsTable name="TreeView" />

::: fw react

`expanded` with `onExpandedChange` makes the open branches controlled; `defaultExpanded` makes them uncontrolled. `selected` and `onSelectedChange` work the same way for the selection, and both values are arrays of the rows' `value`s.

Every other `<ul>` attribute passes through to the tree. The shared axes are in [prop conventions](../../design/prop-conventions).

:::

::: fw flutter

`NebaTreeView` is generic over the type of its rows' values. `expanded` with `onExpandedChange` makes the open branches controlled; left `null`, the tree keeps its own state from `defaultExpanded`. `selected` and `onSelectedChange` work the same way for the selection, and both values are lists of the rows' `value`s. `label` is the name a screen reader hears, as `aria-label` is. The tree fills the width it is given. The shared axes are in [prop conventions](../../design/prop-conventions).

:::

### TreeItem

<PropsTable name="TreeItem" />

::: fw react

Every other `<li>` attribute passes through to the row.

:::

::: fw flutter

A row is a `NebaTreeItem`, a description of the row rather than a widget, and the rows under it are its `children`, a list of the same. The tree draws every row itself, because which rows are showing and where the arrow keys go next are questions about the whole tree. A row left without a `value` is named by its place, as React generates one; it opens, shuts and is chosen, and is left out of the lists the tree reports. `onPressed` is React's `onClick`, called before the row opens or is chosen; nothing can cancel those from it, so a row that must not open or be chosen takes `selectable: false` or a controlled `expanded`.

:::

## Examples

### lines

`lines` decides how the hierarchy is drawn. `none` indents and nothing else, `simple` runs one hairline rail down each level, and `folder` adds an elbow into every row and stops the rail under the last child of a branch.

<Demo src="tree-view/lines">

::: fw react

<<< @/.vitepress/demos/tree-view/lines.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_view/lines.dart

:::

</Demo>

### variant

The sheet is never filled with colour. Use `text` inside a [Card](../surfaces/card) or a sidebar that already has a surface.

<Demo src="tree-view/variants">

::: fw react

<<< @/.vitepress/demos/tree-view/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_view/variants.dart

:::

</Demo>

### Selecting rows

Pressing a row chooses it and opens its branch, or shuts the branch if it is already open. `multiple` lets more than one row be chosen at a time; without it, choosing a row replaces whatever was chosen before.

The disclosure arrow is a target of its own: it opens and shuts the branch without choosing the row. A row with <Fw react="`selectable={false}`" flutter="`selectable: false`" /> is never chosen, and pressing it only opens and shuts its branch.

<Demo src="tree-view/selection">

::: fw react

<<< @/.vitepress/demos/tree-view/selection.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_view/selection.dart

:::

</Demo>

### href

::: fw react

A row with an `href` renders as a link, which is what a navigation tree is made of. It is not a second tab stop: the tree holds one, and the arrow keys reach the rows.

:::

::: fw flutter

A row with an `href` is heard as a link to it, which is what a navigation tree is made of. The package opens nothing itself, so following the link is the row's `onPressed`, which a press, Enter and Space all call. It is not a second stop in the focus order: the tree holds one, and the arrow keys reach the rows.

:::

<Demo src="tree-view/navigation">

::: fw react

<<< @/.vitepress/demos/tree-view/navigation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_view/navigation.dart

:::

</Demo>

### keepMounted

::: fw react

A shut branch is not in the DOM by default, so a crawler reading the server render never sees the links inside it. `keepMounted` keeps every shut branch in the DOM, collapsed and `inert`, so a navigation tree has every link in its server render. The rows of a shut branch stay out of the tab order and out of the rows the arrow keys walk. On a tree with thousands of rows, each one is built on the first render.

```tsx
<TreeView label="Docs" keepMounted>
  <TreeItem value="guide" label="Guide" href="/guide">
    <TreeItem value="install" label="Installation" href="/guide/install" />
  </TreeItem>
</TreeView>
```

:::

::: fw flutter

A shut branch's rows are not built by default. `keepMounted` keeps them built, folded away, so whatever state they hold survives the branch being shut. The rows of a shut branch stay out of the focus order, out of the rows the arrow keys walk and out of what a screen reader hears. A Flutter screen has no server render for a crawler to read, so the reason React has for it does not arise. On a tree with thousands of rows, each one is built on the first build.

```dart
NebaTreeView<String>(
  label: 'Docs',
  keepMounted: true,
  children: <NebaTreeItem<String>>[
    NebaTreeItem<String>(
      value: 'guide',
      label: const Text('Guide'),
      children: <NebaTreeItem<String>>[
        NebaTreeItem<String>(value: 'install', label: const Text('Installation')),
      ],
    ),
  ],
);
```

:::

### expandable

A shut branch's rows are not <Fw react="in the DOM" flutter="built" /> unless `keepMounted` is on, so a tree that fetches its children the first time a row is opened has nothing to render yet. `expandable` draws the arrow anyway: fetch in `onExpandedChange`, then render the rows when they arrive.

::: fw react

```tsx
<TreeView expanded={expanded} onExpandedChange={load}>
  <TreeItem value="remote" label="Remote" expandable>
    {children.map((child) => (
      <TreeItem key={child.id} value={child.id} label={child.name} />
    ))}
  </TreeItem>
</TreeView>
```

:::

::: fw flutter

```dart
NebaTreeView<String>(
  expanded: expanded,
  onExpandedChange: load,
  children: <NebaTreeItem<String>>[
    NebaTreeItem<String>(
      value: 'remote',
      label: const Text('Remote'),
      expandable: true,
      children: <NebaTreeItem<String>>[
        for (final Child child in children)
          NebaTreeItem<String>(value: child.id, label: Text(child.name)),
      ],
    ),
  ],
);
```

:::

## Accessibility

::: fw react

- The tree is a `tree`, every row is a `treeitem`, and a branch's children are a `group`.

:::

::: fw flutter

- Flutter has no tree role, so the tree is heard as a list named by `label`, each row as an item of it, and a branch's children as a list inside that item. The row itself is a button, or a link with an `href`, heard as expanded or collapsed when it has a branch and as selected when it is chosen.

:::

- The whole tree is one <Fw react="tab stop" flutter="stop in the focus order" />. Once inside, ArrowUp and ArrowDown walk the visible rows, ArrowRight opens a shut branch and steps into an open one, ArrowLeft shuts a branch and climbs out of a leaf, Home and End jump to the ends, and a typed character moves to the next visible row whose label starts with it. Enter and Space press the focused row, which chooses it and opens or shuts its branch<Fw react=", and Enter on a row that is a link follows the link as well" flutter=", and calls its `onPressed`" />. The arrows never change the selection.
- ArrowLeft and ArrowRight swap under RTL, so the forward arrow always means "further in".
- Pass `label` so the tree has a name; without one, a screen reader announces an unnamed <Fw react="tree" flutter="list" />.

::: fw react

- `multiple` sets `aria-multiselectable` on the tree.
- A branch kept in the DOM by `keepMounted` is `inert` while it is shut, so it is out of the tab order and the accessibility tree, and the browser's page search does not find it.

:::

::: fw flutter

- With `multiple`, every row that can be chosen is heard as selected or not, so "not selected" is said rather than left out.
- A branch kept built by `keepMounted` is out of the focus order and the semantics tree while it is shut, and from the moment it starts to shut.

:::

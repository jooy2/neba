---
title: TreeSelect
order: 13
flutter: true
---

# TreeSelect

<p class="neba-lede">A value chosen from a tree rather than from a list. For a category, a folder, a region or an org-chart node: the things a flat list flattens away.</p>

<Demo src="tree-select/hero" minHeight="380" />

::: fw react

```tsx
import { TreeSelect } from 'neba';

<TreeSelect label="Category" items={categories} value={value} onValueChange={setValue} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaTreeSelect<String>(
  label: const Text('Category'),
  items: categories,
  value: value,
  onValueChange: (List<String> next) => setState(() => value = next),
);
```

:::

## Props

<PropsTable name="TreeSelect" />

::: fw flutter

`NebaTreeSelect` is generic over the type of its values, and `label`, `placeholder`, `description` and `error` are widgets, usually a `Text`. `value` and `defaultValue` are lists whatever `multiple` says, empty for nothing held, where React also takes a single value or `null`; left `null`, `value` means the tree select keeps its own state. `semanticLabel` names a trigger with no label of its own, as `aria-label` does. `startIcon` and `fullWidth` are the picker shell's, as they are in React.

`name`, `required` and `classNames` are not there: nothing submits a Flutter form for the control, and its parts are styled through the shared props. The popup is drawn in the app's root `Overlay`, as a [Popover](../surfaces/popover)'s is.

:::

### The items

<PropsTable name="TreeSelectItem" />

`value` must be unique across the whole tree, not just among siblings: it is what the component looks a node up by.

::: fw flutter

```dart
const NebaTreeSelectItem<String>(
  value: 'europe',
  label: Text('Europe'), // defaults to the value's own text
  selectable: false,
  children: <NebaTreeSelectItem<String>>[
    NebaTreeSelectItem<String>(value: 'fr', label: Text('France')),
  ],
);
```

:::

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

`searchLabel` is what a node is matched against when its `label` is <Fw react="a node rather than a string" flutter="a widget other than a `Text`" />.

### format

How the trigger writes what is held.

::: fw react

```tsx
format={(chosen) => (chosen.length === 1 ? chosen[0].label : `${chosen.length} categories`)}
```

:::

::: fw flutter

```dart
format: (List<NebaTreeSelectItem<String>> chosen) =>
    chosen.length == 1 ? chosen.first.label! : Text('${chosen.length} categories'),
```

:::

### labelPlacement

`notch` and `float` work as they do on [TextField](./text-field#labelplacement). A `float` label rests in the trigger while nothing is chosen, the trigger does not hold the focus and the popup is closed.

<Demo src="tree-select/label-placement" minHeight="300">

::: fw react

<<< @/.vitepress/demos/tree-select/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_select/label_placement.dart

:::

</Demo>

::: fw react

### name

Submits with a form as one input per value, so `multiple` arrives as a repeated field the way a `<select multiple>` does. Inside a [Form](./form), `onSubmit` gets the value under `name`, as an array when `multiple`; a `required` TreeSelect holds the submit while nothing is chosen, and an error the Form is handed under `name` shows under the field.

:::

## Accessibility

::: fw react

- The popup holds a `role="tree"` of `role="treeitem"` rows, with arrow-key navigation and a single tab stop, from [TreeView](../display/tree-view).
- A branch's accessible name includes its subtree, because the row's element contains its children. Query and test by the row's own text.
- A node that cannot be chosen carries `aria-disabled` and keeps its place, so it stays on the arrow-key path.
- The popup is portalled to the end of `<body>`, with `neba-portal` on the positioner.

:::

::: fw flutter

- The trigger is a button named by `label`, which says what it holds and whether its popup is expanded. Enter and Space open it, and the × beside the value is a button of its own, named by `clearLabel`.
- The popup holds a [TreeView](../display/tree-view), with its arrow keys, its single stop in the focus order and its rows heard as a nested list. Opening moves the focus to the search field, or to the tree when there is none; Escape, a press outside and a single choice close it and give the focus back to the trigger.
- A node that is disabled is heard as unavailable and keeps its place, so it stays on the arrow-key path.

:::

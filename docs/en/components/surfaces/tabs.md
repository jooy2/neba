---
title: Tabs
order: 4
flutter: true
---

# Tabs

<p class="neba-lede">Shows one of several panels in the same place. Use it where content is switched between rather than laid out side by side.</p>

<Demo src="tabs/hero" />

::: fw react

```tsx
import { Tab, TabPanel, Tabs } from 'neba';

<Tabs defaultValue="overview">
  <Tab value="overview">Overview</Tab>
  <Tab value="usage">Usage</Tab>

  <TabPanel value="overview">Three deploys today, all green.</TabPanel>
  <TabPanel value="usage">1,284 build minutes used.</TabPanel>
</Tabs>;
```

There is no `<TabList>` wrapper. Write `Tab`s and `TabPanel`s side by side and the component sorts them into the bar and the panel area. A Fragment is looked through, but a component of your own that renders a `TabPanel` is not recognised, so write the `TabPanel` itself among the children.

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaTabs<String>(
  defaultValue: 'overview',
  children: <Widget>[
    NebaTab<String>(value: 'overview', child: Text('Overview')),
    NebaTab<String>(value: 'usage', child: Text('Usage')),
    NebaTabPanel<String>(value: 'overview', child: Text('Three deploys today, all green.')),
    NebaTabPanel<String>(value: 'usage', child: Text('1,284 build minutes used.')),
  ],
);
```

There is no list wrapper. Write `NebaTab`s and `NebaTabPanel`s side by side in `children` and the widget sorts them by type into the bar and the panel area. A widget of your own that builds a `NebaTabPanel` is not recognised, so write the `NebaTabPanel` itself among the children.

:::

## Props

### Tabs

<PropsTable name="Tabs" />

::: fw flutter

The set is generic over the type of a tab's `value`. `value` with `onValueChange` makes it controlled; left `null`, the set keeps its own state from `defaultValue`.

:::

### Tab

<PropsTable name="Tab" />

### TabPanel

<PropsTable name="TabPanel" />

## Examples

### variant

`variant` is the weight of the tab **bar**, not of the panels under it.

- `solid`: a filled tile moves between the tabs inside a trough.
- `outline`: the indicator rides on a rule along the edge of the bar.
- `text`: the indicator with no rule, for tabs inside a [Card](./card) that already has an edge.

<Demo src="tabs/variants">

::: fw react

<<< @/.vitepress/demos/tabs/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/variants.dart

:::

</Demo>

### orientation

`vertical` puts the bar down the <Fw react="left" flutter="start" /> side. The arrow keys move onto the vertical axis with it.

<Demo src="tabs/orientation">

::: fw react

<<< @/.vitepress/demos/tabs/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/orientation.dart

:::

</Demo>

### align

Where a tab's label sits when the tab is wider than the label: in a vertical bar, where every tab is as wide as the longest, or in a horizontal one with `fullWidth`.

It moves the label and the icons and nothing else. `start` and `end` are logical, so they follow the reading direction.

<Demo src="tabs/align">

::: fw react

<<< @/.vitepress/demos/tabs/align.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/align.dart

:::

</Demo>

### overflow and lines

`overflow` says what a bar with more tabs than room does about it. `scroll` (the default) keeps the bar on one line and scrolls along it; the ends fade while there is more bar in that direction, and the scrollbar itself is hidden. `wrap` takes as many lines as the tabs need, and the rule under the chosen tab moves onto the line that tab is on.

`lines` caps a wrapping bar at that many tab-rows and scrolls past the cap. It is read only when `overflow` is `wrap`.

<Demo src="tabs/overflow" minHeight="420">

::: fw react

<<< @/.vitepress/demos/tabs/overflow.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/overflow.dart

:::

</Demo>

### wheel

`wheel` turns a mouse wheel rolled over the bar into travel along it. It is on by default, and <Fw react="wheel={false}" flutter="wheel: false" code /> turns it off.

While the pointer is over a bar that overflows, the wheel moves only the bar, even at its ends, and the page takes the wheel back once the pointer moves off. A bar that fits takes nothing, and a sideways trackpad swipe is left to <Fw react="the browser" flutter="the bar's own scroll view" />.

<Demo src="tabs/wheel" minHeight="320">

::: fw react

<<< @/.vitepress/demos/tabs/wheel.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/wheel.dart

:::

</Demo>

### startIcon and endIcon

Put an icon or a count before or after the label.

<Demo src="tabs/icons">

::: fw react

<<< @/.vitepress/demos/tabs/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/icons.dart

:::

</Demo>

### size

The same control heights as [Button](../inputs/button): a `md` tab and a `md` button are both 32px, so a tab bar can sit in a toolbar beside one.

### activateOnFocus

Off by default: walking the arrow keys along the bar does not change the panel, and Enter or Space activates. That keeps a panel that fetches from firing a request per tab passed.

### keepMounted

::: fw react

Set on a `TabPanel`, it keeps an unselected panel's React tree alive. An unselected panel is otherwise not in the DOM, so it is not in a server render or a crawler's index either: set `keepMounted` on panels whose content should be found by search.

Set on `Tabs`, it does the same for every panel, which saves writing it on each one. A panel's own `keepMounted` still wins, so `keepMounted={false}` on one panel leaves that panel out.

```tsx
<Tabs defaultValue="overview" keepMounted>
  <Tab value="overview">Overview</Tab>
  <Tab value="usage">Usage</Tab>
  <TabPanel value="overview">…</TabPanel>
  <TabPanel value="usage">…</TabPanel>
</Tabs>
```

:::

::: fw flutter

Set on a `NebaTabPanel`, it keeps an unselected panel built and hidden, so a form in it keeps what was typed while another tab is chosen. An unselected panel is otherwise not built at all.

Set on `NebaTabs`, it does the same for every panel, which saves writing it on each one. A panel's own `keepMounted` still wins, so `keepMounted: false` on one panel leaves that panel out.

```dart
const NebaTabs<String>(
  defaultValue: 'overview',
  keepMounted: true,
  children: <Widget>[
    NebaTab<String>(value: 'overview', child: Text('Overview')),
    NebaTab<String>(value: 'usage', child: Text('Usage')),
    NebaTabPanel<String>(value: 'overview', child: Text('…')),
    NebaTabPanel<String>(value: 'usage', child: Text('…')),
  ],
);
```

:::

## Accessibility

::: fw react

- The whole bar is one tab stop, with the arrow keys and Home/End moving within it (a roving tab index).
- The `tab` / `tabpanel` roles and the `aria-controls` between them are wired up.
- A panel with nothing focusable inside it takes focus itself, so the content stays reachable by keyboard.

:::

::: fw flutter

- The whole bar is one stop in the focus order, with the arrow keys and Home/End moving within it. A disabled tab is reached too, and is never chosen; a tab the arrows reach is scrolled into view.
- A screen reader hears a tab bar of tabs, with the chosen tab selected, and each panel as a tab panel named after its tab.
- A panel is not a focus stop of its own: a screen reader reads it without one, and nothing in Flutter scrolls by the focus landing on a block of text.

:::

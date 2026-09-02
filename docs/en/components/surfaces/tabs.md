---
title: Tabs
order: 4
---

# Tabs

<p class="neba-lede">Shows one of several panels in the same place. Use it where content is switched between rather than laid out side by side.</p>

<Demo src="tabs/hero" />

```tsx
import { Tab, TabPanel, Tabs } from 'neba';

<Tabs defaultValue="overview">
  <Tab value="overview">Overview</Tab>
  <Tab value="usage">Usage</Tab>

  <TabPanel value="overview">Three deploys today, all green.</TabPanel>
  <TabPanel value="usage">1,284 build minutes used.</TabPanel>
</Tabs>;
```

There is no `<TabList>` wrapper. Write `Tab`s and `TabPanel`s side by side and the component sorts them into the bar and the panel area.

## Props

### Tabs

<PropsTable name="Tabs" />

### Tab

<PropsTable name="Tab" />

### TabPanel

<PropsTable name="TabPanel" />

## Examples

### variant

`variant` is the weight of the tab **bar**, not of the panels under it.

- `solid` — a filled tile moves between the tabs inside a trough.
- `outline` — the indicator rides on a rule along the edge of the bar.
- `text` — the indicator with no rule, for tabs inside a [Card](./card) that already has an edge.

<Demo src="tabs/variants">

<<< @/.vitepress/demos/tabs/variants.tsx

</Demo>

### orientation

`vertical` puts the bar down the left side. The arrow keys move onto the vertical axis with it.

<Demo src="tabs/orientation">

<<< @/.vitepress/demos/tabs/orientation.tsx

</Demo>

### overflow and lines

`overflow` says what a bar with more tabs than room does about it. `scroll` — the default — keeps the bar on one line and scrolls along it; the ends fade while there is more bar in that direction, and the scrollbar itself is hidden. `wrap` takes as many lines as the tabs need, and the rule under the chosen tab moves onto the line that tab is on.

`lines` caps a wrapping bar at that many tab-rows and scrolls past the cap. It is read only when `overflow` is `wrap`.

<Demo src="tabs/overflow" minHeight="420">

<<< @/.vitepress/demos/tabs/overflow.tsx

</Demo>

### startIcon and endIcon

Put an icon or a count before or after the label.

<Demo src="tabs/icons">

<<< @/.vitepress/demos/tabs/icons.tsx

</Demo>

### size

The same control heights as [Button](../inputs/button): a `md` tab and a `md` button are both 32px, so a tab bar can sit in a toolbar beside one.

### activateOnFocus

Off by default: walking the arrow keys along the bar does not change the panel, and Enter or Space activates. That keeps a panel that fetches from firing a request per tab passed.

### keepMounted

Set on a `TabPanel`, it keeps an unselected panel's React tree alive.

## Accessibility

- The whole bar is one tab stop, with the arrow keys and Home/End moving within it (a roving tab index).
- The `tab` / `tabpanel` roles and the `aria-controls` between them are wired up.
- A panel with nothing focusable inside it takes focus itself, so the content stays reachable by keyboard.
- The indicator moves via `left` / `top` and `width` / `height`, so no label is resampled.

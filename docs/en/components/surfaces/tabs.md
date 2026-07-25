---
title: Tabs
order: 4
---

# Tabs

<p class="neba-lede">One set of panels, one of which is shown. Horizontal or vertical.</p>

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

There is no `<TabList>` wrapper. Everything written between the tags is either a tab or a panel, the two go in different boxes, and the component sorts them — rather than adding a wrapper you have to remember.

## Props

### Tabs

<PropsTable name="Tabs" />

### Tab

<PropsTable name="Tab" />

### TabPanel

<PropsTable name="TabPanel" />

## Examples

### Variants

`variant` here is the weight of the tab **bar**, not of the panels under it.

- `solid` — a segmented control. The bar is a frosted trough and the indicator is a filled tile that slides between the tabs.
- `outline` — the classic. A rule along the edge of the bar, with the indicator riding on it.
- `text` — the same bar with the rule taken away. For tabs inside a [Card](./card) that already has an edge of its own.

<Demo src="tabs/variants">

<<< @/.vitepress/demos/tabs/variants.tsx

</Demo>

### Orientation

A vertical bar is not a horizontal one turned on its side. Base UI moves the arrow keys onto the other axis with it, which is the part that makes a vertical tab bar reachable at all.

<Demo src="tabs/orientation">

<<< @/.vitepress/demos/tabs/orientation.tsx

</Demo>

### Icons and counts

<Demo src="tabs/icons">

<<< @/.vitepress/demos/tabs/icons.tsx

</Demo>

## The indicator moves its box

Base UI measures the chosen tab and writes the result onto `--active-tab-left`, `--active-tab-width` and their siblings. The indicator animates `left`/`top` and `width`/`height` from those.

That is a layout animation on an empty box, not a transform on a label — nothing with text in it moves, which is the line the [no-transform rule](../../guide/design-language) actually draws.

It is also the one place in the library that reaches for a physical property (`left`) instead of a logical one, on purpose. `--active-tab-left` is a **measurement**: the distance in pixels from the list's left edge to the chosen tab's, and it stays a distance from the left under RTL. Pairing a physical measurement with a logical property is what would break the direction, not what would fix it. The edge the bar sits on _is_ logical, because that one genuinely flips.

## Why `activateOnFocus` is off by default

Automatic activation is only kind when every panel is already on the page. The moment one of them fetches, walking past four tabs with the arrow keys fires four requests.

## Tabs are on the control ladder

A `md` tab and a `md` [Button](../inputs/button) are the same 32px. That is what lets a tab bar sit in a toolbar next to a button without the row losing its baseline.

## Accessibility

Base UI owns everything that makes a tab bar a tab bar rather than a row of buttons: roving focus so the whole bar is one tab stop, the arrow keys on whichever axis the bar runs, Home and End, the `tab` / `tabpanel` roles and the `aria-controls` wiring between them, and the measurement that puts the indicator under the chosen tab.

A panel with nothing focusable inside it takes focus itself, so the content is reachable by keyboard — and when it does, it gets the house focus ring rather than the browser's outline.

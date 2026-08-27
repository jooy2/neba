---
title: Sidebar
order: 4
---

# Sidebar

<p class="neba-lede">A column beside the page's content, and a drawer once the window is too narrow to hold one. It renders a real <code>&lt;aside&gt;</code>, which is the complementary landmark.</p>

<Demo src="sidebar/hero" minHeight="300" />

```tsx
import { List, ListItem, Sidebar } from 'neba';

<Sidebar label="Sections">
  <List>
    <ListItem selected>Overview</ListItem>
    <ListItem>Components</ListItem>
  </List>
</Sidebar>;
```

## Props

<PropsTable name="Sidebar" />

Every native `<aside>` attribute passes through, apart from `color` and `title`. The shared axes are described under [prop conventions](../../design/prop-conventions).

It lays out its own children and nothing else. To have a page laid out _around_ it, put it in a [PageLayout](./page-layout)'s `sidebar` or `endSidebar` slot.

## Examples

### width · size

`size` sets the column's default width — `md` is 16rem — and `width` overrides it with a number in pixels or any CSS length.

### resizable

Lets the reader drag the inner edge. `minWidth` and `maxWidth` bound it, `onResize` fires on every step and `onResizeEnd` once when the edge is let go — which is where a remembered width should be stored. The handle is a focusable `role="separator"`, so the left and right arrow keys do the same thing.

<Demo src="sidebar/resizable" minHeight="300">

<<< @/.vitepress/demos/sidebar/resizable.tsx

</Demo>

### side

`start` and `end` rather than left and right, because a navigation rail is beside the text it belongs to in every writing direction. Inside a [PageLayout](./page-layout) the slot decides and the prop is not needed.

<Demo src="sidebar/sides" minHeight="300">

<<< @/.vitepress/demos/sidebar/sides.tsx

</Demo>

### collapseBelow

The width below which the column becomes a [Drawer](../feedback/dialog) over a scrim, with a focus trap, an Escape and a way back to the trigger. The children exist once either way. `title` is drawn only in that shape — a column has the page around it to say what it is, a panel that has covered the page does not.

It defaults to the PageLayout's own value and to `none` outside one, because a sidebar that collapsed with nothing on the page able to bring it back is a sidebar the reader has lost.

### sticky

On by default. With the page scrolling it becomes a sticky column as tall as what is left of the window under the header; with only the content scrolling it is already as tall as the layout and this changes nothing.

## SidebarTrigger

The button that brings back a sidebar the window has become too narrow to hold. Put it in a [Header](./header)'s `brand` slot, ahead of the logo.

```tsx
import { Header, PageLayout, Sidebar, SidebarTrigger } from 'neba';

<PageLayout header={<Header brand={<SidebarTrigger />} />} sidebar={<Sidebar>…</Sidebar>}>
  Page
</PageLayout>;
```

<PropsTable name="SidebarTrigger" />

Everything else an [IconButton](../inputs/icon-button) takes passes through. It has to be inside a PageLayout to have something to open; outside one it renders nothing. It is hidden at and above the breakpoint by a class rather than by being absent, so it never pops into a header a moment after the page arrives.

## Accessibility

- It renders `<aside>`, the `complementary` landmark, and names itself with the `locale`'s word for "Sidebar" unless `label` says otherwise. A page with two sidebars must name both.
- Collapsed, it is a modal dialog: the focus is held inside it, Escape closes it, and the focus returns to the trigger.
- The resize handle is a `role="separator"` with `tabindex="0"` and is named by the `locale`. Left and right arrows move it by 16px.
- `locale` is inherited from the PageLayout, so it is written once per page.

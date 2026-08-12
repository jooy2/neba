---
title: Drawer
order: 10
---

# Drawer

<p class="neba-lede">A panel attached to one edge of the window. It either floats over the page and is dismissed, or sits in the layout as a fixed sidebar — the same panel either way.</p>

<Demo src="drawer/hero" align="center" />

```tsx
import { Button, Drawer } from 'neba';

<Drawer trigger={<Button variant="outline">Open navigation</Button>} title="Workspace">
  <List>…</List>
</Drawer>;
```

## Props

<PropsTable name="Drawer" />

`DrawerClose` is Base UI's `Dialog.Close`, re-exported. Give it a `render` prop and any element dismisses the drawer it is inside: `<DrawerClose render={<Button>Cancel</Button>} />`. It belongs to an `overlay` drawer — an `inline` one is not a dialog.

The shared axes are described in [prop conventions](../../design/prop-conventions).

## Examples

### side

`side` is the edge the panel is attached to. `left` and `right` take a width from the `size` ladder and fill the height; `top` and `bottom` fill the width and are as tall as their content, up to 85% of the window.

<Demo src="drawer/sides">

<<< @/.vitepress/demos/drawer/sides.tsx

</Demo>

### mode

`overlay`, the default, is the drawer you open: a scrim, a focus trap, Escape, and focus returned to the trigger. `inline` puts the same panel in the layout — no scrim, no portal, nothing to dismiss — and `open` decides whether it is in the flow at all. It defaults to open, so a fixed sidebar needs no state.

Because it is one component, a sidebar that becomes a hamburger at a breakpoint is a `mode` that changes rather than two components to swap between.

<Demo src="drawer/inline">

<<< @/.vitepress/demos/drawer/inline.tsx

</Demo>

### rounded

`rounded` cuts the two corners on the edge facing the page — the top and bottom of a side panel, the inner pair of a top or bottom one. The corners against the window edge stay square. Turn it off for a panel that should read as an extension of the window.

<Demo src="drawer/rounded">

<<< @/.vitepress/demos/drawer/rounded.tsx

</Demo>

### dividers and scrolling

The body is the only part that scrolls, so `title`, `description` and `actions` stay put. `dividers` replaces the space between the sections with hairlines, which is what says the header did not move.

<Demo src="drawer/scrolling">

<<< @/.vitepress/demos/drawer/scrolling.tsx

</Demo>

### extent

`extent` is how far the panel reaches in from its edge: a **width** for `left` and `right`, a **height** for `top` and `bottom`. Numbers are pixels, strings are CSS lengths. Left alone, a side panel takes the width its `size` implies.

```tsx
<Drawer side="right" extent={420} title="Details" />
<Drawer side="bottom" extent="50vh" title="Filters" />
```

## Accessibility

- In `overlay` mode the panel is a modal dialog: focus is trapped inside, the page behind goes inert, Escape closes it and focus returns to the trigger.
- `title` names the drawer and `description` describes it, wired with `aria-labelledby` and `aria-describedby`. A drawer with neither needs an `aria-label` of its own.
- `modal="trap-focus"` keeps the page scrollable and clickable while still holding focus inside.
- `dismissible={false}` cancels Escape and the click on the scrim. Give that drawer actions that close it, because there will be no other way out.
- An `inline` drawer is not a dialog: it takes no focus, traps nothing, and announces nothing. Its `title` is a plain heading, so put it in the page's heading order.
- `locale` decides the ×'s accessible name; `closeLabel` writes it out instead.

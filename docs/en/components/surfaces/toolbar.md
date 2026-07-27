---
title: Toolbar
order: 7
---

# Toolbar

<p class="neba-lede">A bar of controls: an application header, a page's action row, the strip along the bottom of an editor.</p>

<Demo src="toolbar/hero" />

```tsx
import { Toolbar } from 'neba';

<Toolbar render={<header />} start={<Logo />} end={<Button>Deploy</Button>}>
  Workspace
</Toolbar>;
```

Three slots and a row. `start` and `end` are pinned to their ends and `children` takes what is left, which is the arrangement every toolbar has ever had — so it is laid out here rather than left to a caller and a spacer `<div>` they have to remember.

## Props

<PropsTable name="Toolbar" />

Every native `<div>` attribute passes through.

## Examples

### Density

A Toolbar has no height of its own. It is as tall as the controls in it plus its padding, and that padding is the `size` / `density` pair every other surface uses — so `density="compact"` gives you the dense bar without a second prop meaning the same thing, and without the type scale moving.

<Demo src="toolbar/density">

<<< @/.vitepress/demos/toolbar/density.tsx

</Demo>

### Pinned

`position` is CSS's own three values, spelled the way CSS spells them.

- `sticky` is what an application header usually wants: it takes up its own space, so nothing underneath has to be padded around it.
- `fixed` leaves the flow entirely, so the page needs padding of its own or the first screenful sits behind the bar.

A pinned bar drops its radius, because a rounded corner against the edge of the screen is a gap with nothing behind it. `divider` gives it the hairline that says there is content beneath.

<Demo src="toolbar/sticky">

<<< @/.vitepress/demos/toolbar/sticky.tsx

</Demo>

`elevation` stays `0` even when the bar is pinned. A shadow under a header is a way of saying "there is content beneath this", and that is only true once the page has been scrolled — so raise it yourself on scroll, or leave it flat and turn on `divider`.

## Why there is no `role="toolbar"`

That role is a promise about keyboard behaviour: one tab stop for the whole bar, arrow keys between the controls in it. A bar that claims it without implementing it is worse for a keyboard reader than one that never claimed anything.

What a page header wants is `render={<header />}` — a real landmark, which is the thing a screen reader user will actually navigate by. What a genuine roving-focus toolbar wants is a [ButtonGroup](../inputs/button-group), which is one.

## Coming from Material UI

| MUI | Neba |
| --- | --- |
| `<AppBar><Toolbar>…</Toolbar></AppBar>` | One component. `position` is on it directly |
| `position="sticky"` | The same. `'static'`, `'sticky'`, `'fixed'` |
| `variant="dense"` | `density="compact"` — padding, which is all `density` is ever allowed to change |
| `color="primary"` | `color` reaches the hairline and the focus ring. A bar that holds other people's controls does not dye its own sheet |
| `elevation={4}` | `elevation` is `0`–`3`, and `0` means no shadow at all |
| <code v-pre>&lt;Box sx={{ flexGrow: 1 }} /&gt;</code> as a spacer | Not needed. `start`, `children` and `end` are the three slots |

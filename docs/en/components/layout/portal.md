---
title: Portal
order: 9
---

# Portal

<p class="neba-lede">Children rendered somewhere else in the DOM, usually the end of <code>&lt;body&gt;</code>. For a subtree that has to escape a clipping or stacking context its own position would trap it in.</p>

<Demo src="portal/hero" />

```tsx
import { Portal } from 'neba';

<Portal>
  <div className="fixed inset-x-0 top-0 z-50">Announcement</div>
</Portal>;
```

## Props

<PropsTable name="Portal" />

Native `<div>` attributes pass through to the wrapper.

### Differences from `createPortal`

Two things this adds, and the first is the reason to reach for it.

The wrapper carries **`neba-portal`**. A portalled subtree leaves whatever element the page had scoped its styling to, so a scoped stylesheet loses it — and the class is how it is found again. This library's own popups already carry it, and these docs use it to re-apply a reset outside `.neba-scope`.

The second is the server. There is no `document` there, so a portal renders nothing at all until it has mounted, and the markup that ships never contains the portalled subtree. That is what a portal _is_ rather than a limitation to route around: anything that has to be in the server's HTML does not belong in one.

## Examples

### container

Where the children go. Defaults to `document.body`.

A function is called after mount, which is how a portal targets something React itself renders — `() => document.getElementById('drawer')` finds an element that did not exist when the props were built.

```tsx
<Portal container={() => document.getElementById('overlay-root')}>{children}</Portal>
```

### disabled

Renders in place instead of portalling — for a subtree that is already inside a portal, a test that wants the markup where it was written, or an embed with no `document.body` worth reaching.

**Decide it once, at mount.** A portalled subtree and an inline one are different children as far as React is concerned, so flipping this remounts everything inside and throws away what was in it: a half-filled form, a scroll position, a video that was playing. That is React's reconciliation rather than something this component can route around.

## Accessibility

- A portal moves the DOM, not the reading order a screen reader announces from — which is the DOM. Content that belongs _with_ something needs `aria-controls`, `aria-describedby` or a focus move to say so.
- Focus does not follow the children. A portalled dialog needs its own focus management; use [Dialog](../feedback/dialog) or [Drawer](../surfaces/card), which already have it.
- `Escape` and click-outside are not handled here either. This is placement and nothing else.

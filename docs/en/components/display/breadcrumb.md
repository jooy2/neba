---
title: Breadcrumb
order: 14
---

# Breadcrumb

<p class="neba-lede">The trail of pages above the one being read. Use it wherever a screen sits inside a hierarchy the reader may want to climb back out of.</p>

<Demo src="breadcrumb/hero" />

```tsx
import { Breadcrumb, BreadcrumbItem } from 'neba';

<Breadcrumb>
  <BreadcrumbItem href="/">Home</BreadcrumbItem>
  <BreadcrumbItem href="/projects">Projects</BreadcrumbItem>
  <BreadcrumbItem>Settings</BreadcrumbItem>
</Breadcrumb>;
```

## Props

### Breadcrumb

<PropsTable name="Breadcrumb" />

Every other `<nav>` attribute passes through. The shared axes are in [prop conventions](../../design/prop-conventions).

### BreadcrumbItem

<PropsTable name="BreadcrumbItem" />

Every other `<li>` attribute passes through to the step.

## Examples

### separator

`separator` takes one of four names — `chevron`, `arrow`, `slash`, `dot` — or any node. The two that point turn back under RTL.

<Demo src="breadcrumb/separators">

<<< @/.vitepress/demos/breadcrumb/separators.tsx

</Demo>

### maxItems

A trail past `maxItems` steps folds its middle away behind a `…`, which puts it back when pressed. `itemsBeforeCollapse` and `itemsAfterCollapse` decide how many stay at each end; both default to `1`. `expandable={false}` leaves the fold as a plain mark.

The fold only happens when it removes more than one step, since standing in for a single step makes the trail longer rather than shorter.

<Demo src="breadcrumb/collapse">

<<< @/.vitepress/demos/breadcrumb/collapse.tsx

</Demo>

### The current step

The last step is the page you are on, so it is not a link even when it is given an `href`. `current` on an earlier step moves that mark, and takes it off the last one.

### startIcon

<Demo src="breadcrumb/icons">

<<< @/.vitepress/demos/breadcrumb/icons.tsx

</Demo>

### size

<Demo src="breadcrumb/sizes">

<<< @/.vitepress/demos/breadcrumb/sizes.tsx

</Demo>

## Accessibility

- The trail is a `nav` named by `label`, which defaults to `Breadcrumb`, holding an ordered list.
- The current step carries `aria-current="page"`, and exactly one step in a trail ever does.
- The separators are `aria-hidden`, so a reader hears the steps and not the punctuation between them.
- The `…` is a real button named by `expandLabel`. With `expandable={false}` it is a mark and is hidden from readers.

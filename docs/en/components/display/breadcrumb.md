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

`separator` takes one of four names (`chevron`, `arrow`, `slash`, `dot`), or any node. The two that point turn back under RTL.

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

### structuredData

Correct markup alone is not what puts a path under a search result: the structured data is. Turning `structuredData` on emits a schema.org `BreadcrumbList` in a `<script type="application/ld+json">` beside the trail. `baseUrl` is what relative `href`s are resolved against, since a search engine wants an absolute URL.

Every step goes in, including the ones a `maxItems` fold is hiding: what is collapsed is a matter of how much room the row has, and the path is the path either way. A step with no `href` is emitted without an `item`, which is the last step's usual case.

It is off by default. A page can only have one `BreadcrumbList`, and a great many apps already emit theirs from an SEO layer of their own.

<Demo src="breadcrumb/structured-data">

<<< @/.vitepress/demos/breadcrumb/structured-data.tsx

</Demo>

## Accessibility

- The trail is a `nav` named by `label`, which defaults to `Breadcrumb`, holding an ordered list.
- The current step carries `aria-current="page"`, and exactly one step in a trail ever does.
- The separators are `aria-hidden`, so a reader hears the steps and not the punctuation between them.
- The `…` is a real button named by `expandLabel`. With `expandable={false}` it is a mark and is hidden from readers.
- `locale` names the nav landmark and the `…` button; `label` and `expandLabel` write them out instead.
- `structuredData` is not an accessibility feature: it is read by a crawler and draws nothing on screen.

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

The fold only happens when it removes more than one step.

<Demo src="breadcrumb/collapse">

<<< @/.vitepress/demos/breadcrumb/collapse.tsx

</Demo>

### The current step

The last step is the page you are on, so it is not a link even when it is given an `href`. `current` on an earlier step moves that mark, and takes it off the last one.

### startIcon

<Demo src="breadcrumb/icons">

<<< @/.vitepress/demos/breadcrumb/icons.tsx

</Demo>

### render

A step with an `href` is an `<a>`, which reloads the page. Pass a router's `Link` as `render` to move without a reload; `href` still goes through, so it is written once. A trail that stays mounted across a route change folds again when its steps change.

```tsx
<BreadcrumbItem href="/projects" render={<Link to="/projects" />}>
  Projects
</BreadcrumbItem>
```

### size

<Demo src="breadcrumb/sizes">

<<< @/.vitepress/demos/breadcrumb/sizes.tsx

</Demo>

### structuredData

Turning `structuredData` on emits a schema.org `BreadcrumbList` for search engines, in a `<script type="application/ld+json">` beside the trail. It draws nothing on screen. `baseUrl` is what relative `href`s are resolved against, since a search engine wants an absolute URL.

Every step goes in, including the ones a `maxItems` fold is hiding. A step with no `href` is emitted without an `item`, which is the last step's usual case.

It is off by default. Leave it off when the app already emits a `BreadcrumbList` for the page from an SEO layer of its own.

<Demo src="breadcrumb/structured-data">

<<< @/.vitepress/demos/breadcrumb/structured-data.tsx

</Demo>

## Accessibility

- The trail is a `nav` named by `label`, which defaults to `Breadcrumb`, holding an ordered list.
- The current step carries `aria-current="page"`, and exactly one step in a trail ever does.
- The separators are `aria-hidden`, so a reader hears the steps and not the punctuation between them.
- The `…` is a real button named by `expandLabel`. With `expandable={false}` it is a mark and is hidden from readers.
- `locale` names the nav landmark and the `…` button; `label` and `expandLabel` write them out instead.

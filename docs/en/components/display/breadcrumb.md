---
title: Breadcrumb
order: 14
flutter: true
---

# Breadcrumb

<p class="neba-lede">The trail of pages above the one being read. Use it wherever a screen sits inside a hierarchy the reader may want to climb back out of.</p>

<Demo src="breadcrumb/hero" />

::: fw react

```tsx
import { Breadcrumb, BreadcrumbItem } from 'neba';

<Breadcrumb>
  <BreadcrumbItem href="/">Home</BreadcrumbItem>
  <BreadcrumbItem href="/projects">Projects</BreadcrumbItem>
  <BreadcrumbItem>Settings</BreadcrumbItem>
</Breadcrumb>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaBreadcrumb(
  children: <NebaBreadcrumbItem>[
    NebaBreadcrumbItem(onPressed: openHome, href: Uri.parse('/'), child: const Text('Home')),
    NebaBreadcrumbItem(
      onPressed: openProjects,
      href: Uri.parse('/projects'),
      child: const Text('Projects'),
    ),
    const NebaBreadcrumbItem(child: Text('Settings')),
  ],
);
```

:::

## Props

### Breadcrumb

<PropsTable name="Breadcrumb" />

<Fw react="Every other `<nav>` attribute passes through." flutter="The steps wrap onto another line when the row runs out." /> The shared axes are in [prop conventions](../../design/prop-conventions).

### BreadcrumbItem

<PropsTable name="BreadcrumbItem" />

::: fw react

Every other `<li>` attribute passes through to the step.

:::

::: fw flutter

The package opens nothing itself, so a step that leads somewhere is a callback: `onPressed` calls the router, and `href` tells a screen reader, and on the web the browser, where it goes. A step with an `href` and no `onPressed` is text. Enter presses a step, and Space presses a button step but not a link.

:::

## Examples

### separator

`separator` takes one of four names (`chevron`, `arrow`, `slash`, `dot`), or <Fw react="any node" flutter="any widget, as `NebaBreadcrumbSeparator.widget(…)`" />. The two that point turn back under RTL.

<Demo src="breadcrumb/separators">

::: fw react

<<< @/.vitepress/demos/breadcrumb/separators.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/breadcrumb/separators.dart

:::

</Demo>

### maxItems

A trail past `maxItems` steps folds its middle away behind a `…`, which puts it back when pressed. `itemsBeforeCollapse` and `itemsAfterCollapse` decide how many stay at each end; both default to `1`. <Fw react="`expandable={false}`" flutter="`expandable: false`" /> leaves the fold as a plain mark.

The fold only happens when it removes more than one step.

<Demo src="breadcrumb/collapse">

::: fw react

<<< @/.vitepress/demos/breadcrumb/collapse.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/breadcrumb/collapse.dart

:::

</Demo>

### keepMounted

::: fw react

The steps a fold hides are not in the DOM by default, so a crawler reading the server render never sees their links. `keepMounted` keeps them in the DOM, hidden, and pressing the `…` shows them where they already are. `structuredData` describes the whole path either way; this puts the links themselves in the markup.

```tsx
<Breadcrumb maxItems={3} keepMounted>
  …
</Breadcrumb>
```

:::

::: fw flutter

A Flutter trail has no server render for a crawler to read, so there is no `keepMounted`. A step the fold hides is not built until the `…` is pressed.

:::

### The current step

The last step is the page you are on, so it is not <Fw react="a link even when it is given an `href`" flutter="pressable even when it is given an `onPressed`" />. `current` on an earlier step moves that mark, and takes it off the last one.

### <Fw react="target · rel" flutter="newTab" />

::: fw react

`target` decides where a step's link opens, and any target other than this tab adds `rel="noopener noreferrer"`. `rel` is written on the link as well, so a step can carry `nofollow` or `sponsored`; the two tokens a new tab needs are merged into it rather than replacing it.

```tsx
<BreadcrumbItem href="https://example.com/partners" target="_blank" rel="sponsored">
  Partners
</BreadcrumbItem>
```

:::

::: fw flutter

`newTab` says a step's link leaves the app, and a screen reader hears "(opens in a new tab)" after its label, in the trail's `locale`. Opening the tab is `onPressed`'s, through whatever launcher the app uses; there is no `rel`.

```dart
NebaBreadcrumbItem(
  onPressed: openPartners,
  href: Uri.parse('https://example.com/partners'),
  newTab: true,
  child: const Text('Partners'),
);
```

:::

### startIcon

<Demo src="breadcrumb/icons">

::: fw react

<<< @/.vitepress/demos/breadcrumb/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/breadcrumb/icons.dart

:::

</Demo>

### render

::: fw react

A step with an `href` is an `<a>`, which reloads the page. Pass a router's `Link` as `render` to move without a reload. Keep the `href` on the step as well: it goes through to the `Link`, and it is the address `structuredData` writes out. A trail that stays mounted across a route change folds again when its steps change.

```tsx
<BreadcrumbItem href="/projects" render={<Link to="/projects" />}>
  Projects
</BreadcrumbItem>
```

:::

::: fw flutter

A Flutter step has no element to swap. A router's navigation goes in `onPressed`. A trail that stays where it is across a change of page folds again when its steps change.

:::

### size

<Demo src="breadcrumb/sizes">

::: fw react

<<< @/.vitepress/demos/breadcrumb/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/breadcrumb/sizes.dart

:::

</Demo>

### structuredData

::: fw react

Turning `structuredData` on emits a schema.org `BreadcrumbList` for search engines, in a `<script type="application/ld+json">` beside the trail. It draws nothing on screen. `baseUrl` is what relative `href`s are resolved against, since a search engine wants an absolute URL.

Every step goes in, including the ones a `maxItems` fold is hiding. A step with no `href` is emitted without an `item`, which is the last step's usual case.

It is off by default. Leave it off when the app already emits a `BreadcrumbList` for the page from an SEO layer of its own.

:::

::: fw flutter

There is no `structuredData` and no `baseUrl`: a Flutter screen has no markup for a search engine to read.

:::

::: fw react

<Demo src="breadcrumb/structured-data">

<<< @/.vitepress/demos/breadcrumb/structured-data.tsx

</Demo>

:::

## Accessibility

::: fw react

- The trail is a `nav` named by `label`, which defaults to `Breadcrumb`, holding an ordered list.
- The current step carries `aria-current="page"`, and exactly one step in a trail ever does.
- The separators are `aria-hidden`, so a reader hears the steps and not the punctuation between them.
- The `…` is a real button named by `expandLabel`. With `expandable={false}` it is a mark and is hidden from readers.
- Steps a fold keeps in the DOM under `keepMounted` are hidden, so they are out of the tab order and the accessibility tree until the trail unfolds.
- `locale` names the nav landmark and the `…` button; `label` and `expandLabel` write them out instead.

:::

::: fw flutter

- The trail is a navigation region named by `label`, which defaults to `Breadcrumb`, holding a list of its steps. The web reads them as `role="navigation"`, `role="list"` and `role="listitem"`.
- The current step is selected, which the web writes as `aria-current="true"`, and exactly one step in a trail ever is.
- The separators are left out of the semantics tree, so a reader hears the steps and not the punctuation between them.
- The `…` is a button named by `expandLabel`. Pressed from the keyboard, it hands the focus to the first step it was hiding. With `expandable: false` it is a mark and is hidden from readers.
- `locale` names the navigation region and the `…` button; `label` and `expandLabel` write them out instead.

:::

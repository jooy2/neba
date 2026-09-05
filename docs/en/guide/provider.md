---
title: NebaProvider
order: 3
---

# NebaProvider

<p class="neba-lede">One place to set what every component under it starts from: the prop values a product has decided on, the colour scheme a reader has chosen, and the direction the document runs in. It is optional, and every component works without it.</p>

```tsx
import { NebaProvider } from 'neba';

<NebaProvider defaults={{ size: 'sm', density: 'compact', locale: 'ko' }}>
  <App />
</NebaProvider>;
```

It renders no element of its own. Three jobs are together here because all three are properties of the **application** rather than of any control in it.

## defaults

Four axes: `size`, `density`, `variant` and `locale`. Writing `size="sm"` at four hundred call sites is the problem this exists to end.

<Demo src="provider/defaults">

<<< @/.vitepress/demos/provider/defaults.tsx

</Demo>

A call site still wins. The order is **the caller, then the provider, then the component's own default**, so a `<Button size="xl">` inside a `size="xs"` provider is `xl`, and a component with no `size` prop is untouched.

### The four axes

|  |  |
| --- | --- |
| `size` `density` `variant` `locale` | The right value is a property of the product. A dense application is dense everywhere; a Korean one is Korean everywhere. |
| `color` | **Not defaultable.** A component's colour default is often semantic: an [Alert](../components/feedback/alert) is `info`, a [Popconfirm](../components/feedback/popconfirm) is `danger`, severity carries meaning: and one global override would silently repaint those into something that means something else. |
| `elevation` | **Not defaultable.** A shadow is opt-in per surface, which the [design language](../design/design-language) is explicit about. An application-wide one is the moulded-plastic look the whole thing is against. |

Each component is filled only on the axes it actually declares. A key a component does not take would otherwise ride its props spread onto a DOM node, and `size` on an `<input>` is a real attribute that would quietly resize the field.

## Colour scheme

```tsx
<NebaProvider defaultColorScheme="system">
```

The provider writes `data-theme` and `color-scheme` onto `<html>`, remembers the choice in `localStorage`, and hands the state to `useColorScheme()`.

`color-scheme` matters as much as the attribute: it is what turns the browser's own furniture over. The scrollbars, the form controls it still draws itself, the canvas behind an overscroll. A page that changes only its own colours keeps a white scrollbar down the side of a dark one.

<Demo src="provider/color-scheme">

<<< @/.vitepress/demos/provider/color-scheme.tsx

</Demo>

### useColorScheme

```tsx
const { colorScheme, resolvedColorScheme, setColorScheme, toggleColorScheme } = useColorScheme();
```

`colorScheme` is what was **asked for**, `system` included. `resolvedColorScheme` is what that comes out as right now, and is never `system`. The difference is what a three-way switch needs: `system` has to show as its own position rather than as whichever of the two it currently resolves to.

### The flash

React runs after the document has been painted once, so a remembered dark page flashes white on the way in. That is the one thing a provider cannot fix for you, and `colorSchemeScript()` is the fix:

```tsx
<script dangerouslySetInnerHTML={{ __html: colorSchemeScript() }} />
```

Inline it in `<head>`, above everything. It reads the same key and writes the same attribute the provider does, which is why it is a function here rather than a snippet in this page that somebody copies once and never updates.

### storageKey

`'neba-color-scheme'` by default. Pass your own, or `false` to apply the scheme for this visit and forget it. Storage is never allowed to throw: a private window that denies the write still gets the scheme, it just does not remember it.

## direction

```tsx
<NebaProvider direction="rtl">
```

Sets `dir` on `<html>` and wraps the tree in Base UI's own `DirectionProvider`, so its primitives flip their keyboard handling and their positioning with the page.

It is **left alone when it is not given**, so a document that already sets `dir` itself (most localised applications do, in the server-rendered HTML) is not fought over.

The components are built on logical properties (`margin-inline-start` and the rest) rather than physical ones, so the layout follows on its own. What needs `dir` is the handful of places a glyph has to turn: the calendar's steppers, a Breadcrumb's separators, a Carousel's arrows, a TreeView's disclosure.

## Nesting

Providers nest, and the nearest one wins. A settings panel that previews a scheme, or a compact toolbar inside a comfortable page, is a second provider around that subtree.

Two things are **not** scoped, because they are attributes on `<html>`: the colour scheme and the direction. A nested provider that wants to repaint only its own subtree points `colorSchemeElement` at an element of its own: which is exactly what the preview above does, and why that prop is a function rather than an element.

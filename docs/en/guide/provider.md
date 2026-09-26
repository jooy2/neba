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

Five axes: `size`, `density`, `variant`, `locale` and `labelPlacement`. Writing `size="sm"` at four hundred call sites is the problem this exists to end.

<Demo src="provider/defaults">

<<< @/.vitepress/demos/provider/defaults.tsx

</Demo>

A call site still wins. The order is **the caller, then the provider, then the component's own default**, so a `<Button size="xl">` inside a `size="xs"` provider is `xl`, and a component with no `size` prop is untouched. A `ButtonGroup` or `ToggleGroup` sits between the caller and the provider: a Button in a `size="lg"` group under a `size: 'sm'` provider is `lg`.

### The five axes

|  |  |
| --- | --- |
| `size` `density` `variant` `locale` `labelPlacement` | The right value is a property of the product. A dense application is dense everywhere, a Korean one is Korean everywhere, and a form puts all its labels in one place. `labelPlacement` reaches every field that draws a shell: TextField, NumberField, Select, Combobox and the pickers. |
| `color` | **Not defaultable.** A component's colour default is often semantic. An [Alert](../components/feedback/alert) is `info` and a [Popconfirm](../components/feedback/popconfirm) is `danger` because severity carries meaning, and one global override would silently repaint those into something that means something else. |
| `elevation` | **Not defaultable.** A shadow is opt-in per surface, which the [design language](../design/design-language) is explicit about. An application-wide one is the moulded-plastic look the whole thing is against. |

Each component is filled only on the axes it actually declares. A key a component does not take would otherwise ride its props spread onto a DOM node, and `size` on an `<input>` is a real attribute that would quietly resize the field. One axis a component declares is left out on purpose: a [TextLink](../components/display/text-link) takes no `size` from the provider, because a link in a sentence is the size of the sentence.

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

Providers nest. A settings panel that previews a scheme, or a compact toolbar inside a comfortable page, is a second provider around that subtree. An inner provider's `defaults` are merged over the outer ones, so an inner `density` keeps the outer `size`, and an inner provider with no `direction` runs the way the outer one does.

```tsx
<NebaProvider defaults={{ size: 'sm' }}>
  <NebaProvider defaults={{ density: 'compact' }}>
    <Toolbar>{/* compact, and still small */}</Toolbar>
  </NebaProvider>
</NebaProvider>
```

The colour scheme on `<html>` belongs to the outermost provider, and a nested one does not write it. A nested provider that wants to repaint its own subtree points `colorSchemeElement` at an element of its own. The preview above does exactly that, and it is why the prop is a function rather than an element. `direction`, when a nested provider sets one, is still written on `<html>`.

---
title: Breakpoints
order: 4
---

# Breakpoints

Five widths, and one rule about how a value moves between them. Every responsive prop in the library reads them the same way, and so does every media query the stylesheet writes.

## The ladder

```ts
type NebaBreakpoint = 'xs' | 'sm' | 'md' | 'lg' | 'xl';
```

| Name | Floor   | What it usually is                               |
| ---- | ------- | ------------------------------------------------ |
| `xs` | `0rem`  | A phone. The value with no media query around it |
| `sm` | `40rem` | A large phone, or a phone turned sideways        |
| `md` | `48rem` | A tablet                                         |
| `lg` | `64rem` | A laptop                                         |
| `xl` | `80rem` | A desktop                                        |

They are Tailwind's own defaults, which is the point: a Neba layout and a `md:` utility change at the same pixel, so the two can be mixed on one page without a second set of numbers to keep in step.

The five names are the same five `NebaSize` uses, and deliberately not the same idea. A `size` of `md` is how big a control is; a breakpoint of `md` is how wide the window is. They share a spelling because a reader who has learned one ladder should not have to learn a second set of words for the other.

## Every entry is a floor

A responsive prop takes a bare value or a partial map, and **each entry applies from its own breakpoint up**.

```tsx
<Grid span={{ xs: 12, md: 6 }} />
```

Full width until 48rem, half from there on — including at `lg` and `xl`, which the map never mentions. There is no value that means "only at this width", which is what makes two entries enough to describe most layouts.

The other half of the rule is that a map **narrows** a prop rather than replacing it. A `spacing` of `{ md: 4 }` keeps the documented default of `2` below 48rem rather than falling through to nothing; naming one breakpoint never silently takes the value away everywhere else. The same holds when two props overlap: `columnSpacing` is laid over `spacing`, and wins from wherever it first speaks.

## Which props are responsive

> A prop is responsive when its value fits in an inline custom property. It is not when its value is a class name.

Tailwind only ever sees class names written out literally, so a per-breakpoint class map would mean five complete ladders in the bundle of every page that draws the component. A `--n-*` slot costs one inline declaration and one cascade in the stylesheet, shared by every instance on the page.

| Responsive | Not responsive |
| --- | --- |
| `span`, `offset` on [Grid](../components/layout/grid) | `size` |
| `columns`, `spacing`, `rowSpacing`, `columnSpacing` on [GridContainer](../components/layout/grid) and [Flex](../components/layout/flex) | `variant` |
| `direction` on [Flex](../components/layout/flex) | `color` |
| `maxWidth` on [Container](../components/layout/container), [Header](../components/layout/header) and [Footer](../components/layout/footer) | `elevation` |

The list on the left is short on purpose. Each slot is four media blocks that cannot be generated, so adding one is a decision rather than a convenience.

## Deciding in CSS or in JavaScript

Both are available and they are not interchangeable.

**[Show](../components/layout/show)** decides in CSS. The children are always rendered and what changes is `display`, so the answer is right in the first frame the browser paints, it is the same answer on a server, and a resize repaints instead of re-rendering React.

```tsx
<Show above="md">
  <Sidebar />
</Show>
```

**`useBreakpoint` and `useBreakpointValue`** decide in JavaScript, and can do the one thing CSS cannot: not render something at all. They answer `false` and `xs` on a server and on the first client render, so what they control arrives after hydration — which is a flash if it is a layout, and correct if it is a component that must not run.

```tsx
const columns = useBreakpointValue({ xs: 1, md: 3 }) ?? 1;

return useBreakpoint('md') ? <Map /> : <StaticImage />;
```

`useBreakpointValue` reads a map exactly as the cascade does, so the floor rule above is the same rule in both places.

## Changing the widths

A breakpoint is a **build-time** decision. `@media` cannot read a custom property, so no amount of runtime configuration — a provider prop, a context — can move one, and anything that appeared to would move the JavaScript while leaving the CSS where it was.

What it can be is a decision you take part in. The library's media queries are written as `theme(--breakpoint-*)`, which resolves in whichever Tailwind build compiles the stylesheet, so redeclaring them in your own theme moves everything at once — the library's own rules, the `md:` variants its components spell out, and the JavaScript, which reads the resolved widths back off the document.

```css
@import 'tailwindcss';
@import 'neba/tailwind.css';

@theme {
  --breakpoint-md: 50rem;
}
```

This needs the Tailwind path. A project on `neba/styles.css` gets a stylesheet that was compiled here, with the five widths already baked into it; the names still work, but the numbers are the ones in the table above. If you need to move them, run Tailwind — [getting started](../guide/getting-started) has both setups.

Changing the _names_ is not supported on either path. Five is what the type says, what the class tables are written out to, and what the cascades in the stylesheet resolve through.

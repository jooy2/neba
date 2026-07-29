---
title: Getting started
order: 1
---

# Getting started

Neba is a React component library. Behaviour and accessibility come from [Base UI](https://base-ui.com) primitives; styling comes from [Tailwind CSS](https://tailwindcss.com) v4.

## Install

```bash
npm install neba
```

`react` and `react-dom` have to be in the project already.

## Wiring up Tailwind

Neba ships exactly one CSS file. Add two lines to your app's CSS entry point.

```css
@import 'tailwindcss';
@import 'neba/styles.css';
```

| Line | What it does |
| --- | --- |
| `@import 'tailwindcss'` | Tailwind itself |
| `@import 'neba/styles.css'` | The design tokens (colour, radius, elevation, motion), the `.neba-glow` layers, and the `@source` that registers the package |

That is the whole setup — you do not write an `@source` of your own.

The classes Neba's components use are Tailwind utilities, so Tailwind does have to read the package's compiled files to find them. `neba/styles.css` takes care of that by declaring `@source '.'` inside itself: `@source` resolves relative to the file it is written in, which here is `node_modules/neba/dist/`, right next to those files. An explicitly registered source is scanned even inside `node_modules`, which automatic detection skips.

The upshot is that nothing depends on where your own CSS file sits. If you have seen `@source '../node_modules/neba'` in an older README, you can delete it — that path was only correct for a CSS file exactly one directory deep.

`neba/styles.css` is otherwise plain custom properties, so importing it without Tailwind still gives you the tokens; the `@source` line is simply an at-rule the browser ignores.

## Use

```tsx
import { Button } from 'neba';

export default function App() {
  return <Button onClick={() => console.log('clicked')}>Save</Button>;
}
```

## Dark mode

The default follows `prefers-color-scheme`. To force it either way, put a class or a `data-theme` on any ancestor.

```text
<html data-theme="dark">   <!-- or --> <html class="dark">
```

For light, use `data-theme="light"` or `class="light"`. `.dark` is supported alongside it to match Tailwind's own convention.

## Next

- [All components](../components/) — everything released, on one page
- [Examples](../examples/) — the components together on a single screen
- [Prop conventions](../design/prop-conventions) — what the shared props mean
- [Design language](../design/design-language) — why the surfaces, colours and motion look like this

## Browser support

The tokens use `oklch()`, `color-mix()` and `backdrop-filter`. That means Chrome, Safari and Firefox from 2023 onwards. Where `backdrop-filter` is missing only the blur drops out; everything else still works.

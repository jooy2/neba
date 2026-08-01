---
title: Getting started
order: 1
---

# Getting started

Neba is a React component library. Behaviour and accessibility come from [Base UI](https://base-ui.com) primitives; styling comes from [Tailwind CSS](https://tailwindcss.com) v4. Tailwind is used to build this package and does not have to be installed in yours.

## Install

```bash
npm install neba
```

`react` and `react-dom` are peer dependencies — **React 18 or 19**. If your project already has one of them, that is the copy Neba uses; if it does not, npm 7 and later install them for you. Everything else the package brings with it.

## Wiring up the stylesheet

Add one line to your app's CSS entry point.

```css
@import 'neba/styles.css';
```

If your bundler handles CSS, importing it from your entry module works just as well.

```ts
import 'neba/styles.css';
```

`neba/styles.css` is **finished CSS**: the design tokens (colour, radius, elevation, motion), the `.neba-glow` layers, the real rules behind every utility class the components use, and a small reset. There is no build-side configuration, no PostCSS plugin and no `@source`.

### About the reset

`neba/styles.css` includes the global reset the components are written against — Tailwind's Preflight cut down to what they actually need: `box-sizing`, font inheritance on form controls, list markers off. It does not touch the typography of your paragraphs, headings or links.

Every rule in it is wrapped in `:where()`, so it has **specificity 0**. A single type selector of your own — `p { margin: 1rem }` — beats it, whatever the import order. The reset is a floor under the components, not a claim on your page.

### If you already use Tailwind

When Tailwind v4 is already in your project, import the token sheet instead of the compiled one. Nothing is generated twice, and a `className` you pass to a component sorts correctly against the component's own classes.

```css
@import 'tailwindcss';
@import 'neba/tailwind.css';
```

| Line | What it does |
| --- | --- |
| `@import 'tailwindcss'` | Tailwind itself |
| `@import 'neba/tailwind.css'` | The design tokens, the `.neba-glow` layers, and the `@source` that registers the package |

You do not write an `@source` of your own on this path either. The classes Neba's components use are Tailwind utilities, so Tailwind has to read the package's compiled files to find them; `neba/tailwind.css` takes care of that by declaring `@source '.'` inside itself. `@source` resolves relative to the file it is written in, which here is `node_modules/neba/dist/`, right next to those files. An explicitly registered source is scanned even inside `node_modules`, which automatic detection skips.

The upshot is that nothing depends on where your own CSS file sits. If you have seen `@source '../node_modules/neba'` in an older README, you can delete it — that path was only correct for a CSS file exactly one directory deep.

This path carries no reset, because Preflight already is one.

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
- [Examples](../examples/overview) — the components together on a single screen
- [Prop conventions](../design/prop-conventions) — what the shared props mean
- [Design language](../design/design-language) — why the surfaces, colours and motion look like this

## Browser support

The tokens use `oklch()`, `color-mix()` and `backdrop-filter`. That means Chrome, Safari and Firefox from 2023 onwards. Where `backdrop-filter` is missing only the blur drops out; everything else still works.

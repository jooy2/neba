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

`react` and `react-dom` are peer dependencies: **React 18 or 19**. If your project already has one of them, that is the copy Neba uses; if it does not, npm 7 and later install them for you. Everything else the package brings with it.

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

`neba/styles.css` includes the global reset the components are written against: Tailwind's Preflight cut down to what they actually need. It leaves the font size of your paragraphs and the look of your links alone, but it does change headings and a few margins, which the list below names.

Every rule in it that selects an element is wrapped in `:where()`, so it has **specificity 0**. A single type selector of your own (`p { margin: 1rem }`) beats it, whatever the import order. A pseudo-element cannot go inside `:where()`, so the few rules on one, such as `::placeholder`, weigh what a type selector does, and a rule of your own on the same pseudo-element wins by coming after the import. The reset is a floor under the components, not a claim on your page.

It is global, though, so on a page that already has markup of its own, anything that relied on the browser's defaults for these changes when the stylesheet is added:

- Every element is `border-box`.
- Headings, paragraphs, `blockquote`, `figure`, `pre` and `hr` have no margin, and headings take the size and weight of the text around them.
- `ul`, `ol` and `menu` have no markers and no indent. Safari's VoiceOver does not announce a list whose markers were removed in CSS, so give a list in your own prose `role="list"` if it should still be read as one.
- A `<button>`, `<input>`, `<select>` or `<textarea>` of your own has no border, no background and square corners.

Style those in your own CSS where you want them back. A project that already runs Tailwind should take the path below, which carries no reset at all.

### If you already use Tailwind

When Tailwind v4 is already in your project, import the token sheet instead of the compiled one. Nothing is generated twice, and a `className` you pass to a component is generated in the same pass as the component's own, which is what lets the two be ordered against each other at all. That does not make yours win. Which of two utilities for the same property applies is decided by Tailwind's own ordering, so reach for the important modifier (`h-8!`) when the answer has to be yours. See [prop conventions](../design/prop-conventions).

```css
@import 'tailwindcss';
@import 'neba/tailwind.css';
```

| Line | What it does |
| --- | --- |
| `@import 'tailwindcss'` | Tailwind itself |
| `@import 'neba/tailwind.css'` | The design tokens, the `.neba-glow` layers, and the `@source` that registers the package |

Do not import `neba/styles.css` as well, or in place of `neba/tailwind.css`. Tailwind v4 puts your utilities in a cascade layer, while the rules in the compiled sheet sit outside any layer, so a component's own rule beats a class you pass for the same property, whatever its specificity. `className="px-10"` on a `Button` leaves the button's own padding in place, and only an important class such as `px-10!` gets through.

You do not write an `@source` of your own on this path either. The classes Neba's components use are Tailwind utilities, so Tailwind has to read the package's compiled files to find them; `neba/tailwind.css` takes care of that by declaring `@source '.'` inside itself. `@source` resolves relative to the file it is written in, which here is `node_modules/neba/dist/`, right next to those files. An explicitly registered source is scanned even inside `node_modules`, which automatic detection skips.

The upshot is that nothing depends on where your own CSS file sits. If you have seen `@source '../node_modules/neba'` in an older README, you can delete it: that path was only correct for a CSS file exactly one directory deep.

This path carries no reset, because Preflight already is one.

## Use

```tsx
import { Button } from 'neba';

export default function App() {
  return <Button onClick={() => console.log('clicked')}>Save</Button>;
}
```

## Next.js and React Server Components

**Every Neba component carries `'use client'`.** Import one into a Server Component and it works: there is no wrapper to write and no `transpilePackages` entry to add.

```tsx
// app/page.tsx — a Server Component
import { Button, Card } from 'neba';

export default function Page() {
  return (
    <Card>
      <Button>Save</Button>
    </Card>
  );
}
```

The directive marks a boundary, not a page. The page above stays a Server Component; only the components it renders are sent to the browser.

The ordinary rule about that boundary still holds: **props cross it, functions do not**. A handler defined in a Server Component cannot be passed to a Neba component:

```tsx
// ✗ Event handlers cannot be passed to Client Component props
<Button onClick={() => save()}>Save</Button>
```

Put the interactive part in a module of your own that starts with `'use client'`, the way you would with any other component.

The stylesheet is imported once, in the root layout:

```tsx
// app/layout.tsx
import 'neba/styles.css';
```

Two things are deliberately **not** client modules: the `neba` barrel and `neba/locales`. The barrel only re-exports, so a Server Component importing it reaches the components behind it rather than a boundary of its own; and `registerMessages` stays a plain function you can call anywhere. Because the components read the registered language while they render (which happens once on the server and once in the browser), register it from a module that is in the client graph:

```tsx
// app/neba-locale.tsx
'use client';

import { registerMessages, ko } from 'neba/locales';

registerMessages('ko', ko);

export function NebaLocale({ children }: { children: React.ReactNode }) {
  return children;
}
```

Render that around your app in `app/layout.tsx`.

### Everywhere else

`'use client'` is a string at the top of a file. Bundlers that do not implement Server Components (Vite, webpack, Remix, Astro, Parcel, plain React) ignore it, so nothing above changes what the package does in those projects. Register a language in a module that both the server render and the browser load, such as the entry both of them import, so the two render the same words.

## Server rendering

Whatever renders the page on a server, React hydrates it in the browser and expects both to have drawn the same thing. A few habits keep that true.

**Pass a `locale`.** A component that writes a date or a number without one formats as `en-US` on the server and while it hydrates, then switches to the reader's language right after. The page is never thrown away, but the text changes once, a moment after it appears. A date picker's field can also widen at that moment where the reader's language writes longer dates, and the controls beside it move. Give every component the same language from the start with `NebaProvider`, which also spares each of them the second render it otherwise makes once the page has hydrated:

```tsx
<NebaProvider defaults={{ locale: 'ko-KR' }}>{children}</NebaProvider>
```

**Mind the time zone.** A `locale` decides the language, not the clock. A `Date` is written in the time zone of whatever renders it, so a server in UTC and a reader in Los Angeles can disagree about which day `2026-03-03T00:00Z` is. When the two can be in different zones, pass a chart its categories as strings you formatted yourself, or render the date only in the browser.

**Pin the first day of the week.** Calendars and date pickers ask the browser which day a week starts on, and older browsers cannot answer. Pass `weekStartsOn` on a server-rendered page.

**Give a chart an `initialWidth`.** A chart is laid out in pixels, and a server has no box to measure, so a server-rendered chart is an empty box of the right height until the page hydrates. Pass the width it is usually shown at, and the server's HTML and the first paint carry the drawing; the chart draws itself again at its measured width once the page runs. The drawing makes the HTML larger, so keep it for the charts a reader sees first.

**Keep the first screen on `trigger="mount"`.** An `Animate*` component with `trigger="visible"`, `"hover"` or `"manual"` waits at its first frame, which is often invisible, until the page runs and the trigger fires, so what it wraps cannot be the page's largest paint before then. The default, `"mount"`, plays from the first paint without any script.

**Tell a `Shortcut` the platform.** With `os="auto"` the server draws the Windows keys, and a Mac switches to its own at hydration, which moves the text after the shortcut. Read the platform from the request's `User-Agent` and pass it as `os`.

**Write the colour scheme before React.** `colorSchemeScript()` is a plain function, so the root layout can call it even where that layout is a Server Component. The script sets an attribute and a style on `<html>` before React hydrates, so tell React to expect that:

```tsx
// app/layout.tsx
import { colorSchemeScript } from 'neba';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <script dangerouslySetInnerHTML={{ __html: colorSchemeScript() }} />
      </head>
      <body>{children}</body>
    </html>
  );
}
```

Call it with the same `storageKey` and `defaultColorScheme` you give `NebaProvider`. In a development build the provider warns when the scheme already on `<html>` is not the one it resolves.

**Put `dir` in the HTML.** `NebaProvider`'s `direction` writes `dir` on `<html>` once the app is running. A right-to-left page should already carry `dir="rtl"` in the HTML the server sends, or the first paint is laid out left to right.

## Dark mode

The default follows `prefers-color-scheme`. To force it either way, put a class or a `data-theme` on any ancestor.

```text
<html data-theme="dark">   <!-- or --> <html class="dark">
```

For light, use `data-theme="light"` or `class="light"`. `.dark` is supported alongside it to match Tailwind's own convention.

## Browser support

Neba supports Chrome and Edge 111, Firefox 113 and Safari 16.4 or later. [Browser support](../browser-support) covers what sets that range and which details differ inside it.

## Next

- [All components](../components/): everything released, on one page
- [Examples](../examples/overview): the components together on a single screen
- [Prop conventions](../design/prop-conventions): what the shared props mean
- [Design language](../design/design-language): why the surfaces, colours and motion look like this

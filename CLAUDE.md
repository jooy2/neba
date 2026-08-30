# CLAUDE.md

Guidance for Claude Code (and other AI agents) working in this repository.

## What this project is

**Neba** is a React design-component library published to npm as [`neba`](https://www.npmjs.com/package/neba). It provides Neba-styled UI components meant to be consumed by other websites and apps.

- Ships as **ESM only**, type declarations included.
- Compiled with plain `tsc` (no bundler) and then minified — the output mirrors the `src/` folder layout.
- Runtime dependencies: `@base-ui/react` (Base UI), and `highlight.js` — which only `CodeBlock` reaches, only through a dynamic import, and therefore never lands in a bundle that did not ask for it. See `src/internal/highlight.ts` for why it is a `dependencies` entry rather than an optional peer.

## Repository layout

| Path | Purpose |
| --- | --- |
| `src/` | **The library itself.** The only code that gets published. |
| `src/index.ts` | Public entry point. Every exported component must be re-exported from here. |
| `src/components/{name}/` | One folder per component (lowercase folder name). |
| `src/internal/` | The library talking to itself. Shipped but never re-exported from `src/index.ts`. |
| `src/locales/` | One module per language, plus `registerMessages`. Public, reached as `neba/locales`; **not** re-exported from `src/index.ts`, because nothing here should be in a bundle that did not ask for it. |
| `test/` | Test suite (Vitest). Mirrors the `src/` tree. Self-contained: owns its `tsconfig.json`. |
| `docs/` | VitePress site — developer-facing documentation for library consumers, and the only place components are rendered during development. Self-contained: owns its `tsconfig.json`. Not published to npm. |
| `dist/` | Build output (`tsc` + terser). Generated; never edit by hand, never commit. |

There is no separate demo app. `docs/` renders the real components from `src/` through a Vite alias, so `npm run docs:dev` is the develop-and-eyeball loop.

**The docs never read `dist/`, and none of the `docs:*` scripts build it.** The alias points `neba` at `src/index.ts` and `theme/styles/index.css` imports `src/styles.css` directly, so a component edit is on screen without a rebuild — which is the whole reason the alias exists. `npm run build` used to run first in all three scripts and cost about ten seconds of `format:fix`, `tsc` and terser that nothing then looked at, and it rewrote the files being edited while the dev server was starting. Do not put it back: if the docs ever need a built artefact, that is the thing to question.

Three TypeScript projects, each with its own config, because their compiler needs genuinely differ (the library emits declarations; the docs and the tests are `noEmit` and need DOM libs):

- `tsconfig.json` / `tsconfig.prod.json` — the library in `src/`. `prod` is what `npm run build` compiles.
- `test/tsconfig.json` — tests.
- `docs/tsconfig.json` — the VitePress config and the docs' React demos.

`npm run typecheck` runs all three. Root-level configs deliberately exclude `test/` and `docs/`.

## Adding or changing a component

Each component lives in `src/components/{name}/`:

```
src/components/button/
  Button.tsx     # implementation, named export
  index.ts       # export { Button } from './Button.js';
```

Then re-export it from `src/index.ts`:

```ts
export * from './components/button/index.js';
```

Note both extensions. **Every relative specifier in `src/` ends in `.js`, and a directory is written out to its `index.js`** — see [Packaging](#packaging-bundle-size-and-tree-shaking) for why, and `test/package/resolution.test.ts` for the check that keeps it true.

Rules to follow:

1. **Folder name is lowercase** (`button`, `text-field`); the file and the exported symbol are `PascalCase` (`Button.tsx` → `Button`).
2. **Use named exports**, never `export default`.
3. Each component folder gets its own `index.ts` barrel; `src/index.ts` only ever re-exports those barrels. Grow this list as components are added. The barrel is also the component's public entry point — `neba/button` resolves to it through the `./*` pattern in `exports`, so a new folder needs no `package.json` edit.
4. When a component is added, document it under `docs/` — see [Documentation](#documentation) for the five places that means. That is also what makes it viewable alongside the others.
5. **The file starts with `'use client';`** — every component, no exceptions. See [The client boundary](#the-client-boundary).
6. **Tests are part of the change, not a follow-up.** See the rule below.

### The client boundary

**Every `src/components/**/*.tsx` begins with `'use client';` on line one**, and so does every module anywhere in `src/` that calls a React API missing from React's `react-server` build — `useState`, `useEffect`, `useLayoutEffect`, `useRef`, `useContext`, `useReducer`, `useSyncExternalStore`, `createContext` and the rest. Those are not exported at all under the `react-server` condition, so `import * as React from 'react'` hands a server render an `undefined` and the failure is a `TypeError` in someone's Next.js app, not a degraded render. `test/package/resolution.test.ts` asserts it.

All of them, and not only the ones that hold state today. Thirteen components would technically survive a server render right now, and eight of those are Base UI form controls a consumer puts inside a client boundary anyway. The other five are one prop from failing: `transition` is `internal/animate.ts`, which is a `useLayoutEffect`, and `render` is Base UI's `useRender`, which is a hook — nearly every component in the library already takes one or the other. A per-component answer would be a table that rots. "Every Neba component is a client component" is a sentence a consumer can hold, and it costs nothing measurable: `npm run size` did not move by a byte, because a bundler hoists the directive rather than shipping it a hundred and six times.

Three things are deliberately **left unmarked**, and each would break if it were not:

- **`src/index.ts` and the component barrels.** A barrel only re-exports. Unmarked, it is a module either graph may pull in, so a Server Component importing `neba` reaches the client modules behind it; marked, it would become a boundary of its own and drag the whole barrel across.
- **`src/locales/**` and `src/internal/i18n.ts`.** `registerMessages` is a plain function a consumer calls at module scope, and `useMessages` is a `useMemo`, which the `react-server` build does export. Marked, `registerMessages` would come back to a consumer's server module as a client reference instead of a function, and calling it would throw.
- **The rest of `internal/`** — the arithmetic, the tables, the glyphs, `sizer.tsx`, `picker.tsx`. A module with no directive belongs to whichever graph imports it, which is exactly right for these; only the seven that hold a context or an effect (`animate.ts`, `button-group.ts`, `menu.ts`, `page-layout.ts`, `bottom-navigation.ts`, `calendar.tsx`, `chart-frame.tsx`) are marked.

The directive only survives the build because `terser.config.json` says `compress.directives: false`. See [Toolchain notes](#toolchain-notes).

### Tests ship with the component

Every change to a component carries its test changes in the same commit. This is not optional and not deferred to a later cleanup pass.

- **Adding a component** → add `test/components/{name}/{Name}.test.tsx` covering what the component itself does: it renders, its props map to the rendered output, and its interactive behavior works.
- **Adding a prop or behavior** → add cases for it. A new prop with no test is an incomplete change.
- **Changing existing behavior** → update the existing tests to match the new intent. Never delete or skip a failing test to make a build pass; either the test encodes the old contract and should be rewritten, or it caught a real regression.
- **Renaming or removing a component** → move or delete its test file so the `test/` tree keeps mirroring `src/`.

Run `npm test` before considering the change done. If a component's shape makes it hard to test, that is usually a signal about the component's API, not about the test.

## Styling and behavior conventions

- **Styling: Tailwind CSS v4**, applied through `className`. Tailwind is wired via PostCSS (`postcss.config.mjs` → `@tailwindcss/postcss`); there is no `tailwind.config.js` — v4 is configured in CSS.
- **Behavior/logic: [Base UI](https://base-ui.com) (`@base-ui/react`)** — use its unstyled primitives for interaction, state, and accessibility, and layer Tailwind classes on top. This is the pattern in `Button.tsx`, which wraps `Button` from `@base-ui/react/button`.
- **Fallback:** if neither Tailwind nor Base UI can express what a component needs, plain native React/DOM code is acceptable. Prefer the stack above first.
- `prettier-plugin-tailwindcss` sorts Tailwind class strings — do not hand-order classes; run the formatter.

## The design language

**[docs/ko/design-language](docs/ko/design/design-language.md) is the source of truth. Read it before styling anything.** The rules below are the ones most easily broken by accident; the document explains why each exists.

The governing idea: **a Neba surface is a sheet of cut acrylic, not a moulded plastic key.** Every rule below follows from that.

- **No `transform` on a control, ever.** Scaling resamples the label, and text that shifts under the cursor is what reads as cheap. State changes are expressed in colour and depth only.
- **Press is instant, release is slow.** Per-property `transition-duration` with `:active` overriding everything to `0ms`. The same asymmetry drives the afterglow layer. This is the house interaction signature.
- **`elevation` defaults to `0` and `0` means no shadow at all.** The acrylic edge separates a surface from the page; a drop shadow is opt-in. Shadows are never tinted with the control's own colour.
- **No dark bottom bevel** (`inset 0 -1px 0 black`). Top light edge plus a full white hairline only — and no plate at all on a Checkbox, a Radio or a Switch, where a 1px line is a fifteenth of the object rather than light on an edge.
- **Translucency is tuned with the blur radius, not just the alpha.** Too much blur smears the backdrop into flat colour and the surface reads opaque again.
- **`density` changes padding only** — never height, never type scale.
- **Don't express state with `opacity`.** Each state gets its own axis (saturation, colour family, flatness).

Implementation rules that are easy to get wrong:

- **Branch state in JS, not in stacked Tailwind variants.** Two variants of equal specificity resolve by their order in the generated stylesheet. Use `disabled ? … : readOnly ? … : …`.
- **Per-colour values go in inline `--n-*` slots, not in generated class names.** Tailwind only sees literal class names, so `[--n-fill:var(--neba-primary-fill)]` per family does not scale. `styleSlots()` in `Button.tsx` is the pattern.
- **Never `outline-none`.** Tailwind v4 routes outline style through `--tw-outline-style`, which `outline-none` zeroes — killing the focus ring. Use the shorthand: `focus-visible:[outline:2px_solid_var(--n-ring)]`.
- **Derived tokens are repeated per theme root.** A custom property resolves its `var()`s on the element that declares it, so a derived token declared only on `:root` freezes to light-theme values inside a `.dark` subtree.
- **Adding a colour family = two edits.** One entry in `NebaColor` and five tokens in `src/styles.css`. Everything else is derived with `color-mix()`.

### Shared prop vocabulary

`src/types.ts` holds the vocabulary every component draws from: `NebaSize`, `NebaColor`, `NebaDensity`, `NebaVariant`, `NebaElevation`, `NebaOrientation`, `NebaSide`, `NebaAlign`, and the `NebaStyleProps` bundle. A `size` of `md` must mean the same thing on every component. **Do not invent a second spelling for an idea that already has one** — see [docs/ko/design/prop-conventions.md](docs/ko/design/prop-conventions.md).

The same rule applies to the values behind those names, which is what `src/internal/styles.ts` is for. Control heights, radii, type scales, the two padding tracks, the _sheet_ ladder a Card, an Alert and a Dialog share, the frosted surface, the house transition, the focus ring and the `--n-*` slot generators live there once and every component imports them. A component keeps only what genuinely differs: its variant class maps and its layout. If you find yourself writing `h-8` or `rounded-(--neba-radius-md)` into a component, check whether the table already says it.

`src/internal/button-group.ts` holds the context `ButtonGroup` provides and `Button` reads as a fallback — and `ToggleGroup` provides and `Toggle` reads, because it is the same six values and a second context spelled identically would only be a second chance to disagree. It lives in `internal/` so the two components do not import each other; `List`, `Accordion` and `Tabs` have the same arrangement but keep their context in their own file, because each is a parent and its rows in one file. `src/internal/menu.ts` is the exception that proves the rule: `Menu`, `ContextMenu`, `Menubar` and every row read the same context, and a submenu is a menu inside a menu, so four components need it and none of them should have to import the others.

`src/internal/sizer.tsx` is `WidthSizer`, and it is in `internal/` because Select, the picker shell and DateRangePicker all need it. A control that is not `fullWidth` is sized by what it is _currently_ saying, so a Select showing `Seoul` is narrower than the same Select showing `Washington DC` and a DatePicker on the 1st is narrower than the same picker on the 28th — the field moves under the pointer that just used it. The sizer lays out every alternative in a clipped, zero-height, `aria-hidden` box, which pins the intrinsic width to the widest of them. A **string** sample is drawn as generated content off a `data-sample` attribute rather than as a text node: it lays out identically so it reserves the same width, and it leaves nothing for a `getByText` or a find-in-page to match, which is what would otherwise make every query for a chosen value ambiguous in a consumer's tests. Only a sample that is not a string — a Select option whose label is a node — is rendered for real.

Five more files in `internal/` exist for the same "written once" reason. `progress.ts` is the arithmetic and the ladders the three progress indicators share — they are one component in three shapes, and a `value` of `null` has to mean the same thing on all of them. `icons.tsx` is the glyphs more than one component draws: the × that Chip, Alert, Dialog, Toast and FilePicker all need; the chevron, drawn pointing **down** once and turned by whoever needs it — Select's trigger, Accordion's header, a submenu's arrow, Pagination's steppers — because rotating a glyph is the one allowance the no-transform rule makes; the tick and the dot that Select and the menu's checkable rows share; and the severity set, which is a piece of the design language rather than a convenience — an alert that says "this went wrong" only in red says it only to some readers, so the shape has to carry the meaning too, and that only holds if every component uses the same shape for the same family. That set is reached through `severityIcon(color)` rather than a `Record` of elements, for the reason the i18n tables are one per namespace: a component that draws a single mark imports that mark, and no React elements are built at import time for a page that may draw none of them.

`internal/animate.ts` is the eleventh reason: eleven `Animate*` components need one table of effects, and the `transition` prop needs the same table from the other side — a Card and an `AnimateFade` must produce the same fade, or the library has two fades. Nothing in it generates CSS. Every effect is one `@keyframes` in `styles.css` running from a state written entirely in `--n-*` custom properties to the element's natural one, so the file only fills slots — the same split `styleSlots()` makes for colour, for the same reason. Because the from-state is the keyframe rather than a second class, `mode="out"` is `animation-direction: reverse` and costs nothing on all six. What is deliberately _not_ there is any effect that has to know what its children are: a marquee that duplicates them, a headline that swaps between them, a typewriter that counts characters. Those are components, and their logic stays in their own files.

`internal/chart.ts`, `internal/chart-frame.tsx` and `internal/chart-line.tsx` are the three files the charts are built out of, and the split between them is the same one the rest of the folder makes. `chart.ts` is arithmetic and knows nothing about React or SVG: scales, nice numbers, the monotone interpolation, the arc and bar paths, the palette slots, and the estimate of how wide a string renders — which is an estimate on purpose, because the alternative is a canvas measurement on a path that runs on every resize. `chart-frame.tsx` is everything a chart draws that is **not** its marks — the axes, the grid, the crosshair, the legend, the tooltip, the empty state, the measurement that turns a percentage width into pixels, and the visually hidden table a screen reader reads instead of the picture — so a component hands it a function that draws marks and keeps only that. `chart-line.tsx` is the marks a LineChart and an AreaChart share, because an area is a line with the space under it filled and writing the path arithmetic twice would mean two different `curve="smooth"`s. Sparkline deliberately routes through none of it: it has no axes, no legend and no stacking, and what it needs is two calls into `chart.ts`.

Three rules there are load-bearing rather than stylistic. A **`null` is a gap and not a zero**, everywhere — a line breaks at it, an area breaks with it, a bar is not drawn, and the table cell is empty; a chart that renders missing data as zero reports an outage as a collapse. A **series' colour follows its index in the array it was passed**, never its position among the currently visible ones, so filtering a legend cannot repaint the survivors. And the **eight `--neba-chart-*` slots are handed out in order and never cycled** — the order is what makes the _adjacent_ pairs the ones that were checked for colour-vision separation, so a ninth series is an "Other" row or a second chart, not a ninth hue. The ramp's numbers were solved rather than picked; the note above them in `styles.css` says what they satisfy.

`src/internal/page-layout.ts` is the same arrangement `menu.ts` makes, one level up: PageLayout, Header, Footer, Sidebar and SidebarTrigger all read one context, every one of them is also usable on its own, and keeping it in PageLayout's file would make a Header import a layout it may never be inside. What is in there is only what a slot cannot work out from where it sits — which end of the band a sidebar took, the width at which the sidebars stop being columns, whether a drawer is open. The layout itself is flexbox and media queries, stated in CSS so it is right in the first frame the browser paints; the only measurement is the header's and the footer's height, written onto the root as `--n-layout-*`, and only because a sticky sidebar has to start below a bar whose height nobody but the bar knows. Whether it has to is read off the bar's own computed `position` rather than plumbed through a prop.

`internal/avatar-group.ts` is `button-group.ts` again, one component over: an Avatar reads what the stack around it set, and the two must not import each other.

`internal/initials.ts` is one function and it is here for `button-group.ts`'s reason: an Avatar with no photograph and an AppLogo with no artwork both have to say what the first letter of a name is, and a library with two of those rules spells the same person's initials two ways on one page.

`internal/highlight.ts` is the one module in the library that _loads_ rather than imports. Colouring a language means knowing that language, and there are thirty-four of them, so highlight.js is the second runtime dependency — reached as `lib/core` plus one module per grammar, never the package root, and every one of those specifiers behind an `import()`. That is the whole design rather than a nicety: a bundler emits each as its own chunk, so `highlight={false}` downloads nothing and a page colouring TypeScript downloads TypeScript. It is a real `dependencies` entry rather than an optional peer because a specifier a bundler cannot resolve fails the _whole_ build — Rollup walks and resolves `CodeBlock.js` while it is still deciding whether to keep it — so an optional peer would break `import { Button } from 'neba'` for anyone who had not installed a highlighter. The loaders are written out one line each rather than built from a template literal, for `i18n.ts`'s reason in a different shape: an unresolvable dynamic specifier makes every bundler emit a chunk for all hundred and ninety languages. What comes back out is not HTML — `tokenize` turns highlight.js's nested spans into lines of coloured runs, because a line is what carries a number, a prompt and a place in a scroll, and because a span may cross a newline so nothing can simply `split('\n')`. It is also why nothing in the library writes `dangerouslySetInnerHTML`.

`internal/color.ts` is the arithmetic ColorPicker needs — three representations, the conversions between them, one parser and one formatter. It is a hundred lines, and it is the whole reason the package still has one runtime dependency. HSV is the model the panel is drawn in and it never leaves: round-tripping through RGB would lose the hue of every greyscale colour, and the rail would snap to red the moment the pointer reached a corner.

`internal/i18n.ts` is the words the library says on its own behalf. Almost nothing in Neba writes text a reader sees — a Button says what it was handed — so this is only for the strings a component has to invent because there is nowhere else for them to come from: the sentence behind a link that opens a new tab, the label on the button that uncovers a Spoiler, the word under a chat message that says it was read. They are collected because they are a set: a product in Korean does not want eight components each defaulting to English and each needing an override prop of its own. Nothing `Intl` already knows goes in here — month names, weekday names and AM/PM come from the platform, which is why the date pickers do **not** read this file for those. A component that reads it takes a `locale` **and** an override prop for the string itself, so an unsupported language is never a dead end.

Two things about its shape are load-bearing, and both are the same rule about what a bundler can drop. **There is one exported table per namespace and never one table of all of them**, because a bundler drops an unused `export const` and cannot drop a key out of an object literal — a single table put the ColorPicker's seven colour words and the Table's seven column words behind a Chip that wanted the word "Remove", which was fourteen and a half kilobytes gzipped under a two-kilobyte component. And **only English ships**; the other eighteen languages are one module each under `src/locales/`, registered by the consumer:

```ts
import { registerMessages, ko } from 'neba/locales';

registerMessages('ko', ko);
```

A registered language costs about 1.9 kB gzipped, and a product that says nothing carries none of them. `registerMessages` writes into the namespace tables and drops what it invalidates out of the resolution cache, so registering after something has already rendered still takes (it does not re-render that tree — register at module scope). A tag is resolved by script, then by region, then by language; each language fills in as much as it has and is merged over English at read time, so a partial translation is a partial translation rather than a page of blanks.

Adding a namespace is therefore a new `export const` beside the others **and** a field on `NebaLocale` — never a new key inside an existing table. Adding a language is a new file under `src/locales/` and a line in its barrel.

### Table cells are the exception to "styling is Tailwind"

`Table` writes its cell padding, alignment, backgrounds and row rules as **inline styles**, not utilities. This is not a shortcut. `<td>` and `<th>` are among the very few tags a host stylesheet still styles by name — VitePress's `.vp-doc td`, Tailwind Typography's `.prose td`, every CSS framework — always at two-class specificity that a one-class utility cannot outrank. Every one of those declarations silently lost before the styling moved inline.

The row's own background stays a utility, because it has a hover state and inline styles have no `:hover`. It reads a `--n-row` slot that classes then set: a custom property is invisible to a host stylesheet, so a variant wins there without a fight. `paddingXValues` in `internal/styles.ts` is `paddingXClasses` as raw lengths for exactly this; keep the two in step.

An `<a>` is the other one, and TextLink answers it the other way. Inline styles are no use there — half of what a link draws only exists on `:hover` — so the selector is doubled instead: `.neba-link.neba-link` in `styles.css` carries the invariants (the line's thickness, its offset, its colour, the weight), and the two things a prop changes, the colour and whether the line is drawn, are written in the component through `[&.neba-link]`. Two classes clears `.prose a` and `.vp-doc a` and still loses to anything a caller writes with two classes of their own. The class is also a hook a host stylesheet can exempt, the way the docs' `scope.css` does — the same arrangement as `neba-portal`.

### The stylesheet ships

`tsc` emits JavaScript and nothing else, so every `.css` under `src/` reaches `dist/` through `scripts/build-styles.mjs`, which runs last in `npm run build`. It writes **two** files, and their names cross over:

| Source | Output | Exported as | For |
| --- | --- | --- | --- |
| `src/standalone.css` | `dist/styles.css` | `neba/styles.css` | a project with no Tailwind — compiled, ~16 kB gzipped |
| `src/styles.css` | `dist/tailwind.css` | `neba/tailwind.css` | a project that runs Tailwind v4 itself |

`src/styles.css` is the token sheet: the custom properties, the `.neba-glow` layers, and its own `@source '.'`. `src/standalone.css` is a four-line build entry that puts `src/reset.css`, Tailwind's theme and utilities, and that token sheet in order; Tailwind compiles it here so the consumer never runs Tailwind at all. `tailwindcss` is and stays a devDependency.

**Do not fold the two into one.** A precompiled sheet cannot take part in a consumer's own Tailwind build, so a `className` they pass to a component would no longer sort against the component's own classes — and a `@source` left in a precompiled file would make their build generate every utility a second time.

**The `@source` is what keeps the setup one line — or, on the Tailwind path, two rather than three.** `@source` resolves relative to the file it is written in, not to whatever imported it, so one declaration serves three contexts: `node_modules/neba/dist/` for a consumer who runs Tailwind, `src/` for the standalone build and for this repository's own docs. An explicitly registered source is scanned even inside `node_modules`, which automatic detection skips. Never tell a consumer to add an `@source` of their own, since that path would depend on where their CSS file sits. The docs rely on the same mechanism: `theme/styles/index.css` registers only the docs' own directories.

`src/reset.css` is Preflight cut down to what the components actually need and de-escalated: every selector is wrapped in `:where()`, so a consumer's `p { margin: 1rem }` outranks it without `!important`, a layer, or a particular import order. It is reachable only through `src/standalone.css` — a project with Preflight already has all of it. The docs' `theme/styles/scope.css` is the same idea solved the other way, scoped to `.neba-scope` because a VitePress page cannot lose its own typography; the two are separate on purpose and the specificity hazard scope.css documents does not exist in `reset.css`.

Pseudo-element styling (the pointer spotlight, the release afterglow) lives in `styles.css` as real CSS rather than as Tailwind arbitrary variants — `[&::before]:[background:radial-gradient(...)]` is expressible and unreadable. That is the bar for moving something out of Tailwind: not "could this be CSS", but "is the Tailwind form unmaintainable".

## Packaging, bundle size and tree-shaking

A component library's real size is not its `unpackedSize` and not what a badge reports. It is what lands in the bundle of someone who imports _some_ of it, and that number is decided by things that fail silently. Measure with a real bundler, `react` external, judged on gzip, across a fixed set of scenarios — one component, a handful, all of them.

`npm run size` does exactly that and fails when a scenario goes more than 2% over its recorded budget; `npm run size:update` rewrites the budgets after a change that is meant to move them. Both need `npm run build` to have run first, because they measure `dist/`. The scenarios and their budgets live together in [scripts/bundle-budget.json](scripts/bundle-budget.json), so changing what is measured and changing what it may weigh are one edit, and CI runs the check on its own job.

Where it stands, gzipped, with `react`/`react-dom` external:

| What a consumer imports       | Bundle   | Of which is Neba's own code |
| ----------------------------- | -------- | --------------------------- |
| `Divider`                     | 3.0 kB   | 1.3 kB                      |
| `Button`                      | 5.0 kB   | 2.2 kB                      |
| `Chip`                        | 3.0 kB   | 3.0 kB                      |
| `LineChart`                   | 11.0 kB  | 9.5 kB                      |
| `CodeBlock`                   | 4.8 kB   | 4.8 kB                      |
| 12 components — a typical app | 67.0 kB  | 10.6 kB                     |
| 25 components — a large one   | 110.8 kB | 16.4 kB                     |
| a whole page shell            | 28.1 kB  | 8.5 kB                      |
| all 126 exports               | 215.3 kB | 103.7 kB                    |

The page shell row is `PageLayout` with `Header`, `Footer`, `Sidebar`, `SidebarTrigger` and `AppLogo`, and two thirds of it is the Base UI dialog a collapsing sidebar becomes below its breakpoint.

The CodeBlock row is the whole of what a page downloads before it draws a block, and it is 4.5 kB because **the grammars are not in it**. highlight.js is reached through `import()` — the core in one chunk, one chunk per language — so a block that colours TypeScript fetches about 11 kB more _after_ the first paint, one that colours nothing fetches none of it, and the thirty-four grammars are 63.5 kB of chunks a page never asks for in full. `npm run size` prints that async total beside every scenario, unbudgeted, so it can never quietly become the entry's problem: the day the import turns static, the 4.5 kB becomes 68.

Registering one language adds about 1.9 kB on top. Plus `neba/styles.css`, which is 19.7 kB gzipped and very nearly fixed: a single `Button` needs 10.8 kB of it, so the marginal cost of a component is about 0.07 kB. **Splitting the stylesheet per component was measured and rejected** — it would buy a twelve-component app about 5 kB while duplicating the shared two thirds across ninety-six files.

CodeBlock's eight ported themes are the one deliberate exception to that marginal cost: they are 0.8 kB gzipped of the sheet, which everybody carries and only a CodeBlock user sees. The alternative was measured too — ship them as JS token objects and tree-shake per theme — and rejected, because it costs the two things that make the CSS form worth having: `theme` stays a string, and a consumer's own `[data-code-theme='ours']` block is a theme with nothing to import and nothing to register. The derived slots are what keep the number to 0.8: `dim`, `rule`, `hover` and the two a marked line uses are mixed from each theme's own `bg` and `fg`, so a theme is fourteen declarations rather than nineteen.

`@base-ui/react` is roughly half of the maximum and most of what a Select or a Dialog costs. It is already imported per subpath (`@base-ui/react/button`, never the root), which is the only lever there is: the goal is not to slim it but to make sure a page that does not use a Select never meets it.

Five things hold the numbers above in place. Each of them, broken, is invisible in this repository and expensive in someone else's:

1. **`sideEffects: ["**/*.css"]`.** The single line that lets a bundler drop the ninety-odd components a page did not import. Widen it and every consumer ships the whole library.
2. **Every relative specifier ends in `.js`.** `tsc` under `module: Preserve` emits specifiers verbatim, so an extensionless `export * from './types'` reaches `dist/` unchanged — and Node's ESM resolver rejects it, as does TypeScript under `moduleResolution: node16`, where it takes out every named export of the barrel at once. Vite resolves it fine, which is exactly why nothing in this repository noticed for eighty-eight components.
3. **An `@__PURE__` annotation on every `forwardRef`, `createContext` and `memo` call.** A bundler cannot prove `React.forwardRef(…)` is side-effect free, so in a file that exports more than one component the unused ones survive. `scripts/annotate-pure.mjs` writes them into `dist/` between `tsc` and `terser` — never into `src/`, where sixteen characters in front of an already long line makes Prettier rewrap the signature and re-indent the whole function body, which was one annotation and a hundred-line diff in seventy-seven files. It counts what it marked against what `src/` contains and fails the build on a mismatch, because the failure mode of a pattern over emitted code is that it quietly stops matching. Terser then has to be told to write the annotations out again: `output.preserve_annotations` in `terser.config.json`. The two settings are useless apart, and removing either silently costs about a quarter of a multi-part component.
4. **Fixed-cost modules stay divisible.** A table every component reaches through is a table every component pays for in full. `i18n.ts` is one export per namespace and English only; `icons.tsx` reaches its severity set through a function. The rule generalises: an object literal cannot be tree-shaken per key, so anything that would grow past a few hundred bytes belongs in separate exports or separate modules.
5. **Every component is its own entry point.** `neba/button`, through the `./*` pattern in `exports`. The bundle is the same either way — `import { Button } from 'neba'` already shakes correctly — but the barrel makes a bundler parse two hundred modules to keep five, and the subpath makes it parse five. It is also the escape hatch for a build that ignores `sideEffects`.

`test/package/resolution.test.ts` asserts all five as structure; `npm run size` asserts the bytes they add up to. Both are needed: a change can keep every invariant above and still double what a consumer downloads, and a change can break one of them without moving a scenario the budget happens to measure.

Things measured and **rejected**, so they do not get re-litigated: minifier option tuning (under 1%), splitting the stylesheet per component (above), dropping Tailwind's `@property` fallback for older Safari (0.4 kB gzip), and per-key tree-shaking of the size and density ladders in `internal/styles.ts` (impossible in principle, and they are a few hundred bytes).

## Documentation

The docs are VitePress, and VitePress compiles Markdown to **Vue** — so a React component cannot be written into a page. Every live preview is a React island: `theme/components/Demo.vue` owns a `<div>` and hands it to `createRoot()` on mount.

```
docs/.vitepress/
  config.ts                 # React plugin, the `neba` alias, the repo's PostCSS config, i18n
  data/props.ts             # the props tables, as data — both locales per row
  data/i18n.ts              # the few strings the docs' own components render
  demos/{component}/*.tsx   # one file per example — real, runnable React
                            # folder name matches the component's own, lowercased
  demos/home/hero.tsx       # the home page's hero object
  demos/concepts/*.tsx      # one whole fictional screen per file, for Examples
  theme/
    components/Layout.vue   # the default layout + the home page's mark and live hero
    components/Demo.vue     # the React island + the show-code toggle
    components/PropsTable.vue
    styles/index.css        # Tailwind (no Preflight) + tokens + docs chrome
    styles/scope.css        # Preflight, cut down and scoped to `.neba-scope`
    styles/docs.css         # the docs' own furniture: Demo frame, props table, home
    custom.css              # the default theme's shell: sidebar, article and outline widths
docs/public/                # served at `/` — the mark, the icons, llms.txt
docs/{ko,en}/
  index.md                  # home — `layout: home`, with a live hero and body sections
  guide/getting-started.md  # install and set up — the only page in Guide
  components/index.md       # the index grid of every component
  components/{group}/*.md   # one page per component, grouped (display, feedback, inputs, surfaces)
  examples/overview.md      # every component on one sample screen
  examples/concept-*.md     # one fictional screen per page (landing, dashboard, signup)
  design/*.md               # design language, colour, prop conventions
  changelog.md              # generated from the root CHANGELOG.md; git-ignored
```

**The sidebar is four sections: Guide, Components, Design, Discover more** — with the component groups kept as headings inside Components. Almost none of that can be stated by the folder tree, so `arrangeSidebar` in `config.ts` reshapes the generated menu once per locale:

- **The index page is an entry, not the heading's link.** Left to the generator, `/components/` is only reachable by clicking the word "Components" above the menu, which does not look like a link. It becomes a row of its own and the heading stops being clickable. `groupLabels.overview` names it ("All components" / "모든 컴포넌트"), because the page's own title is "Components" and a row repeating the heading directly above it says nothing.
- **Examples** keeps its own top-level URLs but reads as part of Components. A group nested in the menu and not in the filesystem is exactly the case a generated sidebar has no way to state. It has **no `index.md` on purpose** — `/examples/` is four pages, one whole screen each, and an index listing only those four would be a row of links standing where the heading already is. `groupLabels.examples` names it, and the nav points at `examples/overview`. It is also the one subgroup inside Components that is not flattened.
- **The component groups stay** — they are what say that a Combobox is an input and a Card is a surface, and fifty pages in one list say nothing. What is flattened is only what is _inside_ a group, so a folder that gains a subfolder does not push its pages a level deeper.
- **Inside a group the pages are sorted by name**, not by their `order` frontmatter. A group holds up to nineteen components and nobody remembers where Slider sits in a curated order. `order` still decides inside Design.
- **Design and Discover more are named in `groupLabels`**, because neither has an `index.md` to take a heading from and the generated fallback would put an English word over Korean pages. The component groups take their heading from the folder name and stay English in every locale.

The groups are folders, and which one a component belongs in is decided by what it does rather than by what it looks like:

- **`inputs`** — the reader acts on it. Button, IconButton, ButtonGroup, SegmentedButton, Toggle, ToggleGroup, Form, Fieldset, TextField, NumberField, OtpField, Select, Combobox, Checkbox, RadioGroup, Switch, Slider, Menu, Menubar, NavigationMenu, CommandPalette, FilePicker, Transfer, Pagination, ColorPicker, DatePicker, TimePicker, DateTimePicker, DateRangePicker.
- **`display`** — it shows something and nothing more. Typography, TextLink, Blockquote, Highlight, Divider, Chip, Badge, Avatar, AvatarGroup, AppLogo, Icon, Shortcut, List, DataList, Table, CodeBlock, Timeline, Breadcrumb, Anchor, TreeView.
- **`charts`** — it draws numbers. Statistic, Sparkline, LineChart, AreaChart, BarChart, PieChart. Statistic lives here rather than in `display` because what a reader is looking for is not "a component that shows a value" but "the place the charts are", and a number with a delta on it is the smallest chart on the page. The group is also what the shared data model is documented against: every one of them takes the same `series`/`data`, so the pages cross-reference one definition rather than each restating it.
- **`feedback`** — it says what happened, or what is happening. Alert, Dialog, Toast, Tooltip, Overlay, ProgressLinear, ProgressCircular, ProgressBox, Meter, Tour.
- **`surfaces`** — it draws a sheet and holds other things on it. Box, Card, Accordion, Tabs, Carousel, Toolbar, Pill, Spoiler, HowToSteps, ChatBubble, HoverCard.
- **`layout`** — it decides where things go. Container, Grid + GridContainer, Panes, ScrollArea, and the four that build a page's shell: PageLayout, Header, Footer, Sidebar. The first three draw nothing at all; the page shell is the exception, and a deliberate one — a header and a sidebar are _regions_, and a region has an edge. What they still do not decide is the gutter or the measure inside them, which is Container's, so a PageLayout with a Container in it is the ordinary arrangement.
- **`transitions`** — it draws nothing either, and moves what is inside it. The eleven `Animate*` wrappers: AnimateFade, AnimateGrow, AnimateZoom, AnimateSlide, AnimateRotate, AnimateBlink, AnimateAppear, AnimateTyping, AnimateLighting, AnimateMarquee, AnimateHeadline. They are their own group rather than part of `layout` because a layout component is about where something sits and these are about how it got there; and they are one group rather than two — the six that are only a keyframe and the five that have to understand their children — because a reader looking for "the animation ones" is looking for one place.

`layout` is separate from `surfaces` for that last reason: a Container is a gutter and a Grid is a width, and the moment either one had a surface it would stop being usable as the outermost thing on a page. Header, Footer and Sidebar sit here rather than in `surfaces` on the other half of the same argument — a Card is a sheet you put things on and could be anywhere, while a header is the top of the page and is only ever one thing.

**The changelog is generated, not written.** There is one `CHANGELOG.md` and it lives at the repository root, where npm and anyone browsing the repo expects it. `scripts/copy-changelog.mjs` writes it into `docs/{locale}/changelog.md` with the frontmatter the sidebar needs, and `npm run docs:dev` / `docs:build` run it first. The copies are git-ignored; never edit them.

Things that will bite:

- **The locale routing is a three-way agreement.** `vitepress-i18n` puts the root locale in `locales.root` with no path prefix, `vitepress-sidebar` is told to resolve its links against `/`, and `rewrites` is what actually moves `docs/ko/**` to `/`. Change one and every sidebar link 404s — which is exactly what happened when `rewrites` still said `en/:rest*`. Other locales keep their folder as their URL prefix.
- **A demo is referenced twice, by the same path.** `<Demo src="button/variants">` mounts `demos/button/variants.tsx`, and the `<<< @/.vitepress/demos/button/variants.tsx` snippet inside it is what gets displayed. That is deliberate — the code shown is the file that ran, so the two cannot drift. Blank lines around the `<<<` are required, or Markdown swallows it into the HTML block.
- **Demos import from `'neba'`**, aliased to `src/index.ts`. The displayed source is then exactly what a consumer would write, and a component edit shows up without a rebuild.
- **Demos are written in English and shared by every locale** — they are code samples, and the repo writes code in English. Only the two that are documentation rather than sample code (`gallery/all.tsx`, and anything like it) take the `locale` prop `Demo.vue` passes in and localise themselves. Prose belongs in the Markdown around the preview.
- **A props row carries both languages.** `data/props.ts` keys every description by locale, so a Korean and an English table cannot drift into listing different props.
- **Tailwind ships without Preflight here.** Preflight resets `h1`…`p`, links and lists globally, which would flatten VitePress's own typography. `scope.css` re-applies only the parts the library depends on (above all `border: 0 solid`) inside `.neba-scope`. Utilities are imported _unlayered_ on purpose: VitePress's theme is unlayered, and a layered rule loses to an unlayered one no matter how specific.
- **`.vp-doc` is already styling the preview.** Base UI renders a `<p>` for a field description; a card footer can hold an `<a>`. Rules that undo `.vp-doc` need two classes to outrank it — that is why half of `scope.css` is prefixed `.vp-doc .neba-scope`. Where the component itself has to win against `.vp-doc` rather than merely survive it — table cells — the fix belongs in the component, inline, not here; there is no specificity that both beats `.vp-doc td` and loses to a utility.
- **Every tag that reset names is a tag whose padding a component can no longer set.** `.vp-doc .neba-scope` is two classes and a padding utility is one, so the `padding: 0` list in `scope.css` is kept to exactly what something actually pads: `ul`, `ol` and `blockquote`. It once included `li` and `figure`, and a Timeline's `pb-6` between steps and a Blockquote's whole inset silently came out as zero. `[role="list"]` is excluded for the same reason — it is what List, Timeline and Pagination put on their root, so it marks the lists whose padding belongs to the component.
- **A portalled popup leaves `.neba-scope`.** Select's popup renders at the end of `<body>`, outside the element the preview mounted into. Its positioner carries `neba-portal`, which `scope.css` hangs the same reset off. The library treats that class as a hook, not a style; a consumer with real Preflight needs nothing.
- **Dark mode is free.** VitePress puts `.dark` on `<html>`, which `src/styles.css` already answers to.
- **A preview can be in the theme the page is not in.** `Demo.vue` puts `data-theme` on `.neba-demo-canvas` only, which makes the canvas a theme root of its own; the attribute is absent until someone presses the switch, so an untouched preview is exactly what it always was and still follows the site switch. Only the canvas — the frame, the "Show code" bar and the snippet stay on the page theme, because VitePress selects Shiki's dark tokens with `.dark …` and its light ones with `html:not(.dark) …`, and the second of those cannot be beaten from inside the page. The canvas backdrop is therefore mixed from `--neba-fg`/`--neba-surface` rather than taken from `--vp-c-bg-soft`: a VitePress variable would stay on whatever the site switch says. **A portalled popup still does not follow it** — a Select's list or a Dialog renders at the end of `<body>`, outside the canvas, so it comes up in the page's theme.
- The docs' `<Demo>` is client-only, so an SSR build renders an empty box and fills it on hydration.
- **A preview mounts when it is on screen, not when the page loads.** A component page holds a dozen of them and mounting all at once put the one being read behind chunks for previews far below the fold. What is already visible is measured in `onMounted` and mounts straight away — an `IntersectionObserver` reports its first entry a task later, and the preview at the top of the page is what that task would delay — and everything else waits for the observer. React and its DOM renderer are fetched when `Demo.vue` is _evaluated_ rather than inside a lifecycle hook, so the largest download on the page starts during hydration instead of after it. The empty box holds `minHeight` (40px by default, a `<Demo>` prop), and it keeps holding it once the components are there, because a reserve that is dropped on arrival is the same jump twice.
- **`optimizeDeps.include` is derived from `src/`, not written out.** Every `@base-ui/react` subpath is reached only through a demo, which is reached only through a dynamic import, so the dev server would discover them one preview at a time and re-optimize — reloading the page under whoever is reading it. `server.warmup` pre-transforms `src/**` for the same reason: the first preview otherwise asks for all hundred and ten modules at once, through the barrel. The demos are deliberately not warmed; there are two hundred of them.
- **The lede is also the page's `<meta name="description">`.** `transformPageData` reads it out of the source, because VitePress otherwise gives every page the site's own description and a hundred and thirty-five pages ship one sentence between them. A page with no lede falls back to its first prose paragraph, which is why the guide and the design notes still get one. Write the lede as a sentence that stands alone in a search result and both jobs are done at once. Everything else a crawler reads — the canonical URL, the `hreflang` pair, Open Graph, the home page's JSON-LD — is assembled in `transformHead`, which runs **only in a build**: check it by reading a file under `docs-dist/`, never in the dev server. `robots.txt` is written there too, from `package.json`'s `homepage`, so the sitemap it names cannot drift from the sitemap that exists.
- **The shell's own widths are in `theme/custom.css`.** The sidebar, the article and the outline are sized against each other, and the outline runs to `h3` — a component page is one `h2` with a dozen prop names under it. Every rule in that file overrides a Vue scoped style, so each selector deliberately carries one class more than it needs: a scoped rule compiles with a `[data-v-…]` on it, and an equally specific override would be decided by stylesheet order.

Adding a component means seven edits: a page under `components/{group}/` **in every locale**, its rows in `data/props.ts`, its demo files under `demos/`, a card in `demos/gallery/all.tsx`, a place on the sample screen in `demos/showcase/app.tsx`, a line in `docs/public/llms.txt`, and its name in the right group under **Components** in [README.md](README.md). Only the first is per-locale; the demos and the props data are shared.

The last two are the two that get forgotten, because nothing renders them and no build fails without them. Both are lists of every component the library has, read by someone — or something — deciding whether to use it at all: `llms.txt` is the whole site flattened for an agent, so a component missing from it does not exist as far as that reader is concerned. Neither has a generator; check them against `src/index.ts` when a release is being cut.

### How a component page is written

A component page is reference material for someone deciding whether this component solves their problem and then wiring it up. It is not a design essay and not a gallery. Every page follows the same skeleton, in this order:

1. `# Name` — the exported symbol.
2. **A lede** (`<p class="neba-lede">`) — one or two sentences, at most three: what the component _is_ and what it is _for_. Written as prose, not as a fragment. A reader who knows nothing about the library should be able to tell from the lede alone whether to keep reading.
3. **The hero preview** — `<Demo src="{component}/hero" />`, with **no explanatory prose attached to it**, followed by the minimal `import` + usage snippet.
4. `## Props` — `<PropsTable name="…" />`, one for each exported part. Directly under it, only the mechanical facts: which native attributes pass through, what is excluded, and a link to [prop conventions](docs/ko/design/prop-conventions.md) for the shared axes.
5. `## Examples` — one `###` per prop or capability worth showing. Each has a **short, concrete heading** and one to three sentences that say what the prop controls, which values it takes, and how to use it.
6. `## Accessibility` — optional, a bullet list. Only real obligations on the caller and real guarantees of the component.

Rules that hold across every page:

- **No design rationale, no "why we did it this way", no internals.** Anything shaped like _"the reason X is a prop and not a sub-component is…"_, _"a shadow would make it read as moulded plastic"_, or _"Base UI handles the roving tab index"_ belongs in [design-language](docs/ko/design/design-language.md) or in the source, not on a component page. State the behaviour; drop the justification.
- **No comparisons to other libraries and no migration tables.** Material UI, Ant Design, Chakra — a "Coming from …" section is out of scope. Mention Base UI or Tailwind only where a caller must act on it (a `render` prop's contract, a class name they have to register); never as provenance or credit.
- **Example headings name the prop and its effect** — `### variant`, `### Multi-select`, `### Bounding the range`. Never a sentence, a claim, or a slogan (`### 배지는 알약이어도 되는 유일한 것입니다` is exactly wrong).
- **Concise but complete.** Short sentences, concrete nouns, no abstraction for its own sake. A developer should finish the page knowing how to call the component and what it will do — nothing on the page exists to show the design off.
- **Use the real vocabulary of UI work.** `trigger`, `popup`, `controlled`, `roving tab index`, `scrim`, `elevation`, `breakpoint`, `gutter` — the precise term, not a paraphrase of it.
- **Component names stay in English, everywhere, in every locale** — `Button`, not `버튼`. Link to the component's own page on the first mention when a page other than its own refers to it.
- **The lede is raw HTML, so no Markdown works inside it.** `<p class="neba-lede">` opens an HTML block, and a `[Button](./button)` written in there renders as literal brackets — this is why no lede carries a link. Component names in a lede stay plain text; put the link on the first mention in the body instead. `<code>` tags are fine, since that is HTML too.
- **In non-English locales, technical terms stay in English.** `prop`, `variant`, `controlled`, `breakpoint`, `focus`, `hover`, `portal` are written as-is; do not invent Korean calques for them. The surrounding prose is idiomatic Korean — natural enough that it does not read as a translation.
- **The locales are structural mirrors.** Same headings in the same order, same demos, same number of examples. Only the prose language differs.

## Commands

All scripts run from the repository root, even the ones whose config lives in a subdirectory.

```bash
npm test              # Vitest, single run (headless Chromium)
npm run test:watch    # Vitest in watch mode
npm run typecheck     # tsc --noEmit over all three TS projects
npm run docs:dev      # VitePress docs site — the develop-and-eyeball loop (copies the changelog first)
npm run docs:changelog # copy the root CHANGELOG.md into each locale (git-ignored)
npm run build         # format:fix + tsc (tsconfig.prod.json) + terser minify + build-styles → dist/
npm run size          # bundle the budget scenarios against dist/ and fail if one is over
npm run size:update   # record what they weigh now as the new budgets
npm run lint          # ESLint
npm run lint:fix      # ESLint with --fix
npm run format:fix    # Prettier write
```

## Testing

Tests run in **Vitest Browser Mode** against a real headless Chromium, driven by Playwright. Configured in [vitest.config.ts](vitest.config.ts); tests live in `test/` and are picked up by `test/**/*.test.{ts,tsx}`.

Why a real browser rather than jsdom: every component wraps a Base UI primitive, and the ones coming next (select, dialog, tooltip) depend on `ResizeObserver`, the popover API, and `dialog.showModal()` — none of which jsdom implements. The choice is about being able to _render_ the components at all, not about testing Base UI itself.

**What to test.** The component we wrote, not the primitive underneath it:

- it renders, and renders the right element/role;
- props map to the rendered output, including on re-render (`screen.rerender(...)`);
- React-level behavior — state updates, controlled inputs reflecting typed text, handlers firing.

**What not to test.** Base UI's own internals (focus trapping, positioning, keyboard navigation) — that's covered upstream. Visual/styling regressions are also out of scope; no component test loads CSS.

Three files test the package rather than a component, and none of them renders one. [test/package/resolution.test.ts](test/package/resolution.test.ts) checks the wiring between `src/`, `dist/` and `package.json` — the extensions, the barrel, the subpath exports, `sideEffects`, and that the message tables stay one per namespace. [test/locales/register.test.tsx](test/locales/register.test.tsx) checks `registerMessages`: the English fallback for a tag nobody registered, tag matching by script and region, and that a language registered after a first render invalidates what that render cached.

The third is [test/styles/standalone.test.tsx](test/styles/standalone.test.tsx), and it is not a styling test either — it is a test of the _package_. `neba/styles.css` promises that installing one package and importing one file gives you styled components, and that promise is made of three parts that each fail silently: the reset, the compiled utilities, and the tokens the utilities read. It loads `src/standalone.css` through Vite with `?inline` — the same entry the build compiles, so no build has to have run — injects it, and asserts only that each layer arrived and that they compose. Never assert a design value there (a radius, a shade, a height from the size ladder): those move with the design language, and a test that pins them turns every deliberate change into a failure. `border-radius` that is _not_ `0px`, a background that is _not_ transparent.

Conventions, following [test/components/button/Button.test.tsx](test/components/button/Button.test.tsx):

- `render()` from `vitest-browser-react` is **async** — always `await` it.
- Import the component from `'neba'`. That alias points at `src/index.ts` ([vitest.config.ts](vitest.config.ts)), so tests exercise the same public entry point consumers use.
- Query by role/accessible name. Use `await expect.element(locator)` for assertions that need to retry, and `locator.query()` when asserting absence.
- `locator.query()` is for something that was never there. **An element that is leaving needs the retrying form** — Base UI keeps a node mounted while an exit transition might still run, so a Tab panel is still in the document, `inert` and marked `data-ending-style`, at the moment the panel replacing it is up.
- **Before pressing a key, wait for the thing being typed at to hold the focus**, not for its markup. A popup takes focus in an effect after it mounts, and a key pressed in between lands wherever the focus still was. `menuHasFocus` in [Menu.test.tsx](test/components/menu/Menu.test.tsx) is the pattern.

### One file at a time

`fileParallelism` is off. Test files run as frames of one browser, and a browser has a single focus to hand out — a click in one file takes it from whichever file was holding it. Focus is half of what these components do: a toast stops its dismissal timer while the window is blurred, and a keystroke aimed at a menu goes wherever the focus went. Both produced failures that appeared only in a full run and never when the file was run on its own, which is the worst kind. The suite takes about twice as long.

The same asymmetry is worth remembering when writing a test around a timer: a duration short enough to expire during a query round trip has already expired by the time the assertion looks, and Firefox in CI is slower at that round trip than anything local.

### Choosing browsers

`npm test` runs **Chromium only**, so a single browser install is enough for day-to-day work:

```bash
npx playwright install chromium
```

The `VITEST_BROWSER` env var overrides that — one name, or a comma-separated list. An unsupported name fails fast with a startup error rather than silently skipping.

```bash
VITEST_BROWSER=firefox npm test
VITEST_BROWSER=chromium,firefox,webkit npm test   # needs all three installed
```

CI does not use the list form: it puts the browser in the job matrix instead, so `chromium on windows` fails independently of `webkit on ubuntu`.

## Toolchain notes

- Node `>=18` per `engines`, but CI runs 26 — Vite 8 and Vitest 4 need Node 20.19+/22.12+, so the declared floor is stale.
- Both `package-lock.json` and `pnpm-lock.yaml` are checked in; `pnpm-workspace.yaml` exists for pnpm users. Match whichever lockfile the working tree already reflects rather than switching package managers.
- `npm run build` runs `format:fix` first, so a build will rewrite files. Expect formatting changes in the diff.
- `terser.config.json` sets `compress.directives: false`, and it exists for `'use client'`. `directives` removes "redundant or non-standard" directives, and in a module — where `use strict` is implied — terser reads `use client` as both, so it strips it from all one hundred and six files without a word. The published package then says nothing at all to Next.js, and nothing in this repository would notice. It is `output.preserve_annotations`' twin: two settings, each keeping one thing terser would otherwise eat on the way out.
- `terser.config.json` sets `output.preserve_annotations`, and it exists for `scripts/annotate-pure.mjs`. Terser understands an `@__PURE__` comment and, by default, consumes it without emitting it again — which would hand the consumer's bundler minified files with the annotations gone. Neither `output.comments` nor `--comments` brings them back; this option is the one that does.
- `npm run build` has four steps and their order is load-bearing: `tsc`, then `annotate-pure`, then `minify`, then `build-styles`. The annotations have to be written after the JavaScript exists and before terser reads it.
- ESLint's flat config targets `**/*.{js,mjs,cjs,ts,tsx}`. The rule overrides had excluded `.tsx`, which left `n/no-missing-import` on for component files and made extensionless relative imports fail; `tsx` was added to the `files` glob to fix it.
- `.npmignore` is an allow-nothing-by-accident list: anything new at the repo root that should not ship (configs, tooling) has to be added there. Verify with `npm pack --dry-run`.
- Docs are VitePress with `vitepress-i18n` + `vitepress-sidebar`. Two locales, and which one is the root is a single constant: `defaultLocale` in `docs/.vitepress/config.ts`, currently `en`. The root locale is served from `/` (rewritten from `docs/en/`) and every other locale keeps its folder as its URL prefix, so `ko` is served from `/ko/`. Changing that constant swings the locale config, the sidebar's base path and the `rewrites` together.
- CI is [.github/workflows/run-test.yml](.github/workflows/run-test.yml), on PRs to `main`, pushes to `main` touching source/test/config paths, and `workflow_dispatch`. Two jobs:
  - `lint` — lint, prettier check, typecheck. Ubuntu + Node 26 only; these are platform-independent, so running them once is enough.
  - `run-test` — a 9-way matrix: `{ubuntu, windows, macos} × {chromium, firefox, webkit}` on Node 26, `fail-fast: false`. Each job installs only its own browser. `node_version` is kept as a matrix axis with a single value so older versions can be added back by editing one line.
- `npx playwright install --with-deps` is safe on all three runners: Playwright's `installDeps` only acts on Windows and Linux and is a no-op on macOS. On Windows it is not free, though — `windows-latest` is Windows Server, where `installDeps` runs `Install-WindowsFeature Server-Media-Foundation`, and only for chromium. That is four silent minutes on every windows/chromium run, and the reason that one job starts its suite while the other eight have nearly finished theirs. It is not removable: Playwright validates the Media Foundation DLLs when it launches chromium and **throws** if they are missing, and the runner image does not ship them.
- **Every job carries a `timeout-minutes`, and the test step carries one of its own.** GitHub's default is six hours, and the failure mode below is a browser that stops answering rather than one that exits — a run has sat wedged for seventy minutes and was only ended by hand. The step-level cap is what makes the report say which part stopped.

## Conventions

- **All repository content is written in English** — code, comments, docs, issues, commit messages. (The `docs/ko` locale is the deliberate exception.)
- Commit messages follow the Udacity style guide: `tag: message (fixes #1)` with tags `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, plus the informal `package` and `typo`. See [CONTRIBUTING.md](CONTRIBUTING.md).
- Prettier settings that matter: single quotes, no trailing commas, LF endings, `proseWrap: never`.

## Known rough edges

These are pre-existing and worth being aware of before "fixing" them incidentally:

- `react` / `react-dom` are declared **twice**, and both are correct: `peerDependencies` at `^18.0.0 || ^19.0.0`, because the consumer's copy is the one that must be used, and `devDependencies` at the version this repository builds and tests against. Widen the peer range only for a version the suite has actually run on — a peer range is a claim, and npm enforces it as one. `@types/react` is an optional peer, since a JavaScript consumer needs nothing from it.
- Emitted ESM once used extensionless relative imports (`export * from './types'`), which Node's own ESM resolver rejects and which broke `moduleResolution: node16` for every named export of the barrel. **Fixed** — every relative specifier in `src/` now ends in `.js`, and `test/package/resolution.test.ts` keeps it that way. Do not "tidy" the extensions away.
- **A chromium run occasionally loses its browser partway through the suite, and it is not ours.** It reads either as `Failed to run the test <file>` / `[vitest] Browser connection was closed while running tests` or, on Windows, as a file that prints `(0 test)` and then never says anything again. It is chromium-only, has never been seen on macOS, and has landed on five different files — ProgressCircular, AnimateSlide, AnimateZoom, AspectRatio, AreaChart — so no single test is guilty. What they share is a position: all of them are in the last ten or so of the ninety-two, where the files are small and the harness is tearing down and rebuilding a tester frame twice a second. Vitest's own tracker has the same report open against browser mode. Do not chase it through the component that happened to be running, and do not paper over it with a retry — a retry would also swallow the real failures this suite exists to catch. The timeouts above are the mitigation: the run fails in twenty minutes instead of hanging, and a re-run passes.
- The docs paint a gradient-and-grid background behind every preview. That is docs chrome, not library styling — a translucent, blurred surface has nothing to show over a flat white page, so the acrylic can only be judged over real content.

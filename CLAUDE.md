# CLAUDE.md

Guidance for Claude Code (and other AI agents) working in this repository.

## What this project is

**Neba** is a React design-component library published to npm as [`neba`](https://www.npmjs.com/package/neba). It provides Neba-styled UI components meant to be consumed by other websites and apps. It is currently pre-1.0 and explicitly not recommended for production.

- Ships as **ESM only**, type declarations included.
- Compiled with plain `tsc` (no bundler) and then minified — the output mirrors the `src/` folder layout.
- Runtime dependency: `@base-ui/react` (Base UI) only.

## Repository layout

| Path | Purpose |
| --- | --- |
| `src/` | **The library itself.** The only code that gets published. |
| `src/index.ts` | Public entry point. Every exported component must be re-exported from here. |
| `src/components/{name}/` | One folder per component (lowercase folder name). |
| `src/internal/` | The library talking to itself. Shipped but never re-exported from `src/index.ts`. |
| `test/` | Test suite (Vitest). Mirrors the `src/` tree. Self-contained: owns its `tsconfig.json`. |
| `docs/` | VitePress site — developer-facing documentation for library consumers, and the only place components are rendered during development. Self-contained: owns its `tsconfig.json`. Not published to npm. |
| `dist/` | Build output (`tsc` + terser). Generated; never edit by hand, never commit. |

There is no separate demo app. `docs/` renders the real components from `src/` through a Vite alias, so `npm run docs:dev` is the develop-and-eyeball loop.

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
  index.ts       # export { Button } from './Button';
```

Then re-export it from `src/index.ts`:

```ts
export * from './components/button';
```

Rules to follow:

1. **Folder name is lowercase** (`button`, `text-field`); the file and the exported symbol are `PascalCase` (`Button.tsx` → `Button`).
2. **Use named exports**, never `export default`.
3. Each component folder gets its own `index.ts` barrel; `src/index.ts` only ever re-exports those barrels. Grow this list as components are added.
4. When a component is added, document it under `docs/` — see [Documentation](#documentation) for the five places that means. That is also what makes it viewable alongside the others.
5. **Tests are part of the change, not a follow-up.** See the rule below.

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

**[docs/ko/design-language](docs/ko/guide/design-language.md) is the source of truth. Read it before styling anything.** The rules below are the ones most easily broken by accident; the document explains why each exists.

The governing idea: **a Neba surface is a sheet of cut acrylic, not a moulded plastic key.** Every rule below follows from that.

- **No `transform` on a control, ever.** Scaling resamples the label, and text that shifts under the cursor is what reads as cheap. State changes are expressed in colour and depth only.
- **Press is instant, release is slow.** Per-property `transition-duration` with `:active` overriding everything to `0ms`. The same asymmetry drives the afterglow layer. This is the house interaction signature.
- **`elevation` defaults to `0` and `0` means no shadow at all.** The acrylic edge separates a surface from the page; a drop shadow is opt-in. Shadows are never tinted with the control's own colour.
- **No dark bottom bevel** (`inset 0 -1px 0 black`). Top light edge plus a full white hairline only.
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

`src/types.ts` holds the vocabulary every component draws from: `NebaSize`, `NebaColor`, `NebaDensity`, `NebaVariant`, `NebaElevation`, `NebaOrientation`, `NebaSide`, `NebaAlign`, and the `NebaStyleProps` bundle. A `size` of `md` must mean the same thing on every component. **Do not invent a second spelling for an idea that already has one** — see [docs/ko/guide/prop-conventions.md](docs/ko/guide/prop-conventions.md).

The same rule applies to the values behind those names, which is what `src/internal/styles.ts` is for. Control heights, radii, type scales, the two padding tracks, the _sheet_ ladder a Card, an Alert and a Dialog share, the frosted surface, the house transition, the focus ring and the `--n-*` slot generators live there once and every component imports them. A component keeps only what genuinely differs: its variant class maps and its layout. If you find yourself writing `h-8` or `rounded-(--neba-radius-md)` into a component, check whether the table already says it.

`src/internal/button-group.ts` holds the context `ButtonGroup` provides and `Button` reads as a fallback. It lives in `internal/` so the two components do not import each other; `List`, `Accordion` and `Tabs` have the same arrangement but keep their context in their own file, because each is a parent and its rows in one file. `src/internal/menu.ts` is the exception that proves the rule: `Menu`, `ContextMenu` and every row read the same context, and a submenu is a menu inside a menu, so three components need it and none of them should have to import the others.

Two more files in `internal/` exist for the same "written once" reason. `progress.ts` is the arithmetic and the ladders the three progress indicators share — they are one component in three shapes, and a `value` of `null` has to mean the same thing on all of them. `icons.tsx` is the glyphs more than one component draws: the × that Chip, Alert, Dialog, Toast and FilePicker all need; the chevron, drawn pointing **down** once and turned by whoever needs it — Select's trigger, Accordion's header, a submenu's arrow, Pagination's steppers — because rotating a glyph is the one allowance the no-transform rule makes; the tick and the dot that Select and the menu's checkable rows share; and the severity set, which is a piece of the design language rather than a convenience — an alert that says "this went wrong" only in red says it only to some readers, so the shape has to carry the meaning too, and that only holds if every component uses the same shape for the same family.

### Table cells are the exception to "styling is Tailwind"

`Table` writes its cell padding, alignment, backgrounds and row rules as **inline styles**, not utilities. This is not a shortcut. `<td>` and `<th>` are among the very few tags a host stylesheet still styles by name — VitePress's `.vp-doc td`, Tailwind Typography's `.prose td`, every CSS framework — always at two-class specificity that a one-class utility cannot outrank. Every one of those declarations silently lost before the styling moved inline.

The row's own background stays a utility, because it has a hover state and inline styles have no `:hover`. It reads a `--n-row` slot that classes then set: a custom property is invisible to a host stylesheet, so a variant wins there without a fight. `paddingXValues` in `internal/styles.ts` is `paddingXClasses` as raw lengths for exactly this; keep the two in step.

### The stylesheet ships

`src/styles.css` holds the tokens, the `.neba-glow` layers, and — importantly — its own `@source '.'`. `tsc` does not copy it, so `scripts/copy-styles.mjs` runs at the end of `npm run build` and it is exported as `neba/styles.css`.

**The `@source` is what makes the consumer setup two lines rather than three.** `@source` resolves relative to the file it is written in, not to whatever imported it, so the same line means `node_modules/neba/dist/` for a consumer and `src/` in this repository — and an explicitly registered source is scanned even inside `node_modules`, which automatic detection skips. Consumers therefore write only `@import 'tailwindcss'` and `@import 'neba/styles.css'`; never tell them to add an `@source` of their own, since that path would depend on where their CSS file sits. The docs rely on the same mechanism: `theme/styles/index.css` registers only the docs' own directories.

Pseudo-element styling (the pointer spotlight, the release afterglow) lives in `styles.css` as real CSS rather than as Tailwind arbitrary variants — `[&::before]:[background:radial-gradient(...)]` is expressible and unreadable. That is the bar for moving something out of Tailwind: not "could this be CSS", but "is the Tailwind form unmaintainable".

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
  theme/
    components/Layout.vue   # the default layout + the live home hero
    components/Demo.vue     # the React island + the show-code toggle
    components/PropsTable.vue
    styles/index.css        # Tailwind (no Preflight) + tokens + docs chrome
    styles/scope.css        # Preflight, cut down and scoped to `.neba-scope`
docs/{ko,en}/
  index.md                  # home — `layout: home`, with a live hero and body sections
  components/index.md       # the index grid of every component
  components/{group}/*.md   # one page per component, grouped (display, feedback, inputs, surfaces)
  examples/index.md         # every component on one sample screen
```

The groups are folders, and the sidebar orders them alphabetically — `display` (Typography, Divider, Chip, Table, List, Badge), `feedback` (Alert, Dialog, Toast, Tooltip, ProgressLinear, ProgressCircular, ProgressBox), `inputs` (Button, ButtonGroup, TextField, Select, Checkbox, RadioGroup, Switch, Slider, Menu, FilePicker, Pagination), `surfaces` (Box, Card, Accordion, Tabs). Within a group the `order` in a page's frontmatter decides; inserting a component means renumbering the ones after it in **both** locales, so a new one goes on the end unless it genuinely belongs in the middle.

Things that will bite:

- **The locale routing is a three-way agreement.** `vitepress-i18n` puts the root locale in `locales.root` with no path prefix, `vitepress-sidebar` is told to resolve its links against `/`, and `rewrites` is what actually moves `docs/ko/**` to `/`. Change one and every sidebar link 404s — which is exactly what happened when `rewrites` still said `en/:rest*`. Other locales keep their folder as their URL prefix.
- **A demo is referenced twice, by the same path.** `<Demo src="button/variants">` mounts `demos/button/variants.tsx`, and the `<<< @/.vitepress/demos/button/variants.tsx` snippet inside it is what gets displayed. That is deliberate — the code shown is the file that ran, so the two cannot drift. Blank lines around the `<<<` are required, or Markdown swallows it into the HTML block.
- **Demos import from `'neba'`**, aliased to `src/index.ts`. The displayed source is then exactly what a consumer would write, and a component edit shows up without a rebuild.
- **Demos are written in English and shared by every locale** — they are code samples, and the repo writes code in English. Only the two that are documentation rather than sample code (`gallery/all.tsx`, and anything like it) take the `locale` prop `Demo.vue` passes in and localise themselves. Prose belongs in the Markdown around the preview.
- **A props row carries both languages.** `data/props.ts` keys every description by locale, so a Korean and an English table cannot drift into listing different props.
- **Tailwind ships without Preflight here.** Preflight resets `h1`…`p`, links and lists globally, which would flatten VitePress's own typography. `scope.css` re-applies only the parts the library depends on (above all `border: 0 solid`) inside `.neba-scope`. Utilities are imported _unlayered_ on purpose: VitePress's theme is unlayered, and a layered rule loses to an unlayered one no matter how specific.
- **`.vp-doc` is already styling the preview.** Base UI renders a `<p>` for a field description; a card footer can hold an `<a>`. Rules that undo `.vp-doc` need two classes to outrank it — that is why half of `scope.css` is prefixed `.vp-doc .neba-scope`. Where the component itself has to win against `.vp-doc` rather than merely survive it — table cells — the fix belongs in the component, inline, not here; there is no specificity that both beats `.vp-doc td` and loses to a utility.
- **A portalled popup leaves `.neba-scope`.** Select's popup renders at the end of `<body>`, outside the element the preview mounted into. Its positioner carries `neba-portal`, which `scope.css` hangs the same reset off. The library treats that class as a hook, not a style; a consumer with real Preflight needs nothing.
- **Dark mode is free.** VitePress puts `.dark` on `<html>`, which `src/styles.css` already answers to.
- The docs' `<Demo>` is client-only, so an SSR build renders an empty box and fills it on hydration.

Adding a component means five docs edits: a page under `components/{group}/` **in every locale**, its rows in `data/props.ts`, its demo files under `demos/`, a card in `demos/gallery/all.tsx`, and a place on the sample screen in `demos/showcase/app.tsx`. Only the first is per-locale; the demos and the props data are shared.

## Commands

All scripts run from the repository root, even the ones whose config lives in a subdirectory.

```bash
npm test              # Vitest, single run (headless Chromium)
npm run test:watch    # Vitest in watch mode
npm run typecheck     # tsc --noEmit over all three TS projects
npm run docs:dev      # VitePress docs site — the develop-and-eyeball loop (runs a build first)
npm run build         # format:fix + tsc (tsconfig.prod.json) + terser minify → dist/
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

**What not to test.** Base UI's own internals (focus trapping, positioning, keyboard navigation) — that's covered upstream. Visual/styling regressions are also out of scope for now; nothing loads Tailwind into the test run.

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
- ESLint's flat config targets `**/*.{js,mjs,cjs,ts,tsx}`. The rule overrides had excluded `.tsx`, which left `n/no-missing-import` on for component files and made extensionless relative imports fail; `tsx` was added to the `files` glob to fix it.
- `.npmignore` is an allow-nothing-by-accident list: anything new at the repo root that should not ship (configs, tooling) has to be added there. Verify with `npm pack --dry-run`.
- Docs are VitePress with `vitepress-i18n` + `vitepress-sidebar`. Two locales, and which one is the root is a single constant: `defaultLocale` in `docs/.vitepress/config.ts`, currently `en`. The root locale is served from `/` (rewritten from `docs/en/`) and every other locale keeps its folder as its URL prefix, so `ko` is served from `/ko/`. Changing that constant swings the locale config, the sidebar's base path and the `rewrites` together.
- CI is [.github/workflows/run-test.yml](.github/workflows/run-test.yml), on PRs to `main`, pushes to `main` touching source/test/config paths, and `workflow_dispatch`. Two jobs:
  - `lint` — lint, prettier check, typecheck. Ubuntu + Node 26 only; these are platform-independent, so running them once is enough.
  - `run-test` — a 9-way matrix: `{ubuntu, windows, macos} × {chromium, firefox, webkit}` on Node 26, `fail-fast: false`. Each job installs only its own browser. `node_version` is kept as a matrix axis with a single value so older versions can be added back by editing one line.
- `npx playwright install --with-deps` is safe on all three runners: Playwright's `installDeps` only acts on Windows and Linux and is a no-op on macOS.

## Conventions

- **All repository content is written in English** — code, comments, docs, issues, commit messages. (The `docs/ko` locale is the deliberate exception.)
- Commit messages follow the Udacity style guide: `tag: message (fixes #1)` with tags `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, plus the informal `package` and `typo`. See [CONTRIBUTING.md](CONTRIBUTING.md).
- Prettier settings that matter: single quotes, no trailing commas, LF endings, `proseWrap: never`.

## Known rough edges

These are pre-existing and worth being aware of before "fixing" them incidentally:

- `react` / `react-dom` are `devDependencies`, not `peerDependencies` — unusual for a component library.
- Emitted ESM uses extensionless relative imports (`export * from './types'`), which Node's own ESM resolver rejects. Bundlers handle it; a direct `node` import of `dist/` would not. Pre-existing, and not something to fix incidentally.
- The docs paint a gradient-and-grid background behind every preview. That is docs chrome, not library styling — a translucent, blurred surface has nothing to show over a flat white page, so the acrylic can only be judged over real content.

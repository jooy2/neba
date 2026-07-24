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
| `test/` | Test suite (Vitest). Mirrors the `src/` tree. Self-contained: owns its `tsconfig.json`. |
| `examples/` | Vite demo app — a single page showing every component at a glance. Self-contained: owns its `vite.config.ts` and `tsconfig.json`. Not published. |
| `docs/` | VitePress site — developer-facing documentation for library consumers. Holds the design language spec. Not published to npm. |
| `dist/` | Build output (`tsc` + terser). Generated; never edit by hand, never commit. |

Three TypeScript projects, each with its own config, because their compiler needs genuinely differ (the library emits declarations; the demo and the tests are `noEmit` and need DOM libs):

- `tsconfig.json` / `tsconfig.prod.json` — the library in `src/`. `prod` is what `npm run build` compiles.
- `test/tsconfig.json` — tests.
- `examples/tsconfig.json` — the demo app.

`npm run typecheck` runs all three. Root-level configs deliberately exclude `test/` and `examples/`.

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
4. When a component is added, also add it to the demo page (`examples/src/App.tsx`) so it can be viewed alongside the others, and document it under `docs/`.
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

`src/types.ts` holds the vocabulary every component draws from: `NebaSize`, `NebaColor`, `NebaDensity`, `NebaVariant`, `NebaElevation`, and the `NebaStyleProps` bundle. A `size` of `md` must mean the same thing on every component. **Do not invent a second spelling for an idea that already has one** — see [docs/ko/guide/prop-conventions.md](docs/ko/guide/prop-conventions.md).

### The stylesheet ships

`src/styles.css` holds the tokens and the `.neba-glow` layers. `tsc` does not copy it, so `scripts/copy-styles.mjs` runs at the end of `npm run build` and it is exported as `neba/styles.css`. Consumers need `@import 'neba/styles.css'` **and** `@source '../node_modules/neba'` next to their Tailwind import.

Pseudo-element styling (the pointer spotlight, the release afterglow) lives in `styles.css` as real CSS rather than as Tailwind arbitrary variants — `[&::before]:[background:radial-gradient(...)]` is expressible and unreadable. That is the bar for moving something out of Tailwind: not "could this be CSS", but "is the Tailwind form unmaintainable".

## Commands

All scripts run from the repository root, even the ones whose config lives in a subdirectory.

```bash
npm test              # Vitest, single run (headless Chromium)
npm run test:watch    # Vitest in watch mode
npm run typecheck     # tsc --noEmit over all three TS projects
npm run demo:dev      # Vite dev server for the examples/ demo page
npm run docs:dev      # VitePress docs site (runs a build first)
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
- **Vite aliases in `examples/` are counterintuitive** (see [examples/vite.config.ts](examples/vite.config.ts)):
  - `@/dist` → `src/` (the library source, _not_ `dist/`)
  - `@/src` → `examples/src/`
  - So `import { Button } from '@/dist'` in the demo resolves to the live library source — that is why the demo picks up edits without a rebuild.
- `npm run build` runs `format:fix` first, so a build will rewrite files. Expect formatting changes in the diff.
- ESLint's flat config targets `**/*.{js,mjs,cjs,ts,tsx}`. The rule overrides had excluded `.tsx`, which left `n/no-missing-import` on for component files and made extensionless relative imports fail; `tsx` was added to the `files` glob to fix it.
- `.npmignore` is an allow-nothing-by-accident list: anything new at the repo root that should not ship (configs, tooling) has to be added there. Verify with `npm pack --dry-run`.
- Docs are VitePress with `vitepress-i18n` + `vitepress-sidebar`; the only configured locale is `ko`, with content under `docs/ko/`.
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
- `examples/README.md` is the stock Vite template readme.
- The demo page paints a gradient-and-grid background. That is demo chrome, not library styling — a translucent, blurred surface has nothing to show over a flat white page, so the acrylic can only be judged over real content.

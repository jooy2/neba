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
| `examples/` | Vite demo app — a single page showing every component at a glance. Development playground, not published. |
| `docs/` | VitePress site — developer-facing documentation for library consumers. Not published to npm. |
| `dist/` | Build output (`tsc` + terser). Generated; never edit by hand, never commit. |

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

## Styling and behavior conventions

- **Styling: Tailwind CSS v4**, applied through `className`. Tailwind is wired via PostCSS (`postcss.config.mjs` → `@tailwindcss/postcss`); there is no `tailwind.config.js` — v4 is configured in CSS.
- **Behavior/logic: [Base UI](https://base-ui.com) (`@base-ui/react`)** — use its unstyled primitives for interaction, state, and accessibility, and layer Tailwind classes on top. This is the pattern in `Button.tsx`, which wraps `Button` from `@base-ui/react/button`.
- **Fallback:** if neither Tailwind nor Base UI can express what a component needs, plain native React/DOM code is acceptable. Prefer the stack above first.
- `prettier-plugin-tailwindcss` sorts Tailwind class strings — do not hand-order classes; run the formatter.

## Commands

```bash
npm run demo:dev      # Vite dev server for the examples/ demo page
npm run docs:dev      # VitePress docs site (runs a build first)
npm run build         # format:fix + tsc (tsconfig.prod.json) + terser minify → dist/
npm run lint          # ESLint
npm run lint:fix      # ESLint with --fix
npm run format:fix    # Prettier write
```

There is **no test suite** in the repo yet (`tsconfig.json` references a `test/` folder that does not exist). Verify changes by running the demo page.

## Toolchain notes

- Node `>=18`. Both `package-lock.json` and `pnpm-lock.yaml` are checked in; `pnpm-workspace.yaml` exists for pnpm users. Match whichever lockfile the working tree already reflects rather than switching package managers.
- **Vite aliases in `examples/` are counterintuitive** (see `vite.config.ts`):
  - `@/dist` → `src/` (the library source, _not_ `dist/`)
  - `@/src` → `examples/src/`
  - So `import { Button } from '@/dist'` in the demo resolves to the live library source — that is why the demo picks up edits without a rebuild.
- `npm run build` runs `format:fix` first, so a build will rewrite files. Expect formatting changes in the diff.
- ESLint's flat config only targets `**/*.{js,mjs,cjs,ts}` — `.tsx` files are currently not linted.
- Docs are VitePress with `vitepress-i18n` + `vitepress-sidebar`; the only configured locale is `ko`, with content under `docs/ko/`.

## Conventions

- **All repository content is written in English** — code, comments, docs, issues, commit messages. (The `docs/ko` locale is the deliberate exception.)
- Commit messages follow the Udacity style guide: `tag: message (fixes #1)` with tags `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, plus the informal `package` and `typo`. See [CONTRIBUTING.md](CONTRIBUTING.md).
- Prettier settings that matter: single quotes, no trailing commas, LF endings, `proseWrap: never`.

## Known rough edges

These are pre-existing and worth being aware of before "fixing" them incidentally:

- `react` / `react-dom` are `devDependencies`, not `peerDependencies` — unusual for a component library.
- `vite.config.ts` sets `publicDir` to `./src/examples/public`, which does not exist (the real path is `examples/public`).
- `docs/.vitepress/config.ts` still has the template title `'VitePress Sidebar'`.
- `examples/README.md` is the stock Vite template readme.

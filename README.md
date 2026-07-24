# Neba UI

This library is currently under testing. We do not recommend using it in production.

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jooy2/neba/blob/main/LICENSE) ![Programming Language Usage](https://img.shields.io/github/languages/top/jooy2/neba) ![Commit Count](https://img.shields.io/github/commit-activity/y/jooy2/neba) [![npm downloads](https://img.shields.io/npm/dm/neba.svg)](https://www.npmjs.com/package/neba) [![npm latest package](https://img.shields.io/npm/v/neba/latest.svg)](https://www.npmjs.com/package/neba) ![npm bundle size](https://img.shields.io/bundlephobia/min/neba) [![Followers](https://img.shields.io/github/followers/jooy2?style=social)](https://github.com/jooy2) ![Stars](https://img.shields.io/github/stars/jooy2/neba?style=social)

Neba UI is a React component library that provides Neba-styled, ready-to-use UI components for your websites and apps. Components are built on [Base UI](https://base-ui.com) primitives for behavior and accessibility, and styled with [Tailwind CSS](https://tailwindcss.com).

- **ESM only**, with TypeScript declarations bundled.
- **Tree-shakeable** — each component is compiled to its own module.
- **React 19** and Node.js 18 or later.

## Installation

```bash
npm install neba
```

```bash
pnpm add neba
```

Neba expects `react` and `react-dom` to be available in your project.

## Usage

Import components from the package root:

```tsx
import { Button } from 'neba';

export default function App() {
  return <Button onClick={() => console.log('clicked')}>Hello from Neba!</Button>;
}
```

Components are styled with Tailwind CSS, so your app needs Tailwind set up. Add two lines to your CSS entry point:

```css
@import 'tailwindcss';
@import 'neba/styles.css';
```

`neba/styles.css` carries the design tokens, and registers the package as a Tailwind source itself — so there is no `@source` line for you to write, and no path that depends on where your CSS file happens to sit.

Full setup instructions, the design language, and the component reference live in the documentation: https://neba.cdget.com

## Development

Clone the repository and install dependencies, then:

| Command | What it does |
| --- | --- |
| `npm run docs:dev` | Starts the documentation site (`docs/`) locally — every component, rendered live, with HMR. |
| `npm test` | Runs the test suite once. |
| `npm run test:watch` | Runs the test suite in watch mode. |
| `npm run typecheck` | Type-checks the library, the tests, and the docs. |
| `npm run build` | Formats, compiles, and minifies the library into `dist/`. |
| `npm run lint:fix` | Runs ESLint with autofix. |
| `npm run format:fix` | Runs Prettier over the repository. |

All commands are run from the repository root.

### Project structure

- `src/` — the library source. Each component lives in `src/components/{name}/` and is re-exported from `src/index.ts`.
- `test/` — the test suite, mirroring the `src/` tree.
- `docs/` — the VitePress documentation site for library consumers. It renders the real components, so it is also where components are developed and eyeballed.

### Tests

Tests run with [Vitest](https://vitest.dev) in browser mode, against a real headless browser driven by Playwright — Neba's components sit on top of [Base UI](https://base-ui.com) primitives that expect real browser APIs. Install the browser once before your first run:

```bash
npx playwright install chromium
```

`npm test` uses Chromium. To run against another engine, set `VITEST_BROWSER` to `chromium`, `firefox`, or `webkit` (or a comma-separated list), having installed those browsers first:

```bash
VITEST_BROWSER=firefox npm test
```

CI runs the suite across Linux, Windows, and macOS in all three browser engines.

Add a test for each component at the path mirroring its source — `src/components/button/Button.tsx` is covered by `test/components/button/Button.test.tsx`.

## Contributing

Anyone can contribute to the project by reporting new issues or submitting a pull request. For more information, please see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Please see the [LICENSE](LICENSE) file for more information about project owners, usage rights, and more.

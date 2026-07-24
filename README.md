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
  return <Button text="Hello from Neba!" />;
}
```

Because components are styled with Tailwind CSS, your app needs Tailwind set up so that Neba's class names are generated. Full setup instructions and the component reference live in the documentation: https://neba.cdget.com

## Development

Clone the repository and install dependencies, then:

| Command | What it does |
| --- | --- |
| `npm run demo:dev` | Starts the demo page (`examples/`) — every component on one page, with HMR. |
| `npm run docs:dev` | Starts the documentation site (`docs/`) locally. |
| `npm run build` | Formats, type-checks, compiles, and minifies the library into `dist/`. |
| `npm run lint:fix` | Runs ESLint with autofix. |
| `npm run format:fix` | Runs Prettier over the repository. |

### Project structure

- `src/` — the library source. Each component lives in `src/components/{name}/` and is re-exported from `src/index.ts`.
- `examples/` — a Vite demo app used to develop and eyeball components.
- `docs/` — the VitePress documentation site for library consumers.

## Contributing

Anyone can contribute to the project by reporting new issues or submitting a pull request. For more information, please see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Please see the [LICENSE](LICENSE) file for more information about project owners, usage rights, and more.

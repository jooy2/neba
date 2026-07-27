<img src=".github/128x128.png" alt="Neba UI" width="128" height="128" />

# Neba UI

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jooy2/neba/blob/main/LICENSE) ![Programming Language Usage](https://img.shields.io/github/languages/top/jooy2/neba) ![Commit Count](https://img.shields.io/github/commit-activity/y/jooy2/neba) [![npm downloads](https://img.shields.io/npm/dm/neba.svg)](https://www.npmjs.com/package/neba) [![npm latest package](https://img.shields.io/npm/v/neba/latest.svg)](https://www.npmjs.com/package/neba) ![npm bundle size](https://img.shields.io/bundlephobia/min/neba) [![Followers](https://img.shields.io/github/followers/jooy2?style=social)](https://github.com/jooy2) ![Stars](https://img.shields.io/github/stars/jooy2/neba?style=social)

### 📘 [**neba.cdget.com**](https://neba.cdget.com)

[![Components](https://img.shields.io/badge/All_components-live_previews-444?style=for-the-badge)](https://neba.cdget.com/examples/)

Live previews and full props for every component. This README is just the quick start.

---

**Neba UI is a React component library for building application interfaces.** It gives you the pieces a real product needs — buttons and form fields, menus and dialogs, tables and tabs, progress and notifications — already styled, already accessible, and already agreeing with each other.

You install one package, add two lines to your CSS, and import components. There is nothing to configure, no theme object to assemble, and no per-component styling decisions to make before you can ship a screen.

- **A broad component set, still growing** — enough to build a whole screen without reaching elsewhere.
- **One shared vocabulary** — `size`, `color`, `variant`, `density`, `elevation`. An `md` is the same height on every control; `primary` is the same colour everywhere.
- **Accessible by construction** — real roles, labels, focus management and keyboard support, not `div`s with click handlers.
- **Dark mode with no work** — follows the system, and can be forced either way per subtree.
- **A design language, not a theme file** — a translucent acrylic surface with a hairline edge, one deliberate motion signature, and shadows that are opt-in.
- **ESM only**, TypeScript declarations included, tree-shakeable — every component compiles to its own module.
- **One runtime dependency.** React 19, Node.js 18 or later.

## Documentation

Everything is documented at **[neba.cdget.com](https://neba.cdget.com)**, where the previews are not screenshots — they are the components, running in the page.

| Page | What you will find |
| --- | --- |
| [**Getting started**](https://neba.cdget.com/guide/getting-started) | Install and setup, end to end. |
| [**All components**](https://neba.cdget.com/components/) | Every component, one page each: live previews and the full props table. |
| [**Examples**](https://neba.cdget.com/examples/) | A whole sample screen, explained block by block. |
| [**Design language**](https://neba.cdget.com/guide/design-language) | Why a Neba surface looks and behaves the way it does. |
| [**Prop conventions**](https://neba.cdget.com/guide/prop-conventions) | The shared vocabulary every component draws from. |
| [**Color**](https://neba.cdget.com/guide/color) | The token families, and how to theme them. |

Also available in Korean / 한국어 문서: **[neba.cdget.com/ko/](https://neba.cdget.com/ko/)**

## Installation

```bash
npm install neba
```

```bash
pnpm add neba
```

Neba expects `react` and `react-dom` to be available in your project.

### Setup

Add two lines to your app's CSS entry point:

```css
@import 'tailwindcss';
@import 'neba/styles.css';
```

`neba/styles.css` carries the design tokens and registers the package as a style source itself — so there is no `@source` line for you to write, and no path that depends on where your CSS file happens to sit. Utility classes come from [Tailwind CSS](https://tailwindcss.com) v4, which is the only build-side requirement Neba has.

That is the whole setup. No provider is required at the root, no theme object, no config file.

## Usage

Import components from the package root:

```tsx
import { Button, Card, TextField } from 'neba';

export default function SignIn() {
  return (
    <Card>
      <TextField label="Email" type="email" />
      <Button onClick={submit}>Sign in</Button>
    </Card>
  );
}
```

A few components provide context and are mounted once, near the root, only if you use them — `ToastProvider` (paired with the `useToast()` hook) and `TooltipProvider`.

### The shared prop vocabulary

The reason a Neba screen looks composed rather than assembled is that the props mean one thing across the library. They live in [`src/types.ts`](src/types.ts) and every component draws from the same list:

| Prop | Values | What it changes |
| --- | --- | --- |
| `size` | `xs` `sm` `md` `lg` `xl` | The control's scale. `md` is the desktop default. |
| `color` | `primary` `secondary` `success` `warning` `danger` `info` | The semantic colour family. |
| `variant` | `solid` `outline` `text` | How much visual weight the surface carries. |
| `density` | `default` `compact` | Padding only — never the height, never the type scale, so a compact control still lines up with a default one. |
| `elevation` | `0` `1` `2` `3` | How far a surface floats off the page. `0` is the default and means no shadow at all. |

Placement props are logical, not physical — `start`/`end` rather than `left`/`right` — so layouts flip correctly under RTL. The full rules are in [**Prop conventions**](https://neba.cdget.com/guide/prop-conventions).

```tsx
<Button size="sm" color="danger" variant="outline">Delete</Button>
<Chip size="sm" color="danger" variant="outline">Overdue</Chip>
```

### Components

**Inputs** — Button, IconButton, ButtonGroup, TextField, NumberField, Select, Combobox, Checkbox, RadioGroup, Switch, Slider, Menu (with submenus, checkbox and radio items), ContextMenu, FilePicker, Pagination, DatePicker, TimePicker, DateTimePicker, DateRangePicker

**Surfaces** — Box, Card, Accordion, Tabs, Carousel, Toolbar, Pill

**Display** — Typography, Divider, Chip, Badge, Icon, Statistic, List, Table

**Feedback** — Alert, Dialog, Toast, Tooltip, Overlay, ProgressLinear, ProgressCircular, ProgressBox

Recent additions: the four pickers — **DatePicker**, **TimePicker**, **DateTimePicker** and **DateRangePicker** — which take and return a plain `Date`, read every month and weekday name out of `Intl`, and add no date library to your bundle; **Icon** (a glyph at a known size and colour — the glyph is a prop, not children), **IconButton** (that glyph as a round button, with a required accessible name), **Statistic** (a figure, its name, and how far it has moved against a `previousValue`), **Carousel** (a scroll-snap strip of slides — swipeable, RTL-correct, nothing transformed), **Pill** (a floating lozenge for live information, growing into a second half), and **Toolbar** (a header or action bar with `start` / `end` slots, stickable and fixable).

Each one has its own page — live previews, every prop, and the variations worth seeing — under [**All components**](https://neba.cdget.com/components/).

### Theming and dark mode

Colours, radii, and surface strengths are CSS custom properties declared in the stylesheet you imported. Override any of them in your own CSS and the whole library follows:

```css
:root {
  --neba-primary-fill: oklch(0.62 0.19 265);
}
```

Dark mode responds to `prefers-color-scheme` on its own. To force it, put `.dark` or `[data-theme='dark']` (or `'light'`) on any ancestor — it applies to that subtree, so a dark panel on a light page is one attribute.

Adding a whole new colour family is two edits: an entry in `NebaColor` and five tokens; everything else derives from them.

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
- `src/internal/` — what the library shares with itself: the size and spacing tables, the surface and focus-ring generators, the icons more than one component draws. Shipped, but not part of the public API.
- `test/` — the test suite, mirroring the `src/` tree.
- `docs/` — the VitePress documentation site, in English and Korean. It renders the real components from `src/`, so it is also where components are developed and eyeballed.

There is no separate demo app: `npm run docs:dev` is the develop-and-eyeball loop.

### Tests

Tests run with [Vitest](https://vitest.dev) in browser mode, against a real headless browser driven by Playwright — the components depend on browser APIs (`ResizeObserver`, the popover API, `dialog.showModal()`) that jsdom does not implement. Install the browser once before your first run:

```bash
npx playwright install chromium
```

`npm test` uses Chromium. To run against another engine, set `VITEST_BROWSER` to `chromium`, `firefox`, or `webkit` (or a comma-separated list), having installed those browsers first:

```bash
VITEST_BROWSER=firefox npm test
```

CI runs the suite across Linux, Windows, and macOS in all three browser engines.

Tests ship with the component they cover, in the same commit. Add a test at the path mirroring its source — `src/components/button/Button.tsx` is covered by `test/components/button/Button.test.tsx`.

## Contributing

Anyone can contribute to the project by reporting new issues or submitting a pull request. For more information, please see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Please see the [LICENSE](LICENSE) file for more information about project owners, usage rights, and more.

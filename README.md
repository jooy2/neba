<img src=".github/128x128.png" alt="Neba UI" width="128" height="128" />

# Neba UI

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jooy2/neba/blob/main/LICENSE) ![Programming Language Usage](https://img.shields.io/github/languages/top/jooy2/neba) ![Commit Count](https://img.shields.io/github/commit-activity/y/jooy2/neba) [![npm downloads](https://img.shields.io/npm/dm/neba.svg)](https://www.npmjs.com/package/neba) [![npm latest package](https://img.shields.io/npm/v/neba/latest.svg)](https://www.npmjs.com/package/neba) ![npm bundle size](https://img.shields.io/bundlephobia/min/neba) [![Followers](https://img.shields.io/github/followers/jooy2?style=social)](https://github.com/jooy2) ![Stars](https://img.shields.io/github/stars/jooy2/neba?style=social)

### 📘 [**neba.cdget.com**](https://neba.cdget.com)

[![Components](https://img.shields.io/badge/All_components-live_previews-444?style=for-the-badge)](https://neba.cdget.com/examples/overview)

Live previews and full props for every component. This README is just the quick start.

---

**Neba UI is a React component library for building application interfaces.** It gives you the pieces a real product needs — buttons and form fields, menus and dialogs, tables and tabs, progress and notifications — already styled, already accessible, and already agreeing with each other.

You install one package, add one line to your CSS, and import components. There is nothing to configure, no theme object to assemble, and no per-component styling decisions to make before you can ship a screen.

- **A broad component set, still growing** — enough to build a whole screen without reaching elsewhere.
- **One shared vocabulary** — `size`, `color`, `variant`, `density`, `elevation`. An `md` is the same height on every control; `primary` is the same colour everywhere.
- **Accessible by construction** — real roles, labels, focus management and keyboard support, not `div`s with click handlers.
- **Dark mode with no work** — follows the system, and can be forced either way per subtree.
- **A design language, not a theme file** — a translucent acrylic surface with a hairline edge, one deliberate motion signature, and shadows that are opt-in.
- **ESM only**, TypeScript declarations included, tree-shakeable — every component compiles to its own module.
- **One runtime dependency.** React 18 or 19, Node.js 18 or later.

## Documentation

Everything is documented at **[neba.cdget.com](https://neba.cdget.com)**, where the previews are not screenshots — they are the components, running in the page.

| Page | What you will find |
| --- | --- |
| [**Getting started**](https://neba.cdget.com/guide/getting-started) | Install and setup, end to end. |
| [**All components**](https://neba.cdget.com/components/) | Every component, one page each: live previews and the full props table. |
| [**Examples**](https://neba.cdget.com/examples/overview) | A whole sample screen explained block by block, plus three concept screens — a landing page, an admin dashboard and a sign-up flow. |
| [**Design language**](https://neba.cdget.com/design/design-language) | Why a Neba surface looks and behaves the way it does. |
| [**Prop conventions**](https://neba.cdget.com/design/prop-conventions) | The shared vocabulary every component draws from. |
| [**Color**](https://neba.cdget.com/design/color) | The token families, and how to theme them. |
| [**Changelog**](https://neba.cdget.com/changelog) | What changed in each release, and the setup changes worth acting on. |

Also available in Korean / 한국어 문서: **[neba.cdget.com/ko/](https://neba.cdget.com/ko/)**

## Installation

```bash
npm install neba
```

```bash
pnpm add neba
```

`react` and `react-dom` are peer dependencies — React 18 or 19. Neba uses the copy your project already has, and npm 7 and later will install them alongside it if it has none.

### Setup

Add one line to your app's CSS entry point:

```css
@import 'neba/styles.css';
```

`neba/styles.css` is finished CSS — the design tokens, the compiled rules for every utility class the components use, and a small reset whose every rule is specificity 0 so your own styles always win. [Tailwind CSS](https://tailwindcss.com) v4 builds this package; it does not have to be installed in yours.

That is the whole setup. No provider is required at the root, no theme object, no config file.

If your project already runs Tailwind v4, import `neba/tailwind.css` instead — the token sheet, which registers the package as a style source so your own build generates the utilities in the same pass as your app's:

```css
@import 'tailwindcss';
@import 'neba/tailwind.css';
```

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

Placement props are logical, not physical — `start`/`end` rather than `left`/`right` — so layouts flip correctly under RTL. The full rules are in [**Prop conventions**](https://neba.cdget.com/design/prop-conventions).

```tsx
<Button size="sm" color="danger" variant="outline">Delete</Button>
<Chip size="sm" color="danger" variant="outline">Overdue</Chip>
```

### Components

**Inputs** — Button, IconButton, ButtonGroup, SegmentedButton, TextField, NumberField, OtpField, Select, Combobox, Checkbox, RadioGroup, Switch, Slider, Menu (with submenus, checkbox and radio items), ContextMenu, FilePicker, Pagination, ColorPicker, DatePicker, TimePicker, DateTimePicker, DateRangePicker

**Surfaces** — Box, Card, Accordion, Tabs, Carousel, Toolbar, Pill, Spoiler, ChatBubble, Drawer, Popover, Mockup

**Display** — Typography, TextLink, Blockquote, Highlight, Divider, Chip, Badge, Avatar, Icon, Shortcut, Statistic, List, Table, DataTable, Timeline, Breadcrumb, TreeView

**Feedback** — Alert, Dialog, Toast, Tooltip, Overlay, Skeleton, Empty, ProgressLinear, ProgressCircular, ProgressBox

**Layout** — Container, Grid (with GridContainer), Panes, AspectRatio

**Transitions** — AnimateFade, AnimateGrow, AnimateZoom, AnimateSlide, AnimateRotate, AnimateBlink, AnimateAppear, AnimateTyping, AnimateLighting, AnimateMarquee, AnimateHeadline

Recent additions: **Empty** — what stands where content would have been, in four slots: a glyph, a headline, a sentence and an action. The headline defaults to the reader's language, so an empty state that says nothing useful is never the one that ships, and it is the other half of **Skeleton** — one is content on its way, the other is content that is not coming. Before it, **Mockup** — a device with a screen you can put anything on, in three shapes (phone, tablet, and a desktop that is either a monitor or a laptop), with each system's own status bar, dock or taskbar drawn on it, a bezel and a finish for the hardware, and a camera cut-out that can be a notch, a dynamic island or a punch hole. The screen is a viewport at the device's real resolution, so the content inside is laid out against a phone rather than against the page. Before it, the **Animate** family — eleven wrappers that make anything move (**AnimateFade**, **AnimateGrow**, **AnimateZoom**, **AnimateSlide**, **AnimateRotate**, **AnimateBlink**, plus **AnimateAppear**, **AnimateTyping**, **AnimateLighting**, **AnimateMarquee** and **AnimateHeadline** for the effects that have to know what their children are), each taking the same settings for duration, delay, repeat and what triggers it; the six named effects are also a `transition` prop on the components that display something, and every one of them is switched off entirely by a reduced-motion preference. Alongside them, **ColorPicker** — a saturation square, a hue rail, an optional opacity rail and a grid of swatches, reading and writing hex, `rgb()` and `hsl()` with no colour library underneath. Before those, **Drawer** (a panel on one edge of the window, either floating over the page or fixed in the layout — one component, one `mode` prop apart), **Popover** (a sheet anchored to the control that opened it, holding content that can actually be clicked and typed into), **Skeleton** (the shape of something that has not loaded yet, so the page does not reflow when it arrives) and **AspectRatio** (a box that keeps a proportion whatever width it is given); before those, **ChatBubble** (one message in a conversation, where the avatar, the time, the delivery mark, the media and the link card are each drawn only when given something), **Spoiler** (content covered by a blur rather than hidden, so a reader can see there is something there without reading it by accident), **TextLink** (a link with no surface of its own, and a mark for the ones that take over the window), **Avatar** (falls back to initials, a glyph or a silhouette, so it is never an empty box), **TreeView**, **Breadcrumb**, **Panes** (regions with a draggable bar between each pair) and **OtpField**; before those, **Blockquote**, **Shortcut**, **Highlight**, **SegmentedButton** and **Timeline**, and the four pickers — **DatePicker**, **TimePicker**, **DateTimePicker** and **DateRangePicker** — which take and return a plain `Date` and add no date library to your bundle.

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

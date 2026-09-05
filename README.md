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
- **ESM only**, TypeScript declarations included, and genuinely tree-shakeable — every component compiles to its own module, and importing one costs about what one costs. A `Button` is ~5 kB gzipped including its Base UI parts, a `Chip` is ~3 kB, and a twelve-component app is ~70 kB; the whole library, all one hundred and seventy-five exports at once, is ~265 kB.
- **Two runtime dependencies** — Base UI, and `highlight.js`, which only [CodeBlock](https://neba.cdget.com/components/display/code-block) reaches and only through a dynamic import, so it never lands in a bundle that did not ask for it. React 18 or 19, Node.js 18 or later.

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

### Next.js and React Server Components

Every component carries `'use client'`, so it can be imported straight into a Server Component — no wrapper, no `transpilePackages` entry. The directive marks a boundary, not a page: the page stays a Server Component and only the components it renders reach the browser. The ordinary rule about that boundary still applies — an event handler defined in a Server Component cannot be passed across it.

The `neba` barrel and `neba/locales` are deliberately left unmarked, so a Server Component importing the barrel reaches the components behind it rather than a boundary of its own, and `registerMessages` stays a plain function. Bundlers that do not implement Server Components ignore the directive entirely.

A few components provide context and are mounted once, near the root, only if you use them — `ToastProvider` (paired with the `useToast()` hook) and `TooltipProvider`.

Every component is also its own entry point, named after its folder:

```tsx
import { Button } from 'neba/button';
import { TextField } from 'neba/text-field';
```

Both forms produce the same bundle. The root barrel is the one to reach for; the subpath is there for a build that would rather not parse three hundred modules to keep five, and as an escape hatch for a bundler that does not honour `sideEffects`.

### Languages

Neba writes very little text of its own — a Button says what you hand it — but a few components have to invent a string: the label on a Dialog's close button, the word under a chat message that says it was read, the sentence a screen reader hears after a link that opens a new tab.

Those ship in English. Eighteen other languages are included in the package and none of them is in your bundle until you say so:

```tsx
import { registerMessages, ko } from 'neba/locales';

registerMessages('ko', ko);
```

Call it once, at module scope, before your first render. Then a `locale` prop translates:

```tsx
<Dialog locale="ko" title="설정" showClose />
```

A registered language costs about 2.8 kB gzipped and you pay only for the ones you name. Tags are matched by script, then by region, then by language — registering `ko` answers `ko-KR`, and `zhHans` registered as `zh-hans` answers `zh-CN` and a bare `zh`. Available: `ko`, `ja`, `zhHans`, `zhHant`, `es`, `pt`, `fr`, `de`, `it`, `nl`, `pl`, `ru`, `tr`, `ar`, `hi`, `id`, `vi`, `th`, each also its own entry point (`neba/locales/ko`).

Anything the platform already knows — month names, weekday names, AM/PM, number and date formats — comes from `Intl` and needs no registration. And every string a component invents also has a prop that overrides it, so a language Neba does not carry is never a dead end.

### One place for your defaults

```tsx
import { NebaProvider } from 'neba';

<NebaProvider
  defaults={{ size: 'sm', density: 'compact', locale: 'ko' }}
  defaultColorScheme="system"
>
  <App />
</NebaProvider>;
```

Optional, and every component works without it. It fills in `size`, `density`, `variant` and `locale` where a call site left them out — the call site always wins — owns the colour scheme (`useColorScheme()`, plus a `colorSchemeScript()` for the first-paint flash), and sets the writing direction. `color` and `elevation` are deliberately not defaultable; [the guide](https://neba.cdget.com/guide/provider) says why.

### Hooks

The hooks the components already run on, from `neba/hooks` (or from the package root):

```tsx
import { useDisclosure, useBreakpoint, useShortcut } from 'neba/hooks';

const { open, onOpen, setOpen } = useDisclosure();
const desktop = useBreakpoint('lg');

useShortcut('Mod+K', onOpen);
```

`useDisclosure`, `useMediaQuery`, `useBreakpoint`, `useCurrentBreakpoint`, `useBreakpointValue`, `usePrefersReducedMotion`, `useElementSize`, `useOnScreen`, `useShortcut`. Everything here is machinery the library needed for itself — there is no general-purpose hook collection, and there is not going to be one. Full notes in [the hooks guide](https://neba.cdget.com/guide/hooks).

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

**Inputs** — Button, IconButton, ButtonGroup, SegmentedButton, Toggle, ToggleGroup, Form, Fieldset, FloatingActionButton (with FloatingAction), TextField, NumberField, OtpField, Select, Combobox, TreeSelect, Checkbox, RadioGroup, Switch, Slider, Rating, Menu (with submenus, checkbox and radio items), ContextMenu, Menubar, NavigationMenu, CommandPalette, FilePicker, Transfer, Pagination, BottomNavigation, FloatingBottomNavigation, ColorPicker, Calendar, DatePicker, TimePicker, DateTimePicker, DateRangePicker

**Surfaces** — Box, Card, Accordion, Collapsible, Tabs, Carousel, Toolbar, Pill, Spoiler, HowToSteps, ChatBubble, Drawer, Popover, Mockup, WindowPane, HoverCard

**Display** — Typography, TextLink, Blockquote, Highlight, Divider, Chip, Badge, Avatar, AppLogo, Icon, Image, Gallery, Shortcut, List, DataList, Table, DataTable, CodeBlock, Timeline, Breadcrumb, Anchor, TreeView, VisuallyHidden

**Charts** — Statistic, Sparkline, LineChart, AreaChart, BarChart, PieChart, ScatterChart, TimelineChart, HeatmapChart, GaugeChart

**Feedback** — Alert, Dialog, Confirm, Popconfirm, Toast, Tooltip, Overlay, Skeleton, Empty, ProgressLinear, ProgressCircular, ProgressBox, Meter, Tour

**Layout** — PageLayout (with Header, Footer and Sidebar), Container, Grid (with GridContainer), Flex, Panes, Stack, Show, AspectRatio, Portal, ScrollZone, ScrollArea

**Transitions** — AnimateFade, AnimateGrow, AnimateZoom, AnimateSlide, AnimateRotate, AnimateBlink, AnimateReveal, AnimateFloat, AnimateShake, AnimateAppear, AnimateSplit, AnimateTyping, AnimateScramble, AnimateCounter, AnimateLighting, AnimateMarquee, AnimateHeadline

**Added in the last two releases** — Gallery, Flex, Show, Stack and the six new `Animate*` (Reveal, Float, Shake, Split, Counter, Scramble) in 1.12.0; Calendar, TreeSelect, Image, Confirm, Popconfirm and VisuallyHidden in 1.11.0. The [changelog](https://neba.cdget.com/changelog) has the rest.

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

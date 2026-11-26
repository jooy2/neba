# CLAUDE.md

Guidance for Claude Code (and other AI agents) working in this repository.

## What this project is

**Neba** is a design-component library in two packages that share one design language, one prop vocabulary and one documentation site:

| Path | What it is | Published as | Guide |
| --- | --- | --- | --- |
| `packages/react` | The React package | [`neba`](https://www.npmjs.com/package/neba) on npm | [packages/react/CLAUDE.md](packages/react/CLAUDE.md) |
| `packages/flutter` | The Flutter package | [`neba`](https://pub.dev/packages/neba) on pub.dev | [packages/flutter/CLAUDE.md](packages/flutter/CLAUDE.md) |
| `docs` | The documentation site, shared by both | [neba.cdget.com](https://neba.cdget.com) | [Documentation](#documentation) below |
| `examples/flutter` | A sample app for iOS, iPadOS and Android | not published | [examples/README.md](examples/README.md) |

**Read the guide of the package you are changing before you change it.** This file holds only what is true of the whole repository; everything about building, styling and testing a package is in that package's own `CLAUDE.md`.

There is no install at the repository root and no root `package.json`. Each of the four is its own project, entered and run on its own.

**The Flutter port is in progress.** [TODO.md](TODO.md) is the roadmap: the foundation, then the components, then their tests, then the sample app's tests, then real devices. Work through it in that order, tick an item off in the same commit as the work, and add what you find along the way rather than keeping it in a session.

## One design language

[docs/ko/design/design-language.md](docs/ko/design/design-language.md) is the source of truth for how a Neba surface looks and behaves, and both packages answer to it. The React package states it in CSS (`packages/react/src/styles.css`) and the Flutter package computes the same tokens in Dart.

- **The stylesheet is where a token is defined.** `packages/flutter/lib/src/theme/tokens.dart` writes the same `oklch()` values and derives the rest with the same `color-mix()` arithmetic, and `packages/flutter/test/theme/tokens_parity_test.dart` reads the stylesheet and fails on any difference. Change a token on both sides in one commit.
- **A component means the same thing in both packages.** Same name with a `Neba` prefix in Dart (`Button` is `NebaButton`), same props under the same names, same values. A difference is allowed only where Flutter's own idiom demands it — `onPressed` rather than `onClick`, `child` rather than `children`, a controlled `value` with `onChanged` — and every difference is written on the component's documentation page.
- **The rules that follow from the design language hold in both.** No transform on a control, press instant and release slow, elevation `0` by default, translucency tuned with the blur, state never expressed with opacity. The React guide explains each in CSS terms and the Flutter guide in widget terms.

## Versions

The two packages share version numbers from **1.21.0**, the first Flutter release and the React package's next one. Each is released from a tag of its own and keeps its own changelog, so a release of one does not force a release of the other; when both change, they are cut together at the same number.

## Documentation

The docs are VitePress, and VitePress compiles Markdown to **Vue** — so a React component cannot be written into a page. Every live preview is a React island: `theme/components/Demo.vue` owns a `<div>` and hands it to `createRoot()` on mount.

```
docs/.vitepress/
  config.ts                 # React plugin, the `neba` alias, the repo's PostCSS config, i18n
  data/props.ts             # the props tables, as data — both locales per row
  data/i18n.ts              # the few strings the docs' own components render
  demos/{component}/*.tsx   # one file per example — real, runnable React
                            # folder name matches the component's own, lowercased
  demos/catalog/all.tsx     # the card grid on the components index — the docs'
                            # own, not a component's, hence its own folder
  demos/home/hero.tsx       # the home page's hero object
  demos/concepts/*.tsx      # one whole fictional screen per file, for Examples
  demos/showcase/app.tsx    # the sample screen on Overview
  theme/
    index.js                # the default theme, with Layout, Demo and PropsTable registered
    components/Layout.vue   # the default layout + the home page's mark and live hero
    components/Demo.vue     # the React island + the show-code toggle
    components/PropsTable.vue
    styles/index.css        # Tailwind (no Preflight) + tokens + docs chrome
    styles/scope.css        # Preflight, cut down and scoped to `.neba-scope`
    styles/docs.css         # the docs' own furniture: Demo frame, props table, home
    custom.css              # the default theme's shell: sidebar, article and outline widths
docs/public/                # served at `/` — the mark, the icons, llms.txt
  samples/                  # the pictures the previews draw on: photos, people, logos
docs/{ko,en}/
  index.md                  # home — `layout: home`, with a live hero and body sections
  guide/*.md                # getting started, the provider, the hooks and A2UI
  components/index.md       # the index grid of every component
  components/{group}/*.md   # one page per component, grouped (charts, display, feedback, inputs, layout, surfaces, agent, transitions)
  examples/overview.md      # every component on one sample screen
  examples/concept-*.md     # one fictional screen per page (landing, dashboard, signup)
  design/*.md               # design language, colour, prop conventions, breakpoints
  browser-support.md        # minimum browser versions; a loose page, under Discover more
  changelog.md              # generated from packages/react/CHANGELOG.md; git-ignored
```

**The sidebar is four sections: Guide, Components, Design, Discover more** — with the component groups kept as headings inside Components. Almost none of that can be stated by the folder tree, so `arrangeSidebar` in `config.ts` reshapes the generated menu once per locale, and the comment above it is where each rule and its reason are written: the components index as a row of its own, Examples as a group inside Components with its own top-level URLs, the component groups kept and only what is inside them flattened, `agent` and `charts` placed rather than sorted, pages inside a group sorted by name rather than by `order`, and the headings `groupLabels` has to supply. Read it before changing the menu. One thing it does not say: `/examples/` has **no `index.md` on purpose**, since an index listing four whole-screen pages would be a row of links standing where the heading already is.

The groups are folders, and which one a component belongs in is decided by what it does rather than by what it looks like:

- **`inputs`** — the reader acts on it. Button, IconButton, ButtonGroup, SegmentedButton, Toggle, ToggleGroup, Form, Fieldset, TextField, NumberField, OtpField, Select, Combobox, Checkbox, CheckboxGroup, RadioGroup, Switch, Slider, Menu, Menubar, NavigationMenu, CommandPalette, FilePicker, Transfer, TreeSelect, Pagination, Rating, ColorPicker, Calendar, DatePicker, TimePicker, DateTimePicker, DateRangePicker, BottomNavigation, FloatingBottomNavigation, FloatingActionButton.
- **`display`** — it shows something and nothing more. Typography, TextLink, Blockquote, Highlight, Divider, Chip, Badge, Avatar, AppLogo, Icon, Image, Gallery, Shortcut, List, DataList, Table, DataTable, CodeBlock, Timeline, Breadcrumb, Anchor, TreeView, VisuallyHidden.
- **`charts`** — it draws numbers. Statistic, Sparkline, LineChart, AreaChart, BarChart, PieChart, GaugeChart, ScatterChart, HeatmapChart, TimelineChart. Statistic lives here rather than in `display` because what a reader is looking for is not "a component that shows a value" but "the place the charts are", and a number with a delta on it is the smallest chart on the page. The group is also what the shared data model is documented against: every one of them takes the same `series`/`data`, so the pages cross-reference one definition rather than each restating it.
- **`feedback`** — it says what happened, or what is happening. Alert, Dialog, Confirm, Popconfirm, Toast, Tooltip, Overlay, ProgressLinear, ProgressCircular, ProgressBox, Meter, Skeleton, Empty, Tour.
- **`surfaces`** — it draws a sheet and holds other things on it. Box, Card, Accordion, Collapsible, Tabs, Carousel, Toolbar, Pill, Spoiler, HowToSteps, ChatBubble, HoverCard, Popover, Drawer, WindowPane, Mockup.
- **`agent`** — it shows what an agent is doing. ToolCall, Approval, Reasoning, AgentSteps, ContextWindow, Sources, InlineCitation, StreamingText, PromptInput. Its own group rather than spread across `feedback`, `display` and `inputs`, which is where each one would go on its own: what a reader is looking for is not "a component that discloses something" but "the parts an assistant screen is made of", and the nine only make sense next to each other — a `ToolCall` inside an `AgentSteps` under a `Reasoning` above a `PromptInput` is the whole of what this is for. They share a vocabulary the rest of the library does not use (`NebaRunStatus`, a stream that owns the open state, a body that is not there on the first render), and a group is the one place that vocabulary can be stated once.
- **`layout`** — it decides where things go. Container, Grid + GridContainer, Flex, Panes, Stack, Show, AspectRatio, ScrollArea, ScrollZone, Portal, and the four that build a page's shell: PageLayout, Header, Footer, Sidebar. `Flex` and `Show` are the two that answer a breakpoint directly — one is a row that becomes a column, the other is its children at some widths and not at others — and both are here rather than in a group of their own because what they decide is still where something goes. The first three draw nothing at all; the page shell is the exception, and a deliberate one — a header and a sidebar are _regions_, and a region has an edge. What they still do not decide is the gutter or the measure inside them, which is Container's, so a PageLayout with a Container in it is the ordinary arrangement.
- **`transitions`** — it draws nothing either, and moves what is inside it. The seventeen `Animate*` wrappers: AnimateFade, AnimateGrow, AnimateZoom, AnimateSlide, AnimateRotate, AnimateBlink, AnimateReveal, AnimateFloat, AnimateShake, AnimateAppear, AnimateSplit, AnimateTyping, AnimateScramble, AnimateCounter, AnimateLighting, AnimateMarquee, AnimateHeadline. They are their own group rather than part of `layout` because a layout component is about where something sits and these are about how it got there; and they are one group rather than two — the nine that are only a keyframe and the eight that have to understand their children — because a reader looking for "the animation ones" is looking for one place.

`layout` is separate from `surfaces` for that last reason: a Container is a gutter and a Grid is a width, and the moment either one had a surface it would stop being usable as the outermost thing on a page. Header, Footer and Sidebar sit here rather than in `surfaces` on the other half of the same argument — a Card is a sheet you put things on and could be anywhere, while a header is the top of the page and is only ever one thing.

**The changelog is generated, not written.** Each package keeps its own `CHANGELOG.md` beside its manifest, where npm, pub.dev and anyone browsing the repo expects it. `docs/scripts/copy-changelog.mjs` writes the React one into `docs/{locale}/changelog.md` with the frontmatter the sidebar needs, and `npm run dev` and `npm run build` in `docs/` run it first. The copies are git-ignored; never edit them. The Flutter changelog joins the same page once the site can switch between the two packages, which is a step in [TODO.md](TODO.md).

Things that will bite:

- **The locale routing is a three-way agreement.** `vitepress-i18n` puts the root locale in `locales.root` with no path prefix, `vitepress-sidebar` is told to resolve its links against `/`, and `rewrites` is what actually moves the root locale's folder, `docs/en/**`, to `/`. Change one and every sidebar link 404s. Other locales keep their folder as their URL prefix.
- **A demo is referenced twice, by the same path.** `<Demo src="button/variants">` mounts `demos/button/variants.tsx`, and the `<<< @/.vitepress/demos/button/variants.tsx` snippet inside it is what gets displayed. That is deliberate — the code shown is the file that ran, so the two cannot drift. Blank lines around the `<<<` are required, or Markdown swallows it into the HTML block.
- **Demos import from `'neba'`**, aliased to `packages/react/src/index.ts`. The displayed source is then exactly what a consumer would write, and a component edit shows up without a rebuild.
- **A demo that needs a picture links one out of `docs/public/samples`**, never a drawn SVG and never a remote URL. Photographs are in `photos/`, faces for an avatar in `people/`, product marks in `logos/`; the README beside them records where they came from and under which licence, and a file added there has to be added to that note. A stand-in drawn inline reads as a placeholder, which is the one thing a preview must not look like — and a `filter`, a `frame` or a blur has nothing to work on.
- **Demos are written in English and shared by every locale** — they are code samples, and the repo writes code in English. Only the two that are documentation rather than sample code (`catalog/all.tsx`, and anything like it) take the `locale` prop `Demo.vue` passes in and localise themselves. Prose belongs in the Markdown around the preview.
- **A props row carries both languages.** `data/props.ts` keys every description by locale, so a Korean and an English table cannot drift into listing different props.
- **Tailwind ships without Preflight here.** Preflight resets `h1`…`p`, links and lists globally, which would flatten VitePress's own typography. `scope.css` re-applies only the parts the library depends on (above all `border: 0 solid`) inside `.neba-scope`. Utilities are imported _unlayered_ on purpose: VitePress's theme is unlayered, and a layered rule loses to an unlayered one no matter how specific.
- **`.vp-doc` is already styling the preview.** Base UI renders a `<p>` for a field description; a card footer can hold an `<a>`. Rules that undo `.vp-doc` need two classes to outrank it — that is why half of `scope.css` is prefixed `.vp-doc .neba-scope`. Where the component itself has to win against `.vp-doc` rather than merely survive it — table cells — the fix belongs in the component, inline, not here; there is no specificity that both beats `.vp-doc td` and loses to a utility.
- **Every tag that reset names is a tag whose padding a component can no longer set.** `.vp-doc .neba-scope` is two classes and a padding utility is one, so the `padding: 0` list in `scope.css` is kept to exactly what something actually pads: `ul`, `ol` and `blockquote`. It once included `li` and `figure`, and a Timeline's `pb-6` between steps and a Blockquote's whole inset silently came out as zero. `[role="list"]` is excluded for the same reason — it is what List, Timeline and Pagination put on their root, so it marks the lists whose padding belongs to the component.
- **A portalled popup leaves `.neba-scope`.** Select's popup renders at the end of `<body>`, outside the element the preview mounted into. Its positioner carries `neba-portal`, which `scope.css` hangs the same reset off. The library treats that class as a hook, not a style; a consumer with real Preflight needs nothing.
- **Dark mode is free.** VitePress puts `.dark` on `<html>`, which `packages/react/src/styles.css` already answers to.
- **A preview can be in the theme the page is not in.** `Demo.vue` puts `data-theme` on `.neba-demo-canvas` only, which makes the canvas a theme root of its own; the attribute is absent until someone presses the switch, so an untouched preview is exactly what it always was and still follows the site switch. Only the canvas — the frame, the "Show code" bar and the snippet stay on the page theme, because VitePress selects Shiki's dark tokens with `.dark …` and its light ones with `html:not(.dark) …`, and the second of those cannot be beaten from inside the page. The canvas backdrop is therefore mixed from `--neba-fg`/`--neba-surface` rather than taken from `--vp-c-bg-soft`: a VitePress variable would stay on whatever the site switch says. **A portalled popup still does not follow it** — a Select's list or a Dialog renders at the end of `<body>`, outside the canvas, so it comes up in the page's theme.
- The docs' `<Demo>` is client-only, so an SSR build renders an empty box and fills it on hydration.
- **A preview mounts when it is on screen, not when the page loads.** A component page holds a dozen of them and mounting all at once put the one being read behind chunks for previews far below the fold. What is already visible is measured in `onMounted` and mounts straight away — an `IntersectionObserver` reports its first entry a task later, and the preview at the top of the page is what that task would delay — and everything else waits for the observer. React and its DOM renderer are fetched when the first `<Demo>` is _set up_ rather than inside a lifecycle hook, so the largest download on the page starts during hydration instead of after it — and not when `Demo.vue` is evaluated, because the theme imports it on every page and a page with no previews has no use for React. The empty box holds `minHeight` (40px by default, a `<Demo>` prop), and it keeps holding it once the components are there, because a reserve that is dropped on arrival is the same jump twice.
- **`optimizeDeps.include` is derived from `packages/react/src/`, not written out.** Every `@base-ui/react` subpath is reached only through a demo, which is reached only through a dynamic import, so the dev server would discover them one preview at a time and re-optimize — reloading the page under whoever is reading it. `server.warmup` pre-transforms `packages/react/src/**` for the same reason: the first preview otherwise asks for every module in `src/` at once, through the barrel. The demos are deliberately not warmed; there are over six hundred of them.
- **The lede is also the page's `<meta name="description">`.** `transformPageData` reads it out of the source, because VitePress otherwise gives every page the site's own description and nearly three hundred pages ship one sentence between them. A page with no lede falls back to its first prose paragraph, which is why the guide and the design notes still get one. Write the lede as a sentence that stands alone in a search result and both jobs are done at once. Everything else a crawler reads — the canonical URL, the `hreflang` pair, Open Graph, the home page's JSON-LD — is assembled in `transformHead`, which runs **only in a build**: check it by reading a file under `docs-dist/`, never in the dev server. `robots.txt` is written there too, from `package.json`'s `homepage`, so the sitemap it names cannot drift from the sitemap that exists.
- **The shell's own widths are in `theme/custom.css`.** The sidebar, the article and the outline are sized against each other, and the outline runs to `h3` — a component page is one `h2` with a dozen prop names under it. Every rule in that file overrides a Vue scoped style, so each selector deliberately carries one class more than it needs: a scoped rule compiles with a `[data-v-…]` on it, and an equally specific override would be decided by stylesheet order.

**Every page serves both packages.** A reader picks React or Flutter with the switch at the top of the sidebar, the choice is kept in `localStorage` under `neba-framework`, and a script in `<head>` writes it to `<html data-fw>` before the first paint. Nothing is two pages:

- **`::: fw react` and `::: fw flutter` mark what differs**, and `theme/styles/framework.css` displays the half for `html[data-fw]`; without JavaScript the React half shows. A block both see is `::: fw react flutter`, and an id the site does not know is dropped, so a typo hides a block from everyone. Leave a blank line around every fence: Prettier joins a fence to a paragraph it touches, and `text ::: fw react` is text.
- **A container inside another needs one more colon than the one inside it** (`:::: fw react` around a `::: tip`), because `markdown-it-container` closes at the first fence long enough. `misplacedContainers()` in `config.ts` fails the build on that, on a fence sharing a line with prose and on a page whose containers do not balance; the dev server does not run it.
- **`<Fw react="onClick" flutter="onPressed" code />` swaps a few words inside a sentence.** A heading written as one takes its anchor from the React text (`headingText` in `config.ts`), and `Layout.vue` renames its outline entry to the half on screen and hides the entries of headings in the hidden half.
- **The Flutter props table is derived from the React one.** `<PropsTable name="Button" />` draws both; the Flutter rows live in `data/props-flutter/{page}.ts`, built with `from()` and `renamed()` from `props-flutter/shared.ts`, which copy the React row and its descriptions and lay over only what Dart spells differently. A component with no Flutter table says so in the Flutter half.
- **A component page the Flutter package does not have yet carries a note in its Flutter half**, put there by `Layout.vue`. The port's commit takes it off with `flutter: true` in the page's frontmatter, in both locales.
- **`/changelog` holds both packages' histories**, each in its own `::: fw` block, React first so its anchors keep the ids they had.

Adding a component means six edits: a page under `components/{group}/` **in every locale**, its rows in `data/props.ts`, its demo files under `demos/`, a card in `demos/catalog/all.tsx`, a place on the sample screen in `demos/showcase/app.tsx`, and a line in `docs/public/llms.txt`. Only the first is per-locale; the demos and the props data are shared.

The last one is the one that gets forgotten, because nothing renders it and no build fails without it. `llms.txt` is the whole site flattened for an agent, a list of every component the library has, read by something deciding whether to use it at all — so a component missing from it does not exist as far as that reader is concerned. It has no generator; check it against `packages/react/src/index.ts` when a release is being cut.

[README.md](README.md) and the two package READMEs deliberately do **not** list the components. It names the groups and links to the docs, which already have every one; a second full list made the README long and was one more place to fall out of step.

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

There is no root install. Run each from its own folder:

```bash
# packages/react — the npm package
npm install && npx playwright install chromium
npm test              # the suite, in a real browser
npm run lint && npm run typecheck
npm run build && npm run size && npm run compat

# packages/flutter — the pub.dev package
flutter pub get
flutter analyze
dart format lib test tool
flutter test
dart run tool/generate.dart   # the barrel and the gallery's demo registry

# packages/flutter/example — the gallery, and the renderer behind the Flutter previews
flutter run -d chrome

# docs — the documentation site
npm install
npm run dev           # copies the changelog and the A2UI catalog in, then serves
npm run build         # the static site into ../docs-dist/
npm run lint && npm run typecheck

# examples/flutter — the sample app
flutter test                                  # the flows on the host, phone and tablet sizes
flutter test integration_test -d <device>     # the same flows on a simulator, an emulator or a device
```

The docs never read `packages/react/dist/`, and none of the site's scripts build it: the `neba` alias points at `packages/react/src/index.ts`, so a component edit is on screen without a rebuild. The site does need `packages/react/node_modules`, because the library's own imports resolve from there; run `npm install` in `packages/react` once.

**Desktop and device runs stay out of the way.** A Flutter desktop window or an Electron window started by a test is started hidden, a simulator is booted with `xcrun simctl boot` rather than through the Simulator app, and an Android emulator runs with `-no-window`. Ask before running anything on a real device: the maintainer supplies the connection when one is needed.

## Releasing

Each package is released on its own, from a tag of its own, and only the last step is automatic. **The registries are published by [release.yml](.github/workflows/release.yml)**, and no tag is created or pushed by anyone but the maintainer — an agent asked to prepare a release stops at the push of the cut commit.

1. **Cut the version**, as one commit on `main` per package, `[javascript] chore: cut X.Y.Z` or `[dart] chore: cut X.Y.Z`, or one `chore: cut X.Y.Z` for both.
   - **React:** `version` in `packages/react/package.json` and in both places at the top of `packages/react/package-lock.json` (the root entry repeats it); for a minor or a major, `node scripts/build-catalog.mjs --release` in `packages/react`, whose `docs/a2ui/X.Y.json` is committed with it.
   - **Flutter:** `version` in `packages/flutter/pubspec.yaml`, and the `neba` entry in `packages/flutter/example/pubspec.lock` and `examples/flutter/pubspec.lock`, which follow the path dependency.
   - **Both:** the `## vNext (YYYY--)` section of the package's `CHANGELOG.md` renamed to `## X.Y.Z (YYYY-MM-DD)`, with a new, empty `## vNext (YYYY--)` above it. Push, and let CI pass on that commit.
2. **Tag it** with the package's prefix and push the tag by name: `git tag react-vX.Y.Z` and `git push origin react-vX.Y.Z`, or `flutter-vX.Y.Z`. Never `git push --tags`.
3. **`release.yml` runs on the tag.** It refuses a tag that does not name the manifest's version and a changelog section still called `vNext` or undated.
   - The `react` job writes the tagged commit into `package.json` as `gitHead`, packs the package with `npm pack`, runs `npm run size` and `npm run compat` on that build, publishes the tarball to npm and attaches it to the GitHub release. A version with a pre-release part goes to npm under `next`.
   - The `flutter` jobs ask pub.dev whether it has the version, publish through the Dart team's reusable workflow, and attach the archive pub.dev serves, checked against the hash pub.dev records. Pushing a tag again repairs the release without publishing twice.

**Neither registry holds a token of ours.** npm's trusted publisher for `neba` names this repository, `release.yml` and the `release` environment; pub.dev's automated publishing for `neba` names this repository, the tag pattern `flutter-v{{version}}` and the `pub.dev` environment. Renaming the workflow file, an environment or the tag pattern breaks publishing until the registry's settings are changed to match. pub.dev lets a workflow publish only a package that already exists, so **the first Flutter version is published by hand** from `packages/flutter` with `dart pub publish`, automated publishing is switched on in the package's admin page, and only then is its tag pushed: the workflow finds the version on pub.dev and writes the GitHub release.

**The body is the version's whole changelog section**, followed by links to the docs site's changelog and to the package's `CHANGELOG.md` at the tag. GitHub cuts a release body off at 125,000 characters, so a longer section is written as far as it fits, in whole entries, and ends on a line pointing at the rest. Read the body before tagging with `node .github/scripts/release-notes.mjs react-vX.Y.Z` or `flutter-vX.Y.Z`.

**The React package's releases from before the split are tagged `vX.Y.Z`**, from 1.0.0 to 1.20.0, at the commit npm recorded as its `gitHead` wherever it recorded one; 1.13.0's tag is on the bump commit after its `gitHead`, 1.14.0 is not on npm and its tag is on its bump commit, and 0.0.1 has none. Running `release.yml` from the Actions tab writes the GitHub releases those tags never got, with `.github/scripts/release-backfill.mjs`. 1.19.0, 1.19.1 and 1.20.0 are on npm without a `gitHead`, which is why the workflow now writes it before packing.

## CI

Every workflow runs in the folder it is about, and only when that folder changes:

- [run-test-react.yml](.github/workflows/run-test-react.yml) — `packages/react`: lint, typecheck, bundle size, browser support, the suite on three systems in three browsers, and once each on React 18 and on Zod 4. The React guide describes each job.
- [run-test-flutter.yml](.github/workflows/run-test-flutter.yml) — `packages/flutter`: analyse, format and test on three systems, on the Flutter floor `pubspec.yaml` declares and on the latest stable release; and the gallery analysed, formatted and built for the web. It also runs when `packages/react/src/styles.css` changes, because the token parity test reads it.
- [run-test-examples.yml](.github/workflows/run-test-examples.yml) — `examples/flutter`: analyse, format, and the flows on the host.
- [run-test-docs.yml](.github/workflows/run-test-docs.yml) — on pull requests: the site's typecheck, lint, format check and build.
- [publish-documentation.yml](.github/workflows/publish-documentation.yml) — builds the site on `main` and deploys it to GitHub Pages.
- [release.yml](.github/workflows/release.yml) — [Releasing](#releasing).

Every job carries a `timeout-minutes`, because GitHub's default is six hours and the failure that matters is a runner that stops answering rather than one that exits.

## Conventions

- **All repository content is written in English** — code, comments, docs, issues, commit messages. (The `docs/ko` locale is the deliberate exception.)
- Commit messages follow the Udacity style guide: `tag: message (fixes #1)` with tags `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, plus the informal `package` and `typo`. **A change to one package carries its prefix**: `[javascript]` for `packages/react`, `[dart]` for `packages/flutter` and the Flutter apps, and no prefix for a change to both, to the docs alone or to the repository. See [CONTRIBUTING.md](CONTRIBUTING.md).
- One component to one commit, so a component's port, tests, demos and docs land together and can be read or reverted on their own.
- Prettier settings that matter, in the React package and the site: single quotes, no trailing commas, LF endings, `proseWrap: never`. The Flutter package and apps use `dart format` at a page width of 100.

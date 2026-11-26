# TODO

The roadmap of the Flutter port, written so that the next session can pick it up without this one's context. The work runs in five phases, in this order: the foundation, the components, the component tests, the sample app's tests, and the tests on real devices. A phase starts once the one before it is done, unless an item says otherwise.

Tick a box in the same commit as the work it records, and add what you find along the way here rather than keeping it in a session. Delete the file once every box is ticked.

The Flutter package's first version is **1.21.0**, the same number as the React package's next release. Both changelogs keep their entries under `## vNext (2026--)` until that release is cut.

## 1. Foundation

What is done:

| Commit | What it did |
| --- | --- |
| `6ac7843e` | The React package moved into `packages/react`, with its own README and LICENSE; the release scripts into `.github/scripts`. |
| `831b776e` | `docs/` became an npm project of its own, reading the React package from `packages/react`. |
| `70aa416d` | CI per package, releases tagged `react-v*` and `flutter-v*`, pub.dev publishing through OIDC. |
| `363f17d6` | `packages/flutter`: the tokens of both themes computed from the React stylesheet and held to it by a test, `NebaTheme`, `NebaProvider`, `NebaDefaults`, the prop vocabulary and `NebaScale`. |
| `f66b114a` | The gallery, `packages/flutter/example`, with a palette demo of the tokens. |
| `debda9d3` | The sample app, `examples/flutter`, whose flows passed on the host and on an iOS simulator booted without its window. |

What is left, in order:

- [x] **The documentation site switches between React and Flutter.** A selector in the sidebar, remembered in `localStorage` and applied by a `<head>` script before the first paint; `::: fw react` and `::: fw flutter` containers around what differs on a page, with a build-time check for a misplaced container; an inline `<Fw react="onClick" flutter="onPressed" />` for a single word; the Flutter props tables in `docs/.vitepress/data/props-flutter/`, each row derived from the React row and stating only what Dart spells differently; both changelogs on `/changelog`. `material-plus-ui` commit `0c317907` is the reference.
- [x] **The guide pages' Flutter halves.** `guide/getting-started` and `guide/provider` have their own; `guide/hooks` and `guide/a2ui` say they are React only; the colour, prop-convention and breakpoint pages say what Dart spells differently, and the design language says which terms it is written in.
- [x] **The Flutter previews on the site.** `docs/scripts/build-flutter-demos.mjs` builds `packages/flutter/example` for the web into `docs/public/flutter/` (git-ignored, skipped when present, `--force` to rebuild); `Demo.vue` shows it in an iframe with `?demo=<key>` when the reader is on Flutter; the Dart snippet under a preview is quoted from `packages/flutter/example/lib/demos/`. `publish-documentation.yml` and `run-test-docs.yml` then install Flutter.
- [x] **The gallery's side of the iframe.** It reports its height and takes the theme by `postMessage`, through `example/lib/host_bridge_web.dart`, written on `dart:js_interop` so no package was added for it, and it draws the docs canvas's backdrop itself.
- [x] **The gallery's font.** Inter 4.1 at 400 and 600, the Latin subset `plass-ui` ships, under the OFL, in `packages/flutter/example/assets/fonts` with a note on why. A web build now fetches nothing from outside the site: the engine and its fallback Roboto come from the build since `--no-web-resources-cdn`. The sample app uses the same font through `package: 'neba_example'`.
- [x] **The internals every control shares**, in `lib/src/internal/`, each with its tests: the acrylic sheet (backdrop blur and saturation over `backing`, the sheen at 148°, the plate's top light and hairline, the grain texture); the interaction state (hover, press, keyboard focus, and the pointer's position); the pointer spotlight and the release afterglow; the focus ring painter; ink that eases with the fill; and the shared glyphs (×, chevron, tick, the turning ring, the severity set).
- [x] **The words the library says on its own behalf.** `NebaLocale` and `registerNebaMessages`, English built in and eighteen languages in `package:neba/locales.dart`, all generated from the React package's tables by `tool/generate.dart`; `generated_test.dart` fails on a table that is out of date and `messages_test.dart` on a key or a placeholder English does not have.
- [x] **The rest of the tokens**, each with its parity test: the chart series ramp, the sequential and diverging ramps, the chart chrome, the ink on a series colour, and CodeBlock's `auto` palette.
- [x] **The `transition` vocabulary**, which eleven displaying components take and Stack staggers: `NebaAnimation` and `NebaTransition` in `lib/src/types.dart`, one named constructor per effect, and `NebaEntrance` in `lib/src/internal/animate.dart`, which plays one with the React package's defaults and keyframes. `NebaBox` took its `transition` with it. The `Animate*` widgets, with their triggers and replays, stay with the transitions group.
- [ ] **The first pub.dev release, by the maintainer.** pub.dev lets a workflow publish only a package that exists, so 1.21.0 is published by hand with `dart pub publish` from `packages/flutter`, automated publishing is switched on with the tag pattern `flutter-v{{version}}` and the `pub.dev` environment, and then the tag is pushed. Not before the components the release is meant to carry are in.

## 2. Components

140 components, grouped as the documentation groups them. One component is one commit holding the widget, its tests, its demos, its documentation page in both locales, its Flutter props table and its changelog entry; `packages/flutter/CLAUDE.md` lists the steps. `NebaProvider` came with the foundation.

Port in this order, because each group is built out of the ones before it: `NebaBox` first, since nearly every demo puts its content on one, then the layout primitives the demos stand on, then `NebaButton` and the rest of the inputs, the display group, feedback, surfaces, charts, the agent group, and the transitions last. Within a group, take the components another component reuses first: `NebaButton` before `NebaIconButton` and `NebaButtonGroup`, `NebaPopover` before `NebaSelect`.

Some components have no single Flutter equivalent of what they are on the web, and their form is decided when they are reached, then written on their page: `NebaPortal` (an `Overlay` entry), `NebaVisuallyHidden` (a `Semantics` node), `NebaTextLink` (a callback rather than an `href`, since the package opens nothing itself), `NebaImage` and `NebaGallery` (an `ImageProvider` rather than a URL), `NebaCodeBlock` (no highlight.js; a tokenizer of its own or a caller-supplied one), and the page shell (`NebaPageLayout`, `NebaHeader`, `NebaFooter`, `NebaSidebar`) against a phone's safe areas.

Demos that wait on a component not ported yet, to be added with it: `grid/auto-grow` (`NebaAvatar`, `NebaTypography`, `NebaChip`, `NebaButton`), `flex/direction` (`NebaTextField`, `NebaButton`), `flex/spacing` (`NebaChip`) and `flex/alignment` (`NebaAvatar`, `NebaTypography`, `NebaButton`). The React demos of per-breakpoint maps (`container/responsive`, `grid/responsive`) have no Flutter twin, because the Flutter widgets take no such map.

### Layout (15)

- [x] `NebaContainer`
- [x] `NebaGrid`
- [x] `NebaGridContainer`
- [x] `NebaFlex`
- [ ] `NebaStack`
- [ ] `NebaShow`
- [ ] `NebaAspectRatio`
- [ ] `NebaScrollArea`
- [ ] `NebaScrollZone`
- [ ] `NebaPanes`
- [ ] `NebaPortal`
- [ ] `NebaPageLayout`
- [ ] `NebaHeader`
- [ ] `NebaFooter`
- [ ] `NebaSidebar`

### Display (23)

- [ ] `NebaTypography`
- [ ] `NebaTextLink`
- [ ] `NebaBlockquote`
- [ ] `NebaHighlight`
- [ ] `NebaDivider`
- [ ] `NebaChip`
- [ ] `NebaBadge`
- [ ] `NebaAvatar`
- [ ] `NebaAppLogo`
- [ ] `NebaIcon`
- [ ] `NebaImage`
- [ ] `NebaGallery`
- [ ] `NebaShortcut`
- [ ] `NebaList`
- [ ] `NebaDataList`
- [ ] `NebaTable`
- [ ] `NebaDataTable`
- [ ] `NebaCodeBlock`
- [ ] `NebaTimeline`
- [ ] `NebaBreadcrumb`
- [ ] `NebaAnchor`
- [ ] `NebaTreeView`
- [ ] `NebaVisuallyHidden`

### Inputs (36)

- [ ] `NebaButton`
- [ ] `NebaIconButton`
- [ ] `NebaButtonGroup`
- [ ] `NebaSegmentedButton`
- [ ] `NebaToggle`
- [ ] `NebaToggleGroup`
- [ ] `NebaForm`
- [ ] `NebaFieldset`
- [ ] `NebaTextField`
- [ ] `NebaNumberField`
- [ ] `NebaOtpField`
- [ ] `NebaSelect`
- [ ] `NebaCombobox`
- [ ] `NebaCheckbox`
- [ ] `NebaCheckboxGroup`
- [ ] `NebaRadioGroup`
- [ ] `NebaSwitch`
- [ ] `NebaSlider`
- [ ] `NebaMenu`
- [ ] `NebaMenubar`
- [ ] `NebaNavigationMenu`
- [ ] `NebaCommandPalette`
- [ ] `NebaFilePicker`
- [ ] `NebaTransfer`
- [ ] `NebaTreeSelect`
- [ ] `NebaPagination`
- [ ] `NebaRating`
- [ ] `NebaColorPicker`
- [ ] `NebaCalendar`
- [ ] `NebaDatePicker`
- [ ] `NebaTimePicker`
- [ ] `NebaDateTimePicker`
- [ ] `NebaDateRangePicker`
- [ ] `NebaBottomNavigation`
- [ ] `NebaFloatingBottomNavigation`
- [ ] `NebaFloatingActionButton`

### Feedback (14)

- [ ] `NebaAlert`
- [ ] `NebaDialog`
- [ ] `NebaConfirm`
- [ ] `NebaPopconfirm`
- [ ] `NebaToast`
- [ ] `NebaTooltip`
- [ ] `NebaOverlay`
- [ ] `NebaProgressLinear`
- [ ] `NebaProgressCircular`
- [ ] `NebaProgressBox`
- [ ] `NebaMeter`
- [ ] `NebaSkeleton`
- [ ] `NebaEmpty`
- [ ] `NebaTour`

### Surfaces (16)

- [x] `NebaBox`
- [ ] `NebaCard`
- [ ] `NebaAccordion`
- [ ] `NebaCollapsible`
- [ ] `NebaTabs`
- [ ] `NebaCarousel`
- [ ] `NebaToolbar`
- [ ] `NebaPill`
- [ ] `NebaSpoiler`
- [ ] `NebaHowToSteps`
- [ ] `NebaChatBubble`
- [ ] `NebaHoverCard`
- [ ] `NebaPopover`
- [ ] `NebaDrawer`
- [ ] `NebaWindowPane`
- [ ] `NebaMockup`

### Charts (10)

- [ ] `NebaStatistic`
- [ ] `NebaSparkline`
- [ ] `NebaLineChart`
- [ ] `NebaAreaChart`
- [ ] `NebaBarChart`
- [ ] `NebaPieChart`
- [ ] `NebaGaugeChart`
- [ ] `NebaScatterChart`
- [ ] `NebaHeatmapChart`
- [ ] `NebaTimelineChart`

### Agent (9)

- [ ] `NebaToolCall`
- [ ] `NebaApproval`
- [ ] `NebaReasoning`
- [ ] `NebaAgentSteps`
- [ ] `NebaContextWindow`
- [ ] `NebaSources`
- [ ] `NebaInlineCitation`
- [ ] `NebaStreamingText`
- [ ] `NebaPromptInput`

### Transitions (17)

- [ ] `NebaAnimateFade`
- [ ] `NebaAnimateGrow`
- [ ] `NebaAnimateZoom`
- [ ] `NebaAnimateSlide`
- [ ] `NebaAnimateRotate`
- [ ] `NebaAnimateBlink`
- [ ] `NebaAnimateReveal`
- [ ] `NebaAnimateFloat`
- [ ] `NebaAnimateShake`
- [ ] `NebaAnimateAppear`
- [ ] `NebaAnimateSplit`
- [ ] `NebaAnimateTyping`
- [ ] `NebaAnimateScramble`
- [ ] `NebaAnimateCounter`
- [ ] `NebaAnimateLighting`
- [ ] `NebaAnimateMarquee`
- [ ] `NebaAnimateHeadline`

## 3. Component tests

Every component arrives with its own widget tests in phase 2. This phase is the suite that holds across all of them, as `plass-ui`'s `test/package/` does:

- [ ] Every surface the pointer can act on lights under it, and nothing else does.
- [ ] Reduced motion (`MediaQuery.disableAnimations`) stops every animation that is not the user's own drag.
- [ ] Every component lays out right to left, and no source file says left or right where it means start or end.
- [ ] Every component fits a 320-pixel-wide screen without an overflow.
- [ ] Muted text and every focus ring keep their contrast against the surfaces they sit on, in both themes.
- [ ] A widget's layers keep their child when its state changes, so a press never rebuilds what is inside it.
- [ ] Focus semantics: every control is reachable by keyboard and announces its role, state and name.
- [ ] Every controller, listener and ticker a widget creates is disposed with it.
- [ ] The suite passes on the Flutter floor `pubspec.yaml` declares, 3.41.0, as well as the latest stable release.

## 4. The sample app's tests

- [ ] The screens of a real app in `examples/flutter`, mirroring the documentation's concept screens: a settings screen, a dashboard and a sign-up flow, each built only out of Neba widgets.
- [ ] A host test that lays out every demo at 360×640, 390×844 and 834×1194 and fails on an overflow, an exception or an asset path that only a website can resolve.
- [ ] Integration flows through those screens, with screenshots saved by the binding, and a script that pulls them off a simulator, an emulator or a device.
- [ ] The flows on an iOS simulator booted with `xcrun simctl boot` (no Simulator window) and on an Android emulator started with `-no-window`, in both themes.

## 5. Real devices

- [ ] An iPhone and an iPad: signing with the maintainer's development team, `flutter test integration_test -d <id>`, and a `--profile` run to see the blur and the animations at full frame rate.
- [ ] An Android phone: USB debugging, the same flows, and a `--profile` run.
- [ ] Record each run here: the device, the OS, the Flutter version, and what failed.

Ask the maintainer for the device connection when this phase starts.

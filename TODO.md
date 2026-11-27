# TODO

The roadmap of the Flutter port, written so that the next session can pick it up without this one's context. The work runs in five phases, in this order: the foundation, the components, the component tests, the sample app's tests, and the tests on real devices. A phase starts once the one before it is done, unless an item says otherwise.

Tick a box in the same commit as the work it records, and add what you find along the way here rather than keeping it in a session. Delete the file once every box is ticked.

The Flutter package's first version is **1.21.0**, the same number as the React package's next release. Both changelogs keep their entries under `## vNext (2026--)` until that release is cut.

## Where the last session stopped

The port lives on the branch **`flutter-port`**, pushed to GitHub and not merged. `main` on GitHub is still at `4f092a45`, from before the port began. Merging into `main` runs `publish-documentation.yml`, which deploys the site with the React/Flutter switch and the Flutter install instructions, so merge when the Flutter package is ready to be public, ideally together with its first pub.dev release.

The boxes below say what is ported; `git log --oneline` on the branch says in which order. A session that ports several components at once runs each port in a worktree of its own and brings the commit over with `git cherry-pick`: `TODO.md`, `CHANGELOG.md` and `packages/flutter/CLAUDE.md` then conflict on neighbouring lines, which is resolved by keeping both, and `lib/neba.dart` and the demo registry are regenerated with `dart run tool/generate.dart` rather than merged. What comes next, in order:

1. The page shell (`NebaPageLayout`, `NebaHeader`, `NebaFooter`, `NebaSidebar`), on the drag scaffold `NebaPanes` brought (`lib/src/internal/drag.dart`).
2. The inputs, in the order of section 2. `NebaToggle` and `NebaToggleGroup` read the same `NebaButtonGroupScope` and lay out on the same `NebaJoinedRun` that `NebaButtonGroup` does.

To set up a machine (Flutter 3.50.1 stable and Node 26 were used; the package floor is Flutter 3.41):

```bash
git fetch origin && git switch flutter-port
cd packages/react && npm install && npx playwright install chromium
cd ../flutter && flutter pub get
cd example && flutter pub get
cd ../../../examples/flutter && flutter pub get
cd ../../docs && npm install && npm run flutter:demos
```

`docs/public/flutter/`, `docs-dist/`, the generated changelog copies and every `build/` folder are git-ignored and rebuilt by those commands; nothing outside the repository is needed.

The six steps of a port are in `packages/flutter/CLAUDE.md`. What the last session learned doing them:

- **A page's Flutter half.** Wrap a React-only paragraph, snippet or list in `::: fw react` and write its Flutter counterpart in `::: fw flutter` after it; a single word or phrase is `<Fw react="…" flutter="…" />`, and a heading may carry one. Leave a blank line before and after every fence, also after a list item: Prettier otherwise joins the fence to the line above. A container around a `<Demo>` that itself holds a fenced block needs four colons. A demo with no Dart twin keeps its React quote only; a demo that makes no sense in Flutter (`button/render`) goes inside `::: fw react` whole.
- **Dart demos** are quoted inside the `<Demo>` slot with `<<< @/../packages/flutter/example/lib/demos/{folder}/{case}.dart`, folder and file with underscores, and the gallery registers them under the React key with hyphens. A button in a demo takes `onPressed: () {}`: with no `onPressed` a Flutter button is disabled. `ConstrainedBox` is not a `const` constructor, so the `const` goes on its child.
- **The props table** is `docs/.vitepress/data/props-flutter/{page}.ts`, rows built with `from()`, `renamed()` and the row helpers in `shared.ts`; `transitionRow()` is the Flutter description of `transition`. Override a description wherever the React one speaks of CSS, an element or an event.
- **Pictures** are copied from `docs/public/samples/` into `packages/flutter/example/assets/samples/` at the same path and loaded as `Image.asset('assets/samples/…')`; `example/test/samples_test.dart` holds the copies to the originals, and the sample app maps those keys to `packages/neba_example/` itself. A row that holds text wraps it in `Flexible`, as a CSS flex item shrinks, or it overflows at a phone's width.
- **Emoji draw nothing in a web preview.** The gallery ships Inter and no emoji font, so a Dart demo uses a character Inter has where the React demo has an emoji; on a device the system font draws one.
- **A hidden browser pane holds the frames back.** With the pane hidden the page runs as a background page and its animation frames are throttled to a handful a second or none, so a picture that fades up looks like it never arrived. Wake the page (any `requestAnimationFrame` from the JavaScript tool will do) before reading a screenshot as a failure.
- **A tile that slides behind the current item** is `NebaTileRun` in `lib/src/internal/tile.dart`, which `NebaSegmentedButton` and `NebaTabs` draw their tile with, in a row, a column, or lines that wrap; `NebaFloatingBottomNavigation` should take the same rather than a second one.
- **A control drawn smaller than a finger** (the React package's `neba-hit`) is a `NebaHitTarget` inside a `NebaHitArea`, from `lib/src/internal/hit.dart`, as `NebaAlert`'s × is. `NebaChip`'s × came first and takes its press over the chip's height instead; moving it over is open.
- **A live region** (`role="alert"`, `role="status"`, `aria-live`) is a `NebaLiveRegion`, from `lib/src/internal/live_region.dart`, which writes the role on the web and a live region on Android and iOS. `NebaSkeleton` came first and still writes `liveRegion: true` itself.
- **A section that folds** is built from `lib/src/internal/disclosure.dart`, as `NebaCollapsible` and `NebaAccordion` are: the panel that opens to its content's height by layout, the header heard as expanded or collapsed, the chevron and the sheet. The agent components that open the same way (`NebaToolCall`, `NebaReasoning`, `NebaSources`) should take the panel rather than a second one.
- **The wheel over a strip** is `nebaStripWheel` in `lib/src/internal/wheel.dart`, and the arrow keys of a set with one focus stop are `nebaRovingTarget` in `lib/src/internal/button_group.dart`; ScrollZone and Tabs share the first, ToggleGroup and Tabs the second.
- **A run laid out by a render object of our own does not report an overflow.** `NebaJoinedRun` and `NebaTileRun` keep their children at their natural widths, as CSS keeps a `shrink-0` row, and paint past a width too narrow for them without the stripes a `Row` draws, so the gallery's phone test cannot catch one. The segmented button's hero, `Plan` and `Period` sets are 4 to 37 pixels wider than the 342 pixels a phone leaves in the test font, and fit with room to spare in Inter.
- **A surface anchored to a trigger** opens through `NebaFloating` in `lib/src/internal/floating.dart`, as `NebaPopover`, `NebaTooltip` and `NebaHoverCard` do: the root overlay, `nebaPlaceFloating` for the side, the align, the flip, the slide and the wedge, the fade in opacity only, Escape and the press outside with a popup opened from inside another counting as inside it, a press on a Neba control through `NebaPressTrigger`, the pointer resting with a delay, keyboard focus, and the focus moved in and given back. `NebaSelect`, `NebaCombobox`, `NebaMenu`, `NebaMenubar`, `NebaNavigationMenu`, the date and time pickers, `NebaColorPicker`, `NebaTreeSelect`, `NebaPopconfirm` and `NebaInlineCitation` should open their popups through it rather than an overlay of their own, and a popup that is the frosted panel draws `NebaFloatingSheet`. `NebaDialog`, `NebaDrawer` and `NebaTour` draw their × with `NebaSheetClose` from `sheet_close.dart`, and take `modal` as `NebaModal`. The gallery and the sample app wrap themselves in `Overlay.wrap`, since a `WidgetsApp` with no routes has no overlay. A Flutter preview draws its popups inside its frame rather than over the page, so a demo that opens one asks for the room with `<Demo minHeight>`, which the frame keeps as a floor.
- **The wedge copies the stylesheet, which draws it inside the sheet.** The React `arrow` sits a pixel outward from the popup's padding box on the facing side, so on a tooltip only a pixel of it shows below or above, on a side edge none of it, and on a bordered sheet its two slanted strokes are drawn just inside the edge. `nebaPlaceFloating` reproduces that geometry rather than guessing what was meant; if the React side moves the wedge out, `box` in that function moves with it.
- **A field-shaped widget** is built from `lib/src/internal/field.dart` and `notch.dart`, as `NebaTextField` is: `NebaFieldColumn` for the label, the description and the error, `NebaFieldShell` for the box with its looks, ring, light and notch, `NebaFieldWidth` for the width and `NebaFieldSemantics` for what a screen reader hears. A label that is a `Text` is drawn a second time by the notch's sizer as a `RichText`, so a test's `find.text` still finds it once. A Fieldset's `disabled` has no counterpart yet: `NebaFieldset` should put a scope above its fields that each field ORs into its own `disabled`, as `internal/fieldset.ts` does.
- **A press target larger than the control** is the React package's `neba-hit`, which grows a tick's, a track's or a ×'s pressable box to 24 pixels past its drawn edge. `NebaCheckbox`, `NebaRadio` and `NebaSwitch` were ported before `lib/src/internal/hit.dart` existed, so they take the press on the label and on the gap beside the control instead (`NebaChoiceField` in `lib/src/internal/choice.dart`), and a checkbox with no label is pressed on its 18 pixels alone. They should move onto `NebaHitArea` and `NebaHitTarget`, as `NebaAlert`'s × did, which takes a press for a target from the box around it without changing the layout. A Fieldset's `disabled` should reach the three the same way it reaches a field.
- **Checking it.** `flutter analyze` and `flutter test` in `packages/flutter`, in `packages/flutter/example` (every demo in both themes and at a phone's width) and in `examples/flutter` (the sample app, which shows every demo too), `npm run typecheck`, `npm run lint`, `npx prettier . --check` and `npm run build` in `docs` (the build runs the container check), and `npm run flutter:demos -- --force` before looking at a preview. With the browser pane hidden, a preview below the first screen never mounts; open the gallery directly at `/flutter/index.html?demo={key}&theme=dark` on the dev server to see one.

Still open from that session:

- [ ] **Selection handles and a copy-and-paste toolbar for the fields.** `NebaTextField` leaves `EditableText.selectionControls` null, because both are drawn by Material or Cupertino, which the package does not import. The pointer and the keyboard select and the keyboard copies and pastes, and on the web the browser's own menu does too, but a touch screen shows no handles and no Cut, Copy, Paste or Select all. It wants `TextSelectionControls` of the package's own, a handle and a toolbar on `NebaSheet`, shared by every field that holds an `EditableText`; the gestures in `neba_text_field.dart` would then stop skipping the toolbar.

- [ ] **Check whether a consumer of `neba/tailwind.css` loses the library's classes.** The docs did: Vite inlined the stylesheet's `@import`, and the `@source '.'` inside it stopped pointing at `src/` (fixed in the docs by naming `packages/react/src`). A consumer who runs Tailwind through `@tailwindcss/postcss` in Vite may meet the same thing; `@tailwindcss/vite` probably does not. Not verified either way.

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

Port in this order, because each group is built out of the ones before it: `NebaBox` first, since nearly every demo puts its content on one, then the layout primitives the demos stand on, then `NebaButton` and the rest of the inputs, the display group, feedback, surfaces, charts, the agent group, and the transitions last. Within a group, take the components another component reuses first: `NebaButton` before `NebaIconButton` and `NebaButtonGroup`, `NebaPopover` before `NebaSelect`. `NebaTypography` went ahead of the rest of the layout group, because the demos of the layout widgets are written in it; `NebaChip`, `NebaAvatar` and `NebaCard` are the ones most of the waiting demos below need next.

Some components have no single Flutter equivalent of what they are on the web, and their form is decided when they are reached, then written on their page: `NebaTextLink` (a callback rather than an `href`, since the package opens nothing itself), `NebaImage` and `NebaGallery` (an `ImageProvider` rather than a URL), `NebaCodeBlock` (no highlight.js; a tokenizer of its own or a caller-supplied one), and the page shell (`NebaPageLayout`, `NebaHeader`, `NebaFooter`, `NebaSidebar`) against a phone's safe areas.

Demos that wait on a component not ported yet, to be added with it: `meter/thresholds` (`NebaSlider`) and `popover/form` (`NebaSelect`). `chip/links` has no Flutter twin: the package opens nothing itself, so a chip has no `href`. The React demos of per-breakpoint maps (`container/responsive`, `grid/responsive`) have no Flutter twin, because the Flutter widgets take no such map. A widget that draws a shape reads the ring of a pile it is in through `NebaRing`, as `NebaBox` does, so that `ring` follows it. `button/render` has no Flutter twin: a Flutter button has no element to swap.

### Layout (15)

- [x] `NebaContainer`
- [x] `NebaGrid`
- [x] `NebaGridContainer`
- [x] `NebaFlex`
- [x] `NebaStack`
- [x] `NebaShow`
- [x] `NebaAspectRatio`
- [x] `NebaScrollArea`
- [x] `NebaScrollZone`
- [x] `NebaPanes`
- [x] `NebaPortal`
- [ ] `NebaPageLayout`
- [ ] `NebaHeader`
- [ ] `NebaFooter`
- [ ] `NebaSidebar`

### Display (23)

- [x] `NebaTypography`
- [x] `NebaTextLink`
- [x] `NebaBlockquote`
- [x] `NebaHighlight`
- [x] `NebaDivider`
- [x] `NebaChip`
- [x] `NebaBadge`
- [x] `NebaAvatar`
- [x] `NebaAppLogo`
- [x] `NebaIcon`
- [ ] `NebaImage`
- [ ] `NebaGallery`
- [x] `NebaShortcut`
- [ ] `NebaList`
- [ ] `NebaDataList`
- [ ] `NebaTable`
- [ ] `NebaDataTable`
- [ ] `NebaCodeBlock`
- [ ] `NebaTimeline`
- [ ] `NebaBreadcrumb`
- [ ] `NebaAnchor`
- [ ] `NebaTreeView`
- [x] `NebaVisuallyHidden`

### Inputs (36)

- [x] `NebaButton`
- [x] `NebaIconButton`
- [x] `NebaButtonGroup`
- [x] `NebaSegmentedButton`
- [x] `NebaToggle`
- [x] `NebaToggleGroup`
- [ ] `NebaForm`
- [ ] `NebaFieldset`
- [x] `NebaTextField`
- [ ] `NebaNumberField`
- [ ] `NebaOtpField`
- [ ] `NebaSelect`
- [ ] `NebaCombobox`
- [x] `NebaCheckbox`
- [x] `NebaCheckboxGroup`
- [x] `NebaRadioGroup`
- [x] `NebaSwitch`
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

- [x] `NebaAlert`
- [ ] `NebaDialog`
- [ ] `NebaConfirm`
- [ ] `NebaPopconfirm`
- [ ] `NebaToast`
- [x] `NebaTooltip`
- [ ] `NebaOverlay`
- [x] `NebaProgressLinear`
- [x] `NebaProgressCircular`
- [x] `NebaProgressBox`
- [x] `NebaMeter`
- [x] `NebaSkeleton`
- [ ] `NebaEmpty`
- [ ] `NebaTour`

### Surfaces (16)

- [x] `NebaBox`
- [x] `NebaCard`
- [x] `NebaAccordion`
- [x] `NebaCollapsible`
- [x] `NebaTabs`
- [ ] `NebaCarousel`
- [ ] `NebaToolbar`
- [ ] `NebaPill`
- [ ] `NebaSpoiler`
- [ ] `NebaHowToSteps`
- [ ] `NebaChatBubble`
- [x] `NebaHoverCard`
- [x] `NebaPopover`
- [ ] `NebaDrawer`
- [ ] `NebaWindowPane`
- [ ] `NebaMockup`

### Charts (10)

- [x] `NebaStatistic`
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

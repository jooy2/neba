# TODO

The roadmap of the Flutter port, written so that the next session can pick it up without this one's context. The work runs in five phases, in this order: the foundation, the components, the component tests, the sample app's tests, and the tests on real devices. A phase starts once the one before it is done, unless an item says otherwise.

Tick a box in the same commit as the work it records, and add what you find along the way here rather than keeping it in a session. Delete the file once every box is ticked.

The Flutter package's first version is **1.21.0**, the same number as the React package's next release. Both changelogs keep their entries under `## vNext (2026--)` until that release is cut.

## Where the last session stopped

The port lives on the branch **`flutter-port`**, pushed to GitHub and not merged. `main` on GitHub is still at `4f092a45`, from before the port began. Merging into `main` runs `publish-documentation.yml`, which deploys the site with the React/Flutter switch and the Flutter install instructions, so merge when the Flutter package is ready to be public, ideally together with its first pub.dev release.

The boxes below say what is ported; `git log --oneline` on the branch says in which order. A session that ports several components at once runs each port in a worktree of its own and brings the commit over with `git cherry-pick`: `TODO.md`, `CHANGELOG.md` and `packages/flutter/CLAUDE.md` then conflict on neighbouring lines, which is resolved by keeping both, and `lib/neba.dart` and the demo registry are regenerated with `dart run tool/generate.dart` rather than merged. What comes next, in order:

1. The inputs, in the order of section 2. `NebaToggle` and `NebaToggleGroup` read the same `NebaButtonGroupScope` and lay out on the same `NebaJoinedRun` that `NebaButtonGroup` does.

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
- **A tile that slides behind the current item** is `NebaTileRun` in `lib/src/internal/tile.dart`, which `NebaSegmentedButton`, `NebaTabs` and `NebaFloatingBottomNavigation` draw their tile with, in a row, a column, or lines that wrap, with `spacing` between the items. A move under way follows its item to where it ends, so an item that grows on the same clock, as a floating bar's destination does while its name arrives, is met where it finishes.
- **A control drawn smaller than a finger** (the React package's `neba-hit`) is a `NebaHitTarget` inside a `NebaHitArea`, from `lib/src/internal/hit.dart`, as `NebaAlert`'s × is. `NebaChip`'s × came first and takes its press over the chip's height instead; moving it over is open.
- **A live region** (`role="alert"`, `role="status"`, `aria-live`) is a `NebaLiveRegion`, from `lib/src/internal/live_region.dart`, which writes the role on the web and a live region on Android and iOS. `NebaSkeleton` came first and still writes `liveRegion: true` itself.
- **A sheet that says what happened** lays its row out with `NebaMessageContent` from `lib/src/internal/message.dart`, as `NebaAlert` and the toasts do: the glyph, the title over the message in a live region, an action and the × each centred on the first line. A toast's stack is drawn through an `OverlayPortal` the provider shows again on every new toast, so it comes over a popup opened before it; `NebaDialog` and `NebaDrawer` should open through the root overlay too, and a toast raised from one is then drawn over it.
- **A section that folds** is built from `lib/src/internal/disclosure.dart`, as `NebaCollapsible` and `NebaAccordion` are: the panel that opens to its content's height by layout, the header heard as expanded or collapsed, the chevron and the sheet. The agent components that open the same way (`NebaToolCall`, `NebaReasoning`, `NebaSources`) take the panel and the sheet, with a header of their own, `NebaFoldTrigger` in `lib/src/internal/agent.dart`, since what each puts on the line is its own and none turns its ink when open.
- **The wheel over a strip** is `nebaStripWheel` in `lib/src/internal/wheel.dart`, and the arrow keys of a set with one focus stop are `nebaRovingTarget` in `lib/src/internal/button_group.dart`; ScrollZone and Tabs share the first, ToggleGroup and Tabs the second.
- **A run laid out by a render object of our own does not report an overflow.** `NebaJoinedRun` and `NebaTileRun` keep their children at their natural widths, as CSS keeps a `shrink-0` row, and paint past a width too narrow for them without the stripes a `Row` draws, so the gallery's phone test cannot catch one. The segmented button's hero, `Plan` and `Period` sets are 4 to 37 pixels wider than the 342 pixels a phone leaves in the test font, and fit with room to spare in Inter.
- **A surface anchored to a trigger** opens through `NebaFloating` in `lib/src/internal/floating.dart`, as `NebaPopover`, `NebaTooltip` and `NebaHoverCard` do: the root overlay, `nebaPlaceFloating` for the side, the align, the flip, the slide and the wedge, the fade in opacity only, Escape and the press outside with a popup opened from inside another counting as inside it, a press on a Neba control through `NebaPressTrigger`, the pointer resting with a delay, keyboard focus, and the focus moved in and given back. `NebaSelect`, `NebaCombobox`, `NebaMenu`, `NebaMenubar`, `NebaNavigationMenu`, the date and time pickers, `NebaColorPicker`, `NebaTreeSelect`, `NebaPopconfirm` and `NebaInlineCitation` should open their popups through it rather than an overlay of their own, and a popup that is the frosted panel draws `NebaFloatingSheet`. `NebaDialog`, `NebaDrawer` and `NebaTour` draw their × with `NebaSheetClose` from `sheet_close.dart`, and take `modal` as `NebaModal`. The gallery and the sample app wrap themselves in `Overlay.wrap`, since a `WidgetsApp` with no routes has no overlay. A Flutter preview draws its popups inside its frame rather than over the page, so a demo that opens one asks for the room with `<Demo minHeight>`, which the frame keeps as a floor.
- **A list of options** opens through `NebaFloating` with `width` and `maxHeight`, which hold it to the trigger's width (`NebaFloatingWidth`) and to the room beside the trigger (`nebaFloatingAvailableHeight`), and is drawn from `lib/src/internal/listbox.dart`, as `NebaSelect`'s and `NebaCombobox`'s are: `NebaListSheet` for the frosted panel that scrolls, `NebaListRow` for an option with its tick, highlight and disabled grey, `NebaListHeading` for a group's heading, and `NebaTypeahead` for the first letters typed to reach one. `NebaMenu`, `NebaTreeSelect` and the pickers' lists should take the same rows. A field that holds an `EditableText` takes its gestures from `NebaFieldGestures` in `field.dart`, as `NebaTextField` and `NebaCombobox` do, and a shell whose end holds buttons of its own, or whose content is a wrapping row of chips, sets its own `padding`. A control that is as wide as the widest thing it could say (React's `WidthSizer`) measures its alternatives with `NebaWidthSizer` from `lib/src/internal/sizer.dart` and hands it to `NebaFieldWidth` as the sizer; the pickers, `NebaDateRangePicker` and `NebaSlider` should do the same. A field shell whose control is a button rather than a caret passes `keyboardRing: true`, so its ring waits for a key. A closing popup is kept out of the Tab order while it fades, and a popup opened from inside another one, a Select's list in a Popover, holds the focus inside the outer one.
- **A menu's rows and popups** are `lib/src/internal/menu.dart`, as `NebaMenu`, `NebaContextMenu` and every submenu draw them: `NebaMenuScope`, the size, colour, density and arrow wrap a whole menu shares, with the `NebaMenuRoot` that closes it; `NebaMenuSheet`, the popup, which owns the focus inside it (where it goes on opening, through a `NebaMenuFocusRequest`, and back to the trigger or the submenu's row on closing), the arrow keys, Home, End, typeahead and Tab, and the submenu a row beside it closes after a rest; and `NebaMenuRow`, one row in every shape, highlighted while it holds the focus, which the pointer gives it by coming onto it. The popups open through `NebaFloating` without its `moveFocus`, since a menu decides itself which row the focus lands on. A modal menu's barrier leaves its trigger pressable through `NebaFloating.barrierCutout`, a key whose widget the barrier lets the pointer through to, which a `NebaMenubar` points at the whole bar so the pointer can cross it; a modal `NebaPopover`'s trigger still sits under its barrier and could take the same. Uncontrolled checkable rows lose their state when the menu closes, as the React package's do without `keepMounted`, which has no Flutter counterpart.
- **A popup hung off one part of its trigger** passes that part's key as `NebaFloating.anchor`, as `NebaNavigationMenu`'s one panel hangs off whichever item is open while the whole row counts as the trigger for a press outside; `padding` is Base UI's `collisionPadding`, and a popup whose focus is moved in and out by hand takes `inTabOrder: false`, so the page's Tab order does not reach it wherever it happens to be drawn.
- **A closing popup is out of the focus order.** `NebaFloating` sets `skipTraversal` on its popup's scope while it fades out, since Tab landing on the scope of a popup on its way out focused whatever in it last had the focus. Moving the focus on from a trigger after closing a popup (`nebaMenuMoveOn`) also applies the focus given back to the trigger first, because traversal starts from the focus its scope holds, not from the node it is asked about.
- **The wedge copies the stylesheet, which draws it inside the sheet.** The React `arrow` sits a pixel outward from the popup's padding box on the facing side, so on a tooltip only a pixel of it shows below or above, on a side edge none of it, and on a bordered sheet its two slanted strokes are drawn just inside the edge. `nebaPlaceFloating` reproduces that geometry rather than guessing what was meant; if the React side moves the wedge out, `box` in that function moves with it.
- **A field-shaped widget** is built from `lib/src/internal/field.dart` and `notch.dart`, as `NebaTextField` is: `NebaFieldColumn` for the label, the description and the error, `NebaFieldShell` for the box with its looks, ring, light and notch, `NebaFieldWidth` for the width and `NebaFieldSemantics` for what a screen reader hears. A field that types takes `NebaFieldEditable` for its `EditableText` and `NebaFieldGestures` for the presses on its shell, as `NebaTextField` and `NebaNumberField` do; a key the field answers itself goes in the editable's `onKeyEvent`, between the editable and the caller's `shortcuts`. A control drawn inside the shell that takes its own press, a stepper, claims it on the press (`NebaDragRegion` with `eager`), or the shell's gestures move the caret under it. A field that draws its own text, as `NebaOtpField`'s cells do, keeps a `NebaFieldEditable` with `drawn: false` behind it for the keyboard, autofill and a screen reader, and reads every edit through an input formatter. A label that is a `Text` is drawn a second time by the notch's sizer as a `RichText`, so a test's `find.text` still finds it once. A Fieldset's `disabled` is `NebaFieldsetScope` in `lib/src/internal/fieldset.dart`, which every field and choice control ORs into its own `disabled` through `nebaFieldsetDisabled`, as `internal/fieldset.ts` does; a control ported from now on that takes `disabled` reads it the same way, and a fieldset test case is added for it.
- **A press target larger than the control** is the React package's `neba-hit`, which grows a tick's, a track's or a ×'s pressable box to 24 pixels past its drawn edge. `NebaCheckbox`, `NebaRadio` and `NebaSwitch` were ported before `lib/src/internal/hit.dart` existed, so they take the press on the label and on the gap beside the control instead (`NebaChoiceField` in `lib/src/internal/choice.dart`), and a checkbox with no label is pressed on its 18 pixels alone. They should move onto `NebaHitArea` and `NebaHitTarget`, as `NebaAlert`'s × did, which takes a press for a target from the box around it without changing the layout. A Fieldset's `disabled` reaches the three as it reaches a field.
- **A surface that opens over the window** (a drawer, and a dialog after it) opens into the app's root `Overlay` through `NebaModalLayer` in `lib/src/internal/modal.dart`. A `WidgetsApp` with no navigator has no overlay, so the gallery and the sample app wrap their home in `Overlay.wrap`, and a widget test pumps into one. A Flutter preview opens it over its own frame only, which is as tall as the demo, so such a `<Demo>` takes `frameMinHeight`.
- **A bar held against an edge** takes `NebaPosition` through `lib/src/internal/pinned.dart`, as `NebaToolbar` and `NebaPill` do: a widget cannot stick inside a scroll view it is in without painting under every sibling after it, so `sticky` draws the bar as it looks pinned and a `PinnedHeaderSliver` holds it, and `fixed` lifts it into the nearest overlay through `NebaPortal`. `NebaHeader` and `NebaFooter` should take the same rather than a second answer.
- **A panel that replays its entrance without being built again** is a `NebaEntrance` with `playsOnBuild: false` and a `trigger` that counts its arrivals, as `NebaHowToSteps` does for each step.
- **A chart** stands on `lib/src/internal/chart.dart`, `chart_frame.dart` and `chart_line.dart`, the React package's three chart files. A cartesian chart is a `NebaCartesianChart<T>` handed a `trace`, which works the marks out once per layout and again only when its `traceKey` changes, and a `painter`, which paints them on every build and repaints on `NebaChartEmphasis` without a rebuild. The axes, the references and the table are the frame's. `horizontal` turns the frame on its side, as `NebaBarChart`'s `orientation` does: `NebaChartLayout`'s `categoryAt`, `valuePx` and `point` answer in the chart's pixels either way, so a chart's marks ask where a value is rather than which way the chart is turned. A chart's marks live in its own file as private classes unless two charts share them, as a line's and an area's do in `chart_line.dart`, and a test reads them through the painter's fields. A chart that is not cartesian, as `NebaPieChart` is, draws on `NebaChartSurface` and takes the rest from the frame without its axes: `NebaChartPlot` for the image, the focus and the pointer, `chartSummary`, `NebaChartVisibility`, `NebaChartPressOutside`, `NebaChartEmphasis`, the legend, the tooltip panel, `NebaChartDataTable`, `NebaChartEmpty` and `NebaChartStatus`; `NebaHeatmapChart`, which React draws on `ChartSurface` rather than `CartesianChart`, does the same, with its scale bar as a legend of its own. `valueCategories` makes the category axis a second value axis, React's `xScale: 'value'`, and `marks` hands the frame a chart's own marks out of its trace for the nearest-mark search, the arrow keys and the tooltip's anchor, with no crosshair, as `NebaScatterChart` does; `table` and `swatch` are a chart's own table and legend swatch; `scale`, `summary` and `markTooltip` are a value axis worked out by the chart, the sentence the plot is described by and a mark's own reading, as `NebaTimelineChart`'s calendar axis and spans need them. What the frame does not have yet is the `brush` and `exportable` of every cartesian chart, which the chart pages say are React only for now. Text on a chart is measured by `chartTextWidth`'s estimate, as React measures it, so the two packages make the same decisions about which labels fit.
- **A slider's thumb at either end hangs half past its strip**, as Base UI centres a thumb on its value, and that half takes no press: a Flutter widget is hit only inside its own box and its parents'. `NebaSlider` places its thumbs and its marks at a share of the strip's length with a render object of its own, `_Along` in `neba_slider.dart`; a chart brush's handles, which place things the same way, should move it into `lib/src/internal/` rather than write a second one. `NebaColorPicker`'s rails did not need it: their thumbs are painted, take no press and are clipped by the well, as the React `overflow: hidden` clips them, so the whole well takes the press.
- **An `Animate*` widget** extends `NebaAnimateBase` from `lib/src/internal/animate.dart`, which holds every setting the React package's `NebaAnimateProps`, `NebaStaggerProps` and `NebaTimelineProps` name, and builds itself with `nebaAnimate(this, effect: NebaEffect(...))`; a keyframe of its own is a `NebaKeyframe` and a case in the frame, never a second clock. A `transition` (`NebaEntrance`) runs on the same `NebaAnimateRun` without watching the screen. The eight that read what their children are (Appear, Split, Typing, Scramble, Counter, Lighting, Marquee, Headline) should take the run's trigger, pause and offscreen handling the same way, extending `NebaAnimateRun` where they need more than one frame per child.
- **A calendar** is `NebaCalendarGrid` in `lib/src/internal/calendar.dart`, as `NebaCalendar` and `NebaDatePicker` draw it: the header with its steppers and the month and year buttons, the three grids on one footprint, the cells with their range band and today's dot, one focus node a position so the stop survives a month change, and the keys. It already takes `onPreviewChange`, `showPreviousButton` and `showNextButton` for `NebaDateRangePicker`'s two panels, and `NebaCalendarSheet` is the popup's sheet. The arithmetic is `NebaDate` in `lib/src/internal/date.dart`, with `nebaWeekStart`, a region and language table taken from CLDR as the ICU in Node 26 holds it. The names are `NebaDateNames`, English built in and any other language registered by the app: the widgets layer has no date names and the package takes no `intl`, so a Flutter picker in Korean says "이전 달" on its steppers and English month names until the app registers Korean ones. Shipping the eighteen languages' names in `package:neba/locales.dart`, generated from CLDR as the messages are from the React tables, is open.
- **A picker** is drawn on `NebaPickerField` in `lib/src/internal/picker.dart`, as `NebaDatePicker` is: the trigger on a field's shell, the × from `lib/src/internal/remove.dart` that a chip draws too, the width of the longest value from `nebaDisplaySamples`, and the popup on `NebaCalendarSheet` through `NebaFloating`, with `NebaPickerFooter` under it. `NebaTimePicker`, `NebaDateTimePicker` and `NebaDateRangePicker` should take the same, and the clock's columns belong beside the calendar in `calendar.dart`, as React's `TimeGrid` sits beside its `Calendar`.
- **A clock** is `NebaTimeGrid` in `lib/src/internal/calendar.dart`, as `NebaTimePicker` draws it: a column a unit, each a scroll view seven cells tall with the calendar's own cell for a row (`_CalendarCell` with `inTable: false`), one tab stop a column in a `WidgetOrderTraversalPolicy` group, so `Tab` takes the columns in order rather than by where each stop happens to be scrolled to, and a live region saying the time. The span a row stands for is `NebaDate.timeUnitSpan`; AM, PM, the 12-hour default and the time patterns are on `NebaDateNames`, so a Flutter clock in Korean says AM and PM until the app registers Korean names with `am`, `pm` and `time`.
- **A trigger that says more than one value**, as `NebaDateRangePicker`'s two ends do, hands `NebaPickerField` a `display` and a `sizer` in place of the `samples`: the display's text and glyphs take the placeholder's muted ink and hide under a resting label as a placeholder does, each end holds its own width with a `NebaFieldWidth` and a `NebaWidthSizer`, and `value` stays the string a screen reader hears. The range picker's panels are `NebaCalendarGrid`s with `onPreviewChange`, and the day under the pointer is held in a widget of the panels' own, so the band moving rebuilds the panels alone; `shouldDisableDate` is wrapped in a cache made on each build of the picker, which is React's `askOnEveryRender` and `useMemo` together. The headers are still built again as the band moves, which the React test counts and the Flutter one does not.
- **A photograph** is a `NebaImage` on an `ImageProvider`, and what it is drawn with is in `lib/src/internal/picture.dart`: the turn and the mirror with a position read on the picture as shown, the seven filters as colour matrices that ease, the watermark and the protection. A widget that shows a picture full size opens it on `NebaViewerSheet` from `lib/src/internal/viewer.dart`, the React Dialog's sheet at `xl` drawn on `NebaModalLayer` out of the same `NebaSheetSections` a `NebaDialog` draws.
- **A table for a lot of rows** is `NebaDataTable`, which draws its own strips rather than a Flutter `Table`: every row is a row tall, so the body is a `SliverFixedExtentList` in a `CustomScrollView` with the header in a `PinnedHeaderSliver`, inside a horizontal `SingleChildScrollView` when the columns are wider than the box, and a pinned column is the same cell placed further along by the horizontal offset. Its arithmetic is `lib/src/internal/data_table.dart` and its CSV `lib/src/internal/csv.dart`, which a chart's `exportable` should take. Three things bit: a gesture recogniser that resolves itself when the pointer comes up wins the press from a tap recogniser inside it, which waits for the arena's sweep, so a row leaves the press to the sweep; a task scheduled at `Priority.idle` never runs while an animation does, and under `FakeAsync` its event-loop timer then spins for ever, so the search folds its rows on a short `Timer` instead; and `scrollCacheExtent` arrived in Flutter 3.43, so `cacheExtent` stays, with its deprecation ignored, while the floor is 3.41.
- **Checking it.** `flutter analyze` and `flutter test` in `packages/flutter`, in `packages/flutter/example` (every demo in both themes and at a phone's width) and in `examples/flutter` (the sample app, which shows every demo too), `npm run typecheck`, `npm run lint`, `npx prettier . --check` and `npm run build` in `docs` (the build runs the container check), and `npm run flutter:demos -- --force` before looking at a preview. A hidden browser pane draws nothing, so look at a Flutter preview in headless Chromium through the React package's Playwright, or open the gallery directly at `/flutter/index.html?demo={key}&theme=dark`; the gallery's base is `/flutter/`, so a static server has to serve `docs/public`, not the gallery's own folder.

Still open from that session:

- [ ] **What the port turned up on the React side.** Each was found by reading the React source or measuring its previews while porting, and the Flutter widget mirrors React until React changes; none is fixed. Decide each in React first, then port the change.
  - `Switch`: the thumb sits off centre when on. `thumbTravelClasses` computes `100% − 2px − (h − 4)` and ignores the 1-pixel border, so at `md` the thumb is 3 pixels from the start edge off and 5 from the end edge on. The Flutter thumb sits 2 pixels inside the hairline at both ends.
  - `RadioGroup`: a disabled, chosen radio's dot takes the page's text colour, because `disabledDotClasses` sets none; Checkbox uses `--neba-disabled-fg` for the same state. `Checkbox`: a mixed box does not deepen under the pointer, as a ticked one does.
  - `Tabs`: with `overflow="wrap"` the indicator is a `rounded-full` box with only a bottom border, so it draws as a curve rather than a line, in `wrappedIndicatorClasses` and in the pre-hydration rule in `styles.css`.
  - `Meter`: its track and indicator lack the `neba-progress-track` and `neba-progress-indicator` hooks the `forced-colors` block reads, and a non-finite value or an empty range writes "0%" while Base UI draws its own width. `progressFraction` returns `NaN` for a `NaN` max. `ProgressBox`'s page says the plates fill "left to right"; they fill from the start edge.
  - `Alert` and `Chip`: the × goes from 0.7 to 1 opacity on hover and focus, against the design language's rule that state is never opacity.
  - `Tooltip`: the default `delay` is 600 ms, against the house rule that a tooltip is instant.
  - `DataList`: each `<dt>` and `<dd>` carries its own top border, so the hairline breaks at the column gap and the two halves sit at different heights; the `<dt>` and a Timeline's meta set no line height. A bare `TimelineItem` draws a connector into nothing.
  - `Header`: `align="start"` with no middle slot packs the actions right after the brand, as the `header/measure` demo shows.
  - `Toast`: `priority` defaults to `low` for every colour, where an Alert takes its role from the colour; and after a dismissing swipe the toast seems to jump back before it fades, since nothing reads `--toast-swipe-movement-*`.
  - `Panes`: the bar has no `pressTransitionClasses`, so a press is not instant on touch. `ScrollZone`'s `label` props row is stale. A solid `SegmentedButton` glows white on the segments that are not chosen.
  - `Slider`: the page says a vertical slider takes the height it is given, but `Slider.tsx` fixes the inner box at `h-40`; the Accessibility section says `showValue` is announced, but Base UI's `SliderValue` writes `aria-live="off"`; `data-[dragging]` is the root's, so every thumb of a range rings while one is dragged; the `hover:` and `data-[dragging]:` shadows replace the whole list and drop the glass plate; a range's "start range" and "end range" are Base UI's English, in no message table; and `largeStep` works through Base UI with no props row.
  - `Popconfirm`: the severity mark's `<svg>` sits in a `shrink-0` span with no size and measures 0×0 in Chrome, so the mark the page calls "not decoration" is not drawn. `ConfirmProvider`'s `defaults` is typed as four fields of `ConfirmOptions` but merges every one, and its own test passes `confirmLabel` through `as never`.
  - `FloatingBottomNavigation` adds `env(safe-area-inset-bottom)` for `absolute` too, where FloatingActionButton keeps it to `fixed` and `sticky`. FloatingActionButton's `onPointerLeave` calls `onOpenChange(false)` on a dial that is already closed.
  - `Menu`: `MenuItem.onClick`'s JSDoc says a row with no `onClick` and no link is a label, but it is a pressable `menuitem` that closes the menu. An uncontrolled `MenuCheckboxItem` or `MenuRadioGroup` starts over on every opening, because the popup unmounts; `menubar/hero`'s Sidebar and Terminal rows show it.
  - `Calendar`: the inline calendar's chosen days have no fill. Its root writes `surfaceSlots`, which has no `--n-fill`, `--n-fill-hover` or `--n-on-solid`, so `bg-(--n-fill)` is transparent and the chosen day is only semibold; the picker's popup writes `popupSlots` and fills it. The Flutter calendar fills it, as the cell's classes ask. And a header wider than the grid, `September 2026` at `md` or any month at `lg`, widens the calendar and leaves the grid at the start under it, which the Flutter calendar mirrors.
  - `DatePicker`: the popup is anchored to Base UI's inner trigger button, so it starts about 17 pixels inside the field's edge at `md` where a Select's list starts at the edge; the Flutter popup aligns with the field. A `clearable` picker grows about 23 pixels when its × appears, because the × sits outside the width sizer; the Flutter picker mirrors it.
  - `Animate*`: the props table gives AnimateShake's `trigger` a default of `'mount'` and AnimateFloat's `alternate` a default of `false`, from the shared rows, where the components default to `'manual'` and `true`. Under reduced motion `.neba-anim[data-state='paused']` takes `animation: none`, so a held effect in `mode="out"` shows content that should be gone. Not verified: `observe.ts` passes `entry.isIntersecting` through, which is true for any intersection, so a `threshold` above 0 may start a `visible` trigger early.
  - Charts: with no slice active, a PieChart's left arrow goes to the second-to-last slice, since `-1 - 1` wraps to `len - 2`. A GaugeChart's `ticks` are 1 pixel of `--neba-chart-grid` at a 4-pixel length and hardly show. Not verified: a horizontal BarChart keeps 12 pixels of headroom above the plot for value labels but none to its right, so a bar at the scale's end writes its label past the plot.
  - `Image`: `mountLine` defaults the border to `var(--neba-line)`, which no stylesheet defines, so the whole `box-shadow` is invalid and `frame: { border: true }` draws no line; the Flutter frame uses the house hairline. A `cut` frame is clipped with `clip-path`, which clips its own elevation shadow, and its line skips the diagonal. `Gallery`: `dim` is a class `filter: brightness()` that the Image's inline `filter` overrides, so a Gallery with a `filter` does not dim; the viewer passes `watermark` and `protect` but not `filter`; and the justified layout's `::after` spacer wraps onto an empty line when the last row is exactly full, adding a row gap at the bottom.
  - `TreeSelect`: its search field takes the CommandPalette's placeholder, "Type a command or search…"; it gives `PickerShell` no `samples`, so the trigger changes width with what it holds; its props table has no rows for `startIcon`, `fullWidth` or `required`; its × goes from 0.7 to 1 opacity; and the TreeView in its popup has no `label`, so a screen reader hears an unnamed tree. `TreeView`: ArrowRight on an open `expandable` branch with no children yet moves to the next sibling rather than into the branch.
  - `Fieldset`: Button, IconButton, Toggle, ToggleGroup, SegmentedButton, Slider and Rating do not read `FieldsetDisabledContext`, so inside a disabled Fieldset the browser stops them but they are drawn as available; the page's list of controls drawn disabled leaves out CheckboxGroup. `FilePicker`: the zone sets no font size, so its glyph is 1.8 times the page's font at every `size`, and keeps its accent when disabled; a row's × goes from 0.7 to 1 opacity; the drag handlers wrap only the button and the hidden input while a comment says the list is part of the drop area. `CommandPalette`: its rows wash with `--n-soft` at `radius[size]` where Select's and Combobox's take `--n-soft-hover` at `xs`.
  - `DataTable`: folding every group of a grouped table leaves no rows, so it draws its empty line and no heading to unfold a group with; the Flutter table keeps the headings. A pinned cell's ground, `--n-panel-press`, is mixed into a transparent `--neba-backing`, so in the dark theme (white at 9%) the cells scrolling under a pinned column show through it, although the comment above `pinnedStyle` calls it opaque. An empty table says the `empty` namespace's "Nothing here", while `table.empty` ("No data") is documented as shared with Table. Its props table has no `elevation` row, which the component takes.
  - `TimePicker`: the trigger's default `Intl` format does not pass `hour12`, so with `hour12={false}` in en-US the columns are 24-hour and the trigger says "9:30 AM", as `time-picker/columns` shows. `DateRangePicker`: the presets column's `max-h-[calc(var(--n-cell,2rem)*8)]` always takes the fallback, since `--n-cell` is set on the Calendar root, so the cap is 256 pixels at every size. `DateTimePicker`: with `minDate` taken as `new Date()`, Now is disabled for the rest of that minute, because its value has its seconds set to 0.
  - `CodeBlock`: `fontFamily`, `fontSize` and `lineHeight` are set inline on the root, but the body's `codeTextClasses[size]` and the `<pre>`'s `font-mono` override them, so probably none reaches the code (read, not checked in a browser). `WindowPane`'s `veil()` and Mockup's bars mix into `transparent` rather than `--neba-backing`, so under reduced transparency the chrome stays see-through. The Mockup page calls the two resolution mockups 300 pixels wide; `mockup/resolution.tsx` draws them at 230.
  - `ToolCall`: the heading over an error is `run.error` rather than `words.error`, so `labels.error` changes the status word read out but not the heading.
  - `NavigationMenu`: `triggerClasses` has `justify-center` and the list stretches its items, so a vertical rail's labels are centred; a `NavigationMenuLink`'s `startIcon` is 1.2em of the inherited body font and does not follow `size`; and the page says the arrow keys move into an open panel, where in Base UI 1.9 the arrow across the row only opens it and Tab enters it. `Tour`: the mask appears at once while the card fades in, and going back to step 0 removes the Previous button that held the focus, so the focus is lost. `ColorPicker`: `readableInk` takes the 0.03928 threshold where `luminance()` takes 0.04045.
  - Charts: the ScatterChart pages say `maxRadius` defaults to a twelfth of the plot's short side, where the code and `props.ts` take a twelfth of the chart's height; `heatmap-chart/labels` passes `format={{ style: 'percent' }}` with values already out of 100, so cells read "10,000%"; a TimelineChart's named value-axis reference goes through `formatValue` in the hidden list, so a deadline reads as compacted epoch milliseconds, and its `tooltip.render` is handed the row name at the span's index, the wrong row; `types.ts` says overlapping timeline spans are drawn over each other, where the chart gives them lanes; and the tooltip panel's value is `shrink-0` under `max-w-56`, so a long one runs past the panel's edge.
  - Demos and pages: `popover/controlled`'s outside button cannot close an open popover with a pointer (the outside press closes it and the toggle reopens it); `tooltip/grouped`'s icon-only buttons have no `aria-label`; the OtpField page says a click lands on the first empty slot, where Base UI keeps the slot clicked while it is within the code; the DataList lede names `<dt>`/`<dd>`, which only the React half has. `drawer/inline` and `menu/context` draw `border-[var(--n-line)]` where `--n-line` is not set, so the border falls back to the text colour; `page-layout/collapse` collapses below `xl`, so at 1280 pixels and wider the preview shows a column rather than the drawer it describes.

- [ ] **A page whose content is a lazily built list.** `NebaPageLayout` lays its `child` out whole inside the scroll view it owns, as a document is laid out, so a page whose content is a list of thousands of rows builds every row at once. It wants a sliver slot beside `child`, laid out in the band that holds the sidebars beside it.

- [ ] **Selection handles and a copy-and-paste toolbar for the fields.** `NebaTextField` leaves `EditableText.selectionControls` null, because both are drawn by Material or Cupertino, which the package does not import. The pointer and the keyboard select and the keyboard copies and pastes, and on the web the browser's own menu does too, but a touch screen shows no handles and no Cut, Copy, Paste or Select all. It wants `TextSelectionControls` of the package's own, a handle and a toolbar on `NebaSheet`, shared by every field that holds an `EditableText`; the gestures in `neba_text_field.dart` would then stop skipping the toolbar.

- [ ] **A Flutter preview that draws Korean, Japanese, Chinese or Arabic fetches its font from Google.** The gallery ships Inter and the engine's Roboto, and for a script those two lack the engine fetches a Noto subset from `fonts.gstatic.com`, which `--no-web-resources-cdn` does not stop: the `avatar` demos' `홍길동` do, and so do the `spoiler/locale` and `empty/locale` demos. The foundation's note that a web build fetches nothing from outside the site holds for Latin text alone. Bundling the subsets the demos need, or pointing the engine's `fontFallbackBaseUrl` at the site, is a decision about what the site serves.

- [ ] **A chart's `brush` and `exportable`.** Neither is in `NebaCartesianChart` yet. The brush is a strip of the whole series under the plot with a window the reader drags, built on `lib/src/internal/drag.dart`; the export has no download to start in Flutter, so its counterpart is probably `onExport` alone, handed the CSV.

- [ ] **A menu's sheet and rows beside a list's.** `NebaMenuSheet` and `NebaMenuRow` in `lib/src/internal/menu.dart` were written alongside `NebaListSheet` and `NebaListRow` in `listbox.dart`, and both draw the same frosted panel at elevation 3 with a wash on the row in hand. The menu's highlight is the focus and the list's is an index the keys move, so the two do not fold into one without choosing one model; the typeahead is already shared. Decide which way a Select's list should go before a picker takes either. `NebaTreeSelect` took neither, as React's takes neither: its popup is the picker shell's sheet (`pickerPopupClasses`, drawn privately in `neba_tree_select.dart` until a second picker needs it in `internal/`) holding a `NebaTreeView`, whose highlight is the focus. `NebaCommandPalette` took the list's rows, with a padding, corners and a wash of its own: its field keeps the focus while the keys move the highlight, which is the list's model and not the menu's.

- [ ] **A picker popup wider than a phone.** At `md` a DateTimePicker's popup and a two-month DateRangePicker's are about 470 to 500 pixels wide, in both packages, wider than a 390-pixel phone; the gallery's phone test lays out only the closed trigger and does not see it. Both want a narrower arrangement below a breakpoint, one month and the clock under the calendar, decided in React first.

- [ ] **A monospaced face in the web previews.** `NebaScale.monoFonts` names faces the gallery does not bundle, so on the documentation site a `NebaCodeBlock`, a `NebaShortcut`, a tool's name and every other run set in the mono stack is drawn in Inter. Bundling one monospaced face with the gallery, as Inter is, would fix every one of them; which face is a decision about what the site serves, beside the CJK fallback above.

- [ ] **The words a range slider's thumbs add to their values.** `NebaSlider.range` reads "20 start range" and "80 end range" in English, as Base UI writes them on the React side, where they are not in `internal/i18n.ts` either. Both packages should read them from a `slider` namespace once the React side has one; until then `thumbSemanticValue` (`getAriaValueText`) is the way to another language.

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

`chip/links` and `pagination/links` have no Flutter twin: the package opens nothing itself, so neither has an `href`. The React demos of per-breakpoint maps (`container/responsive`, `grid/responsive`) have no Flutter twin, because the Flutter widgets take no such map. A widget that draws a shape reads the ring of a pile it is in through `NebaRing`, as `NebaBox` does, so that `ring` follows it. `button/render` has no Flutter twin: a Flutter button has no element to swap.

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
- [x] `NebaPageLayout`
- [x] `NebaHeader`
- [x] `NebaFooter`
- [x] `NebaSidebar`

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
- [x] `NebaImage`
- [x] `NebaGallery`
- [x] `NebaShortcut`
- [x] `NebaList`
- [x] `NebaDataList`
- [x] `NebaTable`
- [x] `NebaDataTable`
- [x] `NebaCodeBlock`
- [x] `NebaTimeline`
- [x] `NebaBreadcrumb`
- [x] `NebaAnchor`
- [x] `NebaTreeView`
- [x] `NebaVisuallyHidden`

### Inputs (36)

- [x] `NebaButton`
- [x] `NebaIconButton`
- [x] `NebaButtonGroup`
- [x] `NebaSegmentedButton`
- [x] `NebaToggle`
- [x] `NebaToggleGroup`
- [x] `NebaForm`
- [x] `NebaFieldset`
- [x] `NebaTextField`
- [x] `NebaNumberField`
- [x] `NebaOtpField`
- [x] `NebaSelect`
- [x] `NebaCombobox`
- [x] `NebaCheckbox`
- [x] `NebaCheckboxGroup`
- [x] `NebaRadioGroup`
- [x] `NebaSwitch`
- [x] `NebaSlider`
- [x] `NebaMenu`
- [x] `NebaMenubar`
- [x] `NebaNavigationMenu`
- [x] `NebaCommandPalette`
- [x] `NebaFilePicker`
- [x] `NebaTransfer`
- [x] `NebaTreeSelect`
- [x] `NebaPagination`
- [x] `NebaRating`
- [x] `NebaColorPicker`
- [x] `NebaCalendar`
- [x] `NebaDatePicker`
- [x] `NebaTimePicker`
- [x] `NebaDateTimePicker`
- [x] `NebaDateRangePicker`
- [x] `NebaBottomNavigation`
- [x] `NebaFloatingBottomNavigation`
- [x] `NebaFloatingActionButton`

### Feedback (14)

- [x] `NebaAlert`
- [x] `NebaDialog`
- [x] `NebaConfirm`
- [x] `NebaPopconfirm`
- [x] `NebaToast`
- [x] `NebaTooltip`
- [x] `NebaOverlay`
- [x] `NebaProgressLinear`
- [x] `NebaProgressCircular`
- [x] `NebaProgressBox`
- [x] `NebaMeter`
- [x] `NebaSkeleton`
- [x] `NebaEmpty`
- [x] `NebaTour`

### Surfaces (16)

- [x] `NebaBox`
- [x] `NebaCard`
- [x] `NebaAccordion`
- [x] `NebaCollapsible`
- [x] `NebaTabs`
- [x] `NebaCarousel`
- [x] `NebaToolbar`
- [x] `NebaPill`
- [x] `NebaSpoiler`
- [x] `NebaHowToSteps`
- [x] `NebaChatBubble`
- [x] `NebaHoverCard`
- [x] `NebaPopover`
- [x] `NebaDrawer`
- [x] `NebaWindowPane`
- [x] `NebaMockup`

### Charts (10)

- [x] `NebaStatistic`
- [x] `NebaSparkline`
- [x] `NebaLineChart`
- [x] `NebaAreaChart`
- [x] `NebaBarChart`
- [x] `NebaPieChart`
- [x] `NebaGaugeChart`
- [x] `NebaScatterChart`
- [x] `NebaHeatmapChart`
- [x] `NebaTimelineChart`

### Agent (9)

- [x] `NebaToolCall`
- [x] `NebaApproval`
- [x] `NebaReasoning`
- [x] `NebaAgentSteps`
- [x] `NebaContextWindow`
- [x] `NebaSources`
- [x] `NebaInlineCitation`
- [x] `NebaStreamingText`
- [x] `NebaPromptInput`

### Transitions (17)

- [x] `NebaAnimateFade`
- [x] `NebaAnimateGrow`
- [x] `NebaAnimateZoom`
- [x] `NebaAnimateSlide`
- [x] `NebaAnimateRotate`
- [x] `NebaAnimateBlink`
- [x] `NebaAnimateReveal`
- [x] `NebaAnimateFloat`
- [x] `NebaAnimateShake`
- [x] `NebaAnimateAppear`
- [x] `NebaAnimateSplit`
- [x] `NebaAnimateTyping`
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
- [x] Every component fits a 320-pixel-wide screen without an overflow. `packages/flutter/example/test/gallery_test.dart` lays every demo out at 320×568 in Inter, the face the gallery bundles, since the test font's squares are nearly twice as wide as real letters; the sample app's `demos_test.dart` adds 360, 390 and 834. Its first run found a PromptInput's start group sharing its room with a spacer. Two demos are wider than 320 by what they show and are left out of that one test: a calendar at `lg`, seven 44-pixel cells as in the React package, and `Mod+Alt+Shift+Delete` written out in words in the monospaced face the gallery does not bundle.
- [x] Muted text and every focus ring keep their contrast against the surfaces they sit on, in both themes. `packages/flutter/test/theme/contrast_test.dart` checks the tokens rather than the widgets, since every widget draws from them: the ink on each family's solid fill at rest, under the pointer and pressed at 4.5:1, each family's ring at 3:1 against the page, and muted text at 4.5:1 on the page, a panel and a pressed panel, in both themes and under reduced transparency.
- [ ] A widget's layers keep their child when its state changes, so a press never rebuilds what is inside it.
- [ ] Focus semantics: every control is reachable by keyboard and announces its role, state and name.
- [x] Every controller, listener and ticker a widget creates is disposed with it. Checked by a run of the whole suite with `LeakTesting.enable()` from `leak_tracker_flutter_testing` in `test/flutter_test_config.dart`, left out of the commit because the package would have to depend on it. The one leak in the library was the text painters a bar, line, area, pie and gauge chart lay their labels out in, which `test/internal/chart_labels_test.dart` now counts through `FlutterMemoryAllocations`; what the run still reports is made by the tests themselves (an `OverlayEntry` a test inserts, a test image, the elements of a build that throws on purpose) and the grain tile `surface.dart` keeps for the whole app.
- [ ] The suite passes on the Flutter floor `pubspec.yaml` declares, 3.41.0, as well as the latest stable release.

## 4. The sample app's tests

- [x] The screens of a real app in `examples/flutter`, mirroring the documentation's concept screens: a landing page, a dashboard and a sign-up flow, each built only out of Neba widgets. They are the gallery's `concepts/landing`, `concepts/dashboard` and `concepts/signup`, which the sample app lists with every other demo and the Examples pages preview, drawing their glyphs from one file beside them, `concepts/data/glyph.dart`.
- [x] A host test that lays out every demo at 360×640, 390×844 and 834×1194 and fails on an overflow, an exception or an asset path that only a website can resolve: `examples/flutter/test/demos_test.dart`, which shows one demo at a time through the app's own frame. Its first run moved five demos to give way at 320 pixels and taught `NebaButton` to end a label it has no room for in an ellipsis.
- [ ] Integration flows through those screens, with screenshots saved by the binding, and a script that pulls them off a simulator, an emulator or a device.
- [ ] The flows on an iOS simulator booted with `xcrun simctl boot` (no Simulator window) and on an Android emulator started with `-no-window`, in both themes.

## 5. Real devices

- [ ] An iPhone and an iPad: signing with the maintainer's development team, `flutter test integration_test -d <id>`, and a `--profile` run to see the blur and the animations at full frame rate.
- [ ] An Android phone: USB debugging, the same flows, and a `--profile` run.
- [ ] Record each run here: the device, the OS, the Flutter version, and what failed.

Ask the maintainer for the device connection when this phase starts.

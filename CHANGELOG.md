# Changelog

## vNext

### Where the bytes went

| What you import               | 1.12.0   | vNext    |
| ----------------------------- | -------- | -------- |
| `Button`                      | 5.1 kB   | 5.1 kB   |
| `Chip`                        | 3.3 kB   | 3.4 kB   |
| `LineChart`                   | 11.6 kB  | 11.7 kB  |
| `CodeBlock`                   | 5.0 kB   | 5.1 kB   |
| `Image`                       | 6.5 kB   | 7.1 kB   |
| `Gallery`                     | 10.2 kB  | 10.3 kB  |
| a whole page shell            | 29.0 kB  | 29.2 kB  |
| 12 components — a typical app | 70.5 kB  | 70.4 kB  |
| 12 components, with Korean    | 72.9 kB  | 73.2 kB  |
| 25 components — a large one   | 115.7 kB | 115.7 kB |
| all exports                   | 263.9 kB | 264.7 kB |

`Image` is the row that moved, and 0.5 kB of it is what translating one string costs on the smallest component that needed it. A picture that failed with an empty `alt` printed a hardcoded English sentence, so `Image` now reaches `internal/i18n.ts` and `internal/defaults.ts` — resolution machinery every other translated component was already carrying. Which is why the twelve-component row went _down_: on any page that already draws one of them the marginal cost is nothing, and the shared helpers that shrank are what is left. The last 0.1 kB is `width` and `height`, and `Gallery` carries it because it draws an `Image`.

The 0.1 kB on `Chip`, `CodeBlock`, `LineChart` and the page shell is the same machinery gaining an `Object.hasOwn` on each of its two lookups, and a shared bound under the memos in `internal/`.

The Korean row is the other one worth a sentence. Registering a language ships that language's whole module, so the twenty picker strings and the two a Carousel's stop button needs land in it whether or not the page draws either — 2.8 kB now against 2.4 kB before. It is the price of the thing being fixed: those twenty were hardcoded English, and a Korean product had no way to reach them but to write all twenty out.

### Added

- **A `BottomNavigationItem` declares the `target` and `rel` its link already rendered.** The props were typed against a `<button>` and cast to an `<a>`, so a destination that opened in a new tab could only be written by handing the component something TypeScript said was impossible.

- **A `Carousel` with `autoPlay` draws the button that stops it.** It paused on hover, on focus and in a background tab, and it never started for a reader who had asked for less motion — but a reader holding a phone hovers nothing, and one running a magnifier may never put a pointer over the strip at all. WCAG 2.2.2 asks for a mechanism, and those were not one. The control sits in the row under the frame, beside the dots and never over a slide; `pauseLabel` and `playLabel` name it, and it is translated in all nineteen languages. There is no prop to take it away — a caller who wants a control of their own can drive `value` and leave `autoPlay` off.

- **The four date and time pickers say their twenty non-date strings in the reader's language.** "Previous month", "Choose a year", "Today", "Now", "Hour", "AM/PM" and fourteen more were hardcoded English, over dates `Intl` had already translated — so a Korean product's only way out was to write out all twenty through `labels`. There is a `picker` message namespace now, in all nineteen languages. `labels` still wins where it is given, which is what it is for: `locale` answers the language and `labels` answers the wording.

- **An `Image` takes `width` and `height`, and reserves the box they describe.** They were omitted from the props, so the one component in the library whose reason to exist is holding a picture's space could only be told what that space was as a `ratio` worked out by hand — and a default `Image` reserved nothing at all, which is the largest source of layout shift on most sites. They reach the `<img>` as the attributes they are, and giving both turns an `'auto'` ratio into their proportion. An explicit `ratio` still outranks them: that one is the layout's shape and these two are the picture's.

### Changed

- **An `Anchor` finds its headings once instead of on every frame of a scroll.** It ran a `document.getElementById` for each row of the trail on every scroll frame, for an answer that changes only when the document does. The elements are kept and checked against `isConnected`, so a heading that arrives after the trail is still found.

- **An `AnimateMarquee` measures itself when its size changes, not on every render above it.** The measurement listed `children` as a dependency, so every render of whatever held the strip tore both resize observers down, put them back, and ran a `getComputedStyle` and an `offsetWidth` — a forced layout — for a strip that had not moved. The track is observed, so a change in what is on it is already reported.

- **The last two `Intl` objects a render was rebuilding are memoised.** `localeWeekStart` built an `Intl.DateTimeFormat` and an `Intl.Locale` on every render of a `Calendar`, a `DatePicker`, a `DateRangePicker` and a `DateTimePicker` — every keystroke and every hover anywhere inside one — and `graphemesOf` / `wordsOf` built an `Intl.Segmenter` on every call, for three text effects that ask on every frame they animate. Both go through a cache now, as the number and date formatters already did.

- **A `Transfer` and a `TreeSelect` fold their labels once instead of once per keystroke.** Both folded every row inside the filter, which put a `String.prototype.normalize` on every item for every character typed — a `Transfer` did it on every render, search or no search. The haystacks are built once per `items` now, which is the arrangement a `DataTable` and a `CommandPalette` already used. Nothing about what matches has changed.

- **A chart's data table is memoised, and reads the chart's own formatter.** The visually hidden table is built in the same render the crosshair's state lives in, so every cell of it was reconciled again for each pixel the pointer travelled across the picture — a row per point on a `ScatterChart`. It is `React.memo` now, and the frame's `format` is keyed on what the options say rather than on the identity of the object they arrived in, so a `format` written inline in the JSX no longer defeats it.

  One number moves with it: a `ScatterChart` with no `format` writes its table values the way its axis and its tooltip already write them, so `24000` reads as `24K` rather than `24,000`. It was the only chart whose table disagreed with its own picture.

### Fixed

- **Dragging a run of rows in a `DataTable` no longer selects the text it crosses.** It was the last drag in the library written by hand, and it had the hole the column resize used to have: no text-selection suppression, over every cell the pointer passed rather than the two beside a boundary. It goes through `beginPointerDrag` now — captured to the table rather than to the row that was pressed, since a virtual body unmounts a row the moment it scrolls away. The auto-scroll at the edge stays where it is.

- **A `TreeSelect`'s clear button says "Clear" in every language no longer.** It was named out of the pickers' English defaults — a set it has nothing else to do with — rather than out of the same `action` messages the identical × on a `Combobox` reads. It takes a `clearLabel` like `Combobox` does, too.

- **A pointer drag starts even when the pointer cannot be captured.** `setPointerCapture` throws for a pointer that is no longer active — one lifted between the `pointerdown` and the handler — and the exception escaped into React's event handler, which takes the page down. Capture is an optimisation and the three listeners work without it, so it is taken where it can be and skipped where it cannot.

- **An `AnimateScramble` redraws on its own tick and not on every render above it.** The noise glyphs were picked with `Math.random()` during the render, so any re-render from anywhere in the tree reshuffled every unsettled letter at whatever moment it happened to land — an effect meant to be a clock, answering to the whole page. They are picked from the tick counter and the position now, which also settles the hydration mismatch the random source caused on a server-rendered page.

- **A `CodeBlock`'s copy button keeps the focus when the clipboard falls back.** On a page without a secure context the copy goes through `execCommand` against an off-screen textarea, and selecting that textarea took the focus — so a reader who pressed the button with a keyboard was left on `<body>`, having lost their place in the page as the reward for copying.

- **An `Anchor`, an `Image` and a `Panes` write their refs in an effect rather than during a render.** A ref written while rendering is a ref that lies when React throws that render away, which is a live hazard under concurrent rendering and is the rule `useShortcut` had already written down. None of the three reads the value during a render, so nothing about their behaviour changes.

- **An `Image` says its own absence in the reader's language.** A picture that failed with an empty `alt` printed a hardcoded `Image unavailable`, which was the one string the library invented and could not translate. There is an `image` message namespace now, in all eighteen languages, and `Image` takes a `locale` and an `unavailableLabel` like every other component that has to invent a word.

- **A message lookup reads a table's own keys and not its prototype's.** A `locale` a caller took from a URL, or a `{placeholder}` a translation happened to name after a member of `Object`, resolved up the prototype chain — so `locale="constructor"` was spread over English as though it were a table of messages, and `{constructor}` in a translation wrote `function Object() { [native code] }` into the middle of a sentence.

- **An `AppLogo` and a `BottomNavigationItem` merge `noopener noreferrer` into a link that leaves this tab.** `safeRel` reached four of the six components that let a `target` through to an `<a>`; these two handed the page they opened a `window.opener` pointing back at the one that opened it, and a `Referer` header naming it. A `rel` written by hand — `nofollow`, `sponsored` — is merged rather than replaced, as everywhere else.

- **`colorSchemeScript` escapes `<` in the values it writes.** The string is inlined inside a `<script>` element, and a browser stops parsing that element at the first `</script` in it however the JavaScript around it is quoted — so a `storageKey` holding one would have ended the tag and handed the rest to the HTML parser as markup. `Breadcrumb` already wrote its structured data out this way.

- **The five memos in `internal/` cannot grow without bound.** The `Intl` formatters and segmenters, the `MediaQueryList`s, the week-start table and the resolved message tables are keyed on a `locale`, on the options behind a `format` prop, or on a query string handed to the public `useMediaQuery` — a caller's to choose in every case, and two of them carried a comment claiming otherwise. They share one ceiling now, well above anything the library itself reaches; a page that never approaches it is unchanged, and one that passes it rebuilds what it would have built anyway.

- **A shared `IntersectionObserver` is let go once nothing is watching through it.** One is kept per `threshold`, and `threshold` is a public prop on all seventeen `Animate*` components — so a caller computing one left a live observer behind for every value it had ever held, each of them a registration the browser still walks on every scroll. A group now lives exactly as long as its last watcher.

- **An `AnimateMarquee` stops for the focus as well as for the pointer.** `pauseOnHover` was `:hover` alone, so a link on a moving strip could be aimed at with a mouse and not reached with a keyboard — tabbing to it left it travelling off the screen while it was being read.

## 1.12.0 (2026-09-05)

The release about the things that were already there and were not quite saying it.

Most of it came out of asking one question of every component in turn: when a state turns over, does anything _happen_, or is the second state simply drawn? Twenty-odd answers were "simply drawn" — a toggle whose on and off were the same colour, a checkbox whose tick was there on one frame and gone on the next, a gauge that jumped to each new reading, a spoiler that moved the page when it opened. Three were fades that had been written down and never ran.

Four components are new. `Stack` is a pile of things laid over each other and replaces `AvatarGroup`; `Gallery` is a set of pictures in one of four arrangements; `Show` and `Flex` are the two answers a breakpoint gives directly. There are seventeen `Animate*` where there were eleven, and a `stagger` that turns any of the nine keyframe effects into a set of them.

The last group is the same complaint one level up. The library had a breakpoint system — five widths, a per-breakpoint map, a cascade that resolves it without React hearing about it — and it reached exactly two props on two components. There was no way to draw something at one width and not another, no way to say "a row here, a column there", no way to move the widths, and no page that wrote any of it down.

### Where the bytes went

| What you import               | 1.11.0   | vNext    |
| ----------------------------- | -------- | -------- |
| `Button`                      | 5.1 kB   | 5.1 kB   |
| `Chip`                        | 3.2 kB   | 3.3 kB   |
| `LineChart`                   | 11.4 kB  | 11.6 kB  |
| `CodeBlock`                   | 5.0 kB   | 5.0 kB   |
| `Image`                       | 23.4 kB  | 6.5 kB   |
| `Gallery`                     | —        | 10.2 kB  |
| a whole page shell            | 28.5 kB  | 29.0 kB  |
| 12 components — a typical app | 68.2 kB  | 70.5 kB  |
| 12 components, with Korean    | 70.7 kB  | 72.9 kB  |
| 25 components — a large one   | 112.6 kB | 115.7 kB |
| all exports                   | 248.1 kB | 263.9 kB |

`Image` is the row that moved on purpose, and it is a new row because nothing had ever measured it: a `Dialog` nobody had opened was 20 kB of it. `Chip` is the one worth explaining, because it is the only one that moved for a reason other than "there is more library now" — `transition` gained a seventh effect, and the entrance vocabulary is two `Record`s that an object literal cannot tree-shake per key, so every component offering a `transition` pays 0.1 kB for the row whether or not it names it. `AnimateFloat` and `AnimateShake` bring their own keyframe class instead of a row in that table, which is why it is only 0.1 kB.

`all exports` went up rather than down because `npm run size` learned to count honestly while this was being measured. It called every chunk but the entry deferred, which stopped being true the moment a module was imported both statically and dynamically. It walks the static import graph now, so a number in the table is what a page needs before it draws.

The rest of the movement is one dependency. `@base-ui/react` is on 1.8.0, and pinning it back to 1.7.0 returns every row to the figure this table carried before it — so the 1.4 kB on a twelve-component app and the 2.5 kB on `all exports` are its rather than ours. Nothing that draws a single component moved by more than 0.1 kB.

### Breaking changes

- **`AvatarGroup` is removed.** `Stack` does everything it did and is not about avatars. What is lost is its context — `size`, `shape`, `variant`, `color` and `elevation` set once for the group. Set them on the avatars, or on a `NebaProvider` for the two it covers.

### Added

- **`Stack`** — a pile of things laid over each other. `direction` runs it along the inline axis, down the page, or diagonally as a fanned deck; `overlap` and `drop` say how far each item sits under the last; `max`, `total` and `overflow` turn the ones that did not fit into one more item at the back; `scaleStep` and `opacityStep` make the pile recede; `ring` draws the hairline that stops two overlapping shapes of similar tone reading as one smeared one.

  The overlap is a **margin** rather than a `translate`, so the box is exactly as big as what is in it and the content after a Stack is laid out against the right width. Each item is drawn into a wrapper of its own rather than cloned onto, because a Tooltip around an avatar is under no obligation to accept a `className`.

  ```tsx
  <Stack ring max={3} total={12} overflow={(hidden) => <Avatar initials={`+${hidden}`} />}>
    {team.map((name) => (
      <Avatar key={name} name={name} />
    ))}
  </Stack>
  ```

- **`Gallery`** — a set of pictures, and the arrangement is a prop rather than four components. `grid` is a contact sheet; `masonry` keeps each picture's own proportion and stacks the columns; `justified` keeps the proportions **and** fills every row to the edge, which is the only arrangement where nothing is cropped and nothing is left over; `quilted` is a grid whose tiles may take more than one cell.

  **None of them measures anything.** A tile's shape is the item's own `ratio`, so the wall is right in the first frame the browser paints and does not move again as the files land, and `justified` is a wrapping flex row the browser does the arithmetic for. `masonry` is the one layout that needs a number in JavaScript, and it deals each item into the _shortest_ column rather than filling the first one top to bottom.

  `columns` takes a breakpoint map and `gap` a step, a number or a length. `caption` puts an item's title and description below the picture, across the foot of it, or under the pointer; `hover` answers with depth, colour or the one scale the design language allows; `preview` opens the picture full size with the rest of the set on the arrow keys, in a chunk that is not fetched at all unless the prop is on. `filter`, `frame`, `watermark` and `protect` pass straight through to every tile's `Image`, and the last two follow the picture into the viewer. The `gallery` message namespace is new, in all eighteen languages.

- **`Show`** — its children at some widths and not at others. `above` is an inclusive floor and `below` an exclusive ceiling, so the same breakpoint in both covers every width exactly once, and the two together bound a range.

  ```tsx
  <Show above="md">
    <Sidebar />
  </Show>
  <Show below="md">
    <SidebarTrigger />
  </Show>
  ```

  The children are **always rendered** and what changes is `display`, which is what makes the answer right in the first frame, the same on a server, and free on a resize. What it deliberately cannot do is stop something running; `useBreakpoint` already could. The wrapper is `display: contents`, so a `Show` between a `GridContainer` and a `Grid` leaves the cell a cell.

- **`Flex`** — a row that becomes a column. "Side by side on a desktop, stacked on a phone" is half of what a responsive layout is, and the only way to say it was a `GridContainer` with a `Grid` around each child. `direction` takes `horizontal`/`vertical` rather than CSS's four values, so a Flex and a Stack say the same thing the same way, and it takes a breakpoint map — `direction={{ xs: 'vertical', md: 'horizontal' }}`. `spacing`, `rowSpacing` and `columnSpacing` are a `GridContainer`'s props on its scale, so a gutter is one number across the two. It draws nothing at all, and `wrap` is **off** by default.

- **Six more `Animate*`** — `AnimateReveal`, an edge travelling across content that is already in place, as a `clip-path`, so nothing reflows and it is also a `transition` value; `AnimateFloat`, a slow drift with nowhere to get to; `AnimateShake`, the one effect that says _no_, which defaults to `trigger="manual"` and is the single documented exception to the rule that a control is never transformed; `AnimateSplit`, a line arriving a word or a letter at a time; `AnimateCounter`, a number counted up to its value and formatted with `Intl.NumberFormat` options on every frame; `AnimateScramble`, text resolving out of noise in a box that is the finished length from the first frame.

  The three that animate text put the whole string in the document once for a screen reader and hide the performance from it, which is `AnimateTyping`'s arrangement, and all four now take their grapheme boundaries from `internal/text.ts`.

- **`stagger`, `durationStep` and `reverse`** on the nine `Animate*` whose motion is one `@keyframes` on the element itself. At `0` — the default — the box animates and the children are left alone, which is what they always did. Above it the effect moves onto each child in turn and nothing is written on the box, because a box fading in over eight children fading in is the same content faded twice. `AnimateAppear` runs on the same helper now, which is what stops the library having two staggers.

- **`timeline="view"`** — any of the nine keyframe effects driven by how far the element has travelled through the viewport instead of by the clock. It is two declarations behind an `@supports`. It costs `duration`, `delay`, `repeat` and every `trigger`, and falls back to running once on mount where the browser has no `animation-timeline`.

- **`useBreakpointValue` and `useCurrentBreakpoint`** — a breakpoint map read in JavaScript exactly as the cascade reads it, for a caller working out a number for themselves. `undefined` is a real answer: a map that has said nothing yet at this width is an opinion declined, which is what the CSS fallback says there too.

- **Four things an `Image` could not do**, none of which costs anything until it is asked for. `filter` colours the picture — `grayscale`, `sepia`, `invert`, `saturate`, `mute`, `contrast`, or a CSS chain of your own — and rides the same transition as the picture's own fade. `frame` is how the picture is mounted, a silhouette on its own or the whole arrangement of `corner`, `border`, `mat`, `background`, `elevation` and `feather`; the line is an inset shadow on a layer over the picture rather than a `border`, which is what lets it follow a chamfered corner and keeps it out of the layout. `watermark` draws a mark in a corner or tiled across the whole picture, as one SVG background rather than a wall of elements. `protect` turns off the right-click menu, the drag, the iOS long press and the selection — a deterrent and not a lock, and the docs say so where the prop is described.

- **`overflow` and `lines` on `Tabs`** — `overflow="wrap"` is for a bar whose tabs all have to be visible at once, and the rule under the chosen tab moves onto the line that tab is on rather than staying at the bottom of the list. `lines` caps a wrapping bar at that many tab-rows.

- **`maxWidth` takes a length and a breakpoint map** on `Container`, `Header` and `Footer`, which had a copy each of the measure ladder and could only ever be one of its five values at one width. Anything that is not a step of the ladder goes straight to `max-width`, so `'60ch'` and `'min(90vw, 72rem)'` need no escape hatch and a number is pixels. The ladder is named `NebaMeasure` rather than left as `NebaSize`, because it shares five names with `NebaBreakpoint` and only four of its five values.

- **`Statistic`'s `value` takes a node**, which is where an `AnimateCounter` belongs.

### Changed

- **The library's media queries are `theme(--breakpoint-*)`**, so a Tailwind project moves Neba's widths by moving its own. `@media` cannot read a custom property, so a breakpoint stays a build-time decision and no provider prop could ever move one — but it can be a decision you take part in.

  ```css
  @import 'tailwindcss';
  @import 'neba/tailwind.css';

  @theme {
    --breakpoint-md: 50rem;
  }
  ```

  That moves the library's own rules, the `md:` variants its components spell out, and its JavaScript, which reads the resolved widths back off the document rather than holding a second copy. Before this, redeclaring `--breakpoint-md` moved your utilities and left Neba at 48rem in both places. A project on `neba/styles.css` gets the widths baked in, since that sheet is compiled here.

- **A `Toggle` that is on now looks like it.** Off was `accent 8%` and on was `accent 10%` — two names for one colour, with the ink carrying the whole state. Off leaves the colour family entirely now for the neutral `--neba-panel` ladder, and on takes the dyed `--n-panel-press` that draws a `SegmentedButton`'s chosen segment. A control with two states cannot spend the family on the one that is false.

- **`Home`, `End`, `PageUp` and `PageDown` scroll a `DataTable` and nothing else.** They used to move the selection with them, so ticking a row and then looking at the bottom of a thousand threw the tick away on the journey. The arrows still move and choose. A table with no `height` or `maxHeight` leaves all four to the browser rather than taking them and turning them into nothing.

- **A `Spoiler` is the same height covered and uncovered.** `reversible` grew the box by a whole button row at the moment of the press, and the cover — an `absolute inset-0` layer contributing no height — lost its own reveal button off the bottom edge whenever it was taller than what it covered. The row is drawn from the start and kept out of sight, and the cover is a grid item spanning every row that keeps its row on the press, giving up only the paint and the tab stop. `maxHeight` stays the deliberate exception, since releasing the clamp is the whole point of it.

- **A tab bar says when it has more bar.** It already scrolled; the scrollbar is an overlay on macOS and furniture on Windows, so it is hidden on both and the ends fade instead, through the same two masks `ScrollArea` already uses.

- **A drawer comes in from its edge.** It faded, which moves nothing and throws away the only thing that distinguishes it from a `Dialog` — and a `Sidebar` below its breakpoint _is_ a drawer, so the same thing happened to every collapsed page shell. The panel travels on `translate` now and the scrim behind it still fades. It runs on `--neba-duration` rather than the window ladder's 240ms, because `--neba-duration-window` is not zeroed under `prefers-reduced-motion` and a drawer sliding across the screen is exactly what that setting is asking not to see.

- **A `GaugeChart` sweeps to its reading.** It drew the reading as a wedge, and a wedge is a closed shape, so moving the value rewrote its `d` — not a property CSS can travel along. It is a stroke along the middle of the groove now, whose drawn length is `stroke-dashoffset` with `pathLength="1"`. The shape on screen is identical; only `fill` moved to `stroke`.

- **An `Image` weighs 6.5 kB instead of 23.4.** A `Dialog` was most of what it cost, and `preview`, the only thing that opens one, is off by default. It is fetched on demand now, the way `CodeBlock` fetches a grammar.

- **`npm test` runs the suite in sessions of at most fifty files**, each its own browser, through `scripts/run-tests.mjs` — `ceil(files / 50)`, so adding tests does not need the number touched. Nothing is skipped and nothing is retried: a failing test still fails its shard and still fails the run.

- **`npm run build` empties `dist/` first.** It never did, and `tsc` only ever writes, so a component deleted from `src/` stayed in `dist/` and shipped. Removing `AvatarGroup` is what surfaced it.

- **`ScrollZone`'s `buttons="auto"` disables an inline button that has nowhere to go** rather than hiding it. The lane is held open either way, so an emptied one was not a lighter row — it was the same row reading as stray padding at the leading edge, which is the state every reader meets first.

- **`@base-ui/react` is on 1.8.0**, which is the floor `dependencies` declares. It is the only runtime dependency that moved, and the multi-component rows of the table above are where it shows.

### Fixed

- **A `Select`'s and a `Combobox`'s popup arrived in one frame** while the calendar hanging off the `DatePicker` beside them took 160ms. The fade was fourteen identical copies of one declaration; it is `popupFadeClasses` in `internal/styles.ts` now, read by sixteen surfaces, and the two that were missing it got it by being written the same way as the rest. `NavigationMenu` keeps its own `transition`, because its panel also changes size and a second shorthand beside its own would win or lose by stylesheet order.

- **Three fades were written down and never ran.** `transitionClasses` lists the four properties a control answers a pointer with, and `opacity` is not one of them. An `Image` carried a comment saying the picture is faded in over a transition that could not fade it; a chart's legend dimming switched rather than faded; and a chart's other series dropped to 0.28 the frame the pointer crossed a legend row. `LineChart`, `AreaChart`, `BarChart` and `ScatterChart` now read the same `seriesDimClasses` that only `PieChart` had.

- **A `Checkbox`'s tick and a `Radio`'s dot appear over time.** The tick draws itself along its own length on `stroke-dashoffset`, over a path normalised with `pathLength="1"` so one number covers both the tick and the indeterminate dash; the dot grows out of the centre of its ring on `width` and `height`. Neither scales, and the [design language](https://neba.cdget.com/design/design-language) now names the four things allowed to travel inside a control — a Switch's thumb, a Checkbox's tick, a Radio's dot, a Rating's fill — and says the list is closed.

- **A chart's marks answer the pointer on one `transition` shorthand.** A whole series at 0.28 and a single datum at 0.92 are the same sentence at two scales, and the datum half snapped everywhere the series half now fades; the mark under the crosshair also grows by a pixel, which a `<circle>` reaches through `r` and a scatter's arbitrary `<path>` reaches through `scale`. The scatter mark grows about the point it is pinned to rather than the middle of its bounding box. All three ride `markTransitionClasses`, because two shorthands on one element are decided by stylesheet order rather than by intent.

- **Four more places where something changed and nothing moved.** A `Rating`'s fill travels on `width` — the same width on the same element, so no glyph is scaled. A `Tab` panel's arriving content fades up, and only the arriving one, since fading a leaving panel would put both in the layout and make the sheet twice as tall on the way past. An `Avatar`'s picture fades up on its own clock instead of swapping in on one frame, which on a list of forty was forty separate flickers. A `FloatingActionButton`'s dial no longer arrives in a single frame.

- **A `TreeView` branch opens at a height.** It was there on one frame and gone on the next, while `Accordion` and `Collapsible`, which do the same thing, both travel. It is a grid row going from `0fr` to `1fr`, so nothing is measured and a nested branch is carried by the same track. A branch on its way shut stays in the document but is marked `data-closing`, which keeps its rows out of the order the arrow keys walk and deregisters them on the same render that shut the branch.

- **`Transfer` says where the rows went.** A press on the arrow took three rows off one list and put them in the other in a single frame, so the only way to find them was to read the whole panel again. The rows that landed fade up — keyed on the press and not on the list changing, because `rows` also changes on every keystroke in the search box and a filter that animates is a filter that feels slow.

- **A `GaugeChart`'s reading and range labels stay inside the dial.** The reading was twice the tick type whatever it said, so `10,000%` was written straight across the band and out of the card; it is solved against a chord of the inner circle now and gives way to once the tick type before it is left to run. The two range labels were written from the arc's mid radius and lay over the band on a thick dial; they are set from the outer edge, in the arrangement the end calls for, and a dial closed past 330° writes none. The dial is also centred in the box rather than pinned under its top margin.

- **A picture that had already decoded stayed invisible.** An `<img>` fires `load` at whoever is listening at the time, and a data URI decodes inside the same task the element was inserted in — so the event went out before React had attached anything to catch it and the picture sat at `opacity: 0` behind its own placeholder for good. It is asked after the fact now: `complete` says whether it finished and `naturalWidth` says which way.

- **A `Drawer` in `inline` mode and a collapsed `Sidebar` dropped the props they were handed.** Only the `overlay` shape spread them, so an `id`, a `data-*` or an `aria-*` reached the panel in one mode and not the other — and on a `Sidebar` the mode is the window's choice rather than the caller's, so an attribute was there on the screen you developed against and gone on the screen you did not. A structural rule for this was tried and rejected: `resolution.test.ts` can ask whether one element both spreads and writes an attribute of its own, but "every tree this component can return forwards what it was handed" is a question about branches, and every regex shape of it produced false positives. It is three ordinary tests instead.

- **A `HowToSteps` row said its title twice.** The sentence naming the step sat in a visually hidden line beside the title rather than in place of it, so a screen reader announced the button as "Use it Step 3: Use it". It is the button's `aria-label` now. A `title` that is a node leaves no string to build that sentence out of, and such a row is read as its contents.

- **`GridContainer`'s axis gutters took their prop whole.** `spacing={2} columnSpacing={{ md: 6 }}` left the row with no column gutter at all below 48rem, because the map says nothing there and the baseline it fell back to was the prop's own default rather than the `spacing` beside it. The two are walked together now, and `Flex` uses the same fold.

- **The suite finishes.** `run-test` had been red on `main` for weeks, always the same way: the chromium jobs failed on every runner while firefox and webkit passed on all three. It is not a test — every test that starts passes, and chromium loses the browser somewhere past the hundredth file of a hundred and forty-six, so the _file_ count comes up short beside a full _test_ count. Twelve full runs, none finished; the only lever that separated a run which finished from one which did not was how many files a single browser session was asked to hold. See the sharding above; eighteen sharded runs since, all green.

- **`npm run docs:build` needed more heap than Node gives by default.** A hundred and thirty-nine pages with two hundred React demos behind them is past 4.3 GB, and it failed as a V8 `Abort trap: 6` inside Rollup that named no page at all.

### Documentation

- A new [breakpoints](https://neba.cdget.com/design/breakpoints) page, which is where the rule that every entry is a floor, the table of which props are responsive, and the reason `size` and `variant` are not among them all live.

- The [design language](https://neba.cdget.com/design/design-language) names its two exceptions rather than leaving them to be found: the closed list of four indicators allowed to travel inside a control, and the drawer that arrives on `translate` where every other floating surface only fades.

## 1.11.0 (2026-08-31)

The release that closes the gaps, rather than the one that adds a shelf of new components.

It started as an audit against the libraries people arrive here from — MUI, Ant Design, Chakra, Mantine, Radix, PrimeReact — and the answer was not the component list. Neba already ships charts, animations, a page shell and a data table that most of them charge for or split into a second package. What it was missing was smaller and felt harder: no way to say "this application is compact" once, no hooks, no imperative confirm, no standalone calendar, and a `TextField` you could hand an `onKeyDown` but could not actually make act on a key.

Nine of those are closed here. The one deliberately left open is a rich text editor, which is somebody else's package.

### Where the bytes went

| What you import               | 1.10.0   | 1.11.0   |
| ----------------------------- | -------- | -------- |
| `Divider`                     | 3.0 kB   | 3.2 kB   |
| `Button`                      | 5.0 kB   | 5.1 kB   |
| `Chip`                        | 3.0 kB   | 3.2 kB   |
| `LineChart`                   | 11.3 kB  | 11.4 kB  |
| `CodeBlock`                   | 4.9 kB   | 5.0 kB   |
| a whole page shell            | 28.4 kB  | 28.5 kB  |
| 12 components — a typical app | 67.3 kB  | 68.2 kB  |
| 12 components, with Korean    | 69.9 kB  | 70.7 kB  |
| 25 components — a large one   | 111.7 kB | 112.6 kB |
| all exports                   | 240.7 kB | 248.1 kB |

**Every component grew by about 0.2 kB, and it is one thing.** `NebaProvider` fills in the props a call site left out, which means every component that takes `size`, `density`, `variant` or `locale` now reads a context before its own destructuring — a hundred and thirty of them. `internal/defaults.ts` is 0.2 kB gzipped and it is a fixed cost even on a page that has no provider, which on a Chip is five per cent. It is stated here rather than left to be found, and `CLAUDE.md` now carries it as the sixth thing that holds the bundle numbers in place: whatever goes into that module goes into all of them.

The rest of the growth is the four new components and the hooks, and it lands where it should — on `all exports` and nowhere else.

`neba/styles.css` moved 20.8 → 21.0 kB gzipped.

---

A `DatePicker` has always drawn all three grids. The month name opened twelve months, the year opened twelve years, and both were only ever a way of reaching a day — so a product that wanted a billing period or a tax year got a control that showed it the twelve months and then insisted on a date inside one of them. `granularity` makes one of those grids the answer.

And a field has always accepted an `onKeyDown`, which is not the same as being able to act on a key. On a `Combobox` the keys worth acting on are the list's and never arrive; on a `NumberField` the handler lands on the column holding the label rather than on the `<input>`. `shortcuts` is `{ 'Mod+Enter': send }` bound to the control itself, written in the vocabulary `Shortcut` already draws — which turned out to be a vocabulary the library only half spoke.

`internal/keys.ts` is 0.6 kB of the field rows above, and it is carried whether or not a `shortcuts` map was passed: the alias table and the predicate are reached from the control's own key handler, so there is nothing for a bundler to drop.

### Added

- **`granularity` on `DatePicker`** — `'day'` (the default, unchanged), `'month'` or `'year'`. At the two coarser settings the calendar opens on that grid and a click there is the answer; there is no day view to fall into. Climbing is untouched, so a month picker still reaches any month of any year in two clicks.

  The value stays a `Date`, normalised to the first day of what was chosen — 1 March, 1 January. A second value type would have meant a second set of props to compare it with, and `minDate`/`maxDate` already speak `Date`.

  Four things follow the unit rather than being left to the caller to keep in step. The trigger's default `format` becomes `{ year: 'numeric', month: 'long' }` or `{ year: 'numeric' }` — `dateStyle: 'medium'` on a month picker prints `Mar 1, 2026`, which names a day nobody chose in the one place a reader actually looks. The footer's shortcut says "This month" or "This year". `name` submits `YYYY-MM` or `YYYY`, the shape a native `<input type="month">` already submits, rather than a day the server would have to know to ignore. And the bounds are read at the unit.

- **`thisMonth` and `thisYear` on `PickerLabels`** — the two strings that footer needs. Both have English defaults, like the eighteen already there.

- **`shortcuts` on `TextField`, `NumberField` and `Combobox`** — a map from a key combination to what it does, spelled the way [`Shortcut`](https://neba.cdget.com/components/display/shortcut) draws it, so the key a form _shows_ a reader and the key it _binds_ are one string.

  ```tsx
  <TextField
    label="Message"
    multiline
    shortcuts={{
      'Mod+Enter': (event) => {
        event.preventDefault();
        send();
      },
      Escape: clear
    }}
  />
  ```

  A map rather than an `onShortcut(combination, event)`, because a caller with three shortcuts wants three functions and not a `switch`. Modifiers are matched **exactly**, so `Enter` and `Mod+Enter` are two entries that never both fire and no entry is ambiguous.

  It is bound to the control, which is the half `onKeyDown` could not do. On a `TextField` that only moves `currentTarget` onto the `<input>`; on a `NumberField` it is the difference between the field and the column the label sits in; on a `Combobox` it is the only way in at all, because the arrows, `Escape` and `Enter` belong to the list and are gone before anything on the root sees them. `onKeyDown` still receives every keystroke and runs after the map — neither prop replaces the other, and nothing is prevented on your behalf.

  This is deliberately three components and not thirteen. It is for a control a reader **types into**, where a key is a thing the control already has an opinion about. Everything else already takes the handler it needs.

- **`NebaShortcuts` in `src/types.ts`** — the type behind that prop, generic in the element so `event.currentTarget.value` is typed without a cast.

- **`NebaProvider`** — one optional place to set what every component under it starts from, and the gap that costs the most on every project while showing up in no bundle number.

  `defaults` fills in `size`, `density`, `variant` and `locale` where a call site left them out, and the call site still wins: caller, then provider, then the component's own literal. The list is closed. `color` is out because a component's colour default is often semantic — an Alert is `info`, a Popconfirm is `danger` — and one global override would repaint those into something that means something else; `elevation` is out because a shadow is opt-in per surface, and an application-wide one is the moulded-plastic look the design language is against.

  The colour scheme writes `data-theme` **and** `color-scheme` on `<html>`; the second is what turns the browser's own scrollbars and form controls over, and a page that changes only its own colours keeps a white scrollbar down the side of a dark one. `useColorScheme()` keeps `system` as its own answer and `resolvedColorScheme` never is, because a three-way switch has to show `system` as a position rather than as whichever of the two it resolves to. `colorSchemeScript()` is exported for the first-paint flash React cannot prevent, and shares the provider's key and attribute rather than being a snippet in a page nobody updates.

  `direction` sets `dir` and wraps Base UI's `DirectionProvider`, and is left alone when not given, so a document that already sets it server-side is not fought over.

- **Seven hooks, from `neba/hooks` and the barrel** — `useDisclosure`, `useMediaQuery`, `useBreakpoint`, `usePrefersReducedMotion`, `useElementSize`, `useOnScreen`, `useShortcut`.

  Every one is machinery the library already runs on, which is the whole selection rule: there is no general-purpose hook collection here and there is not going to be one. `useDisclosure` is the caller's half of the `open`/`onOpenChange` pair every overlay takes; `useMediaQuery` is the store PageLayout subscribes to, one live `MediaQueryList` per query for the page; `useElementSize` and `useOnScreen` are the two shared observers; `useShortcut` is what CommandPalette binds its own opener with.

- **`Calendar`** — the pickers' grid, inline. It has been in `internal/` since the first picker shipped, which meant a page wanting a month on it had to open a DatePicker and never close it. `mode` is `single`, `multiple` or `range`; a second click on a held day takes it out, and a range click below the start begins a new span rather than inverting the old one. `renderDay` puts a dot or a count under a number. It is **not** a scheduler, and the docs say so: the cells are the control ladder's heights.

- **`TreeSelect`** — the gap between `Select` and `TreeView`. `selectableBranches` is off by default because in most of these trees the branches are the taxonomy and the leaves are the answers, and `searchable` keeps every ancestor of a match and opens the branches it kept — a tree filtered to bare matches is a list, which is what the tree was chosen over.

- **`Image`** — the three things a bare `<img>` leaves to whoever wrote it: `ratio` reserves the box, a Skeleton stands in while the file arrives, and a box carrying the `alt` is drawn if it does not. `alt` is required by the type, because a missing one and an empty one mean different things and only the second is ever correct.

- **`ConfirmProvider` and `useConfirm`** — "are you sure?" as something you await. A promise rather than an `onConfirm`, because the code that asks is the code that acts. It never rejects; cancelling, `Escape` and the backdrop all resolve `false`. Questions queue rather than replacing each other: resolving an older one to make room reports an answer nobody gave, which at the call site reads as "they said no".

- **`Popconfirm`** — the same question beside the control that raised it. The choice between the two is **reach**, not danger or size.

- **`VisuallyHidden` and `Portal`** — two things the library has needed everywhere and kept to itself. `VisuallyHidden` is the 1px clipped box behind a Chip's × and a chart's screen-reader table; `Portal` adds the `neba-portal` class a scoped stylesheet finds a portalled subtree by, which is the reason to reach for it over `createPortal`.

- **Five things on `DataTable`** — column pinning, `columnOrder` and drag-to-reorder, in-place cell editing, `groupBy` with per-column `aggregate`, and CSV export. Each carries its own sharp edge in the docs: a pinned column moves to its edge, an order that does not name a key leaves it alone, editing needs both a column that allows it and a handler above it, grouping turns virtual scrolling off, and an export is every row the search and sort left rather than the page the reader is on.

### Fixed

- **A folded group in `DataTable` kept its rows but lost its own heading**, so there was no way to unfold it. Caught by its own test on the way in; the body now renders group by group rather than deriving headings from the rows it can see.

- **`shortcut` on `CommandPalette` now binds every spelling `Shortcut` draws.** `Cmd+K`, `Command+K`, `Meta+K` and `Esc` all rendered a correct key cap and none of them fired; `Ctrl+K` was dead on Windows and Linux, because the matcher folded any `Ctrl` into the platform's `Mod` and then found no `Mod` in what it had been given. Only `Mod+…` and a bare key ever worked.

  The cause was two spellings of one idea: the drawing side had an alias table and the binding side had a five-line predicate written separately. `src/internal/keys.ts` is now the one place that decides which key a token names, and both sides read it — the aliases, the platform, and the `Alt`-on-a-Mac case where `event.key` reports `˚` and the physical key has to be consulted instead. What a key looks like stays in `Shortcut`.

### Changed

- **`minDate`, `maxDate` and `shouldDisableDate` on `DatePicker` are read at `granularity`.** A minimum of 15 March leaves March pickable at `month`, since part of March is allowed, and `shouldDisableDate` is handed the value the cell would produce — the 1st, rather than a day inside the month it is being asked about.

  Nothing changes at `day`, which is what every existing call is: `isUnitOutside` at day granularity is the `isDayOutside` it was before, character for character. The month grid was already making this comparison inline — it is the rule that keeps a month whose `minDate` falls inside it reachable — so the two coarser grids now call one function instead of restating it, and the footer's shortcut asks the same question the cells do.

  `shouldDisableDate` reaches a coarser grid only when that grid is the one being chosen from. At `day` a callback blocking weekends must not grey out every month whose 1st happens to be a Saturday.

- **Every component reads its props through `useStyleDefaults` before its own destructuring.** That is what makes `NebaProvider`'s precedence come out as caller → provider → literal, and it is why every row of the table above moved.

  The keys are passed in per component rather than worked out, and that is load-bearing: a key a component does not destructure stays in the props it spreads onto its root, so filling `density` into one that has none would put `density="compact"` on a `<div>` — and `size` on an `<input>` is a real attribute that would quietly resize the field.

- **`internal/media.ts` owns the five breakpoint widths**, which used to live in `page-layout.ts`. A layout asks "narrower than this" and a caller asks "at least this"; two tables would be two chances to disagree about what `md` is.

## 1.10.0 (2026-08-30)

No new components. This one is about the question that follows installing a component library and using it for a week: how do I change how this looks, when the design language and I disagree about one thing on one screen.

`className` was never the missing half — every component already took one and merged it with its own. What it could never reach was everything _behind_ the root. A `TextField`'s `className` lands on the column holding the label, the shell and the two lines under it, which means the `<input>` itself had no name a caller could use; a `Table`'s lands on the sheet the table scrolls inside, leaving the `<table>`, its header band, its rows and its cells unreachable; and a `Select`'s popup, a `Dialog`'s backdrop and a `Tour`'s mask all render at the end of `<body>`, outside the element `className` reaches, so no selector written against the root would ever find them. Thirteen components now take a `classNames` map — seventy-six named parts between them.

The standing scenarios say what that cost the people who do not use it:

| What you import               | 1.9.0    | 1.10.0   |
| ----------------------------- | -------- | -------- |
| `Button`                      | 5.0 kB   | 5.0 kB   |
| `Chip`                        | 3.0 kB   | 3.0 kB   |
| `LineChart`                   | 11.3 kB  | 11.3 kB  |
| `CodeBlock`                   | 4.9 kB   | 4.9 kB   |
| a whole page shell            | 28.4 kB  | 28.4 kB  |
| 12 components — a typical app | 67.2 kB  | 67.3 kB  |
| 12 components, with Korean    | 69.7 kB  | 69.9 kB  |
| 25 components — a large one   | 111.4 kB | 111.7 kB |
| all exports                   | 240.3 kB | 240.7 kB |

A slot is one more argument into a `cx()` that was already being called, so nothing was added to the runtime and the five unchanged rows did not move. `neba/styles.css` does not move at all — there is no new CSS in this release. The 1.9.0 column is the budget as last recorded, which for two rows is a tenth or two above the table in those release notes — four commits of `perf` and `refactor` work landed after they were written.

### Added

- **`classNames` on thirteen components** — `TextField`, `NumberField`, `Select`, `Combobox`, `Checkbox`, `Switch`, `RadioGroup`, `Radio`, `Table`, `Dialog`, `ToastProvider`, `Tour` and `CommandPalette`. One class name per part, merged with the component's own rather than replacing it.

  **There is never a `root` key.** `className` is the root, on every component in the library, and a `classNames.root` beside it would be a second spelling of an idea that already has one — which is the rule `src/types.ts` exists to hold. `NebaSlots` and `NebaFieldSlot` are in that file for the same reason `NebaStyleProps` is: `label`, `control`, `description` and `error` mean the same four things on a `TextField`, a `Select`, a `Checkbox` and a `RadioGroup`, and what a component adds past them lives with the component.

  The slots worth knowing about are the ones with no other way in. `Select`'s and `Combobox`'s `popup` and `item`, `Dialog`'s and `CommandPalette`'s `backdrop` and `viewport`, and `Tour`'s `mask` are all portalled or siblings of the element `className` lands on. A descendant selector written against the root does not reach any of them, and before this there was nothing that did.

- **`className` on `Tour` and `CommandPalette`**, on the card and on the sheet — the same element `Dialog` puts one on, because in all three that is what a caller means when they name the component.

  `ToastProvider` still takes none, and that is the answer rather than an omission: it renders no element of its own — it wraps the application and puts a portalled stack on the page — so there is nothing for a root class name to land on. Its `viewport` and `toast` are slots instead.

### Changed

- **A `Table` cell's padding, alignment and background are still inline styles, and now say so.** They have to be — `.vp-doc td` and `.prose td` outrank any one-class utility, which is why the styling moved inline in the first place — so a class handed to `cell`, `headCell` or `empty` can add anything the component does not already set inline and needs an important utility (`p-4!`) to change what it does. The slot type and the component page both carry that caveat rather than leaving it to be discovered.

- **`ToastProvider`'s description no longer builds an empty class name out of a nested ternary.** Same output, one condition instead of two.

### Fixed

- **`npm run size:update` no longer leaves the working tree failing `prettier --check`.** It serialised with `JSON.stringify(…, 2)`, which puts `"imports": ["Button"]` on three lines where Prettier wants one; the file stayed unformatted from the moment the script finished until something else rewrote it, and the only reason that was survivable is that `npm run build` runs `format:fix` first, so it was usually undone by accident before anyone looked. The formatter now does the layout, loaded on that path only so the check path — the one CI runs — does not pay for a formatter it never calls.

### Documentation

- **The getting-started guide stopped promising the wrong thing.** It told a Tailwind user that a `className` they pass "sorts correctly against the component's own classes", which reads as a promise that theirs wins. Same-pass generation is only what lets the two be ordered against each other at all; the order is Tailwind's own, so a component's `h-10` beats a caller's `h-8` and its `rounded-lg` beats a caller's `rounded-full`, while `bg-red-500` wins — decided by the value rather than by who wrote it. The important modifier (`h-8!`) is the form that always wins, and it is now documented as such.

- **A new section in [prop conventions](https://neba.cdget.com/design/prop-conventions)** covering all three channels: `className` on the root, `classNames` on the parts behind it, and `style` writing one of the hundred-odd `--n-*` custom properties a component reads its colour and depth out of. The last of those is the one override in the library that cannot lose — a caller's `style` is merged after the component's own, and an inline custom property has no cascade to compete in.

- Twenty-four component pages — twelve components in both locales — gain a `classNames` section, with their rows in the props tables.

- **`test/package/resolution.test.ts` now holds the override contract**, which fails the way everything else in that file fails: silently, and in someone else's project. Four invariants — that no component drops the `className` or `style` it was handed into a props spread, in JSX and in the `props` object `useRender` takes; that a slot union is declared beside the component that offers it; that it never names `root`; and that every slot offered is actually read. A slot that type-checks, reads as supported and does nothing is exactly what this catches.

- Thirty-nine new test cases across thirteen files, taking the suite to 2,466.

## 1.9.0 (2026-08-30)

Sixteen components, and they come from one question asked properly: what does a large application still have to write by hand after installing this? The answer was in two places. Nine of them were Base UI primitives that had simply never been wrapped — a toggle and its group, a meter, a menu bar, a navigation menu, a hover card, a scroll area, a form and its fieldset. The other seven are the components a product team writes itself around the third month: a command palette, a guided tour, a two-list transfer, a table of contents that follows the scroll, a key-value panel, a stack of avatars, and a gauge.

Twenty new exports, and the standing scenarios say what they cost the people who do not import them:

| What you import               | 1.8.1    | 1.9.0    |
| ----------------------------- | -------- | -------- |
| `Button`                      | 5.0 kB   | 5.0 kB   |
| `Chip`                        | 3.0 kB   | 3.0 kB   |
| `LineChart`                   | 11.0 kB  | 11.0 kB  |
| a whole page shell            | 28.1 kB  | 28.1 kB  |
| 12 components — a typical app | 67.0 kB  | 67.1 kB  |
| 25 components — a large one   | 110.8 kB | 111.4 kB |
| `DataList`                    | —        | 1.4 kB   |
| `Anchor`                      | —        | 2.0 kB   |
| `Meter`                       | —        | 3.9 kB   |
| `Form` with `Fieldset`        | —        | 3.9 kB   |
| `GaugeChart`                  | —        | 5.4 kB   |
| `CommandPalette`              | —        | 36.6 kB  |
| all exports (126 → 146)       | 215.3 kB | 239.8 kB |

The four unchanged rows are the ones worth reading: twenty new exports, and a bundle that did not ask for them is the same size to the byte. The two application-sized rows moved by 0.1 kB and 0.6 kB, and for a reason that is in **Changed** below rather than for anything that stopped being shaken out — every field component now renders the message its validity already had.

The spread in the new rows is Base UI rather than Neba. `DataList` is a `<dl>` and weighs what one weighs; `CommandPalette` is a modal dialog over an autocomplete, and the floating machinery underneath it is most of thirty-six kilobytes — shared with `Menu`, `Select`, `Popover` and `Dialog` the moment a page uses any of them. `neba/styles.css` moves 19.7 kB → 20.8 kB gzipped.

### Added

- **`Toggle` and `ToggleGroup`.** A button that stays down. The difference from a `Switch` is what the press _is_ — a switch changes a setting and the change is the point, a toggle changes the state of the thing beside it: bold on the selected words, the grid on the canvas, the filter on the list. The difference from a `Checkbox` is that this one is a control rather than an answer, so it never goes in a form.

  `variant` says how the toggle looks while it is **off**, and on is always the colour family asserting itself. That is the whole design: the ink at rest is `--neba-muted-fg` in all three weights, because a Button at rest is an action waiting to be taken while a toggle at rest is a state that is currently _false_, and accent ink on an unpressed toggle says it is on. With no children it goes square around its icon, which is the shape a toolbar wants.

  `ToggleGroup` squares off the corners facing a neighbour exactly as `ButtonGroup` does, owns the value as an array in both the single and the multiple case, and sets `variant`, `size`, `color`, `density`, `elevation` and `disabled` once for the set. It provides the same context a `ButtonGroup` provides rather than a second one spelled identically, so a `Toggle` dropped into a `ButtonGroup` picks the set up too.

- **`Meter`.** How much of something there is, on a scale known in advance — disk used, seats taken, quota spent, a password's strength. It looks exactly like a `ProgressLinear` and is not one: a progress bar is about _time_, so it may have no value at all and is expected to move on its own, while a meter is about _quantity_ and does not move unless the thing it measures does. `value` is therefore required, and `role="meter"` rather than `role="progressbar"`.

  `thresholds` is the reason it earns a component. A meter's whole job is that where the value sits is what it means — 40% of a disk is fine, 95% is a page — and left to the caller that is a ternary at every call site, with the fourth one disagreeing about where amber starts.

- **`GaugeChart`.** The same reading bent into an arc, and deliberately the same component in two shapes: `value`, `min`, `max` and `thresholds` mean exactly what they mean on a `Meter`, so a figure can move from a bar to a dial without changing what it says. Reach for the bar in a row of fields and for the dial in a tile of its own, where it reads from across a room and four pixels of bar does not.

  `sweep` opens the dial symmetrically about twelve o'clock — `180` for a dashboard tile, `270` for the instrument shape, `360` for a ring — and the drawing is sized against the box for the sweep it was given, so a half-dial leaves no empty half above it. It is not a `PieChart` with `shape="semi"`: a pie is parts of a whole and every slice is a category, while the unfilled part of a gauge is not a second category, it is the rest of the dial. The reading in the middle is real text rather than an SVG `<text>`, so it is selectable, findable and in the accessibility tree.

- **`Menubar`.** The strip of words at the top of an application — File, Edit, View. What makes it a bar rather than a row of separate menus is what happens once one is open: moving along the strip walks through the others instead of closing the one you left, and the arrow keys move between the menus as well as inside them. `MenubarMenu` takes a `label` and the same `MenuItem`, `MenuGroup`, `MenuSeparator`, `MenuCheckboxItem`, `MenuRadioGroup` and `MenuSubmenu` a `Menu` takes, because it is the same menu.

  It draws no surface, and the words sit on a ladder one rung below the control heights at every step. A menu bar is a strip of _words_ rather than a row of buttons, and it is always on something that already has a height — a `Toolbar`, a `WindowPane`'s title bar, a `Header`. Sized as controls, `File Edit View` would make the bar taller than the thing it is drawn on.

- **`NavigationMenu`.** A site's navigation: a row of destinations, some of which open a panel of more of them. The difference from a `Menu` is what the rows _are_. A menu holds actions, so its rows are `menuitem`s and the whole thing is a widget. This holds links, so it is a `<nav>` full of real `<a href>`s — which is what puts them in the link list a screen reader pulls up, on the status bar, in a "open in new tab", and in a crawler's index. An item with children is a trigger and a panel; an item with an `href` and nothing else is a link, and the two are announced differently.

  One panel is open at a time and it resizes between items rather than closing and reopening, so crossing the row reads as one surface rather than three. `columns` lays a wide panel out in two or three.

- **`CommandPalette`.** Everything an application can do, behind one field — the shape a keyboard-first product takes once it has more actions than a menu bar can hold. Not a `Menu`, which is a short list in one place where every row is visible before you look for it; not a `Combobox` either, because what comes back is not a value, it is something happening.

  `keywords` is the prop that decides whether anyone opens it twice: words the query matches and that are never drawn, so `Roll back` is found by typing `undo` and `Deploy production` by typing `ship`. `group` draws a heading each time it changes. `shortcut` binds the opening keystroke on the window and defaults to `Mod+K` — `Mod` being Command on a Mac and Control everywhere else, read from the same spelling `Shortcut` draws, so the label on the screen and the key that actually works cannot drift apart. `shortcut={false}` binds nothing, for an application that owns its own keyboard.

- **`Tour`.** A guided walk over a page that already exists — the three things a new reader has to be shown once, pointed at where they actually are. It is `HowToSteps` turned inside out: that component puts the instructions _in_ the page and the reader follows them, this one leaves the page alone and stands over it. Each step names its target with a CSS selector rather than restating it, because what a tour is about is already on screen and a second copy inside the card is a second copy to keep in step.

  The dimming is one element with a hole in it — a box the size of the target carrying a shadow larger than any screen — rather than four rectangles around it, because the corners of a four-piece scrim never quite meet and the seams show the moment the dimming is anything but opaque. It never takes the pointer either, so the control being pointed at can still be used while the card is up, which is the whole difference between a tour and a sequence of dialogs. A step with no `target` is centred with nothing cut out, for a welcome card and a closing one.

- **`Transfer`.** Two lists and the arrows between them: everything that could be chosen on one side, everything that has been on the other. The shape for a choice that is _long_ — the columns in a report, the permissions on a role, the people on a channel — where a `Combobox` with forty chips in its field stops being readable and forty checkboxes give no answer to "what did I actually pick". Below about a dozen options, one of those two is the smaller component.

  Ticking a row is not choosing it: ticks say which rows the next press moves and `value` says which side they are on, and keeping the two apart is what lets a filter hide a row without silently moving it. The order of `items` is the order both lists show, so a row does not jump when it is sent across and back.

- **`Anchor`.** The list of headings on the page being read, with the one the reader is in marked. Real `<a href="#…">`s in a real `<nav>`: they jump to their headings with JavaScript off and they are in the link list, and the scroll tracking is added on top rather than being the thing that makes it work.

  The marked row is the last heading whose top has passed the line, which is the only rule that reads correctly going _up_ as well as down, and the last heading wins once the scroll reaches the bottom — otherwise a final section with less content than a viewport is the one section that can never be marked. Nothing is marked while the reader is still above the first heading. `offset` clears a sticky header and `container` names what scrolls when it is not the document, which is what a `PageLayout` with `scroll="content"` needs.

- **`DataList`.** A list of things and what they are called — a details panel, a summary of a record, the metadata under a heading. Real `<dt>`/`<dd>` pairs rather than a two-column `Table`, and the difference is not cosmetic: a table is a grid of rows all of the same shape and a screen reader walks it as a grid, while this is a set of pairs and each one is read as "label, value". The label column sizes itself to the widest label, so every value in the list starts at the same place without anybody measuring.

- **`AvatarGroup`.** A stack of avatars, overlapping, with the ones that did not fit as a count. `max` is how many are drawn and `total` how many there are altogether, for a group handed only the first few. The first avatar is on top, because a stack read left to right is read front to back and the one the group is _about_ should not be the one behind everything else.

- **`HoverCard`.** A card that opens when the pointer rests on something, holding a preview of what is on the other side — a person behind a mention, a repository behind a link, a deploy behind an id. It sits between the library's other two popups and is close to both: a `Tooltip` is a label the pointer never reaches, a `Popover` was _asked for_ by a press. This one is uninvited like the first and reachable like the second, so the pointer can cross into it and a link inside it can be followed. `closeDelay` is what makes the gap between the trigger and the card crossable.

- **`ScrollArea`.** A box with a scrollbar of its own, because the browser's is drawn by the operating system: seventeen pixels wide on one machine, overlaid and invisible on the next, and a different colour from the sheet it is cut into. Not `ScrollZone`, which is a _rail_ — a strip of items with buttons that step through them; this is the plain case of a box too small for what is in it, and underneath both are ordinary scroll containers, so the wheel, the trackpad, momentum and the keyboard are the browser's own.

  `fade` dims the content at each edge that has more beyond it and only there, so there is no fade at the top when you are at the top. It is a mask rather than a gradient painted over the content, because a gradient has to fade _to_ a colour and a scroll area usually sits on a translucent acrylic sheet where there is no such colour.

- **`Form` and `Fieldset`.** A `<form>` that knows which of its fields is wrong. On its own, a page of `TextField`s validates one field at a time and a failed submit leaves the reader to find the red one; what this adds is the part that has to be owned above the fields — a submit collects every field's validity at once and moves focus to the first that failed, so the reader is taken to the problem rather than told there is one. `errors`, keyed by each field's `name`, puts a server's answer back on the field it belongs to instead of in a banner, and clears it as soon as that field changes.

  It is not a form _library_. There is no schema, no resolver and no field array here — a project that wants those keeps them and hands the result to `errors`, which is the seam this is built around. `validationMode` defaults to `onSubmit`, the only setting that does not tell somebody their email is wrong while they are still typing it.

  `Fieldset` is the grouping and draws no surface, because a group of fields is a grouping and not a sheet — the sheet already exists, and this goes inside a `Card`. What it owns is the legend, the gap the controls stand at, and the one thing only a real `<fieldset>` can do: `disabled` reaches every control inside it, including ones a component three levels down rendered and never heard of it.

- Three new message namespaces in all eighteen languages — `anchor` for the table of contents' `<nav>` name, `transfer` for the two headings, the two buttons, the filter and the select-all, and `command` for the palette's placeholder, its empty line and the name of a dialog that has no visible title — plus `steps.skip`, which `Tour` and `HowToSteps` share. All four together move a twelve-component app with Korean registered from 69.2 kB to 69.6 kB.

- **`ScrollZone` takes the wheel, where it is asked to.** A mouse has one wheel and it points down the page, which is the one axis a horizontal strip does not run along, so `wheel` turns a wheel rolled over the strip into travel along it. It is off by default, because a wheel taken from the page is the page's: a reader who meant to scroll past the shelf would be held by it instead. What it does take it gives back — at either end of the strip the wheel is the page's again — and a trackpad swiping sideways is left alone, since that already scrolls the strip and answering it here would move it twice as far as it was asked to.

### Changed

- **A field with no `error` of its own now shows the message its validity already had.** `TextField`, `NumberField`, `OtpField`, `Select`, `Combobox`, `Checkbox`, `RadioGroup` and `Switch` rendered a message only when the caller passed one, so a `required` field that failed the browser's own constraint went red and said nothing, and a `Form`'s `errors` marked a field invalid without ever drawing the sentence. Each of the eight now falls through to a plain `Field.Error`, which renders the current validation message and nothing at all while the field is valid. An explicit `error` still wins and still shows whenever the field is invalid. This is the tenth of a kilobyte in the twelve- and twenty-five-component rows above.

- **`Menu` no longer passes `modal` when it was not given one.** Base UI's default is the same `true`, and it warns when the prop is set on a menu that turns out to be nested — which is every menu on a `Menubar` and every submenu. Not passing it is how the default stays a default; nothing about how a menu behaves has changed.

- **`NebaThreshold` is in the shared vocabulary**, in `src/types.ts` beside `NebaSize` and `NebaColor`, because `Meter` and `GaugeChart` are the same reading in two shapes and a page carrying both must not disagree about where amber starts. It is the one place in the library where a semantic colour is _computed_.

- `fill()` — the `{index} of {total}` interpolation — moved from `HowToSteps` into `internal/i18n.ts`, now that a second component counts steps. The placeholders are part of the message format, and a language that orders them the other way round is exactly the case a second copy of that function would eventually get wrong.

- **`ScrollZone`'s `buttonPlacement` now defaults to `inline`.** The buttons stand beside the strip rather than over its ends, so an item is cut off at the button's edge instead of sliding beneath it, and the button is legible over the page rather than over whatever it landed on. `overlay` is still there and is still what a shelf of pictures wants, where the thing under a button is a picture that carries on. The type lists `inline` first now, the way every other union in the file puts its default first.

### Documentation

- Thirty-two component pages — sixteen components in both locales — with their props rows, sixty-one demos, sixteen cards in the component gallery and their blocks on the sample screen. `llms.txt` and the README's component lists carry all sixteen.
- The sample screen gains the two components that are only really visible in a page that already exists: a `Tour` hung off the application header it points at, and a `CommandPalette` opened by the `Mod+K` row the Keyboard card was already advertising.
- One hundred and eighty new test cases across sixteen files, taking the suite to 2,228.
- `CLAUDE.md` records the new group memberships, the two internal modules that gained a second reader (`button-group.ts` for `ToggleGroup`, `menu.ts` for `Menubar`), the new `internal/avatar-group.ts`, and the refreshed bundle table.

## 1.8.1 (2026-08-29)

Neba could not be imported into a React Server Component, and nothing in this repository could have said so. React's `react-server` build does not export `useState`, `useEffect`, `useRef`, `useContext` or `createContext` at all, so the fifty-three modules here that called one were a `TypeError` in someone's Next.js app rather than a component that rendered badly — and every check stayed green, because nothing here renders on a server.

### Fixed

- **Every component is a client component and now says so.** `'use client'` on all ninety-nine component files, and on the seven modules under `internal/` that hold a context or an effect. Importing one into a Server Component works, with no wrapper of your own and no `transpilePackages` entry. The directive marks a boundary rather than a page: a Server Component that renders a `Button` stays a Server Component, and only the components it renders reach the browser. What has not changed is the ordinary rule about that boundary — an event handler defined in a Server Component still cannot be passed across it.
- All of them, and not only the ones that hold state today. Thirteen components would technically have survived a server render; eight of those are Base UI form controls that go inside a client boundary anyway, and the other five are one prop from failing, since `transition` is a `useLayoutEffect` and `render` is Base UI's `useRender` and nearly every component in the library already takes one or the other. A per-component answer would be a table that rots. It costs nothing measurable either: every `npm run size` scenario is unchanged to the byte, because a bundler hoists the directive rather than shipping it a hundred and six times.
- **The `neba` barrel, the component barrels and `neba/locales` are deliberately left unmarked**, and each would break if they were not. A barrel only re-exports, so unmarked it belongs to whichever graph imports it and a Server Component importing `neba` reaches the client modules behind it rather than a boundary of its own. `registerMessages` stays a plain function for the same shape of reason: marked, it would arrive in a consumer's server module as a client reference instead of a function and throw when called.
- **`terser.config.json` sets `compress.directives: false`**, which is the half of this that would otherwise have failed silently. `directives` removes "redundant or non-standard" directives, and in a module — where `use strict` is implied — terser reads `use client` as both, stripping it out of all one hundred and six files without a word. The published package would have said nothing at all to Next.js while every check here still passed. It is `output.preserve_annotations`' twin: two settings, each keeping one thing terser eats on the way out.

### Documentation

- **Next.js and React Server Components**, a new section in _Getting started_ in both locales: what the directive does and does not do, why a handler written in a Server Component cannot be passed to a `Button`, where the stylesheet is imported in an App Router project, and how to register a language from a module that is in the client graph. `'use client'` is a string at the top of a file, so Vite, webpack, Remix, Astro and plain React ignore it and nothing above changes what the package does there. The README carries the short form.
- `test/package/resolution.test.ts` gains four checks, since this is exactly the kind of invariant that is invisible here and expensive in someone else's project: that every component starts with the directive, that every module calling a client-only React API does too, that the barrels and the locales do not, and that the terser setting holding it all up is still there. `CLAUDE.md` records the rule and its three deliberate exemptions.

## 1.8.0 (2026-08-29)

Everything Neba had until now went _inside_ a page somebody else had already built. This release builds the page: a layout and the three regions it arranges, the mark that goes in the corner of it, and two components for the kind of page you would put in it — a code viewer and a step-by-step guide.

Eight components, nine exports, and not a byte on anyone who does not import them:

| What you import               | 1.7.0    | 1.8.0    |
| ----------------------------- | -------- | -------- |
| `Button`                      | 5.0 kB   | 5.0 kB   |
| `Chip`                        | 3.0 kB   | 3.0 kB   |
| `LineChart`                   | 11.0 kB  | 11.0 kB  |
| 12 components — a typical app | 67.0 kB  | 67.0 kB  |
| 25 components — a large one   | 110.8 kB | 110.8 kB |
| a whole page shell            | —        | 28.1 kB  |
| `CodeBlock`                   | —        | 4.8 kB   |
| all exports (117 → 126)       | 206.8 kB | 215.3 kB |

The five unchanged rows are the interesting ones: they are what says the new modules are still shaken out of a bundle that did not ask for them. `neba/styles.css` moves 17.5 kB → 19.7 kB gzipped, and 0.8 kB of that is CodeBlock's ported themes — see below.

### Added

- **`PageLayout`, with `Header`, `Footer` and `Sidebar`.** The skeleton a page is hung on, and what it is really for is the landmarks: a page assembled out of divs is one undifferentiated region to a screen reader and one undifferentiated blob to a crawler, while the same page built out of `<header>`, `<aside>`, `<main>` and `<footer>` has a table of contents. `PageLayout` arranges the four, contributes the `<main>` and the skip link that jumps to it, and answers the questions the four cannot answer alone.

  `headerSpan` and `footerSpan` decide which of the bar and the rail takes the top corner — `full` is a website, `content` is an application — and they are asked separately, because a dashboard with a full-height rail still usually wants its copyright line under the content rather than under the rail. `scroll` decides whether the document scrolls or only the region between the bars. `sidebar` and `endSidebar` are two slots, for navigation down one side and a table of contents, an inspector or a filter panel down the other.

  The arrangement is flexbox and media queries on purpose: everything that decides where a column goes is stated in CSS, so the layout is right in the first frame the browser paints and right with JavaScript off. The only measurement is the header's and the footer's height, and only because a sidebar that holds its place has to start below a bar whose height nobody but the bar knows.

- **A `Sidebar` below `collapseBelow` is a `Drawer`**, not a second drawer written beside it — over a scrim, with a focus trap, an Escape and a way back to the trigger. Its children exist once either way, so nothing inside is in the document twice for a screen reader to read twice. `SidebarTrigger` is the hamburger that opens it and is _hidden_ above the breakpoint by a class rather than being absent, or every phone would draw a header and then pop a button into it a moment later. A sidebar can also be `resizable`, dragged by its inner edge and reported through `onResizeEnd`.

- **`Header` and `Footer` are usable on their own**, which is most of why they are separate components. A header takes three slots — `brand`, the middle, and `actions` — because the arrangement is fixed and what a caller wants to decide is what goes in each; `align="center"` centres the middle on the bar's own midline rather than in the space left over, so a logo one character longer does not move the navigation. Both take `position`, `maxWidth` on Container's ladder, and a `divider`.

- **`AppLogo`.** A product's mark, at a known size, that is never an empty box. Four things can be the mark and exactly one is at a time: markup handed to `children`, an image at `src`, the initials of `name` on a tile, or — with no tile to put them on — the name itself set as the logotype. That last one is the point: a product that has not drawn a logo yet still has a logo, and swapping it for the real file later is one prop.

  `shape` is the decision an `<img>` cannot make for you: a mark drawn as a bare glyph and one drawn with its own background need opposite treatment and the file cannot say which it is. `bare` keeps the artwork's proportions and draws nothing behind it; `app` and `circle` inset it into a tile. `bare` is the default because a logo file very often has the product's name set into it, which is also why `name` is read out rather than drawn a second time.

- **`CodeBlock`.** A viewer for one line of code or a thousand. Everything it draws above the code is optional and off one prop each — `toolbar`, `showLanguage`, `copyable`, `rawToggle`, `lineNumbers`, `startLine`, `prompt` — because the same component has to be a bare snippet inside a sentence and the full transcript at the top of a README, and those are the same block with different things turned on rather than two components.

  Syntax highlighting is highlight.js, and **every specifier that reaches it is behind an `import()`**: the core in one chunk, one chunk per grammar. So the block is 4.8 kB in the bundle a page downloads to draw its first frame, `highlight={false}` fetches none of the rest, and a block colouring TypeScript fetches about 11 kB more after the paint. Thirty-four languages come with it; `registerLanguage` is `registerMessages`' arrangement for the other hundred and fifty.

  `prompt` draws a shell symbol — `$`, `#`, `C:\>` — that is never actually there: it is generated content, so it cannot be selected, cannot be found by find-in-page and never reaches the clipboard. A transcript stays a transcript and still pastes into a shell. `highlightLines` marks lines with a tinted row and a rule down the leading edge, taking a number, a string of lines and ranges (`'1,4-9,12'`) or an array of either, counted the way the gutter counts. <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + <kbd>A</kbd> inside the focused block selects the code and nothing else.

  **`theme` is the one colour decision in the library that does not follow the page.** Code is read against a background chosen for code. Four themes are the library's own — `dark` (the default), `light`, `auto` and `mono` — and eight are ports kept at their published values: `one-dark`, `dracula`, `monokai`, `nord`, `night-owl`, `gruvbox`, `github` and `solarized-light`. A theme is a set of `--n-code-*` custom properties under a `[data-code-theme]` selector and nothing else, so the prop takes any string and a project that writes one in its own CSS has a theme with nothing to import and nothing to register.

- **`HowToSteps`.** A guide the reader walks through: numbered steps down one side, one step's instructions beside them, a way forward under those, and an end that says so. It is `Timeline`'s interactive sibling and the two are deliberately not one component — a Timeline _reports_ and nothing in it is pressed, while a HowToSteps _asks_.

  Every step's body is rendered into the same grid cell, with the ones not showing left in the document, `invisible` and `inert`, so the panel is as tall as the tallest step at every moment: moving from a one-line step to one with a code block in it does not resize the card the guide sits in, which on a page the reader has already scrolled moves everything under it. Nothing is remounted either, so a form halfway through a guide still holds what was typed into it.

  `orientation` runs the numbers down a column or across the top; `maxHeight` scrolls a long list and keeps the current row in view; `divider` puts a hairline between the list and the body; a step's `icon` is drawn before its title over the body and never in the list, where the numbered disc already says which step it is. `transition` is the entrance a step arrives with, from the library's usual motion vocabulary plus `'none'` — the one place that prop runs on something other than a mount, and inside the rule against moving a control for the same reason the rule exists: the effect is on the panel, and the buttons and rows that changed it hold still.

- Three new message namespaces in all eighteen languages — `layout` for the skip link, the sidebar's name and the button that opens it, `code` for the copy button and the raw toggle, and `steps` for the four buttons and the sentence at the end. All three together move a twelve-component app with Korean registered from 68.7 kB to 69.2 kB, which is the whole of what a new set of words costs a project that has registered a language.
- `npm run size` gains a **page shell** scenario — `PageLayout` with `Header`, `Footer`, `Sidebar`, `SidebarTrigger` and `AppLogo` — and prints each scenario's on-demand chunk total beside its entry. That second number is unbudgeted and exists so CodeBlock's grammars cannot quietly become the entry's problem: the day that `import()` turns static, 4.8 kB becomes 68.

### Changed

- **`highlight.js` is a second runtime dependency**, alongside Base UI. Only `CodeBlock` reaches it, only through a dynamic import, and it therefore never lands in a bundle that did not ask for it. It is a real dependency rather than an optional peer because a specifier a bundler cannot resolve fails the _whole_ build — Rollup walks and resolves `CodeBlock.js` while it is still deciding whether to keep it — so an optional peer would break `import { Button } from 'neba'` for anyone who had not installed a highlighter.
- A `Header`'s three slots are held apart by their own gap ladder, about twice the gap _inside_ a slot. One ladder was doing both jobs, which put the first navigation link exactly as far from the logo as the logo sits from its own name, so the eye grouped the wrong things and the bar read as one undifferentiated row.

### Fixed

- **A press on a `FloatingBottomNavigation` no longer moves the bar's height.** The name on a floating destination collapsed in both axes, so an item without one was shorter than an item with one — and since a press animates two items at once, the tallest item in the row dipped to somewhere between the two heights and came back, taking the sheet with it. On a lozenge floating over the page that read as the whole bar wobbling. Only the column track travels now.

### Documentation

- Seven component pages in both locales — `PageLayout`, `Header`, `Footer` and `Sidebar` under **Layout**, `AppLogo` and `CodeBlock` under **Display**, `HowToSteps` under **Surfaces** — with their props rows, thirty-five demos, seven cards in the component gallery, and their blocks on the sample screen.
- The sidebar and page-layout demos draw their navigation as plain text links rather than as a bordered `List`, which is what a navigation rail is; the header demos' links lose their underline, which is the case `TextLink`'s three-way `underline` prop exists for.
- `CLAUDE.md` records the one deliberate exception to the stylesheet's marginal cost: CodeBlock's eight ported themes are 0.8 kB gzipped that everybody carries and only a CodeBlock user sees. Shipping them as tree-shakeable JS token objects was the alternative and was rejected, because it costs both the string prop and the consumer's own theme.

## 1.7.0 (2026-08-27)

A release about what lands in your bundle. Nothing about how a component looks or behaves has changed; what changed is how much of the library you have to take to get one of them.

Measured with a real bundler rather than reported from an `unpackedSize` — rollup and terser, `react` external, judged on gzip:

| What you import               | 1.6.0    | 1.7.0    |
| ----------------------------- | -------- | -------- |
| `Chip`                        | 14.5 kB  | 3.0 kB   |
| `LineChart`                   | 22.8 kB  | 11.0 kB  |
| 12 components — a typical app | 79.8 kB  | 67.0 kB  |
| 25 components — a large one   | 124.4 kB | 110.8 kB |
| all 117 exports               | 218.7 kB | 206.8 kB |

The last row is the least interesting one, and that is the point: taking the whole library is barely cheaper, because nothing was removed. What changed is the price of taking a _part_ — and the reason `Chip` used to cost fourteen kilobytes was never `Chip`.

### Changed

- **Languages are registered rather than shipped.** Neba speaks English out of the box and the other eighteen languages are now modules you turn on:

  ```tsx
  import { registerMessages, ko } from 'neba/locales';

  registerMessages('ko', ko);
  ```

  Call it once at module scope, before your first render, for each language you support; then a `locale` prop translates exactly as it did.

  **This is a breaking change in a minor release**, which is deliberate given how few projects are on Neba today, and it is the only one here. A project that passes `locale` and registers nothing will see English where it used to see a translation — the strings still resolve, they just resolve to the fallback. If you pass a `locale` anywhere, add the two lines above and you are done. Everything else is unchanged: tags are still matched by script, then region, then language, so registering `ko` answers `ko-KR` and `zhHans` registered as `zh-hans` answers `zh-CN` and a bare `zh`; a language still fills in only what it has and English answers for the rest; and every string a component invents still has a prop that overrides it.

  The reason is arithmetic. Eighteen languages of sixteen namespaces was one object literal, and a bundler cannot drop a key out of an object literal — so a `Chip` that wanted the word "Remove" carried the ColorPicker's colour names and the Table's column labels in eighteen languages. Registered, a language costs about 1.7 kB gzipped and you pay for the ones you name.

- `severityIcons` is now `severityIcon(color)` internally, so a component that draws one severity mark carries one, and no React elements are built at import time for a page that may draw none.

### Added

- **Every component is its own entry point**, named after its folder: `import { Button } from 'neba/button'`, `import { TextField } from 'neba/text-field'`. The bundle is the same as the barrel's — `import { Button } from 'neba'` already tree-shook correctly — but the barrel makes a bundler parse two hundred modules to keep five, and the subpath makes it parse five. It is also the escape hatch if your bundler ignores `sideEffects`.
- `neba/locales` for the barrel and `neba/locales/ko` for one language, plus the `NebaLocale` type for a translation of your own.
- `neba/package.json` is exported, which some tooling asks for.
- `npm run size` — a bundle-size budget. Seven scenarios, from one component to all of them, bundled against `dist/` and checked against the numbers committed in `scripts/bundle-budget.json`. It runs as its own CI job, so a change that quietly stops something being tree-shakeable fails a pull request instead of shipping. `npm run size:update` records a new budget when the growth is real and wanted.

### Fixed

- **The package can be imported by Node, and by TypeScript on `moduleResolution: node16`.** Emitted ESM used extensionless relative imports (`export * from './types'`), which Node's resolver rejects outright and which TypeScript on `node16` or `nodenext` reported as _"Module 'neba' has no exported member"_ — for every component at once. Anything using a bundler was unaffected, which is why it went unnoticed. Every relative specifier now carries its `.js`.
- The published files now carry `@__PURE__` annotations, so a bundler can drop the parts of a multi-component module you did not import. They are written into `dist/` during the build and terser is told to keep them, which it does not do by default — until now the annotations reached the consumer's bundler stripped, and it kept `Tab` and `TabPanel` for anyone who imported only `Tabs`. `Tabs` on its own is 23% smaller.

### Documentation

- The README gains a **Languages** section and the subpath import form; `CLAUDE.md` gains a **Packaging, bundle size and tree-shaking** section with the measurements, the five invariants that hold them in place, and the list of things measured and rejected so they are not tried again — minifier tuning, per-component stylesheets, and dropping Tailwind's `@property` fallback.
- `test/package/resolution.test.ts` and `test/locales/register.test.tsx` are new. Neither renders a component: the first checks the wiring between `src/`, `dist/` and `package.json` that no render test or `tsc --noEmit` can see, and the second checks the registration contract.

## 1.6.0 (2026-08-24)

### Added

- **`ScrollZone`.** A strip of anything laid out in one direction and scrolled in it — a rail of cards, a row of chips, a column of rows. `orientation` decides which way it runs, `lines` how many rows it fills before starting a new column, so one scroll can hold twice as much in the same width, and `spacing` is the gutter on the same Tailwind scale `GridContainer` uses. The mechanism underneath is an ordinary scroll container, which is the whole design: touch, the wheel, the scrollbar and the arrow keys are the browser's own, nothing is transformed, and the strip runs the other way under RTL without being told.
- **What a press of its buttons does is a prop.** `mode` is `item` (with `step` for more than one at a time), `page`, or `hold` — which scrolls at `speed` pixels a second for as long as the button is down, and falls back to one item on a press too short to be a hold, so a quick tap is never a dead press. `buttons` draws them only when there is somewhere to go, always (with the useless one disabled), or never. `buttonPlacement` decides whether they sit over the strip or beside it: `inline` stops the scroller where the button starts, so an item is cut off at its edge rather than sliding under it, and the lane is kept even while that button has nowhere to go. `drag` adds a mouse and pen drag to the finger's; `snap` brings the nearest child to the leading edge whenever the scrolling stops.
- **`FloatingBottomNavigation`.** `BottomNavigation` lifted off the page: the same `<nav>`, the same `aria-current`, and the same `BottomNavigationItem` children, which is why the item's context moved to `internal/` — two bars provide it and one item reads it. What differs is everything that follows from `offset`, the gap it floats above the bottom edge: the sheet is a stadium rather than a bar with two corners, it is only as wide as its destinations, it carries a shadow, `position` gains `absolute` for a bar that belongs to a region rather than to the window, and `labels` defaults to `selected`, because five drawn names would stretch it back into a bar.
- **Its highlight belongs to the bar rather than to the destination that is current**, which is what gives it a position to travel: it is measured off whichever item carries `aria-current` and animates its `left`, `top`, `width` and `height` to the next one, transforming nothing. A name the bar is not drawing is _collapsed_ rather than clipped — the box it sits in runs between `0fr` and `1fr` in both axes — so pressing a destination re-shapes the bar around it: the name grows, its neighbours move over, and the highlight slides under it on one clock.
- **`WindowPane`.** Anything at all, drawn the way an operating system draws a window. It is not a real window and does not pretend to be one — there is no desktop and no z-order — but the frame _behaves_: the title bar drags, all four edges and all four corners resize, and the three buttons are real buttons with real names, so a screenshot, a feature demo or a piece of a landing page can be shown as the thing it will be rather than as a picture of it.
- **`os` is eight systems, a version being its own entry wherever the title bar is what changed.** `macos` and `macosx` (Aqua — a short striped bar, glossy lights, a bold embossed title); `windows11` (rounded corners, bar and body one Mica sheet), `windows10` (square, white, ruled off from the body), `windows8` (flat, with a band of colour around the whole window), `windows7` (Aero — a sheet of glass with the content sunk into it and the page blurred through the band as well as the caption) and `windowsxp` (Luna — the glossy blue caption curve and a band of the same blue down the sides and along the bottom); and `linux`, a GNOME header bar. The older systems paint their own chrome rather than the page's, so Luna stays blue and Aqua stays grey on a page switched to dark — the choice `Mockup`'s finishes already make. Nothing here is a copy of anything: a minimize is a line, a maximize is a box, a close is a cross, and no mark, wordmark or icon belonging to anyone else is drawn.
- `controls` is `true`, `false` or exactly the buttons named, in the system's order rather than the array's. `open`, `minimized` and `maximized` are each a controlled/uncontrolled pair: closing an uncontrolled window renders nothing, minimizing rolls it up to its title bar — a page has no dock to send it to — and maximizing fills whatever is holding the window. `draggable` and `resizable` report through `onOffsetChange` and `onResize`, with `minWidth`/`minHeight` bounding them.
- **`active` looks after itself.** Left out, a window is in front until another `WindowPane` on the page is pressed or takes the focus; a press on the page _around_ the windows changes nothing, because a paragraph is not a desktop. Being in front is drawn the way each system draws it — coloured traffic lights, an accent title bar and border on Windows 10, a tinted header bar on GNOME — and on all of them it is one step more shadow than the windows behind. `accent` dyes the title bar (and, on the systems with one, the band) with the colour family; `transparency` lets the page through the chrome and turns the acrylic on with it, never touching the content on top.
- **Maximizing, restoring and rolling up are journeys rather than cuts.** `left`, `top`, `width` and `height` are what move — never a transform, so no glyph in the window is resampled on the way — and a window that was never given a `height` is measured and pinned for one frame, because `auto` is not a length a transition can start from. A rolled-up window keeps its body in the tree, `inert` and clipped; a closed one fades before it goes; a reader who has asked for reduced motion gets every one of them instantly.
- Two new namespaces in `src/internal/i18n.ts`, translated into all eighteen locales: `scroll` for the two buttons that are an arrow and nothing else, and `window` for minimize, maximize, restore and the corner a keyboard resizes with. The × is `action.close`, which every other close button in the library already reads.
- `--neba-duration-window` — 240ms, longer than a control's 160ms because what is travelling is the whole sheet rather than a colour on one. Nothing but a window may use it.

### Documentation

- Three component pages in both locales — `ScrollZone` under **Layout**, `FloatingBottomNavigation` under **Inputs**, `WindowPane` under **Surfaces** — with their props rows, fifteen demos, three cards in the component gallery, three new blocks on the sample screen, and their entries in `llms.txt` and the README.
- The props table's name column wraps at spaces and never inside a word, which is the arrangement the type column already made with the pipes in its unions. One row of five names had been setting the width of a forty-row table; the five are their own rows now, so a reader looking for `closeLabel` finds a row called `closeLabel`.

## 1.5.0 (2026-08-12)

### Added

- **Charts.** Five components on one engine: `Sparkline`, `LineChart`, `AreaChart`, `BarChart` and `PieChart`. They take their data the way `Table` does — `series` (or, for a pie, `data`) as a prop rather than markup — and they take it in the _same_ shape as each other, so a dashboard tile can be switched from one chart to another without rewriting what feeds it. `Statistic` joins them in a new **Charts** group in the docs.
- **A `null` is a gap, not a zero,** on every one of them. A line breaks at it, an area breaks with it, a bar is not drawn and the table cell is empty; `connectNulls` bridges it for the case where the gap is an artefact of collection rather than a month in which nothing happened. A chart that renders missing data as zero reports an outage as a collapse.
- **A series' colour follows its place in the array it was passed, never its position among the visible ones** — so filtering a legend cannot repaint the survivors, and a reader who learned that Europe is blue keeps that. `series.color` overrides the slot with a `NebaColor` family or any CSS colour, and a point's own `color` overrides that for one mark.
- `LineChart` takes `curve` (`linear`, a monotone `smooth` that will not dip below a value both its neighbours are above, or `step`), `markers`, `gradient`, `connectNulls`, `valueLabels` and `stacked`. Its value axis crops to the data, because a line encodes a _position_ and cropping moves every point by the same amount.
- `AreaChart` takes the same three curves plus `stacked` — `true` for totals, `'full'` for a chart about the mix rather than the size, where the axis becomes a percentage and the tooltip and the table keep the caller's own number. Its axis keeps zero, because there the fill's thickness _is_ the magnitude. Unstacked bands are a wash that fades downward so two of them overlapping stay readable; stacked bands are a flat tint parted by two pixels of the surface rather than by a stroke.
- `BarChart` takes `orientation` — `horizontal` is the right answer whenever the category names are words — plus `stacked` (`true` / `'full'`), `rounded`, `barSize` and `valueLabels`. Corners are cut off the **data end** only; a rounded foot makes the axis look scalloped. Bars grow from where zero is rather than from the bottom of the plot, so a negative bar starts on the same line as its neighbours.
- `PieChart` takes `shape` — `pie`, `donut` or a `semi` circle — plus `center` for what goes in the hole, and `valueLabels` for each slice's share, drawn only where the text fits with room on both sides and dropped rather than clipped where it does not.
- `Sparkline` is not a small chart: no axes, no grid, no legend, and no numbers, because every number it could label is one the sentence around it already has. `shape` is a line, an area or bars; `endDot`, `baseline`, `min` and `max` are the rest of it. It fills itself with its own range, which is what makes it legible at twenty pixels tall — and why two of them are only comparable when both are given the same `min` and `max`.
- **A hidden table under every chart, always.** The drawing is `aria-hidden` and the data is rendered as a visually clipped `<table>` captioned with `label`, so no value is reachable only by pointer. The plot itself is focusable: `←`/`→` step the crosshair between categories, `Home`/`End` jump to the ends, `Escape` clears it, and the tooltip is a live region. The legend is a list of `aria-pressed` buttons, so which series are drawn is stated rather than implied by colour.
- **Eight new colour tokens, `--neba-chart-1` … `--neba-chart-8`, per theme** — and the one place in the library where a colour is not a semantic role, because a series is an _entity_ and nothing about it means success or danger. They were solved rather than picked: every step inside the OKLCH lightness band, chroma above the floor where a hue stops carrying identity, every adjacent pair at least ΔE 8 apart in OKLab under simulated protanopia and deuteranopia (measured at 13.6 light and 14.5 dark), and every slot above 4:1 on white and 5.3:1 on the dark sheet. Dark is re-solved against the dark surface rather than lightened from the light values. Slots are handed out in order and never cycled: a ninth series is an "Other" row or a second chart, not a ninth hue.
- `--neba-chart-grid`, `--neba-chart-axis`, `--neba-chart-baseline` and `--neba-chart-gap` — the chart's chrome, derived from `--neba-border` and `--neba-surface` so a chart's rules and a Card's dividers are one family of line. Gridlines are solid hairlines: a dashed grid says "projection" when all it is is a grid.
- `src/types.ts` gains the vocabulary the charts share — `NebaChartSeries`, `NebaChartDatum`, `NebaChartPoint`, `NebaChartCategory`, `NebaChartAxis`, `NebaChartLegend`, `NebaChartTooltip`, `NebaChartCurve`, `NebaChartValueLabels` — for the reason `NebaSize` is there: a `series` handed to a LineChart has to be the one a BarChart takes.
- **`Collapsible`.** One section that folds, standing on its own — what an `Accordion` is a set of, for a "Show more" on a form or the detail under a row. `title`, `subtitle`, `startIcon` and `action` build the header the way `AccordionItem` does, with `action` outside the trigger so a header that both folds and holds a switch has two things to press rather than one nested in the other; `trigger` replaces the header entirely and the element passed becomes the trigger, handed the click, `aria-expanded` and the `aria-controls`. `keepMounted` and `hiddenUntilFound` decide whether a closed panel is in the DOM, the second of them so the browser's own page search can open it.
- **`Rating`.** A score as a row of stars, and two components in one skin. Choosable, it is a `role="radiogroup"` of real `<input type="radio">`s hidden under the half-stars they stand for — one tab stop for the row, arrow keys within it, `aria-checked` on the one that is taken and a value in a form submission, none of which a row of `<button>`s would have. `readOnly` renders no inputs at all and leaves one `role="img"` carrying the score as a sentence, which is why it is the one read-only in the library that does not drain the saturation: it is not a control being held still, it is the number itself. `precision` bounds what can be **picked** and never what is **drawn**, so a `value` of `4.3` stays 4.3 — an average is not a choice, and rounding it would report a different number from the one it was handed. The fraction is a filled star laid over an empty one and clipped from the inline start, so nothing is scaled and a half star fills from the right under RTL on its own.
- **`BottomNavigation`** and **`BottomNavigationItem`.** An app's main destinations, held against the bottom edge of the window — `position` defaults to `fixed` here, against the `static` everything else defaults to, because that is what the component is. It is a `<nav>` of ordinary buttons (or `<a>`s, given an `href`) with `aria-current="page"` on the one you are on, and deliberately **not** a `role="tablist"`: a tab list promises one tab stop for the set and arrow keys within it, and a bottom navigation changes the page rather than which panel of one is showing. `labels` draws every name, only the current one, or none — and a name it does not draw stays in the document, because a glyph on its own has no accessible name at all. `safeArea` holds the row clear of a phone's home indicator while the sheet still reaches the bottom of the screen.
- **`FloatingActionButton`** and **`FloatingAction`.** The one action a screen is about, floating over it. The button is a `Button` unchanged — same variants, same elevation ladder, same pointer light — started one step up the size ladder at `lg`, because this is the control that has to be found and hit with a thumb without being looked at. `extended` writes `label` beside the glyph, which is also its accessible name, so the word drawn and the word read can never differ. `position` adds `absolute` to the three CSS values `NebaPosition` has, which is what pins one inside a card or a `Mockup` rather than to the window; `corner` and `offset` place it. Given `FloatingAction` children it becomes a dial: `aria-expanded` and `aria-controls` rather than a `role="menu"` it would not honour, the actions as ordinary buttons next in the tab order, Escape closing it and handing the focus back, and a press outside putting it away.

### Documentation

- Five component pages in both locales — `Sparkline`, `LineChart`, `AreaChart`, `BarChart`, `PieChart` — with the data model written out once on the LineChart page and cross-referenced from the rest, their props rows (including tables for `NebaChartAxis`, `NebaChartLegend` and `NebaChartTooltip`), sixteen demos, a **Charts** group in the component gallery, three charts and a row of sparklines on the sample screen, and their entries in `llms.txt`.
- `Statistic` moved from **Display** to **Charts**, in both locales and in every index that names it.
- Four component pages in both locales — `Collapsible` under **Surfaces**, `Rating`, `BottomNavigation` and `FloatingActionButton` under **Inputs** — with their props rows, twenty-one demos, four cards in the component gallery, two new blocks on the sample screen, and their entries in `llms.txt` and the README.
- A `rating` namespace in `src/internal/i18n.ts`, translated into all eighteen locales: the group's name, the sentence one star is read out as, and what an unrated control says. The sentence carries both numbers rather than counting stars, because a count of stars is a plural in most languages and a fraction in none of them.

## 1.4.0 (2026-08-06)

### Added

- `Empty` — what stands where content would have been, in four slots: `icon`, `title`, `children` and `action`. It is the other half of `Skeleton`: one is the shape of something on its way, the other is the shape of something that is not coming, and a list showing neither has a blank rectangle where its answer should be.
- **The headline is defaulted rather than required**, because the version that says nothing useful is the version that gets shipped. `title` falls back to the `locale`'s way of saying that there is nothing here — a new `empty` namespace in the message table, translated into all eighteen languages the library already speaks — and `title={false}` drops it for a state that is a glyph and a sentence. `icon` defaults to an empty tray and takes any node, so an illustration or another set's glyph goes in without a wrapper; `action` holds the way out, and several of them wrap together in one row.
- `variant` defaults to `text` on this component and on no other: an empty state is nearly always already inside a Card, a Table or a panel, and a second rectangle inside the first is one rectangle too many. `outline` and `solid` are the undyed container sheet, so `color` reaches the hairline and the ring and stops — an empty state arriving in the accent colour is making a claim about content that does not exist. The root is a `role="status"` live region, which is what lets a list that empties under the reader say so; `role={undefined}` turns that off for a state that is part of the page on arrival.
- `Mockup` — a device with a screen you can put anything on. `device` is the one prop with no default and picks the machine: a `mobile`, a `tablet`, or a `desktop` that is either a `monitor` on a stand or a `laptop` on a base. `os` draws that system's own chrome — a menu bar and a floating dock, a centred taskbar, a top bar with a dock down the leading edge, a status bar with a home indicator or three navigation glyphs — and `systemUi={false}` takes all of it away. `bezel` runs from `none` (no hardware at all, just the glass) through `thin` and `standard` to `thick`, which is an older device with a forehead and a chin rather than a wider frame; `finish` is `graphite`, `silver` or `white`; `notch` is a `dynamic-island`, a `notch`, a `punch-hole` or `none`, defaulting to whatever the device would really have. `orientation` turns a handheld, and the screen, the bezel and the cut-out turn with it.
- **The screen is a viewport at the device's real resolution, not a picture scaled down.** `size` is a five-step ladder of genuine resolutions per device — a phone from 320 to 430 CSS pixels wide, a desktop from 1024 to 1920 — and `resolution` takes a `{ width, height }` pair for anything else. The whole device is then scaled once to whatever `width`/`height` come to on the page, so the same component laid out inside a phone and inside a desktop wraps differently in each. The screen is also a container named `neba-screen`, so content can answer to the device with a container query rather than to the window.
- `scroll` lets content taller than the screen scroll instead of being clipped; `wallpaper` takes any CSS `background` for what sits behind it; `time` is the clock, and the only text the chrome draws — every menu title, dock icon and tray glyph is an abstract shape, so there is nothing to translate and no other party's marks in the library. Every part of the device is `aria-hidden`, which leaves a screen reader with `children` and nothing else.
- `DataTable` — a table for a lot of rows. `Table` draws a grid; this one is a place to work, and it takes the same two props to get there: `headers` and `items`. It is compact by default (`sm`, `compact`) with its own row ladder a step below the rest of the library, `striped` takes `true`, `'odd'` or `'even'`, and the parity is counted over the whole set so it does not change as the rows are scrolled or sorted.
- **Only the rows on screen are in the DOM, and `height` is what turns that on.** Every row is `rowHeight` tall — defaulted off the `size`/`density` ladder — so the offset of a row is its index times a constant and nothing has to be measured on a scroll frame; the rows that are left out stand up as two spacer rows, which is what keeps the scrollbar honest. Without a `height` or a `maxHeight` there is nothing to measure against and every row is rendered, whatever `virtual` says; `virtual={false}` asks for that on purpose, for a table small enough that find-in-page matters more than the DOM count. Cells truncate rather than wrap, which is the price of the arithmetic.
- **Selecting is the file manager's, not the form's.** A click chooses a row and drops the rest, <kbd>Ctrl</kbd>/<kbd>⌘</kbd> adds one, <kbd>Shift</kbd> takes the run between, a drag takes the run under the pointer and scrolls when it reaches an edge, and the arrow keys do all three with the same modifiers — plus <kbd>Home</kbd>, <kbd>End</kbd>, <kbd>PageUp</kbd>, <kbd>PageDown</kbd>, <kbd>Space</kbd>, <kbd>Ctrl</kbd>+<kbd>A</kbd>, <kbd>Esc</kbd> and <kbd>Enter</kbd>. `selectionMode` is `none`, `single` or `multiple`; `checkboxes` adds a tick column and is deliberately not the default, because a column of checkboxes says the task is choosing and on most tables it is not. With a selection mode the table is a `grid` with one tab stop and `aria-activedescendant`, since a virtual row cannot hold the focus.
- `sortable` makes the headings pressable and they cycle ascending → descending → **unsorted**, because the order the rows arrived in is a state nothing else can get back to. `sortMode="multiple"` lets a Shift-click add a second key rather than replace the first. `resizable` puts a handle on each boundary; the first drag freezes every column at the width the browser had given it, so pulling one moves one, and a double-click restores it. Adjacent columns sharing a `group` string merge under one heading in a second header row.
- `paging="pages"` swaps the scroll for a footer holding the range, the number of chosen rows, a page-size `Select` and a `Pagination`; `footer` shows that bar on its own, so a scrolling table can have the count without the pages. `search` matches every column that has not set `searchable: false`, case- and accent-insensitively, and `searchable` draws the field with `toolbar` filling the rest of its bar. `manual` hands any of `'sort'`, `'filter'` and `'pages'` back to the caller — with `rowCount` for the total — so a table whose rows come from a server is the same component rather than a second one.
- The i18n table gains a `table` namespace — the search field's placeholder, the two ticks' labels, the page-size label, and the footer's count and selection sentences — in all eighteen languages. The two that carry numbers are whole templates with `{start}`, `{end}`, `{total}` and `{count}` in them rather than fragments, because what differs between languages is the order the numbers appear in.

### Fixed

- **Forcing a theme on a nested element now works in both directions.** `.dark` / `[data-theme='dark']` on an element that is not the document root was already documented, but the light values were declared on `:root` alone, so `.light` / `[data-theme='light']` inside a dark page had nothing to switch back to. The light block now carries all three selectors.
- `--neba-plate-solid`, `--neba-plate-glass` and the `--neba-shadow-1` … `--neba-shadow-4` ladder moved into the derived block. Each is a base token spread into a shadow list, and declared only on `:root` they froze to the light hairline and the light ambient inside any theme root that was not the document root.

### Documentation

- Every live preview carries a theme switch in its top corner, so a component can be read in the theme the page is not in without taking the whole site with it. Untouched previews still follow the site switch, and a preview flipped back to the page's own theme rejoins it.
- An `Empty` page in both locales with eight examples, its props rows, its demos, a card in the component gallery, a place on the sample screen beside the placeholder it is the other half of, and its entry in `llms.txt`.
- A `Mockup` page in both locales with eleven examples, its props rows, its demos, a card in the component gallery, a place on the sample screen and its entry in `llms.txt`.
- A `DataTable` page in both locales with seven examples, two props tables, its demos, a card in the component gallery, twelve thousand rows on the sample screen and its entry in `llms.txt`.
- **The nav bar and the sidebar no longer hang off the edges between 1440px and 1600px.** The site raises `--vp-layout-max-width` to 1600px, and the default theme centres the shell on the article by taking half of what the page has left over — an expression it writes out five times without a floor, because at its own 1440px it cannot come out below zero. At ours it can: the social icons sat 8px outside the viewport and the sidebar climbed over the article's left margin. All five now read one floored `--neba-gutter`, which reduces every one of them to the gutter plus nothing, the page margin, or the sidebar's width.
- `npm run docs:dev` starts in about four seconds instead of fourteen. All three `docs:*` scripts ran `npm run build` first — ten seconds of `format:fix`, `tsc` and terser that nothing then looked at, since the docs resolve `neba` to `src/index.ts` and import `src/styles.css` directly. Prettier now runs where it always did as part of `npm run build`, and CI still checks it.

## 1.3.0 (2026-08-05)

### Added

- **A sixth group, Transitions: eleven `Animate*` wrappers that make anything move.** `AnimateFade`, `AnimateGrow`, `AnimateZoom`, `AnimateSlide`, `AnimateRotate` and `AnimateBlink` are the six named effects; `AnimateAppear`, `AnimateTyping`, `AnimateLighting`, `AnimateMarquee` and `AnimateHeadline` are the five that have to understand what their children are. All eleven take the same settings — `duration` and `delay` in milliseconds, `easing`, `repeat` (a count or `'infinite'`), `alternate`, `paused`, and `trigger`: `mount`, `visible` (with `once` and `threshold`), `hover`, or `manual` driven by `play`. Every one of them is switched off entirely by a `prefers-reduced-motion` preference, so none of them is ever the only thing carrying a message.
- **A `transition` prop on the components that display something** — `Box`, `Card`, `Statistic`, `Alert`, `Chip`, `Avatar`, `Icon`, `Typography` and `Blockquote`. `transition="fade"` is an entrance run once on mount, and the object form takes the details: `{ type: 'slide', from: 'left', duration: 500 }`. It is offered on no component that is pressed, because a control that moves under the pointer aiming at it is the one thing the design language rules out. Anything past a mount — a replay, a scroll trigger, a hover — is an `Animate*` component, and any component can be wrapped in one.
- `ColorPicker` — a colour chosen by eye: a saturation square, a hue rail, an optional opacity rail, a field for typing a value in, and a grid of swatches. `format` decides whether the value comes back as hex, `rgb()` or `hsl()`; `alpha` adds the fourth channel; `swatches` replaces the built-in set with the colours a product actually uses; `inline` draws the panel into the page instead of into a popup. It reads hex in all four lengths, `rgb()`/`rgba()` and `hsl()`/`hsla()` in both syntaxes, and it adds no dependency — the conversions are a hundred lines of arithmetic in `internal/color.ts`.
- The i18n table gains a `color` namespace, so the picker's square, rails, field and swatch grid — none of which have any text on them — are named in all nineteen languages. `locale` picks the language and `labels` overrides any one of them.

### Documentation

- Pages for `ColorPicker` and the eleven `Animate*` components in both locales, their props rows, their demos, cards in the component gallery, a place on the sample screen, and their entries in `llms.txt`.
- **Prop conventions gains a Motion section**, which is where the shared animation vocabulary and the rule about which components take `transition` are written down.

## 1.2.0 (2026-08-01)

### Added

- Eight components, bringing the library to fifty-seven: `Avatar`, `Breadcrumb` (with `BreadcrumbItem`), `ChatBubble`, `OtpField`, `Panes` (with `Pane`), `Spoiler`, `TextLink` and `TreeView` (with `TreeItem`). `Panes` opens a fifth group, **Layout**, alongside `Container` and `Grid`.
- **The library speaks nineteen languages on its own behalf.** Almost nothing in Neba writes text a reader sees — a Button says whatever it was handed — but a few components have to invent a string because there is nowhere else for it to come from: the sentence read out after a link that opens a new tab, the label on the button that uncovers a `Spoiler`, the word under a chat message that says it was read. Those are now one table rather than eight English defaults. `TextLink`, `Spoiler` and `ChatBubble` take a `locale`, and every string still has an override prop of its own, so an unsupported language is never a dead end. A tag resolves by script, then by region, then by language (`zh-Hant-TW` → `zh-hant`, `pt-BR` → `pt`), and a translation that fills in part of the table falls back to English one namespace at a time rather than leaving blanks.
- `Avatar` — an image that falls back to initials, to a glyph, or to a silhouette, so the slot is never an empty box. `shape` is `circle` or `square`, `delay` holds the fallback back long enough for a cached image not to flash it, and `onLoadingStatusChange` reports `idle` / `loading` / `loaded` / `error`.
- `Breadcrumb` — a trail that collapses in the middle when it is too long: `maxItems`, `itemsBeforeCollapse` and `itemsAfterCollapse` decide where, and `expandable` makes the ellipsis a button that opens the rest in place. `separator` takes `chevron`, `arrow`, `slash`, `dot` or a node of your own.
- `ChatBubble` — one message in a conversation. The avatar, the name, the time, the delivery mark, the media and the link card are each drawn only when given something, so the same component is a bare bubble or a full row. `status` runs `sending` → `sent` → `delivered` → `read`, plus `failed`; `typing` draws three dots that change colour rather than bounce.
- `OtpField` — a one-time code as one field per character. `length`, `charset` (`numeric`, `alpha`, `alphanumeric`, `any`), `mask`, and `groupSize` with a `separator` for codes written in blocks. `onComplete` fires when the last box is filled, `autoSubmit` submits the form it is in, and `onValueInvalid` reports what was rejected.
- `Panes` — regions with a draggable bar between each pair, horizontal or vertical. Each `Pane` takes `defaultSize`, `minSize` and `maxSize` as a number of pixels or any CSS length; `resizable` turns the bars off, and `onResize` / `onResizeEnd` report the split.
- `Spoiler` — content covered by a blur rather than removed, so a reader can see that something is there without reading it by accident. Controlled with `revealed` / `defaultRevealed` / `onRevealedChange`; `reversible` allows covering it again, `maxHeight` clamps it to a fade-out instead, and `blur` is the radius.
- `TextLink` — a link with no surface of its own. `underline` is `always`, `hover` or `none`, `newTab` adds the mark and the sentence a screen reader needs, `icon` overrides or drops that mark, and `render` swaps in a router's own link component.
- `TreeView` — a tree with roving focus, controlled `expanded` and `selected`, and `multiple` for checkbox-style selection. `lines` draws the guides as `none`, `simple` or `folder` — the rail runs past an expanded subtree to the next sibling and stops halfway down the last child, the way a file manager draws it, and mirrors under RTL without a second rule.

### Changed

- **The Examples section is four pages, not one.** `/examples/` no longer resolves to a page — the overview moved to [`/examples/overview`](https://neba.cdget.com/examples/overview) and three concept screens joined it. Any link you have to `/examples/` needs updating.
- The stylesheet carries a `.neba-link` rule, written as `.neba-link.neba-link` so that a host's `.prose a` or `.vp-doc a` cannot outrank the link's underline thickness, offset and colour. Like `neba-portal`, the class is a hook you can exempt from your own typography rules.

### Fixed

- The date formatter cache joined a locale and its options with a space, which is a character both halves of the key can contain. Two different requests could land on one entry and the second would be formatted with the first's options. The separator is now one that cannot appear in either.

### Documentation

- **Three concept screens**, each a whole fictional product page built only out of the library: a [landing page](https://neba.cdget.com/examples/concept-landing), an [admin dashboard](https://neba.cdget.com/examples/concept-dashboard) and a [sign-up flow](https://neba.cdget.com/examples/concept-signup).
- The home page now says what the library is rather than how it is drawn — what ships, what is tested, and what an install actually gets you.
- **Every page carries its own description.** A page's lede is read out of the source and becomes its `<meta name="description">`, so pages no longer share one sentence between them. Canonical URLs, an `hreflang` pair per locale with an `x-default`, Open Graph and Twitter cards, JSON-LD on the home page, and a `robots.txt` naming the sitemap are generated in the build.
- **A preview mounts when it is scrolled into view**, not when the page loads. A component page holds a dozen of them, and mounting all at once put the one being read behind chunks for previews far below the fold. The empty box reserves its height before and after, so nothing jumps.
- New icons and social image at 128 and 256 px, an `apple-touch-icon`, and a `theme-color`.
- Pages for the eight new components in both locales, their props rows, their demos, and their entries in `llms.txt`.

## 1.1.0 (2026-07-29)

### Setup

- **`neba/styles.css` now ships compiled.** It carries the design tokens, the real rules for every utility class the components use, and a small reset — so the whole setup is `npm install neba` and one `@import`. Tailwind is no longer a requirement on your side; it builds this package and stays a devDependency of it. About 13 kB gzipped.
- **New export: `neba/tailwind.css`.** The token sheet, for a project that already runs Tailwind v4 — it registers the package as a Tailwind source, so your own build generates the components' utilities in the same pass as your app's and a `className` you pass to a component sorts correctly against the component's own classes. If you were on the previous two-line setup, this is the line to switch to:

  ```css
  @import 'tailwindcss';
  @import 'neba/tailwind.css'; /* was: neba/styles.css */
  ```

- **The bundled reset** is Tailwind's Preflight cut down to what the components actually need — `box-sizing`, font inheritance on form controls, list markers off. It does not touch the typography of your paragraphs, headings or links, and every rule is wrapped in `:where()`, so a single type selector of your own beats it whatever the import order. It is in `neba/styles.css` only; the Tailwind path has Preflight already.
- **`react` and `react-dom` are now declared as `peerDependencies`** (`^18.0.0 || ^19.0.0`) rather than only as devDependencies, so the requirement is stated where a package manager can check it. `@types/react` is an optional peer for TypeScript consumers.

### Added

- Eighteen components: `Blockquote`, `Carousel`, `Container`, `DatePicker`, `DateRangePicker`, `DateTimePicker`, `Grid`, `GridContainer`, `Highlight`, `Icon`, `IconButton`, `Pill`, `SegmentedButton` (with `Segment`), `Shortcut`, `Statistic`, `TimePicker`, `Timeline` (with `TimelineItem`) and `Toolbar`.
- Shared types for the new layout and date work: `NebaPosition`, `NebaBreakpoint`, `NebaResponsive<T>`, `NebaWeekday`, `NebaJustifyContent`, `NebaAlignItems` and `NebaAlignSelf`.
- `Divider` takes a `thickness`, as a number of pixels or any CSS length.
- `Pill` takes `elevation`, `startIcon` / `endIcon`, `title` / `description` / `details`, `expanded` and `position`.
- `llms.txt`, for agents reading the documentation site.

### Changed

- `Select`, `DatePicker` and `DateRangePicker` hold their trigger at the width of the longest thing it could say. Choosing a shorter option no longer shrinks the field out from under the pointer that just used it.
- `Checkbox` and `RadioGroup` drop the white plate highlight. A 1px hairline is light on a cut edge at 32px and a bevel at 18px; the acrylic surface stays, only the highlight goes.
- A highlighted row in a `Select` or `Combobox` popup now takes the accent text colour as well as the soft background.

### Fixed

- `Select` and `Combobox` popups render through a portal, outside the element their `--n-*` slots were declared on, which left every `var()` in them with nothing to resolve to: a `currentColor` hairline instead of the family's, a transparent surface, and a highlighted row that did not light at all. The slots are now set on the popup itself.
- A field at the top or bottom of a scrolling `Dialog` body had its focus ring sliced off by the scroll container. The body without `dividers` now reserves the 4px the ring is drawn in and gives the space straight back, so nothing on the sheet moves.
- `Pagination` keyed its buttons by page number, so recentring the window moved the DOM nodes and the button under the pointer became a different element — its hover bloom faded out while a fresh neighbour's faded in from a centre it had no pointer position for. The row is keyed by slot now.
- `Combobox`'s input stretches to the height of the row it sits on rather than to a fixed `1lh`, which put the placeholder a pixel or two above the chips beside it.

### Documentation

- The sidebar is four sections — Guide, Components, Design and Discover more — with the component groups kept as headings inside Components, and the index page as an entry of its own rather than as the heading's link.
- The design pages moved from `guide/` to `design/`.
- This changelog is published at [/changelog](https://neba.cdget.com/changelog) in both locales.

## 1.0.0 (2026-07-26)

- First release

## 0.0.1 (2025-12-08 / Alpha)

- Alpha release (Not tested. Do not use production.)

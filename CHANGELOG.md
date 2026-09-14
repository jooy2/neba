# Changelog

## vNext (2026--)

### Breaking changes

- **A lone `width` or `height` on an `Image` sizes its box.** One dimension is not a proportion, so it used to reach the `<img>` and change nothing on the page. `height={200}` is now a box 200 pixels tall across the width it is given, and `width={320}` one 320 wide, capped at the container, with `fit` deciding what the picture does inside. A number is pixels and a string a CSS length, and beside a `ratio` a lone `height` takes its width from the ratio. An `Image` given only one of the two as a hint about the file draws at that size now: pass both, or remove the one. Both together still reserve their proportion, as before.

- **A `Gallery` loads its tiles lazily.** Every tile's picture is `loading="lazy"` unless the Gallery says otherwise, so a wall of forty photographs asks for the few a reader can see rather than all forty at once. A Gallery that is the largest thing above the fold should pass `loading="eager"`, or its first row arrives later than it did.

- **A `Form` without `onSubmit` lets the submit go ahead.** It prevented the native submit whether or not anybody was given the values, and React skips a function `action` for a prevented submit, so `<Form action={formAction}>` did nothing. Validation still runs first and still stops an invalid submit. A `Form` that relied on never navigating with no `onSubmit` should pass `onSubmit` or an `action`.

- **A disabled `MenuItem` or `NavigationMenuItem` with an `href` is no longer a link.** Both ignored `disabled` once they had an `href`, so the row was drawn as available and pressing it navigated. While disabled it renders as a disabled row, with no `<a>` and no `href`; a test that found it by the `link` role finds a `menuitem`, or plain text in a navigation menu.

- **A `DataTable` sorted descending puts rows with no value last.** A blank, `null`, `undefined` or `NaN` cell went last in an ascending sort and was reversed to the top of a descending one, so the first screen of a column sorted high-to-low could be all blanks. Blanks now go last in both directions, which was always the stated intent. A column with its own `compare` orders its blanks itself, as before.

- **A `TextLink` with a `target` of its own is announced as opening elsewhere.** The spoken "(opens in a new tab)" came only with `newTab`, so `target="_blank"` written by hand opened a new tab without a word to a screen reader. The sentence now follows any target that leaves this tab, which changes the link's accessible name: a test that finds it by name needs the sentence added. The glyph still comes only with `newTab` or `icon`.

- **A picker's trigger is named by its label and what it shows.** `DatePicker`, `DateRangePicker`, `TimePicker`, `DateTimePicker`, `TreeSelect` and `ColorPicker` named the trigger by `label` alone, which covered the date, the time or the choice written on it, so a screen reader said "Ships on, button" whatever had been picked. The name is now the label followed by the trigger's own text — "Ships on Jul 30, 2026". A test that finds the trigger by its exact label needs the value added, or `exact: false`.

- **A calendar's month and year buttons are named by what they show.** They were named "Choose a month" and "Choose a year" over the words "July" and "2026", so a reader using voice control could not say what they saw to press them. They are named by their text now and described by what they do, which changes their accessible names: a test that found `name: 'Choose a month'` finds the month on screen. This covers `Calendar` and every date picker.

- **A `FilePicker`'s button is named by its `label`.** The label was drawn above the box and tied to nothing, so a form asking for a résumé and a cover letter had two buttons both called "Drop files here, or click to browse". The button is now named by the label followed by what the box says. A test that finds the box by its title alone needs the label added, or `exact: false`.

- **A `Fieldset`'s `description` describes the group instead of joining its name.** It was drawn inside the legend, so the group was named "Billing address Where the card statement goes." and that sentence was read before every control in it. The legend alone names the group now, and the description is tied to it with `aria-describedby`, merged with any the caller passes. A test that found the group by the whole sentence finds it by the legend.

- **A pressable `Chip` is a toggle only when it says whether it is on.** `selected` defaulted to `false`, so every chip with an `onClick` carried `aria-pressed="false"` and was announced as a toggle that was off, including a chip that only opened something. It is a plain button now unless `selected` is passed, and `selected={false}` still makes it a toggle. A test that expected `aria-pressed="false"` on a chip with no `selected` needs the prop.

- **An `AccordionItem`'s `action` sits beside its heading instead of inside it.** The action was rendered in the `<h3>`, so a section with a Switch in its header was a heading named "Billing Enable", and every heading list read the control's label as part of the title. The heading holds only the trigger now, and the action is its sibling in the same row. Nothing moves on screen; a test that found the heading by title and action together finds it by the title.

- **A closed `Accordion` or `Collapsible` panel stays in the document.** `hiddenUntilFound` is on by default. A closed panel used to leave the DOM, so an FAQ's answers were missing from a server render and from a crawler's index, and the browser's find-on-page could not reach them. A closed panel is now `hidden="until-found"`: out of sight, the tab order and the accessibility tree as before, and opened when a page search lands in it. A test that asserted a closed panel's text is absent should assert it is not visible, and a panel too expensive to build while closed can pass `hiddenUntilFound={false}`. `Tabs` keeps its default; its docs now say to set `keepMounted` on a panel whose content should be indexed.

- **A `NavigationMenu` panel's links are in the page before it opens.** A panel was created only when a pointer or a key first opened it, so its links were missing from a server render and a crawler never followed them, although the component is the one meant to put a site's destinations in a crawler's index. Each `NavigationMenuItem` now renders its panel hidden from the start, and `keepMounted={false}` restores the old behaviour for a panel that is expensive to build. A test that asserted a panel link is absent before opening should assert it is not visible.

- **A `Pagination` stepper keeps the focus when the press runs it out.** Pressing Next onto the last page made the button `disabled`, and with `getPageHref` and `onPageChange` it swapped the link for a button, so either way the focus fell to the document and a keyboard reader started again from the top. A stepper with nowhere to go, and the current page, stay where they are with `aria-disabled`; a link loses only its `href`. A test that asserted `toBeDisabled()` on such a stepper should assert `aria-disabled="true"`, and with `getPageHref` the current page and an exhausted stepper are found by the `link` role.

- **A `Carousel` arrow keeps the focus when the press runs it out.** With `loop={false}`, pressing Next onto the last slide made the arrow `disabled`, which dropped the focus onto the document, and the blur that caused restarted an auto-playing carousel the focus had paused. The arrow stays in place with `aria-disabled`; a test that asserted `toBeDisabled()` on it should assert `aria-disabled="true"`.

- **A `ScrollZone` button keeps the focus when the press reaches the end.** The button with nowhere to go became `disabled`, or under `buttons="auto"` with overlaid buttons was removed outright, and either way the focus fell to the document. It is now `aria-disabled`, and an overlaid one stays until the focus leaves it. A test that asserted `toBeDisabled()` on it should assert `aria-disabled="true"`.

- **`HowToSteps`' Previous and Next keep the focus at the ends.** Pressing Previous onto the first step, or Next onto the last with `completion={false}`, made the button `disabled` and dropped the focus onto the document. Both stay in place with `aria-disabled`; a test that asserted `toBeDisabled()` on them should assert `aria-disabled="true"`.

- **A confirm is an alert dialog that opens a destructive question on Cancel.** `useConfirm` rendered a plain `role="dialog"` and put the focus on the confirming button whatever was asked, so for `color: 'danger'` the Enter that raised the question was one more Enter from the loss. The sheet is `role="alertdialog"` now, a `danger` question opens on the cancelling button, and the focus goes back to what asked once the last queued question is answered; it could be lost there before, because the confirming button took the focus as the sheet mounted. A test that found the sheet by the `dialog` role finds it by `alertdialog`.

- **A `CodeBlock` scrolls as a region only when there is something to scroll.** Every block was a named `role="region"` and a tab stop, so a page of thirty short snippets had thirty landmarks and thirty stops on the way through it. The box is measured now, and only code wider or taller than it is a focusable, named region. A test that found a short block by the `region` role finds it by its text or its toolbar.

- **A captioned `Gallery` tile is named by its caption, and a hover caption shows on a touch screen.** A tile's button was named "alt — Image 1 of 12" whatever was written on it, so a voice-control user saying the caption they could see pressed nothing, and `caption="hover"` never appeared on a device that cannot hover. A tile with a caption drawn is now named by its title and its place in the set, described by its description, and a hover caption is always up where there is no hover. A tile with no caption keeps the `alt`; a test that found a captioned tile by its `alt` finds it by its title.

- **A `DataTable` without a selection can be worked from the keyboard.** With `selectionMode="none"` the table took no focus, so `onRowActivate` answered only a double-click and an editable cell opened only on one. A table whose rows open something or whose cells edit is now a `grid` with a tab stop: the arrows move an active row without choosing it, Enter calls `onRowActivate`, and F2 edits the first editable cell of the row, in every selection mode. Enter and Escape in an editor hand the focus back to the table. A test that found such a table by the `table` role finds it by `grid`.

- **`AnimateCounter` no longer takes `paused`.** It came with the props every `Animate*` shares, and a count ignored it: nothing held the number, so `paused` type-checked and did nothing. It is gone from the type; hold a count with `trigger="manual"` and `play`. A counter that passed `paused` fails to compile and can drop it with no change in behaviour.

- **`AnimateLighting` no longer takes `easing`.** The arc travels on a pseudo-element at a constant rate, so `easing` type-checked and changed nothing. It is gone from the type; a lighting that passed it fails to compile and can drop it with no change in behaviour. The props tables of `AnimateScramble`, `AnimateTyping` and `AnimateHeadline` also stop listing `easing` and `alternate` where their types never took them, and `repeat` on a Scramble and a Headline is described as what it actually decides.

- **A `Skeleton` given a `label` says it.** A labelled skeleton was a `role="status"` with `aria-busy="true"` and the label as its `aria-label`. `aria-busy` tells a screen reader to hold a region's changes back until it clears, and a live region is announced by what it holds rather than by its name, so neither half reached the reader. The status now holds the label as visually hidden text and carries no `aria-busy`. A test that found it with `getByRole('status', { name })` should look for the text inside it.

- **An `Overlay` with no `label` is named "Loading".** The default name was the word "Overlay", so the common case — a sheet holding only a spinner — was announced as "Overlay, dialog", which says nothing about why the page went out of reach. The default is the locale's word for "Loading" now, in all eighteen registered languages. A test that found an unlabelled overlay by the name "Overlay" should use "Loading", and an overlay that means something else should pass `label`.

- **A labelled `GaugeChart` is a `meter`.** It was a `role="img"` named "label: value / max", so a dial from `-50` to `50` reading `0` was announced as "0 / 50" and its `caption` was never read. It is now `role="meter"` named by `label`, with `aria-valuenow`, `aria-valuemin` and `aria-valuemax`, and an `aria-valuetext` of the reading followed by a text caption. A dial with no reading stays a `role="img"` named by its label. A test that found the dial with `getByRole('img', { name: 'CPU: 64 / 100' })` finds it with `getByRole('meter', { name: 'CPU' })`.

- **A link whose address uses a scheme other than `http`, `https`, `mailto` or `tel` is written with no `href`.** A ChatBubble's `preview.url` and every other `href` a component takes went into the DOM as they were, and React 18, which the peer range includes, writes a `javascript:` URL unchanged, so a preview built from another user's message could run a script when pressed. `TextLink`, `MenuItem`, `NavigationMenuLink`, `NavigationMenuItem`, `ListItem`, `TreeItem`, `BreadcrumbItem`, `BottomNavigationItem`, `AppLogo`, `Anchor`, `Pagination`'s `getPageHref` and `ChatBubble`'s preview now pass it through one check, which reads the scheme the way a browser does. A relative address, a `#fragment` and a `//host` are kept. An address with another scheme is dropped: a component that switches between a link and a button draws the button, and one that is always a link draws an `<a>` with no `href`. A link to a custom scheme such as `sms:` or an app's own should be written as a plain `<a>` through `render`.

- **A `FloatingActionButton`'s `className` and `style` go on the button.** `className` landed on the box pinned to the corner, so a class meant for the button styled the invisible frame around it, and the button's own inline radius had nothing a caller could merge with. Both now go on the button, with `style` merged over the round radius instead of replacing it, and the box in the corner takes its classes through the new `classNames.frame`. A caller who positioned or spaced the box with `className` should move those classes to `classNames.frame`; every other `<div>` attribute still goes to the box.

- **A chart axis's `tickFormat` returns a string or a number.** It was typed to return any `ReactNode`, but a tick is SVG text and the result went through `String()`, so a callback that handed back an element type-checked and drew `[object Object]` on the axis. The type now says what the axis can write. A `tickFormat` returning JSX stops compiling, and should return the text instead.

- **An `Image` and a `Stack` draw only `<span>` elements, so they can sit inside a `<p>`.** An Image drew its proportion box and its loading placeholder as `<div>`s, and a Stack's root was a `<div>`, although a Markdown renderer puts an Image inside a paragraph and a pile of avatars in a line of text is what a Stack is for. A `<div>` inside a `<p>` is invalid markup, which the browser rewrites and React reports as a hydration error. Both now draw spans with the same display they had. A `Stack`'s `ref` is an `HTMLSpanElement` and its props are a `<span>`'s, so code that typed the ref as `HTMLDivElement` needs the new type.

- **`AnimateTyping`, `AnimateHeadline` and `AnimateMarquee` render a `<span>` and take `render`.** Each rendered a `<div>`, so none could sit inside a `<p>` without invalid markup and a hydration error, and a headline being typed or turned could not be a heading. Each now renders a `<span>` with the display it had, and `render` puts it on another element: `<AnimateHeadline render={<h2 />}>`. The `ref` of all three is an `HTMLElement` and their props are a `<span>`'s, so code that typed the ref as `HTMLDivElement` needs the new type.

- **A `DateRangePicker` reports a range only once it has both ends, and keeps the old one until then.** The first press called `onValueChange` with `{ start, end: null }`, so the range that had been chosen was gone as soon as a new start was pressed, and closing the popup before the second press left the half range as the value, although the docs said it was thrown away. The first press now only marks the start, the value changes once when the second end is chosen, and closing early keeps the range that was there. A caller that acted on the half-range call gets no call until the range is complete.

- **A `Badge` with no `content` draws its dot.** Leaving `content` out was documented to draw a dot, and the dot was drawn with `invisible` and `aria-hidden`, so a status marker such as `<Badge color="success"><Avatar /></Badge>` never appeared. It is now a visible dot, hidden from a screen reader only when it has no `label` to read. A `content` of `0` is still hidden unless `showZero` is passed, and a caller who relied on an empty Badge drawing nothing should pass `invisible`.

- **An `Image` with `preview` puts `className` and `style` on the button.** They landed on the picture inside it, so the button spanned the whole line beside a smaller picture and pressing the empty space opened the preview. A caller who styled that inner element with `preview` on now styles the button; a frame's own look stays on `classNames.frame`.

### Where the bytes went

`Image` is 7.1 kB → 8.6 kB and `Gallery` 10.4 kB → 11.4 kB, gzipped with `react` external. The 1.5 kB is the props above, and all of it is in `Image` itself: the quarter-turn layout and its preview box, the `position` reader that follows a turn and a mirror, the blurred letterbox, the picture stand-in and its object URL.

### Added

- **`Image` turns and mirrors a picture with `rotate` and `flip`.** `rotate` takes quarter turns, clockwise, and `flip` mirrors along the axes the picture is shown on, so `flip="horizontal"` swaps left and right whether or not the picture was turned. A picture on its side reserves a box on its side: `width` and `height` still describe the file, and with neither the box takes the turned shape once the file arrives. The preview opens turned and mirrored the same way.

- **`fit` takes `scale-down` on `AspectRatio` and `Image`.** It is `contain` that never enlarges, for a file that may be smaller than the box it is given.

- **`Image` takes `position`.** It is `object-position`: which part of the picture a `cover` crop keeps, and where `contain`, `none` and `scale-down` leave their empty space. It takes a side, a corner, `center` or two percentages, and is read on the picture as it is shown, so `position="top"` keeps the top the reader sees through `rotate` and `flip`.

- **`Image` takes `letterbox`.** It fills the part of the box `contain`, `none` or `scale-down` leave empty: `blur` lays the same picture behind it, covering the box and blurred, and any other string is a CSS `background`. The blurred copy is the same file rather than a second download, follows `position`, `rotate`, `flip` and `filter`, and is only drawn under a `fit` that can leave space.

- **An `Image`'s `placeholder` can be a picture.** `placeholder={{ src }}` stands a URL, a data URI or a `Blob` in for the file while it arrives, drawn with the same `fit`, `position`, `rotate` and `flip`, and `blur` softens a copy stretched up from a few pixels. A Blob is shown through an object URL that is released when the stand-in goes. The picture fades in over the stand-in, which is taken away once that fade has run.

- **`Image` takes `priority`.** It is for the picture a page is judged by, usually its Largest Contentful Paint: `loading="eager"` and a high fetch priority together, with an attribute written out still winning. `fetchpriority` is spelled the way the installed React accepts it, so neither React 18 nor React 19 warns.

- **`Gallery` passes the new `Image` props on.** An item takes `rotate`, `flip`, `position` and a `placeholder`, and the Gallery takes `fit`, `letterbox` and `loading` for every tile. An item's `ratio` stays the file's own: a turned item is laid out on its side by `masonry` and `justified`, and opens turned in the viewer.

- **`TreeItem` takes `selectable`.** A row with `selectable={false}` is never chosen, and pressing it only opens and shuts its branch — the folder in a tree whose answers are the files.

- **`ToastProvider` takes `label`, `Tour` takes `closeLabel` and `Combobox` takes `openLabel`.** Each overrides a word the component otherwise takes from its `locale`: the name of the region the toast stack lives in, the × that ends a tour, and the chevron of a combobox with no string label.

- **`Button` and `IconButton` take `focusableWhenDisabled`.** A disabled button stays in the tab order, marked `aria-disabled` rather than with the `disabled` attribute, and still cannot be pressed. It is for a button that is disabled by its own press, which would otherwise hand the focus to the document.

- **`Slider` takes `getAriaLabel` and `getAriaValueText`.** The first names each thumb by its index, so a range slider's two thumbs are no longer both read by the label; the second words a thumb's value, for a unit or in place of the English Base UI reads for a range.

- **`Dialog` takes `initialFocus` and `finalFocus`.** Base UI's own options, passed to the popup: what takes the focus when the dialog opens, and where it goes when it closes.

- **`FilePicker` takes `locale`.** The sentence inside the box and the name of each remove button were English whatever the page spoke, with only a prop per string as the way out. Both come from the new `file` namespace now, which every registered language has; `title` and `removeLabel` still override them.

- **`Toolbar`, `Pill`, `Footer`, `FloatingActionButton` and `Drawer` take `safeArea`.** On a page laid out under a phone's notch and home indicator with `viewport-fit=cover`, a bar or button pinned to the edge of the screen sat underneath them. With `safeArea` on, the default, a `fixed` or `sticky` one adds the screen's `env(safe-area-inset-*)` on the edge it is held against, and an overlay `Drawer` keeps its contents inside the insets on the edges it runs to; the sheets still reach the edge of the screen. A `static` one is left alone.

- **`PageLayout` takes `main`.** With `main={false}` the content goes in a plain `<div>` rather than a `<main>`, with no `id` and no skip link, for a layout that is not the page — an app shell previewed inside the page's own layout. A `PageLayout` on a `Mockup`'s screen is off unless it passes `main`, so a device preview no longer gives the document a second `<main>`, a second `id="main"` and a second skip link.

- **A `Panes` handle is named, and says which panes it resizes.** A handle was a `role="separator"` with a value and nothing else, so a screen reader announced "separator, 50" with no word for what the number was the share of. Each handle is now named by the new `panes` namespace's "Resize panes", in all eighteen registered languages, and its `aria-controls` names the pane on either side; a pane without an `id` is given one. `handleLabel` takes a name of its own, as a string or as a function of the handle's index, and `locale` picks the language.

- **`Table` takes `maxHeight`, and `stickyHeader` sticks under it.** A Table's sheet scrolls sideways, which makes it the box its sticky header sticks to, so limiting the height on a box around the table, as the docs said to, scrolled that outer box instead and the header scrolled away with the rows. `maxHeight` limits the sheet itself, as a number of pixels or any CSS length, so the rows scroll inside it and a `stickyHeader` stays at its top.

- **`BreadcrumbItem` takes `render` and `target`.** A step with an `href` could only be an `<a>`, so every step in an app with a router reloaded the page. `render={<Link to="/projects" />}` draws the router's link with `href` passed through, and a `target` other than this tab gets `rel="noopener noreferrer"`.

### Changed

- **A `NebaProvider` with inline `defaults` no longer re-renders everything under it.** `defaults={{ size: 'sm' }}` is a new object on every render of the component around the provider, and it was handed to the context as it came, so every Neba component below re-rendered with the page even when nothing had changed. The four values are kept by value now.

- **Dragging a run of `DataTable` rows reports the selection once per row it reaches.** Every `pointermove` committed the run again, so a drag held still inside one row called `onSelectedChange` and re-rendered the table on every frame the pointer shook.

- **A grouped `DataTable` finds each row's place on the page in constant time.** Every render searched the page once per row of every group, which in a five-thousand-row grouped table without virtualisation made a single selection tens of millions of comparisons.

- **A controlled `TreeView` re-renders its rows only when something in the tree changed.** Its toggle and select handlers were rebuilt whenever the `expanded` or `selected` array or an inline callback was, which is every render in the usual way of writing a controlled tree, and each rebuild re-rendered every row.

- **`ScatterChart` and `TimelineChart` stop re-rendering for every pixel the pointer moves.** Both stored the pointer's offset on each move for a tooltip mode that only a chart of columns reads, so hovering over one mark laid the whole chart out again for every pixel of travel. They re-render when the mark under the pointer changes.

- **A chart formats, cuts and measures its category labels once rather than on every hover.** Moving the pointer across a `LineChart`, `AreaChart` or `BarChart` re-renders it for each column crossed, and every one of those re-renders ran every label through `tickFormat`, the truncation and the width estimate again, which was most of the time spent on a plot of ten thousand dates. The widest label is also found without spreading the list into `Math.max`, which threw a `RangeError` past about a hundred thousand of them.

- **`BarChart` finds a series' high and low once for `valueLabels="extremes"`.** It walked the whole series again for every bar, so a five-hundred-bar series did a quarter of a million comparisons on each render, and a hovered chart renders on every column the pointer crosses. It now asks the same question the line charts already asked once.

- **`CodeBlock` trims the end of its code in linear time.** The trailing whitespace was found with a pattern that retried every run of spaces from each position in it, so a pasted file with a long run of spaces in the middle held the page for seconds — forty thousand of them took 2.6 seconds — every time `code` changed.

- **An open `Tour` re-renders only when its target moves.** It listens to scrolling anywhere in the page, and every scroll frame handed it a new measurement even when the target had not moved, so scrolling a side panel re-rendered the tour on every frame.

- **`AnimateTyping` and `AnimateHeadline` attach a callback `ref` once.** Both wrote their ref inline, so a caller's callback ref was called with `null` and then with the node again on every render — once per character typed, and once per line turned. `AnimateMarquee` already held its ref, and the other two do the same now.

- **An endless animation holds while it is off the screen.** An `Animate*` component with `repeat="infinite"` — `AnimateLighting`, `AnimateMarquee`, `AnimateFloat`, `AnimateBlink` and the rest, and a `transition="blink"` — kept its animation, timer or paint running for as long as it was mounted, however far below the fold it sat. It now pauses when it leaves the viewport and carries on from where it was when it comes back, through one shared observer. A finite animation is untouched and still finishes on schedule.

- **A `Pill` with `details` no longer forces a layout on every render of its parent.** The details were written inline in the usual case, a new object each time, and each one re-subscribed the height observer and read the panel's height again; the observer already follows the details as they change.

- **`AnimateHeadline` holds its line under a reduced-motion preference.** It already dropped the slide, but the reel went on changing every few seconds for as long as it was on the page, which is still motion and never ends. It now stays on the line it is showing; a controlled `index` still changes it. The docs of every `Animate*` that keeps moving past five seconds now say to pair it with a pause button bound to `paused`, and `transition="blink"` is documented as the one `transition` that repeats.

- **On a `HeatmapChart` grid, `↑` and `↓` keep the column and change the row.** Both vertical arrows did what the horizontal ones did and walked the cells row by row, so following one hour down a week of rows took a key press per cell in between. They now move to the same column in the row above or below, skipping a row whose cell there is a gap. A treemap has no columns, so every arrow still walks its tiles from the largest to the smallest, which the docs now say.

- **A chart's plot is described by one sentence rather than by its whole table.** The plot's `aria-describedby` pointed at the visually hidden data table, so a screen reader read every number in the chart each time the plot took the focus — three hundred and sixty-five of them on a year of daily points. It now points at a hidden sentence with the number of values and the lowest and highest of them ("Data points: 7. Range: 5 to 40."), and a `TimelineChart` counts its spans and names when the first starts and the last ends. The table is still there to be walked. The words are the `chart` namespace's new `summary`, in all eighteen registered languages.

- **Under a reduced-motion preference an `AnimateMarquee` lays its content down once and lets it wrap.** The strip stopped, but its `overflow: hidden` and its copies stayed, so long content was cut off at the edge for good and short content sat on the page two or four times over. It now renders a single copy, stops clipping and wraps the content onto more lines, and the stylesheet does the same in the first paint, before the component has read the preference.

- **A `MenuSubmenu` opens towards the row's inline end.** Its `side` defaulted to `'right'` and its chevron was always turned to point right, so under RTL the submenu opened over the menu it came from and the chevron pointed away from it. Left out, `side` is now the inline end, to the left under RTL, and the chevron follows the same direction Base UI places the popup by. A `side` passed explicitly is unchanged.

- **A `DataTable` export writes a text cell a spreadsheet would run with a `'` in front.** A cell starting with `=`, `+`, `-`, `@`, a tab or a carriage return went into the CSV as it was, so a name a user had typed as `=HYPERLINK(...)` ran as a formula in whatever spreadsheet opened the file. Such text is now written as `'=HYPERLINK(...)`, which a spreadsheet shows as text. Numbers are untouched. `exportEscapeFormulas={false}` writes the cells as they are, for a file no spreadsheet opens.

- **A vertical `Menubar` or `NavigationMenu` opens its popups beside the bar.** With `orientation="vertical"` a `Menubar`'s menus still hung below the word that opened them, and a `NavigationMenu`'s panels below their item, so each popup covered the next word or item down the rail. Both now open at the bar's inline end: to the right, or to the left under RTL. A horizontal bar is unchanged.

- **An empty `TimePicker` writes a picked hour on the hour.** With no `value` and no `referenceDate`, the time was written onto the moment the picker mounted, so at 15:42:17 pressing the hour `9` gave 09:42:17, and the seconds stayed even with `showSeconds` off. The default `referenceDate` is now the start of today, so the same press gives 09:00:00. A `referenceDate` passed explicitly is unchanged.

- **A nested `NebaProvider` builds on the one around it.** An inner provider replaced the outer `defaults` whole, so `defaults={{ density: 'compact' }}` inside `defaults={{ size: 'sm' }}` lost the small size; one with no `direction` reset Base UI's direction to left-to-right inside a right-to-left tree; and every provider wrote its scheme onto `<html>`, so a nested preview fought the page's own toggle, although the guide recommends nesting. An inner provider's `defaults` are now merged over the outer ones, a missing `direction` is inherited, and only the outermost provider writes the scheme to `<html>`. A nested provider still writes it to the element its `colorSchemeElement` names.

- **A chart with more than eight series warns that its colours repeat.** The palette's eight slots are handed out by index and start again at the ninth series, while the docs said they never cycled, and nothing on screen told a reader that the ninth line was not the first one again. A development build now says so once in the console, naming how many series the chart was given, and the docs say the slots repeat. A production build says nothing.

- **A `BottomNavigation` with `labels="selected"` keeps its glyphs still as the selection moves.** An unselected name was clipped to a pixel and took no line, so an item was a line shorter while it was not selected, and each glyph moved down as the selection left its item and up as it came back. Every item now keeps the line its name takes, with the name drawn only on the current one and still read out on the rest. A `labels="none"` bar is unchanged.

- **A `DateRangePicker` starts a new range at a day before the start, as a `Calendar` does.** With a start chosen, pressing an earlier day sorted the two and made the first press the end of the range, while a `Calendar` in `range` mode took the same press as a new start. The picker now starts over at the earlier day and waits for the end, so the one gesture means the same thing in both.

- **A `DateTimePicker` or `TimePicker` holds a chosen value to its bounds.** A row stays pressable when its span only overlaps the bounds, so pressing it could commit a value outside them: with a `minTime` of 09:30 and a value of 10:15, the hour `9` gave 09:15, and choosing the day a `minDate` falls on, with no time yet, gave midnight. A value outside the bounds is now moved to the nearest bound before it is committed, so those presses give 09:30.

- **A controlled `Anchor` still reports the heading the reader is in, and a page with nothing to scroll starts on its first heading.** Passing `activeHref` switched the scroll tracking off, so `onActiveChange`, which the docs pair with it, never fired and a controlled caller had nothing to set `activeHref` from. On a page too short to scroll, the rule that marks the last heading at the bottom of the page already held on the first frame, so the last heading was marked on a page that had just opened at the first. Tracking now runs in both modes, and when nothing scrolls the first heading is marked once it is in the document.

- **`Highlight` ignores accents in a string `query`.** `jose` marks `José`, as a DataTable's search finds it; before, a DataTable found the row and a Highlight in it marked nothing. The match is marked in the original text, so a decomposed accent stays inside the mark. A RegExp is still matched as written.

### Fixed

- **A secondary line inside a tinted or filled surface is the same ink, one step smaller.** `Pill`'s description was `currentColor` at 72% and a selected `List` row's was `--neba-muted-fg`, and neither could hold 4.5:1 — the description on a `solid` pill read 3.2:1 and the row's 3.1:1. The reason is the same in both: the ink on those beds was already solved to the minimum, `--n-on-solid` on `--n-fill` being 4.6:1 at full strength, so there is nothing to take away. Size and weight carry the step now, which they do on every variant and need no number. A row that is _not_ selected keeps the neutral grey, because on the bare sheet that is what quiet means.

- **A `Chip`'s count plate carries its own bed instead of another wash on top of the chip's.** `--n-on-tint` is solved for one wash, and the plate was `--n-soft-press` painted over whatever wash the chip already had: a count on a `text` chip read 4.2:1 and on a selected one 3.5:1. It is a fill now on every variant that is not itself filled, which holds 4.6:1 or better wherever the chip is sitting; a filled chip keeps the hole punched in its own fill.

  `Badge`, `Avatar` and `AppLogo` take the idea the rest of the way, because they are marks a caller drops _inside_ other things and cannot know what: their `text` plate is the wash laid on the page's own surface rather than on the caller's, which makes it opaque and leaves it no bed to depend on. It had none to spare — a `text` Badge read 3.9:1 on a selected row and **1.45:1 on a filled surface**, which is not faint, it is gone. It reads 5.5:1 in light and 7.6:1 in dark now, on every bed, and unchanged on the page: there the opaque colour _is_ what the wash resolved to.

- **Text on a surface tinted with its own colour has an ink of its own.** `panel` and `soft` are both washes of the family's `accent`, so writing the label in that accent put a colour on a pale copy of itself — the two move together, and past a wash of about 9% no adjustment to either one can reach 4.5:1. `soft-press` is 25%. An `on` Toggle, a `text` Chip, a highlighted menu row and an `outline` Button under the pointer were all between 3.4:1 and 4.5:1, in **both** themes; this one was never a dark-mode fault. `--neba-{color}-on-tint` is the ink for those beds, the way `on-solid` is the ink for a fill: `accent` pulled 28% toward `--neba-fg`, so it turns toward near-black on a white page and near-white on a dark one without a second value to keep in step. Every family now clears 4.5:1 on every step of both ladders, worst case 4.8:1 in light and 5.6:1 in dark. `accent` is untouched, so a TextLink, a Statistic's delta and an Alert's title read exactly as they did, and a project that overrides the five hand-picked values of a family gets the new ink derived from them for free.

- **Dark mode's panel ladder is 5/7/9%, down from 7/10/13%.** The ladder is opacity, which is why it is free on a white page — white over white is white — and expensive on a near-black one, where every step multiplies the bed's luminance and nested sheets compound. At the old numbers a Card was 2.6x the page and a table header inside that Card was 7.5x, which squeezed the whole ink hierarchy into the top of its range: `--neba-fg` itself fell from 16:1 to 9:1 just by being inside two sheets. The light theme's own ladder moves a sheet's lightness by nothing at all, and it is the hairline and the plate edge that say where a Card begins there, so the dark sheet keeps more separation than its light counterpart even after the change.

- **Dark mode's secondary ink, disabled ink and hairline are measured on that raised sheet, not the bare one.** All three were picked against `--neba-surface`, which is the one bed almost nothing is drawn on. So a DataTable's column names came out at 3.3:1, a SegmentedButton's unchosen labels at 3.9:1, a Combobox's placeholder at 4.5:1, and a disabled Select option or segment at 1.8:1 — a fifth of what its own label reads at.

  `--neba-muted-fg` now reads 5.05:1 on a table header inside a Card and 4.34:1 with a page shell around that, against the 4.33-4.64:1 the light theme reads everywhere — parity at every depth the library composes. `--neba-disabled-fg` lands inside the 2.0-2.4:1 light reads at, still clearly unavailable and no longer gone. Nothing in the light theme moved.

- **A hairline in dark mode is lighter than the sheet it is drawn on.** `--neba-border` was 0.11 above the bare surface in perceptual lightness but 0.02 to 0.05 _below_ a raised one, so on anything that is not the bare page the edge that is supposed to catch the light was a black scratch. A TreeView's rails and elbows were the clearest case, at 1.03:1 against the sheet behind them; a chart's grid and axis, a Panes divider, a Slider's ticks, an Anchor's rail, a Timeline's connectors and a DataList's rules are derived from the same token and were all doing it. The dark value now sits above the whole panel ladder. It is more present on a plain page than the light hairline is, which is the trade — one value cannot be a whisper across a ladder that moves.

- **A heading a component renders keeps the sheet's type, not the article's.** The same specificity problem, one level out: an Accordion's header, an inline `Drawer`'s title and a `HowToSteps` step are real `h1`-`h6` because they belong in the document outline, and that is exactly the tag `.prose` and `.vp-doc` have already styled. Inside rendered Markdown an Accordion header came out at 20px where the sheet asked for 15px — taking every `em`-sized glyph in the trigger with it — and a step heading at 18px and one weight heavier. All three write their type through `[&.neba-heading]` now, and `headingTitleClasses` is `sheetTitleClasses` in that form; the two tables cannot drift, because `test/package/resolution.test.ts` asserts one is the other with the prefix on each token.

  The `.neba-title` rule has the same fix. It is what lets a caller pass a real heading — `<Card title={<h2>…</h2>}>` — and keep the card's type, and it was written with one class plus a `:where()`, which is one class: inside an article the browser's own bold was being replaced by the article's rather than by the card's. Card, Alert, Empty, Collapsible, HoverCard, Toast, Timeline, Gallery, FilePicker and Fieldset all read it.

  `Dialog`, `Popover`, `Tour` and an overlay `Drawer` were measured and need none of this: they render into a portal at the end of `<body>`, where a container's `h2` rule cannot reach them.

- **`Typography` states its type scale at a specificity a host stylesheet cannot beat.** `h1`-`h6` and `p` are the tags a CSS framework is most certain to have styled by name, and `.prose h2` and VitePress's `.vp-doc h2` both write `font-size`, `line-height`, `letter-spacing` and `font-weight` on them — at one class plus one tag, which a single utility cannot outrank. Measured inside a rendered-Markdown article, every level of the scale lost its leading, `h1` and `h4` their size, the headings their tracking, and `weight` was ignored outright: `<Typography level="h2" weight="regular">` rendered at 600. The scale, the weight, the ink and the `gutter` margin are now written through `[&.neba-typography]`, the same doubling `TextLink` uses, and `align` and `lines` stay plain because nothing styles them by tag name.

  **This changes how an override is written.** A plain `className="text-[2.75rem]"` no longer wins; use Tailwind's `!` — `className="text-[2.75rem]!"` — which is what the component's own docs already recommended, for the weaker reason that the two classes used to tie. There is no specificity above a host's `h2` rule and below a caller's plain utility, so the only choice is which of the two wins.

- **`Table` and `DataTable` write their header ink inline.** Everything else a cell is painted with already was, for the reason that `<th>` and `<td>` are among the last tags a host stylesheet still styles by name, at a specificity a one-class utility cannot reach. `color` was the declaration left out, and both `.vp-doc th` and `.prose th` write it — so under Tailwind Typography a column heading took the _heading_ colour, the one ink on the page chosen to stand out from the text around it. The ink reads a `--n-cell-ink` slot, which is also the way a caller changes it: a custom property is invisible to a host stylesheet, where a `text-*` class through `classNames.headCell` never worked.

- **A `Chip` keeps the tails of its letters.** The label is truncated, and truncation clips at the line box, which the chip's one-em leading made shorter than the glyphs inside it — so every g, j, p, q and y lost its descender, at every size. The label's line box is now the font's own height. The chip is the same height and the words sit where they did.

- **Ticking a `DataTable` row with the pointer adds it to the selection.** In `multiple` mode with `checkboxes`, the press on a tick reached the row first and replaced the selection with that row, and the tick's own click then took it away again, so ticking a second row left at most one chosen. A press on a checkbox, switch, radio or label inside a cell now belongs to that control, as a press on a button or a link already did.

- **An `Image` given its own `onLoad` or `onError` still shows the picture.** The caller's handler replaced the one that marks the picture loaded, so it stayed at `opacity: 0` behind its placeholder for good, and a caller's `onContextMenu`, `onDragStart` or `draggable` switched `protect` off in the same way. Both handlers run now, the component's first.

- **A `Tour`'s card follows the step to its target.** The card was anchored to the first step's target for as long as the tour stayed open, so from the second step on the cut-out moved and the card did not. It is anchored again on every step.

- **`Highlight` no longer remounts its children when a query arrives or clears.** Marking re-keyed every child in a list, so typing the first character of a search, or deleting the last one, threw away the state inside every row it wrapped: what had been typed into a field, what was open and which pictures had loaded. Keys are left as they were, and a part of the tree with no match in it is not rebuilt at all.

- **Turning a `Carousel` slide scrolls the strip and nothing else.** The slide was scrolled into view, which moves every scroll container above it as well, so a reader who had scrolled past an autoplaying carousel was pulled back up to it on every turn, and a `value` changed from outside did the same. Only the carousel's own track moves now.

- **`registerMessages` cannot be used to write onto `Object.prototype`.** A locale parsed from JSON can carry an own `__proto__` key, and registering one put the tag on every object in the page. Namespaces are now matched only against the ones the library has, and a tag of `__proto__` is ignored.

- **A `TextLink` given `target` directly gets the same `rel` protection as `newTab`.** Only the target `newTab` implies went through the merge, so `<TextLink target="_blank">` left out `noopener noreferrer` and the new page kept a `window.opener` and a `Referer` pointing back.

- **A `NavigationMenuLink` that opens elsewhere carries `noopener noreferrer`.** A link inside a panel passed `target` straight through, unlike a `NavigationMenuItem` link beside it, so `target="_blank"` in a panel left the new page a `window.opener` and a `Referer`. A `rel` of the caller's own is kept and merged.

- **`neba/hooks` has types under `moduleResolution: node10`.** `typesVersions`, which that resolver reads instead of `exports`, had no entry for it, so its wildcard sent the import to a component folder that does not exist and TypeScript reported the module as missing.

- **A `Tour` step with a selector the browser cannot parse no longer takes the app down.** `querySelector` throws on a `target` such as `#1-intro` or an id made by React 18's `useId`, and it threw inside an effect, where it unmounted the whole tree. Such a step is drawn as a step with no target.

- **A `TreeSelect` branch that cannot be chosen opens again.** It was drawn as a disabled row, and a disabled row answers neither a click nor its arrow, so with the default `selectableBranches={false}` no branch could be opened at all and only `defaultExpanded` or a search reached the leaves. Such a branch is now an ordinary row that opens and shuts and is never chosen; a branch marked `disabled` still looks and acts disabled.

- **`useToast`'s methods keep one identity.** `add`, `close`, `update` and `promise` were rebuilt every time the list of toasts changed, so an effect that raised a toast and listed `add` among its dependencies raised one, received a new `add`, and ran again without end. The object the hook returns still changes with `toasts`; list the method you call, not the object.

- **A grouped `DataTable` in pages heads each page with the groups that are on it.** Every group's heading was drawn on every page, so the second page of a long table opened with a column of headings for groups whose rows were all somewhere else. An open group is headed only on the pages that hold its rows; a folded one has no rows anywhere and stays on every page, so it can be opened again.

- **`CodeBlock` keeps nothing for a `language` it cannot load.** Every unknown name a page passed was remembered for the page's lifetime, so a block whose language came from a reader's choice grew the cache without bound; such a name is now answered as plain text on the spot. A `language` named after a member of `Object`'s prototype, such as `constructor`, is plain text too rather than a failed attempt to call `Object` as a grammar.

- **`HowToSteps` keeps the keyboard focus through Done and Start over.** Both remove the button that was pressed, so the focus fell to the page and a keyboard reader started again from the top. Done hands it to Start over, and Start over hands it back to the forward button.

- **A `Spoiler` keeps the keyboard focus when it is revealed or covered again.** The pressed button went inert with the half it was in, which drops the focus to the page. Revealing now hands the focus to the content, and covering again hands it to the cover's button.

- **Unfolding a `Breadcrumb` keeps the keyboard focus in the trail.** The `…` button left the trail as soon as it was pressed, which dropped the focus to the page. It now moves to the first step the fold was hiding.

- **Removing a file from a `FilePicker` keeps the keyboard focus in the list.** The remove button left with its row and the focus fell to the page. It now moves to the remove button that takes that place, the one before it when the last file went, and the drop zone when the list is empty.

- **Pressing a `FloatingAction` puts the keyboard focus back on the button it came out of.** The dial closed with the pressed action inside it, so the focus fell to the page, where Escape already refused to leave it. A dial kept open with `closeOnAction={false}` leaves the focus on the action.

- **Picking a month from a calendar's month grid keeps the focus in the calendar.** The day grid drew its first frame with the tab stop still in the previous month, found no day to focus and dropped the focus to the page; this happened in `Calendar` and in every date picker. The first day of the picked month takes the focus.

- **`Panes`, `Sidebar` and a draggable `WindowPane` can be dragged with a finger.** Their handles and the window's title bar let the browser treat a moving finger as a scroll, so it cancelled the pointer a few pixels into every drag. They take `touch-action: none` now, as the window's resize handles already did.

- **The preview button of an `Image` and the tiles of a `Gallery` draw a focus ring.** Both wrote their outline through a ring colour that nothing above them declares, and a custom property with no value drops the whole declaration, so a keyboard reader saw no focus at all. They fall back to the primary ring.

- **Focus rings inside a clipped sheet are drawn inside the edge.** A ruled `Accordion`, a ruled `List` and a `ScrollArea` clip their overflow, and the ring drawn outside a full-width header, row or viewport was cut off on both sides — entirely, for a lone accordion section or the viewport. Those three rings sit inside the edge now, as `Collapsible`'s already did.

- **The words `Combobox`, `ToastProvider`, `ScatterChart` and `TimelineChart` said in English now follow `locale`.** The row that adds what was typed, the name of a combobox's chevron, the name of the toast region, and the column headings of the scatter and timeline data tables were written in English whatever language the product spoke. All eighteen languages under `neba/locales` translate them, and a test now fails when a language is missing a word English has. The hidden tables' English headings change as well: a scatter's size column is `Size` rather than `z`, and a timeline's columns are `Label`, `Start` and `End`.

- **`colorSchemeScript()` sets `color-scheme` as well as `data-theme`.** A remembered dark page kept light scrollbars and native controls until the app hydrated, because only the provider wrote `color-scheme`. The pre-paint script writes both now, as the provider does.

- **Reduced motion holds inside a forced-light box.** An element with `.light` or `data-theme="light"` declares the motion durations again, so a reader who asked for less motion got the hover transitions and popup fades back everywhere inside one. The override now names those roots too.

- **A `Gallery` tile answers the keyboard focus the way it answers the pointer.** The lift, the dim, the zoom and a `caption="hover"` were keyed to the tile being focused, and the tile is a list item that never is, so none of them appeared for a keyboard reader. They follow a focused button inside the tile now, and `focus-within` in a browser without `:has()`.

- **A `Transfer`'s two lists are named groups.** Each list has its own "Select all" box and search field, identical to the other list's, and nothing tied them to a heading, so a screen reader could not tell which list a control belonged to. Each list is now a group named by its heading.

- **An inline `ColorPicker` is a group named by its `label` and described by its `description` and `error`.** The three were drawn beside the panel and connected to nothing, so the square, the rails and the field were heard without any of them, and two inline pickers on a page could not be told apart.

- **A read-only `Rating` reads an average out to one decimal.** The score was spoken whole, so `value={13 / 3}` was announced as "4.333333333333333 out of 5". It is rounded to one decimal before it is written into the sentence.

- **A virtualised `DataTable` with column groups counts its rows correctly.** The row numbers a screen reader reads out assumed a head of one row, so under a two-row head every body row was numbered one too low and the total one too few. Both head rows are numbered now and the body starts after them.

- **`TreeView`'s keyboard follows the tree pattern more closely.** Enter or Space on a button in a row's `action` chose the row instead of pressing the button; the tree now leaves keys pressed inside a row's controls alone. Enter on a row with an `href` follows the link, where it only chose the row before. In a `multiple` tree every row that can be chosen says whether it is, and a reader tabbing into a tree lands on the chosen row rather than the first.

- **A selected `ListItem` that is not pressable is announced as the current one.** Only a row that was a button or a link said so, through `aria-current`; a plain row showed it with its tint alone. It carries `aria-current` as well now.

- **An autoplaying `Carousel` stays held while the keyboard focus is inside it.** The pointer and the focus shared one pause, so a mouse passing over and out of the strip started it again under a reader who had tabbed into a slide, and the slide changes made there by the arrows were not announced because the live region stayed silent. The two pauses are kept apart, the live region speaks whenever the strip is held, and a caller's `onFocus`, `onBlur`, `onPointerEnter` and `onPointerLeave` run beside the carousel's own instead of switching the pause off.

- **A failed `Image` is named once, and a previewable one with `alt=""` has a name.** When the file did not arrive, the `<img>` kept its `alt` in the accessibility tree and the fallback wrote the same words over it, so a screen reader read the name twice; the drawn words are hidden from it now. With `preview` and an empty `alt`, the button and the preview had no name at all, and both are called "Enlarge image", translated in every language under `neba/locales`.

- **An `Avatar` says its `alt` whatever stands in for the picture, and says nothing when `alt` is empty.** A silhouette given an `alt` and no `name` had nothing to read while its picture loaded or after it failed, and `alt=""` beside a `name` still read the initials out as two letters. The name is spoken from the label alone now, and an empty `alt` hides the stand-in as it hides the picture.

- **A `Popconfirm` bubble is named by its title and described by its description.** Both were plain paragraphs connected to nothing, so the focus moved into a bubble announced only as "dialog". They are the popover's own title and description now, drawn as the same paragraphs.

- **A focus ring on the light sheet clears 3:1.** A ring is drawn 2px off its control, so it is read against the page, and on white 55% of a family's accent was 2.2:1 to 2.6:1 — under what a focus indicator needs, on a Button or a Chip's × where the ring is the only sign of focus. The light theme draws the ring at 80% now, 3.4:1 or better for every family; the dark theme keeps 55%, which already cleared 3.2:1. `--neba-ring-alpha` holds the number for each theme.

- **A calendar says which month it moved to.** Stepping a month, or arrowing off the edge of one, changed every cell at once and a screen reader heard only the newly focused day. The grid is named by the month on screen, in a polite live region that says it again when it changes. A month cell is named the way the locale writes a month of a year ("2026년 11월", not "11월 2026"), and a `multiple` or `range` calendar marks its grid `aria-multiselectable`.

- **The tick on a chosen `ColorPicker` swatch is the ink that reads.** It turned black only past a luminance of 0.42, so a white tick was drawn on a mid grey, an orange or a green at 2.3:1 to 2.8:1, where black reads 7:1 or better. The tick now takes whichever of the two contrasts more, so a few light swatches that had a white tick have a black one.

- **A `HowToSteps` with a `title` is a named group.** Its root pointed `aria-labelledby` at the title, but a `<div>` with no role cannot carry a name, so the reference was ignored and the guide had no name at all. With a `title` the root is `role="group"` named by it.

- **A blink never runs faster than three times a second.** `AnimateBlink`'s `duration` had no floor, so `duration={200}` flashed five times a second, past the rate at which a flash can bring on a seizure. A blink shorter than 334ms is raised to it, on `AnimateBlink`, on `transition="blink"` and on an `AnimateSplit` whose effect is `blink`.

- **Hidden panels are out of reach under React 18 too.** `Spoiler`, `Pill`, `WindowPane` and `HowToSteps` take what they hide out of the tab order and the accessibility tree with `inert`, written as a boolean. React 18 does not know the attribute and drops a boolean on it, so under 18 a covered spoiler was read aloud, a collapsed pill's details and a minimised window took the focus, and a guide's other steps could be tabbed into. The attribute is now spelled for the React that is running.

- **An `aria-label` on a `Select`, `Combobox` or `NumberField` names the control.** `aria-label` and `aria-labelledby` went to the root `<div>` with every other attribute, so a field with no visible label, the usual case in a table cell or a toolbar, had a trigger or an input with no name at all. Both now go to the control itself, as they already did on `TextField`.

- **A `Slider` is named and described on its thumbs.** `aria-label` and `aria-labelledby` went to the root, so a slider with no visible label had thumbs with no name, and `description` was tied to nothing. Both names, and `aria-describedby` merged with the description, now go to every thumb.

- **`HowToSteps` says which step it moved to.** Next, Previous and a row in the list changed the panel in place and left the focus on the button pressed, so a screen reader heard nothing change. A polite live region now reads the new step, as "Step 2: Configure", or its position when the title is not a string.

- **A `Tour` says which step it moved to.** Next rewrote the title, the words and the counter in place while the focus stayed on Next, so a screen reader heard nothing change. A polite live region in the card now reads the new step, as "Step 2: Deploy", or its position when the title is not a string.

- **A `Pill` that opens its `details` says so.** The button a pill with `onClick` draws had no `aria-expanded` and no way to be given one, since attributes passed to the pill land on its root, so a screen reader was never told that pressing it revealed anything. With `details` it now carries `aria-expanded` from `expanded` and `aria-controls` pointing at the details.

- **A `priority` `Image` is visible before hydration.** Every picture started at `opacity: 0` under a Skeleton and faded in once React had seen it load, so on a server-rendered page the picture Largest Contentful Paint measures stayed hidden until hydration, however early its file arrived. A `priority` picture is now drawn from the first paint, with no fade and no Skeleton over it; a `placeholder` picture still stands beneath it.

- **A `CodeBlock`'s line numbers and prompts are not read out.** They are generated content, which a screen reader reads with the code, so a block was heard as "1 const a equals 1, 2 const b…" although the docs said otherwise. Both now carry empty alternative text; a browser without that syntax, Firefox before 128 and Safari before 17.4, keeps reading them as before.

- **A modal `Popover` always has a way out.** With `modal` on and `showClose` left off, the popup trapped the focus with no close button in it, so on iOS VoiceOver, which has no Escape key, a reader could not leave; Base UI requires a close for a modal popover. One is now added last in the popup, visually hidden until it takes the keyboard focus, when it shows as the × in the corner.

- **A `Mockup` with a width in pixels is drawn in a server render, and never widens the page.** The device stayed `visibility: hidden` until its box was measured, so on a server-rendered page the device and everything on its screen were invisible until hydration, and meanwhile a desktop drawn at 1440 pixels could give a phone-width page a horizontal scrollbar. A numeric `width` or `height` now works out the scale while rendering, and the root clips what it holds; a mockup sized in a CSS length is still measured first.

- **`OtpField` names each slot by its place, and takes `locale` and `slotLabel`.** Every slot was named by the field's label, so a six-digit code was "Verification code" six times with no word about which box held the caret. The first slot keeps the label and every other is "Character 2 of 6", in the `locale`'s words or through `slotLabel`. Every registered language has the new `otp` namespace.

- **A `Timeline` step says in words whether it is done.** Only the current step was read, through `aria-current`; a finished and a waiting step differed only in the shape of their bullets. Each now carries visually hidden text, "Completed" or "Upcoming", in the words of the new `locale` prop or of `labels`, and every registered language has the new `timeline` namespace.

- **A read `ChatBubble` is told from a delivered one by shape.** `read` was the `delivered` double tick in the accent colour, so whether a message had been read was said only to readers who can tell the two colours apart. It is now the double tick cut out of a filled disc.

- **A `CommandPalette` group names the rows in it.** A group heading was a `presentation` element between rows of the listbox, tied to none of them, so arrowing from "Navigate" into "Actions" never said the group had changed. Each run of rows that share a `group` is now a `role="group"` named by its heading.

- **A time column is one tab stop.** Every hour, minute and second in a `TimePicker` or `DateTimePicker` was a tab stop of its own and no key moved within a column, so getting past a 24-hour clock with seconds took a hundred and forty-four presses of Tab. Each column is now one stop, on its chosen row or its first; ↑ and ↓ walk it, Home and End jump to its ends, and Enter, Space or a press still chooses.

- **Scrolling a `DataTable` with a finger no longer changes the selection.** A row was chosen on `pointerdown`, so every touch that began a scroll replaced the selection with the row under the finger. A touch now chooses on `click`, which the browser does not send when the finger went on to scroll; a mouse and a pen still choose on the press and drag a run as before.

- **A macOS `WindowPane` shows its traffic-light glyphs to the keyboard and to touch, and its resize corner says how it works.** The glyph inside each dot appeared only under a hovering pointer, so a keyboard or a touch reader told close, minimise and maximise apart by colour alone; it now also shows while one of the three has the focus, and always where there is no hover. The keyboard-reachable corner, a button that does nothing when pressed, is described as resizing with the arrow keys, in a new `window` message every registered language has.

- **Tapping a field on an iPhone no longer zooms the page.** Safari on iOS and iPadOS zooms in on any field under 16px when it takes the focus, and the default `md` field is 13px, so the ordinary field on the ordinary phone moved the whole page and left it zoomed. On those systems alone, the text of `TextField`, `NumberField`, `Combobox`, `CommandPalette`, `TreeSelect`'s search, `ColorPicker`'s value, a `DataTable` cell editor and an `xs` or `sm` `OtpField` is now at least 16px; every other browser keeps the size `size` sets.

- **Controls and indicators stay visible in a forced-colour theme.** Windows' contrast themes draw no `box-shadow` and replace background colours, and the stylesheet had nothing for them: a filled `Button`, `Toggle`, `Chip` or `Pill` lost the plate that was its edge, and a `Switch`, a `ProgressLinear` and a `Slider` lost the fill and the thumb that say their value. Under `forced-colors: active` those controls now carry a system-coloured outline, and the indicators are drawn in the system's own `Highlight` and `ButtonText`. Nothing changes in any other mode.

- **Small controls are pressed at the size of a finger.** An `Alert` or `Toast` ×, a `NumberField` stepper at `xs` and `sm`, a `Carousel` dot, a `Panes` or `Sidebar` resize handle, a `WindowPane`'s resize corner and its macOS traffic lights were all drawn, and pressed, well under the 24px WCAG 2.5.8 asks for. Each now carries an invisible target of at least 24px on the short axis; a control in a tight row grows along the row only into the gaps beside it, so it never takes a neighbour's press. Nothing drawn moves, and the `xs` step of the control height ladder is left as it was.

- **A `static` `BottomNavigation` no longer leaves room for a home indicator.** `safeArea` added the bottom inset whatever the position, so a bar sitting in the flow inside a card had 34px of empty sheet under it on an iPhone. It applies only to a `fixed` or `sticky` bar now.

- **An `Empty` rendered as a table cell stays a cell.** The props table suggests `render={<td colSpan={5} />}`, which put `role="status"` and `display: flex` on the `<td>` itself: the cell lost its role, and a flex `<td>` is no longer laid out as a cell, so its `colSpan` spanned nothing. Given a `<td>` or a `<th>`, the state is now drawn inside it, and the cell keeps its role, its span and the class names it was given.

- **A `GaugeChart`'s reading is in a server render.** The number in the middle was drawn only once the box had been measured, and an unmeasured box counted as an empty gauge, so the HTML a server sent, and a crawler read, said "Nothing here" where the reading belonged. Until it is measured the gauge now shows its reading and caption in the middle of the box.

- **An `AnimateMarquee`'s copies are out of the tab order.** The strip is laid down more than once so it can loop, and the copies were only `aria-hidden`, so every link or button in it was a tab stop once per copy, each landing somewhere a screen reader had been told was not there. The copies are `inert` now.

- **`AnimateScramble` and `AnimateCounter` show the answer to a reader who asked for less motion, triggered or not.** Under a reduced-motion preference both skipped the animation once it started, but until then a Scramble showed its noise and a Counter its `from` value, and with `trigger="hover"` or `"manual"` that could be all the reader ever saw. Both show the final text or number from the first frame now.

- **A `Sidebar`'s resize handle says how wide the sidebar is.** It is a focusable `separator`, which has to carry a value and its range, and it carried neither, so a screen reader announced a separator and nothing about where it was or how far it could go. It now carries `aria-valuenow`, `aria-valuemin` and `aria-valuemax` in pixels, kept up to date as the width is dragged or stepped.

- **A `CodeBlock` range that runs past the code no longer freezes the page.** `highlightLines="10-100000000"` counted every number in the range into a set before drawing anything, which held the page for seconds and then threw a `RangeError` that took the render down. A range is held to the lines the block has.

- **A `threshold` outside 0–1 no longer takes the page down.** Every `Animate*` component and `useOnScreen` hand `threshold` to an `IntersectionObserver`, which throws a `RangeError` for `1.2` or `-0.1`, from an effect, so nothing caught it. A threshold is held to the range now, and a `NaN` is treated as `0`.

- **A translation's placeholders are filled the same way everywhere.** `Tour`, `HowToSteps` and `Gallery` filled theirs with an older helper that looked a `{name}` up with a plain index, so a registered translation containing `{constructor}` printed `function Object() { [native code] }` into the counter. They use the one helper the rest of the library does, which leaves a placeholder it has no value for as it was written.

- **A disabled `TextField`, `NumberField` or `Toggle` shows the not-allowed cursor.** Each carried its ordinary cursor on every render and `cursor-not-allowed` beside it when disabled, and two cursor utilities on one element are decided by the order Tailwind emits them in: a disabled field showed an I-beam and a disabled toggle a pointer. The cursor is chosen with the state now, so each element carries one.

- **A `fullWidth` `ButtonGroup`, `ToggleGroup` or `SegmentedButton` is a block.** Each kept `inline-flex` in its base classes and added `flex` for `fullWidth`, and two display utilities on one element are decided by stylesheet order, so the group stayed `inline-flex w-full` and sat on the text baseline like a word. The display is chosen with `fullWidth` now.

- **A child put in front of the others no longer remounts the ones after it in `Stack`, `Timeline` and `Carousel`.** Each drew a wrapper around every child and keyed it by position, which threw the caller's own keys away: a new first avatar, step or slide handed every later wrapper a different child, so React mounted all of them again, reloading their images, dropping their state and replaying a `Stack`'s entrance. The wrappers take the child's key now.

- **An `Animate*` with `trigger="hover"` runs the caller's `onPointerEnter`, `onPointerLeave`, `onFocus` and `onBlur` beside its own.** Fourteen of them spread the trigger's handlers over the caller's and threw those away, and `AnimateTyping`, `AnimateMarquee` and `AnimateHeadline` spread them the other way round, so a caller's handler took the trigger off and the effect never started.

- **A `Tooltip` given an `id` still describes its trigger.** The `id` replaced the generated one on the popup while the trigger's `aria-describedby` kept the generated one, so a screen reader was pointed at an element that did not exist and read nothing. The popup takes the caller's `id` and the trigger points at it.

- **A `style` on a `TimelineItem` is merged with the item's own slots.** It went through the props spread and replaced the whole inline style, so any `style` at all took away the bullet size and the colour slots and drew the step with a bullet of no size. The caller's declarations are laid over the slots now.

- **A `className` in the `imageProps` of an `Avatar` or an `AppLogo` is added to the picture's own classes.** It went through the spread and replaced them, so `imageProps={{ className: 'grayscale' }}` took away `size-full object-cover` on an Avatar and `object-contain` with its bounds on an AppLogo, and the picture spilled out of its circle or tile.

- **A chart whose values all lie past a pinned axis end still draws its axis.** A `LineChart` or `ScatterChart` given `yAxis={{ min: 0 }}` over values that are all below zero, or any chart with a `max` below all of its values, worked out a value range that ran backwards, so the step and the top of the scale were `NaN`, no tick was written and the marks were drawn far outside the plot. The pinned end now stays where it was put and the scale opens past it. A flat series under one pinned end keeps that end too, where it used to be moved to open the band.

- **A chart writes the name of its left axis above the plot, and on a horizontal chart writes it at all.** A vertical chart's `yAxis.label` was drawn eight pixels above the plot, which on most charts is above the top of the box, while the room for it was taken out of the band beside the ticks, where nothing was drawn. A horizontal chart's `xAxis.label` took that band too and was never drawn. The name of the axis along the left edge now takes a band along the top of the box and is drawn in it, so the plot is a little shorter and a little wider than before. A `hidden` axis draws no name, as its props say.

- **A `CommandPalette` opens with an empty search after a command closed it.** The query was cleared only when Escape or the scrim closed the sheet, so running a command, or turning a controlled `open` off, left the last search in the field and the next open showed a filtered list. It is cleared whenever the palette closes, however that happens.

- **The highlight of a `SegmentedButton` or a `FloatingBottomNavigation` goes away when nothing matches `value`.** A `value` no segment or destination carried left the tile where the last choice had been, which drew a choice that was no longer made. The tile is hidden until something matches again, and then appears in place.

- **A `FloatingBottomNavigation` highlight lands on the whole destination when two names are the same width.** Under `labels="selected"` the tile was measured as the pressed destination's name set off, before it had any width, and only a change in the bar's own width sent it on from there. Two names of the same width leave the bar as wide as it was, so the tile stopped short and narrow beside the destination. It is measured again when the names finish their transition.

- **A read-only `Checkbox` in the mixed state is filled.** The read-only tick filled for `checked` and not for `indeterminate`, so `readOnly` with `indeterminate` drew a light dash on an empty box, which did not read as mixed. It is filled the way an editable mixed tick is, and desaturated like the rest of the read-only state.

- **A `ColorPicker` reads an `rgb()` channel written as a percentage.** `rgb(100% 0% 0%)` was read as a red channel of 100 out of 255 and became `#640000`, a dark red. A percentage channel is a share of 255 now, so it is `#ff0000`; a percentage alpha was already read correctly.

- **`marks` on a `Slider` stepped in fractions keeps its last mark.** The marks for `marks={true}` were counted by flooring the range over the step, and `0.6 / 0.1` is `5.999999999999999`, so a slider from 0 to 0.6 in tenths drew no mark at 0.6. The count now allows for the rounding.

- **A `DateTimePicker` blocks the right hours on a day the clocks change.** A row was compared with `minDate` and `maxDate` as midnight plus a fixed number of hours, and a day the clocks go back is 25 hours long, so in New York on 1 November 2026 a minimum of 09:30 blocked the whole of hour 9 and 09:30 to 09:59 could not be chosen. A spring-forward day was an hour out the other way. Each row's first and last instant is now set on the day's wall clock.

- **A date picker whose format writes a weekday is sized to its widest date.** A trigger is held at the width of the longest string its format can produce, measured over twenty-four sample dates, and those dates fell on no Friday and paired each month with only two weekdays. A `dateStyle: 'full'` picker in Greek was sized for 27 characters of a real 29, so choosing a Friday in February widened the field. A format with a weekday is measured over every month against every weekday now, and the samples are worked out once per locale and format rather than on every render.

- **A virtual `DataTable` scrolled far down still draws rows after a search narrows it.** Scrolled to the bottom of five thousand rows and then searched down to ten, the table kept its old scroll offset, started its window of rendered rows past the last one and drew nothing, while the spacer standing in for the rows above held the scroll where it was, so the body stayed empty. An offset past the end now draws the last screen of rows, and the table shrinks back to the rows it has.

- **The arrow keys keep a `DataTable`'s active row on screen.** A row's place was counted from the top of the scrolling box, so a table with a caption, a head or group headings scrolled too little and left the row the arrows had reached below the edge — by the height of the head and caption, and by one more heading for every group above it. A table with no `height` did not scroll at all, so arrowing past the bottom of the window lost the row. The row is measured where it is now, and a table without a height scrolls the page.

- **Dragging a run of rows in a grouped `DataTable` takes the row under the pointer.** The drag read the body as rows of one height from its top, and each group heading is one more row than that, so a drag onto a row took the one after it, or more. The row is now found by where the rows are drawn.

- **A mouse click reaches the rows of a `DataTable` that selects many, and the sort buttons of one whose columns can be dragged.** Pressing a row with `selectionMode="multiple"` captured the pointer to the table in case the press became a drag, and a captured pointer's `click` and `dblclick` go to the capturing element, so `onRowClick`, `onRowActivate` on a double click and a cell's editor never ran for a mouse in Chromium, Firefox or WebKit. A header with `reorderable` did the same to its own sort button. Both drags now follow the pointer from the document instead, and still carry on past the edge of the table.

- **An emptied number cell in a `DataTable` writes no zero.** `Number('')` is `0`, so clearing a cell with `editType: 'number'` called `onCellEdit` with `0`, and so did opening an empty number cell and leaving it. An empty number field is treated like one holding no number, and the edit is dropped.

- **A `DataTable` with ticks and a column pinned to the start keeps both in place as it scrolls sideways.** The pinned columns were offset by the width of the tick column, but the tick column itself scrolled away, which left a gap that width in front of them with the scrolling cells showing through. The tick column is frozen with them now. A pinned heading was also stacked under the sticky headings beside it, so under `stickyHeader` the headings scrolling past were drawn over the frozen one; it is stacked above them.

- **Dragging a `DataTable` column reports the new order once.** The order was worked out and committed inside two nested state updaters, and React's StrictMode runs every updater twice, so `onColumnOrderChange` was called twice for one drag in development. The drag reads what it needs when it ends and commits outside them.

- **A `DataTable` rings its sheet only when the table has the focus.** The ring around a selectable table answered any focus inside it, so the search field drew its own ring inside a second ring around the whole table, which said the table had the focus when it did not; the footer's page-size Select did the same. It answers the table itself and the cell editor now, which is the one control in it with no ring of its own.

- **A `DataTable` heading being dragged is marked with a wash instead of being faded.** The heading carried along the row was drawn at 60% opacity, which faded the label saying which column it was, and state is not carried on opacity anywhere else in the library. It takes the soft wash a dragged `Sidebar` or `Panes` handle takes, over its own opaque ground, and the grabbing cursor while it moves.

- **`wholeWord` on a `Highlight` is ignored for a RegExp `query`, as documented.** A regular expression says its own boundaries, and the props said `wholeWord` was ignored for one, but it went on dropping every match that was not a whole word. `query={/cat/} wholeWord` now marks what the expression matches.

- **An `outline` `Highlight` no longer moves the text after it.** Each mark takes a hair of padding and gives it back as a negative margin, but the outline's 1px border was not given back, so every mark was two pixels wider than its word and the rest of the line shifted each time a search found one more. The margin now takes the border back too.

- **A shortcut on a letter no longer fires for the letter in the same place on another layout.** When the key typed was not the one named, a shortcut fell back to the physical key, even when the layout had typed a different Latin letter there. On AZERTY the Z sits where QWERTY has W, so Ctrl+Z fired both `Ctrl+Z` and `Ctrl+W` in `useShortcut`, a `CommandPalette` and a field's `shortcuts`. The fallback is kept for a key that types something other than a Latin letter or a digit, such as `Alt+K` on a Mac or a Cyrillic layout.

- **A shortcut does not fire in the middle of a word typed through an input method.** Korean, Japanese and Chinese build a character over several keydowns, and every one of them reached the page, so a `Mod+Enter` bound on a field, or bound with `useShortcut` and `ignoreWhileTyping: false`, could fire while a syllable was still being composed and send it half written. A keystroke an input method is holding, marked by `isComposing` or a `keyCode` of 229, matches no shortcut now. This covers `useShortcut`, a `CommandPalette`'s opener and a field's `shortcuts`.

- **`lines` on a `Typography` or an `AccordionItem` clamps to any count.** Each count from two to six had a class of its own, and anything larger fell back to the class for six, so `lines={8}` cut the text off at six lines without a word. The count is written into an `--n-lines` slot that one clamp class reads, the way the library passes every other number to its styles.

- **An `Image` preview opens the picture from the same sources.** The enlarged picture in the preview took only `src`, so an `Image` given a `srcSet` and no `src` opened an empty dialog, and a picture served behind a CORS or referrer rule was requested again without its `crossOrigin` and `referrerPolicy`. The preview takes all three now. It does not take `sizes`, which describes the thumbnail, so the browser picks a candidate for the size of the dialog.

- **A `Gallery` tile zooms on a transition under `hover="zoom"`.** The Gallery wrote a `transition` of its own onto each picture beside the one `Image` already carries, and two shorthands on one element are decided by stylesheet order: the Image's won, it did not name `transform`, and the zoom jumped to full size. The picture's own transition names `transform` now, and the Gallery no longer writes a second one.

- **A `CodeBlock` shows new `code` as soon as it is given.** The colouring is worked out after the code changes, and until it arrived the block went on drawing the colouring of the previous code, while the copy button already copied the new one; with a language whose grammar still had to load, the old code stayed on screen for the length of the download. A colouring is kept with the code and the language it was made from, and new code is drawn plain until its own arrives.

- **A `ButtonGroup` or `ToggleGroup` beats a `NebaProvider` for the buttons inside it.** The provider's defaults were filled in before a `Button` or a `Toggle` read its group, so a group's `size`, `density` or `variant` lost to the provider's: `<ButtonGroup size="lg">` under `defaults={{ size: 'sm' }}` drew small buttons. The order is the button's own prop, then its group, then the provider, then the default.

- **A `NebaProvider`'s defaults reach every component that takes the axis.** Some components never asked for them and others asked for part: `SegmentedButton`, `RadioGroup`, `Tabs`, `Timeline`, `Form`, `Fieldset`, `Menu`, `ContextMenu`, `NavigationMenu`, `LineChart`, `AreaChart` and `useConfirm`'s sheet ignored the provider, the date pickers took their `size` and not their `density` or `variant`, the Cartesian charts took no `variant` or `locale`, and `AnimateCounter`, `AnimateScramble` and `AnimateSplit` took no `locale`. Each fills in every axis it declares now.

- **A `TextLink` takes no `size` from a `NebaProvider`.** A link in a sentence is the size of the sentence, and a provider with `size: 'lg'` turned every link in running text into 15px type. A link given `size` itself still takes it.

- **A disabled `Accordion` section or `Collapsible` looks disabled.** Base UI keeps a disabled trigger focusable, so it never carries the `disabled` attribute, and the `disabled:` classes that grey it out never matched: a disabled section kept its ink, its hover wash and its pointer. The state is decided in the component now, for a section, for a whole disabled Accordion and for a Collapsible.

- **The radios of a disabled `RadioGroup` look disabled.** The group's `disabled` reached Base UI, which stopped the radios answering, and never reached the `Radio`s' own drawing, which read only their own prop, so a disabled group looked available. A Radio takes the group's `disabled` when it has none of its own.

- **A disabled `SegmentedButton` drops its colour family.** It had no disabled drawing of its own: the groove and the tile kept the family's colours, and the chosen segment's grey label sat on the solid fill, where the checked ink and the disabled ink were decided by stylesheet order. The groove and the tile take the disabled ground a Button does, every label takes the disabled ink, and the tile under one disabled segment in an enabled set is greyed as well.

- **A disabled `Slider` is drawn in the disabled colours rather than faded.** It was the whole slider desaturated and at 70% opacity, which took its label down with the control and put the state on the one axis no other state in the library uses. The rail, the fill and the thumb take the disabled ground, ink and hairline a Button uses, and the label keeps the disabled ink it already had.

- **A field inside a disabled `Fieldset` looks disabled.** Base UI's Fieldset stopped every field inside it answering, but each Neba field draws itself from its own `disabled` prop and cannot read Base UI's fieldset state, so a disabled group of fields looked available. `TextField`, `NumberField`, `OtpField`, `Select`, `Combobox`, `Checkbox`, `RadioGroup`, `Switch` and the date and time pickers now take the Fieldset's `disabled` as well as their own.

- **A `Dialog`, `Overlay` or `Drawer` that is not fully modal leaves the page clickable.** With `modal={false}` or `modal="trap-focus"` the page is meant to stay usable, but the scrim and the full-screen viewport the popup is centred in both covered it, so nothing behind them could be clicked. They let the pointer through now, and the popup takes it back. A fully modal one covers the page as before.

- **A `PieChart` share is written in the ink its slice reads best under, and the plot answers `Home`, `End` and `Escape`.** Every label written by `valueLabels="all"` wore the surface colour, which is about 4:1 on the light theme's slots and disappears on a pale slice a caller coloured. Each of the eight slots now has its ink in `--neba-chart-on-1` to `--neba-chart-on-8`, per theme, and a slice given a literal colour gets black or white by contrast. The accessibility notes promised `Escape` to clear the selection, and only the arrow keys existed; `Home` and `End` now go to the first and the last slice, and `Escape` lets go of a selection.

- **A treemap `HeatmapChart`'s hidden table puts every value under its own name.** Its column headings were taken from the first group's tile names, so a second group's tiles were written under the first group's headings and a screen reader read the wrong figure against each name. The columns are now every tile name the groups use, in the order they first appear, and a group's row is blank under a name it does not have.

- **A tap on a chart pins its tooltip until a press lands outside the plot.** On a touch screen a `LineChart`, `AreaChart`, `BarChart`, `ScatterChart`, `TimelineChart`, `PieChart` or `HeatmapChart` cleared its tooltip on `pointerleave`, which a finger sends the moment it lifts, so a tap showed the tooltip for a frame at most; a tap that did not move never read a point at all, because only `pointermove` did. A tap now reads the nearest point and keeps its tooltip up, and a press anywhere outside the plot puts it down. A mouse still clears it by leaving.

- **A `Switch` under RTL puts "on" at the end of the line.** The thumb travelled on a physical `left`, so in a right-to-left page it still sat on the left when off and moved right when on, the reverse of what the reader expects. It now travels on `inset-inline-start`, and on and off swap ends with the direction. A caller who moved the thumb through `classNames.thumb` with a `left-*` utility should use `start-*`.

- **A `Transfer`'s move arrows point the way the items go under RTL.** Both glyphs were turned for a left-to-right layout only, so on a right-to-left page, where the chosen list sits on the left, each arrow pointed away from the list it moves items into. Both now turn the other way under RTL.

- **A `Panes` boundary moves towards the arrow pressed under RTL.** A drag already followed the direction, but ArrowLeft and ArrowRight on an upright bar moved the boundary as if the page ran left to right, so on a right-to-left page each key moved it the other way from the arrow. The keys now follow the direction too.

- **A calendar's left and right arrows follow RTL.** The day, month and year grids are laid out in the reading direction, but ArrowLeft always went back and ArrowRight always went forward, so on a right-to-left page each arrow moved the focus away from the cell it pointed at. Under RTL ArrowLeft is now the next day, month or year. This covers `Calendar` and every date picker.

- **The `Gallery` viewer's arrow keys follow RTL.** Its Previous and Next buttons already swapped sides on a right-to-left page, but ArrowRight still went to the next picture, so the key pointing at the Next button went back. ArrowLeft is now the next picture under RTL.

- **A striped `Table` shows its stripes on a white page.** Every other row took the panel hover token, which is 82% white, so on a white page the stripes were not there at all. They now take the 4% mix of the ink that a striped `DataTable` already uses, which shows on any surface and in both themes.

- **A vertical `DataList` keeps each label with its own value.** With `orientation="vertical"` the gap between every child fell between a label and its value as well as between pairs, and the label's own margin made the first of those larger, so a label read as belonging to the value above it. `dividers` drew its rule above every `<dd>` too, between a label and its value. The space now goes above each label after the first, and the rule runs only between pairs. A horizontal list is unchanged.

- **A nested `Anchor` row marks its place on the rail.** On the `rail`, a row with a `depth` was indented with a margin, which moved its whole box and the `border-s` highlight with it, so the active nested row was marked a step away from the rail rather than on it. Nested rows on the rail are now indented with `padding-inline-start` inside a box that starts at the rail. Without the rail the indent is unchanged.

- **A server-rendered `Calendar` or `NebaProvider` hydrates without a mismatch.** A calendar marked today while it rendered, so a server in UTC and a reader in Seoul disagreed about which day to mark for nine hours of every day, and React reported the hydration failing; the month and year grids did the same with the current month and year. `NebaProvider` read the stored colour scheme in its first render, which a server has no `localStorage` for, so the server rendered the default and a returning reader's browser rendered their choice. Today is now marked, and the stored scheme read, once the page has hydrated; `colorSchemeScript()` still puts the stored scheme on `<html>` for the first paint, and the provider does not write the attribute until it has read the same value. The chart docs now tell a server-rendered page to pass `locale`, since a chart without one writes dates in the language and time zone of wherever it renders.

- **A `stacked="full"` chart writes the caller's numbers through `format` and shares the hundred between the series still shown.** An `AreaChart` or `BarChart` stacked to full kept each original value as `String(value)`, so its tooltip and its table ignored `format` and the locale and read `1234.5678` where the rest of the chart said `1,235`. Hiding a series in the legend left it counted in each category's total, so the bars and bands that remained stopped short of 100%. The originals are now written through the chart's own `format` and `locale`, and the total counts only the series still shown. The normalisation, which both charts had a copy of, is done once in the shared chart frame.

- **A chart takes any CSS length as its `height`.** The type and the docs said a string was any CSS length, but a `LineChart`, `AreaChart`, `BarChart`, `ScatterChart` or `TimelineChart` given `height="16rem"` drew into a plot 0 pixels tall and showed nothing, and a `PieChart`, `HeatmapChart` or `GaugeChart` ignored the string and took its `size`. A string height is now written on the chart's box and the drawing is laid out against the height that box comes to, following it when it changes. A number is still used as it is, with nothing measured.

- **A stacked `LineChart` or `AreaChart` stacks negative values down from zero.** The value axis summed each category's positive and negative values apart, but the lines and bands added every value together, so a series below zero pulled every band above it down: the top of the stack no longer met the axis, and bands drew over each other. Positive values now stack up from the zero line and negative ones down from it, as the axis and a stacked `BarChart` already did.

- **A chart keeps the same series hidden when new data reorders them.** The legend remembered hidden series by their position, so a refresh that brought the same series back in another order hid whichever series now sat where the hidden one had been, and a series added later with `hidden` was drawn anyway because the prop was only read on the first render. What the reader chose is now remembered by each series' `name`, falling back to its index when it has none, and a series nobody has toggled follows its own `hidden`.

- **A `DataTable` that takes the focus without selecting rings its sheet.** A table with `selectionMode="none"` that still takes a tab stop, because its rows have `onRowActivate` or a column is editable, drew no focus indicator at all when it was tabbed to, and nothing showed until an arrow key marked a row. It now rings its sheet while the table holds the focus, as a selecting table already did.

- **A `Combobox` with a `limit` still offers to add what was typed.** The row that adds a value the list does not have came last, and `limit` cut the list to that many rows, so once enough options matched the row was cut off: the typed value could not be added, and Enter chose the first option instead. `limit` now counts options only, and the row is drawn after as many of them as it allows.

- **A `FilePicker` in a form submits the files it lists.** Its hidden input held only the batch last picked in the browser dialog, so a dropped file was never submitted and a file removed from the list still was, and a `readOnly` picker disabled the input, so a form got nothing from it at all. The input now holds exactly the files in the list, written back whenever the list changes and again when the dialog is dismissed, and only `disabled` takes it out of the form. `required` still applies while the list is empty. The `maxFiles` docs said it implied `multiple`; it is counted only when `multiple` is on, and now says so.

- **A `Transfer` keeps a value it has no row for, whichever way rows are moved.** An id in `value` that `items` did not list — a row not loaded yet, or one filtered out before it reached the component — disappeared from the value the first time rows were sent to the right, and stayed when rows were sent back to the left. It now stays in both directions, after the listed rows.

- **A `NumberField`'s `ref` is its input.** It was a plain function component, so under React 18 a `ref` was dropped with a warning, and under React 19 it was passed along as a prop to the root `<div>`, so a form library focusing the field that failed validation focused nothing a reader can type into. It now forwards the ref to the `<input>`, as `TextField` does. Code that read the root `<div>` through the ref under React 19 gets the input instead.

- **`IconButton`s in a `ButtonGroup` join like other buttons.** An IconButton drew itself round with an inline `border-radius`, which beat the classes a ButtonGroup uses to square off the corners between neighbours, so a row of icon buttons overlapped as circles. It now reaches round through the radius ladder Button's own class reads, so the group's joined corners apply and the ends of the row stay round. A caller's `style` still overrides the radius.

- **A `Rating` without `name` submits nothing.** Its radios were given a generated `name` so they would act as one group, and a form then submitted that name as a field of its own, so a form's data gained an entry like `«r3»=4`. An unnamed Rating's radios still share a name, so they keep one Tab stop and the arrow keys still move between the stars, but they belong to no form. Pass `name` for a Rating a form should submit; without it `required` has nothing to hold back.

- **Clicking a `FloatingActionButton` with a mouse no longer shuts the dial the pointer just opened.** With `openOnHover`, the default, the dial opened as the pointer reached the button, and the click that followed toggled it straight back shut, so a mouse user who clicked the button saw the dial flash and close. A click on a dial the pointer opened now keeps it open, and the next click closes it. A dial opened by a press still closes on the next press.

- **A `Calendar`'s `elevation` draws a shadow, and `bordered` draws the popup's own sheet.** `elevation` wrote the shadow slot every surface writes, but nothing on the calendar read it, so the prop changed nothing. `bordered` drew a sheet of its own with one padding for every size and no glass edge, although the prop says it draws the sheet a picker's popup draws. The calendar now takes its shadow from `elevation`, with or without the sheet, and a bordered calendar draws the popup's edge and its padding for each `size`.

- **A picker in a form submits nothing while disabled, and `required` holds back an empty one.** The value of a `DatePicker`, `DateRangePicker`, `TimePicker`, `DateTimePicker`, `TreeSelect` or `ColorPicker` goes out through hidden inputs, which were submitted even while the picker was `disabled`, and which a browser never validates, so `required` only reached the trigger's ARIA and an empty picker let the form submit. The hidden inputs are now disabled with the picker, and a required picker that is empty blocks the submit through the form's own validation and hands the focus to its trigger. A read-only picker is not held back, as a read-only input is not.

- **A `DataTable` paged by its caller keeps the rows chosen on other pages.** With `manual={['pages']}` the table only holds the page it was given, and every Ctrl-click, range or press of the header tick rebuilt the selection from those rows, so choosing a row on page 2 dropped everything chosen on page 1. A key already chosen is now kept when its row is not on the page. `onSelectedChange` still hands over the row behind each key the table was given; a key chosen on another page of a manual table comes without one.

- **A grouped `DataTable` heads its ungrouped rows "No group".** Rows `groupBy` put in no group were headed by the empty-state text, "Nothing here", above rows that were plainly there. They now take the `table` namespace's new `noGroup` word, in all eighteen registered languages and in the table's `locale`.

- **A `DataTable` writes a `Date` in a column without `render` as a date.** Sorting and the CSV export already understood a `Date`, but a cell with no `render` of its own handed the object to React, and the whole table failed with "Objects are not valid as a React child". Such a cell is now written as a date in the table's `locale`. A column that needs another shape still passes `render`.

- **A `Breadcrumb` folds again when its steps change.** Once the `…` was pressed the trail stayed unfolded for as long as it was mounted, so a layout that keeps the breadcrumb across a route change showed every later trail in full.

- **`Shortcut` draws the Mac modifiers in the order macOS uses.** `Mod+Shift+P` drew `⌘⇧P`; it now draws `⇧⌘P`, as every menu on a Mac and the docs do, whatever order the modifiers were written in. Windows and Linux keep the written order.

- **A shortcut on a punctuation key fires with Shift held.** `useShortcut('?')`, as the hooks guide shows it, never fired: `?` is typed with Shift and the modifiers were matched exactly. For a single key that is neither a letter nor a digit, Shift is no longer compared, so `?` fires however the layout types it. Letters and digits still need `Shift` written.

- **`Typography` with no `color` inherits.** Every level was pinned to `--neba-fg`, so a Typography inside a solid Alert drew dark text on the dark fill, and a host's heading colour never reached it. It now states no colour and takes the one around it, as the docs said; `caption` and `overline` stay muted.

- **`align` and `gutter` work on a `caption` and an `overline`.** Both levels are `<span>` elements, where `text-align` and a bottom margin do nothing. Either prop now makes them a block.

## 1.13.0 (2026-09-11)

### Where the bytes went

| What you import               | 1.12.0   | 1.13.0   |
| ----------------------------- | -------- | -------- |
| `Button`                      | 5.1 kB   | 5.2 kB   |
| `Chip`                        | 3.3 kB   | 3.4 kB   |
| `LineChart`                   | 11.6 kB  | 11.8 kB  |
| `CodeBlock`                   | 5.0 kB   | 5.1 kB   |
| `Image`                       | 6.5 kB   | 7.1 kB   |
| `Gallery`                     | 10.2 kB  | 10.4 kB  |
| a whole page shell            | 29.0 kB  | 29.2 kB  |
| 12 components — a typical app | 70.5 kB  | 71.0 kB  |
| 12 components, with Korean    | 72.9 kB  | 73.8 kB  |
| 25 components — a large one   | 115.7 kB | 116.9 kB |
| all exports                   | 263.9 kB | 265.8 kB |

`Image` is the row that moved. A picture that failed with an empty `alt` printed a hardcoded English sentence, so `Image` now reaches `internal/i18n.ts` and `internal/defaults.ts`, which costs it 0.5 kB. The last 0.1 kB is `width` and `height`, which `Gallery` also carries because it draws an `Image`.

The 0.1 kB on `Chip`, `CodeBlock`, `LineChart` and the page shell is the same machinery gaining an `Object.hasOwn` on each of its two lookups, and a shared bound under the memos in `internal/`.

The twelve- and twenty-five-component rows carry `internal/wheel.ts` on top of that, which is what a `Tabs` bar now takes the wheel with.

The last 0.1 kB on nearly every row is the focus ring: the resting declaration and the transition it travels on are two more entries in the class string every control carries. `neba/styles.css` moved 22.4 kB → 22.5 kB for the same reason, plus the breakpoint slots each responsive element now clears — which is the cost of a fix that could not be made anywhere else, since only the element that reads a slot can say it does not inherit one.

Registering a language ships that language's whole module, so the twenty picker strings and the two a Carousel's stop button needs land in it whether or not the page draws either: 2.8 kB now against 2.4 kB before. Those twenty used to be hardcoded English, which a Korean product could not reach at all.

### Added

- **Every portalled surface reads one z-index, `--neba-z-portal`.** Fourteen of them carried a hardcoded `z-50`, which is a guess about a page the library cannot see — a site whose own fixed header sits above that had its menus and dialogs opening underneath its chrome, and the way out was a selector per surface. The token defaults to 50, and a host that needs another number sets it once on `:root`.

- **A `BottomNavigationItem` declares the `target` and `rel` its link already rendered.** The props were typed against a `<button>` and cast to an `<a>`, so a destination that opened in a new tab could only be written by handing the component something TypeScript said was impossible.

- **A `ProgressLinear`, a `ProgressCircular` and a `Meter` take a `thickness`.** The ladder decides the bar's height and the ring's stroke, and the ladder is five steps — so a speed-test dial or a page that is about one number had no way to draw a heavier line without moving the diameter with it. It is a number of pixels on all three, because that is what the ring's arithmetic already works in. A ring's stroke is held inside the ring it describes: past half the radius there is no hole left in the middle of it.

- **A `Combobox` takes a `filter`, and `false` turns it off.** The list was always narrowed here, against each option's visible label — so a search answered by a server, which is the case a combobox with hundreds of options exists for, had its results filtered a second time and lost every row that had matched on a keyword, a description or a synonym rather than on the label. `filter={false}` lets a narrowed list through; a function decides per option. The row that offers to add what was typed is exempt from both, since it is the query written out.

- **A `Slider` draws `marks`, and takes `classNames` for the parts behind its root.** Labelling points on a track — `1 / 100 / 250 / 500` under a count, "realistic" and "abstract" at the ends of a style axis — was a row a caller had to lay out themselves, absolutely positioned at `(value − min) / (max − min)` of a width they had to know. An array of `{ value, label? }` does it, and a bare `marks` is a tick at every `step`. The row sits beside the control rather than on the rail, because a tick on the rail has to stay legible over both the fill and the groove, and it is `aria-hidden`: the thumb already announces the value and the range.

  The slots are the other half of the same complaint. A Slider draws seven parts and offered a class name for exactly one of them, so a one-off recolour had to reach for `[role="slider"]`. `label`, `control`, `track`, `indicator`, `thumb`, `description` and `mark` are named now, like every other multi-part component in the library.

- **A `SelectOption` can name a `group`, and a run of them gets a heading.** A list of time zones by region or fonts by family had nowhere to put the heading, and the stand-in was a disabled option holding a `<strong>` — which the keyboard and the pointer skip correctly and a screen reader still reads as an option that cannot be chosen. A group is a run of _adjacent_ options naming it, so the array's order stays the list's order and nothing is moved out from under a caller; two runs of one name draw two headings, which is the array saying they are not together.

- **A `Tabs` bar takes the wheel.** A bar with more tabs than room scrolls, but a mouse has one wheel and it points down the page — and the bar draws no scroll buttons and hides its scrollbar, so the tabs past the edge were reachable only by keyboard. A wheel rolled over the bar now travels along it. It is on by default, which is what separates the prop from `ScrollZone`'s `wheel`: that strip has a pair of buttons and this one has nothing. A bar that fits takes nothing at all, so a page with three tabs on it is unaffected, and `wheel={false}` turns it off.

- **A `Carousel` with `autoPlay` draws the button that stops it.** It paused on hover, on focus and in a background tab, and it never started for a reader who had asked for less motion — but a reader holding a phone hovers nothing, and one running a magnifier may never put a pointer over the strip at all. WCAG 2.2.2 asks for a mechanism, and those were not one. The control sits in the row under the frame, beside the dots and never over a slide; `pauseLabel` and `playLabel` name it, and it is translated in all nineteen languages. There is no prop to take it away — a caller who wants a control of their own can drive `value` and leave `autoPlay` off.

- **The four date and time pickers say their twenty non-date strings in the reader's language.** "Previous month", "Choose a year", "Today", "Now", "Hour", "AM/PM" and fourteen more were hardcoded English, over dates `Intl` had already translated — so a Korean product's only way out was to write out all twenty through `labels`. There is a `picker` message namespace now, in all nineteen languages. `labels` still wins where it is given, which is what it is for: `locale` answers the language and `labels` answers the wording.

- **An `Image` takes `width` and `height`, and reserves the box they describe.** They were omitted from the props, so the one component in the library whose reason to exist is holding a picture's space could only be told what that space was as a `ratio` worked out by hand — and a default `Image` reserved nothing at all, which is the largest source of layout shift on most sites. They reach the `<img>` as the attributes they are, and giving both turns an `'auto'` ratio into their proportion. An explicit `ratio` still outranks them: that one is the layout's shape and these two are the picture's.

### Changed

- **A focus ring arrives rather than appears, and on a field it is flush with the edge.** Two things about the same object. The ring is declared at rest with no width instead of not being declared at all, so the focus has a width to travel rather than a style to switch — it grows in beside the hairline it belongs to, at the house duration, and instantly for a reader who has asked for less motion. And a field's shell takes it flush: the hairline turns the ring's own colour the moment the focus lands, so a ring held two pixels off drew a second line with a stripe of page between the two, which is a control wearing a halo rather than an edge that has thickened. Everywhere else the ring keeps its offset, and that is contrast rather than taste — flush against a filled control it would sit on a fill of its own family.

  A pointer resting on a focused field used to take the hairline a shade _under_ the ring it is now flush against, because `hover:` and `focus-within:` are one class each and the winner was whichever Tailwind generated last. The pair is spelled out, so the edge is one colour.

  The six field shells also stop holding every duration at 0ms while the focus is inside. That was the rule about a press applied one step too far: clicking into a field is a press, but the ring is the answer to the caret being somewhere, and it arrives from a Tab as often as from a click.

- **An `AccordionItem`'s title wraps, and the header is a heading at a level the caller chooses.** Two things about the same element. The title was wrapped in `truncate`, which is right for a label and wrong for the thing an accordion is most often a list of: an FAQ's title is a sentence, and an ellipsis in the middle of it loses the question. It wraps now, and `lines` clamps it where a caller wants one — the same word, and now the same table, `Typography` uses. And the header renders an `<h3>` whatever sits above it, so the natural way to ask for a different one was to pass a styled heading as the `title`, which nests a heading inside a heading; the documentation said to do exactly that. `headingLevel` on the `Accordion` sets it for the whole stack, which is where it belongs — the sections are siblings, and a run of headings at different levels is an outline that lies.

- **A field's height is a floor rather than a fixed row.** A TextField, a Select, a Combobox, a NumberField and the four date and time pickers all took the size ladder as an exact height, and a field holds a caller's own text — so text set larger than the step, which is the whole point of the tool that does it, had its glyphs cut off by the row around it. `classNames.shell` could repair it only with an `h-auto!`, and needing `!important` to beat your own class is the signal that the height was the wrong shape rather than the wrong number. Nothing moves at the library's own sizes. It stays an exact height on a Button, a Chip and everything else the library draws the contents of: those are flex children of a row a caller arranges, and a minimum height there is a control that stretches to whatever is beside it.

- **A `Typography` level's leading is a ratio rather than a length, and the root carries `neba-typography`.** The two halves of one problem: the scale paired each size with the line height it worked out to, and the component emitted nothing but utilities. So a caller who set a size of their own — which is what a figure, a display number or a hero line is — got a line box built for a size nobody asked for, with no selector to repair it from a stylesheet either, since a utility string is not a contract. Every level keeps exactly the ratio it was drawn at, so nothing moves at the scale's own sizes and an overridden one gets a line box in proportion. The class is a hook and carries no styling of its own, the way `neba-link` and `neba-portal` do.

- **A `ScrollZone` and a `Tabs` bar hold the wheel at their ends rather than handing it back.** Taking the wheel and then giving it up the moment the strip runs out is what makes the page lurch mid-flick: the reader is still pushing the strip and what answers is the article behind it. Both hold it now, and the pointer leaving the strip is what gives the page its wheel back. `overscroll-behavior: contain` does the same for the gestures the browser scrolls itself — a finger, a sideways trackpad swipe, and the wheel over a vertical zone — which used to carry on into the page at either end.

  This changes what `ScrollZone`'s `wheel` promises. The old wording said a strip with nothing left ahead of it was something to scroll past rather than something to be caught in; a caller who wanted that behaviour wants `wheel` off.

- **An `Anchor` finds its headings once instead of on every frame of a scroll.** It ran a `document.getElementById` for each row of the trail on every scroll frame, for an answer that changes only when the document does. The elements are kept and checked against `isConnected`, so a heading that arrives after the trail is still found.

- **An `AnimateMarquee` measures itself when its size changes, not on every render above it.** The measurement listed `children` as a dependency, so every render of whatever held the strip tore both resize observers down, put them back, and ran a `getComputedStyle` and an `offsetWidth` — a forced layout — for a strip that had not moved. The track is observed, so a change in what is on it is already reported.

- **The last two `Intl` objects a render was rebuilding are memoised.** `localeWeekStart` built an `Intl.DateTimeFormat` and an `Intl.Locale` on every render of a `Calendar`, a `DatePicker`, a `DateRangePicker` and a `DateTimePicker` — every keystroke and every hover anywhere inside one — and `graphemesOf` / `wordsOf` built an `Intl.Segmenter` on every call, for three text effects that ask on every frame they animate. Both go through a cache now, as the number and date formatters already did.

- **A `Transfer` and a `TreeSelect` fold their labels once instead of once per keystroke.** Both folded every row inside the filter, which put a `String.prototype.normalize` on every item for every character typed — a `Transfer` did it on every render, search or no search. The haystacks are built once per `items` now, which is the arrangement a `DataTable` and a `CommandPalette` already used. Nothing about what matches has changed.

- **A chart's data table is memoised, and reads the chart's own formatter.** The visually hidden table is built in the same render the crosshair's state lives in, so every cell of it was reconciled again for each pixel the pointer travelled across the picture — a row per point on a `ScatterChart`. It is `React.memo` now, and the frame's `format` is keyed on what the options say rather than on the identity of the object they arrived in, so a `format` written inline in the JSX no longer defeats it.

  One number moves with it: a `ScatterChart` with no `format` writes its table values the way its axis and its tooltip already write them, so `24000` reads as `24K` rather than `24,000`. It was the only chart whose table disagreed with its own picture.

### Fixed

- **A responsive slot no longer inherits into a nested component.** Every value that changes at a breakpoint resolves through a custom property, one per breakpoint, and only the breakpoints a caller names are written — so a slot an element did not write was whatever the nearest ancestor had written. A `GridContainer` inside a `Grid` read the _item's_ `--n-span-md` and came out a fraction of the width it had asked for, and the same shape covered every gutter, column count, flex direction and content measure in the library. The element that reads a slot now clears it, which an inline style still outranks.

- **A `NavigationMenu`'s panel keeps its surface.** The colour slots were declared on the Root, and the panel is portalled to the end of the document — so it was not a descendant of the element carrying them, `bg-(--n-panel-press)` painted nothing, and the panel opened as clear glass with the page readable straight through the links. Both ends of the component take the slots now, which is what every other portalling component in the library already did.

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

| What you import               | 1.11.0   | 1.12.0   |
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

---
title: Browser support
---

# Browser support

Neba supports Chrome and Edge 111, Firefox 113 and Safari 16.4, and every later release of each, on desktop and on mobile. All four were released between March and May 2023. Older browsers are not supported: without `color-mix()` most of the colours are not drawn, and further back the components stop running at all.

## Minimum versions

| Browser                         | Minimum version | Released   |
| ------------------------------- | --------------- | ---------- |
| Chrome, Chrome for Android      | 111             | March 2023 |
| Edge                            | 111             | March 2023 |
| Firefox, Firefox for Android    | 113             | May 2023   |
| Safari on macOS, iOS and iPadOS | 16.4            | March 2023 |

- Other Chromium-based browsers, such as Opera and Samsung Internet, are supported from the release built on Chromium 111.
- A browser on iOS or iPadOS that uses the system's WebKit engine follows the Safari row, so what counts is the OS version of the device. An iPhone or iPad that cannot update past iOS 15 or iPadOS 15 is outside the range.
- Every Firefox ESR release from 115 onwards is inside the range.

The test suite runs against the current releases of Chromium, Firefox and WebKit, so the minimum versions are not tested in a browser. They are derived from the features in the next section and from the range Neba's dependencies declare, and on every change a CI check compares what the stylesheet and the source use against [MDN's compatibility data](https://github.com/mdn/browser-compat-data).

To keep your build from transpiling for browsers Neba does not render in, target the same range. As a [Browserslist](https://browsersl.ist) query:

```text
chrome >= 111, edge >= 111, firefox >= 113, safari >= 16.4, ios_saf >= 16.4
```

## What sets the minimum

| Requirement | Chrome, Edge | Firefox | Safari | What depends on it |
| --- | --- | --- | --- | --- |
| [`color-mix()`](https://developer.mozilla.org/docs/Web/CSS/Reference/Values/color_value/color-mix) | 111 | 113 | 16.2 | Every derived colour token: fills, hover and press states, tints, lines and focus rings |
| [`oklch()`](https://developer.mozilla.org/docs/Web/CSS/Reference/Values/color_value/oklch) | 111 | 113 | 15.4 | The palette those tokens are mixed from |
| [Base UI](https://base-ui.com/react/overview/about) 1.x | 111 | 113 | 16.4 | Behaviour and accessibility of the interactive components |
| [Tailwind CSS](https://tailwindcss.com/docs/compatibility) v4 | 111 | 128 | 16.4 | The utility classes compiled into `neba/styles.css` |

The minimum for a browser is the highest number in its column, with one exception. Tailwind CSS lists Firefox 128 because of `@property`, and since v4.1 it ships fallbacks that let Firefox 113 to 127 render the same utilities. If you import `neba/tailwind.css` into your own Tailwind build, use Tailwind CSS v4.1 or later to keep those fallbacks.

### Why it cannot go lower

`color-mix()` is the limit. A colour family is five tokens, and every other shade is mixed from them in the browser, which is also what lets a project override one token and have every state follow. A browser without `color-mix()` does not fall back to a nearby colour. The token is still defined, but a property that reads it through `var()` becomes invalid at computed-value time and behaves as `unset`, so a filled Button has no fill, and hover and press stop changing its colour. Colours precomputed at build time would render, but they would ignore every token a project overrides.

Base UI declares the same range. Its supported browsers are the ones that implement every feature marked Baseline Widely Available when its last major version was released, which its [Browserslist file](https://github.com/mui/base-ui/blob/master/.browserslistrc) lists as Chrome and Edge 111, Firefox 113 and Safari 16.4. A lower minimum would run the interactive components on browsers their primitives do not support.

Transpiling or polyfilling does not change this. The JavaScript is not the limit: without checking for it first, the code in Neba and Base UI relies on nothing newer than Chrome 102, Firefox 112 and Safari 16, the `inert` attribute included. A transpiler and polyfills can lower that, but nothing can add `color-mix()` to a browser.

## Differences inside the range

Every browser in the range renders and runs every component. A few details use newer features, and a browser without one of them leaves that detail out.

| Detail | Needs | In an older browser inside the range |
| --- | --- | --- |
| The 2px focus ring on [TextField](./components/inputs/text-field), [Select](./components/inputs/select), [Combobox](./components/inputs/combobox), [NumberField](./components/inputs/number-field), the date and time pickers, [Rating](./components/inputs/rating) and a selectable [DataTable](./components/display/data-table) | [`:has()`](https://developer.mozilla.org/docs/Web/CSS/Reference/Selectors/:has): Firefox 121 | The fields draw no ring and show focus through their border or fill, and a DataTable through its active row. Rating still draws the ring, but on a star focused by a click as well as by the keyboard |
| The box or icon beside a label in [Checkbox](./components/inputs/checkbox), [RadioGroup](./components/inputs/radio-group), [Switch](./components/inputs/switch), [Alert](./components/feedback/alert) and other rows with a label | The `lh` unit: Firefox 120 | It sits at the top of the label's first line instead of centred on it |
| Splitting text into characters and words in [AnimateSplit](./components/transitions/animate-split), [AnimateTyping](./components/transitions/animate-typing) and [AnimateScramble](./components/transitions/animate-scramble) | [`Intl.Segmenter`](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/Intl/Segmenter): Firefox 125 | Text is split by code point and by whitespace. An emoji made of several code points arrives in pieces, and a sentence in a language written without spaces is treated as one word |
| The travelling light in [AnimateLighting](./components/transitions/animate-lighting) | [`@property`](https://developer.mozilla.org/docs/Web/CSS/Reference/At-rules/@property): Firefox 128 | The light stays in one place |
| The first day of the week in [Calendar](./components/inputs/calendar) and the date pickers | [`Intl.Locale` week data](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/Intl/Locale/getWeekInfo): Firefox 153 | The week starts on Sunday unless `weekStartsOn` is set |
| The edge fades of [ScrollArea](./components/layout/scroll-area) and [Tabs](./components/surfaces/tabs) in a right-to-left layout | [`:dir()`](https://developer.mozilla.org/docs/Web/CSS/Reference/Selectors/:dir): Chrome and Edge 120 | The left and right fades are not swapped |
| `timeline="view"` on the Animate components, such as [AnimateFade](./components/transitions/animate-fade) | [`animation-timeline`](https://developer.mozilla.org/docs/Web/CSS/Reference/Properties/animation-timeline): Chrome and Edge 115, Safari 26, not yet in Firefox | The effect runs once on mount instead of following the scroll |

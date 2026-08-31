---
title: Calendar
order: 16
---

# Calendar

<p class="neba-lede">A month, inline, with the days it is holding lit up. The same grid the four pickers open, without a popup around it — for a page where the dates are always visible.</p>

<Demo src="calendar/hero" align="center" />

```tsx
import { Calendar } from 'neba';

<Calendar value={day} onValueChange={setDay} />;
```

## Props

<PropsTable name="Calendar" />

Native `<div>` attributes pass through to the root. The shared axes are described in [prop conventions](../../design/prop-conventions).

### What it is not

A scheduler. The cells are the control ladder's heights — 32px at `md` — so `renderDay` is room for a dot, a count or a bar under the number, and not for a day's worth of entries. A component that drew those would need a different grid, and calling this one that would be a promise the sizes cannot keep.

Use it for choosing, filtering and marking. Reach for [DatePicker](./date-picker) when the date should be behind a field instead.

## Examples

### mode

`mode` decides what the value is.

| `mode`             | `value`                                      |
| ------------------ | -------------------------------------------- |
| `single` (default) | `Date \| null`                               |
| `multiple`         | `Date[]`                                     |
| `range`            | `{ start: Date \| null, end: Date \| null }` |

In `multiple`, clicking a day that is already held takes it back out — the only way a pointer can undo one.

In `range`, the first click sets the start and the second sets the end. A click **below** the start begins a new span rather than inverting the old one, because inverting is the behaviour that makes a reader believe they mis-clicked. Once a span is finished, the next click starts another.

<Demo src="calendar/modes">

<<< @/.vitepress/demos/calendar/modes.tsx

</Demo>

### renderDay

Whatever it returns is drawn inside the day cell, under the number. The cell is `position: relative`, so an absolutely positioned mark lands where you put it.

A hook rather than an `events` prop: the caller is the only one who knows what a day _has_ on it, and taking a data shape here would mean having an opinion about one.

<Demo src="calendar/marks">

<<< @/.vitepress/demos/calendar/marks.tsx

</Demo>

### granularity

The same three units [DatePicker](./date-picker) offers. At `month` or `year` the grid opens on that view and a click there is the answer, and the value is the first day of what was chosen.

### minDate · maxDate · shouldDisableDate

Read at `granularity`, exactly as on [DatePicker](./date-picker). A blocked cell keeps its place in the grid and is marked with `aria-disabled` rather than the `disabled` attribute, so it stays on the arrow-key path.

### bordered and elevation

`bordered` draws the sheet the picker's popup draws. Turn it off for a bare grid to put inside a [Card](../surfaces/card) that already has an edge. `elevation` is `0` by default — a calendar sitting in a page is not floating.

## Keyboard

| Key                   | What it does                                              |
| --------------------- | --------------------------------------------------------- |
| `←` `→` `↑` `↓`       | Moves by a day or a week, stepping the month at the edges |
| `Home` / `End`        | To the start or the end of the week                       |
| `PageUp` / `PageDown` | By a month — with `Shift`, by a year                      |

The grid has a single tab stop, so `Tab` leaves it rather than walking forty-two cells.

## Accessibility

- The grid is a `role="grid"` of `role="gridcell"` buttons, each named with the full date rather than the bare number.
- A held day carries `aria-selected`; today carries `aria-current="date"` and a dot under the number.
- Anything `renderDay` draws is inside the cell's accessible name unless you mark it `aria-hidden`. A dot that repeats what a label already says should be hidden; a count that adds something should not.

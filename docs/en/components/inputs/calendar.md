---
title: Calendar
order: 16
---

# Calendar

<p class="neba-lede">A month, inline, with the days it is holding lit up. The same grid the four pickers open, without a popup around it: for a page where the dates are always visible.</p>

<Demo src="calendar/hero" align="center" />

```tsx
import { Calendar } from 'neba';

<Calendar value={day} onValueChange={setDay} />;
```

## Props

<PropsTable name="Calendar" />

Native `<div>` attributes pass through to the root. The shared axes are described in [prop conventions](../../design/prop-conventions).

When the date should be behind a field instead, use [DatePicker](./date-picker).

## Examples

### mode

`mode` decides what the value is.

| `mode`             | `value`                                      |
| ------------------ | -------------------------------------------- |
| `single` (default) | `Date \| null`                               |
| `multiple`         | `Date[]`                                     |
| `range`            | `{ start: Date \| null, end: Date \| null }` |

In `multiple`, clicking a day that is already held takes it back out.

In `range`, the first click sets the start and the second sets the end. A click **below** the start begins a new span rather than inverting the old one. Once a span is finished, the next click starts another.

<Demo src="calendar/modes">

<<< @/.vitepress/demos/calendar/modes.tsx

</Demo>

### renderDay

Whatever it returns is drawn inside the day cell, under the number. The cell is `position: relative`, so an absolutely positioned mark lands where you put it. A cell is as tall as a control (32px at `md`), which is room for a dot, a count or a bar and not for a day's worth of entries.

<Demo src="calendar/marks">

<<< @/.vitepress/demos/calendar/marks.tsx

</Demo>

### granularity

The same three units [DatePicker](./date-picker) offers. At `month` or `year` the grid opens on that view and a click there is the answer, and the value is the first day of what was chosen.

### minDate · maxDate · shouldDisableDate

Read at `granularity`, exactly as on [DatePicker](./date-picker). A blocked cell keeps its place in the grid and is marked with `aria-disabled` rather than the `disabled` attribute, so it stays on the arrow-key path.

### bordered and elevation

`bordered` draws the sheet the picker's popup draws, with the same edge and the same padding for each `size`. Turn it off for a bare grid to put inside a [Card](../surfaces/card) that already has an edge. `elevation` gives the calendar a shadow from the same ladder as every surface, with or without the sheet, and is `0` by default.

## Accessibility

- The grid is a `role="grid"` of `role="gridcell"` buttons, each named with the full date rather than the bare number.
- The grid has a single tab stop, so `Tab` leaves it rather than walking forty-two cells.
- The arrow keys move by a day or a week and step the month at the edges. Under RTL, `←` is the next day.
- `Home` and `End` move to the start or the end of the week. `PageUp` and `PageDown` move by a month, or by a year with `Shift`.
- A held day carries `aria-selected`; today carries `aria-current="date"` and a dot under the number. In `multiple` and `range` mode the grid carries `aria-multiselectable`.
- The grid is named by the month on screen, in a polite live region that says the new month again when a stepper or an arrow key changes it. The month and year buttons are named by the month and year they show and described by what pressing them does.
- Anything `renderDay` draws is inside the cell's accessible name unless you mark it `aria-hidden`. A dot that repeats what a label already says should be hidden; a count that adds something should not.

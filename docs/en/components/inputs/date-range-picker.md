---
title: DateRangePicker
order: 18
---

# DateRangePicker

<p class="neba-lede">A span between two days. Two months side by side, with the band drawn as the pointer moves — before the second click lands.</p>

<Demo src="date-range-picker/hero" />

```tsx
import { DateRangePicker } from 'neba';

<DateRangePicker label="Stay" startPlaceholder="Check in" endPlaceholder="Check out" clearable />;
```

## Props

<PropsTable name="DateRangePicker" />

### The value is one object

```ts
interface DateRange {
  start: Date | null;
  end: Date | null;
}
```

An object rather than a `[Date, Date]` tuple, and rather than two props. A range is one value — it is chosen in one gesture, cleared in one gesture and validated as a whole — and the two names are what stop a caller writing the end into the start.

`onValueChange` is always called with an object, never with `null`, so a cleared range is `{ start: null, end: null }` and a caller never has to test for two kinds of empty.

Half a range is a real state: it is what the picker holds between the first click and the second, and it is reported as `{ start, end: null }`. Abandoning it — closing the popup without a second click — throws it away rather than leaving a range with one end in a form.

### Two panels, one calendar

A range that crosses a month boundary is the ordinary case, not the exception, so `monthCount` is `2` by default. The two panels are one calendar in two halves: the left one has no forward stepper, the right one has no back stepper, and either header's month and year buttons move the pair.

The panels deliberately **do not** draw the leading and trailing days of the neighbouring months, which a single [DatePicker](./date-picker) does. With both panels showing six full weeks, the 1st of August would appear twice — once as a trailing day of July and once as itself — and two cells with the same name in one popup is ambiguous to a pointer and outright broken to a screen reader.

### Clicking backwards is not a mistake

The second click may land before the first. That is the same range typed in the other order, not an error to reject, so the two ends are sorted before they are reported. The click after a finished range starts a new one.

## Examples

### Presets

The shortcut column is what a reporting UI is actually used through — nobody picks "the last 30 days" one day at a time.

<Demo src="date-range-picker/presets">

<<< @/.vitepress/demos/date-range-picker/presets.tsx

</Demo>

A preset's `value` may be a range or a function returning one. Prefer the function: a range computed at render time would be wrong for anyone who left the tab open overnight.

### One panel, and bounds

<Demo src="date-range-picker/one-month">

<<< @/.vitepress/demos/date-range-picker/one-month.tsx

</Demo>

## Submitting

`name` renders two hidden inputs of the same name, so the two ends arrive together:

```ts
const form = new FormData(event.currentTarget);
const [start, end] = form.getAll('stay'); // '2026-07-03', '2026-07-09'
```

Both are local `YYYY-MM-DD`, the shape a native `<input type="date">` submits.

## Accessibility

- Each panel is a `role="grid"` of `role="gridcell"` buttons named with the full date, and each keeps a tab stop of its own — `Tab` moves between the two grids rather than through eighty-four cells.
- Both ends carry `aria-selected`; the days between them carry the band and nothing else, because being inside a range is not the same as being chosen.
- The footer says which end the next click will fill. The trigger says the same thing with its two halves, but the trigger is behind the popup while the popup is up.

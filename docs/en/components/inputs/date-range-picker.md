---
title: DateRangePicker
order: 18
---

# DateRangePicker

<p class="neba-lede">Chooses a span made of a start and an end day. Two calendars sit side by side, and the span previews under the pointer before the second click lands.</p>

<Demo src="date-range-picker/hero" />

```tsx
import { DateRangePicker } from 'neba';

<DateRangePicker label="Stay" startPlaceholder="Check in" endPlaceholder="Check out" clearable />;
```

## Props

<PropsTable name="DateRangePicker" />

The value is a single object rather than a tuple.

```ts
interface DateRange {
  start: Date | null;
  end: Date | null;
}
```

`onValueChange` is always called with an object, so a cleared range is `{ start: null, end: null }` and there is never a second kind of empty to test for.

The half state between the first and second click is reported as `{ start, end: null }`, and closing the popup without a second click throws it away. A second click that lands before the first is not an error — it is the same range in the other order, so the ends are sorted.

The remaining props — `minDate` · `maxDate` · `shouldDisableDate` · `variant` · `size` — behave as they do on [DatePicker](./date-picker).

## Examples

### monthCount

Defaults to `2`. The two panels are one calendar in halves: the left has no forward stepper, the right has no back stepper, and either header moves the pair.

With two panels, the leading and trailing days of neighbouring months are not drawn, so the same date never appears in both panels at once.

<Demo src="date-range-picker/one-month">

<<< @/.vitepress/demos/date-range-picker/one-month.tsx

</Demo>

### presets

Puts common spans beside the popup as buttons. A preset's `value` may be a range object or a function returning one. Prefer the function — a range computed once at render time is wrong for anyone who left the tab open.

<Demo src="date-range-picker/presets">

<<< @/.vitepress/demos/date-range-picker/presets.tsx

</Demo>

### name

`name` renders two hidden inputs of the same name, so both ends submit together.

```ts
const form = new FormData(event.currentTarget);
const [start, end] = form.getAll('stay'); // '2026-07-03', '2026-07-09'
```

Both are local `YYYY-MM-DD`, the shape a native `<input type="date">` submits.

## Accessibility

- Each panel is a `role="grid"` with a tab stop of its own, so `Tab` moves between the two grids rather than through eighty-four cells.
- Only the two ends carry `aria-selected`; the days between them get the band and nothing else.
- The popup footer says which end the next click will fill.

---
title: DateRangePicker
order: 18
flutter: true
---

# DateRangePicker

<p class="neba-lede">Chooses a span made of a start and an end day. Two calendars sit side by side, and the span previews under the pointer before the second click lands.</p>

<Demo src="date-range-picker/hero" minHeight="440" />

::: fw react

```tsx
import { DateRangePicker } from 'neba';

<DateRangePicker label="Stay" startPlaceholder="Check in" endPlaceholder="Check out" clearable />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaDateRangePicker(
  label: const Text('Stay'),
  startPlaceholder: const Text('Check in'),
  endPlaceholder: const Text('Check out'),
  clearable: true,
);
```

:::

## Props

<PropsTable name="DateRangePicker" />

::: fw react

Native `<div>` attributes pass through to the root. Only `color`, `defaultValue` and `children` are excluded, since the table above spells them differently.

The value is a single object rather than a tuple.

```ts
interface DateRange {
  start: Date | null;
  end: Date | null;
}
```

`onValueChange` is always called with an object, so a cleared range is `{ start: null, end: null }` and there is never a second kind of empty to test for.

:::

::: fw flutter

The value is a single `NebaDateRange` rather than two values, the same type as a `NebaCalendar.range`'s value, so a span chosen on an inline calendar and one chosen here can share a variable.

```dart
const NebaDateRange({DateTime? start, DateTime? end});
```

`onValueChange` is always called with a `NebaDateRange`, so a cleared range is `NebaDateRange()`, both ends `null`, and there is never a second kind of empty to test for. Left `null`, `value` lets the picker keep its own state from `defaultValue`. `format` is a function from a `DateTime` to the words each end of the trigger shows, `startPlaceholder` and `endPlaceholder` are widgets, usually a `Text`, and `showStartIcon: false` is React's `startIcon={false}`. `name`, `required` and `classNames` are not there, as on [DatePicker](./date-picker).

:::

The value changes once, when the second end is chosen. The first <Fw react="click" flutter="press" /> only marks where the range starts, and closing the popup before a second <Fw react="click" flutter="press" /> keeps the range that was there. A second <Fw react="click" flutter="press" /> that lands before the first starts a new range there, as a [Calendar](./calendar) in `range` mode does.

The remaining props (`minDate` · `maxDate` · `shouldDisableDate` · `variant` · `size`) behave as they do on [DatePicker](./date-picker).

## Examples

### monthCount

Defaults to `2`. The two panels are one calendar in halves: the left has no forward stepper, the right has no back stepper, and either header moves the pair.

With two panels, the leading and trailing days of neighbouring months are not drawn, so the same date never appears in both panels at once.

<Demo src="date-range-picker/one-month" minHeight="440">

::: fw react

<<< @/.vitepress/demos/date-range-picker/one-month.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_range_picker/one_month.dart

:::

</Demo>

### presets

Puts common spans beside the popup as buttons.

::: fw react

A preset's `value` may be a range object or a function returning one. Prefer the function: a range computed once at render time is wrong for anyone who left the tab open.

:::

::: fw flutter

`NebaDateRangePreset` takes a fixed `value`, and `NebaDateRangePreset.computed` a function that works the range out when the preset is pressed. Prefer the second: a range computed once when the screen is built is wrong for anyone who left it open.

:::

<Demo src="date-range-picker/presets" minHeight="440">

::: fw react

<<< @/.vitepress/demos/date-range-picker/presets.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_range_picker/presets.dart

:::

</Demo>

### labelPlacement

`notch` and `float` work as they do on [TextField](./text-field#labelplacement). A resting `float` label stands in for both placeholders and moves up once either end is chosen, the trigger takes the focus or the popup opens. The calendar glyph keeps it in the notch unless you pass <Fw react="startIcon={false}" flutter="showStartIcon: false" code />.

<Demo src="date-range-picker/label-placement" minHeight="440">

::: fw react

<<< @/.vitepress/demos/date-range-picker/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_range_picker/label_placement.dart

:::

</Demo>

::: fw react

### name

`name` renders two inputs of the same name, so both ends submit together and arrive as `FormData.getAll(name)`. Inside a [Form](./form), `onSubmit` gets them as a two-item array under `name`, a `required` range holds the submit while it is empty, and an error the Form is handed under `name` shows under the field.

```ts
const form = new FormData(event.currentTarget);
const [start, end] = form.getAll('stay'); // '2026-07-03', '2026-07-09'
```

Both are local `YYYY-MM-DD`, the shape a native `<input type="date">` submits.

:::

## Accessibility

::: fw react

- Each panel is a `role="grid"` with a tab stop of its own, so `Tab` moves between the two grids rather than through eighty-four cells.
- Only the two ends carry `aria-selected`; the days between them get the band and nothing else.
- The popup footer says which end the next click will fill.

:::

::: fw flutter

- The trigger is one node to a screen reader: a button named by a `Text` label, which says both ends as its value and is heard as collapsed or expanded.
- Each panel is a table of named cells with a tab stop of its own, so `Tab` moves between the two grids rather than through eighty-four cells.
- Only the two ends are heard as selected; the days between them get the band and nothing else.
- The popup footer says which end the next press will fill.

:::

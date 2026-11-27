---
title: Calendar
order: 16
flutter: true
---

# Calendar

<p class="neba-lede">A month, inline, with the days it is holding lit up. The same grid the four pickers open, without a popup around it: for a page where the dates are always visible.</p>

<Demo src="calendar/hero" align="center" />

::: fw react

```tsx
import { Calendar } from 'neba';

<Calendar value={day} onValueChange={setDay} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaCalendar(
  value: day,
  onValueChange: (DateTime? next) => setState(() => day = next),
);
```

:::

## Props

<PropsTable name="Calendar" />

::: fw react

Native `<div>` attributes pass through to the root. The shared axes are described in [prop conventions](../../design/prop-conventions).

:::

::: fw flutter

`mode` is the constructor: `NebaCalendar` holds one day, `NebaCalendar.multiple` a list and `NebaCalendar.range` a span, and each takes `value`, `defaultValue` and `onValueChange` in its own type. A `value` left `null` keeps the calendar's own state, and one that goes from a day to `null` empties it. Every date is a local `DateTime` compared on its year, month and day. `weekStartsOn` counts as `DateTime.weekday` does, `DateTime.monday` being `1` and `DateTime.sunday` `7`, where React counts Sunday as `0`.

The month and weekday names are a `NebaDateNames`, not `Intl`. Flutter's widgets layer has no date names (`WidgetsLocalizations` holds a text direction and a few editing labels) and the package takes no dependency on `intl`, so English is built in and any other language is registered once, by its tag, as the widgets' own words are. Its patterns also decide how a cell is read and in which order the header's two buttons stand. The week's first day still follows the locale's region without any registration, from the week data CLDR keeps.

```dart
registerNebaDateNames(
  'ko',
  const NebaDateNames(
    months: <String>['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
    shortMonths: <String>['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
    weekdays: <String>['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'],
    shortWeekdays: <String>['월', '화', '수', '목', '금', '토', '일'],
    monthYear: '{year}년 {month}',
    fullDate: '{year}년 {month} {day}일 {weekday}',
    mediumDate: '{year}. {monthNumber}. {day}.',
  ),
);
```

:::

When the date should be behind a field instead, use [DatePicker](./date-picker).

## Examples

### mode

`mode` decides what the value is.

::: fw react

| `mode`             | `value`                                      |
| ------------------ | -------------------------------------------- |
| `single` (default) | `Date \| null`                               |
| `multiple`         | `Date[]`                                     |
| `range`            | `{ start: Date \| null, end: Date \| null }` |

:::

::: fw flutter

| Constructor             | `value`                                               |
| ----------------------- | ----------------------------------------------------- |
| `NebaCalendar`          | `DateTime?`                                           |
| `NebaCalendar.multiple` | `List<DateTime>`                                      |
| `NebaCalendar.range`    | `NebaCalendarRange(start: DateTime?, end: DateTime?)` |

:::

In `multiple`, <Fw react="clicking" flutter="pressing" /> a day that is already held takes it back out.

In `range`, the first <Fw react="click" flutter="press" /> sets the start and the second sets the end. A <Fw react="click" flutter="press" /> **below** the start begins a new span rather than inverting the old one. Once a span is finished, the next <Fw react="click" flutter="press" /> starts another.

<Demo src="calendar/modes">

::: fw react

<<< @/.vitepress/demos/calendar/modes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/calendar/modes.dart

:::

</Demo>

### renderDay

::: fw react

Whatever it returns is drawn inside the day cell, under the number. The cell is `position: relative`, so an absolutely positioned mark lands where you put it. A cell is as tall as a control (32px at `md`), which is room for a dot, a count or a bar and not for a day's worth of entries.

:::

::: fw flutter

Whatever it returns is drawn inside the day cell, in a `Stack` the size of the cell, so a `Positioned` mark lands where you put it and anything else is centred on the number. A cell is as tall as a control (32 logical pixels at `md`), which is room for a dot, a count or a bar and not for a day's worth of entries.

:::

<Demo src="calendar/marks">

::: fw react

<<< @/.vitepress/demos/calendar/marks.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/calendar/marks.dart

:::

</Demo>

### granularity

The same three units [DatePicker](./date-picker) offers. At `month` or `year` the grid opens on that view and a <Fw react="click" flutter="press" /> there is the answer, and the value is the first day of what was chosen.

### minDate · maxDate · shouldDisableDate

Read at `granularity`, exactly as on [DatePicker](./date-picker).

::: fw react

A blocked cell keeps its place in the grid and is marked with `aria-disabled` rather than the `disabled` attribute, so it stays on the arrow-key path.

:::

::: fw flutter

A blocked cell keeps its place in the grid and is heard as unavailable while it keeps its focus node, so it stays on the arrow-key path.

:::

### bordered and elevation

`bordered` draws the sheet the picker's popup draws, with the same edge and the same padding for each `size`. Turn it off for a bare grid to put inside a [Card](../surfaces/card) that already has an edge. `elevation` gives the calendar a shadow from the same ladder as every surface, with or without the sheet, and is `0` by default.

## Accessibility

::: fw react

- The grid is a `role="grid"` of `role="gridcell"` buttons, each named with the full date rather than the bare number.
- The grid has a single tab stop, so `Tab` leaves it rather than walking forty-two cells. It starts on the held day, or on today; a server-rendered calendar starts it on the 1st and moves it to today once the page has hydrated, since the server's today can be another day.
- Rendered on a server with no value, `defaultMonth` or `month`, the calendar opens on the month of the server's clock, hydrates that same month, and moves to the reader's month once the page has hydrated if the two differ. With no `locale`, the month and day names are written in `en-US` until then and in the reader's language after. Pass `defaultMonth` and `locale` to draw the final calendar from the first paint.
- The arrow keys move by a day or a week and step the month at the edges. Under RTL, `←` is the next day.
- `Home` and `End` move to the start or the end of the week. `PageUp` and `PageDown` move by a month, or by a year with `Shift`.
- A held day carries `aria-selected`; today carries `aria-current="date"` and a dot under the number. In `multiple` and `range` mode the grid carries `aria-multiselectable`.
- The grid is named by the month on screen, in a polite live region that says the new month again when a stepper or an arrow key changes it. The month and year buttons are named by the month and year they show and described by what pressing them does.
- Anything `renderDay` draws is inside the cell's accessible name unless you mark it `aria-hidden`. A dot that repeats what a label already says should be hidden; a count that adds something should not.

:::

::: fw flutter

- The grid is a table of rows, its column heads read by the weekday's whole name, and each day a cell holding a button named with the full date rather than the bare number.
- The grid has a single tab stop, so `Tab` leaves it rather than walking forty-two cells. It starts on the held day, or on today when today is on screen, or on the 1st.
- The arrow keys move by a day or a week and step the month at the edges, starting from whichever cell holds the focus. Under RTL, `←` is the next day.
- `Home` and `End` move to the start or the end of the week. `Page Up` and `Page Down` move by a month, or by a year with `Shift`. `Enter` and `Space` choose the focused cell.
- A held day is heard as selected. Today is heard with the word for it after its date, and carries a dot under the number; in the month and year grids the same goes for this month and this year.
- The grid is named by the month on screen, and a live region says the new month again when a stepper or an arrow key changes it. The month and year buttons are named by the month and year they show, described by what pressing them does, and heard as expanded while their grid is open.
- Anything `renderDay` draws is read with the cell's name unless you wrap it in `ExcludeSemantics`. A dot that repeats what a label already says should be excluded; a count that adds something should not.

:::

---
title: TimePicker
order: 16
flutter: true
---

# TimePicker

<p class="neba-lede">Takes a time of day from hour, minute and second columns. Each column is a scrolling listbox.</p>

<Demo src="time-picker/hero" minHeight="400" />

::: fw react

```tsx
import { TimePicker } from 'neba';

<TimePicker label="Starts at" placeholder="Pick a time" minuteStep={15} clearable />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaTimePicker(
  label: const Text('Starts at'),
  placeholder: const Text('Pick a time'),
  minuteStep: 15,
  clearable: true,
);
```

:::

## Props

<PropsTable name="TimePicker" />

::: fw react

Native `<div>` attributes pass through to the root. Only `color`, `defaultValue` and `children` are excluded, since the table above spells them differently.

`value` is a `Date | null`. `referenceDate` is the day a chosen time is written onto while the value is still empty; it defaults to the start of today, so an hour picked on an empty picker lands on the hour, and is held still for as long as the picker is mounted, so a popup left open across midnight does not move the value onto a new day.

:::

::: fw flutter

`value` is a `DateTime?`, so it carries a day as well as a time. Left `null`, the picker keeps its own state from `defaultValue`, and a `value` that goes from a time to `null` empties it. `referenceDate` is the day a chosen time is written onto while the value is still empty; it defaults to the start of today, so an hour picked on an empty picker lands on the hour, and is held for as long as the picker is built, so a popup left open across midnight does not move the value onto a new day.

`shouldDisableTime` is handed a `NebaTimeUnit`, `hour`, `minute`, `second` or `meridiem`, where React passes a string. `format` is a function from the `DateTime` to the words the trigger shows, and `showStartIcon: false` is React's `startIcon={false}`. `name`, `required` and `classNames` are not there, as on [DatePicker](./date-picker).

AM, PM, how a time is written and whether the locale reads a 12-hour dial come from the locale's `NebaDateNames`, the table [Calendar](./calendar) names its months from. English is built in; another language registers its own, with `{dialHour}`, `{hour}`, `{paddedHour}`, `{minute}`, `{second}` and `{dayPeriod}` in its patterns:

```dart
registerNebaDateNames(
  'ko',
  const NebaDateNames(
    months: <String>['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
    shortMonths: <String>['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
    weekdays: <String>['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'],
    shortWeekdays: <String>['월', '화', '수', '목', '금', '토', '일'],
    am: '오전',
    pm: '오후',
    time: '{dayPeriod} {dialHour}:{minute}',
    timeWithSeconds: '{dayPeriod} {dialHour}:{minute}:{second}',
  ),
);
```

The trigger writes the time in the locale's pattern whatever `hour12` says, as it does in React. Pass a `format` to write a 24-hour time beside a 24-hour dial in a 12-hour language.

:::

`closeOnSelect` defaults to `false`: an hour and a minute both have to be given, so the popup does not close on the first, and the footer carries a Done button.

## Examples

### minuteStep · secondStep · hour12

`minuteStep` and `secondStep` are the intervals each column lists. `hour12` follows the locale by default, and a 12-hour column runs `12, 1, 2 … 11` rather than `0…11`.

<Demo src="time-picker/columns" minHeight="400">

::: fw react

<<< @/.vitepress/demos/time-picker/columns.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/time_picker/columns.dart

:::

</Demo>

### minTime · maxTime · shouldDisableTime

`minTime` and `maxTime` are compared against the **span a row stands for**, not a single instant. With a minimum of 09:30, the hour `9` covers 09:00–09:59 and overlaps what is allowed, so it stays available while `00` through `29` grey out in the minute column. That is what keeps 09:30 reachable. A time that lands outside the bounds when a row is pressed, such as the hour `9` on 10:15, is moved to the nearest bound, 09:30, before it is committed.

`shouldDisableTime` is handed the instant a row would produce and the column it belongs to, so a rule may be as coarse as "no lunch hour" or as fine as one minute.

<Demo src="time-picker/bounds" minHeight="420">

::: fw react

<<< @/.vitepress/demos/time-picker/bounds.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/time_picker/bounds.dart

:::

</Demo>

### labelPlacement

`notch` and `float` work as they do on [TextField](./text-field#labelplacement). The clock glyph at the start of the trigger is where a `float` label would rest, so the label stays in the notch unless you pass <Fw react="startIcon={false}" flutter="showStartIcon: false" code />. It also stays there while the popup is open.

<Demo src="time-picker/label-placement" minHeight="400">

::: fw react

<<< @/.vitepress/demos/time-picker/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/time_picker/label_placement.dart

:::

</Demo>

### showNowButton and clearable

`showNowButton` adds a button that jumps to the current time; `clearable` adds one that empties the value.

## Accessibility

::: fw react

- Each column is a `role="listbox"` of `role="option"` rows. The column names come from the `locale`, and `labels` writes them out instead.
- Each column is one tab stop, on its chosen row or its first. ↑ and ↓ move within the column and Home and End jump to its ends; Enter, Space or a press chooses the row.
- The chosen row carries `aria-selected`; a blocked one carries `aria-disabled` rather than the `disabled` attribute, so it stays reachable and announces why it cannot be taken.
- The chosen row in each column is scrolled into view when the popup opens.
- A live region beside the columns reads out the whole time whenever it changes.

:::

::: fw flutter

- The trigger is one node to a screen reader: a button named by a `Text` label, which says the time it shows as its value and is heard as collapsed or expanded.
- Each column is a group named by its column's word, holding one button per row named by what the row says. The column names come from the `locale`, and `labels` writes them out instead.
- Each column is one tab stop, on its chosen row or its first, and `Tab` takes the columns in order. ↑ and ↓ move within the column and `Home` and `End` jump to its ends; `Enter`, `Space` or a press chooses the row. `Escape`, a press outside and the focus leaving the popup close it and give the focus back to the trigger.
- The chosen row is heard as selected; a blocked one is heard as unavailable and keeps its focus node, so it stays on the arrow keys' path.
- The chosen row in each column is scrolled into view when the popup opens.
- A live region beside the columns says the whole time whenever it changes.

:::

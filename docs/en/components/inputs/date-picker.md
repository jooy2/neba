---
title: DatePicker
order: 15
flutter: true
---

# DatePicker

<p class="neba-lede">Chooses one day from a calendar popup. The month name and the year each open a grid of their own, so distant dates stay a few clicks away. Set <code>granularity</code> and the picker asks for a whole month or a whole year instead.</p>

<Demo src="date-picker/hero" minHeight="420" />

::: fw react

```tsx
import { DatePicker } from 'neba';

<DatePicker label="Ships on" placeholder="Pick a day" clearable />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaDatePicker(
  label: const Text('Ships on'),
  placeholder: const Text('Pick a day'),
  clearable: true,
);
```

:::

## Props

<PropsTable name="DatePicker" />

::: fw react

Native `<div>` attributes pass through to the root. Only `color`, `defaultValue` and `children` are excluded, since the table above spells them differently.

`value` is a `Date | null`. Everything is compared on the **local calendar day** rather than on a UTC timestamp. The hidden input a form submits is a local string too (`YYYY-MM-DD` for a day), so nothing shifts by a day the way `toISOString()` would. A `disabled` picker submits nothing, and a `required` one that is empty holds the form back through the browser's own validation and moves the focus to its trigger; the same holds for every picker.

The popup is portalled to the end of `<body>`, with `neba-portal` on the positioner.

:::

::: fw flutter

`value` is a `DateTime?`, compared on the **local calendar day**, and a day chosen keeps the time of day the value already had. Left `null`, the picker keeps its own state from `defaultValue`; a `value` that goes from a day to `null` empties it. `label`, `placeholder`, `description` and `error` are widgets, usually a `Text`, and `semanticLabel` names a picker with no label of its own, as `aria-label` does.

`format` is a function from the `DateTime` to the words the trigger shows, where React takes `Intl` options, and its default writes the date in the locale's `NebaDateNames`, as [Calendar](./calendar) names its days. `showStartIcon: false` is React's `startIcon={false}`. `name`, `required` and `classNames` are not there: nothing submits a Flutter form for the picker, and its parts are styled through the shared props. The popup is drawn in the app's root `Overlay`, as a [Popover](../surfaces/popover)'s is, and lines up with the field's edge.

:::

## Examples

### variant

The same three weights as [TextField](./text-field), drawn on the same shell.

<Demo src="date-picker/variants" minHeight="420">

::: fw react

<<< @/.vitepress/demos/date-picker/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/variants.dart

:::

</Demo>

### size

A day cell uses the control heights: 32px at `md`, the same as a [Button](./button) or [TextField](./text-field) of that `size`.

<Demo src="date-picker/sizes" minHeight="560">

::: fw react

<<< @/.vitepress/demos/date-picker/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/sizes.dart

:::

</Demo>

### labelPlacement

`notch` and `float` work as they do on [TextField](./text-field#labelplacement). The calendar glyph at the start of the trigger is where a `float` label would rest, so the label stays in the notch unless you pass <Fw react="startIcon={false}" flutter="showStartIcon: false" code />. It also stays there while the popup is open.

<Demo src="date-picker/label-placement" minHeight="420">

::: fw react

<<< @/.vitepress/demos/date-picker/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/label_placement.dart

:::

</Demo>

### Three views

The month name in the header opens a grid of twelve months, and the year opens a grid of twelve years, where the steppers move a page at a time. Choosing a year hands over to the month view, and the two buttons are printed in the order the locale writes them. All three views are the same width and height, so switching between them never resizes the popup.

### granularity

`granularity` says which of the three grids the reader may stop on. At `month` and `year` the calendar opens on that grid and a <Fw react="click" flutter="press" /> there is the answer. There is no day view to fall into.

::: fw react

The value stays a `Date`, normalised to the first day of what was chosen, so March is 1 March and 2026 is 1 January. The trigger's default `format` becomes `{ year: 'numeric', month: 'long' }` or `{ year: 'numeric' }`, the footer's shortcut says "This month" or "This year", and `name` submits `YYYY-MM` or `YYYY`.

:::

::: fw flutter

The value stays a `DateTime`, normalised to the first day of what was chosen, so March is 1 March and 2026 is 1 January. The trigger's default `format` writes the month of a year or the bare year, and the footer's shortcut says "This month" or "This year".

:::

Climbing is unchanged, so a month picker still reaches any month of any year in two <Fw react="clicks" flutter="presses" />.

<Demo src="date-picker/granularity" minHeight="440">

::: fw react

<<< @/.vitepress/demos/date-picker/granularity.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/granularity.dart

:::

</Demo>

### minDate · maxDate · shouldDisableDate

`minDate` and `maxDate` are compared at `granularity`, against the whole span a cell stands for. At `day` a maximum of the 27th at 09:00 still leaves the 27th pickable; at `month` a minimum of 15 March leaves March pickable, since part of March is allowed. Use `shouldDisableDate` for cells inside the range that still cannot be chosen: it is handed the value that cell would produce, so at `month` it receives the 1st.

::: fw react

A blocked cell keeps its place in the grid and is marked with `aria-disabled` rather than the `disabled` attribute, so it stays on the arrow-key path.

:::

::: fw flutter

A blocked cell keeps its place in the grid and is heard as unavailable while it keeps its focus node, so it stays on the arrow-key path.

:::

<Demo src="date-picker/bounds" minHeight="440">

::: fw react

<<< @/.vitepress/demos/date-picker/bounds.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/bounds.dart

:::

</Demo>

### disabled · readOnly · error

<Demo src="date-picker/states" minHeight="440">

::: fw react

<<< @/.vitepress/demos/date-picker/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/states.dart

:::

</Demo>

### showTodayButton and clearable

`showTodayButton` adds a button in the popup footer that jumps to the current unit: today, this month or this year, whichever `granularity` is asking for. `clearable` adds a button on the trigger that empties the value, and a Clear button beside the shortcut in the footer.

## Accessibility

::: fw react

- The trigger is a button rather than a text input, and the date is chosen in the calendar. `Space` or `Enter` opens the calendar and focuses the chosen cell, and `Escape` closes it without choosing.
- The grid has a single tab stop, so `Tab` leaves it rather than walking forty-two cells.
- The arrow keys move by a day or a week and step the month at the edges. `Home` and `End` move to the start or the end of the week. `PageUp` and `PageDown` move by a month, or by a year with `Shift`.
- The grid is a `role="grid"` of `role="gridcell"` buttons, each named with the full date rather than the bare number.
- The chosen cell carries `aria-selected`; the current day, month or year carries `aria-current="date"` and a dot under the number.
- The grid is named by the month on screen, in a polite live region that says the new month again when a stepper or an arrow key changes it. The month and year buttons are named by the month and year they show and described by what pressing them does.
- The trigger's accessible name is `label` followed by what the trigger shows, so a reader hears the date that is chosen and not only what the field is for. `description` and `error` are wired to it with `aria-describedby`.

:::

::: fw flutter

- The trigger is one node to a screen reader: a button named by a `Text` label, which says the date it shows as its value and is heard as collapsed or expanded. A `Text` description and error are read after the name.
- The trigger is a button rather than a text input, and the date is chosen in the calendar. A press, `Space` or `Enter` opens the calendar and focuses the chosen cell; `Escape`, a press outside and a choice close it and give the focus back to the trigger.
- The grid has a single tab stop, so `Tab` leaves it rather than walking forty-two cells, and the focus leaving the popup closes it.
- The arrow keys move by a day or a week and step the month at the edges. `Home` and `End` move to the start or the end of the week. `Page Up` and `Page Down` move by a month, or by a year with `Shift`.
- The grid is a table of cells, each holding a button named with the full date rather than the bare number. The chosen cell is heard as selected; the current day, month or year is heard with the word for it and carries a dot under the number.
- The grid is named by the month on screen, and a live region says the new month again when a stepper or an arrow key changes it. The month and year buttons are named by the month and year they show and described by what pressing them does.
- The trigger's focus ring shows for keyboard focus only, as a button's does; its edge still answers any focus.

:::

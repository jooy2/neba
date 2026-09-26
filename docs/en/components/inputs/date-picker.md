---
title: DatePicker
order: 15
---

# DatePicker

<p class="neba-lede">Chooses one day from a calendar popup. The month name and the year each open a grid of their own, so distant dates stay a few clicks away. Set <code>granularity</code> and the picker asks for a whole month or a whole year instead.</p>

<Demo src="date-picker/hero" />

```tsx
import { DatePicker } from 'neba';

<DatePicker label="Ships on" placeholder="Pick a day" clearable />;
```

## Props

<PropsTable name="DatePicker" />

Native `<div>` attributes pass through to the root. Only `color`, `defaultValue` and `children` are excluded, since the table above spells them differently.

`value` is a `Date | null`. Everything is compared on the **local calendar day** rather than on a UTC timestamp. The hidden input a form submits is a local string too (`YYYY-MM-DD` for a day), so nothing shifts by a day the way `toISOString()` would. A `disabled` picker submits nothing, and a `required` one that is empty holds the form back through the browser's own validation and moves the focus to its trigger; the same holds for every picker.

The popup is portalled to the end of `<body>`, with `neba-portal` on the positioner.

## Examples

### variant

The same three weights as [TextField](./text-field), drawn on the same shell.

<Demo src="date-picker/variants">

<<< @/.vitepress/demos/date-picker/variants.tsx

</Demo>

### size

A day cell uses the control heights: 32px at `md`, the same as a [Button](./button) or [TextField](./text-field) of that `size`.

<Demo src="date-picker/sizes">

<<< @/.vitepress/demos/date-picker/sizes.tsx

</Demo>

### labelPlacement

`notch` and `float` work as they do on [TextField](./text-field#labelplacement). The calendar glyph at the start of the trigger is where a `float` label would rest, so the label stays in the notch unless you pass `startIcon={false}`. It also stays there while the popup is open.

<Demo src="date-picker/label-placement">

<<< @/.vitepress/demos/date-picker/label-placement.tsx

</Demo>

### Three views

The month name in the header opens a grid of twelve months, and the year opens a grid of twelve years, where the steppers move a page at a time. Choosing a year hands over to the month view, and the two buttons are printed in the order the locale writes them. All three views are the same width and height, so switching between them never resizes the popup.

### granularity

`granularity` says which of the three grids the reader may stop on. At `month` and `year` the calendar opens on that grid and a click there is the answer. There is no day view to fall into.

The value stays a `Date`, normalised to the first day of what was chosen, so March is 1 March and 2026 is 1 January. The trigger's default `format` becomes `{ year: 'numeric', month: 'long' }` or `{ year: 'numeric' }`, the footer's shortcut says "This month" or "This year", and `name` submits `YYYY-MM` or `YYYY`.

Climbing is unchanged, so a month picker still reaches any month of any year in two clicks.

<Demo src="date-picker/granularity">

<<< @/.vitepress/demos/date-picker/granularity.tsx

</Demo>

### minDate · maxDate · shouldDisableDate

`minDate` and `maxDate` are compared at `granularity`, against the whole span a cell stands for. At `day` a maximum of the 27th at 09:00 still leaves the 27th pickable; at `month` a minimum of 15 March leaves March pickable, since part of March is allowed. Use `shouldDisableDate` for cells inside the range that still cannot be chosen: it is handed the value that cell would produce, so at `month` it receives the 1st.

A blocked cell keeps its place in the grid and is marked with `aria-disabled` rather than the `disabled` attribute, so it stays on the arrow-key path.

<Demo src="date-picker/bounds">

<<< @/.vitepress/demos/date-picker/bounds.tsx

</Demo>

### disabled · readOnly · error

<Demo src="date-picker/states">

<<< @/.vitepress/demos/date-picker/states.tsx

</Demo>

### showTodayButton and clearable

`showTodayButton` adds a button in the popup footer that jumps to the current unit: today, this month or this year, whichever `granularity` is asking for. `clearable` adds a button on the trigger that empties the value.

## Accessibility

- The trigger is a button rather than a text input, and the date is chosen in the calendar. `Space` or `Enter` opens the calendar and focuses the chosen cell, and `Escape` closes it without choosing.
- The grid has a single tab stop, so `Tab` leaves it rather than walking forty-two cells.
- The arrow keys move by a day or a week and step the month at the edges. `Home` and `End` move to the start or the end of the week. `PageUp` and `PageDown` move by a month, or by a year with `Shift`.
- The grid is a `role="grid"` of `role="gridcell"` buttons, each named with the full date rather than the bare number.
- The chosen cell carries `aria-selected`; the current day, month or year carries `aria-current="date"` and a dot under the number.
- The grid is named by the month on screen, in a polite live region that says the new month again when a stepper or an arrow key changes it. The month and year buttons are named by the month and year they show and described by what pressing them does.
- The trigger's accessible name is `label` followed by what the trigger shows, so a reader hears the date that is chosen and not only what the field is for. `description` and `error` are wired to it with `aria-describedby`.

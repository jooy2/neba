---
title: DatePicker
order: 15
---

# DatePicker

<p class="neba-lede">Chooses one day from a calendar popup. The month name and the year each open a grid of their own, so distant dates stay a few clicks away.</p>

<Demo src="date-picker/hero" />

```tsx
import { DatePicker } from 'neba';

<DatePicker label="Ships on" placeholder="Pick a day" clearable />;
```

## Props

<PropsTable name="DatePicker" />

`value` is a `Date | null`. There is no date library underneath.

Everything is compared on the **local calendar day** rather than on a UTC timestamp. The hidden input a form submits is a local `YYYY-MM-DD` string too, so nothing shifts by a day the way `toISOString()` would.

### Three views

The two buttons in the header each open a different grid.

- **The month name** — a grid of twelve months.
- **The year** — a grid of twelve years, with the steppers moving a page at a time.

Choosing a year hands over to the month view. The two buttons are printed in the order the locale writes them. All three views are the same width and height, so switching between them never resizes the popup.

## Examples

### variant

The same three weights as [TextField](./text-field), drawn on the same shell.

<Demo src="date-picker/variants">

<<< @/.vitepress/demos/date-picker/variants.tsx

</Demo>

### size

A day cell uses the control heights — 32px at `md`, the same as a [Button](./button) or [TextField](./text-field) of that `size`.

<Demo src="date-picker/sizes">

<<< @/.vitepress/demos/date-picker/sizes.tsx

</Demo>

### minDate · maxDate · shouldDisableDate

`minDate` and `maxDate` are compared at day granularity, so a maximum of the 27th at 09:00 still leaves the 27th pickable. Use `shouldDisableDate` for days inside the range that still cannot be chosen.

A blocked cell keeps its place in the grid and is marked with `aria-disabled` rather than the `disabled` attribute, so it stays on the arrow-key path.

<Demo src="date-picker/bounds">

<<< @/.vitepress/demos/date-picker/bounds.tsx

</Demo>

### disabled · readOnly · error

<Demo src="date-picker/states">

<<< @/.vitepress/demos/date-picker/states.tsx

</Demo>

### showTodayButton and clearable

`showTodayButton` adds a button in the popup footer that jumps to today; `clearable` adds a button on the trigger that empties the value.

## Keyboard

The trigger is a button rather than a text input — the date comes from the calendar.

| Key                   | What it does                                              |
| --------------------- | --------------------------------------------------------- |
| `Space` / `Enter`     | Opens the calendar and focuses the chosen day             |
| `←` `→` `↑` `↓`       | Moves by a day or a week, stepping the month at the edges |
| `Home` / `End`        | To the start or the end of the week                       |
| `PageUp` / `PageDown` | By a month — with `Shift`, by a year                      |
| `Escape`              | Closes without choosing                                   |

The grid has a single tab stop, so `Tab` leaves it rather than walking forty-two cells.

## Accessibility

- The grid is a `role="grid"` of `role="gridcell"` buttons, each named with the full date rather than the bare number.
- The chosen day carries `aria-selected`; today carries `aria-current="date"` and a dot under the number.
- `label` becomes the trigger's accessible name, and `description` and `error` are wired to it with `aria-describedby`.
- The popup is portalled to the end of `<body>`, with `neba-portal` on the positioner.

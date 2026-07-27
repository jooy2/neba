---
title: DatePicker
order: 15
---

# DatePicker

<p class="neba-lede">One day, chosen from a calendar. The month name and the year are each a button that opens a grid of its own, so any month is two clicks away and any year is three.</p>

<Demo src="date-picker/hero" />

```tsx
import { DatePicker } from 'neba';

<DatePicker label="Ships on" placeholder="Pick a day" clearable />;
```

## Props

<PropsTable name="DatePicker" />

### The value is a `Date`

Not a string, not a timestamp, and not a wrapper object. `Date` is what the platform already has, it is what `Intl` formats, and it is what every other library a caller might be using can be converted from in one line.

There is no date library underneath, on purpose. Neba's one runtime dependency is Base UI, and a component library that quietly adds `date-fns` — or worse, picks a side in the dayjs/luxon/Temporal argument on its consumer's behalf — has made a decision that was not its to make. The arithmetic here is a dozen lines and the naming is `Intl`, which knows more about month names in more languages than any bundled table ever will.

Everything is compared on the **local** calendar day, never on the underlying timestamp. A calendar day is a thing a person is looking at on a wall, not an instant on a line — so a picker in Seoul and a picker in São Paulo both light up the cell that says 27. For the same reason the hidden input a form submits writes `2026-07-27` in local time: `toISOString()` on that same value would report `2026-07-26`, which is the single most expensive bug a date picker can ship.

### Three views, not one

A picker that only steps a month at a time puts a birthday thirty years back a hundred and eighty clicks away. So the header carries two buttons rather than a label:

- **the month name** opens a grid of twelve months,
- **the year** opens a grid of twelve years, with the steppers moving a page at a time.

Choosing a year hands over to the month grid rather than all the way back to days: having just said which year, the next question is which month. The two buttons are printed in the order the locale writes them — `July 2026` in English, `2026년 7월` in Korean — and the three views are the same width _and_ the same height, so switching between them never resizes the popup under the pointer that opened it.

## Examples

### Variants

The same three weights as [TextField](./text-field), on the same shell. A form where the date field is a different height, radius or colour from the fields around it is a form that looks assembled rather than designed.

<Demo src="date-picker/variants">

<<< @/.vitepress/demos/date-picker/variants.tsx

</Demo>

### Sizes

A day cell is on the control ladder: 32px at `md`, which is a `md` Button and a `md` TextField. A calendar dropped beside a form is on the form's grid.

<Demo src="date-picker/sizes">

<<< @/.vitepress/demos/date-picker/sizes.tsx

</Demo>

### Bounds

`minDate` and `maxDate` are compared at day granularity, so a maximum of the 27th at 09:00 still leaves the 27th pickable. `shouldDisableDate` blocks the days that are inside the range but still not available.

A blocked cell keeps its place in the grid and reports itself with `aria-disabled` rather than the `disabled` attribute — a disabled button leaves the tab order and the grid's arrow-key path with it, so a reader would fall into a hole at every blocked day.

<Demo src="date-picker/bounds">

<<< @/.vitepress/demos/date-picker/bounds.tsx

</Demo>

### States

<Demo src="date-picker/states">

<<< @/.vitepress/demos/date-picker/states.tsx

</Demo>

## Why the trigger cannot be typed into

The trigger is a button, exactly as a [Select](./select)'s is, and not a text input.

Parsing a date out of free text is locale-dependent in a way that cannot be done honestly without a date library. A field that understands `27/7/26` in one browser and not in the next — or that reads it as the 7th of December for half its readers — is worse than one that never claimed to. The calendar is where the answer comes from, and the three views are what make that fast enough not to miss the keyboard.

## Keyboard

| Key                   | What it does                                                   |
| --------------------- | -------------------------------------------------------------- |
| `Space` / `Enter`     | Opens the calendar; the grid takes the focus on the chosen day |
| `←` `→` `↑` `↓`       | Moves by a day or a week, stepping the month at the edges      |
| `Home` / `End`        | To the start or the end of the week                            |
| `PageUp` / `PageDown` | By a month — with `Shift`, by a year                           |
| `Escape`              | Closes without choosing                                        |

The grid has a single roving tab stop, so `Tab` leaves it rather than walking forty-two cells.

## Accessibility

- The grid is a `role="grid"` of `role="gridcell"` buttons, each named with the full date rather than the bare number — `Monday, July 27, 2026`, not `27`.
- The chosen day carries `aria-selected`; today carries `aria-current="date"` and a dot under the number, because a colour on its own says it only to some readers.
- `label` names the trigger, and `description` and `error` are wired to it with `aria-describedby`.
- The popup is portalled to the end of `<body>`; its positioner carries `neba-portal` as a hook for an app that has scoped its CSS reset to a subtree.

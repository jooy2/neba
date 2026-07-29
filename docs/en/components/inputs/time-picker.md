---
title: TimePicker
order: 16
---

# TimePicker

<p class="neba-lede">Takes a time of day from hour, minute and second columns. Each column is a scrolling listbox.</p>

<Demo src="time-picker/hero" />

```tsx
import { TimePicker } from 'neba';

<TimePicker label="Starts at" placeholder="Pick a time" minuteStep={15} clearable />;
```

## Props

<PropsTable name="TimePicker" />

`value` is a `Date | null`. `referenceDate` is the day a chosen time is written onto while the value is still empty; it defaults to today and is held still for as long as the picker is mounted, so a popup left open across midnight does not move the value onto a new day.

`closeOnSelect` defaults to `false`: an hour and a minute both have to be given, so the popup does not close on the first, and the footer carries a Done button.

## Examples

### minuteStep · secondStep · hour12

`minuteStep` and `secondStep` are the intervals each column lists. `hour12` follows the locale by default, and a 12-hour column runs `12, 1, 2 … 11` rather than `0…11`.

<Demo src="time-picker/columns">

<<< @/.vitepress/demos/time-picker/columns.tsx

</Demo>

### minTime · maxTime · shouldDisableTime

`minTime` and `maxTime` are compared against the **span a row stands for**, not a single instant. With a minimum of 09:30, the hour `9` covers 09:00–09:59 and overlaps what is allowed, so it stays available while `00` through `25` grey out in the minute column. That is what keeps 09:30 reachable.

`shouldDisableTime` is handed the instant a row would produce and the column it belongs to, so a rule may be as coarse as "no lunch hour" or as fine as one minute.

<Demo src="time-picker/bounds">

<<< @/.vitepress/demos/time-picker/bounds.tsx

</Demo>

### showNowButton and clearable

`showNowButton` adds a button that jumps to the current time; `clearable` adds one that empties the value.

## Accessibility

- Each column is a `role="listbox"` of `role="option"` rows. The column names come from `labels` and have English defaults.
- The chosen row carries `aria-selected`; a blocked one carries `aria-disabled` rather than the `disabled` attribute, so it stays reachable and announces why it cannot be taken.
- The chosen row in each column is scrolled into view when the popup opens.
- A live region beside the columns reads out the whole time whenever it changes.

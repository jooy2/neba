---
title: DateTimePicker
order: 17
---

# DateTimePicker

<p class="neba-lede">Chooses a day and a time in one popup. Use it where the two together make a single moment — a scheduled send, a publish time.</p>

<Demo src="date-time-picker/hero" />

```tsx
import { DateTimePicker } from 'neba';

<DateTimePicker label="Publish at" placeholder="Pick a moment" minuteStep={15} clearable />;
```

## Props

<PropsTable name="DateTimePicker" />

The calendar props behave as they do on [DatePicker](./date-picker) and the clock props as they do on [TimePicker](./time-picker). The calendar and the clock sit side by side at the same height.

`closeOnSelect` defaults to `false` and the footer carries a Done button, since two answers have to be given before the popup can close.

Choosing a day leaves the time alone, and choosing a time leaves the day alone, so the two can be picked in either order.

## Examples

### minDate · maxDate

The bounds are read at **full precision**, not just to the day. A `minDate` of 09:30 on the 27th leaves the 27th selectable in the calendar and greys out only the times before 09:30 in the clock; on any later day nothing is blocked.

That is what a rule like "no earlier than now" needs.

<Demo src="date-time-picker/bounds">

<<< @/.vitepress/demos/date-time-picker/bounds.tsx

</Demo>

### What the trigger shows

The trigger wears the calendar glyph and not the clock. The value is written as one string with `Intl`, combining the date and the time.

## Accessibility

- The calendar is a `role="grid"` and the clock a set of `role="listbox"` columns. See [DatePicker](./date-picker#accessibility) and [TimePicker](./time-picker#accessibility) for the details.
- The trigger's accessible name reads as one sentence covering both halves.

---
title: DateTimePicker
order: 17
---

# DateTimePicker

<p class="neba-lede">A day and a time, in one popup. The calendar and the clock sit side by side at exactly the same height, so the popup is one rectangle rather than two of different sizes pushed together.</p>

<Demo src="date-time-picker/hero" />

```tsx
import { DateTimePicker } from 'neba';

<DateTimePicker label="Publish at" placeholder="Pick a moment" minuteStep={15} clearable />;
```

## Props

<PropsTable name="DateTimePicker" />

Everything else it does is [DatePicker](./date-picker)'s and [TimePicker](./time-picker)'s, unchanged: the same three calendar views, the same column behaviour, the same `Date` value. What is worth reading here is the part that is genuinely different.

### The bounds are read at full precision

This is where a DateTimePicker earns being its own component rather than two fields in a row.

`minDate` on a [DatePicker](./date-picker) is day-granular — the 27th either exists or it does not. Here it is not, because the ordinary rule a scheduling form needs is "not before **now**", and now is a time as well as a day. So a `minDate` of 09:30 on the 27th leaves the 27th selectable in the calendar and greys out the morning in the clock.

<Demo src="date-time-picker/bounds">

<<< @/.vitepress/demos/date-time-picker/bounds.tsx

</Demo>

The clock's own check is the span test [TimePicker](./time-picker) makes, moved onto the absolute timeline so it knows which day the columns are writing into. On the boundary day the hours before the minimum are blocked; on any later day none of them are.

### One value, two halves, no order

Choosing a day changes the day and leaves the clock alone. Choosing an hour changes the clock and leaves the day alone. A picker that reset the time to midnight every time the date was corrected would make choosing a moment an ordered task, and nobody reads a popup in the order it was written.

That is also why `closeOnSelect` defaults to `false` and the footer carries **Done**: a moment is a day _and_ a time, so closing on the first of the two would leave the second unanswered.

### One glyph, not two

The trigger wears the calendar and not the clock. A control cannot say two things at once, and the date is the part a reader scans for.

## Accessibility

The calendar is a `role="grid"` and the clock is a set of `role="listbox"` columns, exactly as they are in the two components this one is made of — see [DatePicker](./date-picker#accessibility) and [TimePicker](./time-picker#accessibility). The trigger writes both halves into one string with `Intl`, so what a screen reader reads out is one sentence rather than two fields it has to join up.

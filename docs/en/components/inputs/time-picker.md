---
title: TimePicker
order: 16
---

# TimePicker

<p class="neba-lede">A time of day, chosen from columns. The bounds are checked against the span a row stands for, which is what keeps half past nine reachable when the minimum is 09:30.</p>

<Demo src="time-picker/hero" />

```tsx
import { TimePicker } from 'neba';

<TimePicker label="Starts at" placeholder="Pick a time" minuteStep={15} clearable />;
```

## Props

<PropsTable name="TimePicker" />

### Columns, not a dial

Columns are the shape that answers what a time picker is actually asked. "Half past nine" is two glances, and "any time at all, on the hour" is a column you never touch. A clock face is prettier and needs a `transform` to read, which [this library does not have](../../guide/design-language).

The chosen row in each column is scrolled into view once, when the popup opens. That is the only imperative work in the component and it is not optional: a column of sixty minutes that opens at `00` while the value is `45` has hidden its own answer.

`hour12` defaults to whatever the locale does, and the 12-hour column runs `12, 1, 2 … 11` — the order a dial is read in, not `0…11`.

### The value is a `Date`

Not a string and not a number of minutes, because everything else in this library that carries a moment is a `Date`, and because a bare time has nowhere to record that it crossed a daylight-saving boundary. `referenceDate` is the day a chosen time is written onto while the picker is still empty; it defaults to today and is held still for as long as the picker is mounted, so a popup left open across midnight does not quietly move the value onto a new day.

## Examples

### Steps, seconds and a 24-hour dial

<Demo src="time-picker/columns">

<<< @/.vitepress/demos/time-picker/columns.tsx

</Demo>

### Bounds

This is the detail that separates a working time picker from a frustrating one. `minTime` and `maxTime` are compared against the **span** a row covers, not against one instant inside it: with a minimum of 09:30 the hour `9` covers 09:00:00–09:59:59, which overlaps what is allowed, so it stays available and the minute column is where `00` through `25` grey out.

Comparing the whole candidate instead — which is the obvious implementation — hides the `9` entirely and makes half past nine unreachable.

<Demo src="time-picker/bounds">

<<< @/.vitepress/demos/time-picker/bounds.tsx

</Demo>

`shouldDisableTime` is handed the instant a row would produce and the column it belongs to, so a rule may be as coarse as "no lunch hour" or as fine as one minute.

## Why the popup stays open

`closeOnSelect` is `false` here and `true` on [DatePicker](./date-picker), which is not an inconsistency. A time is two answers — the hour and the minute — and closing after the first would make choosing 9:30 a matter of opening the popup twice. The footer therefore carries a **Done** button, which is the thing to press that means "that is the one".

## Accessibility

- Each column is a `role="listbox"` of `role="option"` rows, named `Hour`, `Minute`, `Second` and `AM/PM`. Those four names come from `labels` and have English defaults.
- The chosen row in each column carries `aria-selected`; a blocked one carries `aria-disabled` rather than the `disabled` attribute, so it stays reachable and announces why it cannot be taken.
- A live region beside the columns reads out the whole time whenever it changes. Three unlabelled lists of numbers say nothing on their own to someone reading the screen rather than looking at it.

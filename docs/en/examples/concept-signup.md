---
title: Sign-up page
order: 4
aside: false
---

# Sign-up page

<p class="neba-lede">Registration for Kestrel, in three steps. This is the library's fields with nothing else in the way: every kind of answer a form can ask for, and the states around them: <code>label</code>, <code>description</code> and <code>error</code> are the same three slots on all of them.</p>

<Demo src="concepts/signup" min-height="620px" />

The source is one file: `docs/.vitepress/demos/concepts/signup.tsx`. The flow works: fill the first step in and Continue turns on.

## Which field asks what

| Question | Component | Worth noticing |
| --- | --- | --- |
| Personal or team | `SegmentedButton` | One of a small, visible set: no popup to open |
| Name, email, password | `TextField` | `type="password"`, `autoComplete` and `startIcon` all pass through to the native control |
| Password strength | `ProgressLinear` | `max={4}` with a colour per band; it appears only once something has been typed |
| Date of birth | `DatePicker` | `maxDate={new Date()}` makes a future date unselectable rather than an error afterwards |
| Country | `Select` | A fixed list, so the value is chosen and never typed |
| Workspace URL | `TextField` | `startIcon` and `endIcon` carry the prefix and the domain, so the field itself stays the slug |
| Seats | `NumberField` | Bounded by `min` and `max`, with the steppers the type of answer implies |
| Disciplines | `Combobox` | `multiple`, and anything not on the list is offered as the last row |
| Plan | `RadioGroup` `Radio` | Two options with a `description` each, because the choice needs the detail next to it |
| Logo | `FilePicker` | `accept`, `maxSize` and `maxFiles` are enforced before anything is handed back |
| Email code | `OtpField` | `length={6}` with `groupSize={3}`; paste fills every box at once |
| Terms, newsletter | `Checkbox` `Switch` | A checkbox is consent to submit with; a switch is a setting that takes effect as it is flipped |

## Notes

- Errors appear on blur, not on every keystroke, so a field is never red before it has been left.
- The step buttons are gated on the fields of that step alone: `Continue` stays disabled until the step is valid, and the last step also needs the code and the terms.
- The right-hand column is `Card`, `List`, `Timeline` and `Blockquote`: what the trial includes, what happens next, and one quote.
- Layout is `GridContainer` and `Grid` at `md`, so the two columns become one on a phone with nothing to configure.

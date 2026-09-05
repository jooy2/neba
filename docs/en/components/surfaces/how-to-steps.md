---
title: HowToSteps
order: 15
---

# HowToSteps

<p class="neba-lede">A guide the reader walks through: numbered steps down one side, one step's instructions at a time beside them, and a way forward under those. It ends, and says so.</p>

<Demo src="how-to-steps/hero" minHeight="420" />

```tsx
import { HowToSteps } from 'neba';

<HowToSteps
  title="Schedule a job with cron"
  steps={[
    { title: 'Open your crontab', content: 'crontab -e opens yours in $EDITOR.' },
    { title: 'Write the schedule', content: 'Five fields, then the command.' }
  ]}
/>;
```

## Props

<PropsTable name="HowToSteps" />

Every native `<div>` attribute passes through, apart from `color`, `title` and `content`, which the component owns. The shared axes are described under [prop conventions](../../design/prop-conventions).

### HowToStep

<PropsTable name="HowToStep" />

The steps are an array rather than children, which is the one place this component could not be built the other way: the list beside the body and the body itself are two renderings of the same data, and the panel is sized against every step rather than the one showing.

## Examples

### orientation

`vertical` is the default: the numbers run down one side with the body beside them, which takes any number of steps and any amount to say about each. Below `sm` it stacks. `horizontal` runs the numbers across the top, and is only honest while every title is short.

<Demo src="how-to-steps/orientation" minHeight="360">

<<< @/.vitepress/demos/how-to-steps/orientation.tsx

</Demo>

### maxHeight

How tall the guide may get before it scrolls — a number is pixels. The list and the body scroll inside it rather than the sheet growing, and the current row is kept in view as the step changes.

<Demo src="how-to-steps/scrolling" minHeight="400">

<<< @/.vitepress/demos/how-to-steps/scrolling.tsx

</Demo>

### step · completed

Both states are controllable. Pass `step` with `onStepChange` to keep the position yourself — in a URL, in a form's state — and `completed` with `onCompletedChange` for the end.

<Demo src="how-to-steps/controlled" minHeight="380">

<<< @/.vitepress/demos/how-to-steps/controlled.tsx

</Demo>

### icon

Each step takes a glyph, drawn before the title over its own body. Only there: a row in the list already carries a numbered disc, and a glyph beside it is a second mark making the same claim. What an icon is good for is saying what _kind_ of step this is — a terminal, a file, a warning.

```tsx
{ title: 'Open your crontab', icon: <TerminalIcon />, content: … }
```

### divider

A hairline between the list and the body — down the inner edge while they are two columns, along the bottom of the list once they have stacked. On by default: the two are different kinds of thing, and space alone leaves that to a gap a narrow screen is about to take away.

<Demo src="how-to-steps/divider" minHeight="320">

<<< @/.vitepress/demos/how-to-steps/divider.tsx

</Demo>

### transition

How a step arrives when the reader moves to it, from the same vocabulary [`transition`](../../design/prop-conventions) uses everywhere — an effect name, or the object form for the duration, the easing, the direction. `'none'` turns it off, and a reduced-motion preference does too.

It runs on the panel and never on anything that is pressed: the buttons and the list rows hold still, and what animates is the content they changed.

<Demo src="how-to-steps/transition" minHeight="340">

<<< @/.vitepress/demos/how-to-steps/transition.tsx

</Demo>

### navigation · completion

`navigation={false}` drops the row of buttons and leaves the list as the only way to move, for a guide inside a page that has navigation of its own. `completion={false}` removes the finished state entirely: the last step is simply the last step.

<Demo src="how-to-steps/bare" minHeight="480">

<<< @/.vitepress/demos/how-to-steps/bare.tsx

</Demo>

### variant · size · color

The three weights say what they say everywhere, and the sheet is never dyed by `color` — what carries the family is the numbers, the connector and the buttons. `text` is the one to reach for inside a [Card](./card), which is already a sheet.

### headingLevel

`title` is drawn as an `<h3>` and a step's title one level below it, at `<h4>`. `headingLevel` moves that starting point, because a level is a claim about the page rather than about the component: a guide sitting directly under an `<h1>` should be an `<h2>`, and the same guide inside a section should be an `<h4>`.

```tsx
<HowToSteps steps={steps} title="Getting started" headingLevel={2} />
```

### Steps with anything in them

`content` takes a node, so a step can hold a [CodeBlock](../display/code-block), a screenshot through `image`, a form, or another component entirely. The panel keeps the height of the tallest step, so a step with a code block in it does not resize the card when the reader reaches it — and nothing is remounted as the step changes, so a form halfway through a guide still holds what was typed into it.

## Accessibility

- The list is a list of buttons, not a tablist. The current row carries `aria-current="step"`, which says the panels are ordered and the reader is expected to arrive at them in that order.
- Each row is read as "Step 3: Use it" — the disc is decoration, and a number drawn beside a title is not a number a screen reader announces. A `title` that is a node is read as itself instead, there being no string to build that sentence out of.
- The steps that are not showing stay in the document so the panel can keep its height, and are `inert`: out of the tab order, off the accessibility tree, and out of a find-in-page.
- Give the guide a `title` when a page has more than one.

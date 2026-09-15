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

## Examples

### orientation

`vertical` is the default. The numbers run down one side with the body beside them, and below `sm` the two stack. `horizontal` runs the numbers across the top and suits a guide whose titles are all short.

<Demo src="how-to-steps/orientation" minHeight="360">

<<< @/.vitepress/demos/how-to-steps/orientation.tsx

</Demo>

### maxHeight

How tall the guide may get before it scrolls: a number is pixels. The list and the body scroll inside it rather than the sheet growing, and the current row is kept in view as the step changes.

<Demo src="how-to-steps/scrolling" minHeight="400">

<<< @/.vitepress/demos/how-to-steps/scrolling.tsx

</Demo>

### step · completed

Both states are controllable. Pass `step` with `onStepChange` to keep the position yourself (in a URL, in a form's state), and `completed` with `onCompletedChange` for the end.

<Demo src="how-to-steps/controlled" minHeight="380">

<<< @/.vitepress/demos/how-to-steps/controlled.tsx

</Demo>

### icon

Each step takes a glyph, drawn before the title over the step's own body and not in the list. Use it to say what kind of step this is, such as a terminal, a file or a warning.

```tsx
{ title: 'Open your crontab', icon: <TerminalIcon />, content: … }
```

### divider

A hairline between the list and the body, drawn down the inner edge while they are two columns and along the bottom of the list once they have stacked. It is on by default.

<Demo src="how-to-steps/divider" minHeight="320">

<<< @/.vitepress/demos/how-to-steps/divider.tsx

</Demo>

### transition

How a step arrives when the reader moves to it, from the same vocabulary [`transition`](../../design/prop-conventions) uses everywhere: an effect name, or the object form for the duration, the easing, the direction. `'none'` turns it off, and a reduced-motion preference does too.

It runs on the panel only, and the buttons and the list rows hold still.

<Demo src="how-to-steps/transition" minHeight="340">

<<< @/.vitepress/demos/how-to-steps/transition.tsx

</Demo>

### navigation · completion

`navigation={false}` drops the row of buttons and leaves the list as the only way to move, for a guide inside a page that has navigation of its own. `completion={false}` removes the finished state entirely: the last step is simply the last step.

<Demo src="how-to-steps/bare" minHeight="480">

<<< @/.vitepress/demos/how-to-steps/bare.tsx

</Demo>

### variant · size · color

The three weights say what they say everywhere. `color` never dyes the sheet and reaches the numbers, the connector and the buttons instead. Use `text` inside a [Card](./card), which is already a sheet.

### headingLevel

`title` is drawn as an `<h3>` and a step's title one level below it, at `<h4>`. Set `headingLevel` to move that starting point to fit the page, such as `2` for a guide directly under an `<h1>` or `4` for one inside a section.

```tsx
<HowToSteps steps={steps} title="Getting started" headingLevel={2} />
```

### content

`content` takes a node, so a step can hold a [CodeBlock](../display/code-block), a screenshot through `image`, a form, or another component entirely. The panel keeps the height of the tallest step, so reaching a step with a code block in it does not resize the card. Nothing is remounted as the step changes, so a form halfway through a guide still holds what was typed into it.

## Accessibility

- The list is a list of buttons, not a tablist, and the current row carries `aria-current="step"`.
- Each row is read as "Step 3: Use it", and the numbered disc is decoration. A row whose `title` is a node is read as its own content instead.
- Moving to another step is announced through a polite live region, as "Step 2: Configure", since the panel changes in place and the focus stays on the button that was pressed.
- The steps that are not showing stay in the document so the panel can keep its height, and are `inert`: out of the tab order, off the accessibility tree, and out of a find-in-page.
- Give the guide a `title` when a page has more than one. With a `title` the guide is a `role="group"` named by it.

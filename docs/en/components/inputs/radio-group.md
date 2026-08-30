---
title: RadioGroup
order: 6
---

# RadioGroup

<p class="neba-lede">A set of options where exactly one is chosen. Use it when each option needs a sentence of its own, or when every option should be visible at once.</p>

<Demo src="radio-group/hero" />

```tsx
import { Radio, RadioGroup } from 'neba';

<RadioGroup label="Plan" defaultValue="team">
  <Radio value="starter" label="Starter" />
  <Radio value="team" label="Team" />
</RadioGroup>;
```

## Props

### RadioGroup

<PropsTable name="RadioGroup" />

`value` with `onValueChange` makes it controlled; `defaultValue` makes it uncontrolled.

### Radio

<PropsTable name="Radio" />

A `Radio` has no `size` and no `color` of its own — set them on `RadioGroup` and they reach every option.

With many options to fit into little space, use [Select](./select); to join two or three into one control, use [SegmentedButton](./segmented-button).

## Examples

### description

Each option can carry a sentence. However many lines the description takes, the dot stays aligned to the first line of the label.

<Demo src="radio-group/descriptions">

<<< @/.vitepress/demos/radio-group/descriptions.tsx

</Demo>

### orientation

`vertical` by default. Use `horizontal` only with short labels — one long label makes the row hard to read.

<Demo src="radio-group/orientation">

<<< @/.vitepress/demos/radio-group/orientation.tsx

</Demo>

### disabled · readOnly

Both can be set on the group or on an individual `Radio`. On the group, they reach every option.

<Demo src="radio-group/states">

<<< @/.vitepress/demos/radio-group/states.tsx

</Demo>

### classNames

The group and one option are styled separately, because they are two components. On RadioGroup, `classNames` takes `label`, `control`, `description` and `error`, where `control` is the element holding the options — the one carrying the row or column direction. On Radio it takes `label`, `control`, `indicator` and `description`, where `control` is the dot.

```tsx
<RadioGroup label="Plan" classNames={{ control: 'gap-6' }}>
  <Radio value="team" label="Team" classNames={{ control: 'rounded-sm' }} />
</RadioGroup>
```

There is no `error` slot on Radio: a validity message belongs to the question, and the question is the group. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

## Accessibility

- The set takes **one** tab stop and the arrow keys move within it (a roving tab index).
- The group's `label` becomes its accessible name.
- Each `Radio` is wired to its label, so clicking the text selects it.

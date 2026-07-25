---
title: RadioGroup
order: 6
---

# RadioGroup

<p class="neba-lede">A set of options where exactly one is chosen. Base UI owns the roving tab index and the arrow keys; this owns the surface they wear.</p>

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

### Radio

<PropsTable name="Radio" />

A `Radio` has no `size` and no `color` of its own. Both come from the group, which is the only place they can be set once and mean the same thing for every option in the set — a radio button is meaningless alone, it only says anything relative to its siblings.

## Examples

### Descriptions

An option that needs a sentence gets one. The dot stays centred on the first line of the label whatever the description does under it.

<Demo src="radio-group/descriptions">

<<< @/.vitepress/demos/radio-group/descriptions.tsx

</Demo>

### Orientation

Vertical by default. A row of options is fine right up until one label is longer than expected, and then it silently stops being readable.

<Demo src="radio-group/orientation">

<<< @/.vitepress/demos/radio-group/orientation.tsx

</Demo>

### States

`disabled` and `readOnly` can be set on the group or on one option. On the group, `readOnly` reaches every member.

<Demo src="radio-group/states">

<<< @/.vitepress/demos/radio-group/states.tsx

</Demo>

## Why this one is round

Roundness is what tells a reader "one of these" rather than "any of these", and it is the one convention old enough that breaking it would cost more than it bought. Everything else about the dot — the acrylic, the hairline, the fill on selection — is the same as a [Checkbox](./checkbox).

## Accessibility

- The set takes **one** tab stop; the arrow keys move within it. That is the whole reason this is a component rather than a `<div>` full of inputs.
- The group's `label` becomes its accessible name.
- Each `Radio` is wired to its label by Base UI's Field, so clicking the text selects it.

---
title: Fieldset
order: 28
---

# Fieldset

<p class="neba-lede">A group of controls that answer one question together, with a name on it. It groups the controls without drawing a surface of its own.</p>

<Demo src="fieldset/hero" />

```tsx
import { Fieldset, TextField } from 'neba';

<Fieldset legend="Billing address" description="Where the card statement goes.">
  <TextField label="Street" name="street" />
  <TextField label="City" name="city" />
</Fieldset>;
```

## Props

<PropsTable name="Fieldset" />

Every native `<fieldset>` attribute passes through, apart from `color`. The browser's own border, padding and margin are cleared: for a surface, put this inside a [Card](../surfaces/card) or a [Box](../surfaces/box).

## Examples

### legend · description

The legend becomes the accessible name of every control inside, so it has to be a phrase that still reads correctly in front of each of them: "Billing address", not "Where should we send it?". `description` is a line under it.

### disabled

The one thing only a real `<fieldset>` can do: it reaches every control inside, including ones a component three levels down rendered and never heard of it.

<Demo src="fieldset/disabled">

<<< @/.vitepress/demos/fieldset/disabled.tsx

</Demo>

### size

`size` is the type scale of the legend and the gap the controls stand at. It does not reach the controls themselves: a group of `sm` fields is written as `sm` fields.

<Demo src="fieldset/sizes">

<<< @/.vitepress/demos/fieldset/sizes.tsx

</Demo>

## Accessibility

- Renders a real `<fieldset>` with `role="group"`, named by the legend through `aria-labelledby`.
- A screen reader reads the legend before each control inside, which is why the legend is written as a phrase rather than a question.

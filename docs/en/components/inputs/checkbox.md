---
title: Checkbox
order: 5
flutter: true
---

# Checkbox

<p class="neba-lede">A single item that can be ticked. Use it for a boolean submitted with a form, or for a list where several items can be chosen at once.</p>

<Demo src="checkbox/hero" />

::: fw react

```tsx
import { Checkbox } from 'neba';

<Checkbox label="Remember me" defaultChecked />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaCheckbox(label: Text('Remember me'), defaultChecked: true);
```

:::

## Props

<PropsTable name="Checkbox" />

::: fw react

`label`, `description` and `error` are props rather than `children`; `children` is not accepted.

:::

::: fw flutter

`label`, `description` and `error` are widgets, usually a `Text`, and there is no `child`. There is no `name`, `required` or form value either: a Flutter checkbox has no form submission to take part in. `semanticLabel` names a checkbox that has no label. Inside a [CheckboxGroup](./checkbox-group) a checkbox reads its own `size`, `color` and `readOnly` first and the group's after, which is why those are nullable.

:::

For a setting that takes effect immediately, use [Switch](./switch). A Checkbox is a value submitted alongside a Save button. For several checkboxes that answer one question, put them in a [CheckboxGroup](./checkbox-group), which gives the set one value, a label and the gap options stand at.

## Examples

### checked and onCheckedChange

`checked` with `onCheckedChange` makes it controlled; `defaultChecked` makes it uncontrolled.

### disabled · readOnly · error

An `error` message also turns the checkbox invalid and re-points the colour family at `danger`: the tick, the focus ring and the message all turn over together.

<Demo src="checkbox/states">

::: fw react

<<< @/.vitepress/demos/checkbox/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/checkbox/states.dart

:::

</Demo>

### indeterminate

A third appearance for a parent checkbox whose children disagree. The value underneath is still on or off; `indeterminate` only affects what is drawn. Inside a [CheckboxGroup](./checkbox-group), a Checkbox with `parent` works this out on its own.

<Demo src="checkbox/indeterminate">

::: fw react

<<< @/.vitepress/demos/checkbox/indeterminate.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/checkbox/indeterminate.dart

:::

</Demo>

### size

<Demo src="checkbox/sizes">

::: fw react

<<< @/.vitepress/demos/checkbox/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/checkbox/sizes.dart

:::

</Demo>

### classNames

::: fw react

`className` lands on the field wrapper, not on the tick. The tick and the mark inside it are reached through `classNames`.

```tsx
<Checkbox label="I agree" classNames={{ control: 'rounded-full', label: 'font-medium' }} />
```

The slots are `label`, `control`, `indicator`, `description` and `error`. `control` is the tick itself (the bordered box that fills when checked), and `indicator` is the mark inside it. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

:::

::: fw flutter

There are no class names. The label, the description and the error are widgets, so each takes a style of its own; the tick and the mark inside it are the checkbox's.

```dart
const NebaCheckbox(label: Text('I agree', style: TextStyle(fontWeight: FontWeight.w500)));
```

:::

## Accessibility

::: fw react

- Renders `role="checkbox"` with a hidden `<input>` beside it, so giving it a `name` submits it with a form.
- The label is wired to the control, so clicking the text toggles the box.
- Without a `label`, give it an `aria-label`.
- `indeterminate` reports `aria-checked="mixed"`.

:::

::: fw flutter

- A screen reader hears one checkbox: ticked, clear or mixed. A `Text` label is its name, and a `Text` description and error are read after it; an `error` also marks it invalid.
- A press on the label ticks the box, and so does a press on the gap between the two. The description takes no press.
- Without a `label`, give it a `semanticLabel`. A press reaches the square only within its own box, so a checkbox with no label has a smaller target than the React one; give it room in a table's cell.
- Space and Enter tick it while it holds the focus. A read-only checkbox keeps its place in the focus order.

:::

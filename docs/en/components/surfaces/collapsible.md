---
title: Collapsible
order: 13
flutter: true
---

# Collapsible

<p class="neba-lede">One section that folds, standing on its own. Pressing the header opens what is under it and pressing it again closes it. A set of these, of which only one is open, is an Accordion.</p>

<Demo src="collapsible/hero" />

::: fw react

```tsx
import { Collapsible } from 'neba';

<Collapsible title="Shipping and returns">
  <p>Orders placed before 2pm ship the same day.</p>
</Collapsible>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaCollapsible(
  title: Text('Shipping and returns'),
  child: Text('Orders placed before 2pm ship the same day.'),
);
```

:::

## Props

<PropsTable name="Collapsible" />

::: fw react

Every other `<div>` attribute passes through to the root, except `onChange`: the change worth listening for is `onOpenChange`.

:::

::: fw flutter

Every slot is a widget, and the body is `child`. The panel opens to the height of what it holds and closes to none, on the house duration and ease, and never by a transform; a reader who asked for less motion sees it open at once.

:::

The shared axes (`variant` `size` `color` `density` `elevation`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### title, subtitle, startIcon, action

`title` is the heading on the header and `subtitle` is the line under it. Both wrap, and `lines` cuts them off after that many lines with an ellipsis. `startIcon` goes before the title; `action` goes at the end of the header but outside the trigger: a header that both folds and holds a switch has two things to press, and one of them cannot be nested inside the other.

<Fw react="indicator={false}" flutter="indicator: false" code /> drops the chevron, which leaves the header reporting its state in colour alone.

<Demo src="collapsible/slots">

::: fw react

<<< @/.vitepress/demos/collapsible/slots.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/collapsible/slots.dart

:::

</Demo>

### <Fw react="trigger" flutter="triggerBuilder" />

::: fw react

`trigger` replaces the header entirely with a control of your own. The element you pass becomes the trigger: it is handed the click handler, `aria-expanded` and the `aria-controls` pointing at the panel, so there is nothing to wire up.

:::

::: fw flutter

`triggerBuilder` replaces the header entirely with a control of your own. It is called with whether the panel is open and the callback that opens or closes it, which is `null` while the Collapsible is `disabled`, so a `NebaButton` given it as `onPressed` disables itself. A screen reader hears the control as expanded or collapsed. The trigger takes the whole width of the Collapsible, as the header would.

:::

<Demo src="collapsible/trigger">

::: fw react

<<< @/.vitepress/demos/collapsible/trigger.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/collapsible/trigger.dart

:::

</Demo>

### variant

The three weights say what they say on every other container. `text` draws no sheet at all, which is what a fold inside running prose (or inside a Card, which is already a sheet) usually wants.

<Demo src="collapsible/variants">

::: fw react

<<< @/.vitepress/demos/collapsible/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/collapsible/variants.dart

:::

</Demo>

### <Fw react="keepMounted, hiddenUntilFound" flutter="keepMounted" />

::: fw react

A closed panel stays in the DOM by default, as `hidden="until-found"`: it is in a server render, and the browser's own page search can find it and open the panel. `hiddenUntilFound={false}` takes a closed panel out of the DOM. `keepMounted` keeps it there without being found, so content that is expensive to build or that holds form state survives being folded away; `hiddenUntilFound` overrides it.

:::

::: fw flutter

A closed panel keeps what it holds built by default, so a field in it keeps what was typed through being folded away. `keepMounted: false` drops it while the panel is closed, for content that is expensive to build and only needs to exist while open. There is no `hiddenUntilFound`: a Flutter screen has no page search and no server render, and keeping the panel built is what its default does to a closed panel in React.

:::

<Demo src="collapsible/mounting">

::: fw react

<<< @/.vitepress/demos/collapsible/mounting.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/collapsible/mounting.dart

:::

</Demo>

### Controlling it

Pass `open` and the Collapsible keeps no state of its own. Use it to open and close several at once, to put the open state in the URL, or to drive it from a control elsewhere on the page.

::: fw react

```tsx
const [open, setOpen] = useState(false);

<Collapsible title="Advanced" open={open} onOpenChange={setOpen}>
  <p>Everything else goes here.</p>
</Collapsible>;
```

:::

::: fw flutter

```dart
NebaCollapsible(
  title: const Text('Advanced'),
  open: open,
  onOpenChange: (bool next) => setState(() => open = next),
  child: const Text('Everything else goes here.'),
);
```

:::

## Accessibility

::: fw react

- The trigger is a real `<button>`, carrying `aria-expanded` and an `aria-controls` pointing at the panel it opens.
- `action` sits outside the trigger, so it is reachable and pressable on its own from a keyboard.
- A closed panel is in neither the tab order nor the accessibility tree, whether it is hidden until found, kept mounted or out of the DOM.
- Unless `hiddenUntilFound` is off, the browser's own page search can find closed content and open the panel around it.

:::

::: fw flutter

- A screen reader hears the trigger as a button that is expanded or collapsed, named by the title and the subtitle. Enter and Space open and close it.
- `action` sits outside the trigger, so it is reachable and pressable on its own from a keyboard.
- A closed panel is in neither the focus order nor the semantics tree from the moment it starts closing, whether it is kept built or not.

:::

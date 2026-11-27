---
title: Popover
order: 11
flutter: true
---

# Popover

<p class="neba-lede">A sheet that opens beside the control that opened it. Unlike a tooltip it stays up and can be reached, so what is inside can be clicked and typed into.</p>

<Demo src="popover/hero" align="center" minHeight="260" />

::: fw react

```tsx
import { Button, Popover, TextField } from 'neba';

<Popover trigger={<Button variant="outline">Share</Button>} title="Share this page">
  <TextField size="sm" label="Link" defaultValue="https://…" readOnly />
</Popover>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaPopover(
  trigger: NebaButton(onPressed: () {}, variant: NebaVariant.outline, child: const Text('Share')),
  title: const Text('Share this page'),
  child: const NebaTextField(
    size: NebaSize.sm,
    label: Text('Link'),
    initialValue: 'https://…',
    readOnly: true,
  ),
);
```

:::

## Props

<PropsTable name="Popover" />

::: fw react

Native `<div>` attributes pass through to the popup. Only `color`, `title` and `children` are excluded, since the table above spells them differently.

`PopoverClose` is Base UI's `Popover.Close`, re-exported. Give it a `render` prop and any element dismisses the popup it is inside: `<PopoverClose render={<Button>Apply</Button>} />`.

:::

::: fw flutter

`trigger` opens the popover through its own press, so it has to be a Neba control, such as a `NebaButton` or a `NebaChip` with `onPressed`: the press does the control's own work and opens or closes the popover as well. A button that is only a trigger takes `onPressed: () {}`, because a Flutter button with none is disabled, and a disabled one opens nothing.

`NebaPopoverClose` hands a control inside the popup the callback that closes it, which gets through even when the popover is not `dismissible`: `NebaPopoverClose(builder: (context, close) => NebaButton(onPressed: close, child: const Text('Apply')))`.

The popup is drawn in the app's root `Overlay`. A `MaterialApp`, a `CupertinoApp` and a `WidgetsApp` with routes all have one; an app built without one wraps itself in `Overlay.wrap`, and a popover with no overlay above it throws the moment it opens.

:::

The shared axes are described in [prop conventions](../../design/prop-conventions).

## Examples

### side and align

`side` is which edge of the trigger the popup sits on; `align` is where it sits along that edge. The side flips automatically when the window has no room. `sideOffset` sets the gap and `alignOffset` shifts it along the edge.

<Demo src="popover/sides" minHeight="220">

::: fw react

<<< @/.vitepress/demos/popover/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/popover/sides.dart

:::

</Demo>

### A form in a popup

The popup holds focusable content, so a filter panel, a small form or a colour picker all belong here rather than in a [Dialog](../feedback/dialog): the page behind stays readable while the form is filled in. `width` caps the popup when its content should decide the measure.

<Demo src="popover/form" minHeight="400">

::: fw react

<<< @/.vitepress/demos/popover/form.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/popover/form.dart

:::

</Demo>

### Controlled

Pass `open` with `onOpenChange` and the caller owns the state, so anything else on the page can open or close it. Without them the popover manages itself and `defaultOpen` sets the starting state.

<Demo src="popover/controlled" minHeight="220">

::: fw react

<<< @/.vitepress/demos/popover/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/popover/controlled.dart

:::

</Demo>

### arrow

`arrow` draws a wedge pointing at the trigger. It is off by default: this surface is translucent over a blurred backdrop, and a wedge sticking out past the popup's own box cannot carry that backdrop with it. Turn it on where the trigger is far enough away that the popup has to say what it belongs to.

::: fw react

```tsx
<Popover arrow trigger={<Button>Details</Button>}>
  Anchored to the button it came from.
</Popover>
```

:::

::: fw flutter

```dart
NebaPopover(
  arrow: true,
  trigger: NebaButton(onPressed: () {}, child: const Text('Details')),
  child: const Text('Anchored to the button it came from.'),
);
```

:::

## Accessibility

::: fw react

- The popup carries `role="dialog"`. `title` names it and `description` describes it, wired with `aria-labelledby` and `aria-describedby`; a popover with neither needs an `aria-label` of its own.
- Focus moves into the popup when it opens and returns to the trigger when it closes.
- Escape closes it, and so does a click outside. `dismissible={false}` cancels both: a `PopoverClose` still gets through, so it is never a trap.
- `modal` is `false` by default, so the page behind stays scrollable and usable. Use `modal` for a popup that must be answered before anything else is touched; `'trap-focus'` holds the focus inside and leaves the page scrollable and clickable. A modal popover without `showClose` still gets a close button, hidden until it takes the keyboard focus, so a reader using VoiceOver on a phone, where there is no Escape key, has a way out.
- `locale` decides the ×'s accessible name; `closeLabel` writes it out instead.

:::

::: fw flutter

- The popup is a dialog to a screen reader, named by a `title` that is a `Text`, and the trigger says whether it is expanded. A `description` is read where it is drawn.
- The focus moves into the popup when it opens, to the first control inside, or to the popup itself when a finger opened it so that a field does not bring the keyboard up, and returns to the trigger when it closes.
- Escape closes it, and so do a press outside and the focus leaving it. `dismissible: false` cancels all three: the × and a `NebaPopoverClose` still get through, so it is never a trap.
- `modal` is `NebaModal.off` by default, so the page behind stays scrollable and usable. `NebaModal.on` lays a barrier over the page that takes every press and keeps Tab inside the popup; `NebaModal.trapFocus` keeps Tab inside and leaves the page pressable. A modal popover without `showClose` still gets a close button, hidden until it takes the keyboard focus, which a screen reader finds and presses while it is hidden.
- `locale` decides the ×'s name for a screen reader; `closeLabel` writes it out instead.

:::

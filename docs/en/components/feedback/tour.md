---
title: Tour
order: 12
flutter: true
---

# Tour

<p class="neba-lede">A guided walk over a page that already exists: the three things a new reader has to be shown once, pointed at where they actually are.</p>

<Demo src="tour/hero" minHeight="360" />

::: fw react

```tsx
import { Tour } from 'neba';

<Tour
  open={open}
  onOpenChange={setOpen}
  steps={[
    { target: '#search', title: 'Find anything', content: 'Everything is behind this field.' },
    { target: '#deploy', title: 'Ship it', content: 'Builds the current branch.', side: 'left' }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaTour(
  open: open,
  onOpenChange: (bool next) => setState(() => open = next),
  steps: <NebaTourStep>[
    NebaTourStep(
      target: searchKey,
      title: const Text('Find anything'),
      content: const Text('Everything is behind this field.'),
    ),
    NebaTourStep(
      target: deployKey,
      title: const Text('Ship it'),
      content: const Text('Builds the current branch.'),
      side: NebaSide.left,
    ),
  ],
);
```

:::

## Props

<PropsTable name="Tour" />

::: fw flutter

The card and the dimming are drawn in the app's root `Overlay`, and the tour takes no room where it is written. A step names its target by the `GlobalKey` the target is built with, in place of React's CSS selector, and a target in a lazily built list has to be built to be found. `className` and `classNames` have no counterpart: a widget takes no class names.

:::

### TourStep

<PropsTable name="TourStep" />

## Examples

### steps · target

::: fw react

Each step names its target with a CSS selector, read against the page as it is at that moment. A step with no `target` is centred with nothing cut out, which suits a welcome step or a closing step.

:::

::: fw flutter

Each step names its target by the `GlobalKey` it is built with, and the card follows it as the page scrolls or the target moves. A step with no `target` is centred with nothing cut out, which suits a welcome step or a closing step.

:::

<Demo src="tour/centred" minHeight="280">

::: fw react

<<< @/.vitepress/demos/tour/centred.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tour/centred.dart

:::

</Demo>

### open · step

`open` runs the tour and `step` is which stop it is on; both have uncontrolled counterparts and both report their changes. `onFinish` is called when the last step's button is pressed, before the tour closes.

### mask

Dims the page and cuts the target out of the dimming. The dimming never takes the pointer, so the control being pointed at can still be used.

<Demo src="tour/mask" minHeight="300">

::: fw react

<<< @/.vitepress/demos/tour/mask.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tour/mask.dart

:::

</Demo>

### locale and the labels

The buttons and the counter come from `locale`. `previousLabel`, `nextLabel`, `doneLabel` and `skipLabel` write any of them out instead.

::: fw react

### className · classNames

`className` lands on the card, the popup each step is written on. The dimming behind it is a sibling of that popup rather than a descendant, so it is reached through `classNames.mask` and no other way.

```tsx
<Tour
  steps={steps}
  className="max-w-sm"
  classNames={{ mask: 'bg-black/70', footer: 'justify-between' }}
/>
```

The slots are `mask`, `title`, `description`, `close` and `footer`. See [prop conventions](../../design/prop-conventions) for how a class name you pass resolves against the component's own.

:::

## Accessibility

::: fw react

- The card is a dialog named by its title and described by its content. Changing step keeps the focus on the button that was pressed.
- Next and Previous rewrite the card in place, so the new step is read out through a polite live region, as "Step 2: Deploy".
- Escape ends the tour unless `dismissible` is off. A press outside the card does not end it.
- A tour is never the only way to something. Whatever it points at has to be findable without it, because a reader who dismissed it or never saw it gets no second showing.

:::

::: fw flutter

- The card is a dialog named by its title, which a screen reader hears as a heading. The focus moves into the card when the tour starts and goes back when it ends, and changing step keeps it on the button that was pressed.
- Next and Previous rewrite the card in place, so the new step is read out through a live region, as "Step 2: Deploy".
- Escape ends the tour wherever the focus is, unless `dismissible` is off. Neither a press outside the card nor the focus leaving it ends it.
- A tour is never the only way to something. Whatever it points at has to be findable without it, because a reader who dismissed it or never saw it gets no second showing.

:::

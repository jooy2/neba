---
title: Accordion
order: 3
flutter: true
---

# Accordion

<p class="neba-lede">Stacks sections that fold open and shut. Use it to keep long content collapsed to its headings so only what is needed is expanded.</p>

<Demo src="accordion/hero" />

::: fw react

```tsx
import { Accordion, AccordionItem } from 'neba';

<Accordion defaultValue={['billing']}>
  <AccordionItem value="billing" title="How does billing work?" subtitle="Plans and invoices">
    You are charged on the first of each month.
  </AccordionItem>
  <AccordionItem value="regions" title="Where do builds run?">
    In the region closest to the default branch.
  </AccordionItem>
</Accordion>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAccordion<String>(
  defaultValue: <String>['billing'],
  children: <Widget>[
    NebaAccordionItem<String>(
      value: 'billing',
      title: Text('How does billing work?'),
      subtitle: Text('Plans and invoices'),
      child: Text('You are charged on the first of each month.'),
    ),
    NebaAccordionItem<String>(
      value: 'regions',
      title: Text('Where do builds run?'),
      child: Text('In the region closest to the default branch.'),
    ),
  ],
);
```

:::

## Props

### Accordion

<PropsTable name="Accordion" />

::: fw react

`value` with `onValueChange` makes it controlled; `defaultValue` makes it uncontrolled. The value is an array of the open items' `value`s.

:::

::: fw flutter

The sections are `children`, each a `NebaAccordionItem`, and the accordion is generic over the type of their `value`. `value` with `onValueChange` makes it controlled; left `null`, the accordion keeps its own state from `defaultValue`. The value is a list of the open sections' `value`s in the single case too, so it does not change type with `multiple`. A section opens to the height of what it holds and closes to none, by layout and never by a transform.

:::

### AccordionItem

<PropsTable name="AccordionItem" />

## Examples

### variant

The sheet is never filled with colour. Use `text` inside a [Card](./card): the card is already a sheet, so the borders do not double up.

<Demo src="accordion/variants">

::: fw react

<<< @/.vitepress/demos/accordion/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/accordion/variants.dart

:::

</Demo>

### multiple · dividers · action

`multiple` is off by default, so opening one section closes the one that was open. Turn it on when the sections are a checklist rather than mutually exclusive answers.

`dividers` rules between the sections, binding them into one block. `action` is a control slot **outside** the folding button, so a header can carry a switch and still fold when pressed.

<Demo src="accordion/behaviour">

::: fw react

<<< @/.vitepress/demos/accordion/behaviour.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/accordion/behaviour.dart

:::

</Demo>

### size

<Demo src="accordion/sizes">

::: fw react

<<< @/.vitepress/demos/accordion/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/accordion/sizes.dart

:::

</Demo>

### headingLevel · lines

`headingLevel` sets the heading level of every section's header, for the whole stack. Use `3` under <Fw react="an `<h2>`" flutter="a level-two heading" /> and `4` under <Fw react="an `<h3>`" flutter="a level-three one" />.

`lines` on a section cuts the title and the subtitle off after that many lines. Unset, both wrap.

::: fw react

```tsx
<Accordion headingLevel={2}>
  <AccordionItem lines={2} title="What happens to my data when I close my account?">
    …
  </AccordionItem>
</Accordion>
```

:::

::: fw flutter

```dart
const NebaAccordion<String>(
  headingLevel: 2,
  children: <Widget>[
    NebaAccordionItem<String>(
      lines: 2,
      title: Text('What happens to my data when I close my account?'),
      child: Text('…'),
    ),
  ],
);
```

:::

### <Fw react="hiddenUntilFound and keepMounted" flutter="keepMounted" />

::: fw react

`hiddenUntilFound` is on by default. A closed panel stays in the DOM as `hidden="until-found"`, so its answer is in a server render and a crawler's index, and the browser's find-on-page can locate it and open the section. Turn it off for panels that are expensive to build and only need to exist while open; `keepMounted` then keeps a closed panel's React tree alive without it being found.

:::

::: fw flutter

`keepMounted` is on by default, so a closed section keeps what it holds built and its state with it. Turn it off for sections that are expensive to build and only need to exist while open. There is no `hiddenUntilFound`: a Flutter screen has no find-on-page and no server render, and keeping a closed section built is what its default does in React.

:::

## Accessibility

::: fw react

- The header button and its panel are wired together with `aria-controls` and `aria-expanded`.
- Each header is a real heading element, at `headingLevel` (`3` by default), so the sections are in the document outline. Pass plain text as `title`: a heading passed in would be nested inside that one.

:::

::: fw flutter

- A screen reader hears each header as a button that is expanded or collapsed, inside a heading at `headingLevel` (`3` by default), so the sections are in the screen's outline. Pass plain text as `title`: a heading passed in would be nested inside that one.
- `action` sits outside the button and the heading, so it is pressed on its own and is not read as part of the title.
- A closed section is in neither the focus order nor the semantics tree.

:::

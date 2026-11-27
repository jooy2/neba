---
title: InlineCitation
order: 7
flutter: true
---

# InlineCitation

<p class="neba-lede">A numbered footnote in the body of an answer, with the source behind it a hover away. The mark is the same square a Sources row draws, so a reader who sees 2 in a sentence finds 2 in the list underneath.</p>

<Demo src="inline-citation/hero" minHeight="260" />

::: fw react

```tsx
import { InlineCitation } from 'neba';

<InlineCitation index={1} title="The design language" site="neba.cdget.com" href="/design" />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

Text.rich(
  TextSpan(
    children: <InlineSpan>[
      const TextSpan(text: 'A control never moves under the pointer'),
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: NebaInlineCitation(
          index: 1,
          title: const Text('The design language'),
          site: const Text('neba.cdget.com'),
          onPressed: () => open('/design'),
        ),
      ),
    ],
  ),
);
```

:::

## Props

<PropsTable name="InlineCitation" />

::: fw react

Native `<a>` attributes pass through to the mark. `color`, `title` and `children` are excluded, since the table above spells them differently.

:::

::: fw flutter

The mark goes into running text as a `WidgetSpan`. A widget in a span is laid out with the `DefaultTextStyle` around the paragraph rather than the span's own style, so set the paragraph's type with a `DefaultTextStyle` for the mark to follow it. `onPressed` and `newTab` take the place of an `<a>`'s `href` behaviour and `target`.

:::

## Examples

### index

The number the mark shows. The mark does not count itself, so pass the number of the source in the list it points at.

Its accessible name is the sentence "Source 2" rather than the digit.

### preview

On, and drawn by [HoverCard](../surfaces/hover-card), so it opens on focus as well as on hover and the gap between the mark and the card is crossable. It needs a `title`: a citation with nothing to preview is a bare link, and turning the card on for it would be an empty box that opens under the pointer.

<Demo src="inline-citation/preview" minHeight="200">

::: fw react

<<< @/.vitepress/demos/inline-citation/preview.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/inline_citation/preview.dart

:::

</Demo>

### href

::: fw react

A real link, with the same scheme check a [Sources](./sources) row makes: anything outside `http`, `https`, `mailto` and `tel` leaves the mark as plain text rather than writing the URL out. Without an `href` the mark is a `<span>`, which takes the keyboard focus only when it has a preview to open. A `target` that leaves the tab gains `rel="noopener noreferrer"`.

:::

::: fw flutter

A real link once it has an `onPressed`, with the same scheme check a [Sources](./sources) row makes on its `href`: anything outside `http`, `https`, `mailto` and `tel` leaves the mark unlinked. Without a link the mark takes the keyboard focus only when it has a preview to open. `newTab` adds the words that say the link leaves the app to the mark's name.

:::

### color · size

The mark is sized <Fw react="in em" flutter="by the type around it" /> and takes its tint from `color`, so it tracks whatever sentence it interrupts at whatever scale that sentence is set. `size` is the preview's type scale and not the mark's.

The mark is not a superscript: it sits on the line at `0.8em`<Fw react=", raised slightly" flutter=", centred on it" />.

<Demo src="inline-citation/color" minHeight="160">

::: fw react

<<< @/.vitepress/demos/inline-citation/color.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/inline_citation/color.dart

:::

</Demo>

## Accessibility

::: fw react

- The mark carries an accessible name in words — "Source 2" — because a digit on its own tells a screen reader nothing about what it is for. A link takes it as `aria-label`; a mark without a link writes it as visually hidden text.
- The preview is Base UI's hover card, so it opens on keyboard focus and not only under a pointer.

:::

::: fw flutter

- The mark carries a name in words — "Source 2" — because a digit on its own tells a screen reader nothing about what it is for. A linked mark is heard as a link by that name.
- The preview is a [HoverCard](../surfaces/hover-card), so it opens on keyboard focus and not only under a pointer, and never on a touch.

:::

---
title: Reasoning
order: 3
flutter: true
---

# Reasoning

<p class="neba-lede">A thinking panel that the stream opens and closes. It fills while the model is working, folds itself away when the working stops, and leaves one line saying that it happened and how long it took.</p>

<Demo src="reasoning/hero" />

::: fw react

```tsx
import { Reasoning } from 'neba';

<Reasoning streaming={thinking}>{thoughts}</Reasoning>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaReasoning(streaming: thinking, child: Text(thoughts));
```

:::

## Props

<PropsTable name="Reasoning" />

::: fw react

Native `<div>` attributes pass through to the root. `color` and `onChange` are excluded, since the table above spells them differently.

:::

::: fw flutter

`duration` is a `Duration` rather than a number of milliseconds. `labels` is a map keyed by the React package's names for the sentences. `showIcon: false` is React's `icon={false}`, and `keepMounted` takes the place of `hiddenUntilFound`.

:::

A [Spoiler](../surfaces/spoiler) and a [Collapsible](../surfaces/collapsible) are the other two folds in the library, and on both of them the reader owns the open state: they covered it, they uncover it. Here the stream owns it.

## Examples

### streaming

::: fw react

The one prop that drives the rest. While it is true the header says so, the mark turns, the root carries `data-streaming` and `aria-busy`, and the panel is open. When it goes false the header becomes a summary and, unless `autoClose` is off, the panel folds away.

:::

::: fw flutter

The one prop that drives the rest. While it is true the header says so, the mark turns, and the panel is open. When it goes false the header becomes a summary and, unless `autoClose` is off, the panel folds away.

:::

A Reasoning that _mounts_ while `streaming` is already true starts open: there is no edge coming to open it, and a panel that stayed shut would hide the one thing arriving on the screen.

<Demo src="reasoning/streaming">

::: fw react

<<< @/.vitepress/demos/reasoning/streaming.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/reasoning/streaming.dart

:::

</Demo>

### duration

<Fw react="Milliseconds" flutter="A Duration" />, and the header reads "Thought for 4.2s". Leave it out and the panel counts its own from the moment `streaming` went true. The count ticks once a second, and is measured once more when the stream stops, so the header gives the time it took — "Thought for 900ms" for a stretch under a second. A panel that never streamed says "Finished thinking".

### autoOpen

On. Turning it off keeps the header's sentence and the mark and leaves the panel exactly where the reader put it, which is what a page wants when the thinking is the content rather than an aside.

The panel follows the _edges_ of `streaming` rather than its value either way, so a reader who folds it away mid-stream is not overruled on the next token. Passing `open` turns all of it off: a controlled Reasoning is where its caller says it is.

### autoClose

On, so `autoOpen` also closes the panel when the stream ends. Turn it off to keep the thinking open once it has arrived: a panel that folds itself away moves the answer under it up the page while the reader is reading it. `autoClose` is only read while `autoOpen` is on, and the reader can still fold the panel away by pressing the header.

::: fw react

```tsx
<Reasoning streaming={streaming} autoClose={false}>
  {thinking}
</Reasoning>
```

:::

::: fw flutter

```dart
NebaReasoning(streaming: streaming, autoClose: false, child: Text(thinking));
```

:::

### <Fw react="hiddenUntilFound" flutter="keepMounted" />

::: fw react

On. A closed panel stays in the DOM as `hidden="until-found"`, so the thinking is in a server render, and the browser's own page search can find it and open the panel. `hiddenUntilFound={false}` takes a closed panel out of the DOM.

:::

::: fw flutter

On. A closed panel keeps the thinking built. `keepMounted: false` lets it go while the panel is closed.

:::

### variant

`text` is the default, and the panel draws no sheet. Pass a variant with a sheet when the panel is the only thing on the screen.

<Demo src="reasoning/variant">

::: fw react

<<< @/.vitepress/demos/reasoning/variant.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/reasoning/variant.dart

:::

</Demo>

## Accessibility

::: fw react

- The header is a real button, wired to the panel with `aria-expanded` and `aria-controls` by Base UI.
- The root carries `aria-busy` while the stream runs.
- A closed panel is in neither the tab order nor the accessibility tree. Unless `hiddenUntilFound` is off, the browser's own page search can still find text in it and open the panel.
- The panel is deliberately **not** a live region. Thinking is long and is revised as it arrives, and a screen reader reading every revision aloud would bury the answer it is on the way to.
- The thinking ending is not announced either. To have it heard, write it into a live region the app keeps on the page, such as a `role="status"` element.

:::

::: fw flutter

- A screen reader hears the header as a button that is expanded or collapsed, named by its sentence. Enter and Space open and close it.
- A closed panel is in neither the focus order nor the semantics tree from the moment it starts closing.
- The panel is deliberately **not** a live region. Thinking is long and is revised as it arrives, and a screen reader reading every revision aloud would bury the answer it is on the way to.
- The thinking ending is not announced either. To have it heard, announce it from the app, through `SemanticsService` or a live region of its own.

:::

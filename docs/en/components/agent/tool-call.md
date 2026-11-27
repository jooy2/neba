---
title: ToolCall
order: 1
flutter: true
---

# ToolCall

<p class="neba-lede">One tool invocation in an agent transcript: what was called, what it was called with, what came back, and how long it took. The header is always there and the rest folds away behind it.</p>

<Demo src="tool-call/hero" />

::: fw react

```tsx
import { ToolCall } from 'neba';

<ToolCall
  name="search_docs"
  status="success"
  duration={412}
  args={'{ "query": "acrylic surface" }'}
  result={'{ "hits": 4 }'}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaToolCall(
  name: Text('search_docs'),
  status: NebaRunStatus.success,
  duration: Duration(milliseconds: 412),
  args: Text('{ "query": "acrylic surface" }'),
  result: Text('{ "hits": 4 }'),
);
```

:::

## Props

<PropsTable name="ToolCall" />

::: fw react

Native `<div>` attributes pass through to the root. `color` and `onChange` are excluded, since the table above spells them differently.

:::

::: fw flutter

`duration` is a `Duration` rather than a number of milliseconds. `labels` is a map keyed by the React package's names for the words. `showIcon: false` is React's `icon={false}`, and `keepMounted` takes the place of `hiddenUntilFound`.

:::

`status` is the shared [`NebaRunStatus`](../../design/prop-conventions), the same four words an [AgentSteps](./agent-steps) step takes. The other shared axes mean what they mean everywhere else.

## Examples

### status

`pending`, `running`, `success` and `error`. Each gets its own mark as well as its own colour — a dashed ring, a turning ring, a tick, a cross — so the state is readable without relying on colour, and each is read out in words by a screen reader.

`color` only decides what a `running` call looks like. The other three are fixed: something that failed is `danger` and something that finished is `success`, on every ToolCall on the page.

<Demo src="tool-call/status">

::: fw react

<<< @/.vitepress/demos/tool-call/status.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tool_call/status.dart

:::

</Demo>

### duration

::: fw react

Milliseconds. Under a second it is written in milliseconds, over it in seconds — to one decimal place for the first ten and to none after that, through `Intl.NumberFormat`, so `locale` writes it in the reader's own language.

:::

::: fw flutter

A `Duration`. Under a second it is written in milliseconds, over it in seconds — to one decimal place for the first ten and to none after that. It is always written in English (`340ms`, `4.2s`), because the widgets layer has no `Intl`; `locale` changes the words around it.

:::

Leave it out and a `running` call counts its own time from the moment it started running. It says nothing for the first second, ticks once a second after that, and stops as soon as a real `duration` arrives.

### args · result · error

::: fw react

A string goes into a `<pre>`, with its own line breaks kept and a scrollbar if it needs one: indented JSON, a stack trace and a diff all mean something by where their lines break. Anything else is a node and is rendered untouched, so a [CodeBlock](../display/code-block) or a [DataList](../display/data-list) can go in instead.

:::

::: fw flutter

A plain `Text` is set in the monospaced face in a block of its own, with its own line breaks kept, scrolling rather than wrapping: indented JSON, a stack trace and a diff all mean something by where their lines break. Any other widget is drawn untouched, so a [DataList](../display/data-list) can go in instead, and a `Text.rich` is how a string is kept out of the block.

:::

`error` replaces `result` while `status` is `error`, under the heading "Failed" rather than "Result". Without one, a failed call shows its `result` under "Result", which is often the error the tool itself returned.

<Demo src="tool-call/body">

::: fw react

<<< @/.vitepress/demos/tool-call/body.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tool_call/body.dart

:::

</Demo>

### open · defaultOpen

The panel is closed to start with. A call that _fails_ opens itself — a reader should not have to go looking for the reason something did not work — and that happens on the transition into `error`, so closing it again keeps it closed.

Passing `open` turns that off with everything else: a controlled ToolCall is exactly where its caller put it, and the failure does not move it.

A ToolCall with no `args`, no `result`, no `error` and no <Fw react="children" flutter="child" code /> is not a disclosure at all. It draws the header row and nothing is pressable.

### <Fw react="hiddenUntilFound" flutter="keepMounted" />

::: fw react

On. A closed panel stays in the DOM as `hidden="until-found"`, so the arguments and the result are in a server render, and the browser's own page search can find them and open the panel. In a transcript of many calls with long results, `hiddenUntilFound={false}` takes the closed panels out of the DOM, and each is built only when it is opened.

:::

::: fw flutter

On. A closed panel keeps what it holds built. In a transcript of many calls with long results, `keepMounted: false` drops the closed panels, and each is built only when it is opened.

:::

### variant

The sheet takes no tint from `color`, so the arguments and the result are drawn on a plain surface. `text` draws no sheet at all, for a long column of calls.

<Demo src="tool-call/variant">

::: fw react

<<< @/.vitepress/demos/tool-call/variant.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tool_call/variant.dart

:::

</Demo>

## Accessibility

::: fw react

- The header is a real button, wired to the panel with `aria-expanded` and `aria-controls` by Base UI.
- A closed panel is in neither the tab order nor the accessibility tree. Unless `hiddenUntilFound` is off, the browser's own page search can still find text in it and open the panel.
- The status is written in words, which a screen reader reads when it reaches the row. The mark is `aria-hidden`, because a shape is not read.
- A change of status is not announced on its own. To have a failed call heard as it happens, write it into a live region the app keeps on the page, such as a `role="status"` element.
- The root carries `data-status`, for styling and for a test that needs to assert the state.

:::

::: fw flutter

- A screen reader hears the header as a button that is expanded or collapsed, named by the tool, the status in words, the meta and the time. Enter and Space open and close it.
- A closed panel is in neither the focus order nor the semantics tree from the moment it starts closing, whether it is kept built or not.
- The mark is drawn and not read; the status is said in words instead. A heading such as "Result" is drawn in capitals and read as the word.
- A change of status is not announced on its own. To have a failed call heard as it happens, announce it from the app, through `SemanticsService` or a live region of its own.

:::

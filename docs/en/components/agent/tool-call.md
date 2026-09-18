---
title: ToolCall
order: 1
---

# ToolCall

<p class="neba-lede">One tool invocation in an agent transcript: what was called, what it was called with, what came back, and how long it took. The header is always there and the rest folds away behind it.</p>

<Demo src="tool-call/hero" />

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

## Props

<PropsTable name="ToolCall" />

Native `<div>` attributes pass through to the root. `color` and `onChange` are excluded, since the table above spells them differently.

`status` is the shared [`NebaRunStatus`](../../design/prop-conventions), the same four words an [AgentSteps](./agent-steps) step takes. The other shared axes mean what they mean everywhere else.

## Examples

### status

`pending`, `running`, `success` and `error`. Each gets its own mark as well as its own colour — a dashed ring, a turning ring, a tick, a cross — so the state is readable without relying on colour, and each is read out in words by a screen reader.

`color` only decides what a `running` call looks like. The other three are fixed: something that failed is `danger` and something that finished is `success`, on every ToolCall on the page.

<Demo src="tool-call/status">

<<< @/.vitepress/demos/tool-call/status.tsx

</Demo>

### duration

Milliseconds. Under a second it is written in milliseconds, over it in seconds — to one decimal place for the first ten and to none after that, through `Intl.NumberFormat`, so `locale` writes it in the reader's own language.

Leave it out and a `running` call counts its own time from the moment it started running. It says nothing for the first second, ticks once a second after that, and stops as soon as a real `duration` arrives.

### args · result · error

A string goes into a `<pre>`, with its own line breaks kept and a scrollbar if it needs one: indented JSON, a stack trace and a diff all mean something by where their lines break. Anything else is a node and is rendered untouched, so a [CodeBlock](../display/code-block) or a [DataList](../display/data-list) can go in instead.

`error` replaces `result` while `status` is `error`. Without one, a failed call shows its `result`, which is often the error the tool itself returned.

<Demo src="tool-call/body">

<<< @/.vitepress/demos/tool-call/body.tsx

</Demo>

### open · defaultOpen

The panel is closed to start with. A call that _fails_ opens itself — a reader should not have to go looking for the reason something did not work — and that happens on the transition into `error`, so closing it again keeps it closed.

Passing `open` turns that off with everything else: a controlled ToolCall is exactly where its caller put it, and the failure does not move it.

A ToolCall with no `args`, no `result`, no `error` and no children is not a disclosure at all. It draws the header row and nothing is pressable.

### variant

The sheet is never dyed, the way a container's is not: what a tool call holds is somebody else's JSON, and every syntax colour in it was chosen against a plain background. `text` draws no sheet at all, which is what a column of twenty of these wants.

<Demo src="tool-call/variant">

<<< @/.vitepress/demos/tool-call/variant.tsx

</Demo>

## Accessibility

- The header is a real button, wired to the panel with `aria-expanded` and `aria-controls` by Base UI.
- The status is announced in words. The mark is `aria-hidden`, because a shape is not read.
- The root carries `data-status`, for styling and for a test that needs to assert the state.

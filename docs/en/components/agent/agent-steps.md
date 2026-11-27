---
title: AgentSteps
order: 4
flutter: true
---

# AgentSteps

<p class="neba-lede">A chain of steps that grows as it runs. Each one carries a status, a time and whatever it did, and the one at the bottom is usually still going.</p>

<Demo src="agent-steps/hero" />

::: fw react

```tsx
import { AgentStep, AgentSteps } from 'neba';

<AgentSteps running="Writing the answer">
  <AgentStep title="Read the request" duration={120} />
  <AgentStep title="Searched the documentation" meta="4 hits" duration={412} />
</AgentSteps>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAgentSteps(
  running: true,
  runningTitle: Text('Writing the answer'),
  children: <Widget>[
    NebaAgentStep(title: Text('Read the request'), duration: Duration(milliseconds: 120)),
    NebaAgentStep(
      title: Text('Searched the documentation'),
      meta: Text('4 hits'),
      duration: Duration(milliseconds: 412),
    ),
  ],
);
```

:::

## Props

<PropsTable name="AgentSteps" />

::: fw react

Native `<ol>` attributes pass through to the root. Only `color` is excluded, since the table above spells it differently.

:::

::: fw flutter

React's `running` takes either `true` or a node; here it is a `bool`, and the node is `runningTitle`. `labels` is a map keyed by status name.

:::

A [Timeline](../display/timeline) and a [HowToSteps](../surfaces/how-to-steps) draw a list that is known in advance: five stages of a checkout, four things to do in order. This one does not know how many items it has.

### AgentStep

<PropsTable name="AgentStep" />

::: fw react

Native `<li>` attributes pass through. `color` and `title` are excluded.

:::

::: fw flutter

`duration` is a `Duration`, and `showIcon: false` is React's `icon={false}`.

:::

## Examples

### Growing while it runs

Append steps as they happen. A step's place in the list is not a prop, so nothing has to be renumbered when one is inserted — the chain works out which one the rail stops at.

::: fw react

`running` draws one more marker under the last step, for the case the next step has no name yet. `true` gives it no label at all, because the turning ring has already said what it is and the status is read out either way; a node gives it one.

:::

::: fw flutter

`running` draws one more marker under the last step, for the case the next step has no name yet. On its own it gives the marker no label at all, because the turning ring has already said what it is and the status is read out either way; `runningTitle` gives it one. Give each step a key when steps can be inserted anywhere but the end, so each keeps its own clock.

:::

<Demo src="agent-steps/growing">

::: fw react

<<< @/.vitepress/demos/agent-steps/growing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/agent_steps/growing.dart

:::

</Demo>

### status

The shared [`NebaRunStatus`](../../design/prop-conventions), the same four words a [ToolCall](./tool-call) takes, and the same four marks. `success` is the default, because a step that is already in the list has usually already run.

Colour follows the status the same way: a failed step is `danger` and a finished one `success` whatever the chain's `color` says, and `color` decides only what a `running` step looks like.

<Demo src="agent-steps/status">

::: fw react

<<< @/.vitepress/demos/agent-steps/status.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/agent_steps/status.dart

:::

</Demo>

### What a step did

<Fw react="children" flutter="child" code /> is the detail under the title — the query that was searched, the file that was read, or a whole [ToolCall](./tool-call). `meta` is for the short thing that belongs on the title line instead.

### duration

<Fw react="Milliseconds" flutter="A Duration" />, written at the end of the title line. Leave it out and a `running` step counts its own from the second it starts, exactly as a [ToolCall](./tool-call) does.

### size · density

`size` moves the marker, the type scale and the gaps together. `density` changes only how far apart two steps sit, on a tighter ladder than a [Timeline](../display/timeline)'s.

<Demo src="agent-steps/size">

::: fw react

<<< @/.vitepress/demos/agent-steps/size.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/agent_steps/size.dart

:::

</Demo>

## Accessibility

::: fw react

- An `<ol>` with `role="list"` spelled out, so Safari keeps the list semantics after Tailwind's reset takes the markers off.
- Every step's status is written in words, which a screen reader reads when it reaches the step; the marks are `aria-hidden`.
- A step changing status is not announced on its own. To have it heard as it happens, write it into a live region the app keeps on the page, such as a `role="status"` element.
- The `running` step carries `aria-current="step"`.

:::

::: fw flutter

- The chain is a list and each step an item of it, to a screen reader.
- Every step's status is said in words before its title; the marks are drawn and not read.
- A step changing status is not announced on its own. To have it heard as it happens, announce it from the app, through `SemanticsService` or a live region of its own.
- The `running` step is marked selected, as the current step of a sequence is.

:::

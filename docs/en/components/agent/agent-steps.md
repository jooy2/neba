---
title: AgentSteps
order: 4
---

# AgentSteps

<p class="neba-lede">A chain of steps that grows as it runs. Each one carries a status, a time and whatever it did, and the one at the bottom is usually still going.</p>

<Demo src="agent-steps/hero" />

```tsx
import { AgentStep, AgentSteps } from 'neba';

<AgentSteps running="Writing the answer">
  <AgentStep title="Read the request" duration={120} />
  <AgentStep title="Searched the documentation" meta="4 hits" duration={412} />
</AgentSteps>;
```

## Props

<PropsTable name="AgentSteps" />

Native `<ol>` attributes pass through to the root. Only `color` is excluded, since the table above spells it differently.

A [Timeline](../display/timeline) and a [HowToSteps](../surfaces/how-to-steps) draw a list that is known in advance: five stages of a checkout, four things to do in order. This one does not know how many items it has.

### AgentStep

<PropsTable name="AgentStep" />

Native `<li>` attributes pass through. `color` and `title` are excluded.

## Examples

### Growing while it runs

Append steps as they happen. A step's place in the list is not a prop, so nothing has to be renumbered when one is inserted — the chain works out which one the rail stops at.

`running` draws one more marker under the last step, for the case the next step has no name yet. `true` gives it no label at all, because the turning ring has already said what it is and the status is read out either way; a node gives it one.

<Demo src="agent-steps/growing">

<<< @/.vitepress/demos/agent-steps/growing.tsx

</Demo>

### status

The shared [`NebaRunStatus`](../../design/prop-conventions), the same four words a [ToolCall](./tool-call) takes, and the same four marks. `success` is the default, because a step that is already in the list has usually already run.

Colour follows the status the same way: a failed step is `danger` and a finished one `success` whatever the chain's `color` says, and `color` decides only what a `running` step looks like.

<Demo src="agent-steps/status">

<<< @/.vitepress/demos/agent-steps/status.tsx

</Demo>

### What a step did

`children` is the detail under the title — the query that was searched, the file that was read, or a whole [ToolCall](./tool-call). `meta` is for the short thing that belongs on the title line instead.

### duration

Milliseconds, written at the end of the title line. Leave it out and a `running` step counts its own from the second it starts, exactly as a [ToolCall](./tool-call) does.

### size · density

`size` moves the marker, the type scale and the gaps together. `density` changes only how far apart two steps sit, and the ladder is tighter than a [Timeline](../display/timeline)'s on purpose: a timeline is a record being browsed, and this is a list being watched, where air between the rows reads as the thing having stopped.

<Demo src="agent-steps/size">

<<< @/.vitepress/demos/agent-steps/size.tsx

</Demo>

## Accessibility

- An `<ol>` with `role="list"` spelled out, so Safari keeps the list semantics after Tailwind's reset takes the markers off.
- Every step's status is read out in words; the marks are `aria-hidden`.
- The `running` step carries `aria-current="step"`.

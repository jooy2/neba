---
title: Approval
order: 2
---

# Approval

<p class="neba-lede">The agent asking permission, and the record of what was answered. Allow once, always allow, deny — with the command it wants to run set out underneath, and a risk level beside the heading.</p>

<Demo src="approval/hero" />

```tsx
import { Approval } from 'neba';

<Approval
  risk="high"
  title="Run a shell command?"
  details="rm -rf ./dist"
  options={[
    { value: 'once', label: 'Allow once' },
    { value: 'always', label: 'Always allow' },
    { value: 'deny', label: 'Deny', color: 'danger' }
  ]}
/>;
```

## Props

<PropsTable name="Approval" />

Native `<div>` attributes pass through to the root. Only `color` and `title` are excluded, since the table above spells them differently.

A [Confirm](../feedback/confirm) and a [Popconfirm](../feedback/popconfirm) are the other two ways of asking. Both are opened by the reader, offer two answers, and are gone the moment one is taken. This one is opened by the agent, offers as many answers as the agent has, and stays: a transcript in which the question disappears once it is answered cannot be read back to find out what was agreed to.

### ApprovalOption

<PropsTable name="ApprovalOption" />

## Examples

### risk

`low`, `medium` and `high`. Each is written out as a word on the chip beside the heading — never a colour alone — and each takes over the card's family: `info`, `warning` and `danger`, which are the three that already mean this everywhere else in the library.

Leave `risk` out and the chip is not drawn; `color` then stands on its own, and defaults to `warning`.

<Demo src="approval/risk">

<<< @/.vitepress/demos/approval/risk.tsx

</Demo>

### No option is emphasised

Every button is `outline` in the card's family, and an option's own `variant` is how one is singled out. A permission request whose loudest button is "Allow" is a request answered by the shape of the buttons rather than by the reader, and the point of asking is that the answer should be the reader's.

An option's `description` is listed under the row rather than inside its button, so the buttons stay a row of short words and a reader who wants to know what "Always allow" covers can find out without pressing it.

### decision · onDecide

`onDecide` is handed the option's `value`. Left uncontrolled, the card also remembers the button that was pressed and replaces the row with a line naming the answer, which is enough for a transcript that is not re-rendered from a server.

Pass `decision` and the card shows only what it was told: `null` is still waiting, a `value` is answered. The root carries `data-decided` either way.

<Demo src="approval/decision">

<<< @/.vitepress/demos/approval/decision.tsx

</Demo>

### details

A string is drawn as preformatted text with its own line breaks kept, which is what a command or a payload wants. A node is rendered untouched, which is where the editable form of the arguments goes — the reader correcting the recipient before agreeing to send.

<Demo src="approval/details">

<<< @/.vitepress/demos/approval/details.tsx

</Demo>

## Accessibility

- The card is a `role="group"` named by its heading, so a screen reader's list of elements says which permission is being asked about.
- Each answer is a real [Button](../inputs/button) and reachable in the tab order.
- The risk level is a word, not only a colour.

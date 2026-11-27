---
title: Approval
order: 2
flutter: true
---

# Approval

<p class="neba-lede">The agent asking permission, and the record of what was answered. Allow once, always allow, deny — with the command it wants to run set out underneath, and a risk level beside the heading.</p>

<Demo src="approval/hero" />

::: fw react

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

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaApproval(
  risk: NebaApprovalRisk.high,
  title: const Text('Run a shell command?'),
  details: const Text('rm -rf ./dist'),
  options: const <NebaApprovalOption>[
    NebaApprovalOption(value: 'once', label: Text('Allow once')),
    NebaApprovalOption(value: 'always', label: Text('Always allow')),
    NebaApprovalOption(value: 'deny', label: Text('Deny'), color: NebaColor.danger),
  ],
  onDecide: (String value) => answer(value),
);
```

:::

## Props

<PropsTable name="Approval" />

::: fw react

Native `<div>` attributes pass through to the root. Only `color` and `title` are excluded, since the table above spells them differently.

:::

::: fw flutter

`risk` is a `NebaApprovalRisk` and each option a `NebaApprovalOption`. A Dart argument cannot tell "not given" from `null`, so `controlled: true` is what React's `decision={null}` says: the buttons stay until the caller hands an answer over. `labels` is a map keyed by the React package's names for the words, and `showIcon: false` is React's `icon={false}`.

:::

A [Confirm](../feedback/confirm) and a [Popconfirm](../feedback/popconfirm) are the other two ways of asking. Both are opened by the reader, offer two answers, and are gone the moment one is taken. This one is opened by the agent, offers as many answers as the agent has, and stays: a transcript in which the question disappears once it is answered cannot be read back to find out what was agreed to.

### ApprovalOption

<PropsTable name="ApprovalOption" />

## Examples

### risk

`low`, `medium` and `high`. Each is written out as a word on the chip beside the heading — never a colour alone — and each takes over the card's family: `info`, `warning` and `danger`, which are the three that already mean this everywhere else in the library.

Leave `risk` out and the chip is not drawn; `color` then stands on its own, and defaults to `warning`.

<Demo src="approval/risk">

::: fw react

<<< @/.vitepress/demos/approval/risk.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/approval/risk.dart

:::

</Demo>

### Option buttons

Every button is `outline` in the card's family. Set an option's own `variant` to single one out.

An option's `description` is listed under the row of buttons rather than inside its button.

### decision · onDecide

`onDecide` is handed the option's `value`. Left uncontrolled, the card also remembers the button that was pressed and replaces the row with a line naming the answer, which is enough for a transcript that is not re-rendered from a server.

::: fw react

Pass `decision` and the card shows only what it was told: `null` is still waiting, a `value` is answered. The root carries `data-decided` either way.

:::

::: fw flutter

Pass `controlled: true` with `decision` and the card shows only what it was told: `null` is still waiting, a `value` is answered. A `decision` that is a value shows that answer even without `controlled`.

:::

<Demo src="approval/decision">

::: fw react

<<< @/.vitepress/demos/approval/decision.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/approval/decision.dart

:::

</Demo>

### details

<Fw react="A string" flutter="A plain Text" /> is drawn as preformatted text with its own line breaks kept, which is what a command or a payload wants. <Fw react="A node" flutter="Any other widget" /> is rendered untouched, which is where the editable form of the arguments goes — the reader correcting the recipient before agreeing to send.

<Demo src="approval/details">

::: fw react

<<< @/.vitepress/demos/approval/details.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/approval/details.dart

:::

</Demo>

## Accessibility

::: fw react

- The card is a `role="group"` named by its heading, so a screen reader's list of elements says which permission is being asked about.
- Each answer is a real [Button](../inputs/button) and reachable in the tab order.
- The risk level is a word, not only a colour.
- An Approval appearing is not announced on its own. To have the question heard, write it into a live region the app keeps on the page, or move the focus to the card.

:::

::: fw flutter

- The card is a semantics node of its own named by its heading, so a screen reader says which permission is being asked about before it reads the answers.
- Each answer is a real [Button](../inputs/button) and reachable in the focus order.
- The risk level is a word, not only a colour.
- When a press replaces the buttons, the line naming the answer takes the focus the pressed button had, unless it has already moved somewhere else.
- An Approval appearing is not announced on its own. To have the question heard, announce it from the app, or move the focus into the card.

:::

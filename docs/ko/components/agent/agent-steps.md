---
title: AgentSteps
order: 4
flutter: true
---

# AgentSteps

<p class="neba-lede">실행되면서 자라는 단계 사슬입니다. 각 단계는 상태와 걸린 시간, 그리고 그 단계가 한 일을 함께 들고 있으며, 맨 아래 것은 대개 아직 진행 중입니다.</p>

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

`<ol>`의 기본 속성은 루트로 전달됩니다. 위 표에서 다르게 정의한 `color`만 제외됩니다.

:::

::: fw flutter

React의 `running`은 `true`와 노드를 모두 받지만, 여기서는 `bool`이고 노드는 `runningTitle`입니다. `labels`는 상태 이름을 키로 삼는 맵입니다.

:::

[Timeline](../display/timeline)과 [HowToSteps](../surfaces/how-to-steps)는 미리 아는 목록을 그립니다. 결제의 다섯 단계, 순서대로 할 네 가지처럼요. 이쪽은 항목이 몇 개인지 모릅니다.

### AgentStep

<PropsTable name="AgentStep" />

::: fw react

`<li>`의 기본 속성은 그대로 전달됩니다. `color`와 `title`만 제외됩니다.

:::

::: fw flutter

`duration`은 `Duration`이고, `showIcon: false`가 React의 `icon={false}`입니다.

:::

## 예시

### 실행되면서 자랍니다

단계는 일어나는 대로 덧붙이면 됩니다. 단계의 순번은 prop이 아니므로 중간에 하나를 끼워 넣어도 다시 매길 것이 없습니다. 레일이 어디서 멈출지는 사슬이 알아서 셉니다.

::: fw react

`running`은 마지막 단계 아래에 표시를 하나 더 그립니다. 다음 단계에 아직 이름이 없는 경우를 위한 것입니다. `true`면 라벨을 붙이지 않습니다. 도는 링이 이미 그 말을 했고 상태는 어차피 읽히기 때문입니다. 노드를 주면 그것이 라벨이 됩니다.

:::

::: fw flutter

`running`은 마지막 단계 아래에 표시를 하나 더 그립니다. 다음 단계에 아직 이름이 없는 경우를 위한 것입니다. 그것만으로는 라벨을 붙이지 않습니다. 도는 링이 이미 그 말을 했고 상태는 어차피 읽히기 때문입니다. `runningTitle`을 주면 그것이 라벨이 됩니다. 끝이 아닌 자리에도 단계를 끼워 넣는다면 단계마다 key를 주세요. 그래야 각 단계가 자기 시계를 지킵니다.

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

공용 [`NebaRunStatus`](../../design/prop-conventions)이며, [ToolCall](./tool-call)이 받는 것과 같은 네 단어에 같은 네 가지 표시입니다. 기본값은 `success`입니다. 이미 목록에 들어와 있는 단계는 보통 이미 실행된 것이기 때문입니다.

색도 같은 방식으로 상태를 따릅니다. 실패한 단계는 사슬의 `color`가 무엇이든 `danger`, 끝난 단계는 `success`이고, `color`가 정하는 것은 `running`인 단계의 모습뿐입니다.

<Demo src="agent-steps/status">

::: fw react

<<< @/.vitepress/demos/agent-steps/status.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/agent_steps/status.dart

:::

</Demo>

### 단계가 한 일

<Fw react="children은" flutter="child는" /> 제목 아래의 세부입니다. 검색한 질의, 읽은 파일, 또는 [ToolCall](./tool-call) 하나를 통째로 넣어도 됩니다. 제목 줄에 올릴 짧은 것은 `meta`입니다.

### duration

<Fw react="밀리초 단위이며" flutter="Duration이며" /> 제목 줄 끝에 씁니다. 주지 않으면 `running`인 단계가 시작한 시점부터 스스로 셉니다. [ToolCall](./tool-call)과 같습니다.

### size · density

`size`는 표시와 타입 스케일, 간격을 함께 움직입니다. `density`는 두 단계 사이의 간격만 바꾸며, 그 사다리는 [Timeline](../display/timeline)의 것보다 촘촘합니다.

<Demo src="agent-steps/size">

::: fw react

<<< @/.vitepress/demos/agent-steps/size.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/agent_steps/size.dart

:::

</Demo>

## 접근성

::: fw react

- `role="list"`를 명시한 `<ol>`입니다. Tailwind의 reset이 마커를 없앤 뒤에도 Safari가 목록 의미를 유지합니다.
- 모든 단계의 상태는 단어로 쓰여 있어서 스크린 리더가 그 단계에 닿으면 읽습니다. 표시는 `aria-hidden`입니다.
- 단계의 상태가 바뀌어도 저절로 알려지지는 않습니다. 바뀌는 순간을 들려주려면 앱이 페이지에 두는 live region, 예컨대 `role="status"` 요소에 그 내용을 쓰세요.
- `running`인 단계에는 `aria-current="step"`이 붙습니다.

:::

::: fw flutter

- 스크린 리더에게 사슬은 목록이고, 단계 하나하나는 그 항목입니다.
- 모든 단계의 상태는 제목보다 먼저 단어로 읽힙니다. 표시는 그리기만 하고 읽지 않습니다.
- 단계의 상태가 바뀌어도 저절로 알려지지는 않습니다. 바뀌는 순간을 들려주려면 앱이 `SemanticsService`나 직접 둔 live region으로 알리세요.
- `running`인 단계는 순서 안의 현재 단계처럼 선택된 것으로 표시됩니다.

:::

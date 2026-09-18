---
title: AgentSteps
order: 4
---

# AgentSteps

<p class="neba-lede">실행되면서 자라는 단계 사슬입니다. 각 단계는 상태와 걸린 시간, 그리고 그 단계가 한 일을 함께 들고 있으며, 맨 아래 것은 대개 아직 진행 중입니다.</p>

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

`<ol>`의 기본 속성은 루트로 전달됩니다. 위 표에서 다르게 정의한 `color`만 제외됩니다.

[Timeline](../display/timeline)과 [HowToSteps](../surfaces/how-to-steps)는 미리 아는 목록을 그립니다. 결제의 다섯 단계, 순서대로 할 네 가지처럼요. 이쪽은 항목이 몇 개인지 모릅니다.

### AgentStep

<PropsTable name="AgentStep" />

`<li>`의 기본 속성은 그대로 전달됩니다. `color`와 `title`만 제외됩니다.

## 예시

### 실행되면서 자랍니다

단계는 일어나는 대로 덧붙이면 됩니다. 단계의 순번은 prop이 아니므로 중간에 하나를 끼워 넣어도 다시 매길 것이 없습니다. 레일이 어디서 멈출지는 사슬이 알아서 셉니다.

`running`은 마지막 단계 아래에 표시를 하나 더 그립니다. 다음 단계에 아직 이름이 없는 경우를 위한 것입니다. `true`면 라벨을 붙이지 않습니다. 도는 링이 이미 그 말을 했고 상태는 어차피 읽히기 때문입니다. 노드를 주면 그것이 라벨이 됩니다.

<Demo src="agent-steps/growing">

<<< @/.vitepress/demos/agent-steps/growing.tsx

</Demo>

### status

공용 [`NebaRunStatus`](../../design/prop-conventions)이며, [ToolCall](./tool-call)이 받는 것과 같은 네 단어에 같은 네 가지 표시입니다. 기본값은 `success`입니다. 이미 목록에 들어와 있는 단계는 보통 이미 실행된 것이기 때문입니다.

색도 같은 방식으로 상태를 따릅니다. 실패한 단계는 사슬의 `color`가 무엇이든 `danger`, 끝난 단계는 `success`이고, `color`가 정하는 것은 `running`인 단계의 모습뿐입니다.

<Demo src="agent-steps/status">

<<< @/.vitepress/demos/agent-steps/status.tsx

</Demo>

### 단계가 한 일

`children`은 제목 아래의 세부입니다. 검색한 질의, 읽은 파일, 또는 [ToolCall](./tool-call) 하나를 통째로 넣어도 됩니다. 제목 줄에 올릴 짧은 것은 `meta`입니다.

### duration

밀리초 단위이며 제목 줄 끝에 씁니다. 주지 않으면 `running`인 단계가 시작한 시점부터 스스로 셉니다. [ToolCall](./tool-call)과 같습니다.

### size · density

`size`는 표시와 타입 스케일, 간격을 함께 움직입니다. `density`는 두 단계 사이의 간격만 바꾸며, 그 사다리는 [Timeline](../display/timeline)의 것보다 일부러 촘촘합니다. Timeline은 훑어보는 기록이고 이쪽은 지켜보는 목록인데, 움직이는 것 사이의 여백은 멈춘 것처럼 읽힙니다.

<Demo src="agent-steps/size">

<<< @/.vitepress/demos/agent-steps/size.tsx

</Demo>

## 접근성

- `role="list"`를 명시한 `<ol>`입니다. Tailwind의 reset이 마커를 없앤 뒤에도 Safari가 목록 의미를 유지합니다.
- 모든 단계의 상태가 단어로 읽힙니다. 표시는 `aria-hidden`입니다.
- `running`인 단계에는 `aria-current="step"`이 붙습니다.

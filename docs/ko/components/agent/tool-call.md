---
title: ToolCall
order: 1
---

# ToolCall

<p class="neba-lede">에이전트 transcript에 놓이는 도구 호출 하나입니다. 무엇을 불렀고, 무엇을 넘겼고, 무엇이 돌아왔고, 얼마나 걸렸는지를 보여 줍니다. 헤더는 늘 보이고 나머지는 그 뒤로 접힙니다.</p>

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

`<div>`의 기본 속성은 루트로 전달됩니다. 위 표에서 다르게 정의한 `color`와 `onChange`만 제외됩니다.

`status`는 공용 [`NebaRunStatus`](../../design/prop-conventions)이며, [AgentSteps](./agent-steps)의 step이 받는 것과 같은 네 단어입니다. 나머지 공용 축도 다른 곳에서와 같은 뜻입니다.

## 예시

### status

`pending`, `running`, `success`, `error`. 색뿐 아니라 모양도 각각 다릅니다. 점선 링, 도는 링, 체크, 가위표. 색을 구분하지 못해도 상태를 읽을 수 있고, 스크린 리더에는 네 단어가 그대로 읽힙니다.

`color`가 정하는 것은 `running`일 때의 색 하나뿐입니다. 나머지 셋은 고정입니다. 실패한 것은 `danger`, 끝난 것은 `success`이며, 페이지 위의 모든 ToolCall에서 같습니다.

<Demo src="tool-call/status">

<<< @/.vitepress/demos/tool-call/status.tsx

</Demo>

### duration

밀리초 단위입니다. 1초 미만은 밀리초로, 그 위는 초로 씁니다. 처음 10초까지는 소수점 한 자리, 그 뒤로는 정수입니다. `Intl.NumberFormat`을 거치므로 `locale`이 독자의 언어로 씁니다.

주지 않으면 `running`인 호출이 실행을 시작한 시점부터 스스로 셉니다. 첫 1초 동안은 아무 말도 하지 않고, 그 뒤로 1초마다 갱신하며, 실제 `duration`이 도착하면 멈춥니다.

### args · result · error

문자열은 `<pre>`에 들어가고, 줄바꿈이 그대로 유지되며 필요하면 스크롤이 생깁니다. 들여쓴 JSON도, 스택 트레이스도, diff도 줄이 어디서 끊기느냐가 곧 의미이기 때문입니다. 그 밖의 값은 노드로 보고 손대지 않고 그리므로 [CodeBlock](../display/code-block)이나 [DataList](../display/data-list)를 그대로 넣을 수 있습니다.

`status`가 `error`이면 `error`가 `result` 자리를 대신합니다. `error`가 없으면 실패한 호출도 `result`를 보여 주는데, 도구가 돌려준 오류 자체인 경우가 많기 때문입니다.

<Demo src="tool-call/body">

<<< @/.vitepress/demos/tool-call/body.tsx

</Demo>

### open · defaultOpen

패널은 닫힌 채로 시작합니다. 다만 _실패한_ 호출은 스스로 열립니다. 무엇이 잘못됐는지를 독자가 찾아다녀야 할 이유는 없습니다. 이 동작은 `error`로 넘어가는 순간에만 일어나므로, 다시 닫으면 닫힌 채로 남습니다.

`open`을 넘기면 이 동작까지 함께 꺼집니다. 제어되는 ToolCall은 호출한 쪽이 둔 그대로이고, 실패해도 움직이지 않습니다.

`args`도 `result`도 `error`도 children도 없는 ToolCall은 아예 disclosure가 아닙니다. 헤더 줄만 그리고 누를 것은 없습니다.

### variant

컨테이너가 그러듯 시트에는 색을 들이지 않습니다. 도구 호출이 담는 것은 남의 JSON이고, 그 안의 문법 색은 전부 평범한 배경을 기준으로 고른 것이기 때문입니다. `text`는 시트를 아예 그리지 않으므로, 이런 것이 스무 개 쌓인 열에는 이쪽이 맞습니다.

<Demo src="tool-call/variant">

<<< @/.vitepress/demos/tool-call/variant.tsx

</Demo>

## 접근성

- 헤더는 진짜 버튼이고, Base UI가 `aria-expanded`와 `aria-controls`로 패널과 연결합니다.
- 상태는 단어로 읽힙니다. 표시는 `aria-hidden`입니다. 모양은 읽히지 않기 때문입니다.
- 루트에 `data-status`가 붙습니다. 스타일링과, 상태를 확인해야 하는 테스트를 위한 것입니다.

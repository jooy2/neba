---
title: Reasoning
order: 3
---

# Reasoning

<p class="neba-lede">스트림이 열고 닫는 사고 패널입니다. 모델이 생각하는 동안 채워지고, 생각이 끝나면 스스로 접히며, 그런 일이 있었다는 사실과 걸린 시간을 한 줄로 남깁니다.</p>

<Demo src="reasoning/hero" />

```tsx
import { Reasoning } from 'neba';

<Reasoning streaming={thinking}>{thoughts}</Reasoning>;
```

## Props

<PropsTable name="Reasoning" />

`<div>`의 기본 속성은 루트로 전달됩니다. 위 표에서 다르게 정의한 `color`와 `onChange`만 제외됩니다.

라이브러리의 다른 fold는 [Spoiler](../surfaces/spoiler)와 [Collapsible](../surfaces/collapsible)이고, 둘 다 열림 상태는 독자의 것입니다. 독자가 덮었고 독자가 엽니다. 이쪽은 스트림의 것입니다.

## 예시

### streaming

나머지를 전부 끌고 가는 prop 하나입니다. true인 동안 헤더가 그렇게 말하고, 표시가 돌고, 루트에 `data-streaming`과 `aria-busy`가 붙고, 패널이 열려 있습니다. false가 되면 패널은 접히고 헤더는 요약이 됩니다.

`streaming`이 이미 true인 상태로 *마운트*된 Reasoning은 열린 채로 시작합니다. 열어 줄 변화가 앞으로 오지 않고, 닫힌 패널은 화면에 도착하고 있는 유일한 것을 가리게 되기 때문입니다.

<Demo src="reasoning/streaming">

<<< @/.vitepress/demos/reasoning/streaming.tsx

</Demo>

### duration

밀리초 단위이고, 헤더는 "Thought for 4.2s"로 읽힙니다. 주지 않으면 `streaming`이 true가 된 시점부터 스스로 셉니다. 세는 동안은 1초마다 갱신하고, 스트림이 멈출 때 한 번 더 재므로 헤더에는 실제로 걸린 시간이 적힙니다. 1초가 안 되는 구간은 "Thought for 900ms"처럼 씁니다. 스트림이 한 번도 돌지 않은 패널은 "Finished thinking"이라고 씁니다.

### autoOpen

켜져 있습니다. 끄면 헤더의 문장과 표시는 그대로 두고 패널만 독자가 둔 자리에 남습니다. 사고 자체가 본문인 페이지가 원하는 동작입니다.

어느 쪽이든 패널은 `streaming`의 값이 아니라 *변화*를 따릅니다. 스트림 도중에 패널을 접은 독자가 다음 토큰에서 뒤집히지 않습니다. `open`을 넘기면 이 동작 전체가 꺼지고, 제어되는 Reasoning은 호출한 쪽이 말한 자리에 있습니다.

### variant

기본값은 `text`이며 패널은 시트를 그리지 않습니다. 이 패널이 화면의 유일한 것일 때는 시트가 있는 variant를 넘기세요.

<Demo src="reasoning/variant">

<<< @/.vitepress/demos/reasoning/variant.tsx

</Demo>

## 접근성

- 헤더는 진짜 버튼이고, Base UI가 `aria-expanded`와 `aria-controls`로 패널과 연결합니다.
- 스트림이 도는 동안 루트에 `aria-busy`가 붙습니다.
- 닫힌 패널은 tab 순서에도 accessibility tree에도 없습니다. `hiddenUntilFound`를 끄지 않는 한 브라우저의 페이지 내 찾기는 그 안의 글을 찾아 패널을 열 수 있습니다.
- 패널은 일부러 live region이 **아닙니다**. 사고는 길고 도착하면서 계속 고쳐지므로, 스크린 리더가 그 수정을 전부 읽으면 정작 다다르려던 답이 묻힙니다.
- 사고가 끝나는 것도 알려지지 않습니다. 이를 들려주려면 앱이 페이지에 두는 live region, 예컨대 `role="status"` 요소에 그 내용을 쓰세요.

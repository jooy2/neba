---
title: ContextWindow
order: 5
---

# ContextWindow

<p class="neba-lede">컨텍스트 창을 얼마나 썼고 무엇으로 채웠는지 보여 줍니다. 링 하나, 짧게 줄인 토큰 수, 입력·출력·추론·캐시의 내역, 그리고 이번 턴의 비용입니다.</p>

<Demo src="context-window/hero" />

```tsx
import { ContextWindow } from 'neba';

<ContextWindow
  max={200_000}
  tokens={{ input: 94_200, output: 12_400, reasoning: 8_100, cached: 61_000 }}
  cost={0.42}
/>;
```

## Props

<PropsTable name="ContextWindow" />

`<div>`의 기본 속성은 루트로 전달됩니다. 위 표에서 다르게 정의한 `color`만 제외됩니다.

[Meter](../feedback/meter)도 같은 값을 막대로 그리고, 여기까지는 대부분 해냅니다. 못 하는 부분이 이 컴포넌트를 컴포넌트로 만듭니다. 토큰 수는 다섯 자리 여섯 자리라 독자의 언어로 짧게 줄여 써야 하고, 네 갈래 내역은 나란히 놓여야만 의미가 생기며, 그 아래 금액은 또 다른 단위입니다.

### ContextTokens

<PropsTable name="ContextTokens" />

## 예시

### max · used · tokens

`max`는 창의 크기, `used`는 쓴 양입니다. `used`를 주지 않으면 `input`과 `output`, `reasoning`을 더한 값이 됩니다. 내역을 아는 쪽은 합계도 알고 있으므로 이쪽이 보통입니다.

`cached`는 그 합에 들어가지 **않습니다**. 캐시를 보고하는 모델은 모두 "입력 중 이만큼이 캐시에서 나왔다"는 뜻으로 말하므로, 그 토큰은 이미 `input` 안에 있습니다. 다시 더하면 캐시가 아낀 만큼 창이 더 찬 것처럼 보고하게 됩니다. 얼마나 아꼈는지는 알 가치가 있으므로 줄로는 그대로 그립니다.

`tokens`의 각 항목은 모두 선택입니다. 보고된 것만 그립니다. 값이 `0`인 항목은 보고된 것입니다. 아무것도 돌려주지 않은 캐시와 캐시가 없는 모델은 다른 사실입니다.

<Demo src="context-window/filling">

<<< @/.vitepress/demos/context-window/filling.tsx

</Demo>

### thresholds

링의 색이 바뀌는 지점이며, 비율이 아니라 토큰 수로 씁니다. 5분의 4는 `{ from: 0.8 * max, color: 'warning' }`입니다. [Meter](../feedback/meter)가 받는 것과 같은 prop이고 읽는 방식도 같습니다. 주어진 순서대로 읽고, 값이 도달한 마지막 항목이 이깁니다.

### 내역의 색

네 항목은 색 계열 넷이 아니라 차트 팔레트의 앞 네 슬롯을 씁니다. 입력과 출력은 *개체*이고, 둘 중 어느 쪽도 성공이나 위험을 뜻하지 않기 때문입니다. 슬롯은 위의 고정된 순서대로 배정되며, 그래야 색각 구분을 확인한 인접 쌍이 그대로 인접합니다.

### breakdown

켜져 있습니다. 끄면 링과 그 옆의 숫자만 남습니다. [Toolbar](../surfaces/toolbar)나 [PromptInput](./prompt-input) 끝에 들어가는 형태입니다.

<Demo src="context-window/compact">

<<< @/.vitepress/demos/context-window/compact.tsx

</Demo>

### locale

124,000 토큰을 `124K`로 쓸지 `12.4万`으로 쓸지 `12.4만`으로 쓸지, 비용을 어떤 통화 형식으로 쓸지를 정합니다. provider의 `locale`을 따르므로 서버와 브라우저가 같은 글자를 씁니다.

<Demo src="context-window/locale">

<<< @/.vitepress/demos/context-window/locale.tsx

</Demo>

## 접근성

- Base UI의 Meter가 의미를 맡습니다. 값과 범위 속성을 가진 `role="meter"`이므로, 그림이 아니라 읽을 수 있는 값으로 전달됩니다.
- `aria-valuetext`는 화면에 찍히는 문장과 같습니다. 아무도 설명하지 않은 범위의 백분율이 아닙니다.
- 내역 옆의 색 사각형은 `aria-hidden`이고, 모든 항목은 단어로 이름이 붙습니다.

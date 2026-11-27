---
title: ContextWindow
order: 5
flutter: true
---

# ContextWindow

<p class="neba-lede">컨텍스트 창을 얼마나 썼고 무엇으로 채웠는지 보여 줍니다. 링 하나, 짧게 줄인 토큰 수, 입력·출력·추론·캐시의 내역, 그리고 이번 턴의 비용입니다.</p>

<Demo src="context-window/hero" />

::: fw react

```tsx
import { ContextWindow } from 'neba';

<ContextWindow
  max={200_000}
  tokens={{ input: 94_200, output: 12_400, reasoning: 8_100, cached: 61_000 }}
  cost={0.42}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaContextWindow(
  max: 200000,
  tokens: NebaContextTokens(input: 94200, output: 12400, reasoning: 8100, cached: 61000),
  cost: 0.42,
);
```

:::

## Props

<PropsTable name="ContextWindow" />

::: fw react

`<div>`의 기본 속성은 루트로 전달됩니다. 위 표에서 다르게 정의한 `color`만 제외됩니다.

:::

::: fw flutter

`tokens`는 `NebaContextTokens`입니다. 위젯 계층에는 `Intl`이 없어서 `currency`가 없습니다. 토큰 수는 `format`이 쓰지 않으면 영어로, 비용은 `formatCost`가 쓰지 않으면 미국 달러로 씁니다. `labels`는 React 패키지가 쓰는 이름을 키로 삼는 맵입니다.

:::

[Meter](../feedback/meter)는 같은 값을 막대 하나로 그리며, 내역과 비용은 없습니다.

### ContextTokens

<PropsTable name="ContextTokens" />

## 예시

### max · used · tokens

`max`는 창의 크기, `used`는 쓴 양입니다. `used`를 주지 않으면 `input`과 `output`, `reasoning`을 더한 값이 됩니다. 내역을 아는 쪽은 합계도 알고 있으므로 이쪽이 보통입니다.

`cached`는 그 합에 들어가지 **않습니다**. 캐시를 보고하는 모델은 모두 "입력 중 이만큼이 캐시에서 나왔다"는 뜻으로 말하므로, 그 토큰은 이미 `input` 안에 있습니다. 다시 더하면 캐시가 아낀 만큼 창이 더 찬 것처럼 보고하게 됩니다. 얼마나 아꼈는지는 알 가치가 있으므로 줄로는 그대로 그립니다.

`tokens`의 각 항목은 모두 선택입니다. 보고된 것만 그립니다. 값이 `0`인 항목은 보고된 것입니다. 아무것도 돌려주지 않은 캐시와 캐시가 없는 모델은 다른 사실입니다.

<Demo src="context-window/filling">

::: fw react

<<< @/.vitepress/demos/context-window/filling.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/context_window/filling.dart

:::

</Demo>

### thresholds

링의 색이 바뀌는 지점이며, 비율이 아니라 토큰 수로 씁니다. 5분의 4는 <Fw react="{ from: 0.8 * max, color: 'warning' }" flutter="NebaThreshold(from: 0.8 * max, color: NebaColor.warning)" code />입니다. [Meter](../feedback/meter)가 받는 것과 같은 prop이고 읽는 방식도 같습니다. 주어진 순서대로 읽고, 값이 도달한 마지막 항목이 이깁니다.

### 내역의 색

네 항목은 색 계열이 아니라 차트 팔레트의 앞 네 슬롯을 위의 순서대로 씁니다.

### breakdown

켜져 있습니다. 끄면 링과 그 옆의 숫자만 남습니다. [Toolbar](../surfaces/toolbar)나 [PromptInput](./prompt-input) 끝에 들어가는 형태입니다.

<Demo src="context-window/compact">

::: fw react

<<< @/.vitepress/demos/context-window/compact.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/context_window/compact.dart

:::

</Demo>

### <Fw react="locale" flutter="format · formatCost" />

::: fw react

124,000 토큰을 `124K`로 쓸지 `12.4万`으로 쓸지 `12.4만`으로 쓸지, 비용을 어떤 통화 형식으로 쓸지를 정합니다. provider의 `locale`을 따르므로 서버와 브라우저가 같은 글자를 씁니다.

:::

::: fw flutter

124,000 토큰을 `124K`가 아닌 다른 모양으로, 비용을 `$0.42`가 아닌 다른 모양으로 씁니다. 위젯 계층에는 물어볼 `Intl`이 없으므로 다른 언어의 숫자와 다른 통화는 호출하는 쪽의 함수입니다. `locale`이 바꾸는 것은 게이지의 단어뿐입니다.

:::

<Demo src="context-window/locale">

::: fw react

<<< @/.vitepress/demos/context-window/locale.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/context_window/locale.dart

:::

</Demo>

## 접근성

::: fw react

- Base UI의 Meter가 의미를 맡습니다. 값과 범위 속성을 가진 `role="meter"`이므로, 그림이 아니라 읽을 수 있는 값으로 전달됩니다. meter는 링과 라벨, 수치까지이고 내역과 비용, `children`은 그 바깥에 있습니다. 그래서 내역은 목록으로 읽히고, 그 아래의 링크도 링크로 동작합니다.
- `aria-valuetext`는 화면에 찍히는 문장과 같습니다. 아무도 설명하지 않은 범위의 백분율이 아닙니다.
- 내역 옆의 색 사각형은 `aria-hidden`이고, 모든 항목은 단어로 이름이 붙습니다.

:::

::: fw flutter

- 링과 라벨, 수치가 라벨을 이름으로 하는 semantics 노드 하나이고, 그 값은 화면에 찍히는 문장과 같습니다. 아무도 설명하지 않은 범위의 백분율이 아닙니다. 내역과 비용, `child`는 그 바깥에 있어서 내역은 목록으로 읽히고, 그 아래의 링크도 링크로 동작합니다.
- 내역 옆의 색 사각형은 그리기만 하고 읽지 않으며, 모든 항목은 단어로 이름이 붙습니다.

:::

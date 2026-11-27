---
title: GaugeChart
order: 9
flutter: true
---

# GaugeChart

<p class="neba-lede">미리 정해진 범위 위의 값 하나를 계기판으로 그립니다. 같은 값을 그린 막대보다 멀리서도 읽히므로 대시보드 타일에 적합합니다.</p>

<Demo src="gauge-chart/hero" />

::: fw react

```tsx
import { GaugeChart } from 'neba';

<GaugeChart label="Memory" caption="Memory" value={82} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaGaugeChart(label: 'Memory', caption: Text('Memory'), value: 82);
```

:::

## Props

<PropsTable name="GaugeChart" />

::: fw react

[Box](../surfaces/box)의 모든 prop이 전달되므로 계기판 자체가 카드가 될 수 있습니다. `legend`도 `tooltip`도 없습니다. 값이 하나이면 구분할 것도, 드러낼 것도 없습니다. 숫자는 가운데에 쓰여 있습니다.

:::

::: fw flutter

계기판은 [Box](../surfaces/box) 위에 놓이고 `variant`·`size`·`color`·`density`·`elevation`·`padded`·`transition`이 그대로 전달되므로, 계기판 자체가 카드가 될 수 있습니다. `legend`도 `tooltip`도 없습니다. 값이 하나이면 구분할 것도, 드러낼 것도 없습니다. 숫자는 가운데에 쓰여 있습니다. `center`와 `caption`은 `Widget`을 받고, `ticks`는 `int?`입니다. React가 `false`로 받는 "눈금 없음"은 `null`입니다.

:::

[Meter](../feedback/meter)를 호로 구부린 것이며, 의도적으로 같은 컴포넌트의 두 가지 모양입니다. `value`, `min`, `max`, `thresholds`는 그쪽에서와 같은 뜻이므로, 하나의 값을 막대에서 계기판으로 옮겨도 말하는 바가 달라지지 않습니다.

<Fw react='`shape="semi"`인' flutter="`NebaPieShape.semi`인" /> [PieChart](./pie-chart)가 아닙니다. 파이는 전체의 부분들이고 모든 조각이 범주입니다. 이쪽은 범위에 대한 값 하나이며, 채워지지 않은 호는 두 번째 범주가 아니라 계기판의 나머지입니다.

## 예시

### value · min · max

`value`가 `null`이면 아무것도 얹히지 않은 계기판과 가운데의 대시를 그립니다.

### thresholds

호의 색이 바뀌는 지점입니다. 값이 도달한 마지막 항목이 이기고, 아무 것에도 도달하지 못했다면 `color`가 그대로 쓰입니다.

<Demo src="gauge-chart/thresholds">

::: fw react

<<< @/.vitepress/demos/gauge-chart/thresholds.tsx

:::

</Demo>

### sweep

계기판이 도는 각도이며 12시를 중심으로 좌우 대칭으로 열립니다. `180`은 타일이 원하는 반원, `270`은 계기의 모양, `360`은 고리입니다. 주어진 sweep에 맞춰 상자에 대해 크기가 잡히므로 반원이 위쪽 절반을 비워두는 일이 없습니다.

<Demo src="gauge-chart/sweep">

::: fw react

<<< @/.vitepress/demos/gauge-chart/sweep.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gauge_chart/sweep.dart

:::

</Demo>

### ticks · thickness · showRange

`ticks`는 양 끝을 포함해 계기판 둘레에 눈금을 그립니다. 기본은 꺼짐입니다. 대시보드 위의 계기판은 비율로 읽히고, 눈금은 거기서 *숫자*를 읽어내는 계기의 것이기 때문입니다. `thickness`는 반지름에 대한 호의 두께이고, `showRange`는 양 끝에 `min`과 `max`를 씁니다.

<Demo src="gauge-chart/ticks">

::: fw react

<<< @/.vitepress/demos/gauge-chart/ticks.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/gauge_chart/ticks.dart

:::

</Demo>

### center · caption

가운데의 값은 진짜 텍스트입니다. 선택되고, 찾아지고, 접근성 트리에 들어갑니다. `center`는 그것을 대체하며 읽는 값이 단어인 계기판을 위한 것이고, `caption`은 그 아래 단위를 적는 한 줄입니다.

## 접근성

::: fw react

- `label`이 있으면 계기판은 그 이름을 가진 `role="meter"`가 되고, `value`, `min`, `max`가 `aria-valuenow`, `aria-valuemin`, `aria-valuemax`로 들어갑니다. `aria-valuetext`는 읽은 값 뒤에 텍스트인 `caption`을 붙인 문장이므로 단위는 `caption`에 넘기면 됩니다. `value={null}`이면 label로 이름이 붙은 `role="img"`입니다. `label`이 없으면 평범한 상자로 남고, 가운데의 숫자는 그대로 텍스트로 읽힙니다.

:::

::: fw flutter

- `label`이 있으면 계기판은 그 이름을 가진 노드 하나가 되고, 그 값은 읽은 값 뒤에 `Text`인 `caption`을 붙인 문장입니다. 단위는 `caption`에 넘기면 됩니다. Flutter에는 meter role도, 최솟값과 최댓값을 알릴 방법도 없으므로 화면 낭독기는 [Meter](../feedback/meter)에서처럼 읽은 값을 값으로 듣습니다. `value: null`이면 label로 이름이 붙은 이미지입니다. `label`이 없으면 평범한 상자로 남고, 가운데의 숫자는 그대로 텍스트로 읽힙니다.

:::

- 색이 유일한 전달 수단이 되지 않습니다. threshold를 넘은 값은 호도 더 많이 채웠고, 숫자도 쓰여 있습니다.

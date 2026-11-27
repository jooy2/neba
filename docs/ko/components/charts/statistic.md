---
title: Statistic
order: 8
flutter: true
---

# Statistic

<p class="neba-lede">이름 붙은 수치 하나를 보여 줍니다. 이전 값을 함께 주면 변화량을 계산해 옆에 표시합니다.</p>

<Demo src="statistic/hero" />

::: fw react

```tsx
import { Statistic } from 'neba';

<Statistic label="월 반복 매출" value={48210} prefix="$" previousValue={42800} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaStatistic(
  label: Text('월 반복 매출'),
  value: 48210,
  prefix: Text(r'$'),
  previousValue: 42800,
);
```

:::

## Props

<PropsTable name="Statistic" />

::: fw react

`<div>`의 native 속성과 [Box](../surfaces/box)의 모든 prop이 그대로 전달됩니다. 변화량은 [Chip](../display/chip)으로 렌더링됩니다.

:::

::: fw flutter

시트는 [Box](../surfaces/box)이며, `variant`, `size`, `color`, `density`, `elevation`, `padded`, `transition`이 그대로 전달됩니다. 변화량은 [Chip](../display/chip)으로 그립니다. `label`, `prefix`, `unit`, `icon`, `caption`은 위젯이고 보통 `Text`를 넘깁니다.

:::

## 예시

### previousValue · delta · betterWhen

`previousValue`를 주면 현재 값과의 변화량이 계산되어 표시됩니다. `delta`는 그 변화를 비율로 쓸지, 차이로 쓸지, 둘 다 쓸지를 정합니다.

`betterWhen`은 어느 방향이 좋은 소식인지 알려 줍니다. 매출은 올라가는 쪽이, 이탈률은 내려가는 쪽이 좋으므로, 이 값이 없으면 변화량의 색을 정할 수 없습니다.

<Demo src="statistic/comparison">

::: fw react

<<< @/.vitepress/demos/statistic/comparison.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/statistic/comparison.dart

:::

</Demo>

변화량은 색과 함께 모양도 바뀝니다. 오를 때는 상승 화살표, 내릴 때는 하락 화살표, 변화가 없을 때는 짧은 선입니다. 색만으로 방향을 표현하지 않습니다.

### icon · unit · caption · align

`icon`은 라벨 앞, `unit`은 수치 뒤에 놓입니다. <Fw react="`children`은" flutter="`child`는" /> 수치 아래 자리로, 목표 대비 [ProgressLinear](../feedback/progress-linear)나 [Sparkline](./sparkline)을 넣을 수 있습니다. <Fw react='align="center"' flutter="align: NebaAlign.center" code />는 여러 타일을 한 줄로 늘어놓을 때 씁니다.

`prefix`와 `unit`이 따로 있는 이유는 조판 위치가 다르기 때문입니다. 통화 기호는 숫자 앞, 단위는 뒤에 옵니다.

<Demo src="statistic/anatomy">

::: fw react

<<< @/.vitepress/demos/statistic/anatomy.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/statistic/anatomy.dart

:::

</Demo>

### format

::: fw react

`format`은 `Intl.NumberFormat` 옵션으로 그대로 전달됩니다. 생략하면 읽는 사람의 locale에 맞춰 자릿수만 구분합니다. `value`에 문자열을 주면 서식을 적용하지 않고 그대로 출력하므로, 숫자가 아닌 수치도 표시할 수 있습니다.

```tsx
<Statistic label="매출" value={48210} format={{ style: 'currency', currency: 'KRW' }} />
<Statistic label="전환율" value={0.0423} format={{ style: 'percent', maximumFractionDigits: 1 }} />
<Statistic label="빌드 중앙값" value="3m 12s" />
```

:::

::: fw flutter

`format`은 숫자를 쓰는 함수이고, 수치와 절대 변화량 모두에 쓰입니다. 생략하면 세 자리마다 쉼표로 묶고 소수점 아래는 세 자리까지 씁니다. widgets 계층에는 `intl`이 없으므로 통화나 다른 언어의 구분 기호는 이 함수로 씁니다. `value`에 `String`이나 위젯을 주면 그대로 그리고 비교하지 않으므로, 숫자가 아닌 수치도 표시할 수 있습니다.

```dart
NebaStatistic(label: const Text('전환율'), value: 0.0423, format: (num v) => '${(v * 100).toStringAsFixed(1)}%');
const NebaStatistic(label: Text('빌드 중앙값'), value: '3m 12s');
```

:::

`previousValue`가 `0`이면 비율을 계산할 수 없으므로, `delta` 설정과 무관하게 차이 값만 표시합니다.

### locale

::: fw react

`locale`은 수치와 차이 값을 어느 언어로 쓸지 정합니다. 모든 차트가 받는 것과 같은 prop이므로, 대시보드 한 장에 놓인 Statistic과 [LineChart](./line-chart)에 같은 값을 걸 수 있습니다. 생략하면 읽는 사람의 locale을 따릅니다.

```tsx
<Statistic label="매출" value={1234.5} locale="de-DE" format={{ minimumFractionDigits: 1 }} />
```

:::

::: fw flutter

`locale`은 없습니다. 기본 수치는 어느 언어에서나 같은 모양으로 쓰이고, 다른 언어로 쓴 수치는 앱이 정한 언어로 `format`이 씁니다.

:::

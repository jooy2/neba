---
title: ProgressBox
order: 7
flutter: true
---

# ProgressBox

<p class="neba-lede">진행 상태를 여러 개의 판이 차례로 채워지는 형태로 표시합니다. Neba 표면 위의 로딩 상태에 어울리는 형태입니다.</p>

<Demo src="progress-box/hero" align="center" />

::: fw react

```tsx
import { ProgressBox } from 'neba';

<ProgressBox />
<ProgressBox value={62} label="마이그레이션 중" showValue />
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaProgressBox();
const NebaProgressBox(value: 62, label: Text('마이그레이션 중'), showValue: true);
```

:::

## Props

<PropsTable name="ProgressBox" />

::: fw react

`<div>`의 native 속성은 root로 전달됩니다. `color`와 `children`만 위 표와 이름이 겹쳐 제외됩니다.

:::

::: fw flutter

너비는 판들의 줄과 그 위 라벨 줄 가운데 더 넓은 쪽을 따릅니다. `semanticLabel`을 주면 `label` 대신 screen reader가 읽을 이름이 됩니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

:::

`value` · `min` · `max` · `format` · `showValue`는 [ProgressLinear](./progress-linear)와 동일하게 동작합니다. `value`가 `null`이면 판이 순서대로 밝아지는 indeterminate 상태입니다.

## 예시

### count

판의 개수입니다. 값이 있을 때 판은 왼쪽부터 채워지고, 진행 중인 판은 부분적으로 채워집니다. 판 단위로만 채워지면 판 4개로는 0 · 25 · 50 · 75 · 100만 표현할 수 있기 때문입니다.

<Demo src="progress-box/counts">

::: fw react

<<< @/.vitepress/demos/progress-box/counts.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_box/counts.dart

:::

</Demo>

### 단계 표시로 쓰기

`count`를 실제 단계 수에 맞추면 판 하나가 단계 하나가 됩니다. 진행 중인 단계의 판이 채워지는 중으로 표시됩니다.

<Demo src="progress-box/steps">

::: fw react

<<< @/.vitepress/demos/progress-box/steps.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_box/steps.dart

:::

</Demo>

## 모션 줄이기

판은 위치가 움직이지 않고 채움과 빛 가장자리만 애니메이션합니다. <Fw react="`prefers-reduced-motion`" flutter="`MediaQuery.disableAnimations`" />에서는 주기가 느려집니다.

## 접근성

::: fw react

- `role="progressbar"`와 값 속성이 적용되고, `label`이 accessible name이 됩니다.
- indeterminate 상태는 `0`이 아니라 미정으로 보고됩니다.

:::

::: fw flutter

- screen reader는 진행률을 이 줄의 값으로 듣고, `label`로 넘긴 `Text`가 이름이 됩니다. `semanticLabel`을 주면 그것으로 바뀝니다.
- indeterminate 상태는 `0`이 아니라 값 없는 작업 중 표시로 알려집니다.

:::

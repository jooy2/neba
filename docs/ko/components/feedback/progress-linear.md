---
title: ProgressLinear
order: 5
flutter: true
---

# ProgressLinear

<p class="neba-lede">진행률을 가로 막대로 표시합니다. 세 가지 progress 컴포넌트 중 가장 널리 쓰이는 형태입니다.</p>

<Demo src="progress-linear/hero" />

::: fw react

```tsx
import { ProgressLinear } from 'neba';

<ProgressLinear value={64} label="에셋 업로드 중" showValue />
<ProgressLinear />
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaProgressLinear(value: 64, label: Text('에셋 업로드 중'), showValue: true);
const NebaProgressLinear();
```

:::

## Props

<PropsTable name="ProgressLinear" />

::: fw react

`<div>`의 native 속성은 root로 전달됩니다. `color`와 `children`만 위 표와 이름이 겹쳐 제외됩니다.

:::

::: fw flutter

막대는 주어진 너비를 차지합니다. `label`은 위젯이며 보통 `Text`를 넘기고, `semanticLabel`을 주면 그 대신 screen reader가 읽을 이름이 됩니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

:::

`value`의 기본값은 `null`이며, 진행률을 알 수 없는 indeterminate 상태를 뜻합니다. 짧은 조각이 막대 위를 반복해 지나갑니다. `0`을 주면 "아직 아무것도 진행되지 않음"이라는 다른 의미가 되므로 구분해서 쓰세요.

## 예시

### size

<Demo src="progress-linear/sizes">

::: fw react

<<< @/.vitepress/demos/progress-linear/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_linear/sizes.dart

:::

</Demo>

### thickness

`size`는 라이브러리의 사다리 위 한 단계이고, `thickness`는 <Fw react="픽셀" flutter="논리 픽셀" /> 값입니다. 페이지가 그 숫자 하나를 위해 존재할 때 쓰는 prop입니다. 바뀌는 것은 홈의 두께뿐이고, 옆에 붙는 라벨의 타입 스케일은 `size`가 계속 맡습니다.

::: fw react

```tsx
<ProgressLinear value={62} thickness={12} />
```

:::

::: fw flutter

```dart
const NebaProgressLinear(value: 62, thickness: 12)
```

:::

### min · max · format

표시되는 백분율은 100이 아니라 `min`…`max` 구간에 대한 비율입니다. `showValue`로 값을 옆에 띄우고, <Fw react="`format`에 `Intl.NumberFormat` 옵션을 주면" flutter="`format`에 값을 글자로 바꾸는 함수를 주면" /> 바이트나 파일 수, 금액처럼 숫자 자체를 보여 줄 수 있습니다.

::: fw react

`locale`은 그 값을 쓰는 언어이며, 주지 않으면 provider의 값을 따르므로 서버와 브라우저가 같은 글자를 씁니다.

:::

::: fw flutter

함수는 범위 안으로 잡힌 값을 받으며, 앱이 이미 쓰는 formatter와 언어로 그 값을 씁니다. 그래서 `locale`은 없습니다.

:::

<Demo src="progress-linear/values">

::: fw react

<<< @/.vitepress/demos/progress-linear/values.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_linear/values.dart

:::

</Demo>

## 모션 줄이기

<Fw react="`prefers-reduced-motion`" flutter="`MediaQuery.disableAnimations`" />에서도 indeterminate 애니메이션이 멈추지는 않습니다. 대신 지나가던 조각이 사라지고 막대 전체가 색으로 맥동합니다.

## 접근성

::: fw react

- `role="progressbar"`와 값·범위 속성이 적용되고, indeterminate일 때는 `aria-valuenow`가 빠집니다.
- `label`이 accessible name이 되고, `aria-valuetext`는 화면에 표시된 값과 같은 내용을 전달합니다.

:::

::: fw flutter

- screen reader는 진행률을 막대의 값으로 듣습니다. `showValue`가 화면에 쓰는 것과 같은 글자입니다. indeterminate일 때는 값이 없고 작업 중 표시로 알려집니다.
- `label`로 넘긴 `Text`가 screen reader가 읽는 이름이 되고, `semanticLabel`을 주면 그것으로 바뀝니다.

:::

---
title: ProgressCircular
order: 6
flutter: true
---

# ProgressCircular

<p class="neba-lede">진행률을 원형 고리로 표시합니다. 가로 막대를 놓을 자리가 없는 좁은 공간에 씁니다.</p>

<Demo src="progress-circular/hero" align="center" />

::: fw react

```tsx
import { ProgressCircular } from 'neba';

<ProgressCircular value={72} showValue label="색인 중" />
<ProgressCircular />
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaProgressCircular(value: 72, showValue: true, label: Text('색인 중'));
const NebaProgressCircular();
```

:::

## Props

<PropsTable name="ProgressCircular" />

::: fw react

`<div>`의 native 속성은 root로 전달됩니다. `color`와 `children`만 위 표와 이름이 겹쳐 제외됩니다.

:::

::: fw flutter

고리와 그 옆의 글자는 필요한 만큼만 너비를 차지하고, 자리가 모자라면 긴 `label`은 말줄임표로 잘립니다. `semanticLabel`을 주면 `label` 대신 screen reader가 읽을 이름이 됩니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

:::

`value`의 기본값은 `null`이며 indeterminate 상태에서는 고리가 회전합니다. `min` · `max` · `format`은 [ProgressLinear](./progress-linear)와 동일하게 동작합니다. <Fw react="`locale`도 마찬가지입니다." />

## 예시

### size

<Demo src="progress-circular/sizes">

::: fw react

<<< @/.vitepress/demos/progress-circular/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_circular/sizes.dart

:::

</Demo>

### thickness

`size`는 고리의 지름이고, `thickness`는 고리 선의 두께를 <Fw react="픽셀로" flutter="논리 픽셀로" /> 정합니다. 화면이 그 수치 하나를 위해 존재할 때 쓰는 prop입니다. 두께는 반지름의 절반까지만 커지므로 가운데 구멍이 늘 남습니다.

::: fw react

```tsx
<ProgressCircular value={62} size="xl" thickness={6} />
```

:::

::: fw flutter

```dart
const NebaProgressCircular(value: 62, size: NebaSize.xl, thickness: 6)
```

:::

### 컨트롤 안에 넣기

고리는 각 단계에서 컨트롤 높이보다 한 단계 작습니다. `md` 고리는 32px 컨트롤 안의 20px입니다. 버튼이나 필드, 표의 행에 넣어도 행 높이가 늘어나지 않습니다.

<Demo src="progress-circular/inline">

::: fw react

<<< @/.vitepress/demos/progress-circular/inline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/progress_circular/inline.dart

:::

</Demo>

### showValue와 label

값은 고리 안이 아니라 옆에 놓입니다. `xs`에서는 고리 지름이 14px이라 안쪽에 숫자가 들어갈 자리가 없기 때문입니다. `showValue`와 `label`은 고리와 한 줄로 정렬됩니다.

## 접근성

::: fw react

- SVG 그림 자체는 `aria-hidden`이고, 값은 바깥 요소의 `role="progressbar"`를 통해 전달됩니다.
- `label`이 accessible name이 됩니다.

:::

::: fw flutter

- 그림은 스스로 아무것도 알리지 않습니다. screen reader는 진행률을 고리의 값으로 듣고, 이것은 `showValue`가 화면에 쓰는 글자와 같습니다. indeterminate일 때는 값 없이 작업 중 표시로 알려집니다.
- `label`로 넘긴 `Text`가 screen reader가 읽는 이름이 되고, `semanticLabel`을 주면 그것으로 바뀝니다.

:::

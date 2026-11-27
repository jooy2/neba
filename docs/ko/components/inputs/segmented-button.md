---
title: SegmentedButton
order: 19
flutter: true
---

# SegmentedButton

<p class="neba-lede">두세 개의 선택지를 하나로 붙여 놓고 그중 하나를 고르는 컨트롤입니다. 선택지가 짧고 개수가 적을 때, 모든 선택지를 한눈에 보여 주면서 자리를 아낍니다.</p>

<Demo src="segmented-button/hero" />

::: fw react

```tsx
import { Segment, SegmentedButton } from 'neba';

<SegmentedButton aria-label="기간" defaultValue="week">
  <Segment value="day">일</Segment>
  <Segment value="week">주</Segment>
  <Segment value="month">월</Segment>
</SegmentedButton>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaSegmentedButton<String>(
  semanticLabel: '기간',
  defaultValue: 'week',
  children: <NebaSegment<String>>[
    NebaSegment<String>(value: 'day', child: Text('일')),
    NebaSegment<String>(value: 'week', child: Text('주')),
    NebaSegment<String>(value: 'month', child: Text('월')),
  ],
);
```

:::

## Props

### SegmentedButton

<PropsTable name="SegmentedButton" />

::: fw react

`value`와 `onValueChange`로 controlled, `defaultValue`로 uncontrolled 컴포넌트가 됩니다. 세트에는 이름이 필요하므로 `aria-label`이나 `aria-labelledby`를 주세요.

:::

::: fw flutter

세그먼트는 `NebaSegment`의 리스트인 `children`으로 받고, 세트는 그 `value`의 타입을 제네릭으로 받습니다. `value`와 `onValueChange`로 controlled 세트가 되며, `value`를 `null`로 두면 세트가 `defaultValue`에서 시작해 상태를 스스로 관리합니다. 세트에는 이름이 필요하므로 `semanticLabel`을 주세요. Flutter 세트에는 값을 실어 보낼 폼 전송이 없으므로 `name`은 없습니다.

:::

선택이 아니라 액션의 줄이라면 [ButtonGroup](./button-group)을, 아래에 패널이 딸린다면 [Tabs](../surfaces/tabs)를 쓰세요. 선택지가 다섯 개를 넘거나 라벨이 길다면 [Select](./select)가, 눈에 보이는 라벨이 필요하다면 [RadioGroup](./radio-group)이 적합합니다.

### Segment

<PropsTable name="Segment" />

## 예시

### variant

`solid`는 홈통 안에서 채워진 타일이 움직이고, `outline`은 같은 홈통에 테두리를 두르고 선택된 sheet를 밝힙니다. `text`는 홈통 없이 선택된 항목에만 표면이 생깁니다.

<Demo src="segmented-button/variants">

::: fw react

<<< @/.vitepress/demos/segmented-button/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/variants.dart

:::

</Demo>

### size

[Button](./button)과 같은 컨트롤 높이 단계를 씁니다. `md` Segment와 `md` Button이 모두 32px이므로 툴바에 나란히 놓아도 기준선이 맞습니다.

<Demo src="segmented-button/sizes">

::: fw react

<<< @/.vitepress/demos/segmented-button/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/sizes.dart

:::

</Demo>

### startIcon · disabled · readOnly

`readOnly`는 선택 상태를 보여 주되 바꿀 수 없게 하고 채도만 낮춥니다. `disabled`는 색 계열을 중립 회색으로 바꿉니다. `Segment` 단위로도 `disabled`를 줄 수 있습니다.

<Demo src="segmented-button/states">

::: fw react

<<< @/.vitepress/demos/segmented-button/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/segmented_button/states.dart

:::

</Demo>

### fullWidth

세트를 컨테이너 너비만큼 늘리고 각 Segment가 공간을 균등하게 나눠 갖습니다.

## 접근성

::: fw react

- `role="radiogroup"`으로 렌더링됩니다. 세트 전체가 tab 정지 하나이고, 그 안에서는 방향키로 이동하며, 선택된 항목에 `aria-checked`가 붙습니다.

:::

::: fw flutter

- 화면 낭독기에는 라디오 그룹으로 읽힙니다. 각 세그먼트가 라디오이고, 선택된 항목은 checked 상태입니다. 세트 전체가 tab 정지 하나이고, 그 안에서 방향키로 옮겨 가면 그 항목이 바로 선택되며, Space나 Enter는 focus가 있는 세그먼트를 선택합니다.

:::

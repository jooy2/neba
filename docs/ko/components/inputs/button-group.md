---
title: ButtonGroup
order: 2
flutter: true
---

# ButtonGroup

<p class="neba-lede">여러 Button을 하나의 세트로 붙여 놓습니다. 맞닿는 모서리가 깎이고, 공통 prop을 세트에 한 번만 지정할 수 있습니다.</p>

<Demo src="button-group/hero" />

::: fw react

```tsx
import { Button, ButtonGroup } from 'neba';

<ButtonGroup variant="outline">
  <Button>일간</Button>
  <Button>주간</Button>
  <Button>월간</Button>
</ButtonGroup>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaButtonGroup(
  variant: NebaVariant.outline,
  children: <Widget>[
    NebaButton(onPressed: day, child: const Text('일간')),
    NebaButton(onPressed: week, child: const Text('주간')),
    NebaButton(onPressed: month, child: const Text('월간')),
  ],
);
```

:::

## Props

<PropsTable name="ButtonGroup" />

::: fw react

`color`를 제외한 `<div>`의 native 속성이 그대로 전달됩니다.

:::

::: fw flutter

버튼은 `children`으로 받습니다. 버튼은 자기 인자를 먼저 따르고, 그다음 그룹, 그다음 `NebaProvider`의 값을 따릅니다. 그래서 버튼의 `disabled`는 `bool?`이며, 주지 않으면 그룹의 값을 씁니다.

:::

## 예시

### 공통 prop 전달

`variant` · `size` · `color` · `density` · `elevation` · `disabled`를 그룹에 지정하면 모든 자식 [Button](./button)에 전달됩니다. 버튼에 직접 지정한 값이 그룹의 값을 덮어쓰므로, 보조 액션들 사이에 `danger` 버튼 하나만 섞을 수 있습니다.

<Demo src="button-group/shared">

::: fw react

<<< @/.vitepress/demos/button-group/shared.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button_group/shared.dart

:::

</Demo>

### orientation

`vertical`은 버튼을 세로로 쌓고 위아래 모서리를 깎습니다.

<Demo src="button-group/orientation">

::: fw react

<<< @/.vitepress/demos/button-group/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button_group/orientation.dart

:::

</Demo>

### fullWidth

그룹을 컨테이너 너비만큼 늘리고, 버튼들이 공간을 균등하게 나눠 갖습니다. 라벨이 그 몫보다 긴 버튼은 자기 너비를 유지하고, 나머지 버튼이 남은 공간을 나눠 갖습니다.

<Demo src="button-group/full-width">

::: fw react

<<< @/.vitepress/demos/button-group/full-width.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button_group/full_width.dart

:::

</Demo>

## 접근성

- <Fw react="`role=&quot;group&quot;`으로 렌더링됩니다. 버튼 라벨만으로 세트의 목적을 알 수 없다면 `aria-label`을 붙이세요." flutter="화면 낭독기에 버튼을 한 그룹으로 묶어 알립니다. 버튼 라벨만으로 세트의 목적을 알 수 없다면 `semanticLabel`을 주세요." />
- 선택 상태를 관리하지 않습니다. 여럿 중 하나를 고르는 컨트롤이라면 [SegmentedButton](./segmented-button)이나 [RadioGroup](./radio-group)을 쓰세요.
- hover되거나 focus된 버튼이 이웃보다 위로 올라오므로 focus ring이 잘리지 않습니다.

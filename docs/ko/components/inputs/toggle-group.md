---
title: ToggleGroup
order: 26
flutter: true
---

# ToggleGroup

<p class="neba-lede">하나의 상태를 공유하는 토글 묶음입니다. 이웃과 맞닿는 모서리는 각지고, 값은 세트가 소유하며, 공통 prop은 구성원 전체에 한 번만 지정합니다.</p>

<Demo src="toggle-group/hero" />

::: fw react

```tsx
import { Toggle, ToggleGroup } from 'neba';

<ToggleGroup aria-label="Text alignment" defaultValue={['left']}>
  <Toggle value="left">Left</Toggle>
  <Toggle value="center">Center</Toggle>
  <Toggle value="right">Right</Toggle>
</ToggleGroup>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaToggleGroup(
  semanticLabel: 'Text alignment',
  defaultValue: <String>['left'],
  children: <Widget>[
    NebaToggle(value: 'left', child: Text('Left')),
    NebaToggle(value: 'center', child: Text('Center')),
    NebaToggle(value: 'right', child: Text('Right')),
  ],
);
```

:::

## Props

<PropsTable name="ToggleGroup" />

::: fw react

`<div>`의 모든 속성이 그대로 전달됩니다. `variant`, `size`, `color`, `density`, `elevation`, `disabled`는 세트 안의 모든 [Toggle](./toggle)에 전달되며, 토글 자신의 prop이 우선합니다. 중립적인 세트 안에 danger 토글 하나를 두는 것은 흔한 구성입니다.

:::

::: fw flutter

토글은 `children`으로 받으며, 각 토글은 `value`로 이름을 갖습니다. `variant`, `size`, `color`, `density`, `elevation`, `disabled`는 세트 안의 모든 [Toggle](./toggle)에 전달되며, 토글 자신의 인자가 우선합니다. 중립적인 세트 안에 danger 토글 하나를 두는 것은 흔한 구성입니다.

:::

## 예시

### value와 onValueChange

값은 단일 선택이든 다중 선택이든 배열입니다. `multiple`을 켜도 타입이 바뀌지 않습니다. `value`와 `onValueChange`로 controlled, `defaultValue`로 uncontrolled 세트가 됩니다.

### multiple

기본값인 `false`에서는 하나를 켜면 직전 것이 꺼집니다. 고르는 대상이 상태의 묶음이 아니라 _값_ 하나라면 [SegmentedButton](./segmented-button)이나 [RadioGroup](./radio-group)이 그 사실을 말해주는 컴포넌트입니다.

<Demo src="toggle-group/multiple">

::: fw react

<<< @/.vitepress/demos/toggle-group/multiple.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle_group/multiple.dart

:::

</Demo>

### variant

세트의 `variant`가 안의 모든 토글에 닿습니다.

<Demo src="toggle-group/variants">

::: fw react

<<< @/.vitepress/demos/toggle-group/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle_group/variants.dart

:::

</Demo>

### orientation

`vertical`은 토글을 세로로 쌓고 가로 이음매 쪽 모서리를 각지게 만듭니다. 방향키도 방향을 따릅니다.

<Demo src="toggle-group/orientation">

::: fw react

<<< @/.vitepress/demos/toggle-group/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle_group/orientation.dart

:::

</Demo>

### fullWidth

컨테이너 너비만큼 늘어나고 토글들이 그 폭을 균등하게 나눠 갖습니다.

<Demo src="toggle-group/full-width">

::: fw react

<<< @/.vitepress/demos/toggle-group/full-width.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle_group/full_width.dart

:::

</Demo>

## 접근성

- 세트 전체가 하나의 tab stop입니다. 방향키로 토글 사이를 이동하고, 끝에서 순환할지는 `loopFocus`가 정합니다.
- 그룹 자체에는 이름이 없으므로 <Fw react="`aria-label`을" flutter="`semanticLabel`을" /> 주세요.

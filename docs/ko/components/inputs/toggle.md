---
title: Toggle
order: 25
flutter: true
---

# Toggle

<p class="neba-lede">눌린 채로 머무는 버튼입니다. 액션을 실행하지 않고 상태를 유지합니다. 선택한 글자의 굵기, 캔버스의 격자, 목록에 걸린 필터가 그런 상태입니다.</p>

<Demo src="toggle/hero" />

::: fw react

```tsx
import { Toggle } from 'neba';

<Toggle defaultPressed>Bold</Toggle>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaToggle(defaultPressed: true, child: Text('Bold'));
```

:::

## Props

<PropsTable name="Toggle" />

::: fw react

`<button>`의 모든 속성이 그대로 전달됩니다. 예외는 [ToggleGroup](./toggle-group) 안에서 토글을 식별하는 `value`와 의미론적 색 역할인 `color`뿐입니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에 정리되어 있습니다.

:::

::: fw flutter

라벨은 `child`입니다. `value`는 [ToggleGroup](./toggle-group) 안에서 토글을 식별하며, 공통 축은 [prop 규칙](../../design/prop-conventions)에 정리되어 있습니다. 토글은 자기 인자를 먼저 따르고, 그다음 그룹, 그다음 `NebaProvider`의 값을 따르므로 `disabled`는 `bool?`입니다.

:::

[Switch](./switch)는 설정을 바꾸고 그 변화 자체가 목적이며, [Checkbox](./checkbox)는 폼과 함께 제출되는 답변입니다. Toggle은 둘 다 아닙니다. 옆에 있는 대상에 작용하는 컨트롤입니다.

## 예시

### pressed와 onPressedChange

`pressed`와 `onPressedChange`로 controlled, `defaultPressed`로 uncontrolled 컴포넌트가 됩니다.

<Demo src="toggle/controlled">

::: fw react

<<< @/.vitepress/demos/toggle/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle/controlled.dart

:::

</Demo>

### variant

`variant`는 토글이 **꺼져 있을 때**의 모습을 정합니다. `outline`이 기본이고, `solid`는 켜지면 accent로 채워지는 판이며, `text`는 hover하거나 켜지기 전까지 표면이 전혀 없습니다.

꺼진 토글은 세 variant 어디에서도 색 계열을 띠지 않습니다. 판은 중립 회백색이고 글자는 muted이며, 켜지는 순간 판과 글자와 hairline이 한꺼번에 accent로 넘어갑니다.

<Demo src="toggle/variants">

::: fw react

<<< @/.vitepress/demos/toggle/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle/variants.dart

:::

</Demo>

### 아이콘만 있는 토글

<Fw react="`children`이" flutter="`child`가" /> 없으면 토글은 `startIcon`을 감싸는 정사각형이 됩니다. 툴바가 원하는 모양입니다. 아이콘은 접근 가능한 이름을 만들지 못하므로 <Fw react="`aria-label`을" flutter="`semanticLabel`을" /> 주세요.

<Demo src="toggle/icons">

::: fw react

<<< @/.vitepress/demos/toggle/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle/icons.dart

:::

</Demo>

### size

`size`는 Button·TextField·Chip이 쓰는 것과 같은 컨트롤 높이입니다. 여러 컨트롤이 섞인 행에서도 baseline이 유지됩니다.

<Demo src="toggle/sizes">

::: fw react

<<< @/.vitepress/demos/toggle/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle/sizes.dart

:::

</Demo>

### color

`color`는 토글이 켜졌을 때 띠는 색입니다. 꺼져 있으면 어느 계열이든 중립입니다.

<Demo src="toggle/colors">

::: fw react

<<< @/.vitepress/demos/toggle/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toggle/colors.dart

:::

</Demo>

## 접근성

::: fw react

- `aria-pressed`를 가진 `<button>`으로 렌더링됩니다.
- 아이콘만 있는 토글에는 `aria-label`이 필요합니다. 이름을 가져올 텍스트가 없습니다.

:::

::: fw flutter

- 화면 낭독기에는 버튼으로 읽히며, 켜져 있는지도 함께 알립니다.
- 아이콘만 있는 토글에는 `semanticLabel`이 필요합니다. 이름을 가져올 텍스트가 없습니다.

:::

- [ToggleGroup](./toggle-group) 안에서는 세트 전체가 하나의 tab stop이고, 방향키로 구성원 사이를 이동합니다.

---
title: IconButton
order: 14
flutter: true
---

# IconButton

<p class="neba-lede">글리프 하나만 담는 원형 버튼입니다. 툴바나 목록 행처럼 라벨을 둘 공간이 없는 자리에 씁니다.</p>

<Demo src="icon-button/hero" />

::: fw react

```tsx
import { IconButton } from 'neba';

<IconButton icon={<PlusIcon />} label="항목 추가" />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaIconButton(onPressed: add, icon: const PlusIcon(), label: '항목 추가');
```

:::

## Props

<PropsTable name="IconButton" />

::: fw react

`<button>`의 native 속성은 그대로 전달됩니다. `variant` · `elevation` · `loading` · `readOnly`를 포함해 [Button](./button)의 축을 그대로 씁니다.

정사각형 아이콘 컨트롤이 필요하다면 `children` 없는 [Button](./button)이 이미 그 모양입니다.

:::

::: fw flutter

`variant` · `elevation` · `loading` · `readOnly`를 포함해 [Button](./button)의 축을 그대로 쓰고, `onPressed`가 없으면 비활성입니다. [ButtonGroup](./button-group) 안에서는 다른 버튼처럼 이웃과 맞닿은 모서리가 깎입니다.

정사각형 아이콘 컨트롤이 필요하다면 `child` 없는 [Button](./button)이 이미 그 모양입니다.

:::

## 예시

### size

[Button](./button)과 같은 컨트롤 높이 단계를 씁니다. 버튼이 늘어선 줄에 섞어 놓아도 기준선이 맞습니다.

<Demo src="icon-button/sizes">

::: fw react

<<< @/.vitepress/demos/icon-button/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon_button/sizes.dart

:::

</Demo>

### loading · readOnly · disabled

동작은 [Button](./button)의 같은 prop과 동일합니다. `loading`은 글리프 자리에 spinner를 띄웁니다.

<Demo src="icon-button/states">

::: fw react

<<< @/.vitepress/demos/icon-button/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon_button/states.dart

:::

</Demo>

### label

::: fw react

`label`은 필수 prop입니다. 글리프뿐인 버튼은 accessible name을 가질 방법이 없으므로 타입 차원에서 요구합니다.

```tsx
// 타입 에러가 발생합니다.
<IconButton icon={<TrashIcon />} />

// 이렇게 쓰세요.
<IconButton icon={<TrashIcon />} label="파일 삭제" />
```

`label`은 화면에 보이지 않습니다. 눈으로도 확인할 수 있게 하려면 [Tooltip](../feedback/tooltip)으로 감싸세요.

:::

::: fw flutter

`label`은 필수 매개변수입니다. 글리프뿐인 버튼은 화면 낭독기가 읽을 이름을 가질 방법이 없으므로 생성자가 요구합니다.

```dart
// 컴파일되지 않습니다.
NebaIconButton(onPressed: remove, icon: const TrashIcon());

// 이렇게 쓰세요.
NebaIconButton(onPressed: remove, icon: const TrashIcon(), label: '파일 삭제');
```

`label`은 화면에 보이지 않습니다. 눈으로도 확인할 수 있게 하려면 [Tooltip](../feedback/tooltip)으로 감싸세요.

:::

## 접근성

::: fw react

- `label`이 `aria-label`로 전달됩니다.
- focus ring은 `:focus-visible`에서만 나타납니다.

:::

::: fw flutter

- `label`은 화면 낭독기가 읽는 이름이며, 탭, Enter, Space가 모두 버튼을 누릅니다.
- focus ring은 키보드 focus에서만 나타납니다.

:::

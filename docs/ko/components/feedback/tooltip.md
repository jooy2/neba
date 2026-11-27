---
title: Tooltip
order: 4
flutter: true
---

# Tooltip

<p class="neba-lede">포인터가 잠시 머물면 나타나는 짧은 설명입니다. 아이콘만 있는 컨트롤의 용도를 보충할 때 씁니다.</p>

<Demo src="tooltip/hero" align="center" minHeight="120" />

::: fw react

```tsx
import { Button, Tooltip } from 'neba';

<Tooltip content="배포 URL 복사">
  <Button variant="outline" startIcon={<LinkIcon />} aria-label="Copy the deploy URL" />
</Tooltip>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaTooltip(
  content: const Text('배포 URL 복사'),
  child: NebaButton(
    onPressed: copy,
    variant: NebaVariant.outline,
    semanticLabel: 'Copy the deploy URL',
    startIcon: const LinkIcon(),
  ),
);
```

:::

## Props

<PropsTable name="Tooltip" />

::: fw react

`<div>`의 native 속성은 popup으로 전달됩니다. `color` · `content` · `children`만 위 표와 이름이 겹쳐 제외됩니다.

trigger는 별도의 box를 만들지 않고 `children`에 병합되므로 레이아웃에 영향을 주지 않습니다. `children`은 ref를 받고 props를 펼칠 수 있는 요소 하나여야 합니다. Neba 컴포넌트는 모두 해당합니다.

:::

::: fw flutter

Tooltip은 `child`에 병합되지 않고 감싸므로 어떤 위젯이든 trigger가 될 수 있고, 그래도 레이아웃에는 영향을 주지 않습니다. 설명은 [Popover](../surfaces/popover)처럼 앱의 root `Overlay`에 그려집니다.

:::

## 예시

### side와 align

`side`는 trigger를 기준으로 팝업이 놓일 방향, `align`은 그 축 위의 정렬입니다. 창 가장자리에 자리가 없으면 반대쪽으로 자동으로 넘어갑니다. `sideOffset`으로 간격을, `arrow`로 꼬리표 표시를 조절합니다.

<Demo src="tooltip/sides" minHeight="120">

::: fw react

<<< @/.vitepress/demos/tooltip/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tooltip/sides.dart

:::

</Demo>

### delay와 <Fw react="TooltipProvider" flutter="NebaTooltipProvider" />

`delay`는 포인터가 머문 뒤 열릴 때까지의 시간, `closeDelay`는 벗어난 뒤 닫힐 때까지의 시간입니다.

<Fw react="TooltipProvider" flutter="NebaTooltipProvider" code />로 감싸면 그 안의 Tooltip들이 지연을 공유합니다. 하나가 열린 뒤에는 이웃이 즉시 열리고, 잠시 쉬면 지연이 다시 적용됩니다. 아이콘 버튼이 여러 개 놓인 툴바에서 매번 지연을 기다리지 않게 됩니다.

::: fw flutter

provider는 자기 값이 없는 Tooltip 모두에 `delay`와 `closeDelay`를 내려주고, `timeout`으로 지연이 다시 적용되기까지 쉬는 시간을 정합니다. 기본은 400밀리초입니다.

:::

<Demo src="tooltip/grouped" minHeight="120">

::: fw react

<<< @/.vitepress/demos/tooltip/grouped.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tooltip/grouped.dart

:::

</Demo>

## 접근성

::: fw react

- 팝업에 `role="tooltip"`이 붙고, 열려 있는 동안에만 trigger에 `aria-describedby`가 연결됩니다.
- Tooltip은 **설명**이지 이름이 아닙니다. 아이콘만 있는 버튼에는 `aria-label`을 따로 주세요.
- 키보드 focus에서는 열리지만 클릭으로 옮겨온 focus에서는 열리지 않습니다. Esc로 닫힙니다.
- `disabled` 버튼은 focus를 받지 않으므로, 그 위의 Tooltip은 키보드로 열 수 없습니다. [Button](../inputs/button)에 `focusableWhenDisabled`를 주면 tab 순서에 남습니다.
- 터치 화면에서는 포인터로 닿을 수 없고, 안에 넣은 컨트롤은 누를 수 없습니다. 둘 중 하나가 필요하면 popover를 쓰세요.

:::

::: fw flutter

- `Text`인 `content`는 화면 낭독기에게 trigger의 tooltip이 되어, 설명이 떠 있든 아니든 trigger의 이름 뒤에 읽힙니다. 설명 자체는 두 번 읽히지 않습니다. 다른 위젯인 `content`는 열려 있는 동안 그려진 자리에서 읽힙니다.
- Tooltip은 **설명**이지 이름이 아닙니다. 아이콘만 있는 버튼에는 `semanticLabel`을 따로 주세요.
- 키보드 focus에서는 바로 열리지만 누름으로 trigger가 받은 focus에서는 열리지 않습니다. Esc로 닫힙니다.
- 비활성 버튼은 focus를 받지 않으므로, 그 위의 Tooltip은 키보드로 열 수 없습니다. [Button](../inputs/button)에 `focusableWhenDisabled`를 주면 focus 순서에 남습니다.
- 터치로는 열리지 않고, 안에 넣은 컨트롤은 누를 수 없습니다. 둘 중 하나가 필요하면 popover를 쓰세요.

:::

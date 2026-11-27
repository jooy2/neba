---
title: AnimateGrow
order: 9
flutter: true
---

# AnimateGrow

<p class="neba-lede">한 점에서 펼쳐지는 효과입니다. 최종 크기에 가까운 지점에서 시작하고 어느 변에든 고정할 수 있어서, 옆에 있는 것에서 열려 나오는 것처럼 읽힙니다.</p>

<Demo src="animate-grow/hero" />

::: fw react

```tsx
import { AnimateGrow } from 'neba';

<AnimateGrow origin="top">
  <Card title="필터">아홉 개 중 세 개 적용됨</Card>
</AnimateGrow>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAnimateGrow(
  origin: Alignment.topCenter,
  child: NebaCard(title: Text('필터'), child: Text('아홉 개 중 세 개 적용됨')),
);
```

:::

## Props

<PropsTable name="AnimateGrow" />

<Fw react="나머지 `<div>` 속성은 모두 루트로 전달됩니다." flutter="`child` 하나를 감싸거나, `children`을 `layoutBuilder`로 배치합니다." /> 모든 `Animate*`가 공유하는 설정은 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### origin

::: fw react

CSS `transform-origin` 그대로, 나머지가 움직이는 동안 제자리를 지키는 점입니다. `top`은 아래로 펼쳐지고 `bottom left`는 모서리에서 열리며, 기본값 `center`는 사방으로 고르게 커집니다. 이 확대가 무엇에서 _나오는_ 것처럼 보이는지를 정하는 prop입니다.

:::

::: fw flutter

`Alignment`로 주는, 나머지가 움직이는 동안 제자리를 지키는 점입니다. `Alignment.topCenter`는 아래로 펼쳐지고 `Alignment.bottomLeft`는 모서리에서 열리며, 기본값 `Alignment.center`는 사방으로 고르게 커집니다. 이 확대가 무엇에서 _나오는_ 것처럼 보이는지를 정하는 prop입니다.

:::

<Demo src="animate-grow/origin">

::: fw react

<<< @/.vitepress/demos/animate-grow/origin.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_grow/origin.dart

:::

</Demo>

### from과 fade

`from`은 최종 크기에 대한 시작 배율입니다. `1`보다 작으면 펼쳐지고, `1`보다 크면 커진 채로 등장해 제자리로 내려앉습니다. `fade`는 함께 따라오는 불투명도 변화이고, 이미 화면에 있으면서 크기만 바뀌는 것에는 꺼 두는 편이 맞습니다.

<Demo src="animate-grow/settling">

::: fw react

<<< @/.vitepress/demos/animate-grow/settling.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_grow/settling.dart

:::

</Demo>

### mode

<Fw react="`out`은" flutter="`NebaAnimateMode.exit`은" /> 다시 접습니다. 같은 애니메이션을 거꾸로 재생하고 끝에서 멈춥니다.

::: fw react

```tsx
<AnimateGrow mode="out" origin="top">
  <Card title="필터">아홉 개 중 세 개 적용됨</Card>
</AnimateGrow>
```

:::

::: fw flutter

```dart
const NebaAnimateGrow(
  mode: NebaAnimateMode.exit,
  origin: Alignment.topCenter,
  child: NebaCard(title: Text('필터'), child: Text('아홉 개 중 세 개 적용됨')),
);
```

:::

### stagger

`stagger`, `durationStep`, `reverse`는 상자 대신 자식 하나하나에게 효과를 차례로 넘깁니다. 동작은 [AnimateFade](./animate-fade)와 같고, 그쪽 페이지에 자세히 적혀 있습니다.

## 접근성

- 축소된 모션 설정에서는 애니메이션이 마지막 프레임으로 바로 넘어가고, 내용은 원래 크기로 그냥 거기 있거나 나가는 중이었다면 사라집니다.
- <Fw react="배율은 `transform` 단축 속성이 아니라 독립된 `scale` 속성으로 적용되므로, 같은 요소에 직접 건 transform이 그대로 남습니다." flutter="배율은 레이아웃이 놓은 위젯 둘레에 그리는 transform이므로, 옆의 것은 움직이지 않고 안쪽에 직접 건 transform도 그대로 남습니다." />

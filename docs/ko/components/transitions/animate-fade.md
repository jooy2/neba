---
title: AnimateFade
order: 9
flutter: true
---

# AnimateFade

<p class="neba-lede">불투명도만으로 나타나거나 사라지는 효과입니다. 이 묶음에서 가장 단순하고 가장 먼저 손이 가야 할 효과로, 아무것도 움직이지 않으므로 레이아웃이 다시 계산되지 않고 글자가 다시 그려지지도 않습니다.</p>

<Demo src="animate-fade/hero" />

::: fw react

```tsx
import { AnimateFade } from 'neba';

<AnimateFade>
  <Card title="배포 완료">서비스 두 개가 재시작되었고 오류는 없습니다.</Card>
</AnimateFade>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAnimateFade(
  child: NebaCard(
    title: Text('배포 완료'),
    child: Text('서비스 두 개가 재시작되었고 오류는 없습니다.'),
  ),
);
```

:::

## Props

<PropsTable name="AnimateFade" />

::: fw react

나머지 `<div>` 속성은 모두 루트로 전달됩니다.

:::

::: fw flutter

`child` 하나를 감싸거나, `children`을 `layoutBuilder`로 배치합니다. `layoutBuilder`를 주지 않으면 `Column`입니다. 스스로 그리는 것이 없고, 화면 낭독기에 들리는 것도 더하지 않습니다.

:::

모든 `Animate*`가 공유하는 설정(`duration`, `delay`, <Fw react="easing" flutter="curve" code />, `repeat`, `alternate`, `trigger`, `play`, `once`, `threshold`, `paused`)은 어디서나 같은 뜻이며 [Prop 규약](../../design/prop-conventions)에 정리되어 있습니다.

## 예시

### duration과 delay

::: fw react

둘 다 밀리초입니다. delay는 여러 개의 fade를 하나의 순서로 만드는 것이고, 그 대상이 목록일 때 대신 해 주는 것이 `AnimateAppear`입니다.

:::

::: fw flutter

둘 다 `Duration`입니다. delay는 여러 개의 fade를 하나의 순서로 만드는 것이고, 그 대상이 목록일 때는 아래의 `stagger`가 대신 해 줍니다.

:::

<Demo src="animate-fade/timing">

::: fw react

<<< @/.vitepress/demos/animate-fade/timing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_fade/timing.dart

:::

</Demo>

### trigger

`mount`가 기본값이고 아무것도 요구하지 않습니다. `visible`은 화면에 들어올 때까지 기다립니다. `once`를 끄지 않는 한 한 번만이고, `threshold`가 얼마나 들어와야 하는지를 정합니다. `hover`는 포인터가 올라가 있는 동안 재생하며 들어올 때마다 처음부터 다시 시작하고, 키보드 focus도 포인터로 셉니다. `manual`은 `play`가 말하기 전까지 아무것도 하지 않으며, `false` → `true`가 될 때마다 다시 시작합니다.

::: fw react

페이지 첫 화면에 보이는 콘텐츠는 기본값 `mount`를 그대로 두거나 `timeline="view"`를 쓰는 편이 좋습니다. 두 방식은 스타일시트만으로 재생되지만 `visible`은 페이지 스크립트가 로드되어 요소를 측정할 때까지 기다리므로, 첫 화면의 제목이나 이미지에 쓰면 그만큼 늦게 그려집니다.

:::

::: fw flutter

hover가 없는 터치 화면에서는 손가락을 대면 포인터가 들어온 것으로, 떼면 나간 것으로 셉니다. `visible`은 위젯을 레이아웃이 놓은 자리에서 측정하며, 위에 있는 모든 clip과 창에 비춰 봅니다. 주변 스크롤 뷰가 움직인 프레임마다 다시 재므로, 화면에 들어온 다음 프레임에 시작합니다. `play`는 `bool`이거나, 바뀔 때마다 효과를 다시 재생하는 숫자입니다.

:::

<Demo src="animate-fade/triggers">

::: fw react

<<< @/.vitepress/demos/animate-fade/triggers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_fade/triggers.dart

:::

</Demo>

### mode

<Fw react="`out`은" flutter="`NebaAnimateMode.exit`은" /> 같은 애니메이션을 거꾸로 재생하고 그 자리에 붙들어 둡니다. 사라진 요소는 애니메이션이 끝났다고 해서 다시 튀어나오지 않습니다. `alternate`와 함께 쓰면 처음으로 튀는 대신 되돌아오므로, 반복되는 fade가 맥동이 됩니다.

<Demo src="animate-fade/mode">

::: fw react

<<< @/.vitepress/demos/animate-fade/mode.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_fade/mode.dart

:::

</Demo>

### from

fade가 시작하는 불투명도로, `0`에서 `1` 사이입니다. 완전히 사라지면 안 되는 것은 이 값을 올려서 사라짐이 아니라 흐려짐으로 만듭니다.

::: fw react

```tsx
<AnimateFade from={0.4}>
  <Chip>초안</Chip>
</AnimateFade>
```

:::

::: fw flutter

```dart
const NebaAnimateFade(from: 0.4, child: NebaChip(child: Text('초안')));
```

:::

### stagger, durationStep, reverse

::: fw react

`stagger`는 한 자식 뒤에 다음 자식이 시작하기까지의 간격(ms)입니다. 기본값 `0`에서는 상자 자체가 페이드하고 자식은 건드리지 않습니다. 그보다 크면 효과가 자식 하나하나에게 넘어가고 상자에는 아무것도 남지 않으므로, 다섯 줄짜리 목록이 한 줄씩 도착합니다.

`durationStep`은 뒤에 오는 자식일수록 `duration`에 그만큼(ms)씩 더합니다. 음수를 주면 뒤로 갈수록 빨라지며, 재생 시간이 0 아래로 내려가지는 않습니다. `reverse`는 마지막 자식부터 실행합니다. 순서만 뒤집힐 뿐 각 자식은 그대로 앞으로 재생됩니다.

:::

::: fw flutter

`stagger`는 `children` 가운데 한 자식 뒤에 다음 자식이 시작하기까지의 간격입니다. 기본값인 0에서는 `layoutBuilder`로 배치한 `children` 전체가 하나로 페이드합니다. 그보다 크면 같은 배치 안에서 효과가 자식 하나하나에게 넘어가므로, 다섯 줄짜리 목록이 한 줄씩 도착합니다.

`durationStep`은 뒤에 오는 자식일수록 `duration`에 그만큼씩 더합니다. 음수를 주면 뒤로 갈수록 빨라지며, 재생 시간이 0 아래로 내려가지는 않습니다. `reverse`는 마지막 자식부터 실행합니다. 순서만 뒤집힐 뿐 각 자식은 그대로 앞으로 재생됩니다.

:::

간격은 _자식_ 단위입니다. 그래서 무엇을 넘기는지가 중요합니다. 자식 다섯이면 다섯 걸음이고, 다섯 개를 담은 자식 하나는 한 걸음입니다. 목록 일부를 빼고 싶으면 묶으면 됩니다.

<Demo src="animate-fade/stagger" minHeight="360">

::: fw react

<<< @/.vitepress/demos/animate-fade/stagger.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/animate_fade/stagger.dart

:::

</Demo>

## 접근성

- 축소된 모션 설정에서는 애니메이션이 마지막 프레임으로 바로 넘어가, 들어오는 내용은 그냥 거기 있고 나가는 내용은 사라집니다. <Fw react="아직 trigger를 기다리는 요소는 있는 그대로 보이며, 보이지 않는 상태로 남는 일은 없습니다. 스크립트를 끈 브라우저에서도 마찬가지입니다." flutter="아직 trigger를 기다리는 위젯은 있는 그대로 그려지며, 보이지 않는 상태로 남는 일은 없습니다." />
- 래퍼는 role도 이름도 더하지 않습니다. 안에 든 것이 자기 것을 그대로 지킵니다.

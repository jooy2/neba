---
title: AspectRatio
order: 8
flutter: true
---

# AspectRatio

<p class="neba-lede">어떤 너비를 받아도 비율을 지키는 상자입니다. 스스로는 아무것도 그리지 않고, 자리를 잡아 두고 그 안의 것을 형태에 붙잡아 둡니다.</p>

<Demo src="aspect-ratio/hero" align="center" />

::: fw react

```tsx
import { AspectRatio } from 'neba';

<AspectRatio ratio={16 / 9} rounded>
  <img src={src} alt="동틀 녘의 잔잔한 호수" />
</AspectRatio>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaAspectRatio(
  ratio: 16 / 9,
  rounded: true,
  child: Image.asset(path, semanticLabel: 'A still alpine lake at dawn'),
);
```

:::

## Props

<PropsTable name="AspectRatio" />

::: fw react

`<div>`의 기본 속성은 그대로 전달되며, `render`로 요소를 바꿀 수 있습니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

:::

::: fw flutter

아무것도 그리지 않고 `className`과 `style`도 받지 않습니다. 배경이나 테두리는 바깥이나 안쪽 위젯에 줍니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

:::

## 예시

### ratio

::: fw react

`ratio`는 CSS의 `aspect-ratio` 그 자체입니다. 숫자(`1.5`)든 비(`'16 / 9'`)든 손대지 않고 그대로 전달되므로 옮겨 적을 것이 없습니다.

:::

::: fw flutter

`ratio`는 너비를 높이로 나눈 `double`이라 `16 / 9`를 말하는 그대로 적습니다. 상자는 받을 수 있는 만큼 넓고 높이는 비율이 정하며, 받은 높이가 그보다 짧으면 그 높이에 맞춥니다.

:::

<Demo src="aspect-ratio/ratios">

::: fw react

<<< @/.vitepress/demos/aspect-ratio/ratios.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/aspect_ratio/ratios.dart

:::

</Demo>

### fit

::: fw react

`fit`은 직계 자식인 미디어 하나(`img`, `picture`, `video`, `canvas`)에 적용되는 `object-fit`입니다. 미디어는 먼저 상자에 맞게 늘어납니다. `svg`와 `iframe`도 상자에 맞게 늘어나지만 안의 내용은 스스로 배치하며, `svg`는 `preserveAspectRatio`로 맞춰집니다. `cover`는 잘라내고, `contain`은 여백을 남기며, `fill`은 찌그러뜨립니다. `none`은 파일 원래 크기를 유지하고, `scale-down`은 `none`과 `contain` 중 더 작게 그려지는 쪽이라 작은 파일을 키우지 않습니다.

:::

::: fw flutter

`fit`은 자식이 `Image`일 때 적용되는 `BoxFit`이며, 이미지는 먼저 상자에 맞게 늘어납니다. 그 밖의 자식은 상자에 맞게 늘어난 뒤 안의 내용을 스스로 배치하고, 다른 위젯 안에 든 이미지는 자기 `fit`을 씁니다. `BoxFit.cover`는 잘라내고, `contain`은 여백을 남기며, `fill`은 찌그러뜨립니다. `none`은 이미지 원래 크기를 유지하고, `scaleDown`은 `none`과 `contain` 중 더 작게 그려지는 쪽이라 작은 이미지를 키우지 않습니다. `fitWidth`와 `fitHeight`는 Flutter에만 있는 두 값입니다.

:::

<Demo src="aspect-ratio/fit">

::: fw react

<<< @/.vitepress/demos/aspect-ratio/fit.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/aspect_ratio/fit.dart

:::

</Demo>

### 자리 잡아 두기

내용이 도착했든 아니든 비율은 그대로이므로, AspectRatio 안의 [Skeleton](../feedback/skeleton)은 이미지가 차지할 바로 그 상자를 차지합니다. 이미지가 로드되어도 아래의 무엇도 움직이지 않습니다.

<Demo src="aspect-ratio/reserving">

::: fw react

<<< @/.vitepress/demos/aspect-ratio/reserving.tsx

:::

</Demo>

### rounded

`rounded`는 반경 사다리의 `size` 단계로 모서리를 깎으며, 기본은 꺼짐입니다.

::: fw react

```tsx
<AspectRatio ratio={4 / 3} rounded size="lg">
  <img src={src} alt="" />
</AspectRatio>
```

:::

::: fw flutter

```dart
NebaAspectRatio(
  ratio: 4 / 3,
  rounded: true,
  size: NebaSize.lg,
  child: Image.asset(path, excludeFromSemantics: true),
);
```

:::

## 접근성

::: fw react

- 이 상자는 role도 이름도 더하지 않습니다. 형태일 뿐이고, 읽히는 것은 그 안에 든 것입니다.
- 안의 `img`에는 여전히 자기 `alt`가 필요합니다. 장식용 이미지는 `alt=""`를 씁니다.

:::

::: fw flutter

- 이 상자는 시맨틱스를 더하지 않습니다. 형태일 뿐이고, 읽히는 것은 그 안에 든 것입니다.
- 안의 `Image`에는 여전히 자기 `semanticLabel`이 필요합니다. 장식용 이미지는 `excludeFromSemantics: true`를 씁니다.

:::

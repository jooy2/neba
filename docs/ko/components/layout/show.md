---
title: Show
order: 11
flutter: true
---

# Show

<p class="neba-lede">어떤 너비에서는 children을 그리고 어떤 너비에서는 그리지 않습니다. 바닥, 천장, 또는 둘 다를 라이브러리의 다른 모든 breakpoint와 같은 다섯 단계 사다리 위에서 정합니다.</p>

<Demo src="show/hero" />

::: fw react

```tsx
import { Show } from 'neba';

<Show above="md">
  <Sidebar />
</Show>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaShow(above: NebaBreakpoint.md, child: sidebar);
```

:::

## Props

<PropsTable name="Show" />

::: fw react

`<div>`의 기본 속성은 그대로 전달되며, `render`로 요소를 바꿀 수 있습니다. 다섯 breakpoint와 그 값은 [breakpoints](../../design/breakpoints)에서 설명합니다.

:::

::: fw flutter

아무것도 그리지 않고 `className`과 `style`도 받지 않습니다. 다섯 breakpoint는 `NebaBreakpoint`이며, 그 값은 [breakpoints](../../design/breakpoints)에서 설명합니다.

:::

## 예시

### above와 below

`above`는 그 값을 포함하고 `below`는 포함하지 않습니다. 그래서 같은 breakpoint를 양쪽에 쓰면 빈틈도 겹침도 없이 모든 너비를 정확히 한 번씩 덮습니다. 폰용 배치 하나와 나머지 전부를 위한 배치 하나를 두는 이 짝이 가장 흔한 경우입니다.

<Demo src="show/pair">

::: fw react

<<< @/.vitepress/demos/show/pair.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/show/pair.dart

:::

</Demo>

### 범위 지정하기

::: fw react

둘을 함께 주면 바닥과 천장이 됩니다. `above="sm" below="lg"`는 40rem부터 64rem 직전까지 그려집니다.

:::

::: fw flutter

둘을 함께 주면 바닥과 천장이 됩니다. `above: NebaBreakpoint.sm, below: NebaBreakpoint.lg`는 논리 픽셀 640부터 1024 직전까지 보입니다.

:::

<Demo src="show/range">

::: fw react

<<< @/.vitepress/demos/show/range.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/show/range.dart

:::

</Demo>

### 그리드나 flex row 안에서

::: fw react

`render`가 없으면 wrapper는 `display: contents`입니다. 그래서 [GridContainer](./grid)와 [Grid](./grid) 사이의 `Show`는 셀을 셀로 남겨 두고, flex row 안의 `Show`는 children을 flex item으로 남겨 둡니다. padding이나 배경처럼 스타일로 준 것은 내려앉을 곳이 없으므로, 안쪽 요소에 주거나 `render`로 요소를 지정하세요.

:::

::: fw flutter

보이는 NebaShow는 자식을 그 자리에서 바로 빌드하고 사이에 아무것도 두지 않습니다. 그래서 [GridContainer](./grid)와 [Grid](./grid) 사이의 NebaShow는 셀을 셀로 남겨 둡니다. 숨겨져 있는 동안에는 `NebaFlex`와 `NebaGridContainer`가 아예 빼고 배치하므로 셀도 간격도 차지하지 않습니다. Flutter의 `Row`와 `Column`은 그 빈 상자에도 다른 자식처럼 간격을 줍니다.

:::

<Demo src="show/transparent">

::: fw react

<<< @/.vitepress/demos/show/transparent.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/show/transparent.dart

:::

</Demo>

### 아예 렌더하지 않기

::: fw react

children은 언제나 렌더되고, 바뀌는 것은 `display`입니다. 그래서 브라우저가 그리는 첫 프레임부터 답이 맞고, 서버에서도 같은 답이 나옵니다.

어떤 너비 아래에서는 아예 _실행되면 안 되는_ 것(fetch를 하거나 지도를 mount하는 컴포넌트)은 CSS가 내릴 수 없는 결정이며, 그것은 `useBreakpoint`가 합니다. 서버에서도 클라이언트의 첫 렌더에서도 `false`이므로, 이것이 제어하는 것은 hydration 이후에 도착합니다.

```tsx
import { useBreakpoint } from 'neba';

const wide = useBreakpoint('md');

return wide ? <Map /> : <StaticImage />;
```

:::

::: fw flutter

너비는 창의 너비, 곧 `MediaQuery.sizeOf`이며 미디어 쿼리가 viewport를 읽는 것과 같습니다. 이 사이트의 미리보기에서는 미리보기 프레임이 창입니다. 숨겨진 자식은 아예 빌드되지 않으므로, 그 아래에서 fetch를 하거나 지도를 mount하는 위젯은 실행되지 않고, breakpoint를 넘나드는 위젯은 상태와 함께 새로 빌드됩니다.

직접 작성하는 build 메서드에서 정하려면 같은 너비를 사다리와 비교하세요.

```dart
final bool wide = MediaQuery.sizeOf(context).width >= NebaBreakpoint.md.width;

return wide ? const MapView() : const StaticImage();
```

:::

### render

::: fw react

`render`는 요소를 지정합니다. 테이블이나 리스트 안의 `Show`에 필요한 것으로, `<tr>`과 `<td>` 사이에 `<div>`는 올 수 없기 때문입니다. 지정한 요소는 자기 상자를 그대로 가지므로, `<td>`는 여백과 테두리를 유지하고 숨기는 동작만 더해집니다.

```tsx
<tr>
  <td>{row.name}</td>
  <Show above="lg" render={<td />}>
    {row.updatedAt}
  </Show>
</tr>
```

:::

::: fw flutter

`render`는 없습니다. Flutter 위젯에는 지정할 요소가 없고, 보이는 NebaShow는 자식 그 자체이므로 자식이 설 수 있는 곳이면 어디든 둘 수 있습니다.

:::

## 접근성

::: fw react

- 숨겨진 쪽은 `display: none`이므로 화면에서만이 아니라 접근성 트리와 탭 순서에서도 빠집니다. 무엇도 두 번 읽히지 않습니다.
- `above`/`below` 짝의 양쪽은 모든 너비에서 DOM에 있습니다. 그러므로 중복되면 안 되는 것(`id`, form control의 `name`, heading)은 둘 사이에서 달라야 하거나 짝 바깥에 있어야 합니다.

:::

::: fw flutter

- 숨겨진 쪽은 빌드되지 않으므로 화면에서만이 아니라 시맨틱스 트리와 포커스 순서에서도 빠집니다. 무엇도 두 번 읽히지 않습니다.
- `above`/`below` 짝은 한 번에 한쪽만 빌드되고, 다시 나타난 쪽은 새로 빌드되므로 거기에 입력했던 내용은 사라집니다.

:::

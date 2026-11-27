---
title: Toolbar
order: 7
flutter: true
---

# Toolbar

<p class="neba-lede">컨트롤을 한 줄로 배치하는 바입니다. 애플리케이션 헤더, 페이지의 액션 줄, 편집기 아래의 상태 띠에 씁니다.</p>

<Demo src="toolbar/hero" />

::: fw react

```tsx
import { Toolbar } from 'neba';

<Toolbar render={<header />} start={<Logo />} end={<Button>배포</Button>}>
  워크스페이스
</Toolbar>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaToolbar(
  start: const <Widget>[Logo()],
  end: <Widget>[NebaButton(onPressed: deploy, child: const Text('배포'))],
  children: const <Widget>[Text('워크스페이스')],
);
```

:::

## Props

<PropsTable name="Toolbar" />

::: fw react

`<div>`의 native 속성은 그대로 전달됩니다.

자리는 셋입니다. `start`와 `end`가 각자의 끝에 고정되고 `children`이 남은 폭을 가져가므로, 간격을 벌리기 위한 spacer를 따로 넣을 필요가 없습니다.

:::

::: fw flutter

자리는 셋이고, 각 자리는 위젯 목록을 8픽셀 간격으로 한 줄에 놓습니다. `start`와 `end`가 각자의 끝에 고정되고 `children`이 남은 폭을 가져가므로, 간격을 벌리기 위한 `Spacer`를 따로 넣을 필요가 없습니다. 가운데에서 그 폭을 채워야 하는 위젯, 예를 들어 필드는 `Expanded`로 감쌉니다. 바는 받은 폭을 그대로 씁니다.

:::

## 예시

### size와 density

Toolbar에는 고정 높이가 없습니다. 안에 든 컨트롤 높이에 여백을 더한 만큼 높아지고, 그 여백을 `size`와 `density`가 정합니다. <Fw react='density="compact"' flutter="density: NebaDensity.compact" code />는 타입 스케일을 건드리지 않고 여백만 줄입니다.

<Demo src="toolbar/density">

::: fw react

<<< @/.vitepress/demos/toolbar/density.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toolbar/density.dart

:::

</Demo>

### position과 side

::: fw react

`position`은 CSS의 세 값을 그대로 씁니다.

- `sticky`: 애플리케이션 헤더에 적합합니다. 자기 자리를 차지하므로 아래 콘텐츠에 여백을 줄 필요가 없습니다.
- `fixed`: 흐름에서 빠지므로, 페이지가 스스로 여백을 마련하지 않으면 첫 화면이 바 뒤에 깔립니다.

:::

::: fw flutter

`position`은 CSS의 세 값을 받지만, Flutter 위젯은 부모가 놓아 준 자리에 그려지므로 바를 실제로 옮기는 값은 `fixed`뿐입니다.

- `sticky`: 가장자리에 붙었을 때의 모습으로 바를 그립니다. 그 자리에 붙들어 두는 일은 스크롤 뷰가 맡습니다. `CustomScrollView` 안의 `PinnedHeaderSliver`에 넣거나, `Expanded` 스크롤 뷰를 감싼 `Column`의 맨 위나 맨 아래에 둡니다.
- `fixed`: 흐름에서 빠져 가장 가까운 `Overlay`의 가장자리에 폭 전체로 붙고, 원래 자리는 비워 둡니다. 페이지가 스스로 여백을 마련하지 않으면 첫 화면이 바 뒤에 깔립니다.

:::

`side`는 바가 붙을 가장자리입니다. 고정된 바는 모서리 반경을 버립니다. 화면 가장자리의 둥근 모서리는 뒤에 아무것도 없는 틈이 됩니다. `safeArea`는 그 가장자리의 화면 inset을 여백에 더해, 휴대폰의 노치와 홈 인디케이터를 피합니다.

<Demo src="toolbar/sticky">

::: fw react

<<< @/.vitepress/demos/toolbar/sticky.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toolbar/sticky.dart

:::

</Demo>

### divider와 elevation

`divider`는 바 아래에 선을 그어 아래에 콘텐츠가 있음을 보여 줍니다. 고정된 바에서도 `elevation`은 `0`으로 남으므로, 스크롤에 맞춰 직접 올리거나 `divider`를 켜세요.

### color

`color`는 선에 적용됩니다. 남의 컨트롤을 담는 바이므로 sheet 자체는 색으로 채우지 않습니다.

## 접근성

::: fw react

- `role="toolbar"`를 붙이지 않습니다. 그 role은 바 전체가 tab 정지 하나이고 내부를 방향키로 이동한다는 약속이므로, 구현하지 않은 채 주장하면 키보드 사용자에게 오히려 방해가 됩니다.
- 페이지 헤더로 쓸 때는 `render={<header />}`를 주세요. 실제 landmark가 되어 screen reader 사용자가 이동 기준으로 쓸 수 있습니다.
- 방향키로 이동하는 컨트롤 묶음이 필요하다면 [ButtonGroup](../inputs/button-group)을 쓰세요.

:::

::: fw flutter

- focus 순서에도 semantics 트리에도 아무것도 더하지 않습니다. 바 위의 컨트롤은 각자 focus 정지이고 각자 읽힙니다. 바 전체가 방향키로 움직이는 정지 하나라고 주장하지 않으며, 그렇게 구현하지도 않았습니다.
- Flutter에는 header landmark가 없으므로 `render={<header />}`에 해당하는 것이 없습니다.
- 방향키로 이동하는 토글 묶음이 필요하다면 focus 정지 하나인 [ToggleGroup](../inputs/toggle-group)을 쓰세요.

:::

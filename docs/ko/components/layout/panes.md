---
title: Panes
order: 7
flutter: true
---

# Panes

<p class="neba-lede">하나의 박스를 여러 영역으로 나누고 그 사이마다 끌 수 있는 바를 둡니다. 파일 목록 옆의 편집기, 폼 옆의 미리보기처럼 비율을 읽는 사람이 정하는 분할에 씁니다.</p>

<Demo src="panes/hero" />

::: fw react

```tsx
import { Pane, Panes } from 'neba';

<Panes>
  <Pane defaultSize="240px" minSize="160px">
    Files
  </Pane>
  <Pane>Editor</Pane>
</Panes>;
```

`Panes`는 자신이 놓인 박스를 채우므로, 그 박스에 높이를 주어야 합니다.

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaPanes(
  children: <NebaPane>[
    NebaPane(
      defaultSize: const NebaPaneSize.pixels(240),
      minSize: const NebaPaneSize.pixels(160),
      child: files,
    ),
    NebaPane(child: editor),
  ],
);
```

`NebaPanes`는 주어진 공간을 채우므로, 너비와 높이가 모두 정해진 곳에 두어야 합니다. 높이를 준 `SizedBox`나 `Expanded`, 다른 분할의 pane 안에 넣으세요.

:::

## Props

### Panes

<PropsTable name="Panes" />

::: fw react

나머지 `<div>` 속성은 그대로 전달됩니다. 직접 자식은 `Pane`이어야 합니다. 크기 제약을 그 props에서 읽기 때문입니다. 공용 축은 [prop 규약](../../design/prop-conventions)에 있습니다.

:::

::: fw flutter

`children`은 `List<NebaPane>`이므로, 직접 자식이 언제나 pane이라는 것을 타입이 보장합니다. 모든 바의 이름은 `handleLabel`로, 바마다 다른 이름은 `handleLabelBuilder`로 줍니다. React에서는 문자열이나 함수를 받는 prop 하나가 둘을 겸합니다. `className`과 `style`은 없습니다. 공용 축은 [prop 규약](../../design/prop-conventions)에 있습니다.

:::

### Pane

<PropsTable name="Pane" />

::: fw react

나머지 `<div>` 속성은 그대로 전달됩니다.

:::

::: fw flutter

pane은 `child`를 자기 크기로 배치하고 넘치는 부분을 잘라 냅니다. React의 pane은 이때 스크롤됩니다. pane보다 길어질 수 있는 내용은 [ScrollArea](./scroll-area)에 넣으세요.

:::

## 예시

### orientation

`horizontal`은 pane들을 좌우로 늘어놓고 그 사이에 세로 바를, `vertical`은 위아래로 쌓고 가로 바를 둡니다. 바는 언제나 pane들이 놓인 축을 가로지릅니다.

<Demo src="panes/orientation">

::: fw react

<<< @/.vitepress/demos/panes/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/panes/orientation.dart

:::

</Demo>

### defaultSize · minSize · maxSize

::: fw react

셋 다 숫자(퍼센트로 읽습니다)나 CSS 길이(`'240px'`, `'15rem'`, `'20%'`)를 받습니다. `defaultSize`가 없는 pane들은 남은 자리를 똑같이 나눠 갖습니다. 어떤 pane의 `minSize`는 이웃 pane의 최대치이기도 하므로, 끌기는 먼저 닿는 한계에서 멈춥니다. 기본 크기는 첫 렌더에 바로 쓰이므로, 서버에서 렌더한 분할도 스크립트가 실행되기 전부터 그 크기로 그려집니다.

:::

::: fw flutter

셋 다 `NebaPaneSize`를 받습니다. 퍼센트는 `NebaPaneSize.percent(20)`, 논리 픽셀 길이는 `NebaPaneSize.pixels(240)`입니다. `defaultSize`가 없는 pane들은 남은 자리를 똑같이 나눠 갖습니다. 어떤 pane의 `minSize`는 이웃 pane의 최대치이기도 하므로, 끌기는 먼저 닿는 한계에서 멈춥니다. 길이는 분할이 처음 배치될 때 비율로 바뀌므로, 첫 프레임부터 기본 크기로 그려집니다.

:::

`onResize`는 바가 움직이는 동안 모든 pane의 비율(%)을 알려주고, `onResizeEnd`는 바를 놓았을 때 한 번 호출됩니다.

<Demo src="panes/sizing">

::: fw react

<<< @/.vitepress/demos/panes/sizing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/panes/sizing.dart

:::

</Demo>

### 중첩

<Fw react="Pane" flutter="NebaPane" code /> 안의 <Fw react="Panes" flutter="NebaPanes" code />는 분할 안의 분할이며, 세 영역짜리 레이아웃은 이렇게 만듭니다. 안쪽에는 반대 `orientation`을 주세요.

::: fw react

```tsx
<Panes>
  <Pane defaultSize="240px">Files</Pane>
  <Pane>
    <Panes orientation="vertical">
      <Pane defaultSize={70}>Editor</Pane>
      <Pane>Terminal</Pane>
    </Panes>
  </Pane>
</Panes>
```

:::

::: fw flutter

```dart
NebaPanes(
  children: <NebaPane>[
    NebaPane(defaultSize: const NebaPaneSize.pixels(240), child: files),
    NebaPane(
      child: NebaPanes(
        orientation: NebaOrientation.vertical,
        children: <NebaPane>[
          NebaPane(defaultSize: const NebaPaneSize.percent(70), child: editor),
          NebaPane(child: terminal),
        ],
      ),
    ),
  ],
);
```

:::

### resizable

<Fw react="resizable={false}" flutter="resizable: false" code />는 바를 pane 사이의 선으로만 남깁니다. 그려지기는 하지만 끌 수 없고 tab 순서에서도 빠집니다.

<Demo src="panes/fixed">

::: fw react

<<< @/.vitepress/demos/panes/fixed.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/panes/fixed.dart

:::

</Demo>

## 접근성

::: fw react

- 각 바는 `separator`이며, 앞에 있는 pane의 비율(%)을 `aria-valuenow`로 실어 나릅니다. 이름은 `locale`의 "패널 크기 조절"이거나 `handleLabel`이고, `aria-controls`가 양쪽의 두 pane을 가리킵니다.

:::

::: fw flutter

- 화면 낭독기에서 각 바는 slider이며, 값은 앞에 있는 pane의 비율(%)입니다. 값을 올리거나 내리면 화살표 키를 한 번 누른 만큼 바가 움직입니다. 이름은 `locale`의 "패널 크기 조절"이거나 `handleLabel` 또는 `handleLabelBuilder`가 정한 것입니다.
- 바를 누르거나 끌어도 focus는 원래 있던 곳에 남습니다. pane 안의 입력 필드가 focus를 잃지 않습니다.

:::

- 바는 focus를 받습니다. 세로 바는 ArrowLeft·ArrowRight로 화살표가 가리키는 쪽으로 움직이고 RTL에서도 같습니다. 가로 바는 ArrowUp·ArrowDown으로 움직입니다.

::: fw react

- `aria-orientation`은 pane이 아니라 바를 설명합니다. 좌우로 놓인 pane 사이의 세로 바는 `vertical`입니다.

:::

- RTL에서도 끌기는 포인터가 간 방향으로 경계를 옮깁니다.

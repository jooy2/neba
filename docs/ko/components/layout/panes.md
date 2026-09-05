---
title: Panes
order: 7
---

# Panes

<p class="neba-lede">하나의 박스를 여러 영역으로 나누고 그 사이마다 끌 수 있는 바를 둡니다. 파일 목록 옆의 편집기, 폼 옆의 미리보기처럼 비율을 읽는 사람이 정하는 분할에 씁니다.</p>

<Demo src="panes/hero" />

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

## Props

### Panes

<PropsTable name="Panes" />

나머지 `<div>` 속성은 그대로 전달됩니다. 직접 자식은 `Pane`이어야 합니다. 크기 제약을 그 props에서 읽기 때문입니다. 공용 축은 [prop 규약](../../design/prop-conventions)에 있습니다.

### Pane

<PropsTable name="Pane" />

나머지 `<div>` 속성은 그대로 전달됩니다.

## 예시

### orientation

`horizontal`은 pane들을 좌우로 늘어놓고 그 사이에 세로 바를, `vertical`은 위아래로 쌓고 가로 바를 둡니다. 바는 언제나 pane들이 놓인 축을 가로지릅니다.

<Demo src="panes/orientation">

<<< @/.vitepress/demos/panes/orientation.tsx

</Demo>

### defaultSize · minSize · maxSize

셋 다 숫자(퍼센트로 읽습니다)나 CSS 길이(`'240px'`, `'15rem'`, `'20%'`)를 받습니다. `defaultSize`가 없는 pane들은 남은 자리를 똑같이 나눠 갖습니다. 어떤 pane의 `minSize`는 이웃 pane의 최대치이기도 하므로, 끌기는 먼저 닿는 한계에서 멈춥니다.

`onResize`는 바가 움직이는 동안 모든 pane의 비율(%)을 알려주고, `onResizeEnd`는 바를 놓았을 때 한 번 호출됩니다.

<Demo src="panes/sizing">

<<< @/.vitepress/demos/panes/sizing.tsx

</Demo>

### 중첩

`Pane` 안의 `Panes`는 분할 안의 분할이며, 세 영역짜리 레이아웃은 이렇게 만듭니다. 안쪽에는 반대 `orientation`을 주세요.

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

### resizable

`resizable={false}`는 바를 pane 사이의 선으로만 남깁니다. 그려지기는 하지만 끌 수 없고 tab 순서에서도 빠집니다.

<Demo src="panes/fixed">

<<< @/.vitepress/demos/panes/fixed.tsx

</Demo>

## 접근성

- 각 바는 `separator`이며, 앞에 있는 pane의 비율(%)을 `aria-valuenow`로 실어 나릅니다.
- 바는 focus를 받습니다. 세로 바는 ArrowLeft·ArrowRight로, 가로 바는 ArrowUp·ArrowDown으로 움직입니다.
- `aria-orientation`은 pane이 아니라 바를 설명합니다. 좌우로 놓인 pane 사이의 세로 바는 `vertical`입니다.
- RTL에서도 끌기는 포인터가 간 방향으로 경계를 옮깁니다.

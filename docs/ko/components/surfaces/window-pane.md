---
title: WindowPane
order: 14
---

# WindowPane

<p class="neba-lede">무엇이든 담아, 네 가지 운영체제 중 하나가 창을 그리는 방식으로 보여 줍니다. 제목표시줄은 끌리고 모서리는 크기가 바뀌며 버튼 세 개는 진짜 버튼이므로, 스크린샷이나 데모, 랜딩 페이지의 한 조각을 그림이 아니라 그것이 될 물건으로 보여 줄 수 있습니다.</p>

<Demo src="window-pane/hero" minHeight="340" />

```tsx
import { WindowPane } from 'neba';

<WindowPane os="macos" title="Notes" width={520} height={320}>
  <Editor />
</WindowPane>;
```

진짜 창은 아닙니다. 바탕화면도, z 순서도, 페이지 바깥도 없습니다. 그리는 것은 창틀이고, 담기는 것은 여러분의 것입니다.

## Props

<PropsTable name="WindowPane" />

`title`과 `onResize`를 빼면 나머지 `<div>` 속성은 그대로 루트에 전달됩니다 — 여기서 `title`은 창의 이름이자 `ReactNode`이고, `onResize`는 DOM 이벤트가 아니라 픽셀 크기를 알려줍니다. 공용 축(`size` `color` `elevation` `position`)은 [prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### os

`macos`는 왼쪽에 색 있는 점 세 개를 두고 제목을 창 전체의 가운데에 놓습니다. `windows11`은 오른쪽에 사각 버튼 세 개를 두고 모서리를 둥글게 깎습니다. `windows10`은 같은 세 개를 각진 모서리와 더 낮은 표시줄, 그 아래 한 줄과 함께 그립니다. `linux`는 GNOME 헤더바입니다 — 더 높고, 버튼이 원형이며, 제목이 가운데에 있습니다.

버튼에는 다른 회사의 마크가 없습니다. 최소화는 선, 최대화는 상자, 닫기는 ×이고, 크롬은 여러분이 준 제목 말고는 아무 글자도 쓰지 않습니다.

<Demo src="window-pane/os" minHeight="420">

<<< @/.vitepress/demos/window-pane/os.tsx

</Demo>

### controls

`true`는 버튼 셋 전부, `false`는 없음이며, 배열은 그 안에 이름을 적은 것만입니다. 순서는 배열이 아니라 시스템이 정하므로 `['close', 'minimize']`라 적어도 Windows에서는 닫기가 마지막에 옵니다.

셋 다 제어/비제어 짝을 가집니다. `open`, `minimized`, `maximized`에 각각 `default*`와 `on*Change`가 있습니다. 비제어 창을 닫으면 아무것도 렌더링하지 않습니다. 최소화는 제목표시줄만 남기고 말아 올립니다 — 페이지에는 창을 보낼 독이 없기 때문입니다. 최대화는 창을 담고 있는 것을 채우며, 그것은 `position="absolute"`에서는 가장 가까운 positioned 조상이고 `fixed`에서는 뷰포트입니다. 제목표시줄을 더블클릭해도 최대화됩니다.

<Demo src="window-pane/controls" minHeight="400">

<<< @/.vitepress/demos/window-pane/controls.tsx

</Demo>

### draggable과 resizable

`draggable`은 창을 `left`와 `top`으로 옮기며 — transform이 아니므로 끄는 동안 글자가 다시 샘플링되지 않습니다 — 어디로 갔는지를 `onOffsetChange`로 알려줍니다. `resizable`은 네 가장자리와 네 모서리 전부에 핸들을 답니다. `minWidth`와 `minHeight`가 한계를 정하고, 움직이는 동안 `onResize`가 픽셀 크기와 함께 호출됩니다.

둘 다 움직일 자리가 있어야 합니다. 창에 `position="absolute"`와 positioned 조상을 주거나 `position="fixed"`를 주세요.

<Demo src="window-pane/interactive" minHeight="400">

<<< @/.vitepress/demos/window-pane/interactive.tsx

</Demo>

### accent · transparency · active

`accent`는 Windows가 제공하는 것처럼 제목표시줄에 `color`를 입힙니다. `transparency`는 크롬 너머로 페이지가 얼마나 비치는지를 `0`에서 `1` 사이로 정합니다. 제목표시줄과 본문의 바탕, 테두리에만 적용되고 그 위의 내용에는 적용되지 않으며, `0`보다 크면 아크릴이 함께 켜져 뒤가 그냥 보이는 대신 흐려집니다. `active={false}`는 앞에 있지 않은 창입니다 — 모양은 지키고 강조만 잃으며, 투명해지지는 않습니다.

<Demo src="window-pane/appearance" minHeight="420">

<<< @/.vitepress/demos/window-pane/appearance.tsx

</Demo>

## 접근성

- 루트는 자기 제목이 이름인 `role="group"`이므로, 스크린 리더는 내용보다 먼저 창의 이름을 읽습니다.
- 제목표시줄의 버튼 셋은 `locale`에서 이름을 받는 진짜 `<button>`이며, 최대화 버튼은 창이 최대화된 동안 스스로 "이전 크기로 복원"으로 이름을 바꿉니다.
- 리사이즈 핸들 중 하나 — 오른쪽 아래 모서리 — 는 키보드로 닿을 수 있고 방향키로 크기를 바꿉니다. 나머지 일곱은 포인터를 위한 것이라 접근성 트리에서 숨겨져 있으며, 키보드 사용자는 `maximize`로 같은 범위를 얻습니다.
- 끌기도 포인터를 위한 것입니다. 포인터 없이도 옮겨야 하는 창이라면 `offset`을 직접 넘기세요.

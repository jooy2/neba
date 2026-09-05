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

여덟 가지이며, 제목표시줄이 달라진 버전마다 별도 항목입니다.

| `os`        | 그리는 것                                                                          |
| ----------- | ---------------------------------------------------------------------------------- |
| `macos`     | 왼쪽에 색 있는 점 세 개, 창 전체의 가운데에 놓인 제목, 이음매 없는 한 장의 시트    |
| `macosx`    | Aqua — 낮고 줄무늬가 있는 바, 광택 있는 신호등, 굵고 양각된 제목, 각진 아래 모서리 |
| `windows11` | 둥근 오른쪽 위 모서리에 딱 붙은 사각 버튼 셋, 바와 본문이 같은 Mica 한 장          |
| `windows10` | 같은 셋에 각진 모서리, 더 낮은 표시줄, 그리고 그 아래 한 줄                        |
| `windows8`  | 납작하고 각지며 줄은 없고, 창 전체를 두르는 색 띠                                  |
| `windows7`  | Aero — 뒤를 흐리는 유리, 빛나는 제목, 더 넓은 닫기 버튼                            |
| `windowsxp` | Luna — 파란 그러데이션 바, 같은 파란색으로 두른 테두리, 색이 든 버튼 플레이트      |
| `linux`     | GNOME 헤더바 — 더 높고, 버튼이 원형이며, 제목이 가운데에                           |

옛 시스템들은 페이지의 색이 아니라 자기 크롬을 칠합니다. 그래서 다크로 전환한 페이지에서도 Luna는 파랗고 Aqua는 회색입니다 — [Mockup](./mockup)의 마감재가 하는 선택과 같습니다. 하드웨어와 시스템 크롬은 테마가 아니기 때문입니다.

XP와 Aero는 헤어라인이 아니라 **띠**를 가진 둘이기도 합니다. 내용이 양옆과 아래를 두르는 시스템 자신의 재질 속에 가라앉아 있는데, 두 창을 알아보게 하는 것의 대부분이 그 띠입니다. `accent`는 제목표시줄과 함께 띠까지 물들이므로, 직접 고른 색의 창은 그 색으로 둘러집니다.

버튼에는 다른 회사의 마크가 없습니다. 최소화는 선, 최대화는 상자, 닫기는 ×이고, 크롬은 여러분이 준 제목 말고는 아무 글자도 쓰지 않습니다.

<Demo src="window-pane/os" minHeight="760">

<<< @/.vitepress/demos/window-pane/os.tsx

</Demo>

### controls

`true`는 버튼 셋 전부, `false`는 없음이며, 배열은 그 안에 이름을 적은 것만입니다. 순서는 배열이 아니라 시스템이 정하므로 `['close', 'minimize']`라 적어도 Windows에서는 닫기가 마지막에 옵니다.

셋 다 제어/비제어 짝을 가집니다. `open`, `minimized`, `maximized`에 각각 `default*`와 `on*Change`가 있습니다. 비제어 창을 닫으면 아무것도 렌더링하지 않습니다. 최소화는 제목표시줄만 남기고 말아 올립니다. 웹 페이지에는 창을 내려놓을 작업 표시줄이 없기 때문입니다. 최대화는 창을 담고 있는 것을 채우며, 그것은 `position="absolute"`에서는 가장 가까운 positioned 조상이고 `fixed`에서는 뷰포트입니다. 제목표시줄을 더블클릭해도 최대화됩니다.

<Demo src="window-pane/controls" minHeight="400">

<<< @/.vitepress/demos/window-pane/controls.tsx

</Demo>

### draggable과 resizable

`draggable`은 창을 `left`와 `top`으로 옮기며 — transform이 아니므로 끄는 동안 글자가 다시 샘플링되지 않습니다 — 어디로 갔는지를 `onOffsetChange`로 알려줍니다. `resizable`은 네 가장자리와 네 모서리 전부에 핸들을 답니다. `minWidth`와 `minHeight`가 한계를 정하고, 움직이는 동안 `onResize`가 픽셀 크기와 함께 호출됩니다.

둘 다 움직일 자리가 있어야 합니다. 창에 `position="absolute"`와 positioned 조상을 주거나 `position="fixed"`를 주세요.

<Demo src="window-pane/interactive" minHeight="400">

<<< @/.vitepress/demos/window-pane/interactive.tsx

</Demo>

### 어느 창이 앞에 있는지

`active`를 넘기지 않으면 스스로 알아서 합니다. 페이지의 다른 WindowPane이 눌리거나 포커스를 가져갈 때까지 그 창이 앞에 있습니다. 창들 *주변*의 페이지를 누르는 것은 아무것도 바꾸지 않습니다 — 문단은 바탕화면이 아닙니다.

앞에 있다는 것은 각 시스템이 그리는 방식대로 그려집니다. macOS에서는 회색이 아닌 색 있는 신호등, Windows 10에서는 강조색 제목표시줄과 강조색 테두리, GNOME에서는 색이 든 헤더바이고, 넷 모두에서 뒤에 있는 창보다 그림자가 한 단계 깊습니다. 직접 정하고 싶다면 `active`를 넘기세요. z 순서를 스스로 관리하는 쪽이 원하는 값입니다.

### 움직임

최대화, 복원, 말아 올리기는 두 기하 사이의 이동이므로 창은 뛰지 않고 지나갑니다. 움직이는 것은 `left`, `top`, `width`, `height`이며 transform은 결코 아닙니다 — 그래서 오는 동안 창 안의 어떤 글자도 다시 샘플링되지 않습니다. `height`를 받은 적 없는 창은 말아 올리는 동안 높이를 재어 고정해 둡니다. `auto`는 트랜지션이 출발할 수 있는 길이가 아니기 때문입니다.

말아 올린 창은 본문을 트리에 남겨 둡니다. `inert` 상태로 잘려 있으며, 그것이 바로 말아 올림이 지나가는 대상입니다. 닫힌 창은 그냥 사라지는 대신 사라지기 전에 서서히 흐려집니다. 움직임을 줄여 달라고 한 사용자에게는 이 모두가 즉시 일어납니다.

### accent · transparency · active

`accent`는 Windows가 제공하는 것처럼 제목표시줄에 `color`를 입히며, `windows10`에서는 창의 테두리까지 함께 물듭니다 — 그 버전이 실제로 하는 일입니다. `transparency`는 크롬 너머로 페이지가 얼마나 비치는지를 `0`에서 `1` 사이로 정합니다. 제목표시줄과 본문의 바탕, 테두리에만 적용되고 그 위의 내용에는 적용되지 않으며, `0`보다 크면 아크릴이 함께 켜져 뒤가 그냥 보이는 대신 흐려집니다. `active={false}`는 그 창을 다른 무엇보다 뒤에 고정해 둡니다.

<Demo src="window-pane/appearance" minHeight="420">

<<< @/.vitepress/demos/window-pane/appearance.tsx

</Demo>

## 접근성

- 루트는 자기 제목이 이름인 `role="group"`이므로, 스크린 리더는 내용보다 먼저 창의 이름을 읽습니다.
- 제목표시줄의 버튼 셋은 `locale`에서 이름을 받는 진짜 `<button>`이며, 최대화 버튼은 창이 최대화된 동안 스스로 "이전 크기로 복원"으로 이름을 바꿉니다.
- 리사이즈 핸들 중 하나 — 오른쪽 아래 모서리 — 는 키보드로 닿을 수 있고 방향키로 크기를 바꿉니다. 나머지 일곱은 포인터를 위한 것이라 접근성 트리에서 숨겨져 있으며, 키보드 사용자는 `maximize`로 같은 범위를 얻습니다.
- 끌기도 포인터를 위한 것입니다. 포인터 없이도 옮겨야 하는 창이라면 `offset`을 직접 넘기세요.

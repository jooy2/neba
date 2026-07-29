---
title: Toolbar
order: 7
---

# Toolbar

<p class="neba-lede">컨트롤을 한 줄로 배치하는 바입니다. 애플리케이션 헤더, 페이지의 액션 줄, 편집기 아래의 상태 띠에 씁니다.</p>

<Demo src="toolbar/hero" />

```tsx
import { Toolbar } from 'neba';

<Toolbar render={<header />} start={<Logo />} end={<Button>배포</Button>}>
  워크스페이스
</Toolbar>;
```

## Props

<PropsTable name="Toolbar" />

`<div>`의 native 속성은 그대로 전달됩니다.

자리는 셋입니다. `start`와 `end`가 각자의 끝에 고정되고 `children`이 남은 폭을 가져가므로, 간격을 벌리기 위한 spacer를 따로 넣을 필요가 없습니다.

## 예시

### size와 density

Toolbar에는 고정 높이가 없습니다. 안에 든 컨트롤 높이에 여백을 더한 만큼 높아지고, 그 여백을 `size`와 `density`가 정합니다. `density="compact"`는 타입 스케일을 건드리지 않고 여백만 줄입니다.

<Demo src="toolbar/density">

<<< @/.vitepress/demos/toolbar/density.tsx

</Demo>

### position과 side

`position`은 CSS의 세 값을 그대로 씁니다.

- `sticky` — 애플리케이션 헤더에 적합합니다. 자기 자리를 차지하므로 아래 콘텐츠에 여백을 줄 필요가 없습니다.
- `fixed` — 흐름에서 빠지므로, 페이지가 스스로 여백을 마련하지 않으면 첫 화면이 바 뒤에 깔립니다.

`side`는 바가 붙을 가장자리입니다. 고정된 바는 모서리 반경을 버립니다 — 화면 가장자리의 둥근 모서리는 뒤에 아무것도 없는 틈이 됩니다.

<Demo src="toolbar/sticky">

<<< @/.vitepress/demos/toolbar/sticky.tsx

</Demo>

### divider와 elevation

`divider`는 바 아래에 선을 그어 아래에 콘텐츠가 있음을 보여 줍니다. 고정된 바에서도 `elevation`은 `0`으로 남으므로, 스크롤에 맞춰 직접 올리거나 `divider`를 켜세요.

### color

`color`는 선과 focus ring에 적용됩니다. 남의 컨트롤을 담는 바이므로 sheet 자체는 색으로 채우지 않습니다.

## 접근성

- `role="toolbar"`를 붙이지 않습니다. 그 role은 바 전체가 tab 정지 하나이고 내부를 방향키로 이동한다는 약속이므로, 구현하지 않은 채 주장하면 키보드 사용자에게 오히려 방해가 됩니다.
- 페이지 헤더로 쓸 때는 `render={<header />}`를 주세요. 실제 landmark가 되어 screen reader 사용자가 이동 기준으로 쓸 수 있습니다.
- 방향키로 이동하는 컨트롤 묶음이 필요하다면 [ButtonGroup](../inputs/button-group)을 쓰세요.

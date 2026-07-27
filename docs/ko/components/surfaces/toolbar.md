---
title: Toolbar
order: 7
---

# Toolbar

<p class="neba-lede">컨트롤이 늘어선 바: 애플리케이션 헤더, 페이지의 액션 줄, 편집기 아래를 가로지르는 띠.</p>

<Demo src="toolbar/hero" />

```tsx
import { Toolbar } from 'neba';

<Toolbar render={<header />} start={<Logo />} end={<Button>배포</Button>}>
  워크스페이스
</Toolbar>;
```

자리 셋과 한 줄. `start`와 `end`는 각자의 끝에 고정되고 `children`이 남은 폭을 가져갑니다. 지금까지의 모든 툴바가 가졌던 배치이므로, 쓰는 쪽과 그 사람이 잊지 않고 넣어야 할 스페이서 `<div>`에 맡기지 않고 여기서 배치합니다.

## Props

<PropsTable name="Toolbar" />

`<div>`의 네이티브 속성은 그대로 전달됩니다.

## 예시

### 밀도

Toolbar에는 자기 높이가 없습니다. 안에 든 컨트롤 높이에 여백을 더한 만큼 높고, 그 여백은 다른 모든 표면이 쓰는 `size` / `density` 짝입니다 — 그래서 같은 뜻의 두 번째 prop 없이도, 타입 스케일을 건드리지 않고도 `density="compact"`가 빽빽한 바를 줍니다.

<Demo src="toolbar/density">

<<< @/.vitepress/demos/toolbar/density.tsx

</Demo>

### 고정

`position`은 CSS 자신의 세 값이고, CSS가 쓰는 그대로 씁니다.

- `sticky`는 애플리케이션 헤더가 대개 원하는 것입니다. 자기 자리를 차지하므로 아래에 있는 것에 여백을 줄 필요가 없습니다.
- `fixed`는 흐름에서 완전히 빠지므로, 페이지가 스스로 여백을 마련하지 않으면 첫 화면이 바 뒤에 깔립니다.

고정된 바는 반지름을 버립니다. 화면 가장자리에 맞닿은 둥근 모서리는 뒤에 아무것도 없는 틈이기 때문입니다. `divider`는 아래에 내용이 있다고 말해 주는 헤어라인을 그립니다.

<Demo src="toolbar/sticky">

<<< @/.vitepress/demos/toolbar/sticky.tsx

</Demo>

고정된 바에서도 `elevation`은 `0`으로 남습니다. 헤더 밑의 그림자는 "이 아래에 내용이 있다"고 말하는 방법이고, 그것은 페이지를 스크롤한 뒤에야 참입니다 — 그러니 스크롤에 맞춰 직접 올리거나, 납작하게 두고 `divider`를 켜세요.

## `role="toolbar"`가 없는 이유

그 role은 키보드 동작에 대한 약속입니다. 바 전체가 탭 정지 하나이고, 안의 컨트롤 사이는 화살표 키로 오간다는 약속. 그것을 구현하지 않은 채 주장하는 바는 아무것도 주장하지 않은 바보다 키보드 독자에게 나쁩니다.

페이지 헤더가 원하는 것은 `render={<header />}` — 진짜 랜드마크이고, 스크린 리더 사용자가 실제로 그것을 기준으로 이동합니다. 진짜 로빙 포커스 툴바가 원하는 것은 [ButtonGroup](../inputs/button-group)이고, 그것이 바로 그것입니다.

## Material UI에서 옮겨올 때

| MUI | Neba |
| --- | --- |
| `<AppBar><Toolbar>…</Toolbar></AppBar>` | 컴포넌트 하나입니다. `position`이 그 위에 바로 있습니다 |
| `position="sticky"` | 같습니다. `'static'`, `'sticky'`, `'fixed'` |
| `variant="dense"` | `density="compact"` — 여백이고, `density`가 바꿔도 되는 것은 그것뿐입니다 |
| `color="primary"` | `color`는 헤어라인과 포커스 링에 닿습니다. 남의 컨트롤을 담는 바는 자기 시트에 색을 들이지 않습니다 |
| `elevation={4}` | `elevation`은 `0`–`3`이고, `0`은 그림자 없음입니다 |
| 스페이서로 쓰는 <code v-pre>&lt;Box sx={{ flexGrow: 1 }} /&gt;</code> | 필요 없습니다. `start`, `children`, `end`가 세 자리입니다 |

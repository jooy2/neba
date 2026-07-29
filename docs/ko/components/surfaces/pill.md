---
title: Pill
order: 6
---

# Pill

<p class="neba-lede">진행 중인 상태를 화면 위에 띠워 두는 알약 모양 표면입니다. 녹음 타이머나 아직 돌고 있는 빌드처럼 계속 갱신되는 정보에 씁니다.</p>

<Demo src="pill/hero" />

```tsx
import { Pill } from 'neba';

<Pill startIcon={<DotIcon />} color="danger">
  녹음 중
</Pill>;
```

## Props

<PropsTable name="Pill" />

`<div>`의 native 속성은 그대로 전달됩니다. 자리는 셋입니다 — `startIcon`, `children`, `endIcon`.

`color`의 기본값은 `secondary`이고 `elevation`의 기본값은 `2`입니다. 화면 위에 떠 있는 것이 전제이므로 그림자가 기본으로 붙습니다.

## 예시

### details와 expanded

`details`를 주면 알약 아래로 두 번째 영역이 자랍니다. `expanded`로 controlled, `onClick`으로 토글 동작을 붙일 수 있습니다. 펼침은 [Accordion](./accordion)의 패널과 같은 방식으로 높이를 애니메이션합니다.

<Demo src="pill/expandable">

<<< @/.vitepress/demos/pill/expandable.tsx

</Demo>

접혀 있는 동안 상세 영역은 `inert`입니다. 높이가 0인 요소에도 focus는 들어갈 수 있으므로, `aria-hidden`만으로는 키보드 사용자가 보이지 않는 영역으로 tab해 들어가게 됩니다.

### variant와 size

색에 관해서 Pill은 컨테이너가 아니라 컨트롤입니다 — [Button](../inputs/button)이나 [Chip](../display/chip)처럼 표면 자체가 색을 갖습니다.

<Demo src="pill/variants">

<<< @/.vitepress/demos/pill/variants.tsx

</Demo>

### position과 side

[Toolbar](./toolbar)와 같은 어휘를 씁니다. `fixed`는 viewport에 고정하고 가로로 가운데 정렬합니다. auto margin으로 정렬하므로 RTL에서도 가운데에 놓입니다.

```tsx
<Pill position="fixed" side="top" startIcon={<BuildIcon />} color="info">
  빌드 중 — 7개 중 2개
</Pill>
```

## 이럴 때는 다른 컴포넌트를

- 콘텐츠 흐름 안의 토큰(태그, 필터, 상태)이라면 [Chip](../display/chip)을 쓰세요.
- 페이지 상단을 가로지르는 컨트롤 줄이라면 [Toolbar](./toolbar)를 쓰세요.
- 사용자가 기다려야 하고 치울 수 없다면 [Overlay](../feedback/overlay), 치울 수 있다면 [Toast](../feedback/toast)를 쓰세요.

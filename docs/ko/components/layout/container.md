---
title: Container
order: 1
---

# Container

<p class="neba-lede">감싼 것에 좌우 여백을 두는 컴포넌트. 그리드와는 아무 상관이 없습니다 — 페이지의 내용이 창 가장자리에 닿지 않게 하는 일 하나만 합니다.</p>

<Demo src="container/hero" />

```tsx
import { Container } from 'neba';

<Container>내용</Container>;
```

[Grid](./grid)와 나란히 쓰이는 일이 많지만 둘은 별개입니다. Container는 그리드를 담는 만큼이나 문단 하나도 잘 담고, [GridContainer](./grid)는 Container 없이도 완전합니다. 나뉘는 질문이 서로 다르기 때문입니다 — 내용이 창 가장자리에서 얼마나 떨어져 있는지, 그리고 내용이 스스로를 어떻게 나누는지.

표면을 그리지 않는 것도 같은 이유입니다. 페이지의 가장 바깥 요소야말로 페이지의 생김새를 정하면 안 되는 하나입니다. 시트가 필요하면 [Box](../surfaces/box)나 [Card](../surfaces/card)를 안에 넣으세요.

## Props

<PropsTable name="Container" />

`<div>`의 네이티브 속성은 그대로 전달됩니다.

## 예시

### 최대 너비

기본값은 `none` — 제한 없이 여백만 둡니다. Container의 일은 거터이고, 본문 폭(measure)은 페이지가 따로 요청해야 하는 두 번째 결정이기 때문입니다.

값을 주면 [브레이크포인트와 같은 사다리](./grid#브레이크포인트)를 씁니다. `lg`는 64rem이고, `lg:` 유틸리티가 바뀌는 폭과 같은 숫자입니다. Tailwind의 `max-w-*` 이름 사다리를 쓰지 않은 이유가 이것입니다 — 한 페이지에 `lg`라는 이름의 사다리가 둘이면 레이아웃이 아무도 찾을 수 없는 몇 픽셀만큼 어긋납니다.

<Demo src="container/max-width">

<<< @/.vitepress/demos/container/max-width.tsx

</Demo>

### 여백 없이, 가운데 없이, 다른 요소로

세 스위치는 서로 독립적입니다. `padded={false}`는 가운데 정렬과 최대 너비를 그대로 두고 여백만 끄고, `centered={false}`는 그 반대입니다. `render`는 Base UI의 render prop 그대로라서, 페이지의 진짜 `<main>`이 될 수 있습니다.

<Demo src="container/plain">

<<< @/.vitepress/demos/container/plain.tsx

</Demo>

### 그리드와 함께

가장 흔한 조합입니다. 바깥은 여백과 본문 폭, 안쪽은 칸 나누기 — 그리고 안쪽 그리드는 이미 여백을 가진 것 안에 있으므로 `padded={false}`입니다.

```tsx
<Container maxWidth="lg">
  <GridContainer spacing={3} padded={false}>
    <Grid span={{ xs: 12, md: 8 }}>본문</Grid>
    <Grid span={{ xs: 12, md: 4 }}>사이드바</Grid>
  </GridContainer>
</Container>
```

## Material UI에서 옮겨올 때

| MUI | Neba |
| --- | --- |
| `maxWidth="lg"` | 같습니다. 다만 기본값이 `'lg'`가 아니라 `'none'`입니다 |
| `disableGutters` | `padded={false}` — 라이브러리 전체가 쓰는 이름입니다 |
| `fixed` | 없습니다. `maxWidth`를 쓰세요 |
| <code v-pre>sx={{ px: 3 }}</code> | `size`/`density`. 여백은 사다리 위의 값이지 임의의 숫자가 아닙니다 |

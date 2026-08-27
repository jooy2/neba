---
title: Container
order: 5
---

# Container

<p class="neba-lede">페이지 내용에 좌우 여백을 두고 가운데로 정렬합니다. 내용이 창 가장자리에 닿지 않게 하는 것이 이 컴포넌트의 유일한 역할입니다.</p>

<Demo src="container/hero" />

```tsx
import { Container } from 'neba';

<Container>내용</Container>;
```

## Props

<PropsTable name="Container" />

`<div>`의 native 속성은 그대로 전달됩니다.

표면을 그리지 않으므로 `variant`나 `color`, `elevation`이 없습니다. sheet가 필요하면 안에 [Box](../surfaces/box)나 [Card](../surfaces/card)를 넣으세요.

[Grid](./grid)와 함께 쓰는 일이 많지만 둘은 별개입니다. Container는 내용이 창 가장자리에서 얼마나 떨어지는지를, [GridContainer](./grid)는 내용이 스스로를 어떻게 나누는지를 정합니다.

## 예시

### maxWidth

기본값은 `none`으로, 너비 제한 없이 좌우 여백만 둡니다.

값을 주면 [Grid의 breakpoint](./grid#breakpoint)와 같은 단계를 씁니다. `lg`는 64rem이며 Tailwind의 `lg:` 유틸리티가 적용되는 폭과 같은 값입니다.

<Demo src="container/max-width">

<<< @/.vitepress/demos/container/max-width.tsx

</Demo>

### padded · centered · render

세 prop은 서로 독립적입니다. `padded={false}`는 가운데 정렬과 너비 제한을 유지한 채 여백만 끄고, `centered={false}`는 그 반대입니다. `render`로 감싸는 요소를 바꿀 수 있으므로 페이지의 `<main>`으로 렌더링할 수 있습니다.

<Demo src="container/plain">

<<< @/.vitepress/demos/container/plain.tsx

</Demo>

### size와 density

여백의 크기를 정합니다. [Box](../surfaces/box)와 같은 단계이며 높이나 타입 스케일에는 영향을 주지 않습니다.

### Grid와 함께 쓰기

바깥은 여백과 최대 너비, 안쪽은 칸 나누기를 담당합니다. 안쪽 Grid는 이미 여백이 있는 요소 안에 들어가므로 `padded={false}`로 둡니다.

```tsx
<Container maxWidth="lg">
  <GridContainer spacing={3} padded={false}>
    <Grid span={{ xs: 12, md: 8 }}>본문</Grid>
    <Grid span={{ xs: 12, md: 4 }}>사이드바</Grid>
  </GridContainer>
</Container>
```

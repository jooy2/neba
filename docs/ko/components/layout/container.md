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

값을 주면 measure 사다리의 한 단계를 씁니다 — `xs` 30rem, `sm` 40rem, `md` 48rem, `lg` 64rem, `xl` 80rem. 위 네 단계는 [breakpoint](../../design/breakpoints)의 바닥과 같은 값이므로, `maxWidth="lg"`는 `lg:` variant가 시작되는 바로 그 폭으로 내용을 묶습니다. `xs`만 예외인데, 폭이 0인 measure는 존재하지 않기 때문입니다.

<Demo src="container/max-width">

<<< @/.vitepress/demos/container/max-width.tsx

</Demo>

### 직접 쓴 길이

사다리의 단계가 아닌 값은 `max-width`에 그대로 전달됩니다. 사다리에 없는 폭이 필요해도 따로 빠져나갈 길이 필요 없다는 뜻입니다. 숫자는 px입니다.

```tsx
<Container maxWidth="60ch">…</Container>
<Container maxWidth="min(90vw, 72rem)">…</Container>
<Container maxWidth={640}>…</Container>
```

### breakpoint에 따라 바꾸기

`maxWidth`는 breakpoint별 map을 받고, 각 항목은 자기 breakpoint부터 위로 적용됩니다. 그래서 두 개면 페이지 하나를 다 설명합니다. [Header](./header)와 [Footer](./footer)도 같은 prop을 같은 모양으로 받으며, 바와 그 아래 내용이 같은 가장자리에 서는 것이 그 방식입니다.

<Demo src="container/responsive">

<<< @/.vitepress/demos/container/responsive.tsx

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

---
title: Grid
order: 6
---

# Grid

<p class="neba-lede">12칸을 기준으로 하는 반응형 레이아웃입니다. <code>GridContainer</code>가 칸 수와 gutter를 정하고, <code>Grid</code>가 그중 몇 칸을 차지할지 정합니다.</p>

<Demo src="grid/hero" />

```tsx
import { Grid, GridContainer } from 'neba';

<GridContainer spacing={3}>
  <Grid span={{ xs: 12, md: 8 }}>본문</Grid>
  <Grid span={{ xs: 12, md: 4 }}>사이드바</Grid>
</GridContainer>;
```

`GridContainer`는 표면을 그리지 않으므로 `variant` · `color` · `elevation`이 없습니다. sheet가 필요하면 [Box](../surfaces/box)나 [Card](../surfaces/card)로 감싸세요.

## Props

### GridContainer

<PropsTable name="GridContainer" />

### Grid

<PropsTable name="Grid" />

두 컴포넌트 모두 `<div>`의 native 속성을 그대로 전달합니다.

## 예시

### span

`span`은 컨테이너의 칸 수에 대한 값입니다. 기본 12칸에서 `span={6}`은 절반이고, `columns={24}`라면 같은 `6`이 4분의 1입니다.

너비는 `(100% + gutter) × span / columns − gutter`로 계산되므로, `span={1}` 열두 개와 `span={12}` 하나가 정확히 같은 지점에서 끝납니다.

<Demo src="grid/spans">

<<< @/.vitepress/demos/grid/spans.tsx

</Demo>

### breakpoint

`span`에 객체를 주면 폭마다 다른 값을 적용합니다. 각 항목은 **그 breakpoint 이상**에 적용되는 하한이므로 두 개만 적어도 레이아웃 하나가 정의됩니다.

폭은 Tailwind 기본값과 같아서 `sm`이 40rem, `md`가 48rem, `lg`가 64rem, `xl`이 80rem입니다. `xs`는 0이며 media query가 붙지 않습니다. Grid와 `md:` 유틸리티가 같은 지점에서 바뀝니다.

`columns` · `spacing` · `rowSpacing` · `columnSpacing` · `offset`도 모두 같은 방식으로 반응형 값을 받습니다.

<Demo src="grid/responsive">

<<< @/.vitepress/demos/grid/responsive.tsx

</Demo>

### spacing · rowSpacing · columnSpacing

`spacing`은 **Tailwind의 간격 스케일**입니다. `spacing={4}`는 `1rem`으로, `gap-4`나 Box의 `p-4`와 같은 길이입니다. 소수도 받으므로 `spacing={1.5}`는 `0.375rem`입니다.

`rowSpacing`과 `columnSpacing`은 각각 한 축만 덮어씁니다.

<Demo src="grid/spacing">

<<< @/.vitepress/demos/grid/spacing.tsx

</Demo>

### columns

칸 수입니다. 12가 기본값이지만 5로 나뉘지 않으므로 `24` 같은 값도 쓸 수 있습니다. 컨테이너 아래의 모든 `span`과 `offset`이 이 수를 기준으로 계산됩니다. 한 줄보다 넓은 `span`은 넘치지 않고 줄에 맞춰 잘립니다.

<Demo src="grid/columns">

<<< @/.vitepress/demos/grid/columns.tsx

</Demo>

### offset

항목 **앞에** 밀어 넣는 빈 칸 수입니다. 줄의 시작에서 센 절대 위치가 아니라 그 자리에 삽입되는 공간이므로, 앞에 이미 항목이 있다면 그 뒤에서부터 밀어냅니다.

<Demo src="grid/offset">

<<< @/.vitepress/demos/grid/offset.tsx

</Demo>

### justifyContent · alignItems · alignContent · alignSelf

정렬은 `className`이 아니라 각각의 prop으로 지정합니다. 앞의 셋은 `GridContainer`에, `alignSelf`는 `Grid`에 있습니다.

값은 `start` / `center` / `end`이며 RTL에서 뒤집힙니다. `space-between` 같은 분배 값은 CSS 이름을 그대로 씁니다.

<Demo src="grid/alignment">

<<< @/.vitepress/demos/grid/alignment.tsx

</Demo>

### padded

`spacing`은 항목 **사이**의 간격이고, `padded`는 grid **둘레**의 여백입니다. 기본값은 `true`이므로 [Container](./container)나 [Card](../surfaces/card), 또는 다른 grid 안에 넣을 때는 끄세요.

여백의 크기는 `size`와 `density`가 정합니다.

<Demo src="grid/padding">

<<< @/.vitepress/demos/grid/padding.tsx

</Demo>

### 중첩

grid 안의 grid는 `Grid` 안에 `GridContainer`를 넣는 형태입니다. 안쪽 grid는 자기 칸이 받은 너비를 다시 나누므로, 거기서의 `span={6}`은 절반의 절반입니다.

<Demo src="grid/nested">

<<< @/.vitepress/demos/grid/nested.tsx

</Demo>

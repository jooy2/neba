---
title: Grid
order: 2
---

# Grid

<p class="neba-lede">12칸을 기준으로 한 반응형 레이아웃. 모든 그리드는 <code>GridContainer</code>가 감싸고, 한 칸씩은 <code>Grid</code>가 차지합니다.</p>

<Demo src="grid/hero" />

```tsx
import { Grid, GridContainer } from 'neba';

<GridContainer spacing={3}>
  <Grid span={{ xs: 12, md: 8 }}>본문</Grid>
  <Grid span={{ xs: 12, md: 4 }}>사이드바</Grid>
</GridContainer>;
```

두 컴포넌트가 나뉜 이유는 아는 것이 다르기 때문입니다. 칸이 몇 개인지와 거터가 얼마나 넓은지는 항목 혼자서는 알 수 없고, 그 셋을 아는 것이 `GridContainer`입니다. `Grid`는 그것을 물려받아 자기 너비만 계산합니다.

물려받는 방법은 React 컨텍스트가 아니라 **상속되는 커스텀 프로퍼티**입니다. 값이 반응형이고, 미디어 쿼리는 React에게 알리지 않은 채 상속된 커스텀 프로퍼티를 바꿀 수 있기 때문입니다 — 그래서 항목이 기준으로 삼는 칸 수는 언제나 지금 화면에 있는 그 값입니다. 컨텍스트였다면 브레이크포인트마다 트리를 다시 렌더링해야 같은 말을 할 수 있습니다.

`GridContainer`는 `variant`도 `color`도 `elevation`도 받지 않습니다. 그리드는 표면이 아니라 표면들의 배치이고, 자기 시트를 그리기 시작하는 순간 페이지의 가장 바깥에 놓을 수 없게 됩니다. 시트가 필요하면 [Box](../surfaces/box)나 [Card](../surfaces/card)로 감싸세요.

## Props

### GridContainer

<PropsTable name="GridContainer" />

### Grid

<PropsTable name="Grid" />

두 컴포넌트 모두 `<div>`의 네이티브 속성을 그대로 전달합니다.

## 예시

### 칸 나누기

`span`은 컨테이너의 칸 수에 대한 값입니다. 기본 12칸에서 `span={6}`은 절반이고, `columns={24}`라면 같은 `6`이 사분의 일입니다.

너비는 `(100% + 거터) × span / columns − 거터`로 정확히 계산됩니다. 근사가 아니라는 점이 중요합니다 — `+ 거터`는 항목이 자기 끝쪽에 갖지 않는 거터를 되돌려주는 몫이라서, `span={1}` 열두 개와 `span={12}` 하나가 같은 픽셀에서 끝납니다.

<Demo src="grid/spans">

<<< @/.vitepress/demos/grid/spans.tsx

</Demo>

### 브레이크포인트

`span`에 맵을 주면 폭마다 다른 값을 씁니다. 각 항목은 **그 브레이크포인트부터 위로** 적용되는 하한이라서, 두 개만 적어도 레이아웃 하나가 설명됩니다.

폭은 Tailwind의 기본값 그대로입니다 — `sm` 40rem, `md` 48rem, `lg` 64rem, `xl` 80rem. `xs`는 0이고, 미디어 쿼리가 없는 값입니다. 그리드와 `md:` 유틸리티가 같은 순간에 바뀌는 것은 이래서입니다.

`columns`, `spacing`, `rowSpacing`, `columnSpacing`, `offset`도 모두 같은 방식으로 반응형입니다.

<Demo src="grid/responsive">

<<< @/.vitepress/demos/grid/responsive.tsx

</Demo>

### 거터

`spacing`은 **Tailwind의 간격 스케일**입니다. `spacing={4}`는 `1rem`이고, 그건 `gap-4`가, 그리고 Box의 `p-4`가 이미 뜻하는 길이입니다. Material의 8px 스케일이 아닙니다 — 이 라이브러리의 다른 모든 숫자가 그 사다리 위에 있고, 거터만 다른 단위로 재는 그리드는 감싸는 상자와 비교할 때마다 계산이 필요한 유일한 지점이 됩니다.

소수점도 받습니다: `spacing={1.5}`는 `0.375rem`, 즉 `gap-1.5`입니다.

`rowSpacing`과 `columnSpacing`은 각각 한 축만 덮어씁니다.

<Demo src="grid/spacing">

<<< @/.vitepress/demos/grid/spacing.tsx

</Demo>

### 칸 수

12는 관례일 뿐 규칙이 아닙니다. 12는 5로 나뉘지 않고, 24는 12가 못 하는 것들을 합니다.

`columns`는 컨테이너에 있고, 그 아래 모든 `span`과 `offset`이 이 수를 기준으로 계산됩니다. 줄보다 넓은 `span`은 넘치지 않고 줄에 맞춰 잘립니다 — `span={99}`는 한 줄을 채우며, 그게 그렇게 쓴 사람의 뜻입니다.

<Demo src="grid/columns">

<<< @/.vitepress/demos/grid/columns.tsx

</Demo>

### 밀어내기

`offset`은 항목 **앞에** 밀어 넣는 빈 칸입니다. 줄의 시작에서 센 절대 위치가 아니라 그 자리에 들어가는 공간이라는 점이 중요합니다. 줄의 첫 항목이라면 둘은 같은 말이지만, 앞에 이미 무언가 있었다면 `offset`은 거기서부터 더 밀어냅니다.

<Demo src="grid/offset">

<<< @/.vitepress/demos/grid/offset.tsx

</Demo>

### 정렬

`justifyContent`, `alignItems`, `alignContent`, 그리고 항목 쪽의 `alignSelf`는 **각자 prop입니다**. `sx`도 `className`도 거치지 않습니다 — 줄이 남은 공간을 어떻게 나누는지는 레이아웃의 결정이지 스타일 탈출구가 아니고, prop이면 타입이 붙고 자동완성이 되고 문서에 남습니다.

값은 `start`/`center`/`end`입니다. `left`/`right`가 아닌 이유는 라이브러리의 다른 모든 곳과 같습니다 — 이 값들은 RTL에서 뒤집힙니다. 분배 값(`space-between` 등)은 CSS 이름을 그대로 씁니다. 이미 이름이 있는 것에 두 번째 이름을 붙이지 않습니다.

<Demo src="grid/alignment">

<<< @/.vitepress/demos/grid/alignment.tsx

</Demo>

### 여백

`padded`는 기본값이 `true`입니다. `spacing`(항목 **사이**)과 `padded`(그리드 **둘레**)는 다른 것이고, 이미 여백을 가진 것 안에 그리드가 들어간다면 — Container, Card, 또 다른 그리드 — 꺼야 합니다.

여백의 크기는 `size`와 `density`가 정합니다. Box에서와 같은 사다리이며, 높이도 타입 스케일도 건드리지 않습니다.

<Demo src="grid/padding">

<<< @/.vitepress/demos/grid/padding.tsx

</Demo>

### 중첩

그리드 안의 그리드는 `Grid` 안의 `GridContainer`이지, 컨테이너를 겸하는 `Grid`가 아닙니다. 안쪽 그리드는 자기 칸이 받은 너비를 다시 나누므로, 거기서의 `span={6}`은 절반의 절반입니다.

<Demo src="grid/nested">

<<< @/.vitepress/demos/grid/nested.tsx

</Demo>

## Material UI에서 옮겨올 때

| MUI | Neba | 왜 |
| --- | --- | --- |
| `<Grid container>` | `<GridContainer>` | 컨테이너와 항목은 받는 prop이 겹치지 않습니다. 하나의 컴포넌트에 `container` 불리언을 두면 나머지 절반의 prop이 언제 무시되는지가 문서에만 남습니다 |
| `<Grid size={6}>` | `<Grid span={6}>` | `size`는 이 라이브러리에서 `xs`…`xl`을 뜻합니다. 같은 이름에 두 번째 뜻을 붙일 수 없어서 CSS가 쓰는 단어인 `span`을 씁니다 |
| <code v-pre>size={{ xs: 12, md: 6 }}</code> | <code v-pre>span={{ xs: 12, md: 6 }}</code> | 맵의 뜻은 같습니다 |
| `spacing={2}` = 16px | `spacing={2}` = 8px | Tailwind 스케일입니다. MUI 값에 2를 곱하면 같은 길이가 됩니다 |
| `offset={4}` | `offset={4}` | 같습니다 |
| `columns={24}` | `columns={24}` | 같습니다 |
| <code v-pre>sx={{ justifyContent: 'center' }}</code> | `justifyContent="center"` | prop입니다 |
| `direction="column"` | 없습니다 | 세로 그리드는 `span={12}`의 나열입니다. `direction`을 받으면 `span`이 폭이 아니라 높이를 뜻하게 되는 상태가 생깁니다 |
| `size="auto"` / `size="grow"` | 없습니다 | 브레이크포인트마다 켜고 끌 수 있는 값이 아니어서, 반응형 맵과 함께 쓰면 반쯤만 동작합니다. 반쯤 동작하는 것을 넣는 대신 뺐습니다 |

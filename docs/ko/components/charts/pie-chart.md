---
title: PieChart
order: 5
---

# PieChart

<p class="neba-lede">전체에 대한 부분을 원의 조각으로 보여 줍니다. "이 중 하나가 대부분인가?"라는 질문 하나에는 잘 답하고, 그보다 세밀한 것은 막대 차트의 몫입니다.</p>

<Demo src="pie-chart/hero" />

```tsx
import { PieChart } from 'neba';

<PieChart
  label="유입 경로별 세션"
  shape="donut"
  categories={['Organic', 'Direct', 'Paid']}
  data={[18420, 9260, 6140]}
/>;
```

## 데이터 형식

pie는 series가 하나이므로 series 배열이 아니라 `data`를 직접 받습니다. 여기서 정체성을 갖는 것은 조각이며, 조각 하나하나가 팔레트 slot을 가져가고 범례도 조각을 나열합니다.

`data`는 `NebaChartDatum`의 배열입니다 — 숫자이거나 `null`이거나, 이름과 색을 직접 들고 있는 점입니다. `categories`가 조각의 이름을 정하고, 대신 각 점이 `x`를 들고 있어도 됩니다.

```tsx
<PieChart categories={['Free', 'Pro', 'Team']} data={[4820, 2140, 890]} />

<PieChart
  data={[
    { x: 'Passed', y: 1284, color: 'success' },
    { x: 'Failed', y: 96, color: 'danger' }
  ]}
/>
```

조각은 넘긴 순서대로 그려지고 다시 정렬되지 않습니다. 필터를 바꿔도 각 category는 원래의 색과 자리를 유지합니다.

## Props

<PropsTable name="PieChart" />

`<div>`의 native 속성과 [Box](../surfaces/box)의 모든 prop이 그대로 전달됩니다. `legend`와 `tooltip`은 [LineChart](./line-chart#props)와 같은 형태를 받습니다. 공용 축은 [prop 규약](../../design/prop-conventions)을 참고하세요.

## 예시

### shape

`pie`는 꽉 찬 원, `donut`은 가운데를 비운 고리입니다. `semi`는 상자 아래쪽에서 반원을 그리므로, 세로보다 가로가 긴 대시보드 타일에 맞습니다.

<Demo src="pie-chart/shapes">

<<< @/.vitepress/demos/pie-chart/shapes.tsx

</Demo>

### center

`donut`이나 `semi`의 빈 가운데에 들어가는 것입니다. 가운데가 빈 고리는 한 입 베어 문 pie일 뿐이고, 합계나 이 차트가 말하려는 수치 하나가 그 고리를 그린 이유입니다.

```tsx
<PieChart shape="donut" center={<Typography level="h4">38.6K</Typography>} … />
```

### valueLabels

`all`은 각 조각에 그 **비중**을 씁니다 — pie가 그리는 것이 비중이고, 값은 hover 한 번 거리에 있습니다. 라벨은 양옆에 여유를 두고 들어갈 만큼 조각이 넓을 때만 그려집니다. 들어가지 않는 라벨은 잘리는 대신 그려지지 않으며, tooltip과 표에는 그대로 남아 있습니다.

### 색

조각은 넘긴 순서대로 팔레트 slot을 가져갑니다. 점의 `color`가 그것을 덮어쓰는데, 조각 자체에 *의미*가 있을 때 그렇게 해야 합니다 — 성공과 실패는 "series 1"과 "series 2"가 아닙니다.

<Demo src="pie-chart/colors">

<<< @/.vitepress/demos/pie-chart/colors.tsx

</Demo>

### legend · startAngle

범례는 조각이 둘 이상이면 나타나고 기본적으로 클릭할 수 있습니다. 조각의 항목을 클릭하면 그 조각이 빠지고 나머지가 원을 다시 채웁니다. `startAngle`은 12시 방향에서 시계 방향으로 몇 도에서 시작할지를 정합니다.

```tsx
<PieChart legend={{ side: 'right', align: 'center' }} startAngle={-30} … />
```

## 접근성

- 데이터는 `label`을 caption으로 하는 **화면에 보이지 않는 표**로도 렌더링됩니다.
- plot에 focus할 수 있습니다. `←`·`→`로 조각을 옮기고 `Escape`로 해제하므로, 포인터 없이도 tooltip에 닿을 수 있습니다.
- 조각은 각각의 테두리가 아니라 표면 색의 간격으로 분리되며, 그 간격은 반지름과 무관하게 화면에서 2px로 유지됩니다.

## 쓰지 말아야 할 때

각도는 비교하기 나쁜 양입니다. 몇 퍼센트 차이의 두 조각은 구분되지 않고, 여섯 조각의 순위를 매길 수 있는 사람은 없습니다. 조각이 여섯을 넘거나 질문이 "이것들의 순위는?"이라면 [BarChart](./bar-chart)를 쓰세요. 조각이 둘인 pie는 [Statistic](./statistic)입니다.

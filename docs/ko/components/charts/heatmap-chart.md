---
title: HeatmapChart
order: 8
---

# HeatmapChart

<p class="neba-lede">셀마다 크기를 하나씩, 재는 대신 색으로 나타내는 차트입니다. 같은 아이디어의 두 형태 — category 축 두 개와 숫자 하나를 위한 grid, 그리고 pie가 담기에는 조각이 너무 많은 전체·부분을 위한 treemap입니다.</p>

<Demo src="heatmap-chart/hero" />

```tsx
import { HeatmapChart } from 'neba';

<HeatmapChart
  label="시간대·요일별 세션"
  categories={['00', '06', '12', '18']}
  series={[
    { name: 'Mon', data: [4, 24, 51, 18] },
    { name: 'Tue', data: [3, 27, 55, 20] }
  ]}
/>;
```

## 데이터 형식

`series`의 형태는 모든 차트가 공유합니다 — 전체 정의는 [LineChart](./line-chart#데이터-형식)에 있습니다. 여기서 series 하나는 grid의 **행** 또는 treemap의 **그룹**이고, `y`가 크기, `x`가 열 또는 타일의 이름입니다.

`null`은 결측이고 그 셀은 그리지 않은 채로 둡니다. 스케일의 맨 아래로 칠하지 않습니다 — "아무 일도 없었다"와 "가장 적었다"는 서로 다른 읽기이고, 데이터에 있는 것은 둘 중 하나뿐이기 때문입니다.

스케일은 행마다가 아니라 차트 전체의 모든 셀에 걸쳐 한 번 정해집니다. 같은 색은 어디에 있든 같은 숫자를 뜻해야 하고, 그것이 heatmap이 하는 약속의 전부입니다. 비교에 고정된 틀이 필요하면 `min`·`max`로 양 끝을 고정하세요.

## Props

<PropsTable name="HeatmapChart" />

`<div>`의 native 속성과 [Box](../surfaces/box)의 모든 prop이 그대로 전달됩니다. 공용 축은 [prop 규약](../../design/prop-conventions)을 참고하세요.

## 예시

### shape

`grid`는 category 축 둘과 숫자 하나를 위한 형태입니다 — 요일 대비 시간대, 주차 대비 코호트. `treemap`은 datum마다 타일 하나를 비중에 맞는 크기로 채워 상자를 가득 메웁니다.

treemap은 잘라 나누는 대신 squarify합니다. 타일을 행으로 쌓다가 종횡비가 더 나아지지 않는 순간 그 행을 닫습니다. 그냥 잘라 나누면 값이 스무 개일 때 폭 1px짜리 조각들이 남는데, 그런 조각의 *넓이*는 아무리 정확해도 읽히지 않습니다.

treemap에는 축이 없습니다 — 모든 타일이 자기 얼굴에 이름을 씁니다 — 그리고 음수는 넓이로 표현될 수 없으므로 표에는 남고 그림에서는 빠집니다.

<Demo src="heatmap-chart/treemap">

<<< @/.vitepress/demos/heatmap-chart/treemap.tsx

</Demo>

### scale

`sequential`은 한 hue로 옅은 쪽에서 진한 쪽까지이고, 많을수록 그냥 많다는 뜻일 때 맞습니다. `diverging`은 중립 회색을 사이에 둔 두 hue로, **중간**이 의미를 가지는 값을 위한 것입니다 — 목표 대비 초과와 미달, 증가와 감소. 그 중간이 어디인지는 `midpoint`가 정합니다.

`diverging`은 실제로 기준이 되는 0이 있을 때만 쓰세요. 그냥 크기인 값에 쓰면 데이터에 없는 경계를 만들어 내고, 독자는 차트를 보는 내내 회색에서 무엇이 바뀌었는지를 찾게 됩니다.

두 램프 모두 8슬롯 [category 팔레트](../../design/color)가 아닙니다. 여기서 색은 정체성이 아니라 크기를 나타내며, hue 여덟 개짜리 heatmap은 셀들이 서로 무관한 여덟 가지라고 말하는 셈입니다.

<Demo src="heatmap-chart/diverging">

<<< @/.vitepress/demos/heatmap-chart/diverging.tsx

</Demo>

### valueLabels · min · max

`valueLabels="all"`은 각 값을 셀 위에 씁니다. 글자가 양옆 여백과 함께 들어갈 만큼 셀이 클 때만이고, 들어가지 않는 라벨은 잘리는 대신 생략됩니다. 채워진 셀 안의 라벨은 그 아래 스텝에서 잉크를 고르므로 램프의 양쪽 끝 모두에서 읽힙니다.

`min`·`max`는 스케일을 고정합니다. 생략하면 양 끝이 데이터에서 오는데, 그 말은 서로 다른 데이터의 두 차트는 같은 범위를 줄 때까지 비교할 수 없다는 뜻입니다.

<Demo src="heatmap-chart/labels">

<<< @/.vitepress/demos/heatmap-chart/labels.tsx

</Demo>

### legend

범례는 swatch 목록이 아니라 양 끝에 값이 붙은 스케일 막대입니다 — 여기에는 이름을 가진 것이 없고, 순서 자체가 의미이기 때문입니다. `diverging`에서는 막대 가운데 아래에 midpoint를 씁니다. `legend={false}`로 끄고, `legend`의 `side`로 옮깁니다.

## 접근성

- 데이터는 `label`을 caption으로 하는 **화면에 보이지 않는 표**로도 렌더링됩니다. series 하나가 한 행, category 하나가 한 열입니다.
- plot에 focus할 수 있습니다. `←`·`→`로 셀을 옮기고 `Escape`로 tooltip을 해제합니다.
- 스케일 범례가 범위의 양 끝을 숫자로 알려 주므로, 램프를 눈으로만 읽어야 하는 경우는 없습니다.

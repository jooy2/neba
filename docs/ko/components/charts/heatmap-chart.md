---
title: HeatmapChart
order: 8
---

# HeatmapChart

<p class="neba-lede">셀마다 하나의 크기를 재는 대신 색으로 나타내는 차트입니다. 같은 아이디어를 두 형태로 그립니다. category 축 두 개와 숫자 하나를 위한 grid, 그리고 pie가 담기에는 조각이 너무 많은 전체와 부분을 위한 treemap입니다.</p>

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

`series`의 형태는 모든 차트가 공유합니다. 전체 정의는 [LineChart](./line-chart#데이터-형식)에 있습니다. 여기서 series 하나는 grid의 **행**입니다. treemap은 모든 series의 타일을 크기에 따라 한데 배치하므로, 거기서 series는 타일을 한곳에 모으지 않고 표에서 이름을 붙이는 역할만 합니다. `y`가 크기, `x`가 열 또는 타일의 이름입니다.

`null`은 결측이고, 그 셀은 스케일의 맨 아래로 칠하지 않고 그리지 않은 채로 둡니다.

스케일은 행마다가 아니라 차트 전체의 모든 셀에 걸쳐 한 번 정해지므로, 같은 색은 어디에 있든 같은 숫자를 뜻합니다. 비교에 고정된 틀이 필요하면 `min`·`max`로 양 끝을 고정하세요.

## Props

<PropsTable name="HeatmapChart" />

`<div>`의 native 속성과 [Box](../surfaces/box)의 모든 prop이 그대로 전달됩니다. 공용 축은 [prop 규약](../../design/prop-conventions)을 참고하세요.

## 예시

### shape

`grid`는 요일 대비 시간대나 주차 대비 코호트처럼 category 축 둘과 숫자 하나를 위한 형태입니다. `treemap`은 datum마다 타일 하나를 비중에 맞는 크기로, 정사각형에 최대한 가깝게 놓아 상자를 가득 메웁니다.

treemap에는 축이 없고 이름이 타일 안에 직접 적힙니다. 음수는 넓이로 표현할 수 없으므로 표에는 남고 그림에서는 빠집니다.

<Demo src="heatmap-chart/treemap">

<<< @/.vitepress/demos/heatmap-chart/treemap.tsx

</Demo>

### scale

`sequential`은 한 hue로 옅은 쪽에서 진한 쪽까지이고, 많을수록 그냥 많다는 뜻일 때 맞습니다. `diverging`은 중립 회색을 사이에 둔 두 hue로, 목표 대비 초과와 미달, 증가와 감소처럼 **중간**이 의미를 가지는 값에 씁니다. 그 중간이 어디인지는 `midpoint`가 정합니다.

`diverging`은 실제로 기준이 되는 0이 있을 때만 쓰세요. 두 램프 모두 8슬롯 [category 팔레트](../../design/color)의 색을 쓰지 않습니다.

<Demo src="heatmap-chart/diverging">

<<< @/.vitepress/demos/heatmap-chart/diverging.tsx

</Demo>

### valueLabels · min · max

`valueLabels="all"`은 각 값을 셀 위에 씁니다. 글자가 양옆 여백과 함께 들어갈 만큼 셀이 클 때만이고, 들어가지 않는 라벨은 잘리는 대신 생략됩니다. 채워진 셀 안의 라벨은 그 아래 스텝에서 잉크를 고르므로 램프의 양쪽 끝 모두에서 읽힙니다.

`min`·`max`는 스케일을 고정합니다. 생략하면 양 끝이 데이터에서 오므로, 서로 다른 데이터의 두 차트는 같은 범위를 줘야 비교할 수 있습니다. sequential 스케일에서 값이 모두 같으면 나눌 범위가 없으므로, 0 이하는 가장 연한 단계, 0보다 크면 가장 진한 단계가 됩니다.

<Demo src="heatmap-chart/labels">

<<< @/.vitepress/demos/heatmap-chart/labels.tsx

</Demo>

### xAxis · yAxis

`grid`에는 **category** 축이 둘 있습니다. `xAxis`는 아래쪽의 열 이름을, `yAxis`는 옆쪽의 행 이름을 정합니다. 크기가 그려지는 곳은 색 ramp이고 그것을 설명하는 것은 축이 아니라 scale 범례이므로, `min`·`max`·`tickCount`·`grid`는 여기서 아무 뜻이 없고 읽지도 않습니다. ramp의 범위는 차트 자신의 `min`과 `max`가 정합니다.

`label`은 축의 이름을, `tickFormat`은 이름 하나의 표기를 정합니다. `hidden`은 띠를 없애고 그 자리를 셀에 돌려주며, `thickness`는 대시보드에서 두 grid를 맞출 때 폭을 고정합니다. `xAxis.tickAngle`은 열 이름을 기울입니다. 긴 단계 이름이 늘어선 grid가 이름을 다 보여 줄 수 있는 이유가 그것입니다. `yAxis`는 이 값을 읽지 않습니다. 행에는 이미 제 줄이 하나씩 있습니다.

`treemap`은 타일 위에 제 이름을 쓰므로 두 축 모두 읽지 않습니다.

<Demo src="heatmap-chart/axes">

<<< @/.vitepress/demos/heatmap-chart/axes.tsx

</Demo>

### legend

범례는 swatch 목록이 아니라 양 끝에 값이 붙은 스케일 막대입니다. `diverging`에서는 막대 가운데 아래에 midpoint를 씁니다. `legend={false}`로 끄고, `legend`의 `side`로 옮깁니다.

## 접근성

- 데이터는 `label`을 caption으로 하는 **화면에 보이지 않는 표**로도 렌더링됩니다. series 하나가 한 행, category 하나가 한 열입니다. treemap의 열은 그룹들이 쓰는 모든 타일 이름이고, 값은 저마다 자기 이름 열에 들어갑니다. plot 자체의 설명은 값의 개수와 범위를 담은 한 문장이라, focus할 때 표 전체를 읽지 않습니다.
- plot에 focus할 수 있습니다. grid에서는 `←`·`→`가 행 순서로 셀을 옮기고 `↑`·`↓`가 열을 유지한 채 행을 바꿉니다. treemap에서는 어느 화살표든 가장 큰 타일부터 작은 타일 순으로 옮깁니다. `Escape`로 tooltip을 해제합니다. 터치 화면에서는 탭한 셀의 tooltip이 plot 바깥을 탭할 때까지 남습니다.
- 스케일 범례가 범위의 양 끝을 숫자로 알려 주므로, 램프를 눈으로만 읽어야 하는 경우는 없습니다.

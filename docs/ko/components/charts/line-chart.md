---
title: LineChart
order: 2
---

# LineChart

<p class="neba-lede">순서가 있는 category 축 위에 하나 이상의 series를 그립니다. 두 점 사이가 서로 무관한 두 값이 아니라 하나의 흐름일 때 — 시간에 따른 값, 구간에 따른 곡선 — 쓰는 차트입니다.</p>

<Demo src="line-chart/hero" />

```tsx
import { LineChart } from 'neba';

<LineChart
  label="월별 주간 활성 사용자"
  categories={['Jan', 'Feb', 'Mar']}
  series={[
    { name: 'Web', data: [1820, 1960, 2140] },
    { name: 'Mobile', data: [940, 1120, 1310] }
  ]}
/>;
```

## 데이터 형식

라이브러리의 모든 차트가 같은 두 prop을 받습니다. 대시보드의 한 타일을 다른 차트로 바꿀 때 데이터를 다시 쓸 필요가 없도록 하기 위해서입니다.

`series`는 `NebaChartSeries`의 배열이고, 항목 하나가 선 하나입니다.

```ts
interface NebaChartSeries {
  name?: string; // 범례·tooltip·표에 쓰이는 이름
  data: readonly NebaChartDatum[]; // category 순서대로 놓인 값
  color?: NebaColor | string; // 팔레트 slot 대신 쓸 색
  hidden?: boolean; // 처음엔 숨김. 범례로 다시 켭니다
}
```

`NebaChartDatum`은 숫자이거나 `null`이거나, 점 하나입니다.

```ts
type NebaChartDatum = number | null | NebaChartPoint;

interface NebaChartPoint {
  x?: string | number | Date; // category 축에서의 위치
  y: number | null; // 값
  color?: string; // 이 점만 series 색을 덮어씁니다
  label?: ReactNode; // 숫자 대신 tooltip에 쓸 내용
}
```

**`null`은 0이 아니라 결측입니다.** 센서가 꺼져 있던 달과 매출이 0이었던 달은 다른 사실이고, 차트도 다르게 그립니다 — `null`에서 선이 끊기고 점은 그리지 않습니다. `connectNulls`가 그 사이를 잇지만, 결측이 수집 과정의 문제일 때만 쓰세요.

`categories`는 x 축의 위치 이름입니다. 대신 각 점이 `x`를 직접 들고 있어도 됩니다 — 데이터가 이미 갖고 있는 모양을 그대로 쓰면 됩니다.

<Demo src="line-chart/data">

<<< @/.vitepress/demos/line-chart/data.tsx

</Demo>

## Props

<PropsTable name="LineChart" />

`<div>`의 native 속성과 [Box](../surfaces/box)의 모든 prop이 그대로 전달됩니다. `variant`의 기본값은 `text`, `padded`는 `false`이므로 [Card](../surfaces/card) 안에 넣어도 표면이 겹치지 않습니다. 자체 표면이 필요하면 `variant="outline"`을 쓰세요. 공용 축은 [prop 규약](../../design/prop-conventions)을 참고하세요.

### NebaChartAxis

`xAxis`와 `yAxis`가 모두 이 형태를 받습니다.

<PropsTable name="NebaChartAxis" />

### NebaChartLegend

<PropsTable name="NebaChartLegend" />

### NebaChartTooltip

<PropsTable name="NebaChartTooltip" />

## 예시

### curve

`curve`는 한 점에서 다음 점으로 가는 방식을 정합니다. 기본값 `linear`는 데이터에 없는 것을 주장하지 않습니다. `smooth`는 monotone cubic 곡선으로, 부드럽지만 양옆 값보다 아래로 내려가는 일이 없습니다. `step`은 다음 측정까지 값을 유지하는데, rate limit이나 요금제 등급이 실제로 그 사이에 한 일이 그것입니다.

<Demo src="line-chart/curve">

<<< @/.vitepress/demos/line-chart/curve.tsx

</Demo>

### xAxis · yAxis

LineChart는 값 축을 데이터에 맞춰 자릅니다. 선이 나타내는 것은 *위치*이고, 축을 잘라도 모든 점이 같은 만큼 움직이므로 모양이 남기 때문입니다. 0이 축에 있어야 한다면 `yAxis`에 `min: 0`을 넘기세요.

`min`·`max`·`tickCount`가 범위를, `tickFormat`이 눈금의 표기를 정합니다. `grid: false`는 격자선을, `hidden`은 축 전체를 없애고 그 자리를 plot에 돌려줍니다.

<Demo src="line-chart/axes">

<<< @/.vitepress/demos/line-chart/axes.tsx

</Demo>

### connectNulls

<Demo src="line-chart/gaps">

<<< @/.vitepress/demos/line-chart/gaps.tsx

</Demo>

### valueLabels · gradient · markers

`valueLabels`는 선 위에 숫자를 씁니다. `last`는 각 series가 도달한 값을, `extremes`는 series의 최고·최저를, `all`은 모든 점을 표시합니다. 기본값은 `none`입니다 — 모든 점 옆에 숫자를 쓰는 것이 차트를 읽을 수 없게 만드는 가장 확실한 방법입니다.

`markers`는 점 위에 dot을 그립니다. `auto`는 점이 열네 개 이하일 때만 그리고, 포인터가 올라간 점에는 설정과 무관하게 항상 그립니다.

`gradient`는 각 선을 같은 hue의 옅은 단계에서 시작해 끝에서 원래 색이 되도록 흐리게 합니다.

<Demo src="line-chart/labels">

<<< @/.vitepress/demos/line-chart/labels.tsx

</Demo>

### legend

범례는 series가 둘 이상이면 자동으로 나타나고, 하나면 나타나지 않습니다. `side`와 `align`이 위치를 정하고, 항목을 클릭하면 해당 series가 숨겨지며 남은 series는 원래 색을 그대로 유지합니다. `legend={false}`는 범례를 없애고, `interactive: false`는 클릭되지 않는 범례로 만듭니다.

<Demo src="line-chart/legend">

<<< @/.vitepress/demos/line-chart/legend.tsx

</Demo>

### 색

series는 넘긴 순서대로 팔레트 slot을 가져갑니다 — 여덟 개의 색이 고정된 순서로 배정되고 순환하지 않습니다. 아홉 번째 series는 아홉 번째 색이 아닙니다. 나머지를 "기타" series로 묶거나 차트를 하나 더 그리세요.

`series.color`는 그 slot을 `NebaColor` 이름이나 임의의 CSS 색으로 덮어쓰고, 점의 `color`는 그 점 하나만 덮어씁니다. 색 계열이 무엇을 만족시키도록 만들어졌는지는 [색](../../design/color)에 있습니다.

```tsx
<LineChart
  series={[
    { name: 'Errors', data: errors, color: 'danger' },
    { name: 'Warnings', data: warnings, color: 'warning' }
  ]}
/>
```

### format

`format`은 `Intl.NumberFormat` 옵션을 받아 숫자가 나타나는 모든 곳에 적용됩니다 — 축, tooltip, 값 라벨, 표. 생략하면 만 이상의 축 눈금은 축약됩니다(`12.4K`).

```tsx
<LineChart format={{ style: 'currency', currency: 'KRW', maximumFractionDigits: 0 }} … />
<LineChart format={{ style: 'percent', maximumFractionDigits: 1 }} … />
```

## 접근성

- 모든 차트는 데이터를 **표**로도 렌더링합니다. 화면에는 보이지 않지만 보조 기술에는 노출되며, `label`이 그 표의 caption이자 차트의 접근 가능한 이름이 됩니다. tooltip에만 있고 표에는 없는 값은 없습니다.
- plot에 focus할 수 있습니다. `←`·`→`로 category를 옮기고, `Home`·`End`로 양 끝으로, `Escape`로 해제합니다. 포인터 없이도 tooltip에 닿을 수 있습니다.
- 범례는 `aria-pressed`를 가진 버튼의 목록이므로, 어떤 series가 그려지고 있는지가 색이 아니라 상태로 표현됩니다.
- 정체성을 색만으로 전달하지 않습니다. series가 둘 이상이면 범례가 항상 있고, 팔레트의 인접한 색은 protanopia·deuteranopia 시뮬레이션으로 검증되어 있습니다.

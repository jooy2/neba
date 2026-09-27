---
title: LineChart
order: 2
---

# LineChart

<p class="neba-lede">순서가 있는 category 축 위에 하나 이상의 series를 그립니다. 이웃한 두 점이 서로 무관한 값이 아니라 하나의 연속된 변화일 때 씁니다. 시간에 따른 값이나 구간에 따른 곡선이 그런 경우입니다.</p>

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
  z?: number; // 두 번째 크기: bubble의 반지름, 타일의 무게
  color?: string; // 이 점만 series 색을 덮어씁니다
  label?: ReactNode; // 숫자 대신 tooltip에 쓸 내용
}
```

**`null`은 0이 아니라 결측입니다.** 센서가 꺼져 있던 달과 매출이 0이었던 달은 다른 사실이고, 차트도 다르게 그립니다. `null`에서 선이 끊기고 점은 그리지 않습니다. 다르게 그리고 싶다면 `nulls`로 말하세요.

`categories`는 x 축의 위치 이름입니다. 대신 각 점이 `x`를 직접 들고 있어도 됩니다. 데이터가 이미 갖고 있는 모양을 그대로 쓰면 됩니다.

<Demo src="line-chart/data">

<<< @/.vitepress/demos/line-chart/data.tsx

</Demo>

## Props

<PropsTable name="LineChart" />

`<div>`의 native 속성과 [Box](../surfaces/box)의 모든 prop이 그대로 전달됩니다. `variant`의 기본값은 `text`, `padded`는 `false`이므로 [Card](../surfaces/card) 안에 넣어도 표면이 겹치지 않습니다. 자체 표면이 필요하면 `variant="outline"`을 쓰세요. 공용 축은 [prop 규약](../../design/prop-conventions)을 참고하세요.

### NebaChartSeries

<PropsTable name="NebaChartSeries" />

### NebaChartAxis

`xAxis`와 `yAxis`가 모두 이 형태를 받습니다.

<PropsTable name="NebaChartAxis" />

### NebaChartBrush

<PropsTable name="NebaChartBrush" />

### NebaChartReference

`references`의 각 항목이 받는 형태입니다.

<PropsTable name="NebaChartReference" />

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

### tickAngle

category 축의 라벨을 `-90`도에서 `90`도 사이로 기울입니다. 음수는 오른쪽 위로 눕히고, 양수는 아래로 눕히며, `-90`은 세로로 세웁니다.

눕히지 않은 라벨은 슬롯 하나 안에 들어가야 하므로 축이 이름을 `…`으로 자르고, 그래도 모자라면 한 칸씩 건너뛰며 지웁니다. 기울이면 라벨은 이웃과 제 높이만큼만 벌어지면 되고, 이름 하나가 차지하는 자리는 이름의 길이와 무관해집니다. plot 아래 띠는 눕힌 라벨을 담을 만큼 넓어지되 상한이 있고, 그 너머는 여전히 잘립니다.

읽는 것은 category 축뿐이고, 그 축이 아래쪽에 그려질 때만입니다. `horizontal`인 [BarChart](./bar-chart)는 이미 이름마다 한 줄씩 주고 있습니다.

<Demo src="line-chart/ticks">

<<< @/.vitepress/demos/line-chart/ticks.tsx

</Demo>

### nulls

값이 없는 자리를 어떻게 할지 정합니다.

- `gap` — 끊습니다. 기본값이고, 아무것도 지어내지 않는 유일한 값입니다.
- `connect` — 앞뒤를 직선으로 잇습니다. 세상이 아니라 수집 과정 때문에 생긴 빈틈에만 쓰세요. 이어 그린 구간은 차트가 지어낸 값입니다.
- `zero` — 0으로 읽습니다. 그림이 아니라 데이터를 고쳐 쓰므로 축의 범위에도 0이 들어가고 tooltip과 표도 `0`이라고 말합니다. 없는 행이 정말로 "한 번도 없었다"를 뜻할 때 쓰세요. 이벤트 수는 대개 그렇고, 비율은 결코 그렇지 않습니다.

`connectNulls`는 `connect`의 옛 이름이고 아직 동작합니다. `nulls`를 주지 않았을 때만 읽습니다.

<Demo src="line-chart/gaps">

<<< @/.vitepress/demos/line-chart/gaps.tsx

</Demo>

### brush

plot 아래에 series 전체를 담은 띠를 놓고, 그 위의 창을 끌어 어느 구간을 그릴지 고르게 합니다.

plot 너비로는 읽을 수 없을 만큼 긴 series에 씁니다. 1년 치 시간별 측정값 같은 것입니다.

창을 끌면 이동하고 양끝 손잡이를 끌면 크기가 바뀝니다. 두 손잡이는 `role="slider"` 버튼이라 방향키로 한 칸씩, `Page Up`·`Page Down`으로 series의 10분의 1씩 움직이고 `Home`·`End`로 양 끝까지 갑니다. 띠는 차트 이름을 단 group입니다. `defaultRange`가 시작 위치를, `range`와 `onRangeChange`가 호출하는 쪽이 들고 있는 창을, `height`가 띠의 높이를 정합니다. 띠는 축 라벨과 마찬가지로 차트의 height **안쪽에** 그려집니다.

창이 좁히는 것은 그림뿐입니다. 숨은 표와 내보낸 파일에는 모든 점이 그대로 있습니다.

<Demo src="line-chart/brush">

<<< @/.vitepress/demos/line-chart/brush.tsx

</Demo>

### secondaryAxis

먼 쪽 가장자리에 그리는 두 번째 값 축입니다. 세로 차트에서는 오른쪽, 옆으로 눕힌 차트에서는 위쪽입니다. `axis: 'secondary'`를 단 series가 이 축으로 측정됩니다. 분리를 켜는 것은 `secondaryAxis`를 주는 일이므로, 축이 하나인 차트에서 `axis`만 단 series는 반쯤 적용되는 대신 그냥 첫 축으로 측정됩니다.

이 축의 `tickFormat`은 **숫자가 나타나는 모든 곳**에서 이 축 series의 값을 씁니다. 눈금, tooltip, 표 전부입니다.

격자선은 따로 긋지 않습니다. 눈금 개수를 첫 축과 같게 맞춰서, 이미 그어진 선을 둘이 함께 씁니다.

**stacked 차트에서는 읽지 않습니다.** 쌓아 올린 것은 합계이고, 단위가 둘인 합계는 숫자가 아닙니다.

<Demo src="line-chart/two-axes">

<<< @/.vitepress/demos/line-chart/two-axes.tsx

</Demo>

### references

데이터에 없는 값 위에 긋는 선과 띠입니다. 목표, SLA, 예산, 예측이 덮는 구간 같은 것들이고, 카테시안 차트 전부가 받습니다.

`value`가 위치를 정합니다. `to`를 주면 선이 띠가 됩니다. `axis: 'category'`는 숫자를 반대쪽 축으로 읽어서, *얼마*가 아니라 *언제*를 말하는 선을 긋습니다. 열로 된 축에서는 그 숫자가 열의 index이고, 날짜나 숫자 축에서는 그 축 위의 한 점입니다. index는 시리즈 전체의 첫 category부터 세므로 `brush`로 plot을 좁혀도 제 열에 남습니다. plot이 그리는 범위 밖의 선은 그리지 않고, 띠는 plot 가장자리에서 잘립니다.

**축의 범위가 이 값까지 넓어집니다.** 측정값 전부보다 높은 목표도 화면에 남는다는 뜻입니다. 선은 마크 아래, 격자 위에 그려지고, 따로 말하지 않으면 중립색 점선입니다. 이름이 있는 reference는 데이터와 함께 읽힙니다.

<Demo src="line-chart/references">

<<< @/.vitepress/demos/line-chart/references.tsx

</Demo>

### valueLabels · gradient · markers

`valueLabels`는 선 위에 숫자를 씁니다. `last`는 각 series가 도달한 값을, `extremes`는 series의 최고·최저를, `all`은 모든 점을 표시합니다. 기본값은 `none`입니다.

숫자는 제 series의 색을 입되, 작은 라벨이 대비를 지키도록 본문 글자색 쪽으로 한 단계 당깁니다.

`markers`는 점 위에 dot을 그립니다. `auto`는 점이 열네 개 이하일 때만 그리고, 포인터가 올라간 점에는 설정과 무관하게 항상 그립니다.

`gradient`는 각 선을 같은 hue의 옅은 단계에서 시작해 끝에서 원래 색이 되도록 흐리게 합니다.

<Demo src="line-chart/labels">

<<< @/.vitepress/demos/line-chart/labels.tsx

</Demo>

### exportable

차트의 데이터를 CSV 파일로 쓰는 작은 버튼을 모서리에 답니다. plot 아래 숨은 표가 들고 있는 것과 같은 숫자입니다. 숨은 표가 있는 차트는 모두 받습니다.

`exportFileName`이 파일 이름을 정합니다. `onExport`를 주면 내려받는 대신 CSV 문자열을 넘기므로, 어딘가로 보내거나 시트를 씌울 수 있습니다.

파일을 쓰는 모듈은 **버튼을 누를 때 받아 옵니다.** 이 기능을 켜지 않은 페이지는 그 코드를 하나도 내려받지 않습니다. `GaugeChart`는 이 셋을 받지 않습니다.

<Demo src="line-chart/export">

<<< @/.vitepress/demos/line-chart/export.tsx

</Demo>

### legend

범례는 series가 둘 이상이면 자동으로 나타나고, 하나면 나타나지 않습니다. `side`와 `align`이 위치를 정하고, 항목을 클릭하면 해당 series가 숨겨지며 남은 series는 원래 색을 그대로 유지합니다. 새 데이터가 series의 순서를 바꿔도 `name`이 같다면 숨긴 series는 계속 숨겨져 있습니다. `legend={false}`는 범례를 없애고, `interactive: false`는 클릭되지 않는 범례로 만듭니다.

<Demo src="line-chart/legend">

<<< @/.vitepress/demos/line-chart/legend.tsx

</Demo>

### 색

series는 넘긴 순서대로 팔레트 slot을 가져갑니다. 여덟 개의 색이 고정된 순서로 배정되고, 아홉 번째 series부터는 slot이 되풀이되며 개발 빌드에서는 콘솔에 한 번 경고가 나옵니다. 아홉 번째 series는 아홉 번째 색이 아닙니다. 나머지를 "기타" series로 묶거나 차트를 하나 더 그리세요.

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

`format`은 `Intl.NumberFormat` 옵션을 받아 축과 tooltip, 값 라벨, 표까지 숫자가 나타나는 모든 곳에 적용됩니다. 생략하면 만 이상의 축 눈금은 축약됩니다(`12.4K`). `locale`이 없는 차트는 렌더링되는 곳의 언어와 시간대로 숫자와 날짜를 쓰므로, 서버에서 렌더링하는 페이지라면 `locale`을 넘기세요. 그러지 않으면 서버의 `Mar 3`과 독자의 표기가 하이드레이션할 때 어긋날 수 있습니다.

```tsx
<LineChart format={{ style: 'currency', currency: 'KRW', maximumFractionDigits: 0 }} … />
<LineChart format={{ style: 'percent', maximumFractionDigits: 1 }} … />
```

## 접근성

- 모든 차트는 데이터를 **표**로도 렌더링합니다. 화면에는 보이지 않지만 보조 기술에는 노출되며, `label`이 그 표의 caption이자 차트의 접근 가능한 이름이 됩니다. tooltip에만 있고 표에는 없는 값은 없습니다. plot의 설명은 표가 아니라 값의 개수와 범위를 담은 한 문장이라, focus할 때 모든 숫자를 읽지 않습니다.
- plot에 focus할 수 있습니다. `←`·`→`로 category를 옮기고, `Home`·`End`로 양 끝으로, `Escape`로 해제합니다. 포인터 없이도 tooltip에 닿을 수 있습니다.
- 터치 화면에서는 탭하면 가장 가까운 점의 tooltip이 뜨고 그대로 남습니다. plot 바깥을 탭하면 닫힙니다. tooltip이 있는 모든 차트가 같습니다.
- 범례는 `aria-pressed`를 가진 버튼의 목록이므로, 어떤 series가 그려지고 있는지가 색이 아니라 상태로 표현됩니다.
- 정체성을 색만으로 전달하지 않습니다. series가 둘 이상이면 범례가 항상 있고, 팔레트의 인접한 색은 protanopia·deuteranopia 시뮬레이션으로 검증되어 있습니다.

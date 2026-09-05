---
title: ScatterChart
order: 6
---

# ScatterChart

<p class="neba-lede">점마다 두 개의 값을 서로에 대해 그려, 둘이 함께 움직이는지를 읽는 차트입니다. 세 번째 숫자를 든 점은 bubble로 그려지므로 산점도와 bubble 차트가 한 컴포넌트입니다.</p>

<Demo src="scatter-chart/hero" />

```tsx
import { ScatterChart } from 'neba';

<ScatterChart
  label="체류 시간 대비 읽은 페이지 수"
  xAxis={{ label: '체류 시간(초)' }}
  yAxis={{ label: '페이지' }}
  series={[
    {
      name: 'Organic',
      data: [
        { x: 22, y: 2 },
        { x: 41, y: 3 },
        { x: 55, y: 4 }
      ]
    }
  ]}
/>;
```

## 데이터 형식

`series`의 형태는 모든 차트가 공유합니다. 전체 정의는 [LineChart](./line-chart#데이터-형식)에 있습니다. 다만 여기에는 조건이 하나 더 있습니다. **모든 점이 `x`를 들고 있어야 하고**, 그 `x`는 숫자 또는 `Date`입니다. 여기서는 두 축이 모두 값을 재므로 숫자 하나짜리 datum은 놓일 자리가 없고, 문자열 `x`를 받은 점은 수직선 위에 없으므로 차트는 마크를 0에 늘어놓는 대신 빈 상태를 그립니다.

```ts
{ x: 22, y: 2 }              // dot
{ x: 22, y: 2, z: 180 }      // bubble
{ x: 22, y: null }           // 결측: 마크를 그리지 않고, 표의 칸도 비웁니다
```

점이 `x`를 직접 들고 있지 않으면 `categories`에서 index로 찾아 씁니다.

`z`는 선택이며 **넓이**로 읽힙니다. `z`가 없는 점은 `pointRadius`로 그려지고, 있는 점은 비율의 제곱근으로 `maxRadius` 아래에 맞춰집니다. 값이 네 배면 지름이 두 배인 bubble이 됩니다.

## Props

<PropsTable name="ScatterChart" />

`<div>`의 native 속성과 [Box](../surfaces/box)의 모든 prop이 그대로 전달됩니다. `xAxis`·`yAxis`·`legend`·`tooltip`은 [LineChart](./line-chart#props)와 같은 형태를 받습니다. 공용 축은 [prop 규약](../../design/prop-conventions)을 참고하세요.

## 예시

### bubble

점에 `z`가 있으면 bubble이 됩니다. `maxRadius`는 가장 큰 bubble의 반지름이고 나머지는 그 아래에 맞춰집니다. 생략하면 plot 짧은 변의 1/12입니다.

크기 기준은 모든 series에 걸쳐 한 번만 정해지고 범례를 걸러도 움직이지 않습니다. 그래서 크기가 같은 두 bubble은 어디에 있든 같은 숫자를 뜻합니다.

<Demo src="scatter-chart/bubble">

<<< @/.vitepress/demos/scatter-chart/bubble.tsx

</Demo>

### shape

산점도는 어떤 두 마크든 나란히 놓일 수 있는 형태이므로, 팔레트가 이웃한 쌍이 아니라 **모든 쌍**에서 구분되어야 합니다. 그렇게 검사하면 구분되는 것은 세 series까지입니다. 넷째부터는 `shape="auto"`가 series마다 다른 모양을 내어 줍니다. 순서는 circle, square, triangle, diamond, cross입니다. 범례에도 같은 모양이 나옵니다.

`shape="varied"`는 첫 series부터 모양을 나눕니다. 인쇄하거나 흑백으로 읽을 차트에 필요한 값입니다. 다섯 모양 중 하나를 직접 지정하면 모든 마크가 그 모양이 되는데, series가 넷 이상일 때 이것은 두 번째 채널을 포기하는 선택이므로 각 series가 자기 `color`를 들고 있을 때만 쓰세요.

<Demo src="scatter-chart/shape">

<<< @/.vitepress/demos/scatter-chart/shape.tsx

</Demo>

### xAxis · yAxis

여기서 x 축은 category 축이 아니라 값 축입니다. 눈금이 데이터가 아니라 반올림된 수에 놓이고, 격자선도 긋습니다. 마크의 x를 그림에서 읽어 내는 것이 이 차트를 보는 이유의 절반이기 때문입니다. `xAxis`의 `grid`를 `false`로 두면 끌 수 있습니다.

두 축 모두 0을 지나도록 강제하지 않습니다. 위치가 나타내는 것은 *자리*이므로 축을 잘라도 모든 마크가 같은 만큼 움직여 구름의 모양은 그대로 남습니다. 비교에 고정된 틀이 필요하면 `min`·`max`로 축을 고정하세요.

`format`은 값 축의 것이므로, x 눈금의 표기는 `xAxis.tickFormat`으로 정합니다.

<Demo src="scatter-chart/axes">

<<< @/.vitepress/demos/scatter-chart/axes.tsx

</Demo>

### tooltip

모아 보여 줄 공통 category가 없으므로 tooltip은 언제나 마크 하나에 대한 것입니다. 포인터는 자기 반지름에 24px을 더한 범위 안에서 가장 가까운 마크를 고르고, crosshair는 그리지 않습니다. 패널의 제목은 그 마크의 `x`이고 한 줄에 series와 `y`가 들어갑니다. 점이 `label`을 들고 있으면 값 대신 그것이 쓰이고, `tooltip.render`로 패널 전체를 대신 그릴 수 있습니다.

```tsx
<ScatterChart tooltip={{ render: ({ category, items }) => … }} … />
```

### 색

series의 팔레트 자리는 `series` 배열에서의 위치로 정해지므로, 범례를 걸러도 남은 series의 색은 그대로입니다. `series.color`는 그 자리를 [색 계열](../../design/color)이나 임의의 CSS 색으로 덮어쓰고, 점 자신의 `color`는 그 마크 하나만 덮어씁니다.

## 접근성

- 데이터는 `label`을 caption으로 하는 **화면에 보이지 않는 표**로도 렌더링됩니다. 점 하나가 한 행이고, 열 이름은 축 라벨에서 옵니다.
- plot에 focus할 수 있습니다. `←`·`→`로 데이터 순서대로 마크를 옮기고, `Home`·`End`로 양 끝으로, `Escape`로 tooltip을 해제합니다.
- series가 셋을 넘으면 색뿐 아니라 모양도 series를 구분합니다. 색각 이상이 있는 독자에게도, 흑백에서도, 인쇄물에서도 차트가 읽히는 것은 이 때문입니다.

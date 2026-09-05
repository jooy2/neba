---
title: AreaChart
order: 3
---

# AreaChart

<p class="neba-lede">선 아래를 채운 차트입니다. 합해서 의미가 있는 양을 나타낼 때, 그리고 stacked로는 그 합이 무엇으로 이루어져 있는지를 나타낼 때 씁니다.</p>

<Demo src="area-chart/hero" />

```tsx
import { AreaChart } from 'neba';

<AreaChart
  label="티어별 사용 스토리지"
  categories={['Jan', 'Feb', 'Mar']}
  stacked
  series={[
    { name: 'Hot', data: [120, 138, 149] },
    { name: 'Archive', data: [610, 648, 690] }
  ]}
/>;
```

데이터 형식은 모든 차트가 공유합니다. `series`와 `categories`, 그리고 0이 아니라 결측을 뜻하는 `null`입니다. 전체 정의는 [LineChart](./line-chart#데이터-형식) 문서에 있습니다.

둘 중 무엇을 쓸지는 그 양이 *무엇인지*로 갈립니다. 합해도 아무 뜻이 없는 값이라면(온도, 비율, 점수) 선 아래의 채움은 장식일 뿐이고, 그런 것이 두 개 겹치면 서로를 가릴 뿐입니다.

## Props

<PropsTable name="AreaChart" />

`<div>`의 native 속성과 [Box](../surfaces/box)의 모든 prop이 그대로 전달됩니다. `xAxis`·`yAxis`·`legend`·`tooltip`은 [LineChart](./line-chart#props)와 같은 형태를 받습니다. 공용 축은 [prop 규약](../../design/prop-conventions)을 참고하세요.

## 예시

### stacked

`false`는 밴드를 겹쳐 그려 "각각 얼마인가"에 답합니다. `true`는 쌓아서 위쪽 가장자리가 합계가 됩니다. `'full'`은 각 category를 100%로 정규화하므로 차트가 크기가 아니라 비중에 대한 것이 됩니다. 값 축이 백분율로 바뀌고 그렇다고 표시하며, tooltip에는 원래 숫자가 남습니다.

<Demo src="area-chart/stacked">

<<< @/.vitepress/demos/area-chart/stacked.tsx

</Demo>

### series가 하나일 때

series가 하나면 범례가 나오지 않습니다. 무엇을 그린 것인지는 카드의 제목이 이미 말하고 있고, 색 하나짜리 범례는 그 말을 반복할 뿐입니다.

<Demo src="area-chart/single">

<<< @/.vitepress/demos/area-chart/single.tsx

</Demo>

### curve · markers · connectNulls

[LineChart](./line-chart#curve)와 같은 세 prop이며 뜻도 같습니다. 다만 `markers`의 기본값은 `auto`가 아니라 `none`입니다. 채워진 밴드에는 이미 보이는 가장자리가 있습니다.

`connectNulls`는 선보다 area에서 더 중요합니다. 결측 구간을 가로질러 닫힌 채움은 없는 숫자를 훨씬 넓은 면적에 칠하는 일이기 때문입니다.

```tsx
<AreaChart curve="step" markers="all" connectNulls … />
```

### 값 축

LineChart와 달리 AreaChart는 값 축에 0을 남겨 둡니다. 채움의 두께가 곧 크기이므로, 축을 자르면 밴드의 높이가 아무 뜻도 갖지 못하게 됩니다. 이유가 있다면 `yAxis`의 `min`·`max`로 여전히 덮어쓸 수 있습니다.

## 접근성

- 데이터는 `label`을 caption으로 하는 **화면에 보이지 않는 표**로도 렌더링됩니다.
- plot에 focus할 수 있습니다. `←`·`→`로 category를 옮기고, `Home`·`End`로 양 끝으로, `Escape`로 해제합니다.
- `stacked="full"`일 때 tooltip과 표는 백분율이 아니라 넘긴 값을 그대로 보고합니다. 차트는 비중을 보여 주고, 원래 숫자에도 여전히 닿을 수 있습니다.

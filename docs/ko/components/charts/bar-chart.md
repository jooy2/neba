---
title: BarChart
order: 4
---

# BarChart

<p class="neba-lede">category 사이의 길이를 비교합니다. <em>얼마나</em>를 말하는 마크이며, category의 순서를 바꿔도 잃을 것이 없는 데이터에 씁니다.</p>

<Demo src="bar-chart/hero" />

```tsx
import { BarChart } from 'neba';

<BarChart
  label="팀별 배포 횟수"
  categories={['Platform', 'Payments', 'Growth']}
  series={[{ name: 'Deploys', data: [318, 264, 197] }]}
  valueLabels="all"
/>;
```

데이터 형식은 모든 차트가 공유합니다. `series`와 `categories`, 그리고 0이 아니라 결측을 뜻하는 `null`입니다. 전체 정의는 [LineChart](./line-chart#데이터-형식) 문서에 있습니다.

막대의 **길이**가 곧 값이므로, 값 축은 0에서 시작하며 그것은 협상 대상이 아닙니다. 축을 자르는 순간 두 배 긴 막대가 두 배를 뜻하지 않게 되기 때문입니다. category에 자연스러운 순서가 있고 변화의 모양이 핵심이라면 [LineChart](./line-chart)가 더 나은 마크입니다.

## Props

<PropsTable name="BarChart" />

`<div>`의 native 속성과 [Box](../surfaces/box)의 모든 prop이 그대로 전달됩니다. `xAxis`·`yAxis`·`legend`·`tooltip`은 [LineChart](./line-chart#props)와 같은 형태를 받습니다. 공용 축은 [prop 규약](../../design/prop-conventions)을 참고하세요.

## 예시

### orientation

category 이름이 단어라면 `horizontal`이 정답입니다. 세로 차트는 이름 하나에 막대 하나만큼의 너비를 주지만, 가로 차트는 한 열을 통째로 주고 읽는 순서도 목록과 같아집니다.

<Demo src="bar-chart/orientation">

<<< @/.vitepress/demos/bar-chart/orientation.tsx

</Demo>

### stacked

묶인 막대는 "여기서 어느 series가 더 큰가"에 답하고, 쌓인 막대는 "이 합계가 무엇으로 이루어져 있는가"에 답합니다. `'full'`은 모든 막대를 같은 길이로 정규화해 비중을 묻습니다. 값 축이 백분율이 되고 tooltip에는 원래 숫자가 남습니다.

서로 다른 질문이며, 하나의 차트에는 하나만 물어야 합니다.

<Demo src="bar-chart/stacked">

<<< @/.vitepress/demos/bar-chart/stacked.tsx

</Demo>

### 음수 값

반대 방향으로 자라는 막대도 다른 막대와 같은 0에서 시작합니다. 기준선은 plot의 바닥이 아니라 0이 있는 자리에 그려집니다.

점의 `color`는 그 막대 하나만 series 색을 덮어씁니다. series를 하나 더 쓰지 않고 특정 값을 표시하는 방법입니다.

<Demo src="bar-chart/negative">

<<< @/.vitepress/demos/bar-chart/negative.tsx

</Demo>

### valueLabels · rounded · barSize

`valueLabels="all"`은 LineChart와 달리 BarChart에서는 충분히 쓸 만합니다. 숫자가 붙은 막대 여덟 개는 차트이면서 동시에 표입니다. 열두 개를 넘어가면 둘 다 아니게 되고, 그때는 series의 최고·최저만 표시하는 `extremes`가 답입니다.

`rounded`는 막대의 **값 쪽 끝**만 둥글게 깎습니다. 기준선 쪽은 각진 채로 둡니다. `barSize`는 두께의 상한을 픽셀로 정합니다. 상한 아래에서는 막대가 자기 몫의 밴드를 채우고, 넘어가면 남은 자리는 여백이 됩니다. `density="compact"`는 그 몫을 넓힙니다.

```tsx
<BarChart valueLabels="extremes" rounded={false} barSize={12} density="compact" … />
```

## 접근성

- 데이터는 `label`을 caption으로 하는 **화면에 보이지 않는 표**로도 렌더링됩니다.
- plot에 focus할 수 있습니다. `←`·`→`(가로일 때는 `↑`·`↓`)로 category를 옮기고, `Home`·`End`로 양 끝으로, `Escape`로 해제합니다.
- 맞닿은 막대는 테두리가 아니라 2px의 표면 색 간격으로 분리됩니다. 차트 위에 데이터가 아닌 잉크는 없습니다.

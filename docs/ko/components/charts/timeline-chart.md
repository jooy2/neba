---
title: TimelineChart
order: 7
---

# TimelineChart

<p class="neba-lede">시간 위에 일을 놓는 차트입니다. 한 행에 하나씩, 그 위의 막대 하나가 하나의 기간입니다. 무엇이 어느 갈래에서 얼마나 오래 일어나는지를 보여 주는 Gantt 차트입니다.</p>

<Demo src="timeline-chart/hero" />

```tsx
import { TimelineChart } from 'neba';

<TimelineChart
  label="워크스트림별 릴리스 계획"
  series={[
    {
      name: 'Design',
      data: [{ start: new Date('2026-02-03'), end: new Date('2026-03-03'), label: 'Wireframes' }]
    }
  ]}
/>;
```

[Timeline](../display/timeline)과 다른 컴포넌트입니다. 그쪽은 축 없이 단계를 늘어놓는 목록으로 사건의 순서를 보여 주고, 이쪽은 달력 위에 기간을 그려 각각이 얼마나 걸렸는지를 보여 줍니다.

## 데이터 형식

행 하나가 series이고 그 안의 datum 하나가 span입니다. 다만 span은 `NebaChartPoint`가 아닙니다 — 축 위에 자리가 하나가 아니라 둘이므로 자기 타입을 따로 가집니다.

```ts
{ start: new Date('2026-03-02'), end: new Date('2026-03-16'), label: 'Wireframes' }
```

`start`와 `end`는 `Date` 또는 밀리초 숫자입니다. 앞뒤가 바뀌어 적힌 span도 제대로 그립니다.

한 행의 span들은 그 행을 함께 씁니다. 겹치는 것들은 서로 위에 그려지는 대신 각자 lane을 하나씩 받으므로, 두 가지를 동시에 하는 행은 둘 다 보입니다. 겹치지 않는 행은 원래 두께를 그대로 유지합니다.

<PropsTable name="NebaTimelinePoint" />

## Props

<PropsTable name="TimelineChart" />

`<div>`의 native 속성과 [Box](../surfaces/box)의 모든 prop이 그대로 전달됩니다. `legend`는 없습니다 — Gantt의 행은 그 자체가 축이고 이미 왼쪽에 이름이 쓰여 있습니다. 공용 축은 [prop 규약](../../design/prop-conventions)을 참고하세요.

## 예시

### min · max

그냥 두면 축은 span들에서 정해지고, 달력이 이름을 가진 날짜로 바깥쪽으로 반올림됩니다. `min`·`max`로 분기·스프린트·근무 시간에 고정할 수 있고, 축 밖으로 나가는 span은 축을 늘리는 대신 가장자리에서 잘립니다.

눈금 단위는 범위를 따라갑니다 — 초·분·시·일·주·월·분기·연. 하루짜리 차트는 정시마다 눈금을 찍습니다.

<Demo src="timeline-chart/range">

<<< @/.vitepress/demos/timeline-chart/range.tsx

</Demo>

### barSize · rounded · density

`barSize`는 막대가 두꺼워질 수 있는 한계이고, 그 아래에서는 막대가 행의 몫을 채웁니다. `density`는 그 몫만 바꿉니다. `rounded`는 span의 모서리를 깎는데, [BarChart](./bar-chart)와 달리 **양쪽 끝** 모두입니다 — span은 0에서 자라지 않으므로 기준이 되는 끝이 없습니다.

<Demo src="timeline-chart/bars">

<<< @/.vitepress/demos/timeline-chart/bars.tsx

</Demo>

### xAxis · yAxis

`xAxis`가 행 축이고 `yAxis`가 시간 축입니다. 모든 차트가 따르는 규칙과 같습니다 — 어느 방향으로 그리든 `xAxis`가 category 축, `yAxis`가 값 축입니다. 여기서 시간 축은 아래쪽에 그려지지만 여전히 `yAxis`입니다.

`yAxis.tickFormat`으로 눈금을 쓰고, `yAxis.tickCount`로 대략의 개수를 요청하며, `xAxis.hidden`으로 행 이름을 지웁니다.

```tsx
<TimelineChart yAxis={{ tickCount: 4 }} xAxis={{ label: 'Workstream' }} … />
```

### 색

행의 팔레트 자리는 `series` 배열에서의 위치로 정해집니다. `series.color`는 그 자리를 [색 계열](../../design/color)이나 임의의 CSS 색으로 덮어쓰고, span 자신의 `color`는 그 막대 하나만 덮어씁니다 — 일정이 밀린 하나가 스스로 그렇다고 말하는 방법입니다.

## 접근성

- 데이터는 `label`을 caption으로 하는 **화면에 보이지 않는 표**로도 렌더링됩니다. span 하나가 한 행이고, 그 행이 속한 행 이름 아래에 놓입니다.
- plot에 focus할 수 있습니다. `←`·`→`로 데이터 순서대로 span을 옮기고, `Home`·`End`로 양 끝으로, `Escape`로 tooltip을 해제합니다.
- 포인터는 중심이 가장 가까운 span이 아니라 **안에 들어와 있는** span을 고릅니다. 긴 막대의 hover를 옆의 짧은 막대가 가로채지 않습니다.

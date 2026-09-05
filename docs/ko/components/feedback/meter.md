---
title: Meter
order: 11
---

# Meter

<p class="neba-lede">사용한 디스크, 채워진 좌석, 소진한 할당량처럼 미리 정해진 범위 안에서 어떤 양이 얼마나 되는지를 보여 줍니다. 프로그레스 바처럼 보이지만 아닙니다. 값은 이미 알려져 있고, 그 값이 어디에 놓였는지가 곧 의미입니다.</p>

<Demo src="meter/hero" />

```tsx
import { Meter } from 'neba';

<Meter value={38} label="Storage" showValue />;
```

## Props

<PropsTable name="Meter" />

`<div>`의 기본 속성은 루트로 전달됩니다. 위 표에서 다르게 정의한 `color`와 `children`만 제외됩니다.

`value`는 필수이며, 이것이 [ProgressLinear](./progress-linear)와의 차이입니다. 프로그레스 바는 *시간*에 대한 것이라 값이 아예 없을 수도 있고 스스로 움직이는 것이 전제입니다. Meter는 *양*에 대한 것이라, 측정 대상이 변하지 않는 한 움직이지 않습니다.

### NebaThreshold

<PropsTable name="NebaThreshold" />

## 예시

### thresholds

막대의 색이 바뀌는 지점입니다. 각 항목은 스케일 위의 한 점과 그 지점부터 막대가 띠는 색 계열이며, 값이 도달한 마지막 항목이 이깁니다. 아무 것에도 도달하지 못했다면 `color`가 그대로 쓰입니다. `from`이 작은 것부터 나열하세요. 주어진 순서대로 읽습니다.

<Demo src="meter/thresholds">

<<< @/.vitepress/demos/meter/thresholds.tsx

</Demo>

### min · max · format

`showValue`는 라벨 옆에 값을 씁니다. `format`이 없으면 `min`…`max`에 대한 비율이고, 있으면 `Intl.NumberFormat`을 거친 숫자 그 자체입니다. Meter는 대개 실제 단위를 가지므로 이쪽이 일반적인 경우입니다.

<Demo src="meter/values">

<<< @/.vitepress/demos/meter/values.tsx

</Demo>

### size

`size`는 홈의 두께이며 ProgressLinear과 같은 사다리를 씁니다. 한 페이지에 둘이 함께 있어도 서로 어긋나지 않습니다.

<Demo src="meter/sizes">

<<< @/.vitepress/demos/meter/sizes.tsx

</Demo>

## 접근성

- 값과 범위 속성을 가진 `role="meter"`로 렌더링됩니다.
- `label`이 접근 가능한 이름이 되고, `aria-valuetext`는 화면에 찍히는 값과 같은 말을 합니다.
- 색이 유일한 전달 수단이 되지 않습니다. threshold를 넘은 막대는 길이도 더 길고, 표시된 값이 숫자를 말합니다.

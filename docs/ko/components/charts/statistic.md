---
title: Statistic
order: 8
---

# Statistic

<p class="neba-lede">이름 붙은 수치 하나를 보여 줍니다. 이전 값을 함께 주면 변화량을 계산해 옆에 표시합니다.</p>

<Demo src="statistic/hero" />

```tsx
import { Statistic } from 'neba';

<Statistic label="월 반복 매출" value={48210} prefix="$" previousValue={42800} />;
```

## Props

<PropsTable name="Statistic" />

`<div>`의 native 속성과 [Box](../surfaces/box)의 모든 prop이 그대로 전달됩니다. 변화량은 [Chip](../display/chip)으로 렌더링됩니다.

## 예시

### previousValue · delta · betterWhen

`previousValue`를 주면 현재 값과의 변화량이 계산되어 표시됩니다. `delta`는 그 변화를 비율로 쓸지, 차이로 쓸지, 둘 다 쓸지를 정합니다.

`betterWhen`은 어느 방향이 좋은 소식인지 알려 줍니다. 매출은 올라가는 쪽이, 이탈률은 내려가는 쪽이 좋으므로, 이 값이 없으면 변화량의 색을 정할 수 없습니다.

<Demo src="statistic/comparison">

<<< @/.vitepress/demos/statistic/comparison.tsx

</Demo>

수치와 변화량은 색과 함께 모양도 바뀝니다 — 상승 화살표, 하락 화살표, 변화가 없을 때는 짧은 선. 색만으로 방향을 표현하지 않습니다.

### icon · unit · caption · align

`icon`은 라벨 앞, `unit`은 수치 뒤에 놓입니다. `children`은 수치 아래 자리로, 목표 대비 [ProgressLinear](../feedback/progress-linear)나 [Sparkline](./sparkline)을 넣을 수 있습니다. `align="center"`는 여러 타일을 한 줄로 늘어놓을 때 씁니다.

`prefix`와 `unit`이 따로 있는 이유는 조판 위치가 다르기 때문입니다. 통화 기호는 숫자 앞, 단위는 뒤에 옵니다.

<Demo src="statistic/anatomy">

<<< @/.vitepress/demos/statistic/anatomy.tsx

</Demo>

### format

`format`은 `Intl.NumberFormat` 옵션으로 그대로 전달됩니다. 생략하면 읽는 사람의 locale에 맞춰 자릿수만 구분합니다. `value`에 문자열을 주면 서식을 적용하지 않고 그대로 출력하므로, 숫자가 아닌 수치도 표시할 수 있습니다.

```tsx
<Statistic label="매출" value={48210} format={{ style: 'currency', currency: 'KRW' }} />
<Statistic label="전환율" value={0.0423} format={{ style: 'percent', maximumFractionDigits: 1 }} />
<Statistic label="빌드 중앙값" value="3m 12s" />
```

`previousValue`가 `0`이면 비율을 계산할 수 없으므로, `delta` 설정과 무관하게 차이 값만 표시합니다.

---
title: Statistic
order: 8
---

# Statistic

<p class="neba-lede">이름이 붙은 숫자, 그리고 비교할 것이 있을 때는 그것이 얼마나 움직였는지까지.</p>

<Demo src="statistic/hero" />

```tsx
import { Statistic } from 'neba';

<Statistic label="월 반복 매출" value={48210} prefix="$" previousValue={42800} />;
```

[Card](../surfaces/card)가 그러하듯 배치 하나가 얹힌 [Box](../surfaces/box)입니다. 각 자리가 합성 서브컴포넌트가 아니라 prop인 이유는 Card가 대는 이유와 같습니다 — 순서는 변하지 않고, 쓰는 쪽이 정하고 싶은 것은 각 자리에 무엇이 들어가느냐입니다.

차이 표시는 색칠한 span이 아니라 [Chip](./chip)입니다. 이것이 옆의 나머지와 어울려 보이는 이유 전부입니다 — 라이브러리의 다른 곳이 쓰는 것과 같은 토큰이, 컨트롤 사다리에서 같은 한 칸 아래에, 같은 아크릴을 두르고 있습니다.

## Props

<PropsTable name="Statistic" />

`<div>`의 네이티브 속성과 [Box](../surfaces/box)의 모든 prop이 그대로 전달됩니다.

## 예시

### 비교

차이 표시를 믿을 수 있게 만드는 것은 `betterWhen`입니다. 아래 두 카드는 둘 다 _올랐지만_, 좋은 소식은 하나뿐이고 어느 쪽인지는 색이 말해 주어야 합니다. `delta`는 변화를 비율로 쓸지, 차이 그 자체로 쓸지, 둘 다 쓸지를 정합니다.

<Demo src="statistic/comparison">

<<< @/.vitepress/demos/statistic/comparison.tsx

</Demo>

수치와 차이 표시는 색만이 아니라 모양도 함께 지고 있습니다 — 올라가는 화살표, 내려가는 화살표, 움직이지 않은 수치를 위한 짧은 선. "내려갔다"를 빨강으로만 말하는 보고서는 빨강과 초록을 구분하지 못하는 독자에게는 아무것도 말하지 않습니다.

### 구성

라벨 앞의 아이콘, 수치 뒤의 단위, 그 아래에 무엇이든 — 목표 대비 [ProgressLinear](../feedback/progress-linear)나 스파크라인. `align="center"`는 한 줄로 늘어놓았을 때 하나의 띠로 읽혀야 하는 타일들을 위한 것입니다.

<Demo src="statistic/anatomy">

<<< @/.vitepress/demos/statistic/anatomy.tsx

</Demo>

### 형식

`format`은 `Intl.NumberFormat`에 그대로 넘어가며, [진행 표시기](../feedback/progress-linear)가 받는 것과 같은 prop입니다. 없으면 읽는 사람의 로케일대로 자릿수만 끊고 나머지는 그대로 둡니다. 문자열 `value`는 준 그대로 찍히는데, 애초에 숫자가 아닌 수치들을 위해서입니다.

```tsx
<Statistic label="매출" value={48210} format={{ style: 'currency', currency: 'KRW' }} />
<Statistic label="전환율" value={0.0423} format={{ style: 'percent', maximumFractionDigits: 1 }} />
<Statistic label="빌드 중앙값" value="3m 12s" />
```

`prefix`와 `unit`이 방향을 가진 하나의 장식이 아니라 두 개의 자리인 이유는 둘이 조판상 다른 것이고 늘 달랐기 때문입니다 — 통화 기호는 숫자 앞에 서고 단위는 뒤에 섭니다. 둘 다 있는 어느 로케일에서든 그렇습니다.

### 나눌 것이 없을 때

`previousValue`가 `0`일 때의 백분율은 큰 수가 아니라 정의되지 않은 수입니다. 그래서 비율은 버리고 차이 그 자체를 대신 씁니다. 지난달이 첫 달이었다는 이유로 `+∞%`를 보고하는 것은, 대시보드가 딱 한 번 하고 나면 아무도 다시 믿지 않게 되는 종류의 일입니다.

## Ant Design에서 옮겨올 때

| Ant | Neba |
| --- | --- |
| `title` | `label` — *값*의 이름이고, 그것이 라이브러리가 이미 `label`이라 부르는 것입니다 |
| `value` | 같습니다 |
| `precision={2}` | <code v-pre>format={{ minimumFractionDigits: 2, maximumFractionDigits: 2 }}</code> |
| `prefix` / `suffix` | `prefix` / `unit` |
| `valueStyle` | 없습니다. `color`, `size`, `variant`가 축입니다 |
| `<Statistic.Countdown />` | 없습니다. 형식을 맞춘 문자열을 `value`로 넘기고 직접 흘려보내세요 |
| — | `previousValue`, `delta`, `betterWhen` — Ant이 쓰는 쪽에 맡겨 두는 비교 |

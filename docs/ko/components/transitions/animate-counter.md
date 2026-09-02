---
title: AnimateCounter
order: 9
---

# AnimateCounter

<p class="neba-lede">숫자를 목표값까지 세어 올립니다. 라이브러리에서 유일하게 상자가 아니라 내용 자체가 주제인 애니메이션입니다. 매 프레임 값을 보간하고 형식을 입히는 일은 keyframe이 할 수 있는 것이 아닙니다.</p>

<Demo src="animate-counter/hero" minHeight="140" />

```tsx
import { AnimateCounter, Statistic } from 'neba';

<Statistic label="Monthly active" value={<AnimateCounter value={128400} />} />;
```

## Props

<PropsTable name="AnimateCounter" />

나머지 `<div>` 속성은 루트로 그대로 전달됩니다. `easing`, `repeat`, `alternate`는 없습니다. 숫자는 한쪽에서만 값에 다가갈 수 있으므로 곡선은 고정된 ease-out이고, 반복되는 카운트라는 것은 존재하지 않습니다.

[Statistic](../charts/statistic)과 짝을 이룹니다. 그쪽 `value`가 바로 이걸 위해 노드를 받습니다. 숫자는 즉시 그리면서 그 주변만 애니메이션하는 대시보드는 강조를 정확히 반대로 둔 것입니다.

## 예시

### format과 locale

`Intl.NumberFormat` 옵션입니다. 통화, 백분율, `1.2M` 같은 compact 표기가 `format` 콜백이 아니라 prop입니다. [Statistic](../charts/statistic)과 진행 표시기들이 받는 것과 같은 prop입니다.

<Demo src="animate-counter/formats" minHeight="240">

<<< @/.vitepress/demos/animate-counter/formats.tsx

</Demo>

### trigger

화면 아래쪽 대시보드에서 손이 가는 것은 `trigger="visible"`입니다. 스크롤해서 닿았을 때 이미 끝나 있는 카운트는 본 적이 없는 것과 같습니다. 시작 전에는 정답이 아니라 `from`에 머뭅니다.

```tsx
<AnimateCounter value={128400} trigger="visible" />
```

## 접근성

- 완성된 숫자는 첫 프레임부터 스크린 리더를 위해 잘린 상자 안에 들어 있고, 세는 것은 `aria-hidden`인 사본입니다. 볼 수 없는 독자는 중간값 백 개가 아니라 답을 듣습니다.
- 모션 감소 설정에서는 곧바로 답을 보여 줍니다.

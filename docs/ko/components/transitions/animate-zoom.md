---
title: AnimateZoom
order: 9
---

# AnimateZoom

<p class="neba-lede">놓일 자리의 한가운데에서 다가오는 효과입니다. AnimateGrow와 같은 계산을 두 배 넘는 거리로, 언제나 중심을 기준으로 실행합니다. 화면에서 한 번은 시선을 끊어야 하는 그 하나를 위한 것입니다.</p>

<Demo src="animate-zoom/hero" />

```tsx
import { AnimateZoom } from 'neba';

<AnimateZoom>
  <Statistic label="이번 분기 가동률" value={99.98} unit="%" />
</AnimateZoom>;
```

## Props

<PropsTable name="AnimateZoom" />

나머지 `<div>` 속성은 모두 루트로 전달됩니다. 모든 `Animate*`가 공유하는 설정은 [Prop 규약](../../design/prop-conventions)에 있습니다.

`origin`은 없습니다. 모서리에 고정된 zoom은 grow이고, 그것은 [AnimateGrow](./animate-grow)입니다.

## 예시

### from

시작 배율입니다. `1`보다 한참 작으면 아무것도 없던 자리에서 솟아오르고, `1`보다 크면 커진 채로 등장해 제자리로 물러납니다. 후자는 페이지에서 솟는 것이 아니라 읽는 사람 쪽으로 다가오는 것처럼 읽힙니다.

<Demo src="animate-zoom/strength">

<<< @/.vitepress/demos/animate-zoom/strength.tsx

</Demo>

### trigger="visible"

zoom이 가장 흔히 쓰이는 자리는 독자가 다다르는 순간 놓이는 수치입니다. `threshold`는 요소가 화면에 얼마나 들어와야 하는지를 `0`에서 `1` 사이로 정하고, 기본으로 켜져 있는 `once`가 페이지를 되돌릴 때마다 다시 재생되는 것을 막습니다.

<Demo src="animate-zoom/visible">

<<< @/.vitepress/demos/animate-zoom/visible.tsx

</Demo>

### mode

`out`은 다시 멀어지며 끝에서 멈춥니다.

```tsx
<AnimateZoom mode="out" duration={240}>
  <Card title="닫힘">이 카드는 나가는 중입니다.</Card>
</AnimateZoom>
```

## 접근성

- 축소된 모션 설정에서는 애니메이션이 통째로 꺼지고 내용은 원래 크기로 그냥 거기 있습니다.
- 넓은 면적에 걸친 강한 zoom은 이 묶음에서 모션에 민감한 독자를 가장 괴롭히기 쉬운 효과입니다. 화면의 상당 부분을 덮는 것에는 작은 `from`이나 fade를 쓰세요.

---
title: AnimateReveal
order: 9
---

# AnimateReveal

<p class="neba-lede">가장자리가 지나가며 내용을 드러냅니다. 아무것도 움직이지 않고 색도 변하지 않습니다. 내용은 이미 제자리에 온전한 크기로 있고, 바뀌는 것은 그중 얼마만큼이 통과되었는가입니다.</p>

<Demo src="animate-reveal/hero" />

```tsx
import { AnimateReveal } from 'neba';

<AnimateReveal>
  <h2>움직인 것이 아니라 통과된 것입니다</h2>
</AnimateReveal>;
```

## Props

<PropsTable name="AnimateReveal" />

나머지 `<div>` 속성은 루트로 그대로 전달됩니다. 모든 `Animate*`가 공유하는 설정은 [prop 규약](../../design/prop-conventions)에 있습니다.

`clip-path`라서 래퍼도 `overflow` 상자도 없습니다. 요소는 늘 차지하던 자리를 그대로 차지하고, 주변은 첫 프레임부터 완성된 크기를 기준으로 배치됩니다. 그래서 제목, 구분선, 차트의 플롯 영역처럼 **위치 자체가 정보인** 것에 쓰기 좋습니다.

## 예시

### side

지우개가 지나오는 변입니다. 기본값 `left`는 왼쪽에서 오른쪽으로 드러냅니다.

<Demo src="animate-reveal/sides" minHeight="260">

<<< @/.vitepress/demos/animate-reveal/sides.tsx

</Demo>

### from

닦이면서 함께 페이드할 시작 투명도입니다. 기본값 `1`은 순수한 wipe이고, 보통 이 효과를 고르는 이유가 그것입니다. `0`을 주면 둘 다 합니다.

### mode

`mode="out"`은 같은 가장자리를 거꾸로 돌려 그 자리에서 멈춥니다. 내용을 다시 덮습니다.

### stagger

`stagger`, `durationStep`, `reverse`는 상자 대신 자식 하나하나에게 효과를 차례로 넘깁니다. 동작은 [AnimateFade](./animate-fade)와 같고, 그쪽 페이지에 자세히 적혀 있습니다.

## 접근성

- 모션 감소 설정에서는 애니메이션이 꺼지고 내용이 통째로 그려집니다. 어차피 도달할 상태입니다.
- 내용은 처음부터 끝까지 문서에도 접근성 트리에도 있습니다. clip은 픽셀을 가리는 것이지 정보를 가리는 것이 아닙니다.

---
title: AnimateAppear
order: 9
---

# AnimateAppear

<p class="neba-lede">여러 개가 하나씩 차례로 제자리에 내려앉는 효과입니다. 자식마다 같은 짧은 fade와 미끄러짐이 자기 순서만큼 늦춰져 실행되므로, 효과가 개별 항목이 아니라 묶음 전체에 속합니다.</p>

<Demo src="animate-appear/hero" />

```tsx
import { AnimateAppear } from 'neba';

<AnimateAppear className="flex flex-col gap-2">
  <Card title="디자인 리뷰">목요일 14:00</Card>
  <Card title="스프린트 계획">금요일 10:00</Card>
</AnimateAppear>;
```

## Props

<PropsTable name="AnimateAppear" />

나머지 `<div>` 속성은 모두 루트로 전달됩니다. 모든 `Animate*`가 공유하는 설정은 [Prop 규약](../../design/prop-conventions)에 있습니다.

애니메이션은 자식을 감싸는 래퍼가 아니라 자식 자신에게 쓰입니다. 그래서 `<li>`의 나열은 그대로 `<li>`의 나열로 남고, grid의 셀은 그대로 직계 자식으로 남습니다. 글자만 있는 자식만은 쓸 요소가 없으므로 `<span>`으로 감쌉니다.

## 예시

### stagger

자식 하나와 다음 자식 사이의 간격(밀리초)입니다. 이 효과 자체이며, 나머지는 자식 하나가 하는 일입니다.

간격은 *자식*마다 매겨지므로 무엇을 넘기는지가 중요합니다. 자식 여덟은 여덟 걸음이고, 여덟 개를 담은 자식 하나는 한 걸음입니다. 목록의 일부를 효과에서 빼는 방법도 그것입니다 — 묶으면 됩니다.

<Demo src="animate-appear/stagger">

<<< @/.vitepress/demos/animate-appear/stagger.tsx

</Demo>

### from, distance, reverse

`from`은 각 자식이 밀려 들어오는 변이고 `distance`는 이동 거리입니다. 짧은 것은 의도한 것으로, 이것은 화면 밖에서의 등장이 아니라 제자리에 내려앉는 움직임이기 때문입니다. `reverse`는 마지막 자식부터 실행합니다.

<Demo src="animate-appear/direction">

<<< @/.vitepress/demos/animate-appear/direction.tsx

</Demo>

### trigger="visible"

가장 자연스러운 조합입니다. 독자가 다다르는 순간 한 번 내려앉는 내용 묶음. 전체가 루트의 observer 하나를 공유하므로 마흔 개짜리 목록도 observer는 하나입니다.

<Demo src="animate-appear/visible">

<<< @/.vitepress/demos/animate-appear/visible.tsx

</Demo>

## 접근성

- 축소된 모션 설정에서는 애니메이션이 통째로 꺼지고 목록 전체가 그냥 거기 있습니다.
- 래퍼는 role도 이름도 더하지 않습니다. 목록이 정말 목록이라면 `render`로 진짜 요소를 주세요 — `render={<ul />}`.

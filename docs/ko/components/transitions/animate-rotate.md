---
title: AnimateRotate
order: 9
---

# AnimateRotate

<p class="neba-lede">한 점을 축으로 회전하는 효과입니다. 각도를 하나가 아니라 둘 받으므로, 제자리에 안착하는 회전과 끝내 멈추지 않는 회전을 같은 컴포넌트로 표현합니다.</p>

<Demo src="animate-rotate/hero" />

```tsx
import { AnimateRotate } from 'neba';

<AnimateRotate from={-270}>
  <Icon icon={<StarIcon />} size="xl" color="warning" label="즐겨찾기" />
</AnimateRotate>;
```

## Props

<PropsTable name="AnimateRotate" />

나머지 `<div>` 속성은 모두 루트로 전달됩니다. 모든 `Animate*`가 공유하는 설정은 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### from과 to

`from`만 있으면 도착입니다. 무언가 돌아 들어와 멈춥니다. `from`과 `to`를 함께 쓰고 `repeat="infinite"`, `easing="linear"`, `fade={false}`를 더하면 끝내 착지하지 않는 회전이 됩니다 — 작업 중 표시, 장식용 글리프 같은 것들입니다. 음수 각도는 반시계 방향입니다.

<Demo src="animate-rotate/spin">

<<< @/.vitepress/demos/animate-rotate/spin.tsx

</Demo>

### origin

CSS `transform-origin` 그대로입니다. 중심을 벗어나면 회전이 아니라 흔들림이 되고, `alternate`와 함께 쓰면 좌우로 흔들리는 움직임이 됩니다.

<Demo src="animate-rotate/origin">

<<< @/.vitepress/demos/animate-rotate/origin.tsx

</Demo>

### fade

기본으로 켜져 있고, 반복하는 경우 가장 먼저 꺼야 할 것입니다. 회전이 한 바퀴 돌 때마다 실행되는 fade는 회전이 아니라 깜빡임으로 읽힙니다.

```tsx
<AnimateRotate from={0} to={360} repeat="infinite" easing="linear" fade={false}>
  <Icon icon={<GearIcon />} label="작업 중" />
</AnimateRotate>
```

## 접근성

- 축소된 모션 설정에서는 애니메이션이 통째로 꺼지고 내용은 `to` 각도에 그냥 놓입니다.
- 텍스트는 회전시키지 마세요. 회전한 낱말은 길이 전체가 다시 그려지는데, 그것이 바로 디자인 언어가 transform을 금지하며 막으려는 것입니다. 회전은 글리프를 위한 것입니다.

---
title: AnimateSlide
order: 9
---

# AnimateSlide

<p class="neba-lede">한쪽 변에서 미끄러져 들어오는 효과입니다. 기본 이동 거리가 요소 자신의 크기이므로 정확히 화면 밖에서 출발하며, 있어서는 안 될 자리에 반쯤 그려지는 일이 없습니다.</p>

<Demo src="animate-slide/hero" />

```tsx
import { AnimateSlide } from 'neba';

<div className="overflow-hidden">
  <AnimateSlide from="left">
    <Alert color="success" title="초대를 보냈습니다" />
  </AnimateSlide>
</div>;
```

## Props

<PropsTable name="AnimateSlide" />

나머지 `<div>` 속성은 모두 루트로 전달됩니다. 모든 `Animate*`가 공유하는 설정은 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### from

어느 변에서 들어오는지 — `top`, `right`, `bottom`, `left`입니다. 라이브러리의 다른 곳에서 `NebaSide`가 그렇듯 논리적이 아니라 물리적입니다. 위에서 내려오는 패널은 어떤 쓰기 방향에서도 위에서 내려옵니다.

`overflow: hidden`인 상자 안에 넣으면 그 상자의 변 뒤에서 패널이 나타나는 효과가 됩니다.

<Demo src="animate-slide/edges">

<<< @/.vitepress/demos/animate-slide/edges.tsx

</Demo>

### distance

CSS 길이 또는 픽셀 수입니다. 기본값 `'100%'`는 요소 자신의 너비 또는 높이입니다. 짧은 거리는 등장이 아니라 살짝 미는 정도이고, 그런 것을 목록 전체에 하나씩 걸고 싶다면 [AnimateAppear](./animate-appear)를 쓰세요.

<Demo src="animate-slide/distance">

<<< @/.vitepress/demos/animate-slide/distance.tsx

</Demo>

### mode

`out`은 왔던 길로 되돌려 보내고 화면 밖에서 멈춥니다.

```tsx
<AnimateSlide mode="out" from="right">
  <Toolbar>…</Toolbar>
</AnimateSlide>
```

## 접근성

- 축소된 모션 설정에서는 애니메이션이 통째로 꺼지고 내용은 제자리에 그냥 있습니다.
- 요소는 `translate`로 움직이므로 재생되는 동안 페이지의 레이아웃이 다시 계산되지 않고, 아래의 어떤 것도 밀려나지 않습니다.

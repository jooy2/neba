---
title: AnimateFloat
order: 9
---

# AnimateFloat

<p class="neba-lede">도착할 곳 없이 천천히 떠다닙니다. 일러스트나 떠 있는 카드, 히어로 위의 마크처럼 페이지에 고정되어 있지 않은 것에 쓰며, 페이지가 열려 있는 동안 계속됩니다.</p>

<Demo src="animate-float/hero" />

```tsx
import { AnimateFloat } from 'neba';

<AnimateFloat>
  <Card>페이지에 고정되어 있지 않습니다.</Card>
</AnimateFloat>;
```

## Props

<PropsTable name="AnimateFloat" />

나머지 `<div>` 속성은 루트로 그대로 전달됩니다. 모든 `Animate*`가 공유하는 설정은 [prop 규약](../../design/prop-conventions)에 있습니다.

무한히 반복하며 양 끝에서 방향을 돌리므로 되돌아 튀는 프레임이 없습니다. `mode`는 없습니다. 표류에는 거꾸로 돌릴 방향이 없습니다.

`transform`이 아니라 `translate`라서, 요소에 이미 걸린 scale이나 rotate와 합성됩니다.

## 예시

### from과 distance

`from`은 떠 가는 방향이고 `distance`는 얼마나 가는지입니다. CSS 길이나 픽셀 숫자를 받습니다. 일부러 짧습니다. 1cm를 넘어가면 쉬고 있는 것이 아니라 움직이는 것으로 읽히기 시작합니다.

<Demo src="animate-float/distance" minHeight="300">

<<< @/.vitepress/demos/animate-float/distance.tsx

</Demo>

### stagger

`stagger`는 떠 있는 여러 개를 서로 어긋나게 만듭니다. 넷이 한 덩어리로 읽히지 않게 하는 것이 이 값입니다. 동작은 [AnimateFade](./animate-fade)와 같습니다.

### paused

`paused`는 언마운트 없이 표류를 그 자리에 붙들어 둡니다.

## 접근성

- 모션 감소 설정에서는 애니메이션이 꺼지고 내용은 레이아웃이 놓아 준 자리에 그대로 있습니다.
- 컨트롤을 띄우지 마세요. 늘 있던 자리에 정확히 있지 않은 것은 누르기 어렵고, 이 효과는 세트에서 유일하게 끝이 없습니다.

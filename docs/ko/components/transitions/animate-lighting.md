---
title: AnimateLighting
order: 9
---

# AnimateLighting

<p class="neba-lede">무언가의 바깥을 도는 빛입니다. 광채가 내용 위가 아니라 뒤에 있으므로, 감싼 것이 그려지는 방식을 하나도 바꾸지 않으면서 그것을 표시합니다.</p>

<Demo src="animate-lighting/hero" />

```tsx
import { AnimateLighting } from 'neba';

<AnimateLighting size="md">
  <Card title="4,281개 행 분석 중">보통 1분쯤 걸립니다.</Card>
</AnimateLighting>;
```

## Props

<PropsTable name="AnimateLighting" />

나머지 `<div>` 속성은 모두 루트로 전달됩니다. 모든 `Animate*`가 공유하는 설정은 [Prop 규약](../../design/prop-conventions)에 있습니다.

`size`는 안에 든 것의 반경과 맞아야 합니다. 광채는 래퍼 자신의 모서리를 따라가므로, `xs` Lighting 안에 `lg` 카드를 넣으면 카드가 이미 깎아 낸 네 모서리에서 빛이 삐져나옵니다.

## 예시

### color와 glow

`color`는 여섯 의미론적 색 중 하나입니다. `glow`는 대신 CSS 색상을 받아, 상태가 아니라 장식으로서의 빛을 만듭니다.

<Demo src="animate-lighting/colors">

<<< @/.vitepress/demos/animate-lighting/colors.tsx

</Demo>

### arc, spread, blur

`arc`는 한 번에 밝아지는 윤곽의 길이를 도로 정합니다. 작으면 스치고 지나가는 불꽃, 크면 훑고 지나가는 빛입니다. `spread`는 내용 바깥으로 빛이 얼마나 번지는지, `blur`는 얼마나 부드러운지입니다. `0`이면 빛이 아니라 도형처럼 읽힙니다.

<Demo src="animate-lighting/shape">

<<< @/.vitepress/demos/animate-lighting/shape.tsx

</Demo>

### trigger="hover"

무한히 반복하는 효과에 `hover`를 걸면 포인터가 올라가 있는 동안 재생되고 떠나면 멈춥니다. 키보드 focus도 포인터로 세므로 마우스 없이도 닿습니다.

<Demo src="animate-lighting/hover">

<<< @/.vitepress/demos/animate-lighting/hover.tsx

</Demo>

## 접근성

- 축소된 모션 설정에서는 호가 돌기를 멈추고 고른 광채가 됩니다. 장식은 살아남고 움직임은 사라집니다.
- 그래서 빛만으로 진행 상태를 전달해서는 안 됩니다. "분석 중", "실시간" 같은 문구와 함께 쓰고, 문구를 대신하는 용도로는 쓰지 마세요.
- 래퍼는 role도 이름도 더하지 않습니다.

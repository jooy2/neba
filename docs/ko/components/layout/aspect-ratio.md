---
title: AspectRatio
order: 4
---

# AspectRatio

<p class="neba-lede">어떤 너비를 받아도 비율을 지키는 상자입니다. 스스로는 아무것도 그리지 않고, 자리를 잡아 두고 그 안의 것을 형태에 붙잡아 둡니다.</p>

<Demo src="aspect-ratio/hero" align="center" />

```tsx
import { AspectRatio } from 'neba';

<AspectRatio ratio={16 / 9} rounded>
  <img src={src} alt="낮은 해 아래의 능선" />
</AspectRatio>;
```

## Props

<PropsTable name="AspectRatio" />

`<div>`의 기본 속성은 그대로 전달되며, `render`로 요소를 바꿀 수 있습니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

## 예시

### ratio

`ratio`는 CSS의 `aspect-ratio` 그 자체입니다. 숫자(`1.5`)든 비(`'16 / 9'`)든 손대지 않고 그대로 전달되므로 옮겨 적을 것이 없습니다.

<Demo src="aspect-ratio/ratios">

<<< @/.vitepress/demos/aspect-ratio/ratios.tsx

</Demo>

### fit

`fit`은 직계 자식인 미디어 하나 — `img`, `video`, `canvas`, `svg`, `iframe` — 에 적용되는 `object-fit`입니다. 미디어는 먼저 상자에 맞게 늘어나는데, 이 컴포넌트를 쓸 때마다 반드시 먼저 쓰게 되는 선언 두 줄이 바로 그것입니다. `cover`는 잘라내고, `contain`은 여백을 남기며, `fill`은 찌그러뜨립니다.

<Demo src="aspect-ratio/fit">

<<< @/.vitepress/demos/aspect-ratio/fit.tsx

</Demo>

### 자리 잡아 두기

내용이 도착했든 아니든 비율은 그대로이므로, AspectRatio 안의 [Skeleton](../feedback/skeleton)은 이미지가 차지할 바로 그 상자를 차지합니다. 이미지가 로드되어도 아래의 무엇도 움직이지 않습니다.

<Demo src="aspect-ratio/reserving">

<<< @/.vitepress/demos/aspect-ratio/reserving.tsx

</Demo>

### rounded

`rounded`는 `size` 단계의 반경 사다리로 모서리를 깎습니다. 레이아웃 컴포넌트는 아무것도 그리지 않으므로 기본은 꺼짐이며, 이것이 유일한 예외입니다. 카드 안의 사진은 거의 언제나 이것을 원하기 때문입니다.

```tsx
<AspectRatio ratio={4 / 3} rounded size="lg">
  <img src={src} alt="" />
</AspectRatio>
```

## 접근성

- 이 상자는 role도 이름도 더하지 않습니다. 형태일 뿐이고, 읽히는 것은 그 안에 든 것입니다.
- 안의 `img`에는 여전히 자기 `alt`가 필요합니다. 장식용 이미지는 `alt=""`를 씁니다.

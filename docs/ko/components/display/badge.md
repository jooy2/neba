---
title: Badge
order: 6
---

# Badge

<p class="neba-lede">다른 요소의 모서리에 겹쳐 놓는 작은 표식입니다. 읽지 않은 개수나 현재 상태를 원래 요소를 가리지 않고 알릴 때 씁니다.</p>

<Demo src="badge/hero" />

```tsx
import { Badge, Button } from 'neba';

<Badge content={4} label="읽지 않은 알림 4개">
  <Button startIcon={<BellIcon />} />
</Badge>

<Badge dot color="success" overlap="circle">
  <Avatar />
</Badge>;
```

## Props

<PropsTable name="Badge" />

`children`을 주면 그것을 감싸는 `<span>`이 positioning context가 되고 표식은 그 모서리에 붙습니다. `children` 없이 쓰면 표식 자체가 inline 요소로 놓이므로, 표 안의 상태 표시처럼 단독으로도 쓸 수 있습니다.

공통 축(`variant` `size` `color` `density` `elevation`)의 의미는 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### variant와 color

`solid`는 채운 표식, `outline`은 테두리와 옅은 panel, `text`는 배경만 얇게 깔린 형태입니다. `color`는 여섯 가지 역할 색 중 하나를 고릅니다.

<Demo src="badge/variants">

<<< @/.vitepress/demos/badge/variants.tsx

</Demo>

### content와 max

`content`가 표식에 들어갈 내용입니다. 숫자가 `max`(기본 `99`)를 넘으면 `99+`로 표시되고, 문자열은 자르지 않습니다.

`content`가 `0`이면 기본적으로 그리지 않습니다. `showZero`로 켤 수 있습니다. 셀 것은 없지만 알릴 것이 있을 때는 `dot`으로 점만 찍고, `invisible`은 레이아웃을 유지한 채 표식만 감춥니다.

<Demo src="badge/content">

<<< @/.vitepress/demos/badge/content.tsx

</Demo>

### placement와 overlap

`placement`는 표식이 붙을 모서리입니다. `top`/`bottom`과 `start`/`end`를 조합한 네 값이며, `start`/`end`를 쓰기 때문에 RTL에서는 좌우가 자동으로 뒤집힙니다.

`overlap`은 감싼 요소의 모양입니다. `circle`은 원의 모서리가 bounding box보다 안쪽에 있는 만큼 표식을 더 당겨서, 아바타 위에서도 표식이 떠 보이지 않게 합니다.

<Demo src="badge/placement">

<<< @/.vitepress/demos/badge/placement.tsx

</Demo>

### size

Badge는 컨트롤 높이 단계를 쓰지 않고 자체 단계를 씁니다. `md`가 18px이며, 두 자리 숫자가 읽히는 가장 작은 크기입니다.

<Demo src="badge/sizes">

<<< @/.vitepress/demos/badge/sizes.tsx

</Demo>

## 접근성

- `content={3}`만 있으면 screen reader에는 "3"으로 읽힙니다. `label`에 문장을 주면 그 문장이 표식의 accessible name이 됩니다.

```tsx
<Badge content={3} label="읽지 않은 알림 3개">
  <Button startIcon={<BellIcon />} aria-label="알림" />
</Badge>
```

- `dot`일 때도 `content`는 DOM에 남아 시각적으로만 가려지므로, 점이 무엇을 뜻하는지 읽을 수 있습니다.
- `invisible`이거나 표시할 내용이 없으면 DOM에서도 제거됩니다. 화면에 없는 표식의 글자가 find-on-page에 잡히지 않습니다.

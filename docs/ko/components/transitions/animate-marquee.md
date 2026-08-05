---
title: AnimateMarquee
order: 9
---

# AnimateMarquee

<p class="neba-lede">내용이 끝없이 한쪽으로 흘러가는 효과입니다. 내용을 두 벌 깔고 각 벌이 정확히 자기 길이만큼 이동하므로, 이음매도 없고 띠가 비는 프레임도 없습니다.</p>

<Demo src="animate-marquee/hero" />

```tsx
import { AnimateMarquee } from 'neba';

<AnimateMarquee speed={45} gap="1.5rem">
  {customers.map((name) => (
    <Chip key={name}>{name}</Chip>
  ))}
</AnimateMarquee>;
```

## Props

<PropsTable name="AnimateMarquee" />

나머지 `<div>` 속성은 모두 루트로 전달됩니다. 모든 `Animate*`가 공유하는 설정은 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### speed와 reverse

띠 자신의 너비를 재어 계산하는 초당 픽셀입니다. 그래서 로고 네 개와 마흔 개가 같은 속도로 흐르고, 긴 쪽이 흐릿해지지 않습니다. `duration`도 받으며 측정값보다 우선합니다. `reverse`는 반대 방향으로 흘립니다.

<Demo src="animate-marquee/speed">

<<< @/.vitepress/demos/animate-marquee/speed.tsx

</Demo>

### orientation

`vertical`은 띠를 가로가 아니라 세로로 흘립니다. 로그나 활동 피드에 씁니다. 흐를 자리가 있으려면 상자에 높이가 있어야 합니다.

<Demo src="animate-marquee/vertical">

<<< @/.vitepress/demos/animate-marquee/vertical.tsx

</Demo>

### pauseOnHover

기본으로 켜져 있고, 장식이 아닙니다. 포인터 앞을 지나가는 내용은 안정적으로 클릭할 수 없고, 멈추지 않는 띠 안의 링크는 아무도 따라갈 수 없는 링크입니다.

<Demo src="animate-marquee/pause">

<<< @/.vitepress/demos/animate-marquee/pause.tsx

</Demo>

### copies와 gap

`gap`은 항목 사이의 간격이자, 한 바퀴의 마지막 항목과 다음 바퀴의 첫 항목 사이의 간격입니다. `copies`는 내용을 몇 번 이어 붙이는지입니다. 컨테이너만큼 넓은 내용이라면 둘이면 충분하고, 내용이 짧아 뒤에 빈 구간이 생길 때 올리면 됩니다.

```tsx
<AnimateMarquee copies={4} gap="3rem">
  <Chip>짧은 항목 하나</Chip>
</AnimateMarquee>
```

## 접근성

- 첫 번째 벌만 읽힙니다. 나머지는 `aria-hidden`인데, 그렇지 않으면 스크린 리더가 띠 전체를 깔린 횟수만큼 읽게 됩니다.
- 축소된 모션 설정에서는 띠가 멈추고 내용은 제자리에 놓입니다.
- `pauseOnHover`가 그 안의 상호작용 요소를 쓸 수 있게 만드는 것입니다. 링크나 버튼이 든 띠에서는 끄지 마세요.

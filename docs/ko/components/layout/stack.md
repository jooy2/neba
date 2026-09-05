---
title: Stack
order: 11
---

# Stack

<p class="neba-lede">여러 항목을 서로 겹쳐 놓아 한 줄이 아니라 하나의 더미로 읽히게 합니다. 한 작업에 붙은 얼굴들, 한 벌의 카드, 책상 위의 서류처럼 항목 하나하나보다 전체 개수가 중요한 자리를 위한 것입니다.</p>

<Demo src="stack/hero" />

```tsx
import { Avatar, Stack } from 'neba';

<Stack ring>
  <Avatar name="Jane Doe" />
  <Avatar name="Kim Minji" />
</Stack>;
```

## Props

<PropsTable name="Stack" />

모든 네이티브 `<div>` 속성이 그대로 전달됩니다. 자체 표면을 그리지 않으므로 `variant`, `color`, `elevation`은 없습니다. 그것은 쌓이는 대상의 몫입니다.

겹침은 translate가 아니라 margin이라, 상자 크기가 내용과 정확히 일치하고 Stack 뒤에 오는 내용도 올바른 너비를 기준으로 배치됩니다. `size`는 `overlap`의 기본값을 정할 때에만 읽습니다.

각 항목은 자기 래퍼 안에 그려지고 자식은 손대지 않은 채 통과합니다. 그래서 무엇이든 쌓을 수 있습니다. 아바타를 감싼 [Tooltip](../feedback/tooltip)이든, 다른 컴포넌트의 `.map()`이 만들어 낸 것이든. 자식에 직접 쓰는 것은 `ring` 하나뿐인데, 실선은 그것이 두르는 모양을 따라가야 하기 때문입니다.

공통 축은 [prop 규약](../../design/prop-conventions)을 보세요.

## 예시

### direction

기본값 `horizontal`은 inline 축을 따라 더미를 쌓고, `vertical`은 아래로 내려갑니다. `diagonal`은 `horizontal`처럼 옆으로 흐르면서 `drop`만큼 한 칸씩 내려앉습니다. 부채처럼 펼쳐진 카드 더미입니다.

<Demo src="stack/direction" minHeight="260">

<<< @/.vitepress/demos/stack/direction.tsx

</Demo>

### overlap과 drop

`overlap`은 더미가 흐르는 축에서 각 항목이 앞선 항목 아래로 들어가는 거리입니다. CSS 길이나 픽셀 숫자를 받습니다. 지정하지 않으면 `size`의 일정 비율입니다. `drop`은 나머지 한 축이고, 두 축으로 움직이는 것은 `diagonal`뿐이라 그것만 읽습니다. 기본값은 `overlap`입니다.

### scaleStep, opacityStep, front

`scaleStep`은 앞 항목 대비 배율을 곱합니다. `0.94`면 한 단계마다 6%씩 작아져 더미가 뒤로 물러납니다. `opacityStep`은 투명도에 같은 일을 합니다. `front`는 어느 쪽 끝이 맨 앞인지 정합니다. 기본값 `first`라서 더미를 앞쪽 가장자리부터 읽으면 앞에서 뒤 순서로 읽힙니다.

<Demo src="stack/depth" minHeight="280">

<<< @/.vitepress/demos/stack/depth.tsx

</Demo>

### max, total, overflow

`max`는 나머지가 더미 맨 뒤의 항목 하나로 합쳐지기 전까지 그려지는 개수입니다. `total`은 전체 개수로, 앞의 몇 개만 넘겨받은 더미를 위한 것입니다. `overflow`는 들어가지 못한 개수를 받아 그 자리를 대신할 것을 돌려줍니다.

```tsx
<Stack max={3} total={12} overflow={(hidden) => <Avatar initials={`+${hidden}`} />}>
```

### transition과 stagger

`transition`은 라이브러리 공통 등장 애니메이션 어휘이고, 각 항목에 적용됩니다. `stagger`는 항목마다 지연을 그만큼(ms) 더해 더미가 한꺼번에 나타나는 대신 한 장씩 놓이게 만듭니다. `durationStep`은 재생 시간에 같은 일을 하고, `reverse`는 마지막 항목부터 실행합니다.

<Demo src="stack/dealt" minHeight="320">

<<< @/.vitepress/demos/stack/dealt.tsx

</Demo>

## 접근성

- Stack은 `<div>`이고 아무것도 알리지 않습니다. 더미가 한 무리를 뜻한다면(작업에 붙은 사람들, 폴더 안의 파일들) `role`과 이름을 주거나 개수를 옆에 글로 적으세요.
- overflow 표시도 평범한 항목으로 그려지므로 거기서 렌더링한 것이 그대로 읽힙니다. `+38` 하나로는 전달되는 것이 거의 없으니 나머지는 `aria-label`로 적어 주세요.

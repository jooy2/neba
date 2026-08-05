---
title: AnimateBlink
order: 9
---

# AnimateBlink

<p class="neba-lede">완전한 불투명도와 정해진 바닥값 사이를 오가며 맥동하는 효과입니다. 주기가 대칭이므로 몇 번을 반복하든 시작한 자리에서 끝납니다.</p>

<Demo src="animate-blink/hero" />

```tsx
import { AnimateBlink } from 'neba';

<AnimateBlink min={0.35}>
  <Chip color="danger" variant="solid">
    녹화 중
  </Chip>
</AnimateBlink>;
```

## Props

<PropsTable name="AnimateBlink" />

나머지 `<div>` 속성은 모두 루트로 전달됩니다. 모든 `Animate*`가 공유하는 설정은 [Prop 규약](../../design/prop-conventions)에 있습니다.

`mode`는 없습니다. 주기가 양쪽 방향으로 같으므로 거꾸로 재생한다는 말에 담길 뜻이 없습니다.

## 예시

### min

주기의 바닥에서 얼마나 흐려지는지를 `0`에서 `1` 사이로 정합니다. `0`이면 내용이 사라집니다. 맥동하는 동안에도 읽혀야 하는 것 — 대부분이 그렇습니다 — 은 이 값을 올리세요.

<Demo src="animate-blink/floor">

<<< @/.vitepress/demos/animate-blink/floor.tsx

</Demo>

### repeat

따로 말하지 않으면 끝없이 반복합니다. 한 번뿐인 깜박임은 효과가 아니라 화면 결함이기 때문입니다. 횟수를 정하는 것은 한 번 시선을 끌기 위한 용도입니다 — 세 번 맥동하고 멈춥니다.

<Demo src="animate-blink/counted">

<<< @/.vitepress/demos/animate-blink/counted.tsx

</Demo>

### paused

`paused`는 애니메이션을 있는 자리에 붙들어 둡니다. 실시간 표시를 unmount하지 않고 멈추는 방법입니다.

```tsx
<AnimateBlink paused={!recording} min={0.35}>
  <Chip color="danger">녹화 중</Chip>
</AnimateBlink>
```

## 접근성

- 축소된 모션 설정에서는 애니메이션이 통째로 꺼지고 내용은 완전한 불투명도로 놓입니다.
- 그래서 깜박임이 메시지를 혼자 지고 있어서는 안 됩니다. 말로도 하세요 — "녹화 중"이라고 적힌 `Chip`은 맥동하든 하지 않든 그렇게 말합니다.
- 읽고 있는 페이지의 한구석에서 멈추지 않고 움직이는 것은 이 라이브러리가 다른 곳에서는 거부하는 종류의 모션입니다. 정말로 살아 있는 상태에만 쓰고, 그 상태가 끝나면 멈추세요.

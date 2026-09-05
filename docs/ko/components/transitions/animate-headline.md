---
title: AnimateHeadline
order: 9
---

# AnimateHeadline

<p class="neba-lede">한 줄이 위의 줄을 밀어내며 교체되는 효과입니다. 모든 줄이 같은 grid 칸에 놓이므로 상자는 첫 프레임부터 가장 긴 줄만큼 높고, 릴이 도는 동안 크기가 변하지 않습니다.</p>

<Demo src="animate-headline/hero" />

```tsx
import { AnimateHeadline } from 'neba';

<AnimateHeadline interval={2000}>
  <span>빠른</span>
  <span>조용한</span>
  <span>당신의</span>
</AnimateHeadline>;
```

## Props

<PropsTable name="AnimateHeadline" />

나머지 `<div>` 속성은 모두 루트로 전달됩니다. 모든 `Animate*`가 공유하는 설정은 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### interval과 duration

`interval`은 한 줄이 머무는 시간이며, 주기의 시작이 아니라 그 줄이 도착한 순간부터 셉니다. 그래서 전환 자체의 길이인 `duration`을 늘려도 읽는 시간이 조용히 깎이지 않습니다.

<Demo src="animate-headline/breaking">

<<< @/.vitepress/demos/animate-headline/breaking.tsx

</Demo>

### 제어하기

`index`를 넘기면 릴은 스스로 돌지 않고, 넘긴 값에 따라 줄을 바꿉니다. 폼의 단계나 tab, 직접 만든 타이머가 그 값을 정합니다. `onIndexChange`는 방금 올라온 줄을 알립니다.

<Demo src="animate-headline/controlled">

<<< @/.vitepress/demos/animate-headline/controlled.tsx

</Demo>

### loop와 rise

`loop`를 끄면 릴은 마지막 줄에서 멈추고 거기 머뭅니다. `rise`는 한 줄이 올라오거나 나가며 이동하는 거리입니다. 기본값 `'100%'`는 한 줄 자신의 높이이고, 더 작은 값은 교체가 아니라 살짝 밀어 올리는 정도가 됩니다.

```tsx
<AnimateHeadline loop={false} rise="0.4rem">
  <span>업로드 중…</span>
  <span>처리 중…</span>
  <span>완료</span>
</AnimateHeadline>
```

## 접근성

- 지금 보이는 줄만 접근성 트리에 있습니다. 나머지는 `visibility: hidden`이라 자리는 지키면서 읽는 순서에는 들어가지 않습니다.
- 릴이 돌 때 아무것도 알리지 않습니다. 2초마다 바뀌는 live region은 쓸 수 없으므로 의도한 동작입니다. 그래서 이 컴포넌트는 어느 것이어도 상관없는 문구 묶음에 쓰고, 독자가 반드시 봐야 하는 내용에는 쓰지 마세요.
- 축소된 모션 설정에서는 전환이 사라집니다. 줄은 여전히 바뀌지만 미끄러지는 대신 그냥 나타납니다.

---
title: AnimateScramble
order: 9
---

# AnimateScramble

<p class="neba-lede">노이즈를 뚫고 글자가 하나씩 자리를 잡습니다. AnimateTyping의 형제입니다. 타자기는 빈 줄에서 문자열을 드러내고, 이것은 이미 제 길이인 줄에서 문자열을 해석해 냅니다.</p>

<Demo src="animate-scramble/hero" minHeight="120" />

```tsx
import { AnimateScramble } from 'neba';

<AnimateScramble text="RESOLVING SIGNAL" />;
```

## Props

<PropsTable name="AnimateScramble" />

나머지 `<div>` 속성은 루트로 그대로 전달됩니다. 모든 `Animate*`가 공유하는 설정은 [prop 규약](../../design/prop-conventions)에 있습니다.

상자 크기가 한 번도 변하지 않습니다. [AnimateTyping](./animate-typing) 대신 이 컴포넌트를 고르는 이유가 여기에 있습니다. 주변이 재배치되지 않고, 제목이 내려앉으면서 페이지를 밀어내지 않습니다.

공백은 절대 섞이지 않습니다. 공백이 글자로 깜빡였다 돌아오면 단어가 움직인 것처럼 읽히는데, 이 효과는 바로 그것을 피하려고 있는 것입니다.

## 예시

### speed, duration, tick

`speed`는 초당 몇 글자가 정착하는지입니다. `duration`은 전체 실행 시간이고 주어지면 그쪽이 이깁니다. 글자당 지연이 거기서 나오므로 같은 것을 두 번 물어보지 않습니다. `tick`은 아직 정착하지 않은 글자를 다시 그리는 주기인데, 30ms 아래로 내려가면 글자로 읽히지 않습니다.

<Demo src="animate-scramble/pool" minHeight="240">

<<< @/.vitepress/demos/animate-scramble/pool.tsx

</Demo>

### characters

정착하지 않은 글자를 뽑아 올 풀입니다. 높이를 하나로 맞추세요. 크고 작은 글자가 섞인 풀은 정착하는 동안 줄을 튀게 만듭니다.

## 접근성

- 완성된 문자열은 첫 프레임부터 스크린 리더를 위해 잘린 상자 안에 있고, 노이즈는 `aria-hidden`인 사본입니다.
- 모션 감소 설정에서는 곧바로 텍스트를 보여 줍니다.
- 독자가 빨리 반응해야 하는 것에는 쓰지 마세요. 끝나야만 읽힙니다.

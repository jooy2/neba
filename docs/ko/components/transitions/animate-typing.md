---
title: AnimateTyping
order: 9
---

# AnimateTyping

<p class="neba-lede">글자가 하나씩 나타나는 효과입니다. 문자열 전체는 첫 프레임부터 스크린 리더를 위해 문서 안에 있고, 움직이는 것은 스크린 리더에게 숨겨진 사본입니다.</p>

<Demo src="animate-typing/hero" />

```tsx
import { AnimateTyping } from 'neba';

<AnimateTyping speed={18}>디자인 시스템이 아니라 화면을 배포하세요.</AnimateTyping>;
```

## Props

<PropsTable name="AnimateTyping" />

나머지 `<div>` 속성은 모두 루트로 전달됩니다. 모든 `Animate*`가 공유하는 설정은 [Prop 규약](../../design/prop-conventions)에 있습니다.

타이핑되는 것은 텍스트뿐입니다. 문자열 하나 또는 여럿을 넘기세요. 자식 중 요소가 있으면 그 안의 글자만 쓰이고 마크업은 반영되지 않습니다. 링크의 절반을 정직하게 드러낼 방법이 없기 때문입니다. `text`는 같은 것을 prop으로 받는 것이고, 둘 다 주면 이쪽이 이깁니다.

## 예시

### speed

초당 글자 수입니다. 시간이 아니라 속도인 이유는, 긴 줄과 짧은 줄이 같은 시간이 아니라 같은 속도로 쓰여야 하기 때문입니다. `duration`도 받으며, 그 경우에는 문자열 전체를 쓰는 데 걸리는 시간을 뜻합니다.

<Demo src="animate-typing/speed">

<<< @/.vitepress/demos/animate-typing/speed.tsx

</Demo>

### repeat, hold, erase

`repeat`은 몇 번 반복하는지, `hold`는 다 쓴 글이 다음 반복까지 얼마나 머무는지입니다. `erase` 없이 반복하면 한 프레임에 지워지는데, 교체되는 줄에는 그쪽이 맞습니다. 켜면 `eraseSpeed`로 한 글자씩 지웁니다 — 기본값은 `speed`의 두 배이고, 사람이 실제로 그렇게 합니다.

<Demo src="animate-typing/loop">

<<< @/.vitepress/demos/animate-typing/loop.tsx

</Demo>

### delay

시작 전 대기 시간(밀리초)입니다. 줄마다 delay를 주면 여러 개의 타자기가 하나의 기록이 됩니다.

<Demo src="animate-typing/terminal">

<<< @/.vitepress/demos/animate-typing/terminal.tsx

</Demo>

### caret

글자 뒤의 커서로, 기본으로 켜져 있습니다. `caretChar`가 그 모양을 정합니다 — `▌`, `_`, 무엇이든 됩니다.

```tsx
<AnimateTyping caretChar="▌" caret={false}>
  커서 없음
</AnimateTyping>
```

## 접근성

- 전체 텍스트는 첫 프레임부터 잘린 상자 안에 들어 있고, 움직이는 사본은 `aria-hidden`입니다. 스크린 리더는 그 줄을 한 번 읽고 공연을 끝까지 지켜보지 않습니다.
- 축소된 모션 설정에서는 문자열 전체가 즉시 보이고 타이핑은 일어나지 않습니다.
- 상자의 크기는 지금까지 도착한 글자로 정해지지 않으므로, 주변 텍스트가 매 프레임 다시 배치되지 않습니다.
- 글자는 code point가 아니라 grapheme 단위로 셉니다. `한`도 `👩‍👩‍👧`도 세 걸음이나 일곱 걸음이 아니라 한 걸음에 도착합니다.

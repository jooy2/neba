---
title: AnimateSplit
order: 9
---

# AnimateSplit

<p class="neba-lede">한 줄의 글이 단어씩 — 또는 글자씩 — 도착합니다. AnimateAppear가 목록을 자식 하나씩 내려간다면, 이것은 문장을 따라 걸어갑니다.</p>

<Demo src="animate-split/hero" minHeight="140" />

```tsx
import { AnimateSplit } from 'neba';

<AnimateSplit render={<h1 />}>한 단어씩 도착하는 문장</AnimateSplit>;
```

## Props

<PropsTable name="AnimateSplit" />

나머지 `<div>` 속성은 루트로 그대로 전달됩니다. 모든 `Animate*`가 공유하는 설정은 [prop 규약](../../design/prop-conventions)에 있습니다.

쪼개지는 것은 텍스트뿐입니다. 문자열이나 `text`를 넘기세요. children 안의 element는 그 안의 단어만 기여하고 markup은 전달되지 않습니다. 링크의 절반을 애니메이션할 정직한 방법은 없기 때문입니다.

각 조각은 `inline-block`입니다. inline 상자는 위로 옮길 수 없으니까요. 그리고 각 조각이 뒤따르던 공백을 함께 가지므로, 줄은 여전히 단어 사이에서 나뉘고 공백 안에서 끊기지 않습니다.

## 예시

### by와 effect

`by`는 조각 하나가 무엇인지입니다. 기본값은 `word`인데, 여덟 단어짜리 제목은 상자 여덟 개이고 같은 제목을 글자로 쪼개면 마흔여섯 개이기 때문입니다. `effect`는 각 조각이 어떤 애니메이션으로 도착하는지이며 라이브러리 공통 어휘를 씁니다. 그래서 쪼개진 제목의 fade와 [AnimateFade](./animate-fade)는 같은 fade입니다.

<Demo src="animate-split/by" minHeight="280">

<<< @/.vitepress/demos/animate-split/by.tsx

</Demo>

### stagger

`stagger`는 한 조각 뒤 다음 조각이 시작하기까지의 간격이고, 이 효과를 이루는 것이 바로 그것입니다. 기본값은 45ms. `durationStep`은 뒤의 조각일수록 재생 시간을 늘리고, `reverse`는 줄을 끝에서부터 실행합니다.

### locale

경계를 찾을 언어입니다. 일본어·태국어·중국어에서 단어 경계는 공백이 아니고, 그런 글을 공백으로 쪼개면 문장 전체를 담은 조각 하나가 나옵니다.

## 접근성

- 문장 전체가 스크린 리더를 위해 잘린 상자 안에 한 번 들어 있고, 조각들은 접근성 트리에서 숨겨집니다. 그러지 않으면 문장이 마흔여섯 개의 낱글자 목록으로 읽히고 페이지 내 찾기로는 아무것도 걸리지 않습니다.
- 모션 감소 설정에서는 애니메이션이 꺼지고 줄이 통째로 그려집니다.

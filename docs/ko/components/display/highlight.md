---
title: Highlight
order: 11
---

# Highlight

<p class="neba-lede">이미 읽고 있던 글 안에서, 찾고 있던 단어에 표시를 합니다.</p>

<Demo src="highlight/hero" />

```tsx
import { Highlight } from 'neba';

<Highlight query="acrylic">A sheet of cut acrylic.</Highlight>
<Highlight query={['data', 'database']} variant="text" color="primary">…</Highlight>
<Highlight query={/\d+/} caseSensitive>…</Highlight>;
```

## Props

<PropsTable name="Highlight" />

## 스타일이 아니라 검색입니다

`query`는 검색창이 들고 있는 그 값이고, **어떻게** 맞출지 — 대소문자, 단어 단위, 정규식 — 는 전부 prop입니다. 호출하는 쪽이 오프셋 배열을 미리 계산해서 넘길 일이 없습니다. 상태도 측정도 없어서, 컴포넌트 전체가 `children`과 `query`의 순수 함수입니다. 검색창이 바뀌면 알아서 다시 표시합니다.

`size`가 없는 것은 빠뜨린 것이 아닙니다. 표식은 흐르는 글 안에 앉아 있으므로 그 글과 같은 크기여야 하고, `size` prop은 틀릴 방법만 제공하게 됩니다.

## 예시

### 표식의 모양

`variant`는 다른 곳과 똑같이 표면의 무게를 말합니다. `solid`는 형광펜, `outline`은 단어를 두르는 얇은 선, `text`는 색만. `underline`과 `weight`는 그 위에 겹쳐지는 별개의 축입니다.

`color`가 `warning`인 것은 임의가 아닙니다. 채움이 밝고 잉크가 어두운 유일한 계열이라 — [색](../../guide/color)에서 그 이유를 볼 수 있습니다 — `solid warning` 표식이 검은 글자 위의 노란 형광펜처럼 읽힙니다. 나머지 계열은 흰 글자에 색 블록이 됩니다.

<Demo src="highlight/variants">

<<< @/.vitepress/demos/highlight/variants.tsx

</Demo>

### 무엇을 맞출지

<Demo src="highlight/matching">

<<< @/.vitepress/demos/highlight/matching.tsx

</Demo>

배열은 **긴 것부터** 시도합니다. 정규식의 선택(`|`)은 먼저 맞는 쪽이 이기므로, 그러지 않으면 `['data', 'database']`가 `data`만 잡고 `base`를 표식 밖에 남깁니다.

`wholeWord`에서 단어란 어떤 문자 체계에서든 글자·숫자·밑줄의 연속입니다. `café`와 `naïve`에서 옳게 동작하고, 띄어쓰기로 구획되지 않는 한국어나 일본어에서는 거의 아무 의미가 없습니다. 그것은 이 prop의 문제가 아니라 문자 체계의 성질이고, 기본값이 꺼짐인 이유이기도 합니다.

### 요소 안의 글

대부분의 라이브러리는 `children`이 문자열이어야 한다고 요구하고, 그 방식은 `<strong>`이 들어 있는 첫 번째 검색 결과에서 깨집니다. 여기서는 트리를 걸어 들어가면서 글만 표시하고 나머지는 그대로 둡니다.

<Demo src="highlight/nested">

<<< @/.vitepress/demos/highlight/nested.tsx

</Demo>

## 접근성

표식은 진짜 `<mark>`입니다. "읽는 사람에게 관련이 있는 부분"을 뜻하는 요소이고, 그렇게 읽힙니다. 여기에는 알아 둘 만한 결과가 하나 따라옵니다. 한 문단에서 열한 단어를 표시하면 스크린 리더에게 중요한 것이 열한 개라고 말하는 셈이고, 그것은 아무 말도 안 한 것과 같습니다. 하이라이트는 몇 개를 위한 것입니다.

`<mark>`는 브라우저 기본 스타일시트에서 노란 배경과 검은 잉크를 달고 옵니다. 그래서 `variant="text"`도 배경을 `transparent`라고 **명시**합니다. "표면 없음"은 소리 내어 말하지 않으면 브라우저의 표면이 되어 버립니다.

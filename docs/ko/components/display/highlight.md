---
title: Highlight
order: 11
---

# Highlight

<p class="neba-lede">텍스트 안에서 검색어와 일치하는 부분에 표시를 합니다. 검색 결과 목록이나 필터링된 목록에서 무엇이 걸렸는지 보여 줄 때 씁니다.</p>

<Demo src="highlight/hero" />

```tsx
import { Highlight } from 'neba';

<Highlight query="acrylic">A sheet of cut acrylic.</Highlight>
<Highlight query={['data', 'database']} variant="text" color="primary">…</Highlight>
<Highlight query={/\d+/} caseSensitive>…</Highlight>;
```

## Props

<PropsTable name="Highlight" />

`query`에는 검색창이 들고 있는 값을 그대로 넘깁니다 — 문자열, 문자열 배열, 정규식. 일치 지점을 미리 계산할 필요는 없습니다. 상태를 갖지 않으므로 `children`과 `query`가 바뀌면 표시도 함께 갱신됩니다.

`size`는 없습니다. 표식은 흐르는 텍스트 안에 놓이므로 주변 글자 크기를 그대로 따릅니다.

## 예시

### variant · underline · weight

`variant`는 표식의 무게입니다. `solid`는 형광펜처럼 채우고, `outline`은 단어를 얇은 선으로 두르고, `text`는 색만 바꿉니다. `underline`과 `weight`는 그 위에 겹쳐 쓰는 별개의 축입니다.

기본 `color`는 `warning`입니다. 채움이 밝고 잉크가 어두운 유일한 계열이라 `solid`에서 노란 형광펜처럼 읽힙니다. 다른 계열은 색 블록 위의 흰 글자가 됩니다.

<Demo src="highlight/variants">

<<< @/.vitepress/demos/highlight/variants.tsx

</Demo>

### caseSensitive와 wholeWord

`caseSensitive`는 대소문자를 구분하고, `wholeWord`는 단어 경계에서만 일치시킵니다. 여기서 단어는 글자·숫자·밑줄의 연속이므로, 띄어쓰기로 단어를 구획하지 않는 한국어나 일본어에서는 효과가 거의 없습니다 — 기본값이 꺼짐인 이유입니다.

문자열 배열은 **긴 것부터** 시도합니다. `['data', 'database']`를 짧은 쪽부터 맞추면 `data`만 잡히고 `base`가 표식 밖으로 남기 때문입니다.

<Demo src="highlight/matching">

<<< @/.vitepress/demos/highlight/matching.tsx

</Demo>

### 중첩된 요소 안의 텍스트

`children`은 문자열일 필요가 없습니다. React 트리를 따라 내려가면서 텍스트 노드만 표시하고 나머지 요소는 그대로 둡니다.

<Demo src="highlight/nested">

<<< @/.vitepress/demos/highlight/nested.tsx

</Demo>

## 접근성

- 표식은 실제 `<mark>` 요소로 렌더링됩니다. "읽는 사람에게 관련이 있는 부분"이라는 의미가 함께 전달되므로, 한 문단에서 너무 많은 단어를 표시하면 그 의미가 희석됩니다.
- `<mark>`는 브라우저 기본 스타일시트에서 노란 배경을 갖고 옵니다. 그래서 `variant="text"`도 `background`를 `transparent`로 명시합니다.

---
title: Blockquote
order: 9
---

# Blockquote

<p class="neba-lede">남의 말을 내 말과 구분해 놓는 자리입니다. 표면보다 마크업이 먼저인 컴포넌트입니다.</p>

<Demo src="blockquote/hero" />

```tsx
import { Blockquote } from 'neba';

<Blockquote>완벽함이란 더 보탤 것이 없을 때가 아니라 더 뺄 것이 없을 때 이루어진다.</Blockquote>

<Blockquote author="생텍쥐페리" source="인간의 대지">
  완벽함이란 더 보탤 것이 없을 때가 아니라 더 뺄 것이 없을 때 이루어진다.
</Blockquote>;
```

## Props

<PropsTable name="Blockquote" />

## 마크업

인용에는 상태도, 키보드 계약도, 상호작용할 것도 없습니다. 대신 **틀리기 쉬운 마크업**이 있고, 그것을 맞게 쓰는 것이 이 컴포넌트의 대부분입니다.

출처가 없으면 `<blockquote>` 하나입니다. 출처가 있으면 전체가 이렇게 바뀝니다.

```html
<figure>
  <blockquote cite="…">…</blockquote>
  <figcaption>— 저자, <cite>출처</cite></figcaption>
</figure>
```

HTML 명세는 출처가 인용문 **바깥**에 있어야 한다고 못박습니다. 안에 넣으면 화자가 자기 이름을 말했다고 주장하는 셈이기 때문입니다. 그리고 `<cite>`는 작품의 제목을 위한 요소이지 사람 이름을 위한 요소가 아니므로, `author`는 `<cite>` 밖에 놓입니다.

`cite` prop은 인용을 가져온 문서의 URL로, `<blockquote>`의 `cite` 속성이 됩니다. 이것은 기계만 읽습니다. 사람에게 보여 줄 출처는 `source`입니다.

## 예시

### 무게

`text`가 기본이고, 실제로 글 속의 인용은 여백에 선 하나가 전부입니다 — 표면이라는 것이 생기기 훨씬 전부터 인용은 그렇게 생겼습니다. 나머지 둘은 인용이 그 절의 주인공일 때를 위한 것입니다.

<Demo src="blockquote/variants">

<<< @/.vitepress/demos/blockquote/variants.tsx

</Demo>

### 출처

`author`만, `source`만, 또는 둘 다. 어느 쪽이든 있기만 하면 `<figure>`가 됩니다.

<Demo src="blockquote/attribution">

<<< @/.vitepress/demos/blockquote/attribution.tsx

</Demo>

### 색

시트는 물들지 않습니다. [Box](../surfaces/box)와 [List](./list)가 그러는 것과 같은 이유입니다 — 인용은 남의 말을 담고 있고, 그 말은 아무도 골라 주지 않은 배경 위에 놓여서는 안 됩니다. 색은 여백의 선과 인용부호에만 나타납니다.

<Demo src="blockquote/colors">

<<< @/.vitepress/demos/blockquote/colors.tsx

</Demo>

## 인용부호는 그린 것입니다

기본으로 붙는 표식은 타이포그래피의 `“`가 아니라 그림입니다. 진짜 따옴표는 페이지가 쓰는 서체를 따라가므로 모양도, 굵기도, 베이스라인도 함께 바뀝니다 — 그리고 2em짜리 이것은 컴포넌트 안에서 가장 큰 글리프이므로, 바뀌면 가장 눈에 띄게 바뀝니다.

`icon`은 한 prop으로 세 가지를 말합니다. 생략하면 기본 글리프, 노드를 넘기면 교체, `false`면 없앱니다. [Alert](../feedback/alert)가 같은 생각을 같은 방식으로 씁니다.

## `<blockquote>`에는 아무것도 그리지 않습니다

표면도, 선도, 여백도 전부 그 **바깥** 요소가 그립니다. 정리벽이 아니라 특이성 때문입니다.

`blockquote`는 호스트 스타일시트가 아직도 태그 이름으로 스타일하는 몇 안 되는 요소입니다. 이 문서 사이트만 해도 VitePress의 `.vp-doc blockquote`가 회색 `border-left`와 `padding-left`와 `color`를 지정하며, 클래스 하나짜리 유틸리티로는 이길 수 없는 특이성입니다. 인용문 자체에 선을 그렸다면 조용히 회색으로, 1픽셀 얇게 나왔을 것입니다. 그림을 래퍼로 옮겨 두었기에 문서 쪽 `scope.css`가 VitePress의 것만 걷어내고 우리 것은 건드리지 않을 수 있습니다.

[Table](./table)이 셀 스타일을 인라인으로 쓰는 것과 같은 문제이고, 다른 해법입니다. 표의 셀은 컴포넌트가 호스트를 **이겨야** 하므로 인라인으로 갔고, 인용은 다툴 자리에서 **비켜설** 수 있으므로 비켜섰습니다.

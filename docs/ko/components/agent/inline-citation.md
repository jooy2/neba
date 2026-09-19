---
title: InlineCitation
order: 7
---

# InlineCitation

<p class="neba-lede">답 본문에 놓이는 번호 각주이며, 포인터를 올리면 그 뒤의 출처가 올라옵니다. 표시는 Sources의 줄이 그리는 것과 같은 사각형이라, 문장에서 2를 본 독자가 아래 목록에서 2를 찾습니다.</p>

<Demo src="inline-citation/hero" />

```tsx
import { InlineCitation } from 'neba';

<InlineCitation index={1} title="The design language" site="neba.cdget.com" href="/design" />;
```

## Props

<PropsTable name="InlineCitation" />

`<a>`의 기본 속성은 표시로 전달됩니다. 위 표에서 다르게 정의한 `color`, `title`, `children`만 제외됩니다.

## 예시

### index

여기서 세는 번호가 아니라 호출하는 쪽의 번호입니다. 인용은 문단 안에 있고 가리키는 목록은 페이지의 다른 곳에 있으므로, 번호를 매겨 줄 부모가 없습니다. 렌더 순서로 스스로 번호를 매기는 컴포넌트라면 문장 하나가 자리를 옮길 때마다 답 전체의 번호가 바뀝니다.

이 숫자는 표시가 말하는 전부이기도 합니다. 그래서 접근 가능한 이름은 숫자가 아니라 "Source 2"라는 문장입니다.

### preview

켜져 있고 [HoverCard](../surfaces/hover-card)가 그리므로, hover뿐 아니라 focus에서도 열리고 표시와 카드 사이의 틈을 건널 수 있습니다. `title`이 있어야 합니다. 보여 줄 것이 없는 인용은 그냥 링크이며, 그런 것에 카드를 켜면 포인터 아래에서 빈 상자가 열립니다.

<Demo src="inline-citation/preview">

<<< @/.vitepress/demos/inline-citation/preview.tsx

</Demo>

### href

진짜 링크이며, [Sources](./sources)의 줄과 같은 스킴 검사를 거칩니다. `http`, `https`, `mailto`, `tel` 밖의 주소는 URL을 그대로 쓰는 대신 표시를 평범한 텍스트로 남깁니다. 탭을 벗어나는 `target`에는 `rel="noopener noreferrer"`가 붙습니다.

### color · size

표시는 `em` 단위로 크기가 정해지고 `color`에서 색을 받으므로, 어떤 크기로 조판된 문장에 끼어들든 그 문장을 따라갑니다. `size`는 표시가 아니라 미리보기의 타입 스케일입니다.

일부러 `<sup>`이 아닙니다. 위첨자는 이미 `0.8em`인 표시를 한 번 더 줄이고, 그 크기에서 색이 깔린 상자 안의 숫자는 독자가 누를 수 있는 것이 아니라 얼룩입니다.

<Demo src="inline-citation/color">

<<< @/.vitepress/demos/inline-citation/color.tsx

</Demo>

## 접근성

- 표시에는 "Source 2"처럼 단어로 된 접근 가능한 이름이 붙습니다. 숫자 하나만으로는 스크린 리더에 아무 뜻도 전달되지 않기 때문입니다.
- 미리보기는 Base UI의 hover card이므로 포인터뿐 아니라 키보드 포커스에서도 열립니다.

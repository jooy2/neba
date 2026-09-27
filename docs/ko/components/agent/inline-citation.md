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

표시에 나오는 번호입니다. 표시는 스스로 세지 않으므로, 가리키는 목록에서 그 출처의 번호를 넘기세요.

접근 가능한 이름은 숫자가 아니라 "Source 2"라는 문장입니다.

### preview

켜져 있고 [HoverCard](../surfaces/hover-card)가 그리므로, hover뿐 아니라 focus에서도 열리고 표시와 카드 사이의 틈을 건널 수 있습니다. `title`이 있어야 합니다. 보여 줄 것이 없는 인용은 그냥 링크이며, 그런 것에 카드를 켜면 포인터 아래에서 빈 상자가 열립니다.

<Demo src="inline-citation/preview">

<<< @/.vitepress/demos/inline-citation/preview.tsx

</Demo>

### href

진짜 링크이며, [Sources](./sources)의 줄과 같은 스킴 검사를 거칩니다. `http`, `https`, `mailto`, `tel` 밖의 주소는 URL을 그대로 쓰는 대신 표시를 평범한 텍스트로 남깁니다. 탭을 벗어나는 `target`에는 `rel="noopener noreferrer"`가 붙습니다.

### color · size

표시는 `em` 단위로 크기가 정해지고 `color`에서 색을 받으므로, 어떤 크기로 조판된 문장에 끼어들든 그 문장을 따라갑니다. `size`는 표시가 아니라 미리보기의 타입 스케일입니다.

표시는 위첨자가 아닙니다. `0.8em` 크기로 줄 위에 놓이고 조금 올라가 있습니다.

<Demo src="inline-citation/color">

<<< @/.vitepress/demos/inline-citation/color.tsx

</Demo>

## 접근성

- 표시에는 "Source 2"처럼 단어로 된 접근 가능한 이름이 붙습니다. 숫자 하나만으로는 스크린 리더에 아무 뜻도 전달되지 않기 때문입니다.
- 미리보기는 Base UI의 hover card이므로 포인터뿐 아니라 키보드 포커스에서도 열립니다.

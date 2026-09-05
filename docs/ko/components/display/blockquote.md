---
title: Blockquote
order: 9
---

# Blockquote

<p class="neba-lede">인용문을 본문과 구분해 보여 주는 컴포넌트입니다. 출처를 함께 넘기면 인용과 출처를 올바른 시맨틱 마크업으로 묶어 줍니다.</p>

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

출처가 없으면 `<blockquote>` 하나로 렌더링됩니다. `author`나 `source` 중 하나라도 있으면 `<figure>`로 감싸고 출처를 `<figcaption>`에 넣습니다.

```html
<figure>
  <blockquote cite="…">…</blockquote>
  <figcaption>— 저자, <cite>출처</cite></figcaption>
</figure>
```

`author`는 `<cite>` 바깥에 놓입니다. `<cite>`는 작품 제목을 위한 요소이기 때문입니다.

## 예시

### variant

`text`가 기본으로, 여백에 선 하나만 두어 본문 흐름 안에 놓입니다. `outline`과 `solid`는 인용이 그 절의 중심일 때 쓰는 sheet 형태입니다.

<Demo src="blockquote/variants">

<<< @/.vitepress/demos/blockquote/variants.tsx

</Demo>

### author와 source

`author`만, `source`만, 또는 둘 다 줄 수 있습니다. `cite`는 인용 출처 문서의 URL이며 `<blockquote>`의 `cite` 속성으로 전달됩니다. 화면에는 나타나지 않고 기계만 읽습니다.

<Demo src="blockquote/attribution">

<<< @/.vitepress/demos/blockquote/attribution.tsx

</Demo>

### color

인용문의 배경은 물들지 않습니다. `color`는 여백의 선과 인용부호에만 적용됩니다.

<Demo src="blockquote/colors">

<<< @/.vitepress/demos/blockquote/colors.tsx

</Demo>

### icon

`icon`은 세 가지로 동작합니다. 생략하면 기본 인용부호 글리프, node를 넘기면 그것으로 교체, `false`를 주면 표시하지 않습니다.

```tsx
<Blockquote>기본 인용부호</Blockquote>
<Blockquote icon={<QuoteIcon />}>직접 지정한 글리프</Blockquote>
<Blockquote icon={false}>글리프 없음</Blockquote>
```

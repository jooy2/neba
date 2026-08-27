---
title: Footer
order: 3
---

# Footer

<p class="neba-lede">페이지 끝의 시트입니다. 실제 <code>&lt;footer&gt;</code> — contentinfo 랜드마크 — 를 렌더링하며 표면과 거터, 그리고 바가 손에 닿아 있을지를 정합니다. 안에 들어가는 내용은 전부 직접 넣는 것입니다.</p>

<Demo src="footer/hero" minHeight="180" />

```tsx
import { Footer } from 'neba';

<Footer>© 2026 Neba</Footer>;
```

## Props

<PropsTable name="Footer" />

`<footer>`의 native 속성은 그대로 전달됩니다. 다만 `color`와 `title`은 예외입니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

자리를 나누지 않는다는 점이 [Header](./header)와 다릅니다. footer의 내용은 어떤 사이트에서는 네 개의 열이고 다음 사이트에서는 한 줄이라, 배치를 미리 정해 두면 절반의 사이트가 그것과 싸우게 됩니다.

## 예시

### position

기본값은 `static`으로 Header와 반대입니다. footer는 스크롤해서 닿는 문서의 끝이기 때문입니다. `sticky`는 창 아래에 붙이고, `fixed`는 흐름에서 빼냅니다 — [PageLayout](./page-layout) 안에서는 그 높이만큼 자리가 비워지므로 마지막 문단 위에 겹치지 않습니다.

### variant

세 가지 무게는 다른 곳에서와 같은 뜻입니다. 시트는 `color`로 물들지 않습니다.

<Demo src="footer/variant" minHeight="220">

<<< @/.vitepress/demos/footer/variant.tsx

</Demo>

### maxWidth

시트는 창을 가로지른 채, 안쪽 내용만 이 폭으로 묶어 가운데에 놓습니다. [Container](./container)와 같은 사다리입니다.

<Demo src="footer/measure">

<<< @/.vitepress/demos/footer/measure.tsx

</Demo>

### divider · padded

`divider`는 위 가장자리에 헤어라인을 그리며 기본값은 켜짐입니다. footer는 위에는 내용이 있고 아래에는 아무것도 없는 유일한 시트라, 이 선이 문서가 끝났다고 말하는 전부입니다. `padded={false}`는 여백을 직접 다루는 footer를 위해 거터를 없앱니다.

## 접근성

- `<footer>`를 렌더링하며, `<article>`이나 `<section>` 안이 아니라면 `contentinfo` 랜드마크입니다.
- 한 페이지에 `<footer>`가 둘 이상이면 `label`을 주세요.
- 링크 열이 잔글씨가 아니라 탐색이라면 직접 `<nav>`로 묶으세요.

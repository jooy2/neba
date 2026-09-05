---
title: AppLogo
order: 20
---

# AppLogo

<p class="neba-lede">제품의 마크를 정해진 크기로 그리며, 결코 빈 상자가 되지 않습니다. 이미지든 인라인 SVG든, 타일 위의 글자든, 아무것도 없으면 제품 이름을 로고타이프로 그립니다.</p>

<Demo src="app-logo/hero" />

```tsx
import { AppLogo } from 'neba';

<AppLogo name="Neba" src="/logo.svg" />;
```

## Props

<PropsTable name="AppLogo" />

`<a>`의 native 속성은 그대로 전달됩니다. 다만 `color`는 예외입니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

마크는 `children`이 있으면 그것, 없으면 `src`, 그것도 없으면 이름입니다. `href`가 없으면 `<span>`으로 렌더링됩니다.

## 예시

### src · children

마크를 어디서 가져올지 정합니다. `src`는 파일을 연결하고 — PNG든 SVG든 브랜드가 배포하는 무엇이든 —, `children`은 대신 마크업을 받습니다. 주변 색을 물려받아야 하는 인라인 `<svg>`가 필요로 하는 쪽이 후자입니다. 둘 다 주면 `children`이 이깁니다. 그래서 파일을 연결하는 프로젝트와 아이콘을 인라인으로 넣는 프로젝트가 같은 컴포넌트를 씁니다. 둘 다 없으면 타일에 `name`의 이니셜을 대신 그립니다.

<Demo src="app-logo/artwork" minHeight="120">

<<< @/.vitepress/demos/app-logo/artwork.tsx

</Demo>

### shape

마크를 두르는 방식입니다. 기본값 `bare`는 준 그대로 — `size`가 정한 높이와 그에 따른 너비로 — 그리며 배경도 자르기도 여백도 없습니다. `app`은 모서리를 깎은 채워진 타일 안으로 들여넣고, `circle`은 같은 타일을 둥글게 만듭니다. `padded={false}`는 마크가 타일 가장자리까지 닿게 합니다.

기본값이 `bare`인 이유는, 로고 파일에 배경이나 여백이나 제품 이름이 이미 들어 있는 경우가 많고 정사각형으로 자르면 그 셋이 모두 잘려 나가기 때문입니다.

<Demo src="app-logo/shape" minHeight="120">

<<< @/.vitepress/demos/app-logo/shape.tsx

</Demo>

### name

마크가 아예 없으면 이름이 곧 마크입니다. `bare`에서는 로고타이프로, 타일에서는 이니셜로 그려집니다. 유도된 글자가 맞지 않으면 `initials`로 직접 씁니다.

<Demo src="app-logo/name" minHeight="220">

<<< @/.vitepress/demos/app-logo/name.tsx

</Demo>

### showName

마크 옆에 이름을 그려 lockup을 만듭니다. 기본값은 꺼짐인데, 흔한 경우는 파일에 이미 이름이 들어 있기 때문입니다. 그린 순간부터 그 글자가 접근성 이름이 되므로 이름이 두 번 읽히지 않습니다.

### variant · color

마크 뒤 타일의 무게와 색 계열입니다. 타일을 그리지 않는 `bare`에서는 둘 다 아무 일도 하지 않습니다.

<Demo src="app-logo/variant" minHeight="120">

<<< @/.vitepress/demos/app-logo/variant.tsx

</Demo>

### href · height · render

`href`는 전체를 링크로 만듭니다. [Header](../layout/header)의 로고는 거의 언제나 그렇습니다. 이 탭을 벗어나는 `target`을 주면 직접 쓴 `rel`에 `rel="noopener noreferrer"`가 합쳐집니다. `height`는 `size` 대신 정확한 픽셀 값이나 CSS 길이를 씁니다. `render`는 요소를 바꿉니다 — 제품 이름이 곧 페이지 제목인 한 페이지를 위한 `render={<h1 />}`, 또는 라우터의 링크 컴포넌트.

<Demo src="app-logo/link" minHeight="120">

<<< @/.vitepress/demos/app-logo/link.tsx

</Demo>

## 접근성

- 이름은 문서에 정확히 한 번만 놓입니다. 그려진 이름이 곧 접근성 이름이고, 이미지는 `alt`로 그것을 나르며, 마크업이나 이니셜로 된 마크는 장식으로 표시되고 이름은 옆의 잘린 span에 남습니다.
- `alt`는 마크가 말하는 내용을 덮어씁니다. 제품이 아닌 다른 것을 뜻하는 드문 로고를 위한 것입니다.
- `href`가 있으면 링크의 접근성 이름이 제품 이름이 됩니다. 첫 페이지로 돌아가는 로고에 다른 글자를 더 쓸 필요가 없습니다.

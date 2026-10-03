---
title: Typography
order: 1
---

# Typography

<p class="neba-lede">라이브러리의 타입 스케일에 맞춰 텍스트를 렌더링합니다. 제목과 본문, 캡션이 모두 같은 크기 체계를 씁니다.</p>

<Demo src="typography/hero" />

```tsx
import { Typography } from 'neba';

<Typography level="h2">잘라낸 아크릴 한 장</Typography>
<Typography>모든 표면은 같은 재료를, 다른 불투명도로 쓴 것입니다.</Typography>;
```

## Props

<PropsTable name="Typography" />

다른 컴포넌트와 두 가지가 다릅니다. 타입 스케일을 고르는 prop은 `variant`가 아니라 `level`입니다. `variant`는 라이브러리 전체에서 표면의 무게를 뜻하기 때문입니다. 그리고 `color`에 기본값이 없어서, 지정하지 않으면 주변 텍스트 색을 물려받습니다.

루트에는 `neba-typography` 클래스가 붙습니다. React 바깥의 stylesheet가 이 텍스트를 잡는 후크입니다. `.neba-typography { text-wrap: balance }`처럼 씁니다. level이 만들어 내는 유틸리티 클래스 이름은 약속된 API가 아닙니다.

## 예시

### level

`level`은 타입 스케일과 렌더링할 요소를 함께 정합니다. `body`는 `md` 크기 [Card](../surfaces/card)의 본문과 같은 단계이므로, Card 안팎의 문단이 같은 크기로 보입니다. 제목 단계는 커질수록 행간 비율이 좁아집니다.

<Demo src="typography/scale">

<<< @/.vitepress/demos/typography/scale.tsx

</Demo>

### color

<Demo src="typography/colors">

<<< @/.vitepress/demos/typography/colors.tsx

</Demo>

### lines

`lines={1}`은 말줄임표를 붙여 한 줄로 자릅니다. `2` 이상은 그 줄 수까지만 보이는 line clamp입니다.

<Demo src="typography/clamp">

<<< @/.vitepress/demos/typography/clamp.tsx

</Demo>

### render

`level`이 정하는 요소와 실제로 필요한 요소가 다를 때 `render`로 요소만 바꿉니다. 문서 개요에 들어가면 안 되는 소제목, 또는 제목처럼 보여야 하는 `<p>`가 그런 경우입니다.

```tsx
<Typography level="h3" render={<p />}>
  제목처럼 보이지만 제목은 아닙니다
</Typography>
```

### gutter

`gutter`는 기본적으로 꺼져 있어 위아래 여백이 없습니다. 이어지는 산문에는 켜고, 간격을 이미 관리하는 flex 컨테이너 안에서는 끈 채로 두세요.

### className으로 덮어쓰기

`className`에 넣은 Tailwind utility는 variant가 붙든 안 붙든 level의 크기, 행간, 자간, weight, 여백, 글자색보다 우선합니다.

```tsx
<Typography level="h2" className="mb-8 text-[2.75rem] font-black">
  42
</Typography>
```

각 level의 행간은 길이가 아니라 **비율**이라서, 이렇게 바꾼 크기에도 행간이 비율대로 따라옵니다. 비율 자체를 바꾸려면 옆에 `leading-*`을 붙이세요.

variant가 붙은 class는 level을 대신하지 않고 그 위에 얹힙니다. `md:text-5xl`은 `md`부터 크기를 바꾸고, 그보다 좁은 화면에서는 level의 크기가 그대로 쓰입니다.

level은 scale을 class 두 겹의 특정도로 씁니다. `.prose h2`와 VitePress의 `.vp-doc h2`가 태그 이름으로 `font-size`, `line-height`, `letter-spacing`, `font-weight`와 여백을 지정하는데, class 하나로는 그 특정도를 넘지 못하기 때문입니다. `className`이 지정한 속성은 level이 특정도 0으로 물러나므로, 그런 본문 안에서는 그 속성 하나만 내 class와 본문 규칙이 겨루게 됩니다. Tailwind의 utility 이름만 읽으므로, 직접 만든 스타일시트의 class로 level을 이기려면 여전히 class 두 개나 `!important`가 필요합니다. `mb-8!`처럼 `!`를 붙인 utility는 지금까지와 똑같이 동작합니다.

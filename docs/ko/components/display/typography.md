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

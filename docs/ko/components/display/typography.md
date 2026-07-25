---
title: Typography
order: 1
---

# Typography

<p class="neba-lede">라이브러리의 타입 스케일 그 자체입니다. 지금까지 이 사다리는 그것이 필요했던 컴포넌트 안에만 있었습니다 — Card의 제목, TextField의 라벨.</p>

<Demo src="typography/hero" />

```tsx
import { Typography } from 'neba';

<Typography level="h2">잘라낸 아크릴 한 장</Typography>
<Typography>모든 표면은 같은 재료를, 다른 불투명도로 쓴 것입니다.</Typography>;
```

## Props

<PropsTable name="Typography" />

### 의도적인 두 가지 예외

**`variant`가 아니라 `level`입니다.** 이 라이브러리에서 `variant`는 **표면**의 무게 — `solid` / `outline` / `text` — 를 뜻하고, 같은 단어에 두 번째 뜻을 붙이는 것이야말로 [Prop 규약](../../guide/prop-conventions)이 금지하는 일입니다.

**`color`에는 기본값이 없습니다.** 다른 모든 컴포넌트는 `primary`가 기본입니다. 여기서 그러면 본문 글자가 전부 파랗게 됩니다. 문단의 일반적인 경우는 주변 문단과 같아 보이는 것이므로, `color`를 지정하지 않으면 "페이지의 색을 물려받는다"는 뜻이 됩니다.

## 예시

### 스케일

`body`는 `md` 크기 Card의 본문 사다리 위에 있습니다. 카드 안의 문단과 바깥의 문단이 같은 글자인 이유입니다. 제목들은 거기서 위로 올라가고, 커질수록 행간 비율은 좁아집니다 — 30px 줄은 13px 줄과 같은 비율을 원하지 않습니다.

<Demo src="typography/scale">

<<< @/.vitepress/demos/typography/scale.tsx

</Demo>

### 색

<Demo src="typography/colors">

<<< @/.vitepress/demos/typography/colors.tsx

</Demo>

### 줄 자르기

한 줄이면 말줄임표가 붙는 자르기이고, 두 줄 이상이면 줄 수 제한입니다. 둘 다 `lines`입니다.

<Demo src="typography/clamp">

<<< @/.vitepress/demos/typography/clamp.tsx

</Demo>

### 요소는 두고 스케일만

`level`은 타입 스케일과 요소를 함께 정하고, 대부분은 그것이 맞습니다. 둘이 달라져야 할 때 — 문서 개요에 들어가면 안 되는 소제목, 또는 `h3`처럼 보여야 하는 `<p>` — 는 `render`가 결정합니다.

```tsx
<Typography level="h3" render={<p />}>
  제목처럼 보이지만 제목은 아닙니다
</Typography>
```

## 기본적으로 여백이 없습니다

`gutter`는 꺼져 있습니다. 스스로 여백을 만드는 라이브러리 컴포넌트는 레이아웃이 싸워야 할 대상입니다. 이어지는 산문에는 켜고, 이미 간격을 관리하는 flex 열 안에서는 꺼 두세요.

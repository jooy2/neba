---
title: Skeleton
order: 9
---

# Skeleton

<p class="neba-lede">아직 불러오지 않은 것의 형태입니다. 실제 내용이 차지할 자리를 미리 잡아 두므로, 이미지가 도착했다고 해서 읽고 있던 카드가 갑자기 200px 자라지 않습니다.</p>

<Demo src="skeleton/hero" align="center" />

```tsx
import { Skeleton } from 'neba';

<Skeleton shape="circle" size="lg" />
<Skeleton shape="rect" height={120} />
<Skeleton lines={3} />
```

## Props

<PropsTable name="Skeleton" />

`<div>`의 기본 속성은 그대로 전달되며, `render`로 요소를 바꿀 수 있습니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

## 예시

### shape

세 가지 shape은 레이아웃을 이루는 세 가지입니다. `line`은 글줄이며 타입 스케일에 맞춰 크기가 정해지므로 `md` 줄은 `md` 글자와 같은 높이입니다. `rect`는 블록(이미지, 차트, 카드)이고 `height`를 주지 않으면 썸네일 높이로 떨어집니다. `circle`은 [Avatar](../display/avatar)와 같은 사다리 위에서 그려지므로 같은 `size`에서 정확히 같은 크기입니다.

<Demo src="skeleton/shapes">

<<< @/.vitepress/demos/skeleton/shapes.tsx

</Demo>

### lines

`lines`는 타입 스케일의 행간을 사이에 두고 막대를 쌓으며, 마지막 줄은 문단의 마지막 줄처럼 짧게 그립니다. `shape="line"`에만 적용되고 나머지 둘에서는 무시됩니다.

<Demo src="skeleton/lines">

<<< @/.vitepress/demos/skeleton/lines.tsx

</Demo>

### width와 height

`width`와 `height`는 숫자를 픽셀로, 문자열을 CSS 길이로 받습니다. 줄은 따로 말하지 않는 한 전체 너비를 차지하므로, 제목 자리 표시자는 `width` 하나 차이입니다.

<Demo src="skeleton/swapping">

<<< @/.vitepress/demos/skeleton/swapping.tsx

</Demo>

### animated

`animated`는 자리 표시자 위를 지나가는 하이라이트입니다. 한 화면에 수십 개가 놓이거나, 기다림이 길어 움직임이 소음이 되는 곳에서는 끄세요.

```tsx
<Skeleton animated={false} lines={4} />
```

이것은 접근성 스위치가 아닙니다. 축소된 모션 설정은 묻지 않고도 이미 이 하이라이트를 색 맥동으로 바꿉니다.

## 접근성

- Skeleton은 기본적으로 `aria-hidden`입니다. 자리 표시자 열둘이 저마다 자기를 알리는 것보다 침묵이 낫습니다.
- 한 영역 전체를 대표하는 **하나**에만 `label`을 주면 그 이름과 `aria-busy`를 가진 `status`가 됩니다. 쌓인 막대마다 label을 붙이지 마세요.
- 레이아웃을 이미 알고 있다면 spinner보다 skeleton을 쓰세요. 내용이 도착할 때 페이지가 다시 흐르지 않게 해 주는 로딩 표시는 이것뿐입니다.

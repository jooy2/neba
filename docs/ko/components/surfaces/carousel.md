---
title: Carousel
order: 5
---

# Carousel

<p class="neba-lede">여러 슬라이드를 한 장씩 넘겨 보여 줍니다. 스와이프와 키보드 이동, RTL을 모두 지원합니다.</p>

<Demo src="carousel/hero" />

```tsx
import { Carousel } from 'neba';

<Carousel label="제품 소개">
  <img src="/one.jpg" alt="" />
  <img src="/two.jpg" alt="" />
</Carousel>;
```

최상위 자식 하나가 슬라이드 하나가 됩니다. 별도의 슬라이드 컴포넌트는 없고, snap 지점과 폭, `role="group"` · `aria-roledescription="slide"`는 컴포넌트가 붙입니다.

## Props

<PropsTable name="Carousel" />

`<div>`의 native 속성은 그대로 전달됩니다.

내부 구현은 CSS scroll snap이 걸린 스크롤 컨테이너입니다. 그래서 스와이프가 브라우저 기본 동작으로 처리되고, RTL에서 방향이 자동으로 뒤집히며, 전환은 `scroll-behavior: smooth`를 씁니다 — `prefers-reduced-motion`에서는 같은 경로로 즉시 전환됩니다.

## 예시

### loop · arrows · indicators

`loop`를 끄면 화살표가 양 끝에서 비활성화됩니다. 처음과 끝이 있는 묶음에 적합합니다. `arrows`와 `indicators`는 각각 좌우 화살표와 하단 인디케이터를 표시합니다.

화살표는 프레임 **위에** 그려집니다. 가장자리 근처에 텍스트가 있는 슬라이드는 화살표를 피할 만큼 안쪽 여백을 두세요 — `size="md"`에서 3.5rem 정도입니다.

<Demo src="carousel/options">

<<< @/.vitepress/demos/carousel/options.tsx

</Demo>

### 사진

사진은 프레임을 가득 채우므로 안쪽 여백을 둘 것이 없고, 화살표는 사진 위에 놓입니다. 슬라이드마다 `ratio`를 준 [Image](../display/image) 하나씩이라, 파일이 오는 동안에도 스트립의 높이가 변하지 않습니다.

<Demo src="carousel/photos">

<<< @/.vitepress/demos/carousel/photos.tsx

</Demo>

### value와 onValueChange

controlled로 쓰면 페이지의 다른 컨트롤로 슬라이드를 옮길 수 있습니다. 사용자가 스와이프해서 슬라이드가 바뀐 경우에도 `onValueChange`가 호출됩니다.

<Demo src="carousel/controlled">

<<< @/.vitepress/demos/carousel/controlled.tsx

</Demo>

### autoPlay와 interval

`autoPlay`의 기본값은 꺼짐입니다. 켜더라도 hover, 내부 focus, 백그라운드 탭에서 멈추고, `prefers-reduced-motion`에서는 시작하지 않습니다. 자동 재생 중에는 현재 슬라이드를 알리는 live region도 침묵합니다.

모든 슬라이드가 반드시 읽혀야 하는 내용이라면 [Tabs](./tabs)나 세로 나열을 고려하세요.

## 접근성

- `label`이 캐러셀의 accessible name이 됩니다. `previousLabel` · `nextLabel` · `slideLabel`로 컨트롤 이름을 지정합니다.
- 각 슬라이드는 `role="group"`과 `aria-roledescription="slide"`를 갖습니다.

## 제공하지 않는 것

- **한 화면에 여러 장** — `overflow-x-auto`를 얹은 [Grid](../layout/grid)를 쓰세요.
- **세로 방향** — 스크롤되는 목록이면 충분합니다.
- **fade 전환** — 스크롤 기반 구현과 함께 쓸 수 없습니다.
- region 이름, 화살표, 각 슬라이드의 이름을 `locale`이 정합니다. `label`과 `slideLabel`로 직접 쓸 수도 있습니다.

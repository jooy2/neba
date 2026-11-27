---
title: Carousel
order: 5
flutter: true
---

# Carousel

<p class="neba-lede">여러 슬라이드를 한 장씩 넘겨 보여 줍니다. 스와이프와 키보드 이동, RTL을 모두 지원합니다.</p>

<Demo src="carousel/hero" />

::: fw react

```tsx
import { Carousel } from 'neba';

<Carousel label="제품 소개">
  <img src="/one.jpg" alt="" />
  <img src="/two.jpg" alt="" />
</Carousel>;
```

최상위 자식 하나가 슬라이드 하나가 됩니다. 별도의 슬라이드 컴포넌트는 없고, snap 지점과 폭, `role="group"` · `aria-roledescription="slide"`는 컴포넌트가 붙입니다. 여러 슬라이드를 한 화면에 함께 보여 주려면 [ScrollZone](../layout/scroll-zone)을 쓰세요.

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaCarousel(
  semanticLabel: '제품 소개',
  children: <Widget>[Image.asset('one.jpg'), Image.asset('two.jpg')],
);
```

자식 하나가 프레임 폭의 슬라이드 하나가 되고, 슬라이드는 모두 가장 높은 슬라이드의 높이를 씁니다. 별도의 슬라이드 위젯은 없으며, 슬라이드마다 screen reader용으로 "Slide 2 of 3" 같은 이름이 붙습니다. 여러 슬라이드를 한 화면에 함께 보여 주려면 [ScrollZone](../layout/scroll-zone)을 쓰세요.

:::

## Props

<PropsTable name="Carousel" />

::: fw react

`<div>`의 native 속성은 그대로 전달됩니다.

:::

::: fw flutter

슬라이드는 프레임 위의 화살표, 아래의 점, 스와이프, 그리고 스트립이 focus를 가졌을 때의 방향키로 넘어갑니다.

:::

## 예시

### loop · arrows · indicators

`loop`를 끄면 화살표가 양 끝에서 비활성화됩니다. 처음과 끝이 있는 묶음에 적합합니다. `arrows`와 `indicators`는 각각 좌우 화살표와 하단 인디케이터를 표시합니다.

화살표는 프레임 **위에** 그려집니다. 가장자리 근처에 텍스트가 있는 슬라이드는 화살표를 피할 만큼 안쪽 여백을 두세요. `size="md"`에서 3.5rem 정도입니다.

<Demo src="carousel/options">

::: fw react

<<< @/.vitepress/demos/carousel/options.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/carousel/options.dart

:::

</Demo>

### 사진

사진은 프레임을 가득 채우므로 안쪽 여백을 둘 것이 없고, 화살표는 사진 위에 놓입니다. 슬라이드마다 `ratio`를 준 [Image](../display/image) 하나씩이라, 파일이 오는 동안에도 스트립의 높이가 변하지 않습니다.

<Demo src="carousel/photos">

<<< @/.vitepress/demos/carousel/photos.tsx

</Demo>

### value와 onValueChange

controlled로 쓰면 페이지의 다른 컨트롤로 슬라이드를 옮길 수 있습니다. 사용자가 스와이프해서 슬라이드가 바뀐 경우에도 `onValueChange`가 호출됩니다.

::: fw react

서버에서 렌더링한 strip은 Chrome과 Edge 133 이상에서 첫 페인트부터 `value`나 `defaultValue` 슬라이드로 열립니다. 다른 브라우저는 hydration 전까지 첫 슬라이드를 보여 주다가 hydration이 끝나면 그 슬라이드로 옮겨 갑니다. 이 차이는 [브라우저 지원](../../browser-support#지원-범위-안에서-달라지는-점)에 정리돼 있습니다.

:::

::: fw flutter

스트립은 첫 프레임부터 `value`나 `defaultValue` 슬라이드로 열립니다.

:::

<Demo src="carousel/controlled">

::: fw react

<<< @/.vitepress/demos/carousel/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/carousel/controlled.dart

:::

</Demo>

### autoPlay와 interval

::: fw react

`autoPlay`의 기본값은 꺼짐입니다. 켜더라도 hover, 내부 focus, 백그라운드 탭에서, 그리고 Carousel이 화면 밖으로 스크롤됐을 때 멈추고, `prefers-reduced-motion`에서는 시작하지 않습니다. 다시 화면에 들어오면 멈춘 슬라이드를 `interval`만큼 온전히 보여 준 뒤에 넘어갑니다. 자동 재생 중에는 현재 슬라이드를 알리는 live region도 침묵하고, 멈추면 다시 알립니다.

:::

::: fw flutter

`autoPlay`의 기본값은 꺼짐입니다. 켜더라도 hover, 내부 focus, 앱이 백그라운드에 있을 때, 그리고 Carousel이 담긴 스크롤 뷰 밖으로 스크롤됐을 때 멈추고, 움직임을 줄여 달라고 한 독자에게는 시작하지 않습니다. 다시 화면에 들어오면 멈춘 슬라이드를 `interval`만큼 온전히 보여 준 뒤에 넘어갑니다. 독자가 슬라이드를 넘기면 현재 슬라이드를 screen reader에 알리고, 스스로 넘어가는 동안에는 알리지 않습니다.

:::

켜면 회전을 멈추는 버튼이 프레임 아래 점 줄 옆에 그려집니다. 이 버튼을 없애는 prop은 없으며, 이름은 `pauseLabel`과 `playLabel`로 지정합니다.

### locale

::: fw react

`locale`은 region 이름, 컨트롤 이름, 각 슬라이드 이름의 언어를 정합니다. `ko`, `pt-BR`, `zh-Hant` 같은 BCP 47 태그를 받으며, 번역이 없는 태그는 영어로 돌아갑니다. `label`을 비롯한 `*Label` prop으로 직접 쓸 수도 있습니다.

:::

::: fw flutter

`locale`은 캐러셀 이름, 컨트롤 이름, 각 슬라이드 이름의 언어를 정하며, 기본값은 `NebaProvider`의 값, 없으면 앱의 언어입니다. `semanticLabel`을 비롯한 `*Label` 인자로 직접 쓸 수도 있습니다.

:::

## 접근성

::: fw react

- `label`이 캐러셀의 accessible name이 됩니다. `previousLabel` · `nextLabel` · `pauseLabel` · `playLabel` · `slideLabel`로 컨트롤 이름을 지정합니다.
- `autoPlay`는 회전을 멈추는 버튼을 프레임 아래에 함께 그리므로, hover도 tab도 쓰지 않는 독자도 회전을 멈출 수 있습니다.
- 각 슬라이드는 `role="group"`과 `aria-roledescription="slide"`를 갖습니다.
- `prefers-reduced-motion`에서는 슬라이드가 부드럽게 스크롤되지 않고 즉시 바뀝니다.

:::

::: fw flutter

- `semanticLabel`이 캐러셀의 이름이 됩니다. `previousLabel` · `nextLabel` · `pauseLabel` · `playLabel` · `slideLabel`로 컨트롤 이름을 지정합니다.
- `autoPlay`는 회전을 멈추는 버튼을 프레임 아래에 함께 그리므로, hover도 키보드도 쓰지 않는 독자도 회전을 멈출 수 있습니다.
- 각 슬라이드는 "Slide 2 of 3"처럼 자리로 이름이 붙은 노드입니다.
- 움직임을 줄여 달라고 한 독자에게는 슬라이드가 스크롤되지 않고 즉시 바뀝니다.

:::

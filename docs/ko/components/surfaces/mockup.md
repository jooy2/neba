---
title: Mockup
order: 12
---

# Mockup

<p class="neba-lede">화면에 무엇이든 올릴 수 있는 기기입니다. 휴대폰, 태블릿, 모니터, 노트북을 그리고 그 위에 시스템의 상태바나 dock, 작업 표시줄을 얹습니다. 화면은 기기의 실제 해상도를 가진 viewport이므로, 안의 내용은 페이지가 아니라 휴대폰을 기준으로 배치됩니다.</p>

<Demo src="mockup/hero" align="center" minHeight="440" />

```tsx
import { Mockup } from 'neba';

<Mockup device="mobile" os="ios" width={260}>
  <YourScreen />
</Mockup>;
```

## Props

<PropsTable name="Mockup" />

`<div>`의 기본 속성은 그대로 전달되며, `render`로 요소를 바꿀 수 있습니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

특정 기기에만 해당하는 prop이 셋 있고, 나머지 기기에서는 무시됩니다. `hardware`는 데스크톱의 것, `orientation`은 손에 드는 기기의 것이며, 그 기기가 돌리지 않는 `os`는 해당 기기의 기본값으로 되돌아갑니다.

## 예시

### device

`device`는 기본값이 없는 유일한 prop입니다. 형태와 해상도 사다리, 그리고 고를 수 있는 시스템이 여기서 정해집니다. 데스크톱은 `macos`·`windows`·`linux`, 태블릿은 `ipados`·`android`, 휴대폰은 `ios`·`android`를 돌립니다.

<Demo src="mockup/devices" minHeight="320">

<<< @/.vitepress/demos/mockup/devices.tsx

</Demo>

### 목업 크기 정하기

`width`와 `height`는 기기가 페이지에 그려지는 크기입니다. 픽셀 숫자든 임의의 CSS 길이든 받습니다. 하나만 주면 나머지는 기기의 비율을 따르고, 둘 다 주지 않으면 놓인 자리의 너비를 채웁니다. 어떤 값이 되든 안쪽 화면은 자기 해상도를 유지하며, 기기 전체가 거기에 맞춰 축소됩니다.

```tsx
<Mockup device="mobile" width={260} />
<Mockup device="desktop" height={320} />
<Mockup device="tablet" width="100%" />
```

### size와 resolution

`size`는 기기별로 실제 해상도 다섯 단계를 오르내리는 사다리입니다. 휴대폰은 320부터 430 CSS 픽셀까지, 데스크톱은 1024부터 1920까지입니다. `resolution`은 `{ width, height }` 쌍을 받아 이를 덮어씁니다.

화면은 `neba-screen`이라는 이름의 container이므로, 안의 내용은 창이 아니라 기기에 container query로 반응할 수 있습니다. 아래 두 목업은 페이지에서 똑같이 300픽셀 너비이고, 다른 것은 그 뒤의 화면뿐입니다.

<Demo src="mockup/resolution" minHeight="280">

<<< @/.vitepress/demos/mockup/resolution.tsx

</Demo>

### os

`os`는 어떤 바를 어디에 그릴지를 정합니다. 메뉴 바와 떠 있는 dock, 가운데 정렬된 작업 표시줄, 상단 바와 시작 모서리를 따라 내려가는 dock이 그것입니다. 크롬은 복제가 아니라 인상입니다. Neba 자신의 토큰으로 그린 추상적인 도형이고, 글자는 시계 하나뿐입니다.

<Demo src="mockup/os" minHeight="300">

<<< @/.vitepress/demos/mockup/os.tsx

</Demo>

손에 드는 기기에서는 상태바와 아래쪽 바가 한 쌍입니다. `ios`와 `ipados`는 home indicator를, `android`는 탐색 glyph 셋을 그립니다.

<Demo src="mockup/handhelds" minHeight="360">

<<< @/.vitepress/demos/mockup/handhelds.tsx

</Demo>

### hardware

데스크톱에서 `hardware`는 화면을 받치는 것입니다. 아래에 받침대가 있거나, 앞에 키보드가 있거나입니다. 태블릿과 휴대폰에서는 무시됩니다.

<Demo src="mockup/hardware" minHeight="340">

<<< @/.vitepress/demos/mockup/hardware.tsx

</Demo>

### bezel

`bezel`은 화면을 둘러싼 하드웨어의 양입니다. `none`은 더 얇은 테두리가 아니라 하드웨어가 아예 없는 상태, 즉 모서리만 깎인 화면 그 자체입니다. `thick`은 옛날 기기입니다. 옆은 좁고 위아래가 넓습니다.

<Demo src="mockup/bezel" minHeight="300">

<<< @/.vitepress/demos/mockup/bezel.tsx

</Demo>

### finish

`finish`는 하드웨어의 재질입니다. 셋 모두 테마 토큰이 아니라 고정된 색이므로, graphite 휴대폰은 페이지가 dark로 바뀌어도 graphite 그대로입니다.

<Demo src="mockup/finish" minHeight="300">

<<< @/.vitepress/demos/mockup/finish.tsx

</Demo>

### notch

`notch`는 카메라 구멍입니다. `dynamic-island`, `notch`, 동그란 `punch-hole`, 그리고 `none`이 있습니다. 기본값은 그 기기가 실제로 가진 형태입니다. iOS 휴대폰은 island, Android 휴대폰은 punch hole, 태블릿과 데스크톱은 없음입니다.

크롬이 아니라 하드웨어이므로 `systemUi`를 껐든 켰든 그려지며, landscape에서는 시작 모서리로 옮겨 갑니다.

<Demo src="mockup/notch" minHeight="300">

<<< @/.vitepress/demos/mockup/notch.tsx

</Demo>

### orientation

`orientation`은 손에 드는 기기를 돌립니다. 화면과 bezel과 구멍이 함께 돌아갑니다. 데스크톱은 받침대가 돌지 않으므로 이를 무시합니다.

<Demo src="mockup/orientation" minHeight="280">

<<< @/.vitepress/demos/mockup/orientation.tsx

</Demo>

### systemUi

모든 바는 내용을 덮는 대신 자기 자리를 차지합니다. 따라서 `systemUi={false}`는 가려져 있던 무언가를 드러내는 것이 아니라, 화면을 `children`에게 돌려줍니다.

<Demo src="mockup/system-ui" minHeight="360">

<<< @/.vitepress/demos/mockup/system-ui.tsx

</Demo>

### scroll

화면보다 긴 내용은 기본적으로 잘립니다. 기기의 정지된 사진이 원하는 것이 그것이기 때문입니다. `scroll`을 켜면 대신 화면이 스크롤됩니다.

<Demo src="mockup/scroll" align="center" minHeight="340">

<<< @/.vitepress/demos/mockup/scroll.tsx

</Demo>

### wallpaper

`wallpaper`는 내용 뒤에 놓이는 것입니다. 색이든 gradient든 `url()`이든, 임의의 CSS `background` 값을 받습니다. 기본값은 페이지 자신의 surface 색입니다.

<Demo src="mockup/wallpaper" minHeight="300">

<<< @/.vitepress/demos/mockup/wallpaper.tsx

</Demo>

### elevation

`elevation`은 기기를 페이지에서 띄웁니다. 그림자는 실루엣으로 그려지므로 이를 감싸는 상자가 아니라 뚜껑과 목과 받침을 따라가며, 기기가 축소되어도 함께 줄어들지 않습니다.

```tsx
<Mockup device="mobile" elevation={2} width={240} />
```

## 접근성

- 기기의 모든 부분(테두리, 바, 구멍)은 `aria-hidden`입니다. screen reader가 닿는 것은 `children`뿐이며, 목업이란 곧 실제 내용을 둘러싼 그림이라는 뜻입니다.
- 시계는 장식이며 읽히지 않습니다. 크롬이 그리는 유일한 글자입니다.
- 목업은 스스로 role도 이름도 만들지 않습니다. 그림 자체가 페이지에서 의미를 가진다면 `aria-label`을 주거나, `render`로 캡션이 있는 `<figure>`로 바꾸어 이름을 주십시오.
- 안의 내용은 그대로 조작할 수 있고 focus도 갑니다. 4분의 1로 축소된 기기는 컨트롤도 4분의 1 크기라는 점은, 그 안에 form을 넣기 전에 알아 둘 만합니다.

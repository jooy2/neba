---
title: Slider
order: 8
---

# Slider

<p class="neba-lede">범위 위에서 값을 고릅니다. 배열을 넘기면 범위 슬라이더가 됩니다 — 그것을 위한 별도 prop은 없습니다. 값의 모양이 이미 어느 쪽인지 말해 주기 때문입니다.</p>

<Demo src="slider/hero" />

```tsx
import { Slider } from 'neba';

<Slider label="볼륨" defaultValue={65} showValue />;
```

## Props

<PropsTable name="Slider" />

`onValueChange`는 끄는 동안 계속 호출되고, `onValueCommitted`는 값이 확정될 때 한 번만 호출됩니다. 네트워크 요청은 두 번째에 거세요.

## 예시

### 범위

<Demo src="slider/range">

<<< @/.vitepress/demos/slider/range.tsx

</Demo>

### 크기

thumb은 트랙보다 의도적으로 훨씬 큽니다. 실제로 손이 닿는 곳은 여기뿐이고, 6px 레일에 맞춘 thumb은 터치스크린에서 아무도 잡지 못하는 thumb입니다.

<Demo src="slider/sizes">

<<< @/.vitepress/demos/slider/sizes.tsx

</Demo>

### 세로

세로 슬라이더에는 자기 길이가 없습니다. 높이를 직접 주세요. 기본값은 규칙이 아니라 출발점입니다.

<Demo src="slider/vertical">

<<< @/.vitepress/demos/slider/vertical.tsx

</Demo>

## thumb은 커지지 않습니다

호버와 드래그는 thumb을 확대하는 대신 그 **둘레에** 링을 그립니다. 라이브러리의 나머지가 따르는 transform 금지 규칙과 같은 것이고, 이 부품에 글자가 없다는 이유로 느슨해지지 않습니다. 커서 아래에서 부품 크기가 변하는 컨트롤이야말로 싸구려로 읽히는 그것입니다.

레일과 인디케이터가 알약 모양인 이유는 [Switch](./switch)의 트랙과 같습니다 — 이것은 무언가가 지나가는 홈이지 시트가 아닙니다.

## 접근성

- 각 thumb은 진짜 `<input type="range">`이므로 방향키, Home/End, PageUp/PageDown이 여기 코드 없이 그대로 동작합니다.
- `label`이 접근성 이름이 됩니다. 없다면 `aria-label`을 주세요.
- `showValue`는 `<output>`으로 렌더링되어 값이 바뀔 때 읽힙니다.

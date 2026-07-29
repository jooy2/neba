---
title: Slider
order: 8
---

# Slider

<p class="neba-lede">정해진 범위 안에서 값을 끌어서 고릅니다. 정확한 숫자보다 상대적인 크기가 중요한 값에 씁니다.</p>

<Demo src="slider/hero" />

```tsx
import { Slider } from 'neba';

<Slider label="볼륨" defaultValue={65} showValue />;
```

## Props

<PropsTable name="Slider" />

`onValueChange`는 끄는 동안 계속 호출되고, `onValueCommitted`는 값이 확정될 때 한 번만 호출됩니다. 네트워크 요청은 후자에 거세요.

정확한 숫자를 입력받아야 한다면 [NumberField](./number-field)를 쓰세요.

## 예시

### value 배열로 범위 지정

`value`에 숫자 배열을 주면 thumb이 그만큼 생기는 range slider가 됩니다. 별도의 prop은 없습니다.

<Demo src="slider/range">

<<< @/.vitepress/demos/slider/range.tsx

</Demo>

### min · max · step

`step`은 thumb이 멈추는 간격입니다. `showValue`는 현재 값을 라벨 옆에 표시합니다.

### size

thumb은 트랙보다 크게 그려집니다. 실제로 손이 닿는 부분이므로 터치 대상 크기를 확보하기 위한 것입니다.

<Demo src="slider/sizes">

<<< @/.vitepress/demos/slider/sizes.tsx

</Demo>

### orientation

`vertical`은 자기 길이를 갖지 않으므로 높이를 직접 지정하세요.

<Demo src="slider/vertical">

<<< @/.vitepress/demos/slider/vertical.tsx

</Demo>

## 접근성

- 각 thumb이 실제 `<input type="range">`이므로 방향키, Home/End, PageUp/PageDown이 그대로 동작합니다.
- `label`이 accessible name이 됩니다. 없으면 `aria-label`을 주세요.
- `showValue`는 `<output>`으로 렌더링되어 값이 바뀔 때 읽힙니다.
- hover와 drag에서 thumb 크기는 변하지 않고 둘레에 ring이 그려집니다.

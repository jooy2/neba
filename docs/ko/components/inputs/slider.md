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

### marks

`marks`는 트랙 위의 지점에 이름을 답니다. 개수 축의 `1 / 100 / 250 / 500`, 스타일 축의 양 끝 같은 것들입니다. `{ value, label? }` 배열을 넘기고, label이 없는 mark는 눈금만 그려집니다.

값 없이 `marks`만 주면 `step`마다 눈금이 하나씩 생깁니다. step을 직접 정한 슬라이더에 어울리는 형태입니다. 기본값인 `step={1}`을 기본 범위에 쓰면 눈금이 101개 그려지고, 100단계를 넘는 범위에서는 아무것도 그리지 않습니다.

이 줄은 스크린 리더에서 숨겨집니다. 값과 범위는 thumb이 이미 읽어 줍니다.

<Demo src="slider/marks">

<<< @/.vitepress/demos/slider/marks.tsx

</Demo>

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

### classNames

`className`은 루트(라벨과 스트립, 그 아래 한 줄을 담은 열)에 붙고, 그 안의 파트는 `classNames`로 잡습니다.

```tsx
<Slider label="Volume" classNames={{ track: 'h-1', thumb: 'rounded-sm', mark: 'font-mono' }} />
```

슬롯은 `label`, `control`, `track`, `indicator`, `thumb`, `description`, `mark`입니다. `control`은 press가 닿는 스트립 전체로, 그 안에 그려지는 `track`보다 두껍습니다.

## 접근성

- 각 thumb이 실제 `<input type="range">`이므로 방향키, Home/End, PageUp/PageDown이 그대로 동작합니다.
- `label`이 각 thumb의 accessible name이 되고 `description`이 설명으로 붙습니다. label이 없으면 `aria-label`을 주세요. 이것도 thumb에 붙습니다.
- 범위 slider의 두 thumb은 label을 함께 씁니다. `getAriaLabel`로 이름을 나누고, `getAriaValueText`로 값을 읽는 문장을 정하세요.
- `showValue`는 `<output>`으로 렌더링되어 값이 바뀔 때 읽힙니다.
- hover와 drag에서 thumb 크기는 변하지 않고 둘레에 ring이 그려집니다.

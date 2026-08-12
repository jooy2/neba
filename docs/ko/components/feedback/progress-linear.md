---
title: ProgressLinear
order: 5
---

# ProgressLinear

<p class="neba-lede">진행률을 가로 막대로 표시합니다. 세 가지 progress 컴포넌트 중 가장 널리 쓰이는 형태입니다.</p>

<Demo src="progress-linear/hero" />

```tsx
import { ProgressLinear } from 'neba';

<ProgressLinear value={64} label="에셋 업로드 중" showValue />
<ProgressLinear />
```

## Props

<PropsTable name="ProgressLinear" />

`<div>`의 native 속성은 root로 전달됩니다. `color`와 `children`만 위 표와 이름이 겹쳐 제외됩니다.

`value`의 기본값은 `null`이며, 진행률을 알 수 없는 indeterminate 상태를 뜻합니다. 짧은 조각이 막대 위를 반복해 지나갑니다. `0`을 주면 "아직 아무것도 진행되지 않음"이라는 다른 의미가 되므로 구분해서 쓰세요.

## 예시

### size

<Demo src="progress-linear/sizes">

<<< @/.vitepress/demos/progress-linear/sizes.tsx

</Demo>

### min · max · format

표시되는 백분율은 100이 아니라 `min`…`max` 구간에 대한 비율입니다. `showValue`로 값을 옆에 띄우고, `format`에 `Intl.NumberFormat` 옵션을 주면 바이트나 파일 수, 금액처럼 숫자 자체를 보여 줄 수 있습니다.

<Demo src="progress-linear/values">

<<< @/.vitepress/demos/progress-linear/values.tsx

</Demo>

## 모션 줄이기

`prefers-reduced-motion`에서도 indeterminate 애니메이션이 멈추지는 않습니다. 대신 지나가던 조각이 사라지고 막대 전체가 색으로 맥동합니다.

## 접근성

- `role="progressbar"`와 값·범위 속성이 적용되고, indeterminate일 때는 `aria-valuenow`가 빠집니다.
- `label`이 accessible name이 되고, `aria-valuetext`는 화면에 표시된 값과 같은 내용을 전달합니다.

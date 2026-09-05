---
title: ProgressCircular
order: 6
---

# ProgressCircular

<p class="neba-lede">진행률을 원형 고리로 표시합니다. 가로 막대를 놓을 자리가 없는 좁은 공간에 씁니다.</p>

<Demo src="progress-circular/hero" align="center" />

```tsx
import { ProgressCircular } from 'neba';

<ProgressCircular value={72} showValue label="색인 중" />
<ProgressCircular />
```

## Props

<PropsTable name="ProgressCircular" />

`<div>`의 native 속성은 root로 전달됩니다. `color`와 `children`만 위 표와 이름이 겹쳐 제외됩니다.

`value`의 기본값은 `null`이며 indeterminate 상태에서는 고리가 회전합니다. `min` · `max` · `format`은 [ProgressLinear](./progress-linear)와 동일하게 동작합니다.

## 예시

### size

<Demo src="progress-circular/sizes">

<<< @/.vitepress/demos/progress-circular/sizes.tsx

</Demo>

### 컨트롤 안에 넣기

고리는 각 단계에서 컨트롤 높이보다 한 단계 작습니다. `md` 고리는 32px 컨트롤 안의 20px입니다. 버튼이나 필드, 표의 행에 넣어도 행 높이가 늘어나지 않습니다.

<Demo src="progress-circular/inline">

<<< @/.vitepress/demos/progress-circular/inline.tsx

</Demo>

### showValue와 label

값은 고리 안이 아니라 옆에 놓입니다. `xs`에서는 고리 지름이 14px이라 안쪽에 숫자가 들어갈 자리가 없기 때문입니다. `showValue`와 `label`은 고리와 한 줄로 정렬됩니다.

## 접근성

- SVG 그림 자체는 `aria-hidden`이고, 값은 바깥 요소의 `role="progressbar"`를 통해 전달됩니다.
- `label`이 accessible name이 됩니다.

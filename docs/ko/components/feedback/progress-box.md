---
title: ProgressBox
order: 7
---

# ProgressBox

<p class="neba-lede">진행 상태를 여러 개의 판이 차례로 채워지는 형태로 표시합니다. Neba 표면 위의 로딩 상태에 어울리는 형태입니다.</p>

<Demo src="progress-box/hero" align="center" />

```tsx
import { ProgressBox } from 'neba';

<ProgressBox />
<ProgressBox value={62} label="마이그레이션 중" showValue />
```

## Props

<PropsTable name="ProgressBox" />

`value` · `min` · `max` · `format` · `showValue`는 [ProgressLinear](./progress-linear)와 동일하게 동작합니다. `value`가 `null`이면 판이 순서대로 밝아지는 indeterminate 상태입니다.

## 예시

### count

판의 개수입니다. 값이 있을 때 판은 왼쪽부터 채워지고, 진행 중인 판은 부분적으로 채워집니다 — 판 단위로만 채워지면 판 4개로는 0 · 25 · 50 · 75 · 100만 표현할 수 있기 때문입니다.

<Demo src="progress-box/counts">

<<< @/.vitepress/demos/progress-box/counts.tsx

</Demo>

### 단계 표시로 쓰기

`count`를 실제 단계 수에 맞추면 판 하나가 단계 하나가 됩니다. 진행 중인 단계의 판이 채워지는 중으로 표시됩니다.

<Demo src="progress-box/steps">

<<< @/.vitepress/demos/progress-box/steps.tsx

</Demo>

## 모션 줄이기

판은 위치가 움직이지 않고 채움과 빛 가장자리만 애니메이션합니다. `prefers-reduced-motion`에서는 주기가 느려집니다.

## 접근성

- `role="progressbar"`와 값 속성이 적용되고, `label`이 accessible name이 됩니다.
- indeterminate 상태는 `0`이 아니라 미정으로 보고됩니다.

---
title: ProgressLinear
order: 5
---

# ProgressLinear

<p class="neba-lede">차오르는 막대. 셋 중 가장 많이 쓰이는 것.</p>

<Demo src="progress-linear/hero" />

```tsx
import { ProgressLinear } from 'neba';

<ProgressLinear value={64} label="에셋 업로드 중" showValue />
<ProgressLinear />
```

## Props

<PropsTable name="ProgressLinear" />

## 예시

### 크기

<Demo src="progress-linear/sizes">

<<< @/.vitepress/demos/progress-linear/sizes.tsx

</Demo>

### 0–100이 아닌 범위

표시되는 값은 100에 대한 비율이 아니라 `min`…`max`에 대한 백분율입니다. 4단계 중 3단계를 "3%"라고 말하는 것은 아무 말도 하지 않느니만 못합니다. 숫자 자체가 독자에게 의미가 있다면 — 바이트, 파일 수, 금액 — `format`을 넘기세요.

<Demo src="progress-linear/values">

<<< @/.vitepress/demos/progress-linear/values.tsx

</Demo>

## 기본값은 미정입니다

`value`의 기본값은 `null`이고, `null`은 "무언가 진행 중인데 얼마나 남았는지는 아무도 모른다"는 뜻입니다. 의도된 기본값입니다. 값을 듣지 못한 표시기는 빈 막대를 그리는 대신 모른다고 말해야 합니다. 빈 막대는 "아무 진척도 없다"는 주장이니까요.

미정 막대는 transform이 아니라 `inset-inline-start`로 짧은 조각을 홈 위에서 움직입니다. RTL에서 알아서 반대로 흐르는 이유이자, 표면을 움직이지 않는다는 이 집의 규칙을 깨지 않는 이유입니다. 대가는 프레임마다 한 번의 레이아웃이고, 그 범위는 높이 4픽셀짜리 상자 안입니다.

## 완전히 둥근 것은 의도입니다

알약 모양을 금지하는 규칙이 적용되지 않는 유일한 자리입니다. 높이가 4픽셀이면 지켜야 할 평평한 구간 자체가 없고, 끝이 각진 막대는 잘린 모서리가 아니라 렌더링 버그로 읽힙니다. 그 규칙이 다른 곳에서 무엇을 지키는지는 [디자인 언어](../../guide/design-language)에 있습니다.

## 모션 줄이기

`prefers-reduced-motion`에서도 애니메이션을 끄지는 않습니다. 가만히 있는 미정 표시기는 자기 존재 이유와 반대되는 말을 합니다. 대신 지나가던 조각이 사라지고 홈 전체가 색으로 맥동합니다. 이 라이브러리가 다른 모든 상태에 이미 쓰고 있는 축입니다.

## 접근성

의미론은 Base UI의 Progress가 가집니다. `role="progressbar"`, 값과 범위 속성, 그리고 미정일 때 `aria-valuenow`를 아예 빼는 처리까지. `label`이 접근성 이름이 되고, `aria-valuetext`는 막대 옆에 적힌 것과 똑같은 말을 합니다.

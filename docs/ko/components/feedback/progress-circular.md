---
title: ProgressCircular
order: 6
---

# ProgressCircular

<p class="neba-lede">차오르는 고리. 막대가 들어갈 자리가 없을 때.</p>

<Demo src="progress-circular/hero" align="center" />

```tsx
import { ProgressCircular } from 'neba';

<ProgressCircular value={72} showValue label="색인 중" />
<ProgressCircular />
```

## Props

<PropsTable name="ProgressCircular" />

## 예시

### 크기

<Demo src="progress-circular/sizes">

<<< @/.vitepress/demos/progress-circular/sizes.tsx

</Demo>

### 컨트롤 안에서

고리는 매 단계에서 컨트롤 사다리 바로 아래에 놓입니다 — `md` 고리는 32px 컨트롤 안의 20px입니다. 그래서 버튼이나 필드, 표의 행에 넣어도 행이 원래보다 높아지지 않습니다.

<Demo src="progress-circular/inline">

<<< @/.vitepress/demos/progress-circular/inline.tsx

</Demo>

## 숫자는 옆에 놓입니다

원판 한가운데의 백분율은 이 컴포넌트 하면 누구나 떠올리는 그림이지만, 다섯 크기 중 둘에서만 성립합니다. `xs`에서 고리는 지름 14픽셀이고 "40%"가 들어갈 자리가 없습니다. 옆에 두면 모든 크기에서 읽히므로, `showValue`와 `label`은 고리와 한 줄에 앉습니다.

## 라이브러리에서 유일하게 도는 것

이 집의 규칙이 컨트롤의 transform을 막는 이유는, 크기를 바꾸거나 움직이면 그 안의 글자가 다시 샘플링되기 때문입니다. 고리 안에는 글자가 없습니다. 도는 것은 글리프이고, 이것은 [Select](../inputs/select)의 셰브런이 받는 것과 같은 허용입니다.

호는 **어디서 시작하는가**는 CSS transform이 아니라 SVG 기하 속성입니다. 그것이 없으면 값이 정해진 고리는 3시 방향에서부터 차오르는데, "72%"라고 말할 때 아무도 그것을 뜻하지 않습니다.

## 접근성

그림 자체는 `aria-hidden`입니다. 값은 막대에서와 똑같이, 바깥 요소에 걸린 Base UI의 `role="progressbar"`를 통해 스크린 리더에 닿습니다. `label`이 접근성 이름이 됩니다.

---
title: Switch
order: 7
---

# Switch

<p class="neba-lede">즉시 켜고 끄는 컨트롤입니다. Checkbox와의 차이는 생김새가 아니라 시점에 있습니다.</p>

<Demo src="switch/hero" />

```tsx
import { Switch } from 'neba';

<Switch label="이메일 알림" defaultChecked />;
```

## Props

<PropsTable name="Switch" />

## 스위치인가 체크박스인가

체크박스는 폼과 함께 제출되는 값입니다. 스위치는 움직이는 순간 효력이 생깁니다. 아래에 저장 버튼이 있다면 그것은 체크박스였어야 합니다.

## 예시

### 상태

<Demo src="switch/states">

<<< @/.vitepress/demos/switch/states.tsx

</Demo>

### 라벨 위치

`end`는 컨트롤에 붙은 설명처럼 읽힙니다. `start`는 라벨이 한 열을 이루고 스위치가 모두 오른쪽에 정렬되는 설정 목록을 위한 것입니다.

<Demo src="switch/placement">

<<< @/.vitepress/demos/switch/placement.tsx

</Demo>

### 크기

<Demo src="switch/sizes">

<<< @/.vitepress/demos/switch/sizes.tsx

</Demo>

## 규칙을 두 번 굽히는 곳

**알약 모양입니다.** 다른 곳에서는 반경이 50%에 못 미치게 멈춥니다. 위아래 가장자리의 평평한 구간이야말로 모서리를 잘라낸 시트로 읽히게 하는 것이기 때문입니다. 스위치는 시트가 아니라 무언가가 지나가는 트랙이고, 모서리가 있는 트랙은 thumb이 기어올라야 하는 트랙입니다.

**무언가가 움직입니다.** 이 라이브러리에서 실제로 이동하는 것은 여기뿐이고, `transform`이 아니라 `left`로 움직입니다. transform 금지 규칙이 있는 이유는 컨트롤을 확대하면 라벨이 다시 샘플링되기 때문인데, thumb에는 글자가 없고 그 움직임 자체가 곧 컨트롤입니다. `prefers-reduced-motion`에서는 나머지와 함께 0ms가 됩니다.

## 접근성

- 진짜 `role="switch"`와 그 옆의 숨은 `<input>`으로 렌더링됩니다.
- 라벨은 Base UI Field가 묶어 줍니다. 글자를 눌러도 전환됩니다.
- `label`이 없다면 `aria-label`을 주세요.

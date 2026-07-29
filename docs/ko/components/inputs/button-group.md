---
title: ButtonGroup
order: 2
---

# ButtonGroup

<p class="neba-lede">여러 Button을 하나의 세트로 붙여 놓습니다. 맞닿는 모서리가 깎이고, 공통 prop을 세트에 한 번만 지정할 수 있습니다.</p>

<Demo src="button-group/hero" />

```tsx
import { Button, ButtonGroup } from 'neba';

<ButtonGroup variant="outline">
  <Button>일간</Button>
  <Button>주간</Button>
  <Button>월간</Button>
</ButtonGroup>;
```

## Props

<PropsTable name="ButtonGroup" />

`color`를 제외한 `<div>`의 native 속성이 그대로 전달됩니다.

## 예시

### 공통 prop 전달

`variant` · `size` · `color` · `density` · `elevation` · `disabled`를 그룹에 지정하면 모든 자식 [Button](./button)에 전달됩니다. 버튼에 직접 지정한 값이 그룹의 값을 덮어쓰므로, 보조 액션들 사이에 `danger` 버튼 하나만 섞을 수 있습니다.

<Demo src="button-group/shared">

<<< @/.vitepress/demos/button-group/shared.tsx

</Demo>

### orientation

`vertical`은 버튼을 세로로 쌓고 위아래 모서리를 깎습니다.

<Demo src="button-group/orientation">

<<< @/.vitepress/demos/button-group/orientation.tsx

</Demo>

### fullWidth

그룹을 컨테이너 너비만큼 늘리고, 버튼들이 공간을 균등하게 나눠 갖습니다.

<Demo src="button-group/full-width">

<<< @/.vitepress/demos/button-group/full-width.tsx

</Demo>

## 접근성

- `role="group"`으로 렌더링됩니다. 버튼 라벨만으로 세트의 목적을 알 수 없다면 `aria-label`을 붙이세요.
- 선택 상태를 관리하지 않습니다. 여럿 중 하나를 고르는 컨트롤이라면 [SegmentedButton](./segmented-button)이나 [RadioGroup](./radio-group)을 쓰세요.
- hover되거나 focus된 버튼이 이웃보다 위로 올라오므로 focus ring이 잘리지 않습니다.

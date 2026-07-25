---
title: ButtonGroup
order: 2
---

# ButtonGroup

<p class="neba-lede">서로 붙어 있는 버튼들입니다. 이웃과 맞닿는 모서리는 깎이고, 공통 prop은 세트 전체에 한 번만 지정합니다.</p>

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

`color`를 제외한 모든 네이티브 `<div>` 속성이 그대로 통과합니다.

## 예시

### 공통 prop

여기서 벌어지는 일은 두 가지이고, 그중 눈에 보이는 것은 하나뿐입니다. 모서리는 겉모습이고, 나머지 절반은 `variant`·`size`·`color`·`density`·`elevation`·`disabled`를 버튼마다 반복하지 않고 한 번만 적는다는 점입니다. 버튼 하나만 크기가 어긋난 그룹이야말로 이 컴포넌트가 막으려는 실패입니다.

버튼 자신의 prop은 여전히 이깁니다 — 보조 액션들 사이에 `danger` 버튼 하나가 섞이는 경우는 실제로 있습니다.

<Demo src="button-group/shared">

<<< @/.vitepress/demos/button-group/shared.tsx

</Demo>

### 방향

<Demo src="button-group/orientation">

<<< @/.vitepress/demos/button-group/orientation.tsx

</Demo>

### 전체 너비

<Demo src="button-group/full-width">

<<< @/.vitepress/demos/button-group/full-width.tsx

</Demo>

## 이음매가 만들어지는 방식

버튼을 1px 당겨 붙이는 것은 `outline` 그룹뿐입니다. 하이라인 두 개가 맞닿으면 페이지의 다른 모든 가장자리보다 두 배 두꺼운 선이 생기므로, 뒤쪽 버튼을 한 픽셀 당겨 한 줄을 공유하게 만듭니다.

`solid` 그룹은 그렇게 하면 안 됩니다. 그쪽의 이음매는 채워진 표면이 항상 가지고 있는 흰색 안쪽 하이라인, 즉 plate edge 자체입니다. 겹치면 한 버튼의 채움이 이웃의 가장자리를 덮어 전체가 하나의 덩어리로 뭉개집니다.

## 접근성

- `role="group"`으로 렌더링됩니다. 버튼만으로 이 세트가 무엇을 위한 것인지 알 수 없다면 `aria-label`을 붙이세요.
- 이것은 세그먼티드 컨트롤이 **아니며** 선택 상태를 관리하지 않습니다. 여럿 중 하나를 고르는 것이라면 [RadioGroup](./radio-group)을 쓰세요 — 그게 실제로 그 일입니다.
- 호버되거나 포커스된 버튼은 이웃보다 위로 올라오므로 포커스 링이 잘리지 않습니다.

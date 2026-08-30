---
title: RadioGroup
order: 6
---

# RadioGroup

<p class="neba-lede">여러 선택지 중 정확히 하나를 고르는 세트입니다. 선택지마다 설명이 필요하거나 모든 선택지를 펼쳐 보여야 할 때 씁니다.</p>

<Demo src="radio-group/hero" />

```tsx
import { Radio, RadioGroup } from 'neba';

<RadioGroup label="플랜" defaultValue="team">
  <Radio value="starter" label="Starter" />
  <Radio value="team" label="Team" />
</RadioGroup>;
```

## Props

### RadioGroup

<PropsTable name="RadioGroup" />

`value`와 `onValueChange`로 controlled, `defaultValue`로 uncontrolled 컴포넌트가 됩니다.

### Radio

<PropsTable name="Radio" />

`Radio`에는 `size`도 `color`도 없습니다. 둘 다 `RadioGroup`에 지정하면 모든 선택지에 전달됩니다.

선택지가 많아 공간을 아껴야 한다면 [Select](./select), 두세 개를 한 줄에 붙여 놓아야 한다면 [SegmentedButton](./segmented-button)을 쓰세요.

## 예시

### description

선택지마다 설명을 붙일 수 있습니다. 설명이 몇 줄이 되어도 라디오 점은 라벨 첫 줄에 정렬된 채 유지됩니다.

<Demo src="radio-group/descriptions">

<<< @/.vitepress/demos/radio-group/descriptions.tsx

</Demo>

### orientation

기본값은 `vertical`입니다. `horizontal`은 라벨이 짧을 때만 쓰세요 — 라벨 하나가 길어지면 줄이 읽기 어려워집니다.

<Demo src="radio-group/orientation">

<<< @/.vitepress/demos/radio-group/orientation.tsx

</Demo>

### disabled · readOnly

그룹 전체에도, 개별 `Radio`에도 지정할 수 있습니다. 그룹에 지정하면 모든 선택지에 전달됩니다.

<Demo src="radio-group/states">

<<< @/.vitepress/demos/radio-group/states.tsx

</Demo>

### classNames

group과 개별 option은 따로 스타일합니다. 둘은 서로 다른 컴포넌트이기 때문입니다. RadioGroup의 `classNames`는 `label`, `control`, `description`, `error`를 받고, 여기서 `control`은 option들을 담아 가로·세로 방향을 지고 있는 요소입니다. Radio의 `classNames`는 `label`, `control`, `indicator`, `description`을 받고, 여기서 `control`은 점입니다.

```tsx
<RadioGroup label="Plan" classNames={{ control: 'gap-6' }}>
  <Radio value="team" label="Team" classNames={{ control: 'rounded-sm' }} />
</RadioGroup>
```

Radio에는 `error` slot이 없습니다. 유효성 메시지는 질문에 속하고, 질문은 group이기 때문입니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

## 접근성

- 세트 전체가 tab 정지 **하나**를 차지하고, 그 안에서는 방향키로 이동합니다(roving tab index).
- `RadioGroup`의 `label`이 그룹의 accessible name이 됩니다.
- 각 `Radio`의 라벨이 컨트롤과 연결되어 있어 글자를 눌러도 선택됩니다.

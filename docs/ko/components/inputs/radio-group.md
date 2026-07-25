---
title: RadioGroup
order: 6
---

# RadioGroup

<p class="neba-lede">여럿 중 정확히 하나를 고르는 세트입니다. 로빙 탭 인덱스와 방향키는 Base UI가, 그 위에 입혀지는 표면은 이쪽이 담당합니다.</p>

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

### Radio

<PropsTable name="Radio" />

`Radio`에는 자기만의 `size`도 `color`도 없습니다. 둘 다 그룹에서 옵니다. 한 번만 지정해도 세트의 모든 옵션에서 같은 뜻이 되는 자리는 그룹뿐이기 때문입니다 — 라디오 버튼은 혼자서는 아무 의미가 없고, 오직 형제들과의 관계에서만 무언가를 말합니다.

## 예시

### 설명

문장이 필요한 옵션에는 문장을 답니다. 아래에 설명이 얼마나 붙든 점은 라벨 첫 줄에 맞춰 그대로 있습니다.

<Demo src="radio-group/descriptions">

<<< @/.vitepress/demos/radio-group/descriptions.tsx

</Demo>

### 방향

기본은 세로입니다. 가로로 늘어놓은 옵션은 라벨 하나가 예상보다 길어지는 순간까지만 괜찮고, 그 뒤로는 조용히 읽을 수 없게 됩니다.

<Demo src="radio-group/orientation">

<<< @/.vitepress/demos/radio-group/orientation.tsx

</Demo>

### 상태

`disabled`와 `readOnly`는 그룹에도, 옵션 하나에도 걸 수 있습니다. 그룹에 걸린 `readOnly`는 모든 구성원에게 전달됩니다.

<Demo src="radio-group/states">

<<< @/.vitepress/demos/radio-group/states.tsx

</Demo>

## 여기만 둥근 이유

둥글다는 것은 "이 중 아무거나"가 아니라 "이 중 하나"라고 읽는 이에게 말해 주는 신호이고, 이것은 깨뜨렸을 때 얻는 것보다 잃는 것이 많을 만큼 오래된 관습입니다. 그 외에 점을 이루는 모든 것 — 아크릴, 하이라인, 선택 시의 채움 — 은 [Checkbox](./checkbox)와 같습니다.

## 접근성

- 세트 전체가 탭 정지 **한 번**을 차지하고, 그 안에서는 방향키가 움직입니다. 이것이 이 컴포넌트가 input을 나열한 `<div>`가 아니라 컴포넌트인 이유 전부입니다.
- 그룹의 `label`이 접근성 이름이 됩니다.
- 각 `Radio`는 Base UI Field가 라벨과 묶어 주므로 글자를 눌러도 선택됩니다.

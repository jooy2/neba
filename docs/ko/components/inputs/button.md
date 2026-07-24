---
title: Button
order: 1
---

# Button

<p class="neba-lede">액션을 실행하는 컨트롤입니다. Base UI의 Button 프리미티브 위에 Neba의 아크릴 표면을 올렸습니다.</p>

<Demo src="button/hero" />

```tsx
import { Button } from 'neba';

<Button onClick={save}>저장</Button>;
```

## Props

<PropsTable name="Button" />

`<button>`의 네이티브 속성은 그대로 전달됩니다. `color`만 예외로, 위 표의 `color`와 이름이 겹쳐 제외되어 있습니다.

공통 축(`variant` `size` `color` `density` `elevation`)이 컴포넌트 전반에서 뜻하는 바는 [Prop 규약](../../guide/prop-conventions)에 있습니다.

## 예시

### 변형

한 화면에 `solid`는 하나만 두세요. 주 액션이 둘이면 어느 쪽도 주 액션이 아닙니다.

<Demo src="button/variants">

<<< @/.vitepress/demos/button/variants.tsx

</Demo>

### 색

여섯 가지 역할이 전부입니다. 임의의 색상값은 받지 않습니다 — 색은 값이 아니라 역할입니다.

<Demo src="button/colors">

<<< @/.vitepress/demos/button/colors.tsx

</Demo>

### 크기

`md`(32px)가 데스크톱 기본입니다. `xs` `sm`은 툴바와 표 안쪽에, `lg` `xl`은 그 화면이 실제로 요구하는 하나의 액션에 씁니다.

<Demo src="button/sizes">

<<< @/.vitepress/demos/button/sizes.tsx

</Demo>

### 밀도

`density`는 좌우 여백만 바꿉니다. 같은 `size`라면 밀도가 달라도 높이가 같아서, 섞어 놓아도 기준선이 흐트러지지 않습니다.

<Demo src="button/density">

<<< @/.vitepress/demos/button/density.tsx

</Demo>

### 아이콘

아이콘은 `1.2em`으로 그려져 라벨 크기를 따라갑니다. 크기를 따로 줄 필요가 없습니다. 라벨 없이 아이콘만 넘기면 정사각형이 되며, 이때는 `aria-label`이 필요합니다.

<Demo src="button/icons">

<<< @/.vitepress/demos/button/icons.tsx

</Demo>

### 상태

<Demo src="button/states">

<<< @/.vitepress/demos/button/states.tsx

</Demo>

| 상태       | 겉모습                                   | 포커스 | 네이티브 `disabled` |
| ---------- | ---------------------------------------- | ------ | ------------------- |
| `loading`  | 그대로. 스피너가 `startIcon` 자리를 대신 | 유지   | 아니오              |
| `readOnly` | 색은 유지, 평평해지고 채도가 빠짐        | 유지   | 아니오              |
| `disabled` | 색 계열을 버리고 중립 회색               | 빠짐   | 예                  |

세 상태 모두 클릭이 부모로 전파되지 않습니다.

### Elevation

기본값 `0`은 그림자가 전혀 없다는 뜻입니다. 표면을 배경에서 떼어 놓는 것은 아크릴 가장자리입니다. 호버하면 한 단계 오르고 누르면 한 단계 내려가므로, 평평한 버튼도 움직이지 않고 눌린 것을 표현합니다.

<Demo src="button/elevation">

<<< @/.vitepress/demos/button/elevation.tsx

</Demo>

### 전체 너비

<Demo src="button/full-width">

<<< @/.vitepress/demos/button/full-width.tsx

</Demo>

## 접근성

- 항상 네이티브 `<button>`으로 렌더링됩니다. `type`도 그대로 전달되므로 폼 안에서 `type="submit"`이 동작합니다.
- 아이콘 전용 버튼에는 `aria-label`을 주세요.
- 포커스 링은 `:focus-visible`에서만 나타납니다. 마우스 클릭에는 보이지 않습니다.
- `loading`과 `readOnly`는 포커스를 유지합니다. 포커스 순서에서 사라지면 키보드 사용자가 페이지 구조를 잃기 때문입니다.
- 모든 색 조합이 채움 위 글자 4.5:1을 만족합니다.

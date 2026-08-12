---
title: Chip
order: 3
---

# Chip

<p class="neba-lede">태그, 필터, 상태처럼 짧은 값 하나를 담는 작은 토큰입니다. 누르거나 지울 수 있게 만들 수도 있습니다.</p>

<Demo src="chip/hero" />

```tsx
import { Chip } from 'neba';

<Chip>design-system</Chip>
<Chip color="danger" count={12}>오류</Chip>
<Chip onDelete={remove}>typescript</Chip>;
```

## Props

<PropsTable name="Chip" />

Chip의 `size`는 컨트롤 높이보다 한 단계 아래입니다. `md` Chip은 26px로, [Button](../inputs/button)의 `sm`과 같은 높이입니다. 콘텐츠 안에 놓이는 토큰과 행의 기준이 되는 컨트롤을 구분하기 위한 것입니다.

## 예시

### variant와 color

<Demo src="chip/variants">

<<< @/.vitepress/demos/chip/variants.tsx

</Demo>

### startIcon · endIcon · count

`startIcon`과 `endIcon`은 라벨 앞뒤에 놓이는 node입니다. `count`는 별도의 plate 위에 그려져서, "오류 12"가 두 단어가 아니라 숫자가 붙은 토큰 하나로 읽힙니다.

<Demo src="chip/content">

<<< @/.vitepress/demos/chip/content.tsx

</Demo>

### onClick · onDelete · selected

`onClick`을 주면 Chip 전체가 누를 수 있는 컨트롤이 됩니다. `onDelete`는 라벨 뒤에 삭제 버튼을 붙입니다. `selected`는 색 계열을 바꾸지 않고 표면을 한 단계 깊게 만들어 선택 상태를 표시합니다.

<Demo src="chip/interactive">

<<< @/.vitepress/demos/chip/interactive.tsx

</Demo>

### size

<Demo src="chip/sizes">

<<< @/.vitepress/demos/chip/sizes.tsx

</Demo>

## 접근성

- 겉은 항상 `<span>`입니다. `onClick`을 주면 내용을 감싸는 `<button>`이 생기고, `onDelete`를 주면 그 옆에 두 번째 `<button>`이 놓입니다. 두 버튼은 중첩되지 않으므로 각각 키보드로 닿을 수 있습니다.
- 화면에 Chip이 여러 개일 때는 `deleteLabel`로 무엇을 지우는지 밝혀 주세요. 기본 라벨만으로는 삭제 버튼들이 서로 구분되지 않습니다.
- 삭제 버튼의 접근성 이름은 `locale`이 정합니다. `deleteLabel`로 직접 쓸 수도 있습니다.

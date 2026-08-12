---
title: Combobox
order: 12
---

# Combobox

<p class="neba-lede">입력한 글자로 목록을 걸러내면서 값을 고르는 필드입니다. 선택지가 많아 Select로는 찾기 어려울 때, 또는 목록에 없는 값도 받아야 할 때 씁니다.</p>

<Demo src="combobox/hero" />

```tsx
import { Combobox } from 'neba';

<Combobox
  label="프레임워크"
  placeholder="검색하거나 직접 입력하세요"
  items={[
    { value: 'react', label: 'React' },
    { value: 'vue', label: 'Vue' }
  ]}
/>;
```

## Props

<PropsTable name="Combobox" />

### items

[Select](./select)와 같은 배열 형태이며, `label`의 타입만 다릅니다.

```ts
interface ComboboxOption {
  value: string | number;
  label?: string; // ReactNode가 아니라 string
  disabled?: boolean;
}
```

필터가 이 `label`을 상대로 매칭하고 입력란이 이 값을 그대로 채우기 때문에 `string`이어야 합니다.

## 예시

### multiple

고른 값은 필드 안에서 [Chip](../display/chip)으로 표시되고, 입력란은 그 뒤로도 계속 필터로 동작합니다. 입력란이 비어 있을 때 Backspace를 누르면 마지막 chip으로 focus가 이동합니다.

<Demo src="combobox/multiple">

<<< @/.vitepress/demos/combobox/multiple.tsx

</Demo>

### allowCustom · customLabel · emptyMessage

`allowCustom`은 기본값이 켜짐입니다. 입력한 글자가 목록 맨 끝에 별도 행으로 제안되므로, Enter나 클릭, 방향키 모두 다른 행과 같은 방식으로 닿습니다. focus가 빠질 때 조용히 확정되지는 않습니다.

값이 닫힌 집합이라면 `allowCustom={false}`로 끄세요. 이때 일치하는 항목이 없으면 `emptyMessage`가 표시됩니다.

<Demo src="combobox/custom">

<<< @/.vitepress/demos/combobox/custom.tsx

</Demo>

### variant

[TextField](./text-field)와 같은 세 가지 무게를 같은 shell 위에 그립니다.

<Demo src="combobox/variants">

<<< @/.vitepress/demos/combobox/variants.tsx

</Demo>

### size

단일 선택 Combobox는 같은 `size`의 [TextField](./text-field)와 높이가 같습니다. `multiple`에서는 chip이 줄바꿈하는 만큼 필드가 높아지므로 고정 높이를 갖지 않습니다.

<Demo src="combobox/sizes">

<<< @/.vitepress/demos/combobox/sizes.tsx

</Demo>

### disabled · readOnly · error

<Demo src="combobox/states">

<<< @/.vitepress/demos/combobox/states.tsx

</Demo>

### clearable · limit

`clearable`은 값을 비우는 버튼을 붙입니다. `limit`은 팝업에 한 번에 표시할 항목 수를 제한합니다.

## 팝업

[Select](./select)의 팝업과 동일합니다. `<body>` 끝으로 portal되며 positioner에 `neba-portal` 클래스가 붙습니다.

## 접근성

- trigger는 `combobox`, 목록은 `listbox` role을 갖고 `label`이 accessible name이 됩니다.
- 필터링, 팝업 위치 계산과 뒤집힘, 목록과 chip을 가로지르는 방향키 이동, 폼 제출용 hidden input이 모두 처리됩니다.
- `disabled` 항목은 목록에 남은 채 `aria-disabled`로 보고됩니다.
- chip의 제거 버튼 이름은 `removeLabel`이 chip 라벨을 받아 만듭니다.
- 결과 없음 문구와 지우기 · 삭제 버튼의 이름을 `locale`이 정합니다. `emptyMessage`, `clearLabel`, `removeLabel`로 직접 쓸 수도 있습니다.

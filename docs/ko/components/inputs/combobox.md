---
title: Combobox
order: 12
---

# Combobox

<p class="neba-lede">직접 입력할 수도, 목록에서 고를 수도 있는 필드입니다. 입력한 글자는 목록을 걸러내고, 끄지 않는 한 그 자체로 값이 될 수도 있습니다.</p>

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

### 옵션은 데이터입니다

[Select](./select)와 같은 모양이고, 한 가지만 다릅니다.

```ts
interface ComboboxOption {
  value: string | number;
  label?: string; // ReactNode가 아니라 string입니다
  disabled?: boolean;
}
```

여기서 `label`이 `string`인 것은 필터가 이 값을 상대로 매칭하고 입력란이 이 값을 그대로 써 넣기 때문입니다 — 엘리먼트로는 둘 다 할 수 없습니다. 값은 여전히 문자열과 숫자입니다. combobox는 폼 컨트롤이고, 그 값은 제출되는 것입니다.

## 예시

### 여러 개 고르기

고른 값은 필드 안에서 [Chip](../display/chip)이 되고, 입력란은 그 뒤로도 계속 필터 역할을 합니다. 필드가 한 번도 닫히지 않은 채로 태그 묶음이 만들어집니다. 입력란이 비어 있을 때 Backspace를 누르면 마지막 칩으로 손이 갑니다.

<Demo src="combobox/multiple">

<<< @/.vitepress/demos/combobox/multiple.tsx

</Demo>

### 목록에 없는 값

이것이 검색되는 select와 combobox를 가르는 지점이고, 기본으로 켜져 있습니다.

입력한 글자는 포커스가 빠질 때 조용히 확정되는 대신, 목록 맨 끝에 자기 행으로 제안됩니다. 의도된 것입니다 — 쓰다 만 단어를 포커스가 떠나는 순간 값으로 만들어 버리는 필드는 데이터를 지어내는 필드입니다. 행으로 만들면 Enter도, 클릭도, 방향키도 다른 모든 행과 똑같은 방식으로 그곳에 닿고, 스크린 리더도 하나의 옵션으로 읽습니다.

타이핑하는 동안 첫 번째 일치 항목에 불이 들어오므로, 필요한 것은 여전히 키 하나입니다. 목록에 있는 것을 치면 Enter가 그것을 고르고, 없는 것을 치면 Enter가 그것을 더합니다.

값이 닫힌 집합인 필드라면 `allowCustom={false}`로 끄세요. 그때는 아무것도 찾지 못한 검색이 하는 말이 `emptyMessage`입니다.

<Demo src="combobox/custom">

<<< @/.vitepress/demos/combobox/custom.tsx

</Demo>

### Variant

[TextField](./text-field)와 같은 세 가지 무게를, 같은 셸 위에 그립니다.

<Demo src="combobox/variants">

<<< @/.vitepress/demos/combobox/variants.tsx

</Demo>

### 크기

필드 안의 칩은 컨트롤 사다리에서 한 칸 아래에 앉고, 남는 만큼이 필드의 상하 여백이 됩니다 — 그래서 한 줄짜리 combobox는 옆에 선 필드와 정확히 같은 높이입니다. `multiple`에서는 칩이 줄바꿈하는 만큼 필드가 자라며, 고정 높이를 갖지 않습니다.

<Demo src="combobox/sizes">

<<< @/.vitepress/demos/combobox/sizes.tsx

</Demo>

### 상태

<Demo src="combobox/states">

<<< @/.vitepress/demos/combobox/states.tsx

</Demo>

## 팝업

[Select](./select)의 것과 동일합니다. combobox의 목록과 select의 목록은 같은 목록이기 때문입니다 — 3단계 그림자를 단 떠 있는 표면이고, `<body>` 끝으로 포털되며, CSS 리셋을 서브트리에 한정해 둔 호스트를 위해 positioner에 `neba-portal`이 걸려 있습니다.

## 접근성

- 필터링과 그 콜레이터, 팝업의 위치 계산과 뒤집힘, `combobox`/`listbox` 연결, 목록과 칩을 가로지르는 방향키 이동, 폼 제출을 가능하게 하는 숨은 input은 모두 Base UI가 담당합니다.
- `label`이 접근성 이름이 됩니다.
- 비활성 옵션은 목록에 남은 채 `aria-disabled`로 보고됩니다 — 옵션은 존재하고, 다만 고를 수 없을 뿐입니다.
- 칩의 제거 버튼 이름은 `removeLabel`이 짓고, 칩의 라벨을 받습니다. 그래서 버튼은 그냥 _Remove_가 아니라 _Remove documentation_이라고 말합니다.

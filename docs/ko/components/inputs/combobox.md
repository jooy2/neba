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

`<div>`의 native 속성은 root로 전달됩니다. 다만 `aria-label`과 `aria-labelledby`는 `<input>`의 이름이 됩니다. `color`와 `defaultValue`만 위 표와 이름이 겹쳐 제외됩니다.

팝업은 [Select](./select)의 팝업과 같습니다. `<body>` 끝으로 portal되며 positioner에 `neba-portal` 클래스가 붙습니다.

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

`clearable`은 값을 비우는 버튼을 붙입니다. `limit`은 팝업에 한 번에 표시할 옵션 수를 제한합니다. 입력한 값을 추가하는 행은 그 수에 들어가지 않으므로, 목록이 가득 차도 새 값을 받을 수 있습니다.

### filter

기본값은 입력한 글자로 목록을 좁히는 것입니다. 각 옵션의 label에 대해 대소문자와 악센트를 무시하고 비교합니다.

**서버가 이미 좁혀 준 목록에는 `filter={false}`가 필요합니다.** 키워드나 설명, 동의어로 검색한 결과에는 눈에 보이는 label에 질의가 들어 있지 않은 행이 섞여 있고, 여기서 한 번 더 거르면 검색이 찾아 준 결과가 바로 그 행들과 함께 사라집니다. `onInputValueChange`에서 요청하고, 받은 결과를 `items`에 넘기고, 거르지 않으면 됩니다.

```tsx
<Combobox
  items={results}
  filter={false}
  onInputValueChange={(query) => search(query)}
  label="Customer"
/>
```

함수를 넘기면 옵션마다 직접 판단합니다. label뿐 아니라 `value`까지 보거나, 단어 중간이 아니라 앞부터 맞는 것만 남기는 식입니다. 입력한 값을 추가하겠다고 제안하는 행은 어떤 경우에도 걸러지지 않습니다.

### shortcuts

`shortcuts`는 키 조합과 그 조합이 할 일을 짝지어 받으며, 조합은 [Shortcut](../display/shortcut)이 그리는 표기 그대로 씁니다. `Mod`는 Mac에서 Command, 그 밖에서는 Control이며 modifier는 정확히 일치해야 합니다.

```tsx
<Combobox label="Framework" items={frameworks} shortcuts={{ 'Mod+Enter': createAndOpen }} />
```

화살표는 highlight를 옮기고 `Escape`는 팝업을 닫고 `Enter`는 확정합니다. 이 키들은 root에 쓴 `onKeyDown`에 도달하지 않으므로, Combobox에서 이 키에 반응하려면 `shortcuts`를 써야 합니다.

shortcut은 `<input>`에 붙어 목록이 키를 처리하기 **전에** 실행되지만, 목록이 하는 일을 **대신하지는** 않습니다. `Enter`에 건 shortcut은 확정과 함께 실행되지 그것을 막지 않습니다. 키를 온전히 가져야 한다면 목록이 쓰지 않는 조합을 고르세요.

### classNames

`className`은 루트(라벨과 shell, 그 아래 두 줄을 담는 열)에 붙고, `<input>` 자체는 `classNames.control`로 갑니다.

```tsx
<Combobox
  items={frameworks}
  label="Framework"
  multiple
  classNames={{ control: 'font-mono', chip: 'rounded-none', popup: 'max-h-40' }}
/>
```

slot은 `label`, `shell`, `control`, `description`, `error`, `chip`, `popup`, `item`입니다. `chip`은 multiple 모드에서 input 앞에 놓이는 토큰 하나입니다. `popup`과 `item`은 `<body>` 끝에 그려지므로 루트를 기준으로 쓴 것으로는 닿지 않습니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

## 접근성

- trigger는 `combobox`, 목록은 `listbox` role을 갖고 `label`이 accessible name이 됩니다.
- 필터링, 팝업 위치 계산과 뒤집힘, 목록과 chip을 가로지르는 방향키 이동, 폼 제출용 hidden input이 모두 처리됩니다.
- `disabled` 항목은 목록에 남은 채 `aria-disabled`로 보고됩니다.
- chip의 제거 버튼 이름은 `removeLabel`이 chip 라벨을 받아 만듭니다.
- 결과 없음 문구와 지우기 · 삭제 버튼의 이름을 `locale`이 정합니다. `emptyMessage`, `clearLabel`, `removeLabel`로 직접 쓸 수도 있습니다.

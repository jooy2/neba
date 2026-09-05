---
title: Transfer
order: 31
---

# Transfer

<p class="neba-lede">두 개의 목록과 그 사이의 화살표입니다. 한쪽에는 고를 수 있는 것 전부, 다른 쪽에는 이미 고른 것. 칩으로 가득 찬 필드가 더 이상 읽히지 않을 만큼 선택지가 많을 때 씁니다.</p>

<Demo src="transfer/hero" />

```tsx
import { Transfer } from 'neba';

<Transfer
  items={[
    { value: 'status', label: 'Status' },
    { value: 'commit', label: 'Commit' }
  ]}
  value={shown}
  onValueChange={setShown}
/>;
```

## Props

<PropsTable name="Transfer" />

`<div>`의 모든 속성이 `color`를 제외하고 그대로 전달됩니다.

### TransferItem

<PropsTable name="TransferItem" />

선택지가 열 개 남짓이라면 `multiple`을 켠 [Combobox](./combobox)나 [Checkbox](./checkbox) 한 열이 더 작은 컴포넌트입니다. 이 컴포넌트는 "내가 결국 무엇을 골랐는가"에 별도의 목록이 필요할 때 제 몫을 합니다.

## 예시

### value와 onValueChange

값은 **오른쪽**에 있는 것이며, `items`가 준 순서를 따릅니다. 그래서 보냈다가 되돌려도 행의 자리가 바뀌지 않습니다. 행에 체크하는 것은 고르는 것이 아닙니다. 체크는 다음 버튼이 무엇을 옮길지를 말하고, 값은 그것들이 어느 쪽에 있는지를 말합니다.

### searchable

각 목록 위에 필터를 둡니다. 행을 숨길 뿐 옮기지는 않으며, 숨겨진 행은 버튼이 옮기는 대상에 들어가지 않습니다.

<Demo src="transfer/searchable">

<<< @/.vitepress/demos/transfer/searchable.tsx

</Demo>

### height · disabled

`height`는 각 목록의 높이입니다. `disabled`인 항목은 자기 목록에 남고 체크되지도 옮겨지지도 않습니다. 컴포넌트 전체의 `disabled`는 모든 항목에 같은 일을 합니다.

<Demo src="transfer/states">

<<< @/.vitepress/demos/transfer/states.tsx

</Demo>

### locale · sourceLabel · targetLabel

제목과 버튼과 필터의 문구는 `locale`에서 옵니다. `sourceLabel`과 `targetLabel`은 두 제목을 직접 씁니다. 대개는 이쪽을 쓰게 됩니다. "선택 가능"과 "선택함"이 그 두 목록의 실제 이름인 경우는 드뭅니다.

## 접근성

- 모든 행이 라벨과 연결된 진짜 checkbox이므로 Tab과 Space만으로 전부 조작할 수 있습니다.
- 각 목록 위의 체크는 그 목록의 `Select all`이며, 일부만 체크된 동안에는 mixed 상태를 알립니다.
- 두 버튼 모두 "Move to selected", "Move to available"이라는 이름을 가지며, 옮길 것이 없으면 사용 불가가 됩니다.

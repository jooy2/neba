---
title: TreeSelect
order: 13
---

# TreeSelect

<p class="neba-lede">목록이 아니라 트리에서 값을 고릅니다. 카테고리 · 폴더 · 지역 · 조직도 노드처럼, 평평한 목록이 뭉개 버리는 것들을 위한 것입니다.</p>

<Demo src="tree-select/hero" />

```tsx
import { TreeSelect } from 'neba';

<TreeSelect label="카테고리" items={categories} value={value} onValueChange={setValue} />;
```

## Props

<PropsTable name="TreeSelect" />

### items

<PropsTable name="TreeSelectItem" />

`value`는 형제들 사이에서만이 아니라 **트리 전체에서** 유일해야 합니다. 컴포넌트가 노드를 찾는 열쇠이기 때문입니다.

### 어느 쪽을 쓸까

| 선택지가                               | 쓸 것                            |
| -------------------------------------- | -------------------------------- |
| 평평한 목록                            | [Select](./select)               |
| 타이핑해서 좁히는 평평한 목록          | [Combobox](./combobox)           |
| 계층 구조이고, 거기서 고른다           | TreeSelect                       |
| 계층 구조를 고르는 게 아니라 보여 준다 | [TreeView](../display/tree-view) |

## 예시

### selectableBranches

기본값은 꺼짐이고, 이 기본값에는 무게가 있습니다. 이런 트리의 대부분에서 가지는 분류 체계이고 잎이 답입니다. "France" 옆에서 함께 고를 수 있는 "Europe"은 보통 아무도 의도하지 않은 데이터 모델입니다.

고를 수 없는 가지도 펼치고 접히는 것은 그대로입니다. item 자신의 `selectable`이 어느 방향으로든 이 설정을 덮으므로, 제목들의 트리에서 하나만 고를 수 있게 하거나 반대로 하는 것도 됩니다.

### multiple

몇 개든 담고, `format`이 달리 말하지 않으면 trigger가 쉼표로 이어 씁니다. `closeOnSelect`가 이것을 따라갑니다 — 값이 하나인 TreeSelect는 첫 선택에서 닫히고, multiple은 열린 채로 있습니다.

### searchable

트리 위에 그것을 거르는 필드를 붙입니다.

**일치한 노드는 조상을 함께 남기고**, 필터가 남긴 모든 가지를 펼칩니다. 둘 다 중요합니다. 일치한 것만 남긴 트리는 목록이고, 잎만 모은 목록이야말로 트리를 고른 이유였습니다 — 위에 아무것도 없는 "Seoul"은 어느 분류에서 왔는지 말하지 않고, 닫힌 부모 안에 접혀 있는 일치는 독자에게 보여 주지 않은 일치입니다.

`label`이 문자열이 아니라 노드일 때 무엇과 대조할지는 `searchLabel`이 정합니다.

### format

trigger가 담긴 것을 쓰는 방식입니다.

```tsx
format={(chosen) => (chosen.length === 1 ? chosen[0].label : `${chosen.length}개 카테고리`)}
```

### name

폼 제출 시 값 하나당 hidden input 하나로 나갑니다. `multiple`이 `<select multiple>`처럼 반복 필드로 도착합니다.

## 접근성

- 팝업은 `role="tree"`와 `role="treeitem"` 행들을 담고, 방향키 이동과 단일 tab 정지를 [TreeView](../display/tree-view)에서 가져옵니다.
- 가지의 accessible name에는 그 아래 subtree가 포함됩니다. 행의 element가 자식을 담고 있기 때문입니다. 질의와 테스트는 행 자신의 텍스트로 하세요.
- 고를 수 없는 노드는 `aria-disabled`를 달고 자리를 지키므로 방향키 경로에서 빠지지 않습니다.
- 팝업은 `<body>` 끝으로 portal되며 positioner에 `neba-portal` 클래스가 붙습니다.

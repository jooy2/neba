---
title: TreeSelect
order: 13
flutter: true
---

# TreeSelect

<p class="neba-lede">목록이 아니라 트리에서 값을 고릅니다. 카테고리, 폴더, 지역, 조직도 노드처럼 평평한 목록으로는 계층이 드러나지 않는 값에 씁니다.</p>

<Demo src="tree-select/hero" minHeight="380" />

::: fw react

```tsx
import { TreeSelect } from 'neba';

<TreeSelect label="카테고리" items={categories} value={value} onValueChange={setValue} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaTreeSelect<String>(
  label: const Text('카테고리'),
  items: categories,
  value: value,
  onValueChange: (List<String> next) => setState(() => value = next),
);
```

:::

## Props

<PropsTable name="TreeSelect" />

::: fw flutter

`NebaTreeSelect`는 값의 타입에 대해 제네릭이며, `label`, `placeholder`, `description`, `error`는 위젯이고 보통 `Text`입니다. `value`와 `defaultValue`는 `multiple`과 상관없이 리스트이고, 아무것도 없으면 빈 리스트입니다. React는 값 하나나 `null`도 받습니다. `value`를 `null`로 두면 컴포넌트가 상태를 스스로 관리합니다. `semanticLabel`은 `aria-label`처럼 자기 라벨이 없는 trigger에 이름을 붙입니다. `startIcon`과 `fullWidth`는 React와 마찬가지로 picker shell의 것입니다.

`name`, `required`, `classNames`는 없습니다. Flutter에서는 이 컨트롤을 담아 제출하는 폼이 없고, 각 부분의 스타일은 공용 prop으로 정합니다. 팝업은 [Popover](../surfaces/popover)처럼 앱의 root `Overlay`에 그려집니다.

:::

### items

<PropsTable name="TreeSelectItem" />

`value`는 형제들 사이에서만이 아니라 **트리 전체에서** 유일해야 합니다. 컴포넌트가 노드를 찾는 열쇠이기 때문입니다.

::: fw flutter

```dart
const NebaTreeSelectItem<String>(
  value: 'europe',
  label: Text('Europe'), // 없으면 value의 텍스트
  selectable: false,
  children: <NebaTreeSelectItem<String>>[
    NebaTreeSelectItem<String>(value: 'fr', label: Text('France')),
  ],
);
```

:::

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

몇 개든 담고, `format`이 달리 말하지 않으면 trigger가 쉼표로 이어 씁니다. `closeOnSelect`가 이것을 따라갑니다. 값이 하나인 TreeSelect는 첫 선택에서 닫히고, multiple은 열린 채로 있습니다.

### searchable

트리 위에 그것을 거르는 필드를 붙입니다.

**일치한 노드는 조상을 함께 남기고**, 필터가 남긴 모든 가지를 펼칩니다. 둘 다 중요합니다. 일치한 것만 남긴 트리는 목록이고, 잎만 모은 목록이야말로 트리를 고른 이유였습니다. 위에 아무것도 없는 "Seoul"은 어느 분류에서 왔는지 말하지 않고, 닫힌 부모 안에 접혀 있는 일치는 독자에게 보여 주지 않은 일치입니다.

`label`이 <Fw react="문자열이 아니라 노드일 때" flutter="`Text`가 아닌 위젯일 때" /> 무엇과 대조할지는 `searchLabel`이 정합니다.

### format

trigger가 담긴 것을 쓰는 방식입니다.

::: fw react

```tsx
format={(chosen) => (chosen.length === 1 ? chosen[0].label : `${chosen.length}개 카테고리`)}
```

:::

::: fw flutter

```dart
format: (List<NebaTreeSelectItem<String>> chosen) =>
    chosen.length == 1 ? chosen.first.label! : Text('${chosen.length}개 카테고리'),
```

:::

### labelPlacement

`notch`와 `float`는 [TextField](./text-field#labelplacement)와 같게 동작합니다. `float` 라벨은 아무것도 고르지 않았고 trigger에 포커스가 없으며 popup이 닫혀 있는 동안 trigger 안에 있습니다.

<Demo src="tree-select/label-placement" minHeight="300">

::: fw react

<<< @/.vitepress/demos/tree-select/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_select/label_placement.dart

:::

</Demo>

::: fw react

### name

폼 제출 시 값 하나당 input 하나로 나갑니다. `multiple`이 `<select multiple>`처럼 반복 필드로 도착합니다. [Form](./form) 안에서는 `onSubmit`이 `name` 아래의 값을 받고, `multiple`이면 배열로 받습니다. `required`인 TreeSelect는 아무것도 고르지 않았으면 제출을 막고, Form에 `name`으로 넘긴 오류가 필드 아래에 나옵니다.

:::

## 접근성

::: fw react

- 팝업은 `role="tree"`와 `role="treeitem"` 행들을 담고, 방향키 이동과 단일 tab 정지를 [TreeView](../display/tree-view)에서 가져옵니다.
- 가지의 accessible name에는 그 아래 subtree가 포함됩니다. 행의 element가 자식을 담고 있기 때문입니다. 질의와 테스트는 행 자신의 텍스트로 하세요.
- 고를 수 없는 노드는 `aria-disabled`를 달고 자리를 지키므로 방향키 경로에서 빠지지 않습니다.
- 팝업은 `<body>` 끝으로 portal되며 positioner에 `neba-portal` 클래스가 붙습니다.

:::

::: fw flutter

- trigger는 `label`로 이름 붙은 버튼이며, 담긴 것과 팝업이 펼쳐졌는지를 알립니다. Enter와 Space로 열리고, 값 옆의 ×는 `clearLabel`로 이름 붙은 별도의 버튼입니다.
- 팝업은 [TreeView](../display/tree-view)를 담으므로 방향키 이동, focus 순서의 단일 정지점, 중첩된 목록으로 읽히는 행을 그대로 가져옵니다. 열리면 focus가 검색 필드로, 검색 필드가 없으면 트리로 갑니다. Escape, 바깥 누르기, 값이 하나일 때의 선택은 팝업을 닫고 focus를 trigger에 돌려줍니다.
- 비활성 노드는 사용할 수 없다고 읽히며 자리를 지키므로 방향키 경로에서 빠지지 않습니다.

:::

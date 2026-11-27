---
title: TreeView
order: 13
flutter: true
---

# TreeView

<p class="neba-lede">서로 속해 있는 항목들을 접었다 펼 수 있는 행으로 보여줍니다. 폴더 목록, 사이드바 내비게이션, 접어 둘 수 있어야 하는 그룹 목록에 씁니다.</p>

<Demo src="tree-view/hero" />

::: fw react

```tsx
import { TreeItem, TreeView } from 'neba';

<TreeView label="Project files" lines="folder" defaultExpanded={['src']}>
  <TreeItem value="src" label="src">
    <TreeItem value="index" label="index.ts" />
  </TreeItem>
  <TreeItem value="readme" label="README.md" />
</TreeView>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaTreeView<String>(
  label: 'Project files',
  lines: NebaTreeViewLines.folder,
  defaultExpanded: <String>['src'],
  children: <NebaTreeItem<String>>[
    NebaTreeItem<String>(
      value: 'src',
      label: Text('src'),
      children: <NebaTreeItem<String>>[
        NebaTreeItem<String>(value: 'index', label: Text('index.ts')),
      ],
    ),
    NebaTreeItem<String>(value: 'readme', label: Text('README.md')),
  ],
);
```

:::

## Props

### TreeView

<PropsTable name="TreeView" />

::: fw react

`expanded`와 `onExpandedChange`로 열림 상태가 controlled가 되고, `defaultExpanded`로는 uncontrolled가 됩니다. 선택은 `selected`와 `onSelectedChange`가 같은 방식으로 다루며, 두 값 모두 행의 `value` 배열입니다.

나머지 `<ul>` 속성은 그대로 트리에 전달됩니다. 공용 축은 [prop 규약](../../design/prop-conventions)에 있습니다.

:::

::: fw flutter

`NebaTreeView`는 행 value의 타입에 대해 제네릭입니다. `expanded`와 `onExpandedChange`로 열림 상태가 controlled가 되고, `null`로 두면 트리가 `defaultExpanded`에서 시작해 상태를 스스로 관리합니다. 선택은 `selected`와 `onSelectedChange`가 같은 방식으로 다루며, 두 값 모두 행의 `value` 리스트입니다. `label`은 `aria-label`처럼 화면 낭독기가 듣는 이름입니다. 트리는 주어진 너비를 채웁니다. 공용 축은 [prop 규약](../../design/prop-conventions)에 있습니다.

:::

### TreeItem

<PropsTable name="TreeItem" />

::: fw react

나머지 `<li>` 속성은 그대로 행에 전달됩니다.

:::

::: fw flutter

행은 위젯이 아니라 행을 설명하는 `NebaTreeItem`이고, 그 아래 행들은 같은 것의 리스트인 `children`입니다. 어떤 행이 보이는지, 방향키가 다음에 어디로 가는지는 트리 전체에 대한 질문이라서 트리가 모든 행을 직접 그립니다. `value`가 없는 행은 React가 하나를 생성하듯 자리로 이름이 붙습니다. 열고 닫고 선택할 수 있지만, 트리가 알리는 목록에서는 빠집니다. `onPressed`는 React의 `onClick`이며 행이 열리거나 선택되기 전에 호출됩니다. 여기서 그 둘을 취소할 수는 없으므로, 열리거나 선택되면 안 되는 행에는 `selectable: false`나 controlled `expanded`를 쓰세요.

:::

## 예시

### lines

`lines`는 계층을 어떻게 그릴지 정합니다. `none`은 들여쓰기만 하고, `simple`은 레벨마다 세로선 하나를 내리며, `folder`는 거기에 각 행으로 꺾여 들어가는 선을 더하고 가지의 마지막 자식 아래에서 세로선을 끊습니다.

<Demo src="tree-view/lines">

::: fw react

<<< @/.vitepress/demos/tree-view/lines.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_view/lines.dart

:::

</Demo>

### variant

sheet는 색으로 채워지지 않습니다. 이미 표면이 있는 [Card](../surfaces/card)나 사이드바 안에서는 `text`를 쓰세요.

<Demo src="tree-view/variants">

::: fw react

<<< @/.vitepress/demos/tree-view/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_view/variants.dart

:::

</Demo>

### 행 선택

행을 누르면 선택되고 가지가 열립니다. 이미 열린 가지는 닫힙니다. `multiple`을 켜면 여러 행을 동시에 선택할 수 있고, 끄면 새 행을 고를 때마다 앞의 선택이 교체됩니다.

펼침 화살표는 별도의 과녁입니다. 행을 선택하지 않고 가지만 열고 닫습니다. <Fw react="`selectable={false}`인" flutter="`selectable: false`인" /> 행은 선택되지 않고, 누르면 가지를 펼치고 접기만 합니다.

<Demo src="tree-view/selection">

::: fw react

<<< @/.vitepress/demos/tree-view/selection.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_view/selection.dart

:::

</Demo>

### href

::: fw react

`href`가 있는 행은 링크로 렌더링되며, 내비게이션 트리는 이것으로 만듭니다. 별도의 tab stop이 되지는 않습니다. 트리 전체가 하나이고, 행에는 방향키로 갑니다.

:::

::: fw flutter

`href`가 있는 행은 그 주소로 가는 링크로 읽히며, 내비게이션 트리는 이것으로 만듭니다. 패키지는 스스로 아무것도 열지 않으므로, 링크를 따라가는 일은 행의 `onPressed`가 맡습니다. 누르기, Enter, Space가 모두 이것을 부릅니다. focus 순서에서 별도의 정지점이 되지는 않습니다. 트리 전체가 하나이고, 행에는 방향키로 갑니다.

:::

<Demo src="tree-view/navigation">

::: fw react

<<< @/.vitepress/demos/tree-view/navigation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tree_view/navigation.dart

:::

</Demo>

### keepMounted

::: fw react

기본적으로 닫힌 가지는 DOM에 없으므로, 서버 렌더를 읽는 크롤러는 그 안의 링크를 보지 못합니다. `keepMounted`를 주면 닫힌 가지가 모두 접힌 채 `inert`로 DOM에 남아, 내비게이션 트리의 링크가 전부 서버 렌더에 들어갑니다. 닫힌 가지의 행은 tab 순서에도, 방향키가 지나가는 행에도 들어가지 않습니다. 행이 수천 개인 트리라면 그 전부를 첫 렌더에 만듭니다.

```tsx
<TreeView label="Docs" keepMounted>
  <TreeItem value="guide" label="Guide" href="/guide">
    <TreeItem value="install" label="Installation" href="/guide/install" />
  </TreeItem>
</TreeView>
```

:::

::: fw flutter

기본적으로 닫힌 가지의 행은 빌드되지 않습니다. `keepMounted`를 주면 접힌 채로 빌드된 상태가 유지되어, 가지가 닫혀도 행이 가진 상태가 남습니다. 닫힌 가지의 행은 focus 순서에도, 방향키가 지나가는 행에도, 화면 낭독기가 듣는 내용에도 들어가지 않습니다. Flutter 화면에는 크롤러가 읽을 서버 렌더가 없으므로 React에서 이것을 쓰는 이유는 생기지 않습니다. 행이 수천 개인 트리라면 그 전부를 첫 빌드에 만듭니다.

```dart
NebaTreeView<String>(
  label: 'Docs',
  keepMounted: true,
  children: <NebaTreeItem<String>>[
    NebaTreeItem<String>(
      value: 'guide',
      label: const Text('Guide'),
      children: <NebaTreeItem<String>>[
        NebaTreeItem<String>(value: 'install', label: const Text('Installation')),
      ],
    ),
  ],
);
```

:::

### expandable

`keepMounted`를 켜지 않으면 닫힌 가지는 <Fw react="DOM에 없으므로" flutter="빌드되지 않으므로" />, 행을 처음 열 때 자식을 가져오는 트리에는 아직 그릴 것이 없습니다. `expandable`은 그래도 화살표를 그립니다. `onExpandedChange`에서 가져온 뒤, 도착하면 행을 렌더링하세요.

::: fw react

```tsx
<TreeView expanded={expanded} onExpandedChange={load}>
  <TreeItem value="remote" label="Remote" expandable>
    {children.map((child) => (
      <TreeItem key={child.id} value={child.id} label={child.name} />
    ))}
  </TreeItem>
</TreeView>
```

:::

::: fw flutter

```dart
NebaTreeView<String>(
  expanded: expanded,
  onExpandedChange: load,
  children: <NebaTreeItem<String>>[
    NebaTreeItem<String>(
      value: 'remote',
      label: const Text('Remote'),
      expandable: true,
      children: <NebaTreeItem<String>>[
        for (final Child child in children)
          NebaTreeItem<String>(value: child.id, label: Text(child.name)),
      ],
    ),
  ],
);
```

:::

## 접근성

::: fw react

- 트리는 `tree`, 각 행은 `treeitem`, 가지의 자식들은 `group`입니다.

:::

::: fw flutter

- Flutter에는 tree role이 없어서, 트리는 `label`로 이름 붙은 목록으로, 각 행은 그 항목으로, 가지의 자식들은 그 항목 안의 목록으로 읽힙니다. 행 자체는 버튼이고 `href`가 있으면 링크이며, 가지가 있으면 펼침과 접힘을, 선택되면 선택됨을 알립니다.

:::

- 트리 전체가 <Fw react="하나의 tab stop입니다" flutter="focus 순서에서 하나의 정지점입니다" />. 안에 들어오면 ArrowUp·ArrowDown이 보이는 행들을 오르내리고, ArrowRight는 닫힌 가지를 열고 열린 가지에서는 그 안으로 들어가며, ArrowLeft는 가지를 닫고 잎에서는 부모로 올라갑니다. Home·End는 양 끝으로 가고, 글자를 치면 레이블이 그 글자로 시작하는 다음 행으로 갑니다. Enter와 Space는 focus된 행을 누른 것과 같아서 행을 선택하고 가지를 열거나 닫으며, <Fw react="링크인 행에서는 Enter가 링크도 따라갑니다" flutter="행의 `onPressed`도 부릅니다" />. 방향키는 선택을 바꾸지 않습니다.
- RTL에서는 ArrowLeft와 ArrowRight가 바뀌므로, 전진 방향의 화살표는 언제나 "더 안쪽"을 뜻합니다.
- `label`을 넘겨 트리에 이름을 주세요. 없으면 screen reader가 이름 없는 <Fw react="트리로" flutter="목록으로" /> 읽습니다.

::: fw react

- `multiple`은 트리에 `aria-multiselectable`을 붙입니다.
- `keepMounted`로 DOM에 남은 가지는 닫혀 있는 동안 `inert`입니다. tab 순서와 accessibility tree에서 빠지고, 브라우저의 페이지 내 찾기에도 걸리지 않습니다.

:::

::: fw flutter

- `multiple`이면 선택할 수 있는 행마다 선택되었는지 아닌지를 알리므로, "선택 안 됨"도 빠지지 않고 들립니다.
- `keepMounted`로 빌드된 채 남은 가지는 닫혀 있는 동안, 그리고 닫히기 시작한 순간부터 focus 순서와 semantics tree에서 빠집니다.

:::

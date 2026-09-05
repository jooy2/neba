---
title: TreeView
order: 13
---

# TreeView

<p class="neba-lede">서로 속해 있는 항목들을 접었다 펼 수 있는 행으로 보여줍니다. 폴더 목록, 사이드바 내비게이션, 접어 둘 수 있어야 하는 그룹 목록에 씁니다.</p>

<Demo src="tree-view/hero" />

```tsx
import { TreeItem, TreeView } from 'neba';

<TreeView label="Project files" lines="folder" defaultExpanded={['src']}>
  <TreeItem value="src" label="src">
    <TreeItem value="index" label="index.ts" />
  </TreeItem>
  <TreeItem value="readme" label="README.md" />
</TreeView>;
```

## Props

### TreeView

<PropsTable name="TreeView" />

`expanded`와 `onExpandedChange`로 열림 상태가 controlled가 되고, `defaultExpanded`로는 uncontrolled가 됩니다. 선택은 `selected`와 `onSelectedChange`가 같은 방식으로 다루며, 두 값 모두 행의 `value` 배열입니다.

나머지 `<ul>` 속성은 그대로 트리에 전달됩니다. 공용 축은 [prop 규약](../../design/prop-conventions)에 있습니다.

### TreeItem

<PropsTable name="TreeItem" />

나머지 `<li>` 속성은 그대로 행에 전달됩니다.

## 예시

### lines

`lines`는 계층을 어떻게 그릴지 정합니다. `none`은 들여쓰기만 하고, `simple`은 레벨마다 세로선 하나를 내리며, `folder`는 거기에 각 행으로 꺾여 들어가는 선을 더하고 가지의 마지막 자식 아래에서 세로선을 끊습니다.

<Demo src="tree-view/lines">

<<< @/.vitepress/demos/tree-view/lines.tsx

</Demo>

### variant

sheet는 색으로 채워지지 않습니다. 이미 표면이 있는 [Card](../surfaces/card)나 사이드바 안에서는 `text`를 쓰세요.

<Demo src="tree-view/variants">

<<< @/.vitepress/demos/tree-view/variants.tsx

</Demo>

### 행 선택

행을 누르면 선택되고, 자식이 있으면 함께 열립니다. `multiple`을 켜면 여러 행을 동시에 선택할 수 있고, 끄면 새 행을 고를 때마다 앞의 선택이 교체됩니다.

펼침 화살표는 별도의 과녁입니다. 행을 선택하지 않고 가지만 엽니다.

<Demo src="tree-view/selection">

<<< @/.vitepress/demos/tree-view/selection.tsx

</Demo>

### href

`href`가 있는 행은 링크로 렌더링되며, 내비게이션 트리는 이것으로 만듭니다. 별도의 tab stop이 되지는 않습니다. 트리 전체가 하나이고, 행에는 방향키로 갑니다.

<Demo src="tree-view/navigation">

<<< @/.vitepress/demos/tree-view/navigation.tsx

</Demo>

### expandable

닫힌 가지는 DOM에 없으므로, 행을 처음 열 때 자식을 가져오는 트리에는 아직 그릴 것이 없습니다. `expandable`은 그래도 화살표를 그립니다. `onExpandedChange`에서 가져온 뒤, 도착하면 행을 렌더링하세요.

```tsx
<TreeView expanded={expanded} onExpandedChange={load}>
  <TreeItem value="remote" label="Remote" expandable>
    {children.map((child) => (
      <TreeItem key={child.id} value={child.id} label={child.name} />
    ))}
  </TreeItem>
</TreeView>
```

## 접근성

- 트리는 `tree`, 각 행은 `treeitem`, 가지의 자식들은 `group`입니다.
- 트리 전체가 하나의 tab stop입니다. 안에 들어오면 ArrowUp·ArrowDown이 보이는 행들을 오르내리고, ArrowRight는 닫힌 가지를 열고 열린 가지에서는 그 안으로 들어가며, ArrowLeft는 가지를 닫고 잎에서는 부모로 올라갑니다. Home·End는 양 끝으로, Enter는 focus된 행을 선택합니다. 방향키는 선택을 바꾸지 않습니다.
- RTL에서는 ArrowLeft와 ArrowRight가 바뀌므로, 전진 방향의 화살표는 언제나 "더 안쪽"을 뜻합니다.
- `label`을 넘겨 트리에 이름을 주세요. 없으면 screen reader가 이름 없는 트리로 읽습니다.
- `multiple`은 트리에 `aria-multiselectable`을 붙입니다.

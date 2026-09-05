---
title: DataTable
order: 17
---

# DataTable

<p class="neba-lede">행이 아주 많은 표입니다. 화면에 보이는 행만 그리고, 정렬하고 검색하며, 파일 탐색기와 같은 방식으로 행을 고를 수 있습니다. 데이터 격자가 읽는 것이 아니라 작업하는 곳일 때 쓰세요.</p>

<Demo src="data-table/hero" minHeight="380" />

```tsx
import { DataTable, type DataTableColumn } from 'neba';

const headers: DataTableColumn<Build>[] = [
  { key: 'id', label: 'Build', width: 90, align: 'end' },
  { key: 'branch', label: 'Branch', width: 180 },
  { key: 'duration', label: 'Duration', align: 'end', render: (row) => `${row.duration}s` }
];

<DataTable
  headers={headers}
  items={builds}
  getRowKey={(row) => row.id}
  height={280}
  selectionMode="multiple"
  sortable
/>;
```

## Props

<PropsTable name="DataTable" />

바깥 시트는 [Box](../surfaces/box)입니다. `variant` · `size` · `color` · `density` · `elevation`이 그대로 전달됩니다. `id`, `data-*`, `onContextMenu`처럼 `<div>`가 받는 나머지도 여기에 얹힙니다.

`headers`는 컴포넌트 밖에 정의하거나 memoize하세요. 검색과 정렬은 그 배열의 identity를 기준으로 캐시되고, inline literal은 매 render마다 새 배열입니다.

### DataTableColumn

<PropsTable name="DataTableColumn" />

`render`는 읽는 사람이 보는 것을 정하고, `value`는 정렬과 검색이 보는 것을 정합니다. Chip을 그리는 열에는 `render`가 필요하고, 그 열이 정렬 가능해지는 순간 `value`도 함께 필요합니다.

## Examples

### Virtual scrolling

`height`(또는 `maxHeight`)를 주면 본문이 스크롤되고 보이는 행만 DOM에 남습니다. 높이가 없으면 기준으로 잴 것이 없으므로 `virtual`이 무엇이든 모든 행이 그려집니다. `virtual={false}`는 DOM 개수보다 페이지 내 찾기가 더 중요한 작은 표에서 이 기능을 끕니다.

모든 행은 `rowHeight`만큼 높고 셀은 줄바꿈 없이 잘립니다. 스크롤 위치를 계산으로 풀 수 있는 이유가 바로 이것입니다. 셀에 Avatar나 두 줄짜리 텍스트가 들어간다면 `rowHeight`를 올리세요.

<Demo src="data-table/virtual" minHeight="400">

<<< @/.vitepress/demos/data-table/virtual.tsx

</Demo>

### 행 선택

`selectionMode`는 `none`, `single`, `multiple` 중 하나입니다. `multiple`에서는 이렇게 동작합니다.

|  |  |
| --- | --- |
| 클릭 | 그 행을 고르고 나머지를 놓습니다 |
| <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + 클릭 | 하나를 더하거나 뺍니다 |
| <kbd>Shift</kbd> + 클릭 | 마지막으로 고른 행부터 여기까지 |
| 클릭 후 드래그 | 포인터가 지나간 구간, 가장자리에서는 스크롤하며 |
| <kbd>↑</kbd> <kbd>↓</kbd> | 이동하며 고릅니다 |
| <kbd>Home</kbd> <kbd>End</kbd> <kbd>PageUp</kbd> <kbd>PageDown</kbd> | 스크롤만 합니다. 고른 행은 그대로 남습니다 |
| <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + 방향키 | 고르지 않고 이동만 |
| <kbd>Shift</kbd> + 방향키 | 구간을 늘립니다 |
| <kbd>Space</kbd> | focus가 있는 행을 고릅니다. <kbd>Ctrl</kbd>/<kbd>⌘</kbd>와 함께면 토글 |
| <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + <kbd>A</kbd> | 표시된 모든 행 |
| <kbd>Esc</kbd> | 전부 놓습니다 |
| <kbd>Enter</kbd>, 더블클릭 | `onRowActivate` |

`checkboxes`는 체크박스 열과, 표시된 모든 행을 한 번에 고르는 머리행 체크박스를 답니다. `onSelectedChange`는 key와 그 뒤의 행을 함께 넘기며, 지금 화면에 없는 페이지의 행도 포함합니다.

<Demo src="data-table/selection" minHeight="380">

<<< @/.vitepress/demos/data-table/selection.tsx

</Demo>

### 정렬

`sortable`은 모든 열을 정렬 가능하게 만들고, 열은 자기 `sortable`로 이를 뒤집습니다. 머리글을 누르면 오름차순 → 내림차순 → 정렬 없음으로 돌고, 어느 상태인지는 `aria-sort`가 말합니다.

`sortMode="multiple"`에서는 Shift-클릭이 정렬을 교체하지 않고 열을 덧붙입니다. 화살표 옆의 숫자가 그 열의 순서입니다. 값이 알파벳 순으로 정렬되지 않는 열에는 `compare`를, 셀을 `render`로 그리는 열에는 `value`를 주세요.

<Demo src="data-table/sorting" minHeight="320">

<<< @/.vitepress/demos/data-table/sorting.tsx

</Demo>

### 열 너비와 열 그룹

`width`는 px이며, 너비를 말하지 않은 열들이 남은 폭을 나눠 갖습니다. `resizable`은 경계마다 핸들을 답니다. 첫 드래그가 모든 열을 브라우저가 계산해 둔 너비로 고정하므로, 하나를 끌면 하나만 움직입니다. 핸들을 더블클릭하면 그 열이 원래 너비로 돌아갑니다.

같은 `group` 문자열을 가진 이웃한 열들은 두 번째 머리행에서 하나의 머리글 아래로 합쳐집니다. `group`이 없는 열은 두 행에 걸칩니다.

<Demo src="data-table/columns" minHeight="260">

<<< @/.vitepress/demos/data-table/columns.tsx

</Demo>

### 페이지와 푸터

`paging="pages"`는 행을 페이지로 끊고 푸터를 그립니다. 표시 범위, 선택된 행 수, 페이지 크기 [Select](../inputs/select), 그리고 [Pagination](../inputs/pagination)이 들어갑니다. `pageSizeOptions`가 Select에 담길 값을 정하고, 빈 배열이면 그 컨트롤이 사라집니다.

`footer`는 그 바 자체를 켜고 끄므로, 스크롤하는 표에 페이지 없이 개수만 둘 수도 있습니다.

<Demo src="data-table/pages" minHeight="420">

<<< @/.vitepress/demos/data-table/pages.tsx

</Demo>

### 검색과 필터

`search`는 `searchable: false`를 지정하지 않은 모든 열과 대조되며, 대소문자와 발음 부호를 구분하지 않습니다. `value`가 있는 열은 그 값이 대상입니다. `searchable`은 필드를 그리고, `toolbar`는 그 필드가 있는 바의 나머지를 채웁니다. `filter`는 검색 다음에 적용되는 직접 만든 조건입니다.

<Demo src="data-table/search" minHeight="440">

<<< @/.vitepress/demos/data-table/search.tsx

</Demo>

### 고정 열

열의 `pinned: 'start' | 'end'`가 그 열을 해당 가장자리에 고정하고 나머지가 그 옆을 스크롤해 지나갑니다.

고정은 열을 **옮기기도** 합니다. `columnOrder`가 뭐라 했든 start로 고정된 것이 먼저, end로 고정된 것이 마지막에 그려집니다. 스크롤하는 열들 사이에 얼어붙은 열은 가만히 있는 게 아니라 이웃 위로 미끄러집니다.

고정한 열에는 `width`를 주세요. sticky 셀이 앉는 offset은 그 앞 열들의 너비 합이고, 너비를 적지 않은 열은 더할 숫자가 없어 기본값으로 계산합니다. 그것은 추측입니다.

### 열 순서와 재배치

`columnOrder`는 key의 목록입니다. **거기 없는 key는 제자리를 지킵니다.** 두 개만 적은 순서는 그 둘만 옮기고 나머지를 그대로 두며, 나중에 `headers`에 추가된 열은 저장된 순서를 손보지 않아도 나타납니다.

`reorderable`은 헤더를 행을 따라 끌 수 있게 합니다. 기본값은 꺼짐이며, 드래그는 누르는 순간이 아니라 일정 거리를 움직인 뒤에 시작하므로 정렬하려던 클릭이 열을 옮기지 않습니다. 고정된 헤더는 끌 수 없습니다. 그 자리는 고정이 정하기 때문입니다.

### 셀 편집

표의 `onCellEdit`과 열의 `editable`이 함께 있어야 합니다.

```tsx
<DataTable
  headers={[{ key: 'name', label: 'Name', editable: true }]}
  items={rows}
  onCellEdit={(row, column, value) => save(row.id, column.key, value)}
/>
```

어느 하나만으로는 동작하지 않습니다. 위에 핸들러가 없는 열은 `editable`을 어떻게 두든 편집되지 않습니다. 표가 **행의 사본을 갖지 않기** 때문입니다 — 새 값을 넘기고, `items`로 돌아온 것을 그립니다. 자기 사본에 써 넣는 표는 애플리케이션이 모르는 것을 보여 주는 표입니다.

`editable`은 함수일 수 있습니다. 잠긴 레코드나 계산된 필드를 위해서입니다. `editType: 'number'`는 휴대폰에서 숫자 키패드를 유지하고 문자열이 아니라 숫자를 돌려줍니다.

더블 클릭이 에디터를 열고, blur와 `Enter`가 확정하고 `Escape`가 취소합니다. 에디터를 연 셀에서는 `onRowActivate`가 **함께 발동하지 않습니다** — 그 더블 클릭에는 셀이 이미 답했습니다.

### 그룹과 집계

`groupBy`가 각 행의 제목을 돌려주고, 같은 제목을 가진 행들이 그 아래 모입니다.

```tsx
<DataTable
  headers={[
    { key: 'name', label: 'Name' },
    { key: 'spend', label: 'Spend', aggregate: (rows) => sum(rows) }
  ]}
  items={rows}
  groupBy={(row) => row.team}
/>
```

그룹화는 검색과 정렬 **다음에** 일어납니다. 정렬된 표는 각 그룹 안에서 정렬을 유지하고, 걸러진 표는 남은 것만 묶습니다. 그룹은 첫 행이 나타난 순서를 지킵니다 — `groupBy`가 `undefined`를 돌려준 행들만 예외로 맨 위에 갑니다. 아무 말도 하지 않는 제목은 독자에게 해석을 요구할 수 있는 제목이 아니기 때문입니다.

`aggregate`는 그룹 제목 줄의 **자기 열에** 그려집니다. 그것이 요점입니다. 그룹의 합계는 그것이 합계인 숫자들과 같은 열에 있어야 합니다. `'sum' | 'avg'` 같은 축약형은 없습니다. 가중 평균이나 고유 개수가 필요한 열이 하나 생기는 순간, 절반은 함수이고 절반은 문자열이 됩니다.

그룹화하면 **가상 스크롤이 꺼집니다.** 윈도 계산은 body의 모든 자식을 `rowHeight` 한 줄로 세는데, 제목 줄은 그보다 하나 많습니다.

### 내보내기

`exportable`은 행들을 CSV 파일로 쓰는 버튼을 붙입니다.

**지금 보고 있는 페이지가 아니라 지금 보고 있는 모든 행입니다.** 검색과 정렬은 적용되고 페이징은 적용되지 않습니다. 3페이지짜리 파일은 아무도 요청하지 않은 파일이기 때문입니다.

열의 `exportValue`가 파일에 들어가는 값이고, `render`와 별개인 것은 의도입니다 — Chip이나 Avatar나 진행 막대를 그리는 셀에는 파일에 넣을 글자가 없습니다. 열의 `exportable: false`는 그 열을 빼냅니다.

파일은 byte-order mark로 시작하며, 이것은 장식이 아닙니다. Excel은 BOM 없는 UTF-8 CSV를 로컬 코드 페이지로 읽어서 ASCII가 아닌 이름이 전부 깨져 도착합니다.

`onExport`는 내려받는 대신 CSV를 받아 갑니다.

### 크기와 밀도

`size`는 타입 스케일과 셀 여백, 그리고 `rowHeight`의 기본값을 정합니다. `density`는 여백을 바꾸고, 이 컴포넌트에서만은 그 기본값도 함께 내립니다. 사다리는 라이브러리의 나머지보다 한 단계 아래에 있습니다 — `md` 행은 32px이고, 같은 `md` Button은 높이 32px에 자기 여백이 더해집니다.

<Demo src="data-table/density" minHeight="360">

<<< @/.vitepress/demos/data-table/density.tsx

</Demo>

### 서버에서 오는 행

`manual`은 caller가 이미 끝낸 단계를 지목합니다. `'sort'`, `'filter'`, `'pages'`, 또는 셋 다를 뜻하는 `true`입니다. 표는 `items`를 도착한 그대로 그리고, 요청받은 것만 보고합니다. 목록에 `'pages'`가 있으면 `items`는 한 페이지이고 `rowCount`가 전체 행 수입니다.

<Demo src="data-table/manual" minHeight="420">

<<< @/.vitepress/demos/data-table/manual.tsx

</Demo>

## Accessibility

- `selectionMode`가 있으면 표는 tab stop이 하나인 `grid`가 되고 `aria-activedescendant`로 현재 행을 가리킵니다. virtual한 행은 focus를 들고 있을 수 없기 때문입니다 — 스크롤되어 나가는 순간 그 행은 unmount됩니다. 각 행은 `aria-selected`를 답니다.
- `selectionMode`가 없으면 평범한 `table`이며, 정렬 가능한 머리글 말고는 focus를 받는 것이 없습니다.
- 정렬 가능한 머리글은 진짜 `<button>`이고, 그것을 감싼 `<th>`가 `aria-sort`를 답니다.
- 표에 `caption`이나 `label`을 주세요. 둘 다 없으면 screen reader는 이름 없는 grid라고 읽습니다.
- 크기 조정 핸들은 포인터 전용이며 보조 기술에서는 숨겨집니다. 열 너비는 정보가 아니라 취향이고, 그것 없이 닿지 못하는 내용은 표 안에 없습니다.
- 마크업을 서버에서 렌더링한다면 `locale`을 넘기세요. 기본 정렬이 문자열을 비교할 때 쓰는 locale이 바로 이것이며, 서버와 브라우저가 런타임 locale에 대해 서로 다른 답을 내면 같은 표가 두 가지 행 순서로 나옵니다.

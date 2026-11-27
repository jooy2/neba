---
title: DataTable
order: 17
flutter: true
---

# DataTable

<p class="neba-lede">행이 아주 많은 표입니다. 화면에 보이는 행만 그리고, 정렬하고 검색하며, 파일 탐색기와 같은 방식으로 행을 고를 수 있습니다. 데이터 격자가 읽는 것이 아니라 작업하는 곳일 때 쓰세요.</p>

<Demo src="data-table/hero" minHeight="380" />

::: fw react

```tsx
import { DataTable, type DataTableColumn } from 'neba';

const headers: DataTableColumn<Build>[] = [
  { key: 'id', label: 'Build', width: 90, align: 'end' },
  { key: 'branch', label: 'Branch', width: 180 },
  { key: 'duration', label: 'Duration', align: 'end', render: (row) => `${row.duration}s` }
];
const rowKey = (row: Build) => row.id;

<DataTable
  label="Builds"
  headers={headers}
  items={builds}
  getRowKey={rowKey}
  height={280}
  selectionMode="multiple"
  sortable
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

final List<NebaDataTableColumn<Build>> headers = <NebaDataTableColumn<Build>>[
  NebaDataTableColumn<Build>(
    key: 'id',
    label: const Text('Build'),
    width: 90,
    align: NebaAlign.end,
    value: (Build row) => row.id,
  ),
  NebaDataTableColumn<Build>(
    key: 'branch',
    label: const Text('Branch'),
    width: 180,
    value: (Build row) => row.branch,
  ),
  NebaDataTableColumn<Build>(
    key: 'duration',
    label: const Text('Duration'),
    align: NebaAlign.end,
    value: (Build row) => row.duration,
    builder: (BuildContext context, Build row, int index) => Text('${row.duration}s'),
  ),
];

Object rowKey(Build row, int index) => row.id;

NebaDataTable<Build>(
  semanticLabel: 'Builds',
  headers: headers,
  items: builds,
  rowKey: rowKey,
  height: 280,
  selectionMode: NebaDataTableSelectionMode.multiple,
  sortable: true,
);
```

:::

## Props

<PropsTable name="DataTable" />

::: fw react

바깥 시트는 [Box](../surfaces/box)입니다. `variant` · `size` · `color` · `density` · `elevation`이 그대로 전달됩니다. `id`, `data-*`, `onContextMenu`처럼 `<div>`가 받는 나머지도 여기에 얹힙니다.

`headers`, `getRowKey`, `filter`, `manual`은 컴포넌트 밖에 정의하거나 memoize하세요. 행 key와 검색, 정렬은 이 값들의 identity를 기준으로 캐시되고, inline literal이나 화살표 함수는 매 render마다 새로 만들어집니다. 그러면 표를 감싼 컴포넌트가 render될 때마다 모든 행의 key를 다시 구하고 다시 검색하고 정렬합니다. 선택이나 드래그는 바뀔 때마다 그 render를 일으킵니다.

:::

::: fw flutter

바깥 시트는 [Box](../surfaces/box)입니다. `variant` · `size` · `color` · `density` · `elevation`이 그대로 전달됩니다. 패키지는 주소를 열지도, 내려받기를 시작하지도 않으므로 `getPageHref`와 `exportFileName`은 Flutter에 없습니다.

`headers`, `rowKey`, `filter`, `manual`은 `build` 밖에 두세요. 최상위 `final`이나 필드, tear-off가 그렇습니다. 행 key와 검색, 정렬은 이 값들의 identity를 기준으로 보관되는데, `build` 안에서 쓴 리스트 리터럴이나 클로저는 매번 새로 만들어집니다. 그러면 표를 감싼 위젯이 빌드될 때마다 모든 행의 key를 다시 구하고 다시 검색하고 정렬합니다. 선택이나 드래그는 바뀔 때마다 그 빌드를 일으킵니다.

:::

### DataTableColumn

<PropsTable name="DataTableColumn" />

::: fw react

`render`는 읽는 사람이 보는 것을 정하고, `value`는 정렬과 검색이 보는 것을 정합니다. `render`가 없으면 `Date`는 표의 `locale`로 쓴 날짜로, boolean은 `true`나 `false`로, 나머지는 그대로 쓰입니다. boolean 열에 "예" 같은 말이나 Chip을 보이려면 `render`를 주세요. Chip을 그리는 열에는 `render`가 필요하고, 그 열이 정렬 가능해지는 순간 `value`도 함께 필요합니다.

:::

::: fw flutter

`builder`는 읽는 사람이 보는 것을 정하고, `value`는 정렬과 검색, 편집기가 보는 것을 정하며 `builder` 없는 셀에 그대로 쓰입니다. 행이 `Map`이면 셀이 `row[key]`이므로 둘 다 필요 없습니다. record나 클래스처럼 다른 행이라면 열마다 `value`를 주세요. `builder`가 없으면 `DateTime`은 `Jan 5, 2026` 같은 날짜로, boolean은 `true`나 `false`로, `double`에 담긴 정수는 `.0` 없이, 나머지는 그 텍스트로 쓰입니다.

`editable`은 `bool`이고, 행마다 정하는 것은 `editableWhen`입니다. React의 `editable`은 둘 중 무엇이든 받습니다.

:::

## 예시

### Virtual scrolling

::: fw react

`height`(또는 `maxHeight`)를 주면 본문이 스크롤되고 보이는 행만 DOM에 남습니다. 높이가 없으면 기준으로 잴 것이 없으므로 `virtual`이 무엇이든 모든 행이 그려집니다. `virtual={false}`는 DOM 개수보다 페이지 내 찾기가 더 중요한 작은 표에서 이 기능을 끕니다.

`virtual`이 켜져 있어도 `height`와 `maxHeight`가 모두 없거나 `groupBy`가 있으면 가상 스크롤은 동작하지 않습니다. 그런 표가 행을 500개 넘게 그리면 개발 빌드에서 표마다 한 번 콘솔에 경고합니다. 모든 행을 그리려던 것이라면 `virtual={false}`를 넘기세요.

:::

::: fw flutter

`height`(또는 `maxHeight`)를 주면 본문이 스크롤되고 보이는 행만 빌드됩니다. 그룹으로 묶은 표도 마찬가지입니다. 높이가 없으면 본문을 가둘 것이 없으므로 `virtual`이 무엇이든 모든 행이 빌드되고, `virtual: false`는 높이가 정해진 표에서도 모든 행을 빌드합니다.

`virtual`이 켜져 있는데 높이를 가두는 것이 없는 표가 행을 500개 넘게 빌드하면 debug 빌드에서 표마다 한 번 `debugPrint`로 알립니다. 모든 행을 빌드하려던 것이라면 `virtual: false`를 넘기세요.

:::

모든 행은 `rowHeight`만큼 높고 셀은 줄바꿈 없이 잘립니다. 셀에 Avatar나 두 줄짜리 텍스트가 들어간다면 `rowHeight`를 올리세요.

<Demo src="data-table/virtual" minHeight="400">

::: fw react

<<< @/.vitepress/demos/data-table/virtual.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/virtual.dart

:::

</Demo>

### 행 선택

`selectionMode`는 `none`, `single`, `multiple` 중 하나입니다. `multiple`에서는 이렇게 동작합니다.

|  |  |
| --- | --- |
| 클릭 | 그 행을 고르고 나머지를 놓습니다 |
| <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + 클릭 | 하나를 더하거나 뺍니다 |
| <kbd>Shift</kbd> + 클릭 | 마지막으로 고른 행부터 여기까지 |
| 클릭 후 드래그 | 포인터가 지나간 구간, 가장자리에서는 스크롤하며 |
| 탭 | 손가락을 뗄 때 그 행을 고릅니다. 표를 스크롤한 손가락은 아무것도 고르지 않습니다 |
| <kbd>↑</kbd> <kbd>↓</kbd> | 이동하며 고릅니다 |
| <kbd>Home</kbd> <kbd>End</kbd> <kbd>PageUp</kbd> <kbd>PageDown</kbd> | 높이가 정해진 표에서 스크롤하며 고르지 않고 이동합니다. 고른 행은 그대로 남고, <kbd>Shift</kbd>와 함께면 구간을 늘립니다 |
| <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + 방향키 | 고르지 않고 이동만 |
| <kbd>Shift</kbd> + 방향키 | 구간을 늘립니다 |
| <kbd>Space</kbd> | focus가 있는 행을 고릅니다. <kbd>Ctrl</kbd>/<kbd>⌘</kbd>와 함께면 토글 |
| <kbd>Ctrl</kbd>/<kbd>⌘</kbd> + <kbd>A</kbd> | 표시된 모든 행 |
| <kbd>Esc</kbd> | 전부 놓습니다 |
| <kbd>Enter</kbd>, 더블클릭 | `onRowActivate` |
| <kbd>F2</kbd> | 활성 행에서 편집할 수 있는 첫 셀을 편집합니다 |

`checkboxes`는 체크박스 열과, 표시된 모든 행을 한 번에 고르는 머리행 체크박스를 답니다. `onSelectedChange`는 key와 그 뒤의 행을 함께 넘기며, 지금 화면에 없는 페이지의 행도 포함합니다.

::: fw flutter

셀 안의 컨트롤을 누르면, 예를 들어 `builder`가 그린 버튼을 누르면 그 누름은 그 컨트롤의 것입니다. 행을 고르지도, `onRowPressed`를 부르지도 않습니다.

:::

<Demo src="data-table/selection" minHeight="380">

::: fw react

<<< @/.vitepress/demos/data-table/selection.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/selection.dart

:::

</Demo>

### 정렬

`sortable`은 모든 열을 정렬 가능하게 만들고, 열은 자기 `sortable`로 이를 뒤집습니다. 머리글을 누르면 오름차순 → 내림차순 → 정렬 없음으로 돌고, 어느 상태인지는 <Fw react="`aria-sort`가" flutter="버튼의 semantic value가" /> 말합니다.

<Fw react="sortMode=&quot;multiple&quot;" flutter="sortMode: NebaDataTableSortMode.multiple" code />에서는 Shift-클릭이 정렬을 교체하지 않고 열을 덧붙입니다. 화살표 옆의 숫자가 그 열의 순서입니다. 값이 알파벳 순으로 정렬되지 않는 열에는 `compare`를, 셀을 <Fw react="render" flutter="builder" code />로 그리는 열에는 `value`를 주세요.

::: fw flutter

기본 비교는 숫자를 숫자로, 날짜를 시각으로 비교하고, 텍스트는 대소문자와 발음 부호를 접은 뒤 숫자 부분을 수로 비교하므로 `item2`가 `item10`보다 앞섭니다. widgets 레이어에는 collator가 없어서 언어별 순서는 모릅니다. 그런 순서가 필요한 열에는 `compare`를 주세요.

:::

<Demo src="data-table/sorting" minHeight="320">

::: fw react

<<< @/.vitepress/demos/data-table/sorting.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/sorting.dart

:::

</Demo>

### 열 너비와 열 그룹

::: fw react

`width`는 px이며, 너비를 말하지 않은 열들이 남은 폭을 나눠 갖습니다. `resizable`은 경계마다 핸들을 답니다. 첫 드래그가 모든 열을 브라우저가 계산해 둔 너비로 고정하므로, 하나를 끌면 하나만 움직입니다. 핸들을 더블클릭하면 그 열이 원래 너비로 돌아갑니다. 핸들은 열 이름이 붙은 separator이기도 해서 focus를 받고, <kbd>←</kbd> <kbd>→</kbd>로 16px씩 움직입니다.

:::

::: fw flutter

`width`는 논리 픽셀이며, 너비를 말하지 않은 열들이 남은 폭을 나눠 갖습니다. 열보다 좁은 표는 옆으로 스크롤됩니다. `resizable`은 경계마다 핸들을 답니다. 첫 드래그가 모든 열을 배치된 너비로 고정하므로, 하나를 끌면 하나만 움직입니다. 핸들을 두 번 누르면 그 열이 원래 너비로 돌아갑니다. 핸들은 열 이름이 붙은 focus 대상이기도 해서 <kbd>←</kbd> <kbd>→</kbd>로 16 논리 픽셀씩 움직이고, screen reader도 이를 조절할 수 있습니다.

:::

같은 `group` 문자열을 가진 이웃한 열들은 두 번째 머리행에서 하나의 머리글 아래로 합쳐집니다. `group`이 없는 열은 두 행에 걸칩니다.

<Demo src="data-table/columns" minHeight="260">

::: fw react

<<< @/.vitepress/demos/data-table/columns.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/columns.dart

:::

</Demo>

### 페이지와 푸터

<Fw react="paging=&quot;pages&quot;" flutter="paging: NebaDataTablePaging.pages" code />는 행을 페이지로 끊고 푸터를 그립니다. 표시 범위, 선택된 행 수, 페이지 크기 [Select](../inputs/select), 그리고 [Pagination](../inputs/pagination)이 들어갑니다. `pageSizeOptions`가 Select에 담길 값을 정하고, 빈 배열이면 그 컨트롤이 사라집니다.

::: fw react

`getPageHref`로 페이지마다 주소를 주면 페이지 번호가 크롤러가 따라갈 수 있는 링크가 됩니다. 링크를 눌러도 페이지를 떠나지 않고 표만 넘어갑니다.

:::

`footer`는 그 바 자체를 켜고 끄므로, 스크롤하는 표에 페이지 없이 개수만 둘 수도 있습니다.

<Demo src="data-table/pages" minHeight="420">

::: fw react

<<< @/.vitepress/demos/data-table/pages.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/pages.dart

:::

</Demo>

### 검색과 필터

`search`는 `searchable: false`를 지정하지 않은 모든 열과 대조되며, 대소문자와 발음 부호를 구분하지 않습니다. `value`가 있는 열은 그 값이 대상입니다. `searchable`은 필드를 그리고, `toolbar`는 그 필드가 있는 바의 나머지를 채웁니다. `filter`는 검색 다음에 적용되는 직접 만든 조건입니다.

<Demo src="data-table/search" minHeight="440">

::: fw react

<<< @/.vitepress/demos/data-table/search.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/search.dart

:::

</Demo>

### 고정 열

열의 <Fw react="pinned: 'start' | 'end'" flutter="pinned: NebaDataTablePin.start 또는 NebaDataTablePin.end" code />가 그 열을 해당 가장자리에 고정하고 나머지가 그 옆을 스크롤해 지나갑니다.

고정은 열을 **옮기기도** 합니다. `columnOrder`가 뭐라 했든 start로 고정된 것이 먼저, end로 고정된 것이 마지막에 그려집니다.

::: fw react

고정한 열에는 `width`를 주세요. 너비가 없으면 sticky 셀이 앉는 offset을 그 열의 실제 너비가 아니라 기본 너비로 계산합니다.

:::

::: fw flutter

고정한 열은 배치된 자리에 그대로 붙들리므로, 제자리를 지키려고 따로 `width`를 줄 필요가 없습니다.

:::

### 열 순서와 재배치

`columnOrder`는 key의 목록입니다. **거기 없는 key는 제자리를 지킵니다.** 두 개만 적은 순서는 그 둘만 옮기고 나머지를 그대로 두며, 나중에 `headers`에 추가된 열은 저장된 순서를 손보지 않아도 나타납니다.

`reorderable`은 헤더를 행을 따라 끌 수 있게 합니다. 기본값은 꺼짐이며, 드래그는 누르는 순간이 아니라 일정 거리를 움직인 뒤에 시작하므로 정렬하려던 클릭이 열을 옮기지 않습니다. 고정된 헤더는 끌 수 없습니다. 키보드에서는 헤더에서 <kbd>Alt</kbd> + <kbd>←</kbd> <kbd>→</kbd>를 누르면 열이 한 칸 옮겨집니다. 정렬 버튼이 없는 헤더는 이를 위해 헤더 자체가 focus를 받습니다.

### 셀 편집

표의 `onCellEdit`과 열의 `editable`이 함께 있어야 합니다.

::: fw react

```tsx
<DataTable
  headers={[{ key: 'name', label: 'Name', editable: true }]}
  items={rows}
  onCellEdit={(row, column, value) => save(row.id, column.key, value)}
/>
```

:::

::: fw flutter

```dart
NebaDataTable<Member>(
  headers: <NebaDataTableColumn<Member>>[
    NebaDataTableColumn<Member>(
      key: 'name',
      label: const Text('Name'),
      value: (Member row) => row.name,
      editable: true,
    ),
  ],
  items: rows,
  onCellEdit: (Member row, NebaDataTableColumn<Member> column, Object value) =>
      save(row.id, column.key, value),
)
```

:::

어느 하나만으로는 동작하지 않습니다. 위에 핸들러가 없는 열은 `editable`을 어떻게 두든 편집되지 않습니다. 표는 **행의 사본을 갖지 않습니다**. 새 값을 넘기고, `items`로 돌아온 것을 그립니다.

<Fw react="`editable`은 함수일 수 있습니다" flutter="행마다 정하는 것은 `editableWhen`입니다" />. 잠긴 레코드나 계산된 필드를 위해서입니다. <Fw react="editType: 'number'" flutter="editType: NebaDataTableEditType.number" code />는 휴대폰에서 숫자 키패드를 유지하고 문자열이 아니라 숫자를 돌려줍니다.

더블 클릭이나 활성 행에서 <kbd>F2</kbd>를 누르면 에디터가 열리고, blur와 `Enter`가 확정하고 `Escape`가 취소합니다. 두 키 모두 focus를 표로 돌려줍니다. 에디터를 연 더블 클릭에는 `onRowActivate`가 **함께 발동하지 않습니다**.

### 그룹과 집계

`groupBy`가 각 행의 제목을 돌려주고, 같은 제목을 가진 행들이 그 아래 모입니다.

::: fw react

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

:::

::: fw flutter

```dart
NebaDataTable<Member>(
  headers: <NebaDataTableColumn<Member>>[
    NebaDataTableColumn<Member>(key: 'name', label: const Text('Name'), value: (Member row) => row.name),
    NebaDataTableColumn<Member>(
      key: 'spend',
      label: const Text('Spend'),
      value: (Member row) => row.spend,
      aggregate: (List<Member> rows) => Text('${sum(rows)}'),
    ),
  ],
  items: rows,
  groupBy: (Member row) => row.team,
)
```

:::

그룹화는 검색과 정렬 **다음에** 일어납니다. 정렬된 표는 각 그룹 안에서 정렬을 유지하고, 걸러진 표는 남은 것만 묶습니다. 그룹은 첫 행이 나타난 순서를 지킵니다. `groupBy`가 <Fw react="undefined" flutter="null" code />을 돌려준 행들만 예외로 맨 위에 가며, 이 행들의 제목은 표의 `locale`로 쓴 "그룹 없음"입니다.

열의 `aggregate`는 한 그룹의 행들을 받아 호출되고, 돌려준 값은 그룹 제목 줄의 그 열에 그려집니다. 늘 함수이며 `'sum' | 'avg'` 같은 축약형은 없습니다.

::: fw react

그룹화하면 **가상 스크롤이 꺼집니다.**

:::

::: fw flutter

그룹 제목도 한 행 높이이므로, `height`가 있는 묶인 표는 여전히 가상 스크롤을 합니다. 모든 그룹을 접어도 제목은 페이지에 남아 다시 펼 수 있습니다.

:::

### 내보내기

::: fw react

`exportable`은 행들을 CSV 파일로 쓰는 버튼을 붙입니다.

:::

::: fw flutter

`exportable`은 행들을 CSV로 쓰고 그 텍스트를 `onExport`에 넘기는 버튼을 붙입니다. 패키지는 내려받기를 시작하지 않으므로 `onExport`가 있을 때만 버튼이 그려지며, 파일을 저장하거나 공유하는 것은 앱의 몫입니다.

:::

파일에는 지금 보고 있는 페이지만이 아니라 지금 보고 있는 모든 행이 들어갑니다. 검색과 정렬은 적용되고 페이징은 적용되지 않습니다.

열의 `exportValue`가 파일에 들어가는 값입니다. 없으면 `value`를, 그것도 없으면 `row[key]`를 쓰며, <Fw react="render" flutter="builder" code />가 그린 것은 쓰지 않습니다. 열의 `exportable: false`는 그 열을 빼냅니다.

파일은 byte-order mark로 시작하므로, Excel에서도 ASCII가 아닌 글자가 깨지지 않습니다. `=`, `+`, `-`, `@`, 탭, 캐리지 리턴으로 시작하는 텍스트 셀은 앞에 `'`를 붙여 쓰므로, 스프레드시트가 수식으로 실행하지 않고 글자로 보여 줍니다. <Fw react="exportEscapeFormulas={false}" flutter="exportEscapeFormulas: false" code />면 그대로 씁니다.

::: fw react

`onExport`는 내려받는 대신 CSV를 받아 갑니다.

:::

### 크기와 밀도

`size`는 타입 스케일과 셀 여백, 그리고 `rowHeight`의 기본값을 정합니다. `density`는 여백을 바꾸고, 이 컴포넌트에서만은 그 기본값도 함께 내립니다. `md` 행은 32px로 `md` Button과 높이가 같고, `compact`에서는 28px이 됩니다.

<Demo src="data-table/density" minHeight="360">

::: fw react

<<< @/.vitepress/demos/data-table/density.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/density.dart

:::

</Demo>

### 서버에서 오는 행

`manual`은 caller가 이미 끝낸 단계를 지목합니다. <Fw react="`'sort'`, `'filter'`, `'pages'`, 또는 셋 다를 뜻하는 `true`입니다" flutter="`NebaDataTableStage.sort`, `filter`, `pages`의 집합이고, 셋 다는 `NebaDataTableStage.values.toSet()`입니다" />. 표는 `items`를 도착한 그대로 그리고, 요청받은 것만 보고합니다. 목록에 <Fw react="'pages'" flutter="pages" code />가 있으면 `items`는 한 페이지이고 `rowCount`가 전체 행 수입니다. 한 페이지에서 고른 행은 다른 페이지에서 고르는 동안에도 선택된 채로 남습니다. `onSelectedChange`는 그 key를 넘기지만, 표가 지금 들고 있지 않은 페이지의 key에는 행을 넘기지 않습니다.

<Demo src="data-table/manual" minHeight="420">

::: fw react

<<< @/.vitepress/demos/data-table/manual.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_table/manual.dart

:::

</Demo>

## 접근성

::: fw react

- `selectionMode`가 있으면 표는 tab stop이 하나인 `grid`가 되고 `aria-activedescendant`로 현재 행을 가리킵니다. 각 행은 `aria-selected`를 답니다.
- `checkboxes`가 있으면 행의 체크는 tab 순서에서 빠집니다. <kbd>Space</kbd>가 이미 활성 행을 고르기 때문입니다. 체크의 이름은 "Select row" 뒤에 그 행의 첫 셀을 붙인 것입니다.
- `selectionMode`가 없어도 행이 무언가를 열거나(`onRowActivate`) 편집할 셀이 있으면 tab stop을 가진 `grid`입니다. 방향키로 활성 행을 옮기면 `aria-activedescendant`가 그 행을 가리키고, <kbd>Enter</kbd>로 열고 <kbd>F2</kbd>로 편집하며, 아무것도 고르지 않습니다. 그 어느 것도 없으면 평범한 `table`이며, 정렬 가능한 머리글 말고는 focus를 받는 것이 없습니다.
- 정렬 가능한 머리글은 진짜 `<button>`이고, 그것을 감싼 `<th>`가 `aria-sort`를 답니다. `sortMode="multiple"`에서는 첫 번째 키의 머리글에만 달리고, 그다음 키의 버튼 이름 끝에는 "정렬 2순위, 내림차순"처럼 순서와 방향이 `locale`의 말로 붙습니다.
- 행 범위와 선택한 행 수는 `status`입니다. footer가 있으면 footer에, 없으면 화면에 보이지 않게 둡니다. 검색하거나 페이지를 넘기거나 행을 고르면 screen reader가 바뀐 숫자를 읽습니다.
- 표에 `caption`이나 `label`을 주세요. 둘 다 없으면 screen reader는 이름 없는 grid라고 읽습니다.
- 크기 조정 핸들은 tab 순서에 들어가는 `separator`이고, 이름은 "너비 조절"과 열 이름이며, 너비를 `aria-valuenow`로 알립니다. 핸들을 품은 머리글의 이름은 여전히 열 이름뿐입니다.
- 옮길 수 있는 머리글에는 <kbd>Alt</kbd> + <kbd>←</kbd> <kbd>→</kbd>를 알리는 `aria-keyshortcuts`가 붙습니다.
- 셀은 줄을 바꾸지 않고 글자를 자릅니다. screen reader는 전체를 읽고, `render`가 없는 셀이 잘렸다면 포인터를 올렸을 때 전체 텍스트가 툴팁으로 나옵니다. 키보드 사용자는 핸들로 열을 넓히면 됩니다.
- 마크업을 서버에서 렌더링한다면 `locale`을 넘기세요. 기본 정렬이 문자열을 비교할 때 쓰는 locale이 바로 이것이며, 서버와 브라우저가 런타임 locale에 대해 서로 다른 답을 내면 같은 표가 두 가지 행 순서로 나옵니다.

:::

::: fw flutter

- `selectionMode`나 `onRowActivate`, 편집할 셀이 있으면 표는 focus 대상 하나가 되고, 방향키가 활성 행을 옮깁니다. 활성 행은 안쪽 테두리로 표시되고 표가 화면 안에 붙들어 둡니다. 그 어느 것도 없으면 표는 focus를 받지 않으며, 정렬 가능한 머리글 말고는 그 안에서 focus를 받는 것이 없습니다.
- 각 행은 저마다의 semantics 노드이고, 셀들이 그 label로 읽힙니다. `selectionMode`가 있으면 선택 여부가 함께 들리고, 그것이나 `onRowPressed`가 있으면 탭에 응답합니다.
- `checkboxes`가 있으면 행의 체크는 focus 순서에서 빠집니다. <kbd>Space</kbd>가 이미 활성 행을 고르기 때문입니다. 체크의 이름은 "Select row" 뒤에 첫 열의 값을 붙인 것입니다.
- 정렬 가능한 머리글은 버튼이고, semantic value가 정렬에서의 순서와 방향을 "정렬 1순위, 오름차순"처럼 `locale`의 말로 알립니다. 첫 번째 키도 나머지와 같습니다.
- 행 범위와 선택한 행 수는 live status입니다. footer가 있으면 footer에, 없으면 화면에 보이지 않게 둡니다. 검색하거나 페이지를 넘기거나 행을 고르면 screen reader가 바뀐 숫자를 읽습니다.
- 표에 `semanticLabel`이나 `Text`인 `caption`을 주세요. 둘 다 없으면 screen reader는 이름 없이 읽습니다.
- 크기 조정 핸들은 focus 대상이고, 이름은 "너비 조절"과 열 이름이며, 너비를 값으로 알립니다. screen reader는 slider처럼 이를 조절합니다. 핸들 옆 머리글의 이름은 여전히 열 이름뿐입니다.
- 셀은 줄을 바꾸지 않고 글자를 자르며, screen reader는 전체를 읽습니다. 키보드 사용자는 핸들로 열을 넓히면 됩니다. 잘린 셀이 전체 텍스트를 툴팁으로 보여 주지는 않습니다.

:::

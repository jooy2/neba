---
title: Table
order: 4
flutter: true
---

# Table

<p class="neba-lede">열 정의와 행 데이터를 받아 데이터 격자를 그립니다. <code>&lt;tr&gt;</code>이나 <code>&lt;td&gt;</code>를 직접 쓰지 않습니다.</p>

<Demo src="table/hero" />

::: fw react

```tsx
import { Table, type TableColumn } from 'neba';

const headers: TableColumn<Deploy>[] = [
  { key: 'environment', label: '환경', width: 180 },
  { key: 'duration', label: '소요', align: 'end', render: (row) => `${row.duration}분` }
];

<Table headers={headers} items={deploys} getRowKey={(row) => row.id} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

final List<NebaTableColumn<Deploy>> headers = <NebaTableColumn<Deploy>>[
  NebaTableColumn<Deploy>(
    key: 'environment',
    label: const Text('Environment'),
    width: 180,
    builder: (BuildContext context, Deploy row, int index) => Text(row.environment),
  ),
  NebaTableColumn<Deploy>(
    key: 'duration',
    label: const Text('Duration'),
    align: NebaAlign.end,
    builder: (BuildContext context, Deploy row, int index) => Text('${row.duration}m'),
  ),
];

NebaTable<Deploy>(headers: headers, items: deploys);
```

:::

## Props

<PropsTable name="Table" />

::: fw react

바깥 sheet은 [Box](../surfaces/box)입니다. `variant` · `size` · `color` · `density` · `elevation`이 그대로 통과합니다.

:::

::: fw flutter

바깥 sheet은 [Box](../surfaces/box)입니다. `variant` · `size` · `color` · `density` · `elevation` · `transition`이 그대로 통과합니다. 행은 Flutter의 `Table`이며, screen reader는 이를 행과 셀로 된 표로 읽습니다.

:::

### TableColumn

::: fw react

```ts
interface TableColumn<Row> {
  key: string; // 열 식별자이자, 행에서 읽을 속성 이름
  label?: React.ReactNode; // 머리글. 생략하면 key
  width?: number | string; // 숫자는 px, 문자열은 CSS 길이
  align?: 'start' | 'center' | 'end';
  render?: (row: Row, index: number) => React.ReactNode;
}
```

`render`를 주면 셀 내용을 직접 그리고, 없으면 `row[key]`를 그대로 출력합니다.

:::

::: fw flutter

```dart
class NebaTableColumn<T> {
  final String key; // 열 식별자이자, 행이 Map일 때 읽을 필드 이름
  final Widget? label; // 머리글. 생략하면 key
  final double? width; // 논리 픽셀
  final NebaAlign align;
  final Widget Function(BuildContext context, T row, int index)? builder;
}
```

`builder`를 주면 셀을 직접 만들고, 없으면 `Map`인 행은 `row[key]`를 그대로 출력하며 다른 행은 아무것도 출력하지 않습니다. 그래서 타입이 있는 행이면 모든 열에 builder를 줍니다.

:::

## 예시

### width와 align

::: fw react

`width`는 **기준** 너비입니다. 표는 남는 공간에 맞춰 열을 늘리므로 고정값이 아니라 출발 비율로 동작합니다. 값은 `<col>`에 적용되므로 모든 행에 일관되게 적용됩니다.

:::

::: fw flutter

`width`는 열을 그 논리 픽셀 너비로 고정합니다. 너비가 없는 열들은 브라우저가 표를 배치하듯 내용에 따라 나머지를 나눠 가집니다.

:::

숫자 열에는 자릿수를 맞추기 위해 보통 <Fw react="align: 'end'" flutter="align: NebaAlign.end" code />를 씁니다.

<Demo src="table/columns">

::: fw react

<<< @/.vitepress/demos/table/columns.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/columns.dart

:::

</Demo>

### striped · hoverable · <Fw react="onRowClick" flutter="onRowPressed" />

`striped`는 행마다 배경을 번갈아 칠합니다. 눈이 가로로 길게 이동해야 하는 넓은 표에 유용합니다. <Fw react="`onRowClick`은" flutter="`onRowPressed`는" /> 행을 누를 수 있게 만들고 hover 처리도 함께 켭니다.

<Fw react="getRowKey" flutter="rowKey" code />의 기본값은 행 인덱스입니다. 정렬이나 필터로 행 순서가 바뀔 수 있다면 직접 넘기세요.

<Demo src="table/rows">

::: fw react

<<< @/.vitepress/demos/table/rows.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/rows.dart

:::

</Demo>

### empty

`items`가 비었을 때 표시할 내용입니다. <Fw react="모든 열을 가로지르는 하나의 셀로 렌더링됩니다" flutter="머리행 아래에 너비 전체를 가로지르는 한 줄로 그려집니다" />.

<Demo src="table/empty">

::: fw react

<<< @/.vitepress/demos/table/empty.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/table/empty.dart

:::

</Demo>

### stickyHeader

::: fw react

본문이 스크롤될 때 머리행을 고정합니다. 스크롤되는 것은 표가 그리는 시트이므로, 높이는 `maxHeight`에 픽셀 수나 CSS 길이로 제한합니다. 표를 감싼 상자의 높이를 제한하면 그 상자가 대신 스크롤되어 머리행도 행과 함께 올라갑니다.

:::

::: fw flutter

`maxHeight`로 높이를 제한한 표에서, 본문이 스크롤될 때 머리행을 고정합니다. 이때 머리행은 행과 따로 배치되므로, `width`가 없는 열들은 내용이 아니라 균등하게 너비를 나눕니다. 그것이 문제가 되는 곳에서는 열에 너비를 주세요.

:::

### classNames

::: fw react

`className`은 sheet(table이 가로로 스크롤되는 Box)이고, `<table>`과 그 안의 모든 것은 `classNames`로 갑니다.

```tsx
<Table
  headers={headers}
  items={items}
  classNames={{
    table: 'tabular-nums',
    headCell: '[--n-cell-ink:var(--neba-fg)]',
    row: 'align-top'
  }}
/>
```

slot은 `table`, `caption`, `head`, `headCell`, `body`, `row`, `cell`, `empty`입니다.

`cell`을 쓰기 전에 알아 둘 것이 하나 있습니다. cell의 padding과 정렬, 배경은 utility가 아니라 inline style로 쓰여 있습니다. host stylesheet의 `td` 규칙이 한 개짜리 utility를 이기기 때문입니다. `headCell`·`cell`·`empty`에 넘긴 class는 컴포넌트가 inline으로 정하지 않은 것(폰트, 테두리)은 무엇이든 더할 수 있지만, 저 셋을 바꾸려면 important utility(`p-4!`)여야 합니다. header cell과 빈 줄의 글자색도 inline이며 `--n-cell-ink` slot을 읽으므로, 위 예시처럼 `text-*` 색 대신 그 slot을 정하세요. [prop 규약](../../design/prop-conventions)을 보세요.

:::

::: fw flutter

Flutter 표에는 class 이름이 없습니다. 셀은 열의 `builder`가 돌려주는 위젯으로, 머리글은 열의 `label`로 꾸밉니다.

:::

## 접근성

::: fw react

- 실제 `<table>`과 `<th scope="col">`로 렌더링됩니다.
- `caption`은 표의 accessible name으로 읽힙니다.
- 빈 상태 셀은 `colSpan`으로 모든 열을 덮으므로, 첫 열에만 걸린 짧은 텍스트로 읽히지 않습니다.
- `onRowClick`을 넘기면 행이 tab 순서에 들어가고 Enter와 Space에 반응하며, focus-visible ring을 그립니다. 행의 `role`은 그대로 두므로 열 머리글과 행 위치는 계속 읽힙니다.
- 셀 안에 링크나 버튼을 두면 그 컨트롤의 키 입력은 컨트롤이 처리합니다. 다만 컨트롤이 발생시킨 click은 행까지 버블링되므로, 행이 함께 열리지 않아야 한다면 핸들러에서 `event.stopPropagation()`을 호출하세요.
- 행이 없을 때의 문구는 `locale`이 정합니다. `empty`로 직접 쓸 수도 있습니다.

:::

::: fw flutter

- 행은 Flutter의 `Table`이며, screen reader는 행과 셀로 된 표로 읽습니다. 머리행의 셀은 열 머리글입니다.
- 빈 상태는 머리행 아래의 한 줄이므로, 첫 열에만 걸린 짧은 셀로 읽히지 않습니다.
- `onRowPressed`를 넘기면 행마다 focus 대상이 되고 Enter와 Space에 반응하며, 키를 누른 뒤에는 ring이 그려집니다.
- 셀 안의 컨트롤은 자기 누름을 먼저 받습니다. 행은 셀 안의 무엇도 받지 않은 누름에만 눌립니다.
- 행이 없을 때의 문구는 `locale`이 정합니다. `empty`로 직접 쓸 수도 있습니다.

:::

---
title: Table
order: 4
---

# Table

<p class="neba-lede">열 정의와 행 데이터를 받아 데이터 격자를 그립니다. <code>&lt;tr&gt;</code>이나 <code>&lt;td&gt;</code>를 직접 쓰지 않습니다.</p>

<Demo src="table/hero" />

```tsx
import { Table, type TableColumn } from 'neba';

const headers: TableColumn<Deploy>[] = [
  { key: 'environment', label: '환경', width: 180 },
  { key: 'duration', label: '소요', align: 'end', render: (row) => `${row.duration}분` }
];

<Table headers={headers} items={deploys} getRowKey={(row) => row.id} />;
```

## Props

<PropsTable name="Table" />

바깥 sheet은 [Box](../surfaces/box)입니다. `variant` · `size` · `color` · `density` · `elevation`이 그대로 통과합니다.

### TableColumn

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

## 예시

### width와 align

`width`는 **기준** 너비입니다. 표는 남는 공간에 맞춰 열을 늘리므로 고정값이 아니라 출발 비율로 동작합니다. 값은 `<col>`에 적용되므로 모든 행에 일관되게 적용됩니다.

숫자 열에는 자릿수를 맞추기 위해 보통 `align: 'end'`를 씁니다.

<Demo src="table/columns">

<<< @/.vitepress/demos/table/columns.tsx

</Demo>

### striped · hoverable · onRowClick

`striped`는 행마다 배경을 번갈아 칠합니다 — 눈이 가로로 길게 이동해야 하는 넓은 표에 유용합니다. `onRowClick`은 행을 누를 수 있게 만들고 hover 처리도 함께 켭니다.

`getRowKey`의 기본값은 행 인덱스입니다. 정렬이나 필터로 행 순서가 바뀔 수 있다면 직접 넘기세요.

<Demo src="table/rows">

<<< @/.vitepress/demos/table/rows.tsx

</Demo>

### empty

`items`가 비었을 때 표시할 내용입니다. 모든 열을 가로지르는 하나의 셀로 렌더링됩니다.

<Demo src="table/empty">

<<< @/.vitepress/demos/table/empty.tsx

</Demo>

### stickyHeader

머리행을 스크롤 중에 고정합니다. 표를 감싼 요소가 높이를 제한하고 있을 때만 효과가 있습니다.

### classNames

`className`은 sheet — table이 가로로 스크롤되는 Box — 이고, `<table>`과 그 안의 모든 것은 `classNames`로 갑니다.

```tsx
<Table
  headers={headers}
  items={items}
  classNames={{ table: 'tabular-nums', headCell: 'text-(--neba-fg)', row: 'align-top' }}
/>
```

slot은 `table`, `caption`, `head`, `headCell`, `body`, `row`, `cell`, `empty`입니다.

`cell`을 쓰기 전에 알아 둘 것이 하나 있습니다. cell의 padding과 정렬, 배경은 utility가 아니라 inline style로 쓰여 있습니다. host stylesheet의 `td` 규칙이 한 개짜리 utility를 이기기 때문입니다. `headCell`·`cell`·`empty`에 넘긴 class는 컴포넌트가 inline으로 정하지 않은 것 — 색, 폰트, 테두리 — 은 무엇이든 더할 수 있지만, 저 셋을 바꾸려면 important utility(`p-4!`)여야 합니다. [prop 규약](../../design/prop-conventions)을 보세요.

## 접근성

- 실제 `<table>`과 `<th scope="col">`로 렌더링됩니다.
- `caption`은 표의 accessible name으로 읽힙니다.
- 빈 상태 셀은 `colSpan`으로 모든 열을 덮으므로, 첫 열에만 걸린 짧은 텍스트로 읽히지 않습니다.
- `onRowClick`을 넘기면 행이 tab 순서에 들어가고 Enter와 Space에 반응하며, focus-visible ring을 그립니다. 행의 `role`은 그대로 두므로 열 머리글과 행 위치는 계속 읽힙니다.
- 셀 안에 링크나 버튼을 두면 그 컨트롤의 키 입력은 컨트롤이 처리합니다. 다만 컨트롤이 발생시킨 click은 행까지 버블링되므로, 행이 함께 열리지 않아야 한다면 핸들러에서 `event.stopPropagation()`을 호출하세요.
- 행이 없을 때의 문구는 `locale`이 정합니다. `empty`로 직접 쓸 수도 있습니다.

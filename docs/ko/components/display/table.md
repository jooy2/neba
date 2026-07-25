---
title: Table
order: 4
---

# Table

<p class="neba-lede">열 목록과 행 목록으로 그려지는 데이터 격자입니다. 직접 쓸 <code>&lt;tr&gt;</code>은 없습니다.</p>

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

시트는 [Box](../surfaces/box)입니다 — `variant`·`size`·`color`·`density`·`elevation`이 전부 그대로 통과하므로, 표는 옆에 놓일 다른 것들과 같은 축으로 스타일링됩니다. Table이 더하는 것은 진짜로 표다운 부분뿐입니다.

### TableColumn

```ts
interface TableColumn<Row> {
  key: string; // 열을 식별하고, 행에서 읽을 속성 이름이기도 합니다
  label?: React.ReactNode; // 머리글. 생략하면 key
  width?: number | string; // 숫자는 픽셀, 문자열은 모든 CSS 길이
  align?: 'start' | 'center' | 'end';
  render?: (row: Row, index: number) => React.ReactNode;
}
```

Table이 마크업이 아니라 데이터를 받는 이유가 이것입니다. 행마다 직접 쓴 `<td>`는 위의 `<th>`와 개수나 순서에 대해 조용히 어긋날 수 있지만, 열 목록은 그럴 수 없습니다.

## 예시

### 너비와 정렬

`width`는 **기본** 너비입니다. 표는 여전히 남는 공간을 채우도록 열을 조정하므로, 이것은 보장이 아니라 출발 비율입니다. 이 값은 첫 행의 셀이 아니라 `<col>`에 적힙니다 — `<th>`에 준 너비는 브라우저가 다른 모든 행과 다시 협상하는 너비이고, 한 번만 선언하는 것은 열 요소뿐입니다.

숫자 열은 보통 `align: 'end'`를 원합니다. 자릿수가 맞아야 하기 때문입니다.

<Demo src="table/columns">

<<< @/.vitepress/demos/table/columns.tsx

</Demo>

### 행

`striped`는 눈이 가로로 따라가야 하는 넓은 표를 위한 것이고, 좁은 표에서는 잡음입니다. `onRowClick`은 행을 누를 수 있게 만들고 호버 처리도 함께 켭니다.

<Demo src="table/rows">

<<< @/.vitepress/demos/table/rows.tsx

</Demo>

`getRowKey`의 기본값은 행의 인덱스입니다. 고정된 표에는 괜찮지만 정렬이나 필터가 있는 표에서는 틀립니다 — 행이 움직일 수 있는 순간부터는 넘기세요.

### 비었을 때

<Demo src="table/empty">

<<< @/.vitepress/demos/table/empty.tsx

</Demo>

## 머리행

머리행은 색을 입는 대신 시트의 불투명도 사다리에서 한 칸 올라갑니다. 그것은 여전히 컨테이너이고, 열 이름 뒤에 깔린 색 띠는 데이터를 크롬처럼 보이게 만드는 가장 빠른 방법입니다. 그 아래의 선은 [Card](../surfaces/card)가 섹션을 나눌 때 쓰는 것과 같은 `--n-line`입니다.

`stickyHeader`는 표 주변의 무언가가 실제로 높이를 제한하고 있을 때만 의미가 있습니다.

## 접근성

- 진짜 `<table>`과 `<th scope="col">` 머리글로 렌더링됩니다.
- `caption`은 표의 접근성 이름으로 읽힙니다.
- 빈 상태는 모든 열을 가로지르므로, 짧은 첫 열이 아니라 하나의 셀로 읽힙니다.

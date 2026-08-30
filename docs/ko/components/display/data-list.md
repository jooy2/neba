---
title: DataList
order: 20
---

# DataList

<p class="neba-lede">어떤 것들과 그것들의 이름을 나열합니다 — 상세 패널, 레코드 요약, 제목 아래의 메타데이터. 진짜 <code>&lt;dt&gt;</code>/<code>&lt;dd&gt;</code> 쌍이라 각 행이 "라벨, 값"으로 읽힙니다.</p>

<Demo src="data-list/hero" />

```tsx
import { DataList, DataListItem } from 'neba';

<DataList>
  <DataListItem label="Status">Live</DataListItem>
  <DataListItem label="Region">Frankfurt</DataListItem>
</DataList>;
```

## Props

<PropsTable name="DataList" />

`<dl>`의 모든 속성이 `color`를 제외하고 그대로 전달됩니다. 표면은 그리지 않습니다 — 필요하면 [Card](../surfaces/card)나 [Box](../surfaces/box) 안에 두세요.

두 열짜리 [Table](./table)이 아닙니다. 표는 같은 모양의 행이 격자로 놓인 것이고 격자로 읽힙니다. 이쪽은 쌍의 모음이고 각 쌍이 라벨과 값으로 읽힙니다.

### DataListItem

<PropsTable name="DataListItem" />

## 예시

### orientation

`horizontal`은 값 옆에 라벨만의 열을 두며, 상세 패널이 취하는 모양입니다. `vertical`은 라벨을 위에 둡니다. 폭이 좁은 열이나, 값이 길어서 옆에 라벨을 두면 행 대부분이 비는 경우에 씁니다.

<Demo src="data-list/orientation">

<<< @/.vitepress/demos/data-list/orientation.tsx

</Demo>

### labelWidth

지정하지 않으면 라벨 열은 가장 긴 라벨만큼 넓어지며, 그래서 모든 값이 같은 위치에서 시작합니다. 두 목록을 나란히 같은 치수로 맞출 때 지정하세요.

<Demo src="data-list/label-width">

<<< @/.vitepress/demos/data-list/label-width.tsx

</Demo>

### dividers

행 사이의 하이라인입니다. 쌍이 많아 구분이 필요한 긴 목록에 씁니다.

<Demo src="data-list/dividers">

<<< @/.vitepress/demos/data-list/dividers.tsx

</Demo>

## 접근성

- 각 쌍이 `<dt>`와 `<dd>`인 진짜 `<dl>`로 렌더링되므로, ARIA 없이도 라벨과 값이 연결됩니다.
- 값에는 어떤 노드든 올 수 있고 — [Chip](./chip), [TextLink](./text-link), [Avatar](./avatar) — 각자 가져온 의미를 그대로 유지합니다.

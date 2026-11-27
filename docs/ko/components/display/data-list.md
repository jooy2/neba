---
title: DataList
order: 20
flutter: true
---

# DataList

<p class="neba-lede">상세 패널이나 레코드 요약, 제목 아래의 메타데이터처럼 항목과 그 이름을 나열합니다. 진짜 <code>&lt;dt&gt;</code>/<code>&lt;dd&gt;</code> 쌍이라 각 행이 "라벨, 값"으로 읽힙니다.</p>

<Demo src="data-list/hero" />

::: fw react

```tsx
import { DataList, DataListItem } from 'neba';

<DataList>
  <DataListItem label="Status">Live</DataListItem>
  <DataListItem label="Region">Frankfurt</DataListItem>
</DataList>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaDataList(
  children: <Widget>[
    NebaDataListItem(label: Text('Status'), child: Text('Live')),
    NebaDataListItem(label: Text('Region'), child: Text('Frankfurt')),
  ],
);
```

:::

## Props

<PropsTable name="DataList" />

<Fw react="`<dl>`의 모든 속성이 `color`를 제외하고 그대로 전달됩니다." flutter="목록은 주어진 너비를 그대로 차지합니다." /> 표면은 그리지 않습니다. 필요하면 [Card](../surfaces/card)나 [Box](../surfaces/box) 안에 두세요.

### DataListItem

<PropsTable name="DataListItem" />

## 예시

### orientation

`horizontal`은 값 옆에 라벨만의 열을 두며, 상세 패널이 취하는 모양입니다. `vertical`은 라벨을 위에 둡니다. 폭이 좁은 열이나, 값이 길어서 옆에 라벨을 두면 행 대부분이 비는 경우에 씁니다. 위에 놓인 라벨은 앞 쌍보다 자기 값에 더 가깝게 붙습니다.

<Demo src="data-list/orientation">

::: fw react

<<< @/.vitepress/demos/data-list/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_list/orientation.dart

:::

</Demo>

### labelWidth

지정하지 않으면 라벨 열은 가장 긴 라벨만큼 넓어지며, 그래서 모든 값이 같은 위치에서 시작합니다. 다만 목록 너비의 절반을 넘지 않고, 그보다 긴 라벨은 줄을 바꿉니다. 두 목록을 나란히 같은 치수로 맞출 때 <Fw react="지정하세요" flutter="논리 픽셀로 지정하세요" />.

<Demo src="data-list/label-width">

::: fw react

<<< @/.vitepress/demos/data-list/label-width.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_list/label_width.dart

:::

</Demo>

### dividers

행 사이의 하이라인입니다. 쌍이 많아 구분이 필요한 긴 목록에 씁니다. `vertical` 목록에서는 라벨 위, 즉 쌍과 쌍 사이에만 그어지고 라벨과 값 사이에는 그어지지 않습니다.

<Demo src="data-list/dividers">

::: fw react

<<< @/.vitepress/demos/data-list/dividers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/data_list/dividers.dart

:::

</Demo>

## 접근성

::: fw react

- 각 쌍이 `<dt>`와 `<dd>`인 진짜 `<dl>`로 렌더링되므로, ARIA 없이도 라벨과 값이 연결됩니다.
- 값에는 [Chip](./chip), [TextLink](./text-link), [Avatar](./avatar)를 비롯한 어떤 노드든 올 수 있고, 각자 가져온 의미를 그대로 유지합니다.

:::

::: fw flutter

- Flutter의 semantics에는 설명 목록이 없으므로, 각 쌍을 노드 하나로 만들어 screen reader가 라벨과 값을 차례로 읽게 합니다.
- 값에는 [Chip](./chip), [TextLink](./text-link), [Avatar](./avatar)를 비롯한 어떤 widget이든 올 수 있고, 쌍 안의 별도 노드로 각자 가져온 의미를 그대로 유지합니다.

:::

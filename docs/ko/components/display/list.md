---
title: List
order: 5
flutter: true
---

# List

<p class="neba-lede">같은 형태의 행을 세로로 쌓는 컴포넌트입니다. 내비게이션, 설정 항목, 검색 결과처럼 반복되는 목록에 씁니다.</p>

<Demo src="list/hero" />

::: fw react

```tsx
import { List, ListItem } from 'neba';

<List>
  <ListItem startIcon={<GlobeIcon />} description="4분 전 배포" onClick={open} selected>
    production
  </ListItem>
  <ListItem startIcon={<GlobeIcon />} description="2시간 전 배포" onClick={open}>
    staging
  </ListItem>
</List>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaList(
  children: <Widget>[
    NebaListItem(
      startIcon: const GlobeIcon(),
      description: const Text('4분 전 배포'),
      onPressed: open,
      selected: true,
      child: const Text('production'),
    ),
    NebaListItem(
      startIcon: const GlobeIcon(),
      description: const Text('2시간 전 배포'),
      onPressed: open,
      child: const Text('staging'),
    ),
  ],
);
```

:::

## Props

### List

<PropsTable name="List" />

`size`와 `density`는 `List`에만 지정합니다. <Fw react="context를 통해" flutter="inherited widget으로" /> 모든 `ListItem`에 전달되므로 행마다 반복할 필요가 없습니다.

::: fw flutter

목록은 주어진 너비를 그대로 차지하고, 높이는 행만큼입니다. `render`는 없습니다. Flutter의 semantics에는 목록이 한 종류뿐이라, 순서가 의미를 갖는 목록도 같은 `NebaList`로 씁니다.

:::

### ListItem

<PropsTable name="ListItem" />

::: fw flutter

패키지는 아무것도 직접 열지 않으므로 어딘가로 이동하는 행도 콜백입니다. `onPressed`에서 router를 부르고, `href`는 screen reader와, 웹에서는 브라우저에 행이 가는 곳을 알립니다. `onPressed` 없이 `href`만 주면 행은 focus를 받지 않는 평범한 내용으로 남습니다.

:::

## 예시

### dividers

`dividers`를 켜면 행 사이에 선이 그려집니다. 선이 sheet 양끝까지 닿아야 하므로 목록의 안쪽 여백과 행의 둥근 모서리가 함께 사라지고, 행은 떠 있는 타일이 아니라 구획된 줄로 바뀝니다.

<Demo src="list/dividers">

::: fw react

<<< @/.vitepress/demos/list/dividers.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/list/dividers.dart

:::

</Demo>

### spacing

기본으로 행은 서로 맞닿고, 각 행 안쪽의 여백이 글자 사이를 띄웁니다. `spacing`을 주면 행 사이에 간격이 생깁니다. <Fw react="Tailwind 간격 스케일이라 `1`은 `0.25rem`이고" flutter="간격 스케일이라 `1`은 4 논리 픽셀이고" />, 이 정도면 hover되거나 선택된 타일이 옆 행에 붙어 보이지 않습니다. `dividers`가 있으면 선이 행을 나누므로 무시됩니다.

<Demo src="list/spacing">

::: fw react

<<< @/.vitepress/demos/list/spacing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/list/spacing.dart

:::

</Demo>

### variant

[Card](../surfaces/card) 안에 넣을 때는 <Fw react="`variant=&quot;text&quot;`를" flutter="`NebaVariant.text`를" /> 쓰세요. Card가 이미 sheet이므로 테두리가 겹치지 않습니다.

<Demo src="list/variants">

::: fw react

<<< @/.vitepress/demos/list/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/list/variants.dart

:::

</Demo>

### <Fw react="onClick" flutter="onPressed" /> · href · action

::: fw react

`onClick`이나 `href`를 주면 행 전체가 각각 `<button>` 또는 `<a>`가 됩니다. `action`은 그 클릭 영역 **바깥**에 놓이는 별도의 컨트롤 자리입니다. 행을 눌러 이동하면서 오른쪽 스위치는 따로 조작해야 하는 경우를 위한 것입니다.

:::

::: fw flutter

`onPressed`를 주면 행 전체가 버튼이 되고, `href`도 있으면 링크가 됩니다. `action`은 그 누를 수 있는 영역 **바깥**에 놓이는 별도의 컨트롤 자리입니다. 행을 눌러 이동하면서 오른쪽 스위치는 따로 조작해야 하는 경우를 위한 것입니다.

:::

<Demo src="list/interactive">

::: fw react

<<< @/.vitepress/demos/list/interactive.tsx

:::

</Demo>

## 접근성

::: fw react

- `List`는 `role="list"`를 명시합니다. Tailwind의 reset이 `<ul>`의 불릿을 제거하면 Safari가 목록이라는 의미까지 함께 잃기 때문입니다.
- `ListItem`의 겉은 항상 `<li>`이고, `onClick`이나 `href`에 따라 그 안에 `<button>` 또는 `<a>`가 들어갑니다.
- `selected`는 링크에 `aria-current="page"`, 버튼에 `aria-current="true"`를 붙입니다. 선택된 행은 toggle이 아니므로 `aria-pressed`는 쓰지 않습니다.

:::

::: fw flutter

- `NebaList`는 semantics 트리에서 목록이고 각 `NebaListItem`은 그 항목입니다. 웹에서는 `role="list"`와 `role="listitem"`으로 읽힙니다.
- 누를 수 있는 행은 항목 안의 버튼이고, `href`가 있으면 링크입니다. `action`은 같은 항목 안에서 그 옆에 놓입니다. Enter는 모든 행을 누르고, Space는 버튼인 행만 누릅니다.
- `selected`는 행을 선택된 것으로 표시하며, 웹에서는 `aria-current="true"`가 됩니다. toggle이 아닙니다.

:::

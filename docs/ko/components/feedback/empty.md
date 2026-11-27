---
title: Empty
order: 10
flutter: true
---

# Empty

<p class="neba-lede">내용이 있었어야 할 자리를 대신 채웁니다. 글리프 하나와 제목, 문장 한 줄, 그리고 다음 행동으로 이어지는 버튼으로 이루어집니다. 아무것도 걸리지 않은 검색 결과, 아직 아무도 쓰지 않은 받은 편지함, 첫 파일이 놓이기 전의 폴더에 씁니다.</p>

<Demo src="empty/hero" align="center" minHeight="260" />

::: fw react

```tsx
import { Button, Empty } from 'neba';

<Empty title="No projects yet" action={<Button size="sm">Create a project</Button>}>
  Everything you deploy shows up here.
</Empty>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaEmpty(
  title: const Text('No projects yet'),
  actions: <Widget>[
    NebaButton(onPressed: create, size: NebaSize.sm, child: const Text('Create a project')),
  ],
  child: const Text('Everything you deploy shows up here.'),
);
```

:::

## Props

<PropsTable name="Empty" />

::: fw react

`<div>`의 기본 속성은 그대로 전달되며, `render`로 요소를 바꿀 수 있습니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

:::

::: fw flutter

제목 아래의 문장은 `child`입니다. 상태는 받은 폭을 그대로 쓰고 담은 것을 가운데에 놓으며, 여럿을 한 줄에 둘 때처럼 높이가 늘어나면 세로로도 가운데에 놓습니다. 위젯에는 바꿔 끼울 요소가 없으므로 `render`는 없습니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

:::

## 예시

### title

제목의 기본값은 `locale`이 "여기에는 아무것도 없다"를 표현하는 문장입니다. 그래서 prop을 하나도 주지 않은 Empty도 문장 하나는 보여 줍니다. 무엇이 없는지 짚어 주는 쪽은 `title`이고, 대개 그렇게 쓰는 편이 좋습니다. <Fw react="`title={false}`는" flutter="`showTitle: false`는" /> 제목 없이 글리프와 문장만 남깁니다.

<Demo src="empty/title" minHeight="200">

::: fw react

<<< @/.vitepress/demos/empty/title.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/title.dart

:::

</Demo>

### icon

::: fw react

`icon`은 다른 아이콘 세트의 글리프나 일러스트, 브랜드 마크 등 어떤 노드든 받아 기본 트레이를 대신합니다. `<svg>`는 `size` 사다리에 맞춰지고 그 밖의 것은 원래 크기 그대로 놓입니다. `icon={false}`는 글리프를 없앱니다.

:::

::: fw flutter

`icon`은 다른 아이콘 세트의 글리프나 일러스트, 브랜드 마크 등 어떤 위젯이든 받아 기본 트레이를 대신합니다. `Icon`처럼 `IconTheme`을 읽는 글리프는 `size` 사다리에 맞춰 흐린 잉크로 그려지고, 그 밖의 것은 원래 크기 그대로 놓입니다. `showIcon: false`는 글리프를 없앱니다.

:::

<Demo src="empty/icon" minHeight="200">

::: fw react

<<< @/.vitepress/demos/empty/icon.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/icon.dart

:::

</Demo>

### <Fw react="action" flutter="actions" />

::: fw react

`action`은 본문 아래에 놓여 다음 행동으로 이어 줍니다. 첫 항목을 만드는 버튼이나 아무것도 걸리지 않은 필터를 지우는 링크가 여기에 들어갑니다. 여럿이면 fragment로 넘기면 되고, 한 줄에 놓여 함께 줄바꿈됩니다.

:::

::: fw flutter

`actions`는 본문 아래에 놓여 다음 행동으로 이어 줍니다. 첫 항목을 만드는 버튼이나 아무것도 걸리지 않은 필터를 지우는 링크가 여기에 들어갑니다. 여럿이면 8픽셀 간격으로 한 줄에 놓여 함께 줄바꿈됩니다.

:::

<Demo src="empty/action" minHeight="220">

::: fw react

<<< @/.vitepress/demos/empty/action.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/action.dart

:::

</Demo>

### variant

기본값은 `text`입니다. 빈 상태는 대개 이미 [Card](../surfaces/card)나 [Table](../display/table), 혹은 패널 안에 놓이는데 사각형 안에 사각형을 하나 더 그리는 것은 하나가 더 많은 것이기 때문입니다. `outline`과 `solid`는 그 영역의 경계를 표시해 줄 것이 달리 없을 때를 위한 것입니다.

<Demo src="empty/variants" minHeight="200">

::: fw react

<<< @/.vitepress/demos/empty/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/variants.dart

:::

</Demo>

### size와 density

`size`는 타입 스케일과 글리프 크기, 그리고 상태가 세로로 차지하는 자리를 정합니다. `density`는 여백만 바꾸며, 컨트롤 한 줄 높이 안에 상태를 넣어야 할 때 꺼내 쓰는 쪽입니다.

<Demo src="empty/size" minHeight="360">

::: fw react

<<< @/.vitepress/demos/empty/size.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/size.dart

:::

</Demo>

### color

시트는 물들지 않습니다. `color`는 하이라인과 focus ring까지만 닿고 거기서 멈춥니다. 기본값이 `secondary`인 이유는, 강조색을 입고 등장하는 빈 상태가 존재하지 않는 내용에 대해 무언가를 주장하는 셈이기 때문입니다. 비어 있다는 사실 자체가 문제일 때 옮기세요.

<Demo src="empty/color" minHeight="220">

::: fw react

<<< @/.vitepress/demos/empty/color.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/color.dart

:::

</Demo>

### locale

::: fw react

`locale`은 BCP 47 태그이고 기본 제목의 언어만 정합니다. `title`을 주면 무시되며, 모르는 태그는 영어로 돌아갑니다.

:::

::: fw flutter

`locale`은 기본 제목의 언어만 정하며, 없으면 `NebaProvider`의 것, 그다음 앱의 locale을 씁니다. `title`을 주면 무시되고, 앱이 `registerNebaMessages`로 등록하지 않은 언어는 영어로 돌아갑니다.

:::

<Demo src="empty/locale" minHeight="220">

::: fw react

<<< @/.vitepress/demos/empty/locale.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/empty/locale.dart

:::

</Demo>

### Table 안에서

[Table](../display/table)에는 행 대신 무엇을 보여 줄지 정하는 `empty` prop이 있고, 모든 열을 가로지르는 셀 하나에 렌더링됩니다. 그 셀은 자기 여백을 가지고 있으므로 대개 `density="compact"`와 함께 쓰는 편이 맞습니다.

<Demo src="empty/table" minHeight="260">

::: fw react

<<< @/.vitepress/demos/empty/table.tsx

:::

</Demo>

## 접근성

::: fw react

- root는 `role="status"` live region입니다. screen reader는 live region 안의 내용이 바뀔 때 그것을 읽는데, 목록 자리에 나타나는 Empty는 처음부터 문구를 담은 채 들어오므로 모든 screen reader가 읽어 주지는 않습니다. 읽는 사람 눈앞에서 목록이 빈 사실을 반드시 들려줘야 한다면, 처음부터 페이지에 `role="status"` 요소 하나를 두고 거기에 문구를 쓰세요. 처음부터 페이지의 일부로 놓이는 상태라면 `role={undefined}`을 넘기세요.
- 기본 글리프는 `aria-hidden`입니다. 제목이 이미 말한 것 외에 무엇도 새로 말하지 않기 때문입니다.
- 내용이 아직 오는 중이라면 [Skeleton](./skeleton)을, 올 것이 없다는 사실이 확인된 뒤에야 Empty를 쓰세요. 둘 다 보여 주지 않으면 답이 있어야 할 자리에 빈 사각형이 남습니다.

:::

::: fw flutter

- 상태 전체가 live region입니다. 웹에서는 `SemanticsRole.status`, Android와 iOS에서는 live region입니다. screen reader는 live region 안의 내용이 바뀔 때 그것을 읽는데, 목록 자리에 나타나는 Empty는 처음부터 문구를 담은 채 들어오므로 모든 screen reader가 읽어 주지는 않습니다. 처음부터 화면의 일부로 놓이는 상태라면 `role: SemanticsRole.none`을 넘기세요.
- 기본 글리프는 screen reader에게 아무것도 말하지 않습니다. 제목이 이미 말한 것 외에 무엇도 새로 말하지 않기 때문입니다.
- 내용이 아직 오는 중이라면 [Skeleton](./skeleton)을, 올 것이 없다는 사실이 확인된 뒤에야 Empty를 쓰세요. 둘 다 보여 주지 않으면 답이 있어야 할 자리에 빈 사각형이 남습니다.

:::

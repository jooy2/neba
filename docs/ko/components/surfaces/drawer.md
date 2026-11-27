---
title: Drawer
order: 10
flutter: true
---

# Drawer

<p class="neba-lede">창의 한쪽 변에 붙는 패널입니다. 페이지 위에 떠서 열고 닫힐 수도 있고, 레이아웃의 일부로 고정된 사이드바가 될 수도 있습니다. 어느 쪽이든 같은 패널입니다.</p>

<Demo src="drawer/hero" align="center" />

::: fw react

```tsx
import { Button, Drawer, List } from 'neba';

<Drawer trigger={<Button variant="outline">Open navigation</Button>} title="Workspace">
  <List>…</List>
</Drawer>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaDrawer(
  title: const Text('Workspace'),
  triggerBuilder: (BuildContext context, VoidCallback open) {
    return NebaButton(
      onPressed: open,
      variant: NebaVariant.outline,
      child: const Text('Open navigation'),
    );
  },
  child: navigation,
);
```

:::

## Props

<PropsTable name="Drawer" />

::: fw react

`<div>`의 native 속성은 panel로 전달됩니다. `color` · `title` · `children`만 위 표와 이름이 겹쳐 제외됩니다.

`DrawerClose`는 Base UI의 `Dialog.Close`를 그대로 내보낸 것입니다. `render` prop을 주면 어떤 요소든 자기가 속한 drawer를 닫습니다: `<DrawerClose render={<Button>Cancel</Button>} />`. `overlay` drawer의 것이며, `inline` drawer는 dialog가 아닙니다.

:::

::: fw flutter

위젯에는 밖에서 누름을 끼워 넣을 수 없으므로 trigger는 builder입니다. `triggerBuilder`는 drawer를 여는 callback을 받아 호출되고, 그것이 만든 위젯은 drawer를 쓴 자리에 남습니다. 닫을 때도 같은 방식으로 `NebaDrawerClose`를 씁니다. `builder`가 자기가 속한 drawer를 닫는 callback을 받으며, 두 mode 모두에서 동작합니다. 그래서 비제어 drawer의 Cancel 버튼에도 state가 필요 없습니다: `NebaDrawerClose(builder: (context, close) => NebaButton(onPressed: close, child: const Text('Cancel')))`.

overlay drawer는 앱의 root `Overlay`에 열립니다. navigator가 있는 `WidgetsApp`에는 이미 있고, navigator 없이 만든 앱은 home을 `Overlay.wrap`으로 감쌉니다. 패널은 drawer를 쓴 자리에서 빌드되므로 그 자리의 테마와 `NebaProvider` 기본값을 그대로 씁니다.

:::

공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

## 예시

### side

`side`는 패널이 붙는 변입니다. `left`와 `right`는 `size` 사다리에서 너비를 가져오고 높이를 채우며, `top`과 `bottom`은 너비를 채우고 내용만큼의 높이를 갖되 창의 85%를 넘지 않습니다.

<Demo src="drawer/sides" frameMinHeight="420">

::: fw react

<<< @/.vitepress/demos/drawer/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/drawer/sides.dart

:::

</Demo>

### mode

기본값인 `overlay`는 열어서 쓰는 drawer입니다. 스크림, focus 가둠, Esc, 그리고 닫힐 때 trigger로 돌아가는 focus까지 포함됩니다. `inline`은 같은 패널을 레이아웃에 놓습니다. 스크림도 <Fw react="portal" flutter="overlay" />도 닫을 것도 없으며, `open`이 패널을 흐름 안에 둘지 정합니다. 기본이 열림이므로 고정 사이드바에는 별도의 state가 필요 없습니다.

하나의 컴포넌트이므로, breakpoint에서 햄버거로 바뀌는 사이드바는 컴포넌트를 갈아 끼우는 일이 아니라 `mode` 하나가 바뀌는 일입니다.

<Demo src="drawer/inline">

<<< @/.vitepress/demos/drawer/inline.tsx

</Demo>

### rounded

`rounded`는 페이지를 향한 변의 두 모서리만 깎습니다. 옆면 패널이라면 위아래, 위아래 패널이라면 안쪽 두 개입니다. 창 가장자리에 닿은 모서리는 각진 채로 둡니다. 패널이 시트가 아니라 창의 연장처럼 읽혀야 한다면 끄세요.

<Demo src="drawer/rounded" frameMinHeight="320">

::: fw react

<<< @/.vitepress/demos/drawer/rounded.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/drawer/rounded.dart

:::

</Demo>

### dividers와 스크롤

스크롤되는 것은 본문뿐이므로 `title`, `description`, `actions`는 제자리에 있습니다. `dividers`는 구역 사이의 여백을 하이라인으로 바꾸는데, 헤더가 움직이지 않았다고 말해 주는 것이 바로 그 선입니다.

<Demo src="drawer/scrolling">

<<< @/.vitepress/demos/drawer/scrolling.tsx

</Demo>

### extent

`extent`는 패널이 자기 변에서 얼마나 들어오는지입니다. `left`와 `right`에서는 **너비**, `top`과 `bottom`에서는 **높이**입니다. <Fw react="숫자는 픽셀, 문자열은 CSS 길이입니다." flutter="논리 픽셀로 받으며, 창에 대한 비율은 `MediaQuery.sizeOf`로 계산합니다." /> 그대로 두면 옆면 패널은 `size`가 정한 너비를 씁니다.

::: fw react

```tsx
<Drawer side="right" extent={420} title="Details" />
<Drawer side="bottom" extent="50vh" title="Filters" />
```

:::

::: fw flutter

```dart
NebaDrawer(side: NebaSide.right, extent: 420, title: const Text('Details'));
NebaDrawer(
  side: NebaSide.bottom,
  extent: MediaQuery.sizeOf(context).height / 2,
  title: const Text('Filters'),
);
```

:::

### headingLevel

::: fw react

제목이 쓰이는 heading 레벨이며 기본값은 `2`입니다. `inline` drawer의 제목은 페이지 안의 heading이므로 drawer가 놓인 자리에 맞는 레벨을 주세요. `<h2>`로 시작하는 섹션 안이라면 `3`입니다. `overlay` drawer는 자기만의 heading 순서를 여는 dialog라서 바꿀 일이 드뭅니다.

```tsx
<Drawer mode="inline" title="Filters" headingLevel={3} />
```

:::

::: fw flutter

화면 낭독기가 제목을 읽는 heading 레벨이며 기본값은 `2`입니다. `inline` drawer의 제목은 화면 안의 heading이므로 drawer가 놓인 자리에 맞는 레벨을 주세요. 레벨 2 heading으로 시작하는 섹션 안이라면 `3`입니다. `overlay` drawer는 자기만의 heading 순서를 여는 dialog라서 바꿀 일이 드뭅니다.

```dart
NebaDrawer(mode: NebaDrawerMode.inline, title: const Text('Filters'), headingLevel: 3);
```

:::

### keepMounted

::: fw react

기본적으로 닫힌 drawer의 내용은 DOM에 없습니다. `keepMounted`를 주면 숨겨진 채 DOM에 남으므로, 크롤러가 찾아야 하는 내비게이션 링크를 담은 drawer에 쓰세요. `overlay` drawer는 portal로 렌더되므로 내용이 서버 HTML이 아니라 hydration 뒤에 들어오고, 닫힌 `inline` drawer는 서버 HTML에도 들어갑니다. drawer로 접히는 [Sidebar](../layout/sidebar)는 자기 `keepMounted`를 여기로 넘깁니다.

```tsx
<Drawer keepMounted trigger={<Button>Menu</Button>} title="Navigation">
  <nav>…</nav>
</Drawer>
```

:::

::: fw flutter

기본적으로 닫힌 drawer의 내용은 빌드되지 않습니다. `keepMounted`를 주면 offstage로, focus 순서와 semantics 트리 밖에서 빌드된 채 남으므로 스크롤 위치나 입력하다 만 필드 같은 안의 state가 다음에 열 때까지 유지됩니다. drawer로 접히는 [Sidebar](../layout/sidebar)는 자기 `keepMounted`를 여기로 넘깁니다.

```dart
NebaDrawer(keepMounted: true, title: const Text('Navigation'), triggerBuilder: menu, child: nav);
```

:::

::: fw react

### classNames

`className`은 panel에 붙습니다. 그 바깥과 안쪽은 모두 `classNames`로 닿습니다.

```tsx
<Drawer title="Filters" classNames={{ body: 'flex flex-col gap-4', actions: 'justify-between' }} />
```

slot은 [Dialog](../feedback/dialog)와 같은 `backdrop`, `viewport`, `title`, `description`, `close`, `body`, `actions`입니다. `backdrop`과 `viewport`는 `overlay` mode에만 있고, 둘 다 panel 바깥인 `<body>` 끝에 그려집니다. `inline` drawer의 제목은 호스트 stylesheet의 heading 규칙을 막아 두지만, `classNames.title`이 정하는 속성은 넘긴 class를 따릅니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

:::

::: fw flutter

### safeArea

휴대전화에서 overlay drawer는 상태 표시줄, 노치, 홈 인디케이터 같은 시스템 inset 아래까지 깔립니다. 기본으로 켜진 `safeArea`는 패널이 닿는 세 변의 inset만큼 내용을 안쪽으로 들이고, 페이지를 향한 변에는 inset을 주지 않습니다. 시트는 여전히 화면 끝까지 닿고 그 위의 내용만 움직입니다. inset은 패널이 열리는 root overlay에서 읽으므로, drawer를 쓴 자리를 `SafeArea`가 감싸고 있어도 사라지지 않습니다. `inline` drawer는 이미 inset을 처리한 레이아웃의 일부이므로 inset을 받지 않습니다.

:::

## 접근성

::: fw react

- `overlay` mode에서 패널은 modal dialog입니다. focus가 안에 갇히고, 뒤 페이지는 inert가 되며, Esc로 닫히고 focus는 trigger로 돌아갑니다.
- `title`이 drawer의 이름이 되고 `description`이 설명이 되며, `aria-labelledby`와 `aria-describedby`로 연결됩니다. 둘 다 없는 drawer에는 `aria-label`을 따로 주세요.
- `modal="trap-focus"`는 페이지의 스크롤과 클릭은 남기고 focus만 안에 붙잡습니다.
- `dismissible={false}`는 Esc와 스크림 클릭을 모두 취소합니다. 그런 drawer에는 닫는 action을 반드시 함께 주세요. 다른 출구가 없습니다.
- `inline` drawer는 dialog가 아닙니다. focus를 가져가지도, 가두지도, 알리지도 않습니다. `title`은 평범한 heading이므로 `headingLevel`로 페이지의 heading 순서 안에 놓으세요.
- `keepMounted`로 DOM에 남은 닫힌 drawer는 숨겨져 있습니다. 열리기 전까지 그 내용은 tab 순서에도 accessibility tree에도 없고, focus를 가두지 않으며 페이지도 그대로 쓸 수 있습니다.
- ×의 접근성 이름은 `locale`이 정합니다. `closeLabel`로 직접 쓸 수도 있습니다.

:::

::: fw flutter

- `overlay` mode에서 패널은 route를 감싸는 dialog입니다. 안에서 focus를 받을 수 있는 첫 요소가 focus를 갖고, Tab은 안에서만 돌며, 화면 낭독기는 패널만 읽습니다. Esc로 닫히고 focus는 열기 전에 갖고 있던 곳으로 돌아갑니다.
- `title`은 `headingLevel`의 heading이자 dialog의 이름입니다. Flutter에는 `aria-describedby`에 해당하는 것이 없으므로 `description`은 읽는 순서대로 제목 다음에 읽힙니다. 제목이 없는 drawer에는 `semanticLabel`을 주세요.
- `modal: NebaModal.trapFocus`는 페이지를 쓸 수 있게 둔 채 focus만 안에 붙잡습니다. 페이지를 누르면 그 누름은 페이지에 닿고 drawer는 닫힙니다. `NebaModal.off`은 Tab이 밖으로 나가는 것도 허용합니다.
- `dismissible: false`는 Esc, 스크림 누름, 화면 낭독기의 닫기 동작을 모두 취소합니다. 그런 drawer에는 닫는 action을 반드시 함께 주세요. 다른 출구가 없습니다.
- `inline` drawer는 dialog가 아닙니다. focus를 가져가지도, 붙잡지도, 알리지도 않습니다. `title`은 평범한 heading이므로 `headingLevel`로 화면의 heading 순서 안에 놓으세요.
- `keepMounted`로 빌드된 채 남은 닫힌 drawer는 offstage입니다. 열리기 전까지 그 내용은 focus 순서에도 semantics 트리에도 없고, 페이지도 그대로 쓸 수 있습니다.
- ×의 이름은 `locale`이 정합니다. `closeLabel`로 직접 쓸 수도 있습니다.

:::

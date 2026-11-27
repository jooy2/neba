---
title: NavigationMenu
order: 30
flutter: true
---

# NavigationMenu

<p class="neba-lede">사이트의 내비게이션입니다. 목적지들이 한 줄로 놓이고, 그중 일부는 더 많은 목적지가 담긴 패널을 엽니다. 모든 행이 진짜 링크이며, 그래서 링크 목록에도, 상태 표시줄에도, 크롤러의 색인에도 들어갑니다.</p>

<Demo src="navigation-menu/hero" minHeight="260" />

::: fw react

```tsx
import { NavigationMenu, NavigationMenuItem, NavigationMenuLink } from 'neba';

<NavigationMenu aria-label="Main">
  <NavigationMenuItem label="Product">
    <NavigationMenuLink href="/analytics" title="Analytics" description="Every number." />
  </NavigationMenuItem>
  <NavigationMenuItem label="Pricing" href="/pricing" />
</NavigationMenu>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaNavigationMenu(
  semanticLabel: 'Main',
  children: <Widget>[
    NebaNavigationMenuItem(
      label: const Text('Product'),
      children: <Widget>[
        NebaNavigationMenuLink(
          href: Uri.parse('/analytics'),
          onPressed: openAnalytics,
          title: const Text('Analytics'),
          description: const Text('Every number.'),
        ),
      ],
    ),
    NebaNavigationMenuItem(
      label: const Text('Pricing'),
      href: Uri.parse('/pricing'),
      onPressed: openPricing,
    ),
  ],
);
```

:::

## Props

<PropsTable name="NavigationMenu" />

::: fw react

`<nav>`의 모든 속성이 `color`를 제외하고 그대로 전달됩니다.

[Menu](./menu)와의 차이는 행이 *무엇인가*에 있습니다. 메뉴는 액션을 담으므로 행이 `menuitem`입니다. 이쪽은 링크를 담으므로 `<a>`로 가득 찬 `<nav>`입니다. 행이 무언가를 _하면_ Menu를, 어딘가로 _가면_ 이 컴포넌트를 쓰세요.

:::

::: fw flutter

`semanticLabel`은 `aria-label`처럼 screen reader에게 내비게이션의 이름을 알려 줍니다. 패널은 [Popover](../surfaces/popover)처럼 앱의 root `Overlay`에 그려집니다.

[Menu](./menu)와의 차이는 행이 *무엇인가*에 있습니다. 메뉴는 액션을 담으므로 행이 menu item입니다. 이쪽은 링크를 담으므로 링크로 이루어진 내비게이션 영역이고, 각 링크는 `href`와 함께 읽힙니다. 행이 무언가를 _하면_ Menu를, 어딘가로 _가면_ 이 컴포넌트를 쓰세요.

패키지는 아무것도 직접 열지 않으므로 링크는 콜백입니다. `onPressed`가 router나 URL launcher를 부르고, `Uri`로 받는 `href`는 screen reader와, 웹에서는 브라우저에 가는 곳을 알려 줍니다. `target`과 `rel` 자리는 `newTab`이 대신합니다. `delay`와 `closeDelay`는 `Duration`입니다. `keepMounted`는 없습니다. 이 prop은 서버 렌더와 크롤러가 링크를 보게 하려고 있는 것인데, Flutter에서는 닫힌 패널을 아예 만들지 않습니다.

:::

### NavigationMenuItem

<PropsTable name="NavigationMenuItem" />

### NavigationMenuLink

<PropsTable name="NavigationMenuLink" />

## 예시

### 패널이 있는 항목과 없는 항목

::: fw react

children이 있는 항목은 trigger와 패널이 되고, `href`만 있고 children이 없는 항목은 링크가 됩니다. 두 가지는 스크린 리더에 다르게 전달됩니다. 한 항목이 둘 다 될 수는 없습니다. children이 있으면 `href`는 쓰이지 않고, 개발 빌드에서는 콘솔에 경고가 남습니다. 그 목적지는 패널 안에 `NavigationMenuLink`로 넣으세요.

:::

::: fw flutter

children이 있는 항목은 trigger와 패널이 되고, children이 없는 항목은 `onPressed`와 `href`를 가진 링크가 됩니다. 두 가지는 스크린 리더에 다르게 전달됩니다. 한 항목이 둘 다 될 수는 없습니다. children이 있으면 `href`와 `onPressed`는 쓰이지 않고, debug 빌드에서 그렇다고 알려 줍니다. 그 목적지는 패널 안에 `NebaNavigationMenuLink`로 넣으세요.

:::

### columns

패널이 링크를 몇 개의 열로 배치할지 정합니다. 짧은 목록은 한 열이 맞고, 지역이나 제품이 많은 넓은 메뉴는 두세 열을 원합니다.

<Demo src="navigation-menu/columns" minHeight="220">

::: fw react

<<< @/.vitepress/demos/navigation-menu/columns.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/navigation_menu/columns.dart

:::

</Demo>

### orientation

`vertical`은 항목을 세로로 쌓고 패널을 옆으로 엽니다. 바가 아니라 내비게이션 레일이 됩니다.

<Demo src="navigation-menu/orientation" minHeight="180">

::: fw react

<<< @/.vitepress/demos/navigation-menu/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/navigation_menu/orientation.dart

:::

</Demo>

### header 안에서

<Demo src="navigation-menu/header" minHeight="220">

::: fw react

<<< @/.vitepress/demos/navigation-menu/header.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/navigation_menu/header.dart

:::

</Demo>

## 접근성

::: fw react

- 진짜 `<nav>`로 렌더링됩니다. 한 페이지에 nav가 둘 이상이면 `aria-label`을 주세요.
- 모든 목적지가 `<a href>`이므로 새 탭에서 열고, 주소를 복사하고, 크롤러가 따라가고, 스크린 리더의 링크 목록에서 도달할 수 있습니다. 패널의 링크는 패널을 처음 열기 전에도 숨긴 채 렌더되므로 서버 렌더에도 들어갑니다. 항목에 `keepMounted={false}`를 주면 열 때까지 빠집니다.
- 키보드로 조작합니다. 방향키로 항목 사이와 열린 패널 안을 오가고, Escape로 닫습니다.
- 패널은 항목 사이를 이동할 때 닫혔다 열리는 대신 크기를 바꿉니다. 그래서 줄을 가로지르는 동작이 하나의 표면처럼 읽힙니다.

:::

::: fw flutter

- screen reader에게는 내비게이션 영역으로 읽힙니다. 한 페이지에 내비게이션이 둘 이상이면 `semanticLabel`을 주세요.
- 패널이 있는 항목은 펼쳐졌는지를 알려 주는 버튼입니다. 패널이 없는 항목과 패널 안의 모든 행은 `href`와 함께 읽히는 링크입니다.
- 항목마다 focus 순서에서 자기 자리를 가지며, 패널을 여는 항목은 disabled여도 자리를 지킵니다. 줄을 따라가는 방향키는 항목 사이를 오가되 disabled 항목은 건너뛰고 양 끝에서 멈춥니다. 줄을 가로지르는 방향키(아래쪽, 레일이라면 inline end 쪽)는 패널을 엽니다. 열린 항목에서 Tab을 누르면 패널로 들어가고, 패널 끝에서 다음 항목으로 나옵니다. 거기서 Shift+Tab을 누르면 다시 패널로 들어옵니다. 패널 안에서는 방향키가 링크를 차례로 옮겨 다니며, 끝에 이르면 처음으로 돌아갑니다. Escape는 패널을 닫고 focus를 그 항목에 돌려주며, focus가 내비게이션을 벗어나도 패널이 닫힙니다.
- 줄 전체에 sheet가 하나입니다. 항목 사이를 옮겨 가면 sheet를 닫고 새로 여는 대신 위의 내용을 바꾸고 그 크기로 부드럽게 맞춥니다.

:::

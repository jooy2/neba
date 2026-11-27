---
title: BottomNavigation
order: 22
flutter: true
---

# BottomNavigation

<p class="neba-lede">창의 아래 가장자리에 고정되어 앱의 주요 목적지를 나란히 보여 주는 바입니다. 글리프 하나와 그 아래 이름 하나가 한 칸이고, 지금 있는 곳은 현재 페이지로 표시됩니다.</p>

<Demo src="bottom-navigation/hero" minHeight="200" />

::: fw react

```tsx
import { BottomNavigation, BottomNavigationItem } from 'neba';

<BottomNavigation label="Main" value={section} onValueChange={setSection}>
  <BottomNavigationItem value="home" icon={<HomeIcon />}>
    홈
  </BottomNavigationItem>
  <BottomNavigationItem value="search" icon={<SearchIcon />}>
    검색
  </BottomNavigationItem>
</BottomNavigation>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaBottomNavigation<String>(
  label: 'Main',
  value: section,
  onValueChange: (String next) => setState(() => section = next),
  children: const <NebaBottomNavigationItem<String>>[
    NebaBottomNavigationItem<String>(value: 'home', icon: homeIcon, child: Text('홈')),
    NebaBottomNavigationItem<String>(value: 'search', icon: searchIcon, child: Text('검색')),
  ],
);
```

:::

## Props

<PropsTable name="BottomNavigation" />

<PropsTable name="BottomNavigationItem" />

::: fw react

나머지 `<nav>` 속성은 루트로, 나머지 `<button>` 속성은 각 목적지로 전달됩니다. 예외는 `onChange`로, 여기서 들을 만한 변화는 `onValueChange`입니다.

:::

::: fw flutter

목적지는 `NebaBottomNavigationItem`의 목록인 `children`이고, 바는 그 `value`의 타입에 대해 제네릭입니다. `value`와 `onValueChange`를 함께 넘기면 controlled가 되고, `null`로 두면 바가 `defaultValue`에서 시작해 상태를 스스로 관리합니다. Flutter 바에는 바꿔 끼울 요소가 없으므로 `render`는 없습니다.

:::

공통 축(`variant` `size` `color` `density` `elevation` `position`)의 의미는 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### position

::: fw react

기본값은 `fixed`입니다. 라이브러리의 다른 컴포넌트가 모두 `static`을 기본으로 두는 것과 반대이고, 그것이 이 컴포넌트가 하는 일입니다. 페이지가 무엇을 하든 창의 아래 가장자리에 붙어 있습니다. 그러면 페이지는 첫 화면이 바 뒤에 깔리지 않도록 스스로 아래쪽 여백을 마련해야 합니다.

`sticky`는 바를 흐름 안에 두되 스크롤 영역의 아래 가장자리에서 멈추게 합니다. `static`은 그냥 흐름 안의 시트입니다.

:::

::: fw flutter

기본값은 `fixed`로, 라이브러리의 다른 컴포넌트가 모두 `static`을 기본으로 두는 것과 반대입니다. Flutter에는 창을 기준으로 고정하는 배치가 없으므로, `position`은 바를 어떻게 그릴지를 정하고 바를 어디에 둘지는 부모가 정합니다. `fixed`와 `sticky`는 내용을 마주 보는 헤어라인만 있는 각진 시트를 그리고 목적지를 시스템 inset 안쪽에 둡니다. `static`은 페이지 중간에 놓는 모서리가 둥근 시트입니다. 바는 화면 `Column`의 맨 아래, 스크롤되는 부분 밑에 두거나, [PageLayout](../layout/page-layout)의 `footer`로 넘기세요. 레이아웃은 `static`이 아닌 바를 페이지 아래에 붙잡아 둡니다.

:::

<Demo src="bottom-navigation/pinned" minHeight="280">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/pinned.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bottom_navigation/pinned.dart

:::

</Demo>

### labels

`all`은 모든 이름을 그립니다. `selected`는 지금 있는 목적지의 이름만, `none`은 아무 이름도 그리지 않습니다. `selected`에서는 모든 항목이 이름 한 줄만큼의 자리를 유지하므로, 선택이 옮겨 가도 글리프가 움직이지 않습니다.

::: fw react

그리지 않은 이름도 문서에는 남습니다. 글리프 하나뿐인 버튼은 접근성 이름이 아예 없으므로, 사라지는 것은 픽셀뿐입니다.

:::

::: fw flutter

그리지 않은 이름도 그대로 읽힙니다. 글리프 하나뿐인 목적지는 이름이 아예 없으므로, 사라지는 것은 픽셀뿐입니다. screen reader는 항목의 `child`인 `Text`의 글자를 읽고, `child`가 `Text`가 아니면 `semanticLabel`이 필요합니다.

:::

<Demo src="bottom-navigation/labels" minHeight="320">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/labels.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bottom_navigation/labels.dart

:::

</Demo>

### href

::: fw react

`href`를 준 목적지는 진짜 `<a>`가 됩니다. 길게 눌러 새 탭으로 열 수 있고, 주소가 상태 표시줄에 뜨며, 라우터를 부르는 `<button>`으로는 둘 다 되지 않습니다.

:::

::: fw flutter

패키지는 스스로 아무것도 열지 않으므로, 어딘가로 가는 목적지는 콜백입니다. 바의 `onValueChange`나 항목의 `onPressed`가 라우터를 부르고, `href`는 항목을 링크로 만들어 screen reader와, 웹에서는 브라우저에 갈 곳을 알립니다. `newTab`은 링크가 앱 밖으로 나간다는 뜻이고, screen reader가 이름 뒤에 "(새 창에서 열림)"을 읽습니다. `target`과 `rel`은 없습니다.

:::

<Demo src="bottom-navigation/links" minHeight="120">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/links.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bottom_navigation/links.dart

:::

</Demo>

### variant, divider, safeArea

`variant`는 다른 컨테이너에서와 같은 말을 합니다. 시트에는 색이 들지 않고, 색 계열을 입는 것은 지금 있는 목적지 하나뿐입니다. `divider`는 내용을 마주 보는 위쪽 가장자리의 헤어라인이고 기본이 켜짐입니다. `safeArea`는 <Fw react="`env(safe-area-inset-bottom)`만큼 아래를 띄워 홈 인디케이터를 피하되" flutter="아래와 양옆의 시스템 inset, 곧 홈 인디케이터와 노치만큼 줄을 안쪽으로 두되" /> 시트 자체는 화면 끝까지 그대로 닿습니다.

<Demo src="bottom-navigation/appearance" minHeight="360">

::: fw react

<<< @/.vitepress/demos/bottom-navigation/appearance.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/bottom_navigation/appearance.dart

:::

</Demo>

### 제어하기

`value`를 넘기면 바는 자체 상태를 갖지 않습니다. 라우터가 지금 있는 곳을 알고 있을 때 쓰는 형태입니다.

::: fw react

```tsx
<BottomNavigation value={pathname} onValueChange={navigate}>
  <BottomNavigationItem value="/home" icon={<HomeIcon />}>
    홈
  </BottomNavigationItem>
</BottomNavigation>
```

:::

::: fw flutter

```dart
NebaBottomNavigation<String>(
  value: location,
  onValueChange: navigate,
  children: const <NebaBottomNavigationItem<String>>[
    NebaBottomNavigationItem<String>(value: '/home', icon: homeIcon, child: Text('홈')),
  ],
);
```

:::

## 접근성

::: fw react

- 루트는 `<nav>`이고 `label`이 그 이름이 됩니다. `role="tablist"`가 아닙니다. 탭 목록은 세트 전체에 tab 정지점 하나와 그 안의 방향키 이동을 약속하고, 하단 내비게이션은 패널이 아니라 페이지를 바꿉니다.
- 지금 있는 목적지에는 `aria-current="page"`가 붙습니다.
- 각 목적지는 진짜 `<button>`이거나, `href`가 있으면 진짜 `<a>`입니다.
- `labels`가 이름을 그리지 않아도 그 이름은 문서에 남아 목적지의 접근성 이름이 됩니다.
- `position="fixed"`일 때 페이지 아래쪽에 바 높이만큼 여백을 두세요. 첫 화면의 마지막 줄이 바에 가립니다.

:::

::: fw flutter

- screen reader는 `label`로 이름 붙은 내비게이션 영역을 듣습니다. tab bar가 아닙니다. tab bar는 세트 전체에 focus 정지점 하나와 그 안의 방향키 이동을 약속하고, 하단 내비게이션은 패널이 아니라 화면을 바꿉니다. 목적지마다 정지점이 하나씩 있습니다.
- 한 화면에 바가 둘 이상이면 모두 `label`을 주세요. 이름 없는 내비게이션 영역이 둘째로 나오면 Flutter의 semantics 검사가 실패합니다.
- 지금 있는 목적지는 선택된 항목으로 읽힙니다.
- 각 목적지는 버튼이거나, `href`가 있으면 링크입니다. Enter는 둘 다 누르고, Space는 버튼만 누르고 링크는 누르지 않습니다.
- `labels`가 이름을 그리지 않아도 그 이름은 그대로 목적지의 이름입니다.

:::

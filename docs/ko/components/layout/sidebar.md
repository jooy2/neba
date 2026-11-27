---
title: Sidebar
order: 4
flutter: true
---

# Sidebar

<p class="neba-lede">페이지 내용 옆의 열이며, 창이 좁아져 열을 담을 수 없게 되면 drawer가 됩니다. 실제 <code>&lt;aside&gt;</code>를 렌더링하며 이는 complementary 랜드마크입니다.</p>

<Demo src="sidebar/hero" minHeight="300" />

::: fw react

```tsx
import { List, ListItem, Sidebar } from 'neba';

<Sidebar label="목차">
  <List variant="text">
    <ListItem href="/overview" selected>
      개요
    </ListItem>
    <ListItem href="/components">컴포넌트</ListItem>
  </List>
</Sidebar>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaSidebar(label: '목차', child: navigation);
```

:::

## Props

### Sidebar

<PropsTable name="Sidebar" />

::: fw react

`<aside>`의 native 속성은 그대로 전달됩니다. 다만 `color`와 `title`은 예외입니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

`ref`는 열에 붙습니다. 사이드바가 접혀 있는 동안에는 열이 없으므로 `null`입니다.

자기 children만 배치합니다. 페이지가 사이드바를 _둘러싸도록_ 하려면 [PageLayout](./page-layout)의 `sidebar`나 `endSidebar` 자리에 넣으세요.

:::

::: fw flutter

`width`, `minWidth`, `maxWidth`는 논리 픽셀이고 `collapseBelow`는 `NebaBreakpoint`입니다. 어떤 너비도 그보다 좁지 않은 `NebaBreakpoint.xs`가 React의 `'none'`입니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

자기 child만 배치하며, 주어진 높이를 씁니다. `Row` 안에서는 `CrossAxisAlignment.stretch`를 주세요. 내용은 열 안에서 스크롤됩니다. 페이지가 사이드바를 _둘러싸도록_ 하려면 [PageLayout](./page-layout)의 `sidebar`나 `endSidebar` 자리에 넣으세요. React 패키지에는 없는 `safeArea`는 레이아웃이 열에 넘긴 시스템 inset, drawer일 때는 drawer의 inset만큼 내용을 비켜 세웁니다.

:::

### SidebarTrigger

<PropsTable name="SidebarTrigger" />

::: fw react

[IconButton](../inputs/icon-button)이 받는 나머지 prop은 그대로 전달됩니다. 열 대상이 있으려면 PageLayout 안에 있어야 하며, 밖에서는 아무것도 그리지 않습니다. breakpoint 이상에서는 마크업에서 빠지는 대신 CSS로 숨겨지므로, 페이지가 도착하고 잠시 뒤에 header 안으로 튀어나오는 일이 없습니다.

:::

::: fw flutter

[IconButton](../inputs/icon-button)이며, `onPressed`는 누름이 drawer를 열거나 닫은 뒤에 호출됩니다. 열 대상이 있으려면 PageLayout 안에 있어야 하며, 밖에서는 아무것도 빌드하지 않고 안에서도 breakpoint 이상에서는 아무것도 빌드하지 않습니다. 이때 [Header](./header)는 이 버튼을 자리에서 간격째 뺍니다.

:::

## 예시

### width · size

`size`가 열의 기본 너비를 정하고(`md`는 <Fw react="16rem" flutter="256 논리 픽셀" />), `width`가 <Fw react="픽셀 숫자나 CSS 길이로" flutter="논리 픽셀 숫자로" /> 그것을 덮어씁니다.

### resizable

안쪽 가장자리를 끌 수 있게 합니다. `minWidth`와 `maxWidth`가 범위를 정하고, `onResize`는 끄는 동안 매 걸음 호출되고, `onResizeEnd`는 놓을 때 한 번 호출되므로 기억해 둘 너비는 여기서 저장하면 됩니다. 핸들은 focus를 받는 <Fw react='`role="separator"`라' flutter="semantics 트리의 slider이고 안쪽 가장자리 안 8픽셀 폭이라" /> 좌우 화살표로도 같은 일을 할 수 있습니다.

<Demo src="sidebar/resizable" minHeight="300">

<<< @/.vitepress/demos/sidebar/resizable.tsx

</Demo>

### side

`start`는 사이드바를 시작 쪽에, `end`는 끝 쪽에 두므로 RTL에서는 둘의 좌우가 바뀝니다. [PageLayout](./page-layout) 안에서는 어느 자리에 넣었는지가 정해 주므로 이 prop이 필요 없습니다.

<Demo src="sidebar/sides" minHeight="300">

<<< @/.vitepress/demos/sidebar/sides.tsx

</Demo>

### collapseBelow

열이 scrim 위의 [Drawer](../surfaces/drawer)가 되는 너비입니다. focus가 안에 갇히고, Escape로 닫히며, 닫으면 focus가 trigger로 돌아갑니다. 어느 모습이든 children은 문서에 한 번만 존재하고, `title`은 drawer일 때만 그려집니다.

기본값은 PageLayout의 값이며, 레이아웃 밖에서는 <Fw react="`none`" flutter="`NebaBreakpoint.xs`" />입니다.

::: fw react

drawer의 코드는 별도 chunk로 나뉘어 있어, 사이드바가 처음 접히거나 pointer나 focus가 SidebarTrigger에 닿을 때 내려받습니다. 사이드바가 계속 열로 남는 페이지는 이 코드를 받지 않습니다.

:::

### 접힌 사이드바 다시 열기

창이 좁아져 담을 수 없게 된 사이드바는 SidebarTrigger로 다시 불러옵니다. [Header](./header)의 `brand` 자리, 로고 앞에 두세요.

::: fw react

```tsx
import { Header, PageLayout, Sidebar, SidebarTrigger } from 'neba';

<PageLayout header={<Header brand={<SidebarTrigger />} />} sidebar={<Sidebar>…</Sidebar>}>
  페이지
</PageLayout>;
```

:::

::: fw flutter

```dart
NebaPageLayout(
  header: const NebaHeader(brand: <Widget>[NebaSidebarTrigger(), Text('Neba')]),
  sidebar: NebaSidebar(child: navigation),
  child: page,
);
```

:::

### keepMounted

::: fw react

서버는 열을 보내므로, 스크립트를 실행하지 않는 크롤러는 어느 쪽이든 사이드바의 링크를 읽습니다. Google처럼 스크립트를 실행하며 휴대폰 너비로 렌더하는 크롤러에게는 사이드바가 닫힌 drawer로 접히고, 닫힌 drawer는 DOM에 없습니다. `keepMounted`를 주면 닫힌 drawer의 내용이 숨겨진 채 DOM에 남아 링크가 페이지에 그대로 있습니다. 사이드바가 열일 때는 아무것도 바꾸지 않습니다.

```tsx
<Sidebar collapseBelow="md" keepMounted>
  <nav>…</nav>
</Sidebar>
```

:::

::: fw flutter

닫힌 drawer의 내용은 빌드되지 않습니다. `keepMounted`를 주면 offstage로 빌드된 채 남으므로, 스크롤 위치나 고르다 만 필터가 다음에 열 때까지 유지됩니다. 사이드바가 열일 때는 아무것도 바꾸지 않습니다.

```dart
NebaSidebar(collapseBelow: NebaBreakpoint.md, keepMounted: true, child: filters);
```

:::

### sticky

<Fw react="PageLayout 안에서는 켜져 있고 밖에서는 꺼져 있으므로, 단독으로 쓴 Sidebar는 `sticky`를 주지 않으면 sticky가 아닙니다." flutter="PageLayout 안에서는 켜져 있습니다. Flutter에는 sticky position이 없어서 열을 붙잡는 것은 레이아웃이며, 단독으로 쓴 Sidebar는 다른 상자와 같습니다." /> 페이지가 스크롤될 때는 header 아래에서 시작해 남은 창 높이만큼인 sticky 열이 되고, 내용만 스크롤될 때는 이미 레이아웃 높이만큼이라 아무것도 달라지지 않습니다.

## 접근성

::: fw react

- `<aside>`(`complementary` 랜드마크)를 렌더링하고, `label`이 없으면 `locale`의 "사이드바"에 해당하는 단어로 스스로를 이름 짓습니다. 사이드바가 둘인 페이지는 반드시 둘 다 이름을 주어야 합니다.
- 접힌 상태는 modal dialog입니다. focus가 안에 갇히고, Escape로 닫히며, focus는 trigger로 돌아갑니다.
- `keepMounted`로 DOM에 남은 닫힌 drawer는 숨겨져 있으므로, 그 내용은 tab 순서에도 accessibility tree에도 없고 focus를 가두지도 않습니다.
- 크기 조절 핸들은 `tabindex="0"`인 `role="separator"`이며 `locale`이 이름을 붙입니다. 좌우 화살표가 16px씩 움직입니다.
- `locale`은 PageLayout에서 물려받으므로 페이지당 한 번만 씁니다.

:::

::: fw flutter

- 열은 `complementary` 영역이며, `label`이 없으면 `locale`의 "사이드바"에 해당하는 단어로 스스로를 이름 짓습니다. 다른 영역 안에서는 Flutter가 두 번째 영역을 허용하지 않으므로 평범한 묶음이 됩니다. 사이드바가 둘인 화면은 반드시 둘 다 이름을 주어야 합니다.
- 접힌 상태는 modal dialog입니다. focus가 안에 갇히고, Escape로 닫히며, focus는 열기 전에 갖고 있던 곳으로 돌아갑니다.
- `keepMounted`로 빌드된 채 남은 닫힌 drawer는 offstage이므로, 그 내용은 focus 순서에도 semantics 트리에도 없습니다.
- 크기 조절 핸들은 focus를 받는 slider이며 `locale`이 이름을 붙이고, 값은 너비입니다. 화면 낭독기의 증가와 감소, 좌우 화살표가 16픽셀씩 움직입니다.
- `locale`은 PageLayout에서 물려받으므로 화면당 한 번만 씁니다.

:::

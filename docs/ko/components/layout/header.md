---
title: Header
order: 2
flutter: true
---

# Header

<p class="neba-lede">페이지 맨 위의 바로, 앞쪽 자리와 가운데, 뒤쪽 자리로 나뉩니다. 실제 <code>&lt;header&gt;</code>를 렌더링하며 문서 최상단에서 이 태그는 banner 랜드마크입니다.</p>

<Demo src="header/hero" />

::: fw react

```tsx
import { AppLogo, Button, Header } from 'neba';

<Header brand={<AppLogo name="Neba" showName />} actions={<Button size="sm">로그인</Button>}>
  <nav>…</nav>
</Header>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaHeader(
  brand: const <Widget>[Text('Neba')],
  actions: <Widget>[
    NebaButton(onPressed: signIn, size: NebaSize.sm, child: const Text('로그인')),
  ],
  children: navigation,
);
```

:::

## Props

<PropsTable name="Header" />

::: fw react

`<header>`의 native 속성은 그대로 전달됩니다. 다만 `color`와 `title`은 컴포넌트가 쓰는 이름입니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

혼자서도 동작합니다. [PageLayout](./page-layout) 안에서는 자기 자신을 등록해, 자리를 지키는 [Sidebar](./sidebar)가 창 위에서 얼마나 내려와 시작해야 하는지 알게 합니다.

:::

::: fw flutter

세 자리는 목록이며 각각 하나의 줄로 놓이므로, 로고와 이름이나 버튼 두 개를 따로 감쌀 필요가 없습니다. 창 폭 때문에 숨은 [Show](./show)와 열어 줄 drawer가 없는 [SidebarTrigger](./sidebar#sidebartrigger)는 `display: none`이 flex 줄에서 요소를 빼듯 자리에서 간격째 빠집니다. `maxWidth`는 사다리의 한 단계나 직접 준 폭인 `NebaMeasure`를 받고, breakpoint별 map은 받지 않습니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

혼자서도 다른 상자처럼 바로 동작합니다. [PageLayout](./page-layout)의 `header`로 넘기면 페이지가 스크롤되는 동안 레이아웃이 위에 붙잡아 두는 바가 되고, 자리를 지키는 [Sidebar](./sidebar)는 그 아래에서 시작합니다. React 패키지에는 없는 `safeArea`는 시트를 상태 표시줄과 노치 아래까지 깔아 둔 채 그 위의 내용만 비켜 세웁니다. inset을 어떻게 나누는지는 PageLayout의 Safe area 절에 있습니다.

:::

## 예시

### brand · children · actions

세 자리입니다. `brand`는 앞쪽으로 로고나 제품 이름이 들어가고, `children`은 가운데로 대개 탐색이 들어가며, `actions`는 뒤쪽입니다. 끝에 붙여 배치되므로 버튼 여러 개를 따로 감쌀 필요가 없습니다. 아무것도 주지 않은 자리는 <Fw react="그려지지" flutter="빌드되지" /> 않습니다.

### align

가운데 자리가 어디에 놓이는지 정합니다. 기본값 `start`는 brand 바로 다음에 붙이고, `center`는 남는 공간이 아니라 바 자체의 중심선에 놓고, brand와 actions에 나머지 공간을 같은 몫으로 나눠 줍니다. `end`는 actions 쪽에 붙입니다.

<Demo src="header/align" minHeight="180">

::: fw react

<<< @/.vitepress/demos/header/align.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/header/align.dart

:::

</Demo>

### position

::: fw react

기본값 `sticky`는 바를 흐름 안에 남겨 둔 채 창 위에 붙이므로, 다른 것을 밀어낼 필요가 없습니다. `fixed`는 흐름에서 빼내며 이때 [PageLayout](./page-layout)이 그 높이만큼 자리를 비워 둡니다. `static`이면 함께 스크롤되어 사라집니다.

:::

::: fw flutter

Flutter에는 `position`이 없으므로, 바를 넘겨받은 [PageLayout](./page-layout)이 이 값을 읽습니다. 기본값 `sticky`와 `fixed`는 모두 페이지가 스크롤되는 동안 바를 위에 붙잡아 두며, 내용은 시트 아래로 지나가고 바의 자리는 비워 둡니다. `static`이면 함께 스크롤되어 사라집니다. 레이아웃 밖에서는 아무것도 바꾸지 않습니다.

:::

### variant

세 가지 무게는 다른 곳에서와 같은 뜻으로, 각각 채움과 헤어라인, 없음입니다. `color`는 바를 물들이지 않고 <Fw react="헤어라인과 focus 링에서" flutter="헤어라인에서" /> 드러납니다.

<Demo src="header/variant" minHeight="220">

::: fw react

<<< @/.vitepress/demos/header/variant.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/header/variant.dart

:::

</Demo>

### maxWidth

시트는 창을 가로지른 채, 안쪽 줄만 이 폭으로 묶어 가운데에 놓습니다. [Container](./container)와 같은 사다리이고, <Fw react="직접 쓴 길이와 breakpoint별 map도 같은 방식으로 받습니다" flutter="직접 준 폭도 받습니다" />. 그래서 header와 그 아래 Container가 모든 너비에서 같은 선에서 시작합니다.

<Demo src="header/measure">

::: fw react

<<< @/.vitepress/demos/header/measure.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/header/measure.dart

:::

</Demo>

### divider

`divider`는 아래 가장자리에 헤어라인을 그리며 기본값은 켜짐입니다.

## 접근성

::: fw react

- `<header>`를 렌더링하며, `<article>`, `<aside>`, `<main>`, `<nav>`, `<section>` 안이 아니라면 `banner` 랜드마크입니다.
- `label`은 랜드마크 목록에서 banner의 이름이 됩니다. 위 요소들 안의 header는 랜드마크가 아니므로 `label`을 주어도 이름이 붙을 곳이 없습니다.
- 가운데 자리의 탐색은 직접 `<nav>`로 감싸고, 한 페이지에 `<nav>`가 둘 이상이면 각각에 접근성 이름을 주세요.

:::

::: fw flutter

- Flutter의 semantics에는 banner 역할이 없습니다. header는 화면 낭독기가 순서대로 읽는 묶음이고, [PageLayout](./page-layout)의 `header`에 `label`이 있으면 그 이름의 region이 됩니다.
- 다른 곳의 header에서는 `label`이 아무것도 이름 붙이지 않습니다. `<main>` 안의 header가 랜드마크가 아닌 것과 같습니다.
- 가운데 자리의 탐색은 `role: SemanticsRole.navigation`을 준 `Semantics`로 직접 감싸고, 한 화면에 둘 이상이면 각각에 `label`을 주세요.

:::

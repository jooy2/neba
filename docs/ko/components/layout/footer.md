---
title: Footer
order: 3
flutter: true
---

# Footer

<p class="neba-lede">페이지 끝의 시트입니다. contentinfo 랜드마크인 실제 <code>&lt;footer&gt;</code>를 렌더링하며, 표면과 거터, 그리고 바를 화면 아래에 고정할지를 정합니다. 안에 들어가는 내용은 직접 넣습니다.</p>

<Demo src="footer/hero" minHeight="180" />

::: fw react

```tsx
import { Footer } from 'neba';

<Footer>© 2026 Neba</Footer>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaFooter(child: Text('© 2026 Neba'));
```

:::

## Props

<PropsTable name="Footer" />

::: fw react

`<footer>`의 native 속성은 그대로 전달됩니다. 다만 `color`와 `title`은 예외입니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

나누어 둔 자리가 없으므로 children은 쓴 그대로 배치됩니다.

:::

::: fw flutter

`maxWidth`는 사다리의 한 단계나 직접 준 폭인 `NebaMeasure`를 받고, breakpoint별 map은 받지 않습니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

나누어 둔 자리가 없으므로 child는 쓴 그대로, footer의 폭 전체에 배치됩니다. `safeArea`는 시트를 홈 인디케이터와 노치 아래까지 깔아 둔 채 그 위의 내용만 비켜 세웁니다. 페이지 끝의 footer는 끝까지 스크롤되면 화면 아래에 닿으므로, `position`이 `static`이어도 적용됩니다.

:::

## 예시

### position

::: fw react

기본값은 `static`이라 footer는 문서 끝에 놓이고 스크롤해서 닿습니다. `sticky`는 창 아래에 붙이고, `fixed`는 흐름에서 빼냅니다. [PageLayout](./page-layout) 안에서는 `fixed` footer의 높이만큼 자리가 비워지므로 마지막 문단 위에 겹치지 않습니다.

:::

::: fw flutter

Flutter에는 `position`이 없으므로, footer를 넘겨받은 [PageLayout](./page-layout)이 이 값을 읽습니다. 기본값 `static`이면 footer는 페이지 끝에 놓이고 스크롤해서 닿습니다. `sticky`와 `fixed`는 모두 내용이 시트 아래로 지나가는 채 화면 아래에 붙잡혀 손닿는 곳에 남고, 그 높이만큼 자리가 비워지므로 마지막 문단을 가리지 않습니다. 레이아웃 밖에서는 아무것도 바꾸지 않습니다.

:::

### variant

세 가지 무게는 다른 곳에서와 같은 뜻입니다. 시트는 `color`로 물들지 않습니다.

<Demo src="footer/variant" minHeight="220">

::: fw react

<<< @/.vitepress/demos/footer/variant.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/footer/variant.dart

:::

</Demo>

### maxWidth

시트는 창을 가로지른 채, 안쪽 내용만 이 폭으로 묶어 가운데에 놓습니다. [Container](./container)와 같은 사다리이고, <Fw react="직접 쓴 길이와 breakpoint별 map도 같은 방식으로 받습니다" flutter="직접 준 폭도 받습니다" />.

<Demo src="footer/measure">

::: fw react

<<< @/.vitepress/demos/footer/measure.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/footer/measure.dart

:::

</Demo>

### divider · padded

`divider`는 위 가장자리에 헤어라인을 그리며 기본값은 켜짐입니다. <Fw react="`padded={false}`" flutter="`padded: false`" />는 여백을 직접 다루는 footer를 위해 거터를 없앱니다.

## 접근성

::: fw react

- `<footer>`를 렌더링하며, `<article>`, `<aside>`, `<main>`, `<nav>`, `<section>` 안이 아니라면 `contentinfo` 랜드마크입니다.
- `label`은 랜드마크 목록에서 `contentinfo`의 이름이 됩니다. 위 요소들 안의 footer는 랜드마크가 아니므로 `label`을 주어도 이름이 붙을 곳이 없습니다.
- 링크 열이 잔글씨가 아니라 탐색이라면 직접 `<nav>`로 묶으세요.

:::

::: fw flutter

- [PageLayout](./page-layout)이 넘겨받은 footer는 화면 낭독기가 사이트 정보로 내놓는 `contentInfo` 영역입니다. 다른 곳의 footer는 순서대로 읽히는 묶음일 뿐 랜드마크가 아닙니다. 문서 최상위의 `<footer>`만 랜드마크인 것과 같은 규칙입니다.
- `label`은 그 영역의 이름이 됩니다. 랜드마크가 아닌 footer에서는 이름이 붙을 곳이 없습니다.
- 링크 열이 잔글씨가 아니라 탐색이라면 `role: SemanticsRole.navigation`을 준 `Semantics`로 직접 묶으세요.

:::

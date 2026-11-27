---
title: Sources
order: 6
flutter: true
---

# Sources

<p class="neba-lede">답이 무엇을 근거로 만들어졌는지를 모아 둔 목록입니다. 번호가 붙은 줄마다 링크와 인용된 대목이 들어가고, 전체는 개수를 말해 주는 제목 뒤로 접힙니다.</p>

<Demo src="sources/hero" />

::: fw react

```tsx
import { Sources } from 'neba';

<Sources
  items={[
    { title: 'The design language', site: 'neba.cdget.com', href: '/design/design-language' },
    { title: 'Breakpoints', site: 'neba.cdget.com', href: '/design/breakpoints' }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaSources(
  items: <NebaSourceItem>[
    NebaSourceItem(
      title: const Text('The design language'),
      site: const Text('neba.cdget.com'),
      onPressed: () => open('/design/design-language'),
    ),
    NebaSourceItem(
      title: const Text('Breakpoints'),
      site: const Text('neba.cdget.com'),
      onPressed: () => open('/design/breakpoints'),
    ),
  ],
);
```

:::

## Props

<PropsTable name="Sources" />

::: fw react

`<div>`의 기본 속성은 루트로 전달됩니다. 위 표에서 다르게 정의한 `color`, `title`, `onChange`만 제외됩니다.

:::

::: fw flutter

줄 하나하나는 `NebaSourceItem`입니다. `hiddenUntilFound` 자리에는 `keepMounted`가 있고, `labels`는 React 패키지가 쓰는 이름을 키로 삼는 맵입니다.

:::

줄에는 *번호*가 붙고, 그 번호가 본문의 [InlineCitation](./inline-citation)이 가리키는 대상입니다.

### SourceItem

<PropsTable name="SourceItem" />

## 예시

### collapsible

켜져 있습니다. 목록은 제목 줄 아래로 접히고, 제목 줄은 열려 있든 닫혀 있든 출처의 개수를 보여 줍니다.

끄면 제목은 그냥 한 줄이 되고 목록은 열려 있습니다. 그 상태에는 disclosure가 아예 없으므로 누를 것도 없습니다.

<Demo src="sources/folding">

::: fw react

<<< @/.vitepress/demos/sources/folding.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/sources/folding.dart

:::

</Demo>

### <Fw react="hiddenUntilFound" flutter="keepMounted" />

::: fw react

켜져 있습니다. 접힌 목록은 `hidden="until-found"`로 DOM에 남으므로 링크가 서버 렌더에 포함되고, 브라우저의 페이지 내 찾기가 줄을 찾아 목록을 펼칠 수 있습니다. `hiddenUntilFound={false}`를 주면 접힌 목록이 DOM에서 빠집니다.

:::

::: fw flutter

켜져 있습니다. 접힌 목록도 줄을 빌드된 채로 둡니다. `keepMounted: false`를 주면 접혀 있는 동안에는 내려놓습니다.

:::

### 번호

주어진 순서대로 1부터 번호를 붙입니다. 항목의 `index`가 이를 덮어씁니다. 더 긴 목록 가운데 실제로 인용된 것만 보여 주는 경우에 필요합니다.

<Fw react="numbered={false}는" flutter="numbered: false는" /> 번호를 없앱니다. 본문에서 아무것도 인용하지 않을 때 쓰세요. 가리키는 것이 없는 번호는 독자가 의미를 찾아 헤매는 번호입니다.

### 링크

::: fw react

`href`가 있는 줄은 진짜 [TextLink](../display/text-link)입니다. 밑줄도 포커스 링도 라이브러리의 다른 링크와 같습니다. `href`가 없는 줄은 평범한 텍스트입니다. 독자가 열 수 없는 파일의 한 대목도 출처입니다.

스킴이 `http`, `https`, `mailto`, `tel` 중 하나가 아닌 `href`는 그대로 쓰이는 대신 링크를 걸지 않습니다. 탭을 벗어나는 `target`에는 `rel="noopener noreferrer"`가 붙습니다.

:::

::: fw flutter

`onPressed`가 있는 줄은 진짜 [TextLink](../display/text-link)입니다. 밑줄도 포커스 링도 라이브러리의 다른 링크와 같습니다. 패키지는 스스로 아무것도 열지 않으므로 링크를 따라가는 일은 그 콜백이 합니다. `onPressed`가 없는 줄은 평범한 텍스트입니다. 독자가 열 수 없는 파일의 한 대목도 출처입니다.

`href`는 링크가 가리키는 곳을 스크린 리더와 웹의 브라우저에 알립니다. 스킴이 `http`, `https`, `mailto`, `tel` 중 하나가 아니면 링크를 걸지 않고, `newTab`은 링크가 앱을 떠난다는 것을 스크린 리더에 알립니다.

:::

### variant

기본값은 `text`이며 목록은 시트를 그리지 않습니다.

<Demo src="sources/variant">

::: fw react

<<< @/.vitepress/demos/sources/variant.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/sources/variant.dart

:::

</Demo>

## 접근성

::: fw react

- `role="list"`를 명시한 `<ol>`입니다. Tailwind의 reset이 마커를 없앤 뒤에도 Safari가 목록 의미를 유지합니다.
- 줄 옆의 번호는 `aria-hidden`입니다. 눈을 위한 이정표이고, 그 줄은 이미 번호가 매겨진 목록 안에 있습니다.
- 목록이 접힐 때 제목은 진짜 버튼이며 Base UI가 패널과 연결합니다.
- 접힌 목록은 tab 순서에도 accessibility tree에도 없습니다. `hiddenUntilFound`를 끄지 않는 한 브라우저의 페이지 내 찾기는 그 안의 줄을 찾아 목록을 펼칠 수 있습니다.

:::

::: fw flutter

- 스크린 리더에게 줄들은 목록이고, 줄 하나하나는 그 항목입니다.
- 줄 옆의 번호는 그리기만 하고 읽지 않습니다. 눈을 위한 이정표이고, 그 줄은 이미 목록 안에 있습니다.
- 목록이 접힐 때 제목은 펼쳐졌거나 접힌 버튼이며, 제목과 개수가 그 이름입니다.
- 접힌 목록은 접히기 시작하는 순간부터 focus 순서에도 semantics tree에도 없습니다.

:::

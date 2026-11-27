---
title: TextLink
order: 16
flutter: true
---

# TextLink

<p class="neba-lede">문장 안에서든 혼자서든, 링크를 텍스트로 표현합니다. 표면도 고유한 높이도 없습니다. 아래에 그어지는 선과, 새 탭이나 새 창을 여는 링크에 붙는 표식이 전부입니다.</p>

<Demo src="text-link/hero" />

::: fw react

```tsx
import { TextLink } from 'neba';

<TextLink href="/components/">컴포넌트</TextLink>
<TextLink href="https://neba.cdget.com/components/" newTab>모든 컴포넌트</TextLink>
<TextLink href="/guide/getting-started" underline="hover" color="primary">시작하기</TextLink>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaTextLink(onPressed: openComponents, child: const Text('컴포넌트'));
NebaTextLink(onPressed: openSite, newTab: true, child: const Text('모든 컴포넌트'));
NebaTextLink(
  onPressed: openGuide,
  underline: NebaTextLinkUnderline.hover,
  color: NebaColor.primary,
  child: const Text('시작하기'),
);
```

:::

## Props

<PropsTable name="TextLink" />

::: fw react

나머지 `<a>` 속성은 모두 전달됩니다. `rel`만 예외로, 덮어쓰는 대신 합쳐집니다. 아래 `newTab`을 보세요.

:::

::: fw flutter

패키지는 아무것도 직접 열지 않으므로 링크는 콜백입니다. `onPressed`에서 router나 URL launcher를 부릅니다. `href`는 링크가 가는 곳을 screen reader와, 웹에서는 브라우저에 알려 줄 뿐 직접 열지는 않습니다. `onPressed`가 없으면 링크 모양은 그대로지만 아무 일도 하지 않고 focus도 받지 않습니다. 브라우저처럼 Enter는 링크를 따라가고 Space는 그렇지 않습니다.

문장 안의 링크는 `Text.rich`의 `WidgetSpan`으로 넣고 기준선에 맞춥니다. `WidgetSpan(alignment: PlaceholderAlignment.baseline, baseline: TextBaseline.alphabetic, child: NebaTextLink(…))`처럼 씁니다. 이렇게 넣은 링크는 문장의 줄을 따라 이어지지 않고 자기 상자 안에서 줄바꿈되므로, 본문 속 링크는 짧게 쓰세요.

:::

공통 축 가운데 `color`와 `size`에는 기본값이 없습니다. 문단 안의 링크는 그 문단의 색이자 그 문단의 크기이기 때문입니다. 나머지 어휘는 [Prop 규약](../../design/prop-conventions)에 있습니다.

::: fw react

`className`에 넣은 Tailwind utility는 링크의 글자색, weight, 밑줄보다 우선합니다. 밑줄은 표시 여부, 두께, 간격, 색 모두 해당하고, variant가 붙어도 마찬가지입니다. 직접 만든 스타일시트의 class라면 class 두 개나 `!important`가 필요합니다.

루트에는 `neba-link` 클래스가 붙습니다. `a`를 태그 이름으로 스타일링하는 스타일시트(`.prose a`를 비롯한 대부분의 CSS 프레임워크)가 예외로 빼낼 수 있는 후크입니다. `.prose a:not(.neba-link) { … }`처럼 씁니다.

:::

## 예시

### underline

기본값은 `always`입니다. `hover`는 포인터가 올라갔을 때만 선을 긋고, `none`은 아예 긋지 않습니다. 포인터를 올리면 선만 바뀌고 글자 색은 그대로입니다. `none`은 링크임을 이미 다른 것이 말해 주고 있을 때(nav 바, footer, 제목 아래 나란히 놓인 줄) 씁니다.

<Demo src="text-link/underline">

::: fw react

<<< @/.vitepress/demos/text-link/underline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/underline.dart

:::

</Demo>

### color

`color`가 없으면 링크는 주위 텍스트의 색을 그대로 씁니다. 여섯 가지 역할 색 중 하나를 주면 라벨과 선이 함께 물듭니다.

<Demo src="text-link/colors">

::: fw react

<<< @/.vitepress/demos/text-link/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/colors.dart

:::

</Demo>

### size

이것도 기본값이 없고 `NebaProvider`도 채우지 않습니다. 문장 속 링크는 그 문장의 크기입니다. 혼자 서 있는 링크에는 `size`를 주면 되고, 줄바꿈이 일어나는 텍스트에 맞는 행간까지 함께 따라옵니다.

<Demo src="text-link/sizes">

::: fw react

<<< @/.vitepress/demos/text-link/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/sizes.dart

:::

</Demo>

### newTab과 icon

::: fw react

`newTab`은 `target="_blank"`와, 새 페이지가 `window.opener`로 되돌아오지 못하게 하는 `rel`을 함께 붙입니다. 동시에 `icon`을 켭니다.

`rel`을 직접 넘기면 덮어쓰는 대신 합쳐지므로, `newTab rel="nofollow"`는 `nofollow noopener noreferrer`가 됩니다. 같은 탭 링크의 `rel`은 그대로 둡니다. `target`을 직접 쓰면 `newTab`과 같은 `rel`과 읽히는 문장이 붙지만 글리프는 붙지 않습니다. 글리프가 필요하면 `icon`을 넘깁니다.

`icon`은 양쪽 모두를 덮어씁니다. 새 탭 링크에 표식을 없애려면 `false`, 같은 탭 링크에 표식을 붙이려면 `true`, 글리프 자체를 바꾸려면 노드를 넘깁니다.

:::

::: fw flutter

`newTab`은 앱 밖으로 나가는 링크라는 뜻입니다. 바깥 표식을 그리고, screen reader가 읽는 내용에 "(새 창에서 열림)"을 덧붙입니다. 실제로 탭을 여는 일은 앱이 쓰는 launcher로 `onPressed`가 맡습니다.

`showIcon`은 양쪽 모두를 덮어씁니다. 새 탭 링크에 표식을 없애려면 `false`, 같은 탭 링크에 표식을 붙이려면 `true`를 줍니다. `icon`을 넘기면 글리프가 바뀌고 표식도 켜집니다.

:::

<Demo src="text-link/external">

::: fw react

<<< @/.vitepress/demos/text-link/external.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_link/external.dart

:::

</Demo>

### locale

`newTab`은 화면에 그려지지 않고 읽히기만 하는 "(새 창에서 열림)" 문장을 덧붙입니다. `locale`은 그 문장을 어느 언어로 쓸지를 정하며, <Fw react="`ko`, `pt-BR`, `zh-Hant` 같은 BCP 47 태그를 받습니다" flutter="`Locale`을 받고 기본값은 `NebaProvider`의 값, 없으면 앱의 언어입니다" />. 번역이 없는 언어는 영어로 돌아갑니다.

::: fw react

```tsx
<TextLink href="https://neba.cdget.com/components/" newTab locale="ko">
  모든 컴포넌트
</TextLink>
```

:::

::: fw flutter

```dart
NebaTextLink(
  onPressed: openSite,
  newTab: true,
  locale: const Locale('ko'),
  child: const Text('모든 컴포넌트'),
);
```

:::

### render

::: fw react

`render`는 다른 것은 그대로 둔 채 요소만 바꿉니다. 대개는 router가 주는 `Link`입니다. TextLink의 `href`는 그 요소에 전달되고, 자기 `href`를 요구하는 타입의 `Link`에는 아래처럼 같은 값을 줍니다.

```tsx
import Link from 'next/link';

<TextLink href="/components/" render={<Link href="/components/" />}>
  컴포넌트
</TextLink>;
```

:::

::: fw flutter

Flutter 링크에는 바꿔 끼울 요소가 없습니다. router의 이동은 `onPressed`에 넣습니다.

:::

## 접근성

- 새 탭에서 열리는 링크는 그 사실을 <Fw react="accessible name에" flutter="semantics label에" /> 담습니다. 페이지의 언어로 읽히도록 `locale`을 지정하세요.
- `underline="none"`은 색만을 링크의 단서로 남깁니다. 색만으로는 모든 독자에게 전달되지 않으므로, 주변 레이아웃이 이미 링크임을 말하고 있는 자리에만 쓰세요.
- focus ring은 `color`가 없어도 그려집니다. 사라지는 대신 primary ring으로 돌아갑니다.
- scheme이 `http`, `https`, `mailto`, `tel`이 아닌 `href`는 쓰지 않으므로, 사용자 콘텐츠에서 온 `javascript:` 주소는 <Fw react="실행되지 않습니다" flutter="screen reader에도 브라우저에도 전달되지 않습니다" />. 상대 주소, `#fragment`, `//host`는 그대로 둡니다. `href`를 받는 모든 컴포넌트가 같은 규칙을 따릅니다.

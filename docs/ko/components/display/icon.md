---
title: Icon
order: 7
flutter: true
---

# Icon

<p class="neba-lede">아이콘 글리프에 라이브러리의 크기 축과 색 축을 붙여 주는 wrapper입니다. Neba는 아이콘 세트를 포함하지 않으므로, 글리프는 직접 고른 세트에서 가져옵니다.</p>

<Demo src="icon/hero" />

::: fw react

```tsx
import { Icon } from 'neba';

<Icon icon={<BoltIcon />} size="lg" color="warning" label="Fast" />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaIcon(
  icon: BoltGlyph(),
  size: NebaSize.lg,
  color: NebaColor.warning,
  semanticLabel: 'Fast',
);
```

:::

## Props

<PropsTable name="Icon" />

::: fw react

글리프는 `children`이 아니라 `icon` prop으로 넘깁니다. 세트에서 가져온 요소의 크기와 색을 Icon이 직접 지정하기 위한 것으로, `<Icon icon={<BoltIcon />} />`처럼 씁니다.

`<span>`의 native 속성은 그대로 전달됩니다.

:::

::: fw flutter

글리프는 `child`가 아니라 `icon`으로 넘기고, 크기와 색은 `IconTheme`과 `DefaultTextStyle`로 전달됩니다. 그래서 아이콘 폰트의 `Icon`, `IconTheme`을 읽는 그림, 텍스트 글리프가 모두 제대로 그려집니다. 글리프는 크기만 한 정사각형 안에 놓입니다. 문장 안에서는 `PlaceholderAlignment.middle`을 준 `WidgetSpan`으로 넣습니다.

:::

## 예시

### size

컨트롤 높이가 아니라 아이콘 전용 단계입니다: 14 · 16 · 20 · 24 · 28px. 아이콘 세트들이 실제로 그려지는 크기이므로 글리프가 픽셀 격자에 맞아떨어지고 리샘플링되지 않습니다.

<Demo src="icon/sizes">

::: fw react

<<< @/.vitepress/demos/icon/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon/sizes.dart

:::

</Demo>

### color

`color`의 기본값은 <Fw react="`inherit`입니다" flutter="생략했을 때의 주변 텍스트 색입니다" />. 라이브러리에서 기본값이 `primary`가 아닌 유일한 색 prop으로, 버튼 라벨이나 [Alert](../feedback/alert) 안처럼 이미 색이 정해진 자리에 놓았을 때 그 색을 그대로 물려받습니다. 역할 색을 쓰려면 명시적으로 지정하세요.

<Demo src="icon/colors">

::: fw react

<<< @/.vitepress/demos/icon/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/icon/colors.dart

:::

</Demo>

### <Fw react="label" flutter="semanticLabel" />

::: fw react

`label`이 없으면 아이콘은 `aria-hidden`으로 접근성 트리에서 빠집니다. 옆에 같은 뜻의 텍스트가 이미 있는 경우가 대부분이므로 이것이 기본값입니다. 글리프만으로 뜻이 전달되어야 할 때만 `label`을 주세요.

```tsx
// 옆의 텍스트가 이미 "삭제"라고 말하고 있습니다.
<Button startIcon={<Icon icon={<TrashIcon />} />}>삭제</Button>

// 글리프 외에 아무것도 없으므로 이름이 필요합니다.
<Icon icon={<TrashIcon />} label="삭제" />
```

:::

::: fw flutter

`semanticLabel`이 없으면 아이콘은 semantics 트리에서 빠집니다. 옆에 같은 뜻의 텍스트가 이미 있는 경우가 대부분이므로 이것이 기본값입니다. 글리프만으로 뜻이 전달되어야 할 때만 `semanticLabel`을 주세요. 그러면 아이콘은 그 이름을 가진 이미지가 됩니다.

```dart
// 옆의 텍스트가 이미 "삭제"라고 말하고 있습니다.
NebaButton(onPressed: delete, startIcon: const NebaIcon(icon: TrashGlyph()), child: const Text('삭제'));

// 글리프 외에 아무것도 없으므로 이름이 필요합니다.
const NebaIcon(icon: TrashGlyph(), semanticLabel: '삭제');
```

:::

글리프가 컨트롤 전체인 경우에는 [IconButton](../inputs/icon-button)을 쓰세요. 그쪽은 `label`이 필수입니다.

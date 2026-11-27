---
title: Blockquote
order: 9
flutter: true
---

# Blockquote

<p class="neba-lede">인용문을 본문과 구분해 보여 주는 컴포넌트입니다. 출처를 함께 넘기면 인용과 출처를 올바른 시맨틱 마크업으로 묶어 줍니다.</p>

<Demo src="blockquote/hero" />

::: fw react

```tsx
import { Blockquote } from 'neba';

<Blockquote>완벽함이란 더 보탤 것이 없을 때가 아니라 더 뺄 것이 없을 때 이루어진다.</Blockquote>

<Blockquote author="생텍쥐페리" source="인간의 대지">
  완벽함이란 더 보탤 것이 없을 때가 아니라 더 뺄 것이 없을 때 이루어진다.
</Blockquote>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaBlockquote(
  child: Text('완벽함이란 더 보탤 것이 없을 때가 아니라 더 뺄 것이 없을 때 이루어진다.'),
);

const NebaBlockquote(
  author: Text('생텍쥐페리'),
  source: Text('인간의 대지'),
  child: Text('완벽함이란 더 보탤 것이 없을 때가 아니라 더 뺄 것이 없을 때 이루어진다.'),
);
```

:::

## Props

<PropsTable name="Blockquote" />

::: fw react

출처가 없으면 `<div>` 안의 `<blockquote>`로 렌더링됩니다. `author`나 `source` 중 하나라도 있으면 `<figure>`로 감싸고 출처를 `<figcaption>`에 넣습니다.

```html
<figure>
  <blockquote cite="…">…</blockquote>
  <figcaption>— 저자 <cite>출처</cite></figcaption>
</figure>
```

`author`는 `<cite>` 바깥에 놓입니다. `<cite>`는 작품 제목을 위한 요소이기 때문입니다.

:::

::: fw flutter

인용문은 `child`로 넘깁니다. `cite`는 없습니다. Flutter 위젯에는 출처 문서의 주소를 기계가 읽어 갈 속성이 없기 때문입니다. 화면 낭독기는 인용문을 읽은 다음 저자와 출처를 읽고, 인용부호와 줄표는 건너뜁니다.

:::

## 예시

### variant

`text`가 기본으로, 여백에 선 하나만 두어 본문 흐름 안에 놓입니다. `outline`과 `solid`는 인용이 그 절의 중심일 때 쓰는 sheet 형태입니다.

<Demo src="blockquote/variants">

::: fw react

<<< @/.vitepress/demos/blockquote/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/blockquote/variants.dart

:::

</Demo>

### author와 source

`author`만, `source`만, 또는 둘 다 줄 수 있습니다. <Fw react="`cite`는 인용 출처 문서의 URL이며 `<blockquote>`의 `cite` 속성으로 전달됩니다. 화면에는 나타나지 않고 기계만 읽습니다." flutter="둘 다 위젯을 받으며 보통 `Text`를 넘깁니다. 저자는 본문 글자색으로, 출처는 그 뒤에 흐린 색으로 놓입니다." />

<Demo src="blockquote/attribution">

::: fw react

<<< @/.vitepress/demos/blockquote/attribution.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/blockquote/attribution.dart

:::

</Demo>

### color

인용문의 배경은 물들지 않습니다. `color`는 여백의 선과 인용부호에만 적용됩니다.

<Demo src="blockquote/colors">

::: fw react

<<< @/.vitepress/demos/blockquote/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/blockquote/colors.dart

:::

</Demo>

### icon

`icon`은 세 가지로 동작합니다. 생략하면 기본 인용부호 글리프, <Fw react="node를" flutter="위젯을" /> 넘기면 그것으로 교체, <Fw react="false" flutter="null" code />를 주면 표시하지 않습니다.

::: fw react

```tsx
<Blockquote>기본 인용부호</Blockquote>
<Blockquote icon={<QuoteIcon />}>직접 지정한 글리프</Blockquote>
<Blockquote icon={false}>글리프 없음</Blockquote>
```

:::

::: fw flutter

```dart
const NebaBlockquote(child: Text('기본 인용부호'));
const NebaBlockquote(icon: QuoteIcon(), child: Text('직접 지정한 글리프'));
const NebaBlockquote(icon: null, child: Text('글리프 없음'));
```

직접 넘긴 위젯은 글자 크기 두 배의 정사각형에 맞춰지고, 그 안의 아이콘은 인용이 정한 `IconTheme`에서 크기와 색을 받습니다.

:::

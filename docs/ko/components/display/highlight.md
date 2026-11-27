---
title: Highlight
order: 11
flutter: true
---

# Highlight

<p class="neba-lede">텍스트 안에서 검색어와 일치하는 부분에 표시를 합니다. 검색 결과 목록이나 필터링된 목록에서 무엇이 걸렸는지 보여 줄 때 씁니다.</p>

<Demo src="highlight/hero" />

::: fw react

```tsx
import { Highlight } from 'neba';

<Highlight query="acrylic">A sheet of cut acrylic.</Highlight>
<Highlight query={['data', 'database']} variant="text" color="primary">…</Highlight>
<Highlight query="Neba" caseSensitive>…</Highlight>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaHighlight(query: 'acrylic', child: Text('A sheet of cut acrylic.'));
const NebaHighlight.terms(
  query: <String>['data', 'database'],
  variant: NebaVariant.text,
  color: NebaColor.primary,
  child: Text('…'),
);
const NebaHighlight(query: 'Neba', caseSensitive: true, child: Text('…'));
```

:::

## Props

<PropsTable name="Highlight" />

::: fw react

`query`에는 검색창이 들고 있는 값을 그대로 넘기며, 문자열과 문자열 배열, 정규식을 받습니다. 일치 지점을 미리 계산할 필요는 없습니다. 상태를 갖지 않으므로 `children`과 `query`가 바뀌면 표시도 함께 갱신됩니다.

:::

::: fw flutter

`query`에는 검색창이 들고 있는 값을 그대로 넘깁니다. 무엇을 받는지는 생성자가 정합니다. `NebaHighlight`는 문자열 하나, `NebaHighlight.terms`는 문자열 목록, `NebaHighlight.pattern`은 `RegExp`를 받습니다. 일치 지점을 미리 계산할 필요는 없습니다. 상태를 갖지 않으므로 `child`와 `query`가 바뀌면 표시도 함께 갱신됩니다. 표식의 표면은 단어 뒤에 단어보다 조금 넓게 그려지므로 주변 텍스트가 밀리지 않습니다.

:::

`size`는 없습니다. 표식은 흐르는 텍스트 안에 놓이므로 주변 글자 크기를 그대로 따릅니다.

## 예시

### variant · underline · weight

`variant`는 표식의 무게입니다. `solid`는 형광펜처럼 채우고, `outline`은 단어를 얇은 선으로 두르고, `text`는 색만 바꿉니다. `underline`과 `weight`는 그 위에 겹쳐 쓰는 별개의 축입니다.

기본 `color`는 `warning`입니다. 채움이 밝고 잉크가 어두운 유일한 계열이라 `solid`에서 노란 형광펜처럼 읽힙니다. 다른 계열은 색 블록 위의 흰 글자가 됩니다.

<Demo src="highlight/variants">

::: fw react

<<< @/.vitepress/demos/highlight/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/highlight/variants.dart

:::

</Demo>

### caseSensitive와 wholeWord

`caseSensitive`는 대소문자를 구분하고, `wholeWord`는 단어 경계에서만 일치시킵니다. 여기서 단어는 글자·숫자·밑줄의 연속이므로, 띄어쓰기로 단어를 구획하지 않는 한국어나 일본어에서는 효과가 거의 없습니다. 기본값이 꺼짐인 이유입니다.

문자열 `query`는 악센트를 무시하므로 `jose`가 `José`를 표시합니다. DataTable 검색이 찾는 결과와 같습니다. <Fw react="RegExp는 쓴 그대로 일치시킵니다." flutter="라틴·그리스·키릴 문자에 해당하며, 다른 문자는 쓴 그대로 비교합니다. `RegExp`는 쓴 그대로 일치시킵니다." />

<Fw react="문자열 배열은" flutter="검색어 목록은" /> **긴 것부터** 시도합니다. `['data', 'database']`를 짧은 쪽부터 맞추면 `data`만 잡히고 `base`가 표식 밖으로 남기 때문입니다.

<Demo src="highlight/matching">

::: fw react

<<< @/.vitepress/demos/highlight/matching.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/highlight/matching.dart

:::

</Demo>

### 중첩된 요소 안의 텍스트

::: fw react

`children`은 문자열일 필요가 없습니다. React 트리를 따라 내려가면서 텍스트 노드만 표시하고 나머지 요소는 그대로 둡니다.

:::

::: fw flutter

`child`로 `Text`, `Text.rich`, `NebaTypography`를 넘길 수 있습니다. span 안까지 따라 내려가므로, 스타일이 붙은 span 안의 일치도 표시되고 그 span의 스타일과 제스처는 그대로 남습니다. 텍스트 안의 위젯은 건드리지 않습니다.

:::

<Demo src="highlight/nested">

::: fw react

<<< @/.vitepress/demos/highlight/nested.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/highlight/nested.dart

:::

</Demo>

## 접근성

::: fw react

- 표식은 실제 `<mark>` 요소로 렌더링됩니다. "읽는 사람에게 관련이 있는 부분"이라는 의미가 함께 전달되므로, 한 문단에서 너무 많은 단어를 표시하면 그 의미가 희석됩니다.
- `<mark>`는 브라우저 기본 스타일시트에서 노란 배경을 갖고 옵니다. 그래서 `variant="text"`도 `background`를 `transparent`로 명시합니다.

:::

::: fw flutter

- Flutter에는 표식에 해당하는 역할이 없어서, 화면 낭독기는 어느 단어가 표시됐는지 말하지 않고 텍스트를 그대로 읽습니다. 반드시 알아야 할 내용을 표식만으로 전달하지 마세요.

:::

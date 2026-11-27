---
title: Chip
order: 3
flutter: true
---

# Chip

<p class="neba-lede">태그, 필터, 상태처럼 짧은 값 하나를 담는 작은 토큰입니다. 누르거나 지울 수 있게 만들 수도 있습니다.</p>

<Demo src="chip/hero" />

::: fw react

```tsx
import { Chip } from 'neba';

<Chip>design-system</Chip>
<Chip color="danger" count={12}>오류</Chip>
<Chip onDelete={remove}>typescript</Chip>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaChip(child: Text('design-system'));
const NebaChip(color: NebaColor.danger, count: Text('12'), child: Text('오류'));
NebaChip(onDelete: remove, child: const Text('typescript'));
```

:::

## Props

<PropsTable name="Chip" />

::: fw flutter

라벨은 `child`이며 보통 `Text`입니다. Chip에 필요한 너비가 주어지지 않으면 말줄임표로 잘립니다. `onPressed`를 주면 라벨이 버튼이 되고, `onDelete`를 주면 라벨 뒤에 ×가 붙습니다. `href`, `target`, `rel`, `render`는 없습니다. 어딘가로 이동하는 Chip은 `onPressed`에서 라우터를 호출합니다.

:::

Chip의 `size`는 컨트롤 높이보다 한 단계 아래입니다. `md` Chip은 26px로, [Button](../inputs/button)의 `sm`과 같은 높이입니다. 콘텐츠 안에 놓이는 토큰과 행의 기준이 되는 컨트롤을 구분하기 위한 것입니다.

## 예시

### variant와 color

<Demo src="chip/variants">

::: fw react

<<< @/.vitepress/demos/chip/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/variants.dart

:::

</Demo>

### startIcon · endIcon · count

`startIcon`과 `endIcon`은 라벨 앞뒤에 놓이는 <Fw react="node" flutter="widget" />입니다.<Fw flutter=" Chip이 내려주는 `IconTheme`으로 라벨 크기의 1.2배로 그려집니다." /> `count`는 별도의 plate 위에 그려져서, "오류 12"가 두 단어가 아니라 숫자가 붙은 토큰 하나로 읽힙니다.

<Demo src="chip/content">

::: fw react

<<< @/.vitepress/demos/chip/content.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/content.dart

:::

</Demo>

### <Fw react="onClick · onDelete · selected" flutter="onPressed · onDelete · selected" />

<Fw react="`onClick`을" flutter="`onPressed`를" /> 주면 Chip 전체가 누를 수 있는 컨트롤이 됩니다. `onDelete`는 라벨 뒤에 삭제 버튼을 붙입니다. `selected`는 색 계열을 바꾸지 않고 표면을 한 단계 깊게 만들어 선택 상태를 표시합니다. 누를 수 있는 Chip은 `false`를 포함해 `selected`를 줄 때만 토글로 읽히고, <Fw react="`onClick`" flutter="`onPressed`" />만 있으면 일반 버튼입니다.

<Demo src="chip/interactive">

::: fw react

<<< @/.vitepress/demos/chip/interactive.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/interactive.dart

:::

</Demo>

### href · target · rel

::: fw react

`href`를 주면 라벨이 링크가 됩니다. 태그에서 그 태그의 페이지로, 주제에서 그 주제의 목록으로 가는 Chip에 씁니다. 크롤러가 따라갈 수 있고 사용자가 새 탭으로 열 수 있다는 점이 `onClick`을 준 Chip과 다릅니다. `target`과 `rel`은 `<a>`에 그대로 전달됩니다. 현재 탭이 아닌 `target`이면 `rel`에 `noopener noreferrer`가 더해지고, 링크의 접근성 이름 끝에 새 탭에서 열린다는 안내가 `locale`의 언어로 붙습니다. `onDelete`의 삭제 버튼은 링크 안이 아니라 옆에 놓입니다. 선택된 링크 Chip은 눌린 상태 대신 `aria-current="true"`로 표시되고, `disabled`인 Chip은 링크가 되지 않습니다.

<Demo src="chip/links">

<<< @/.vitepress/demos/chip/links.tsx

</Demo>

:::

::: fw flutter

Flutter 패키지는 스스로 아무것도 열지 않으므로 Chip에 `href`가 없습니다. 어딘가로 이동하는 Chip은 `onPressed`에서 라우터를 호출하는 누를 수 있는 Chip이고, 지금 화면의 Chip은 `selected`로 표시합니다.

:::

### render

::: fw react

`href`가 있는 Chip은 `<a>`이므로 페이지를 다시 불러옵니다. 라우터의 `Link`를 `render`로 넘기면 다시 불러오지 않고 이동합니다. Chip에도 `href`를 그대로 두세요. `Link`로 전달되고, `target`과 합쳐진 `rel`, `aria-current`도 함께 전달됩니다. `onDelete`의 삭제 버튼은 링크 옆에 놓이고, `disabled`인 Chip은 링크가 되지 않습니다.

```tsx
<Chip href="/tags/react" render={<Link to="/tags/react" />} onDelete={remove}>
  react
</Chip>
```

:::

::: fw flutter

바꿀 요소가 없습니다. 이동하는 Chip은 `onPressed`에서 라우터를 호출합니다.

:::

### size

<Demo src="chip/sizes">

::: fw react

<<< @/.vitepress/demos/chip/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chip/sizes.dart

:::

</Demo>

## 접근성

::: fw react

- 겉은 항상 `<span>`입니다. `onClick`을 주면 내용을 감싸는 `<button>`이, `href`를 주면 `<a>`가 생기고, `onDelete`를 주면 그 옆에 두 번째 `<button>`이 놓입니다. 둘은 중첩되지 않으므로 각각 키보드로 닿을 수 있습니다.
- 삭제 버튼은 Chip의 라벨이 문자열이면 "Remove Draft"처럼 그 라벨을 넣어 이름을 붙이므로, Chip이 여러 개여도 스크린 리더가 버튼을 구분할 수 있습니다. 라벨이 노드라면 `deleteLabel`로 무엇을 지우는지 밝혀 주세요.

:::

::: fw flutter

- `onPressed`를 주면 라벨이 자기 focus를 가진 버튼이 되고, `onDelete`를 주면 그 뒤에 두 번째 버튼이 놓입니다. 둘은 중첩되지 않으므로 탭, Enter, Space가 각각에 따로 닿습니다.
- ×는 옆 글자 크기로 그려지지만 누르는 영역은 Chip 높이 전체입니다.
- ×는 Chip의 라벨이 `Text`이면 "Remove Draft"처럼 그 라벨을 넣어 이름을 붙이므로, Chip이 여러 개여도 화면 낭독기가 버튼을 구분할 수 있습니다. 그렇지 않으면 `deleteLabel`로 무엇을 지우는지 밝혀 주세요.

:::

- 삭제 버튼의 접근성 이름은 `locale`이 정합니다. `deleteLabel`로 직접 쓸 수도 있습니다.

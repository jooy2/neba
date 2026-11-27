---
title: VisuallyHidden
order: 22
flutter: true
---

# VisuallyHidden

<p class="neba-lede">accessibility tree에는 있고 화면에는 없는 내용입니다. 눈에 보이는 것이 글리프나 숫자나 색뿐일 때, 컨트롤이 이름을 얻어야 하는 단어를 위한 것입니다.</p>

<Demo src="visually-hidden/hero" />

::: fw react

```tsx
import { VisuallyHidden } from 'neba';

<button type="button">
  <span aria-hidden="true">×</span>
  <VisuallyHidden>삭제</VisuallyHidden>
</button>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaButton(
  onPressed: remove,
  child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      ExcludeSemantics(child: Text('×')),
      NebaVisuallyHidden(child: Text('삭제')),
    ],
  ),
);
```

:::

## Props

<PropsTable name="VisuallyHidden" />

::: fw react

`<span>`의 native 속성은 그대로 전달되고, `render`로 element를 바꿉니다. 숨겨진 동안 내용은 clip된 1px 상자 안에 있으므로, accessibility tree에는 남고 페이지에서 자리를 차지하지 않습니다.

:::

::: fw flutter

숨겨진 동안 `child`는 크기가 없는 상자 안에서 제 크기로 배치됩니다. 자리를 차지하지 않고, 그려지지 않으며, 포인터도 받지 않지만, 동작과 함께 semantics tree에는 남습니다.

:::

## 예시

### visible

::: fw react

숨김을 걷어내어 다른 것들처럼 그립니다. skip link는 아래 예시처럼 자기 focus 상태로 `visible`을 정하므로, focus가 있는 동안에만 나타납니다. `focus-visible:` class는 element를 1px 상자 밖으로 꺼내지 못하므로 같은 일을 할 수 없습니다.

:::

::: fw flutter

숨김을 걷어내어 다른 것들처럼 그립니다. skip link는 아래 예시처럼 자기 focus 상태로 `visible`을 정하므로, focus가 있는 동안에만 나타납니다.

:::

<Demo src="visually-hidden/skip-link">

::: fw react

<<< @/.vitepress/demos/visually-hidden/skip-link.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/visually_hidden/skip_link.dart

:::

</Demo>

### render

::: fw react

`<span>` 대신 다른 것을 그립니다. 블록 내용에는 `<div>`, skip link에는 `<a>`, 제목 없이 설명만 있는 표에는 `<caption>`을 씁니다.

```tsx
<VisuallyHidden render={<caption />}>분기별 매출, 백만 원 단위</VisuallyHidden>
```

:::

::: fw flutter

바꿀 element가 없습니다. 내용이 어떤 widget이든 그것이 child입니다.

:::

## 접근성

::: fw react

- 내용은 accessibility tree의 평범한 일부입니다. accessible name에 기여하고, 문서 순서대로 읽히며, `aria-describedby`의 대상이 될 수 있습니다.
- 이름을 붙일 컨트롤의 **옆이 아니라 안에** 넣으세요. `<button>`은 자기 내용에서 이름을 가져옵니다.
- 눈에 보이는 글리프에는 맨 위 코드의 `×`처럼 `aria-hidden="true"`를 붙이세요. 그래야 숨긴 낱말 옆에서 글리프가 함께 읽히지 않습니다.
- `visible`이 참이 될 수 있는 경우가 아니라면 안에 interactive element를 넣지 마세요. 보이지 않는 focus 가능한 컨트롤은 focus가 아무 데도 가지 않는 것처럼 보입니다.

:::

::: fw flutter

- child는 semantics tree의 평범한 일부입니다. 쓴 자리에서 읽히고 동작도 그대로 유지합니다.
- 이름을 붙일 컨트롤 안에, 눈에 보이는 것 옆에 넣고, 그 글리프는 `ExcludeSemantics`로 감싸 함께 읽히지 않게 하세요.
- `visible`이 참이 될 수 있는 경우가 아니라면 안에 컨트롤을 넣지 마세요. 보이지 않는 focus는 아무 데도 가지 않는 것처럼 보입니다.

:::

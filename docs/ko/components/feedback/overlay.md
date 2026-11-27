---
title: Overlay
order: 8
flutter: true
---

# Overlay

<p class="neba-lede">페이지 전체를 덮어 조작을 막는 한 겹입니다. 저장이나 로딩처럼 사용자가 답할 것 없이 기다려야 하는 동안 씁니다.</p>

<Demo src="overlay/hero" frameMinHeight="240" />

::: fw react

```tsx
import { Overlay, ProgressCircular } from 'neba';

<Overlay open={saving} tone="blur" label="저장 중">
  <ProgressCircular size="lg" />
</Overlay>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaOverlay(
  open: saving,
  tone: NebaOverlayTone.blur,
  label: '저장 중',
  child: const NebaProgressCircular(size: NebaSize.lg),
);
```

:::

## Props

<PropsTable name="Overlay" />

::: fw react

`<div>`의 native 속성은 sheet로 전달됩니다. `color`와 `children`만 위 표와 이름이 겹쳐 제외됩니다.

:::

::: fw flutter

`color`는 없습니다. React에서는 overlay 위에 올린 것이 읽어 가는 색 슬롯을 정하지만, Flutter 위젯은 둘레의 위젯에서 색을 받지 않으므로 아무 데도 닿지 않습니다. 올려 둔 것이 자기 `color`를 받으세요. overlay는 앱의 root `Overlay`에 열립니다. navigator가 있는 `WidgetsApp`에는 이미 있고, navigator 없이 만든 앱은 home을 `Overlay.wrap`으로 감쌉니다. 쓴 자리에서 빌드되므로 그 자리의 테마와 `NebaProvider` 기본값을 그대로 쓰고, 올려 둔 것은 시스템 inset과 키보드를 피해 놓입니다.

:::

Overlay에는 표면도, 테두리도, 제목도, 액션도 없습니다. 사용자가 결정할 것이 있다면 [Dialog](./dialog)를 쓰세요.

## 예시

### tone

뒤 페이지가 얼마나 읽히는지를 정하는 네 단계입니다.

| tone | 뒤 페이지 |
| --- | --- |
| `scrim` | 읽을 수는 있고 조작만 막힙니다. [Dialog](./dialog)의 backdrop과 같은 값이라 두 컴포넌트가 겹쳐도 이음매가 보이지 않습니다. |
| `blur` | 형태와 색은 남고 글자는 읽히지 않습니다. 내용이 교체되는 중일 때 씁니다. |
| `solid` | 완전히 가립니다. 페이지 표면 색으로 불투명하게 덮습니다. |
| `clear` | 아무것도 그리지 않고 포인터만 막습니다. |

<Demo src="overlay/tones" frameMinHeight="260">

::: fw react

<<< @/.vitepress/demos/overlay/tones.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/overlay/tones.dart

:::

</Demo>

### dismissible

기본값이 꺼짐이라는 점이 [Dialog](./dialog)와 반대입니다. Overlay는 답을 요구하지 않고 기다리라고 말하는 것이므로, Esc와 scrim <Fw react="클릭이" flutter="누름이" /> 모두 거절됩니다. 무언가의 바깥 <Fw react="클릭을" flutter="누름을" /> 받아 내는 것이 목적인 Overlay라면 켜세요.

<Demo src="overlay/dismissible" frameMinHeight="300">

::: fw react

<<< @/.vitepress/demos/overlay/dismissible.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/overlay/dismissible.dart

:::

</Demo>

### modal

<Fw react="`modal={'trap-focus'}`는" flutter="`modal: NebaModal.trapFocus`는" /> 페이지 <Fw react="스크롤과 클릭을" flutter="누름을" /> 허용하면서 focus만 Overlay 안에 붙잡아 둡니다. 이때는 scrim도 포인터를 통과시키므로, 포인터를 막는 것이 전부인 `clear` tone은 아무것도 막지 못합니다.

## 접근성

::: fw react

- `role="dialog"`로 렌더링되고 `label`이 accessible name이 됩니다. 내용이 스피너뿐이거나 `clear`여도 이름은 필요하므로 `label`의 기본값은 locale의 "불러오는 중"입니다. 다른 뜻의 overlay라면 `label`을 넘기세요.
- portal, scroll lock, focus 유지, 뒤 페이지 inert 처리, 닫을 때 focus 복귀가 모두 적용됩니다.
- 등장 효과는 opacity만 사용합니다.
- overlay의 접근성 이름은 `locale`이 정합니다. `label`로 직접 쓸 수도 있습니다.

:::

::: fw flutter

- route를 가르는 dialog이고 `label`이 그 이름입니다. 내용이 스피너뿐이거나 `clear`여도 이름은 필요하므로 `label`의 기본값은 locale의 "불러오는 중"입니다. 다른 뜻의 overlay라면 `label`을 넘기세요.
- 떠 있는 동안 focus를 안에 붙잡고 닫히면 원래 자리로 돌려주며, 화면 낭독기는 overlay만 읽습니다.
- 등장 효과는 opacity만 사용합니다.
- overlay의 이름은 `locale`이 정합니다. `label`로 직접 쓸 수도 있습니다.

:::

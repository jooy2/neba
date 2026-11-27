---
title: Slider
order: 8
flutter: true
---

# Slider

<p class="neba-lede">정해진 범위 안에서 값을 끌어서 고릅니다. 정확한 숫자보다 상대적인 크기가 중요한 값에 씁니다.</p>

<Demo src="slider/hero" />

::: fw react

```tsx
import { Slider } from 'neba';

<Slider label="볼륨" defaultValue={65} showValue />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaSlider(label: const Text('볼륨'), defaultValue: 65, showValue: true);
```

:::

## Props

<PropsTable name="Slider" />

`onValueChange`는 끄는 동안 계속 호출되고, `onValueCommitted`는 값이 확정될 때 한 번만 호출됩니다. 네트워크 요청은 후자에 거세요.

::: fw flutter

`value`는 `double`이고, `onValueChange`와 함께 주면 controlled slider가 됩니다. 주지 않으면 slider가 `defaultValue`에서 시작하는 자기 값을 둡니다. Dart에는 `number | number[]`가 없으므로 범위는 따로 `NebaSlider.range` 생성자로 만들고, 이쪽은 `values`, `defaultValues`, `onValuesChange`, `onValuesCommitted`를 목록으로 받습니다. `label`과 `description`은 위젯이며 보통 `Text`를 넘깁니다.

값을 글로 쓰는 일은 `format`이 맡습니다. `showValue`가 그리는 줄과 화면 낭독기가 읽는 값 모두 이 함수로 쓰므로 `showValue`의 함수 형태와 `locale`은 없습니다. `getAriaLabel`과 `getAriaValueText`는 `thumbSemanticLabel`과 `thumbSemanticValue`이고, label이 없는 slider의 thumb 이름은 `semanticLabel`로 정합니다. Flutter slider에는 제출할 form이 없으므로 `name`도 없습니다.

:::

정확한 숫자를 입력받아야 한다면 [NumberField](./number-field)를 쓰세요.

## 예시

### <Fw react="value 배열로 범위 지정" flutter="값 목록으로 범위 지정" />

::: fw react

`value`에 숫자 배열을 주면 thumb이 그만큼 생기는 range slider가 됩니다. 별도의 prop은 없습니다.

:::

::: fw flutter

`NebaSlider.range`의 `values`에 숫자 목록을 주면 thumb이 그만큼 생기는 range slider가 됩니다. 값을 주지 않으면 `min`과 `max`에서 시작합니다.

:::

트랙을 누르면 가장 가까운 thumb이 그 자리로 옵니다. 한 thumb을 다른 thumb 너머로 끌면 그 thumb을 밀고 가고, 키로는 이웃한 thumb을 넘지 못합니다.

<Demo src="slider/range">

::: fw react

<<< @/.vitepress/demos/slider/range.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/range.dart

:::

</Demo>

### min · max · step

`step`은 thumb이 멈추는 간격입니다. `showValue`는 현재 값을 라벨 옆에 표시합니다.

::: fw flutter

focus를 가진 thumb은 방향키로 `step`만큼, Shift와 함께 누른 방향키와 Page Up, Page Down으로 `largeStep`만큼 움직입니다. Home과 End는 갈 수 있는 끝까지 보냅니다. `format`이 없으면 값은 세 자리마다 쉼표를 넣고 소수는 세 자리까지 씁니다.

:::

### marks

::: fw react

`marks`는 트랙 위의 지점에 이름을 답니다. 개수 축의 `1 / 100 / 250 / 500`, 스타일 축의 양 끝 같은 것들입니다. `{ value, label? }` 배열을 넘기고, label이 없는 mark는 눈금만 그려집니다. label은 눈금 가운데에 놓이지만 `min`과 `max`에서는 눈금에서 안쪽으로 붙어, 트랙 길이 밖으로 나가지 않습니다.

값 없이 `marks`만 주면 `step`마다 눈금이 하나씩 생깁니다. step을 직접 정한 슬라이더에 어울리는 형태입니다. 기본값인 `step={1}`을 기본 범위에 쓰면 눈금이 101개 그려지고, 100단계를 넘는 범위에서는 아무것도 그리지 않습니다.

:::

::: fw flutter

`marks`는 트랙 위의 지점에 이름을 답니다. 개수 축의 `1 / 100 / 250 / 500`, 스타일 축의 양 끝 같은 것들입니다. `NebaSliderMark(value:, label:)` 목록을 담은 `NebaSliderMarks`를 넘기고, label이 없는 mark는 눈금만 그려집니다. label은 눈금 가운데에 놓이지만 `min`과 `max`에서는 눈금에서 안쪽으로 붙어, 트랙 길이 밖으로 나가지 않습니다.

`NebaSliderMarks.steps`는 `step`마다 눈금이 하나씩 생깁니다. step을 직접 정한 슬라이더에 어울리는 형태입니다. 기본값인 `step: 1`을 기본 범위에 쓰면 눈금이 101개 그려지고, 100단계를 넘는 범위에서는 아무것도 그리지 않습니다.

:::

이 줄은 스크린 리더에서 숨겨집니다. 값과 범위는 thumb이 이미 읽어 줍니다.

<Demo src="slider/marks">

::: fw react

<<< @/.vitepress/demos/slider/marks.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/marks.dart

:::

</Demo>

### size

thumb은 트랙보다 크게 그려집니다. 실제로 손이 닿는 부분이므로 터치 대상 크기를 확보하기 위한 것입니다.

<Demo src="slider/sizes">

::: fw react

<<< @/.vitepress/demos/slider/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/sizes.dart

:::

</Demo>

### orientation

::: fw react

`vertical`은 자기 길이를 갖지 않으므로 높이를 직접 지정하세요.

:::

::: fw flutter

`vertical` slider는 아래쪽의 `min`에서 위로 올라갑니다. 받은 높이를 그대로 쓰고, 높이를 받지 못하면 160픽셀이 됩니다. 길이를 따로 정하려면 `SizedBox`로 감싸세요.

:::

<Demo src="slider/vertical">

::: fw react

<<< @/.vitepress/demos/slider/vertical.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/slider/vertical.dart

:::

</Demo>

::: fw react

### classNames

`className`은 루트(라벨과 스트립, 그 아래 한 줄을 담은 열)에 붙고, 그 안의 파트는 `classNames`로 잡습니다.

```tsx
<Slider label="Volume" classNames={{ track: 'h-1', thumb: 'rounded-sm', mark: 'font-mono' }} />
```

슬롯은 `label`, `control`, `track`, `indicator`, `thumb`, `description`, `mark`입니다. `control`은 press가 닿는 스트립 전체로, 그 안에 그려지는 `track`보다 두껍습니다.

:::

## 접근성

::: fw react

- 각 thumb이 실제 `<input type="range">`이므로 방향키, Home/End, PageUp/PageDown이 그대로 동작합니다.
- `label`이 각 thumb의 accessible name이 되고 `description`이 설명으로 붙습니다. label이 없으면 `aria-label`을 주세요. 이것도 thumb에 붙습니다.
- 범위 slider의 두 thumb은 label을 함께 씁니다. `getAriaLabel`로 이름을 나누고, `getAriaValueText`로 값을 읽는 문장을 정하세요.
- `showValue`는 `<output>`으로 렌더링되어 값이 바뀔 때 읽힙니다.
- hover와 drag에서 thumb 크기는 변하지 않고 둘레에 ring이 그려집니다.

:::

::: fw flutter

- 각 thumb은 값을 가진 slider로 읽히고, 화면 낭독기의 increase와 decrease를 한 step씩의 이동으로 받습니다. focus를 가진 thumb은 방향키, Home/End, Page Up/Page Down으로 움직입니다.
- `label`이 각 thumb의 이름이 되고 `description`은 그 뒤에 읽힙니다. label이 없으면 `semanticLabel`을 주세요.
- 범위 slider의 두 thumb은 label을 함께 쓰고, 각자 범위의 어느 쪽 끝인지 덧붙여 읽힙니다. `thumbSemanticLabel`로 이름을 나누고 `thumbSemanticValue`로 값을 읽는 문장을 정하세요. 이때 label은 따로 한 줄의 글로 읽힙니다.
- `showValue`가 그리는 줄은 읽히지 않습니다. 값은 thumb마다 이미 읽어 줍니다.
- 트랙을 눌러도 focus는 원래 있던 자리에 남습니다. thumb이 하나인 slider는 label을 누르면 focus가 thumb으로 갑니다.
- hover와 drag에서 thumb 크기는 변하지 않고 둘레에 ring이 그려집니다.

:::

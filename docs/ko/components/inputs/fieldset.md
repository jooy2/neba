---
title: Fieldset
order: 28
flutter: true
---

# Fieldset

<p class="neba-lede">하나의 질문에 함께 답하는 컨트롤 묶음이고, 그 묶음에 이름이 붙습니다. 자기 표면은 그리지 않고 컨트롤을 묶기만 합니다.</p>

<Demo src="fieldset/hero" />

::: fw react

```tsx
import { Fieldset, TextField } from 'neba';

<Fieldset legend="Billing address" description="Where the card statement goes.">
  <TextField label="Street" name="street" />
  <TextField label="City" name="city" />
</Fieldset>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaFieldset(
  legend: Text('Billing address'),
  description: Text('Where the card statement goes.'),
  children: <Widget>[
    NebaTextField(label: Text('Street')),
    NebaTextField(label: Text('City')),
  ],
);
```

:::

## Props

<PropsTable name="Fieldset" />

::: fw react

`<fieldset>`의 모든 속성이 `color`를 제외하고 그대로 전달됩니다. 브라우저 자체의 테두리·여백·마진은 지워집니다. 표면이 필요하면 [Card](../surfaces/card)나 [Box](../surfaces/box) 안에 두세요.

:::

::: fw flutter

`legend`와 `description`은 위젯이고 보통 `Text`입니다. 컨트롤은 `children`으로 받아 위아래로 늘어놓고, form 안의 field 열처럼 자기 너비만큼 늘립니다. legend 말고는 아무것도 그리지 않으니 표면이 필요하면 [Card](../surfaces/card)나 [Box](../surfaces/box) 안에 두세요. legend가 `Text`가 아닌 묶음은 `semanticLabel`로 이름을 붙입니다.

:::

## 예시

### legend · description

legend는 <Fw react="안에 있는 모든 컨트롤의" flutter="묶음의" /> 접근 가능한 이름이 됩니다. 그래서 각 컨트롤 앞에 붙여 읽어도 말이 되는 구절이어야 합니다. "Where should we send it?"이 아니라 "Billing address"입니다. `description`은 그 아래 한 줄입니다.

### disabled

::: fw react

진짜 `<fieldset>`만 할 수 있는 일입니다. 안의 모든 컨트롤에 닿습니다. 세 단계 아래의 컴포넌트가 렌더링해 이 fieldset의 존재조차 모르는 컨트롤까지 포함해서입니다. 필드 컴포넌트인 TextField, NumberField, OtpField, Select, Combobox, Checkbox, RadioGroup, Switch와 날짜·시간 picker는 그 안에서 모양도 비활성으로 그립니다.

:::

::: fw flutter

안의 모든 Neba 컨트롤에 닿습니다. 세 단계 아래의 위젯이 만들어 이 fieldset의 존재조차 모르는 컨트롤까지 포함하고, 컨트롤 자신의 `disabled`보다 우선합니다. TextField, NumberField, OtpField, Select, Combobox, DatePicker, TimePicker, DateTimePicker, DateRangePicker, TreeSelect, FilePicker, Checkbox, CheckboxGroup, RadioGroup, Switch, Slider, Rating, SegmentedButton, Toggle, ToggleGroup, [Button](./button), IconButton이 모두 그 안에서 비활성으로 그려지고 입력을 받지 않습니다. 위젯 트리에는 입력을 막아 줄 `<fieldset>`이 없으므로, 라이브러리 바깥의 위젯에는 닿지 않습니다.

:::

<Demo src="fieldset/disabled">

::: fw react

<<< @/.vitepress/demos/fieldset/disabled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/fieldset/disabled.dart

:::

</Demo>

### size

`size`는 legend의 타입 스케일이고, `spacing`이 없으면 컨트롤이 놓이는 간격도 정합니다. 컨트롤 자체에는 닿지 않습니다. `sm` field들의 묶음은 `sm` field로 직접 쓰면 됩니다.

<Demo src="fieldset/sizes">

::: fw react

<<< @/.vitepress/demos/fieldset/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/fieldset/sizes.dart

:::

</Demo>

### spacing

컨트롤 사이의 간격을 정확한 길이로 정합니다. <Fw react="Tailwind 간격 스케일이라 `6`은 `1.5rem`입니다" flutter="간격 스케일이라 `6`은 24 논리 픽셀입니다" />. legend는 `size`가 준 타입 스케일을 그대로 씁니다. [NebaProvider](../../guide/provider)의 `defaults`에 `spacing`을 주면 모든 Fieldset과 [Form](./form)에 한 번에 적용됩니다. 체크박스를 세로로 늘어놓을 때는 [CheckboxGroup](./checkbox-group)을 쓰세요. 묶음 전체가 값 하나와 자기 라벨, 오류 메시지를 갖습니다.

<Demo src="fieldset/spacing">

::: fw react

<<< @/.vitepress/demos/fieldset/spacing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/fieldset/spacing.dart

:::

</Demo>

## 접근성

::: fw react

- `role="group"`을 가진 진짜 `<fieldset>`으로 렌더링되고, `aria-labelledby`로 legend와, `aria-describedby`로 `description`과 연결됩니다.
- 스크린 리더는 안의 컨트롤마다 legend를 먼저 읽습니다. legend를 질문이 아니라 구절로 쓰는 이유입니다.

:::

::: fw flutter

- 컨트롤 전체를 감싸는 semantics 노드 하나를 만듭니다. 이름은 `Text` legend이고 설명은 `Text` description이며, 안의 컨트롤은 각자 자기 노드를 가집니다.
- 스크린 리더는 묶음에 닿을 때 legend를 읽습니다. legend를 질문이 아니라 구절로 쓰는 이유입니다.

:::

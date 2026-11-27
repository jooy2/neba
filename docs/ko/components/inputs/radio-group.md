---
title: RadioGroup
order: 6
flutter: true
---

# RadioGroup

<p class="neba-lede">여러 선택지 중 정확히 하나를 고르는 세트입니다. 선택지마다 설명이 필요하거나 모든 선택지를 펼쳐 보여야 할 때 씁니다.</p>

<Demo src="radio-group/hero" />

::: fw react

```tsx
import { Radio, RadioGroup } from 'neba';

<RadioGroup label="플랜" defaultValue="team">
  <Radio value="starter" label="Starter" />
  <Radio value="team" label="Team" />
</RadioGroup>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaRadioGroup<String>(
  label: Text('플랜'),
  defaultValue: 'team',
  children: <Widget>[
    NebaRadio<String>(value: 'starter', label: Text('Starter')),
    NebaRadio<String>(value: 'team', label: Text('Team')),
  ],
);
```

:::

## Props

### RadioGroup

<PropsTable name="RadioGroup" />

::: fw react

`value`와 `onValueChange`로 controlled, `defaultValue`로 uncontrolled 컴포넌트가 됩니다.

:::

::: fw flutter

그룹은 선택지 `value`의 타입을 제네릭으로 받고, 안의 `NebaRadio`도 같은 타입이어야 합니다. `value`와 `onValueChange`로 controlled 그룹이 되며, `value`를 `null`로 두면 그룹이 `defaultValue`에서 시작해 상태를 스스로 관리합니다. 선택지는 호출하는 쪽의 위젯 안이라도 그룹 아래라면 어디에 두어도 됩니다. Flutter 그룹에는 참여할 폼 전송이 없으므로 `name`과 `required`는 없습니다.

:::

### Radio

<PropsTable name="Radio" />

`Radio`에는 `size`도 `color`도 없습니다. 둘 다 `RadioGroup`에 지정하면 모든 선택지에 전달됩니다.

선택지가 많아 공간을 아껴야 한다면 [Select](./select), 두세 개를 한 줄에 붙여 놓아야 한다면 [SegmentedButton](./segmented-button)을 쓰세요.

## 예시

### description

선택지마다 설명을 붙일 수 있습니다. 설명이 몇 줄이 되어도 라디오 점은 라벨 첫 줄에 정렬된 채 유지됩니다.

<Demo src="radio-group/descriptions">

::: fw react

<<< @/.vitepress/demos/radio-group/descriptions.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/descriptions.dart

:::

</Demo>

### orientation

기본값은 `vertical`입니다. `horizontal`은 라벨이 짧을 때만 쓰세요. 라벨 하나가 길어지면 줄이 읽기 어려워집니다.

<Demo src="radio-group/orientation">

::: fw react

<<< @/.vitepress/demos/radio-group/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/orientation.dart

:::

</Demo>

### spacing

::: fw react

option 사이의 간격입니다. Tailwind 간격 스케일이라 `4`는 `1rem`이고, 가로 group이 줄바꿈되면 줄 사이도 같은 간격으로 벌어집니다. 주지 않으면 세로 group은 [Form](./form)의 field와 같은 단계로 `size`를 따라 `md`에서 `3`(`0.75rem`)이고, 가로 group은 같은 줄에서 `5`, 줄 사이는 세로와 같은 단계입니다. [NebaProvider](../../guide/provider)의 `defaults`에 준 `spacing`은 서로 다른 field 사이의 간격이므로 여기에는 닿지 않습니다.

:::

::: fw flutter

option 사이의 간격입니다. 간격 스케일이라 `4`는 16 논리 픽셀이고, 가로 group이 줄바꿈되면 줄 사이도 같은 간격으로 벌어집니다. 주지 않으면 세로 group은 `size`를 따라 `md`에서 12 논리 픽셀이고, 가로 group은 같은 줄에서 20, 줄 사이는 세로와 같은 단계입니다. [NebaProvider](../../guide/provider)의 `defaults`에 준 `spacing`은 서로 다른 field 사이의 간격이므로 여기에는 닿지 않습니다.

:::

<Demo src="radio-group/spacing">

::: fw react

<<< @/.vitepress/demos/radio-group/spacing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/spacing.dart

:::

</Demo>

### disabled · readOnly

그룹 전체에도, 개별 `Radio`에도 지정할 수 있습니다. 그룹에 지정하면 모든 선택지에 전달됩니다.

<Demo src="radio-group/states">

::: fw react

<<< @/.vitepress/demos/radio-group/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/radio_group/states.dart

:::

</Demo>

### classNames

::: fw react

group과 개별 option은 따로 스타일합니다. 둘은 서로 다른 컴포넌트이기 때문입니다. RadioGroup의 `classNames`는 `label`, `control`, `description`, `error`를 받고, 여기서 `control`은 option들을 담아 가로·세로 방향을 지고 있는 요소입니다. Radio의 `classNames`는 `label`, `control`, `indicator`, `description`을 받고, 여기서 `control`은 점입니다.

```tsx
<RadioGroup label="Plan" classNames={{ control: 'ps-6' }}>
  <Radio value="team" label="Team" classNames={{ control: 'rounded-sm' }} />
</RadioGroup>
```

Radio에는 `error` slot이 없습니다. 유효성 메시지는 질문에 속하고, 질문은 group이기 때문입니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

:::

::: fw flutter

class 이름은 없습니다. 라벨과 설명, 오류는 위젯이라 각자 스타일을 받고, 고리와 점은 option이 그립니다. Radio에는 `error`가 없습니다. 유효성 메시지는 질문에 속하고, 질문은 group이기 때문입니다.

:::

## 접근성

::: fw react

- 세트 전체가 tab 정지 **하나**를 차지하고, 그 안에서는 방향키로 이동합니다(roving tab index).
- `RadioGroup`의 `label`이 그룹의 accessible name이 됩니다.
- 각 `Radio`의 라벨이 컨트롤과 연결되어 있어 글자를 눌러도 선택됩니다.

:::

::: fw flutter

- 세트 전체가 focus 순서에서 **한** 자리를 차지합니다. 선택된 option이 그 자리이고, 선택된 것이 없으면 첫 option입니다. 그 안에서는 방향키로 이동하며 이동하는 대로 선택되고, 비활성 option은 건너뜁니다. 읽기 전용 그룹에서는 선택하지 않고 이동만 합니다.
- 화면 낭독기는 `Text`로 준 라벨을 이름으로 한 radio group을 듣고, 각 option을 그 안의 radio로 선택 여부와 함께 듣습니다.
- option의 라벨을 누르거나 라벨과 고리 사이의 간격을 눌러도 선택됩니다.

:::

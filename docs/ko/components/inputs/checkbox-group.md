---
title: CheckboxGroup
order: 5
flutter: true
---

# CheckboxGroup

<p class="neba-lede">한 질문에 답하는 체크박스 묶음으로, 여러 개를 함께 고를 수 있습니다. 묶음 전체를 값 하나로 다루고, 라벨로 이름을 붙이며, 모든 선택지를 한 번에 체크하는 체크박스를 둘 수 있습니다.</p>

<Demo src="checkbox-group/hero" />

::: fw react

```tsx
import { Checkbox, CheckboxGroup } from 'neba';

<CheckboxGroup label="Email me about" defaultValue={['deploys']}>
  <Checkbox value="deploys" label="Failed deploys" />
  <Checkbox value="digest" label="The weekly digest" />
</CheckboxGroup>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaCheckboxGroup(
  label: Text('Email me about'),
  defaultValue: <String>['deploys'],
  children: <Widget>[
    NebaCheckbox(value: 'deploys', label: Text('Failed deploys')),
    NebaCheckbox(value: 'digest', label: Text('The weekly digest')),
  ],
);
```

:::

## Props

<PropsTable name="CheckboxGroup" />

::: fw react

값은 체크된 체크박스들의 `value` 배열이므로, 안에 있는 모든 [Checkbox](./checkbox)에 `value`가 있어야 합니다. `value`와 `onValueChange`로 controlled, `defaultValue`로 uncontrolled 컴포넌트가 됩니다. `size`, `color`, `readOnly`는 자기 값이 없는 모든 Checkbox에, `disabled`와 invalid 상태는 모든 Checkbox에 전달됩니다. 공통 축은 [prop 규약](../../design/prop-conventions)을 보세요.

:::

::: fw flutter

값은 체크된 체크박스들의 `value` 리스트이므로, 안에 있는 모든 [Checkbox](./checkbox)에 `value`가 있어야 합니다. `value`와 `onValueChange`로 controlled 그룹이 되며, `value`를 `null`로 두면 그룹이 `defaultValue`에서 시작해 상태를 스스로 관리합니다. `size`, `color`, `readOnly`는 자기 값이 없는 모든 Checkbox에, `disabled`와 invalid 상태는 모든 Checkbox에 전달됩니다. 체크박스는 호출하는 쪽의 위젯 안이라도 그룹 아래라면 어디에 두어도 됩니다. Flutter 그룹에는 값을 실어 보낼 폼 전송이 없으므로 `name`은 없습니다. 공통 축은 [prop 규약](../../design/prop-conventions)을 보세요.

:::

답이 정확히 하나라면 [RadioGroup](./radio-group)을 쓰세요.

## 예시

### allValues · parent

`allValues`에 모든 선택지를 적으면, `parent`를 단 Checkbox가 전체를 한 번에 체크하거나 풉니다. 일부만 체크되어 있으면 중간 상태로 그려집니다<Fw react=". 폼에는 제출되지 않습니다" />.

<Demo src="checkbox-group/parent">

::: fw react

<<< @/.vitepress/demos/checkbox-group/parent.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/checkbox_group/parent.dart

:::

</Demo>

### orientation

기본값은 `vertical`입니다. `horizontal`은 라벨이 짧을 때만 쓰세요. 라벨 하나가 길어지면 줄이 읽기 어려워집니다.

<Demo src="checkbox-group/orientation">

::: fw react

<<< @/.vitepress/demos/checkbox-group/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/checkbox_group/orientation.dart

:::

</Demo>

### spacing

::: fw react

체크박스 사이의 간격입니다. Tailwind 간격 스케일이라 `4`는 `1rem`이고, 가로 group이 줄바꿈되면 줄 사이도 같은 간격으로 벌어집니다. 주지 않으면 RadioGroup과 같아서 세로는 [Form](./form)의 field와 같은 단계로 `size`를 따라 `md`에서 `3`(`0.75rem`)이고, 가로는 같은 줄에서 `5`, 줄 사이는 세로와 같은 단계입니다. [NebaProvider](../../guide/provider)의 `defaults`에 준 `spacing`은 서로 다른 field 사이의 간격이므로 여기에는 닿지 않습니다.

:::

::: fw flutter

체크박스 사이의 간격입니다. 간격 스케일이라 `4`는 16 논리 픽셀이고, 가로 group이 줄바꿈되면 줄 사이도 같은 간격으로 벌어집니다. 주지 않으면 RadioGroup과 같아서 세로는 `size`를 따라 `md`에서 12 논리 픽셀이고, 가로는 같은 줄에서 20, 줄 사이는 세로와 같은 단계입니다. [NebaProvider](../../guide/provider)의 `defaults`에 준 `spacing`은 서로 다른 field 사이의 간격이므로 여기에는 닿지 않습니다.

:::

<Demo src="checkbox-group/spacing">

::: fw react

<<< @/.vitepress/demos/checkbox-group/spacing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/checkbox_group/spacing.dart

:::

</Demo>

### disabled · readOnly · error

`disabled`와 `readOnly`는 group에도, 개별 Checkbox에도 지정할 수 있습니다. group에 지정하면 모든 선택지에 전달됩니다. `error`는 묶음 아래에 표시되고, 안의 모든 Checkbox를 `danger` 계열로 바꿉니다.

<Demo src="checkbox-group/states">

::: fw react

<<< @/.vitepress/demos/checkbox-group/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/checkbox_group/states.dart

:::

</Demo>

### name

::: fw react

체크된 값은 group의 `name`으로, 체크된 체크박스마다 하나씩 제출됩니다. [Form](./form)의 `onSubmit`은 이 값을 배열로 받고, `errors`에 같은 이름으로 넣은 오류는 묶음 아래에 표시됩니다.

```tsx
<Form onSubmit={(values) => save(values.alerts)}>
  <CheckboxGroup name="alerts" label="Email me about">
    <Checkbox value="deploys" label="Failed deploys" />
    <Checkbox value="digest" label="The weekly digest" />
  </CheckboxGroup>
</Form>
```

:::

::: fw flutter

폼 전송이 없으므로 이름도 없습니다. 그룹의 `onValueChange`가 바뀐 리스트를 그때그때 넘기고, `error`를 주면 묶음 아래에 메시지가 표시됩니다.

```dart
NebaCheckboxGroup(
  label: const Text('Email me about'),
  value: alerts,
  onValueChange: (List<String> next) => setState(() => alerts = next),
  error: alerts.isEmpty ? const Text('Choose at least one.') : null,
  children: const <Widget>[
    NebaCheckbox(value: 'deploys', label: Text('Failed deploys')),
    NebaCheckbox(value: 'digest', label: Text('The weekly digest')),
  ],
)
```

:::

## 접근성

::: fw react

- 묶음은 `label`로 이름이 붙고 `description`으로 설명되는 `role="group"`입니다.
- 각 Checkbox는 자기 라벨을 그대로 가지며, 묶음 안의 체크박스가 늘 그렇듯 각자 tab 정지를 하나씩 차지합니다.
- 부모 체크박스는 선택지 일부만 체크되어 있는 동안 `aria-checked="mixed"`를 알립니다.

:::

::: fw flutter

- 화면 낭독기는 묶음을 `Text`로 준 라벨로 부르고, `Text`로 준 설명과 오류를 그 뒤에 읽습니다.
- 각 Checkbox는 자기 라벨을 그대로 가지며, 묶음 안의 체크박스가 늘 그렇듯 focus 순서에서 각자 한 자리씩 차지합니다.
- 부모 체크박스는 선택지 일부만 체크되어 있는 동안 중간 상태로 읽힙니다.

:::

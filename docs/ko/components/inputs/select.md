---
title: Select
order: 4
flutter: true
---

# Select

<p class="neba-lede">정해진 목록에서 값 하나를 고릅니다. trigger는 TextField와 같은 shell에 chevron을 얹은 형태입니다.</p>

<Demo src="select/hero" minHeight="280" />

::: fw react

```tsx
import { Select } from 'neba';

<Select
  label="리전"
  placeholder="리전을 고르세요"
  items={[
    { value: 'icn', label: '서울' },
    { value: 'nrt', label: '도쿄' }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaSelect<String>(
  label: const Text('리전'),
  placeholder: const Text('리전을 고르세요'),
  items: const <NebaSelectOption<String>>[
    NebaSelectOption<String>(value: 'icn', label: Text('서울')),
    NebaSelectOption<String>(value: 'nrt', label: Text('도쿄')),
  ],
);
```

:::

## Props

<PropsTable name="Select" />

::: fw react

`<div>`의 native 속성은 root로 전달됩니다. 다만 `aria-label`과 `aria-labelledby`는 trigger의 이름이 됩니다. `color`와 `defaultValue`만 위 표와 이름이 겹쳐 제외됩니다.

팝업은 portal로 `<body>` 끝에 렌더링되므로, CSS reset을 특정 subtree에만 적용한 앱에서는 그 범위를 벗어납니다. positioner에 `neba-portal` 클래스가 붙어 있으니 그 경우 reset을 이 클래스에 걸어 주세요. Tailwind Preflight를 전역으로 적용했다면 아무것도 하지 않아도 됩니다.

:::

::: fw flutter

`NebaSelect`는 값의 타입에 대해 generic이고, `label`과 `placeholder`, `description`, `error`는 위젯이며 보통 `Text`를 넘깁니다. `value`를 `null`로 두면 select가 상태를 스스로 관리하므로, controlled select는 들고 있는 값을 넘기고 `onValueChange`에서 다시 설정합니다. `onValueChange`는 고른 값을 넘기며 `null`을 넘기는 일은 없습니다. 라벨이 없는 select의 이름은 `aria-label`처럼 `semanticLabel`로 붙입니다.

`name`, `autoComplete`, `required`, `classNames`는 없습니다. Flutter에는 select의 값을 제출하는 폼이 없고, 각 부분은 공통 prop으로 스타일을 정합니다. 목록은 [Popover](../surfaces/popover)처럼 앱의 root `Overlay`에 그려집니다.

:::

선택지를 검색해서 찾아야 한다면 [Combobox](./combobox)를, 선택지가 두세 개뿐이라면 [RadioGroup](./radio-group)이나 [SegmentedButton](./segmented-button)을 쓰세요.

### items

선택지는 컴포넌트를 조합하는 대신 <Fw react="배열로" flutter="리스트로" /> 넘깁니다.

::: fw react

```ts
interface SelectOption {
  value: string | number;
  label?: React.ReactNode; // 생략하면 value 자체
  disabled?: boolean;
  group?: string;
}
```

`value`는 문자열이나 숫자입니다. 폼과 함께 제출되는 값이므로 객체는 받지 않습니다. 식별자만 넘기고 객체는 호출부에서 찾으세요.

:::

::: fw flutter

```dart
const NebaSelectOption<String>(
  value: 'icn',
  label: Text('서울'), // 생략하면 value의 글
  disabled: false,
  group: 'Asia',
);
```

`value`는 어떤 `T`든 되며 `==`로 비교합니다. select의 너비와 목록, typeahead는 `label`을 읽습니다. `Text`인 label은 typeahead가 맞춰 보는 글이자 화면 낭독기가 읽는 글이기도 하고, 다른 위젯이면 value의 글로 맞추고 읽습니다.

:::

## 예시

### variant

[TextField](./text-field)와 같은 세 가지 무게를 같은 shell 위에 그립니다. 한 폼 안에서 필드와 select의 높이와 테두리가 어긋나지 않습니다.

<Demo src="select/variants" minHeight="220">

::: fw react

<<< @/.vitepress/demos/select/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/variants.dart

:::

</Demo>

### size

<Demo src="select/sizes" minHeight="240">

::: fw react

<<< @/.vitepress/demos/select/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/sizes.dart

:::

</Demo>

### labelPlacement

`notch`는 trigger 위쪽 테두리를 끊어 낸 틈에 라벨을 올립니다. `float`는 placeholder 자리에 라벨을 두었다가, 무언가를 고르거나 trigger에 포커스가 가거나 목록이 열리면 노치로 올립니다. `startIcon`이 있으면 `float` 라벨도 노치에 머뭅니다. 모든 필드에 공통인 내용은 [TextField](./text-field#labelplacement)에 있습니다.

<Demo src="select/label-placement" minHeight="230">

::: fw react

<<< @/.vitepress/demos/select/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/label_placement.dart

:::

</Demo>

### group

`group`은 같은 이름을 가진 이웃한 옵션들 위에 제목을 답니다. 지역별 시간대, 계열별 글꼴처럼 묶이는 목록에 씁니다. 제목은 하이라이트되지도, 선택되지도, typeahead로 닿지도 않습니다.

group은 **이웃한 옵션들의 묶음**이라 <Fw react="배열" flutter="리스트" /> 순서가 곧 목록 순서입니다. 라이브러리가 항목을 옮기는 일은 없습니다. 같은 이름이 떨어져서 두 번 나오면 제목도 두 번 붙습니다. `group`이 없는 옵션은 <Fw react="배열에" flutter="리스트에" /> 있는 자리에 그대로 놓입니다.

<Demo src="select/groups" minHeight="380">

::: fw react

<<< @/.vitepress/demos/select/groups.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/groups.dart

:::

</Demo>

### disabled · readOnly · error

<Demo src="select/states">

::: fw react

<<< @/.vitepress/demos/select/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/select/states.dart

:::

</Demo>

::: fw react

### autoComplete

`autoComplete`는 이 Select에 무엇이 들어가는지 브라우저에 알려, 주소 폼의 다른 칸과 함께 autofill로 채워지게 합니다. 값을 제출하는 숨은 input에 붙고, 채워진 값이 옵션의 `value`나 label과 같으면 그 옵션이 선택됩니다.

```tsx
<Select label="Country" name="country" autoComplete="country" items={countries} />
```

### classNames

`className`은 루트(라벨과 trigger, 그 아래 두 줄을 담는 열)에 붙고, trigger 자체는 `classNames.control`로 갑니다.

```tsx
<Select
  items={plans}
  label="Plan"
  classNames={{ control: 'font-mono', popup: 'max-h-40', item: 'rounded-none' }}
/>
```

slot은 `label`, `control`, `description`, `error`, `popup`, `item`입니다. `popup`과 `item`은 `<body>` 끝에 그려지므로 루트를 기준으로 쓴 하위 선택자로는 닿지 않고, 이 두 slot이 유일한 경로입니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

:::

## 접근성

::: fw react

- trigger는 `combobox` role을 갖고, `label`이 accessible name이 됩니다.
- 팝업 위치 계산과 화면 경계에서의 뒤집힘, focus 처리, typeahead, 폼 제출용 hidden input이 모두 처리됩니다.
- `disabled` 선택지는 목록에 남은 채 `aria-disabled`로 보고됩니다.

:::

::: fw flutter

- trigger는 화면 낭독기에게 노드 하나입니다. `Text` 라벨이 이름인 버튼이며, 고른 옵션의 글을 값으로 읽고 펼쳐졌는지 접혔는지를 알립니다. `Text`인 설명과 오류는 이름 뒤에 읽힙니다.
- 누르거나 화살표 키, Enter, Space를 쓰면 고른 옵션에서 목록이 열리고 focus가 목록으로 들어갑니다. 목록에서는 화살표 키와 Home, End가 하이라이트를 옮기는데, disabled 옵션은 건너뛰고 끝에서는 반대쪽 끝으로 돌아갑니다. 옵션의 첫 글자를 치면 그 옵션으로 가고, Enter나 Space, 누르기로 고릅니다. 닫힌 trigger에서 글자를 치면 거기 닿은 옵션이 바로 선택됩니다.
- Escape, Tab, 바깥을 누르기, 고르기는 목록을 닫고 focus를 trigger로 돌려줍니다. Tab은 거기서 다음으로 넘어갑니다.
- 각 옵션은 선택됐는지를 알리고, `disabled` 옵션은 목록에 남은 채 사용할 수 없다고 읽힙니다.
- trigger의 focus ring은 버튼처럼 키보드 focus에만 보입니다. 가장자리는 어떤 focus에도 반응합니다.

:::

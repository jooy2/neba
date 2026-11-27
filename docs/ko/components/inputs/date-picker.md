---
title: DatePicker
order: 15
flutter: true
---

# DatePicker

<p class="neba-lede">달력 팝업에서 날짜 하나를 고릅니다. 월 이름과 연도가 각각 자기 그리드를 여는 버튼이므로 먼 과거나 미래에도 몇 번의 클릭으로 닿습니다. <code>granularity</code>를 주면 날짜 대신 한 달이나 한 해를 묻습니다.</p>

<Demo src="date-picker/hero" minHeight="420" />

::: fw react

```tsx
import { DatePicker } from 'neba';

<DatePicker label="출고일" placeholder="날짜를 고르세요" clearable />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaDatePicker(
  label: const Text('출고일'),
  placeholder: const Text('날짜를 고르세요'),
  clearable: true,
);
```

:::

## Props

<PropsTable name="DatePicker" />

::: fw react

`<div>`의 native 속성은 root로 전달됩니다. `color` · `defaultValue` · `children`만 위 표와 이름이 겹쳐 제외됩니다.

`value`의 타입은 `Date | null`입니다. 모든 비교는 UTC 타임스탬프가 아니라 **로컬 달력의 날**을 기준으로 합니다. 폼이 제출하는 hidden input도 로컬 기준 문자열(날짜라면 `YYYY-MM-DD`)이므로, `toISOString()`으로 하루가 밀리는 문제가 생기지 않습니다. `disabled`인 picker는 아무것도 제출하지 않고, 비어 있는 `required` picker는 브라우저의 검증으로 폼 제출을 막고 트리거로 focus를 옮깁니다. 모든 picker가 같습니다.

팝업은 `<body>` 끝으로 portal되며 positioner에 `neba-portal` 클래스가 붙습니다.

:::

::: fw flutter

`value`의 타입은 `DateTime?`이고 **로컬 달력의 날**로 비교하며, 날을 고르면 값에 있던 시각은 그대로 남습니다. `null`로 두면 picker가 `defaultValue`에서 시작해 상태를 스스로 관리하고, 날을 갖고 있던 `value`가 `null`이 되면 비워집니다. `label`, `placeholder`, `description`, `error`는 위젯이며 보통 `Text`입니다. 라벨이 없는 picker의 이름은 `aria-label`처럼 `semanticLabel`로 줍니다.

`format`은 React처럼 `Intl` 옵션을 받지 않고, `DateTime`을 트리거에 보일 문자열로 바꾸는 함수를 받습니다. 기본값은 [Calendar](./calendar)가 날을 이름 붙이는 것과 같은 locale의 `NebaDateNames`로 날짜를 씁니다. `showStartIcon: false`는 React의 `startIcon={false}`입니다. `name`, `required`, `classNames`는 없습니다. Flutter에서는 picker를 대신 제출해 주는 폼이 없고, 각 부분은 공통 prop으로 꾸미기 때문입니다. 팝업은 [Popover](../surfaces/popover)처럼 앱의 루트 `Overlay`에 그려지며 필드의 가장자리에 맞춰 놓입니다.

:::

## 예시

### variant

[TextField](./text-field)와 같은 세 가지 무게를 같은 shell 위에 그립니다.

<Demo src="date-picker/variants" minHeight="420">

::: fw react

<<< @/.vitepress/demos/date-picker/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/variants.dart

:::

</Demo>

### size

달력의 한 칸이 컨트롤 높이 단계를 씁니다. `md`에서 32px로, 같은 `size`의 [Button](./button)이나 [TextField](./text-field)와 같습니다.

<Demo src="date-picker/sizes" minHeight="560">

::: fw react

<<< @/.vitepress/demos/date-picker/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/sizes.dart

:::

</Demo>

### labelPlacement

`notch`와 `float`는 [TextField](./text-field#labelplacement)와 같게 동작합니다. trigger 앞의 달력 아이콘이 `float` 라벨이 내려앉을 자리를 차지하므로, <Fw react="startIcon={false}" flutter="showStartIcon: false" code />를 넘기지 않으면 라벨은 노치에 머뭅니다. popup이 열려 있는 동안에도 노치에 있습니다.

<Demo src="date-picker/label-placement" minHeight="420">

::: fw react

<<< @/.vitepress/demos/date-picker/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/label_placement.dart

:::

</Demo>

### 세 가지 뷰

헤더의 월 이름은 12개월 그리드를, 연도는 12년 그리드를 엽니다. 연도 그리드에서는 stepper가 한 페이지씩 움직입니다. 연도를 고르면 월 뷰로 넘어가고, 두 버튼의 순서는 locale을 따르므로 한국어에서는 `2026년 7월`로 표시됩니다. 세 뷰의 너비와 높이가 같아서 뷰를 바꿔도 팝업 크기가 변하지 않습니다.

### granularity

`granularity`는 세 그리드 중 어디에서 멈출 수 있는지를 정합니다. `month`와 `year`에서는 달력이 그 그리드에서 열리고 거기서 누른 칸이 곧 답입니다. 내려갈 day 뷰 자체가 없습니다.

::: fw react

값은 그대로 `Date`이고, 고른 단위의 첫날로 정규화됩니다. 3월이면 3월 1일, 2026년이면 1월 1일입니다. 트리거의 기본 `format`은 `{ year: 'numeric', month: 'long' }`이나 `{ year: 'numeric' }`이 되고, 푸터의 단축 버튼은 "This month"나 "This year"가 되며, `name`은 `YYYY-MM`이나 `YYYY`로 제출합니다.

:::

::: fw flutter

값은 그대로 `DateTime`이고, 고른 단위의 첫날로 정규화됩니다. 3월이면 3월 1일, 2026년이면 1월 1일입니다. 트리거의 기본 `format`은 연월이나 연도만 쓰고, 푸터의 단축 버튼은 "This month"나 "This year"가 됩니다.

:::

위로 올라가는 길은 그대로이므로, month picker에서도 어느 해 어느 달이든 두 번만 누르면 닿습니다.

<Demo src="date-picker/granularity" minHeight="440">

::: fw react

<<< @/.vitepress/demos/date-picker/granularity.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/granularity.dart

:::

</Demo>

### minDate · maxDate · shouldDisableDate

`minDate`와 `maxDate`는 `granularity` 단위로, 한 칸이 대표하는 기간 전체와 비교합니다. `day`에서는 27일 09:00이 최댓값이어도 27일을 고를 수 있고, `month`에서는 3월 15일이 최솟값이어도 3월이 남습니다. 3월의 일부가 허용되기 때문입니다. 범위 안에 있지만 고를 수 없는 칸은 `shouldDisableDate`로 막습니다. 인자로는 그 칸이 만들 값이 들어오므로 `month`에서는 1일을 받습니다.

::: fw react

막힌 칸은 그리드에 남아 있고 `disabled` 속성 대신 `aria-disabled`로 표시됩니다. 방향키 이동 경로에서 빠지지 않게 하기 위한 것입니다.

:::

::: fw flutter

막힌 칸은 그리드에 남고, 사용할 수 없다고 읽히면서도 focus node를 그대로 가지므로 방향키 이동 경로에서 빠지지 않습니다.

:::

<Demo src="date-picker/bounds" minHeight="440">

::: fw react

<<< @/.vitepress/demos/date-picker/bounds.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/bounds.dart

:::

</Demo>

### disabled · readOnly · error

<Demo src="date-picker/states" minHeight="440">

::: fw react

<<< @/.vitepress/demos/date-picker/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_picker/states.dart

:::

</Demo>

### showTodayButton과 clearable

`showTodayButton`은 팝업 푸터에 지금 단위로 이동하는 버튼을 붙입니다. `granularity`에 따라 오늘, 이번 달, 올해입니다. `clearable`은 trigger에 값을 비우는 버튼을 붙이고, 푸터의 단축 버튼 옆에 Clear 버튼도 붙입니다.

## 접근성

::: fw react

- trigger는 텍스트 입력이 아니라 버튼이며, 날짜는 달력에서 고릅니다. `Space`나 `Enter`는 달력을 열고 선택된 칸에 focus를 두며, `Escape`는 고르지 않고 닫습니다.
- 그리드 전체가 tab 정지 하나이므로 `Tab`은 42개 칸을 지나지 않고 그리드를 빠져나갑니다.
- 방향키는 하루 또는 한 주씩 이동하고, 가장자리에서는 달을 넘깁니다. `Home`과 `End`는 주의 처음과 끝으로 이동합니다. `PageUp`과 `PageDown`은 한 달씩, `Shift`와 함께 누르면 1년씩 이동합니다.
- 그리드는 `role="grid"`, 각 칸은 `role="gridcell"` 버튼입니다. 칸의 이름은 숫자가 아니라 완전한 날짜입니다.
- 선택된 칸은 `aria-selected`, 지금에 해당하는 날·달·해는 `aria-current="date"`와 숫자 아래의 점으로 표시됩니다.
- 그리드의 이름은 화면에 있는 달이며, 이 이름은 polite live region에 있어 stepper나 방향키로 달이 바뀌면 새 달을 다시 알립니다. 월·연도 버튼의 이름은 버튼에 보이는 달과 해이고, 누르면 무엇을 하는지는 설명으로 붙습니다.
- trigger의 accessible name은 `label` 뒤에 trigger에 보이는 내용을 이은 것이라, 무엇을 고르는 필드인지와 함께 고른 날짜가 읽힙니다. `description`과 `error`는 `aria-describedby`로 연결됩니다.

:::

::: fw flutter

- 화면 낭독기에게 trigger는 노드 하나입니다. `Text` 라벨을 이름으로 가진 버튼이며, 보이는 날짜를 값으로 말하고 접힘과 펼쳐짐으로 읽힙니다. `Text`로 준 설명과 오류는 이름 뒤에 읽힙니다.
- trigger는 텍스트 입력이 아니라 버튼이며, 날짜는 달력에서 고릅니다. 누르거나 `Space`나 `Enter`를 누르면 달력이 열리고 선택된 칸에 focus가 갑니다. `Escape`, 바깥을 누르기, 고르기는 달력을 닫고 focus를 trigger로 돌려줍니다.
- 그리드 전체가 tab 정지 하나이므로 `Tab`은 42개 칸을 지나지 않고 그리드를 빠져나가며, focus가 팝업을 떠나면 팝업이 닫힙니다.
- 방향키는 하루 또는 한 주씩 이동하고, 가장자리에서는 달을 넘깁니다. `Home`과 `End`는 주의 처음과 끝으로 이동합니다. `Page Up`과 `Page Down`은 한 달씩, `Shift`와 함께 누르면 1년씩 이동합니다.
- 그리드는 칸으로 이뤄진 표이고, 칸마다 숫자가 아니라 완전한 날짜를 이름으로 가진 버튼이 있습니다. 선택된 칸은 선택됨으로 읽히고, 지금에 해당하는 날·달·해는 그 말이 함께 읽히며 숫자 아래에 점이 붙습니다.
- 그리드의 이름은 화면에 있는 달이며, stepper나 방향키로 달이 바뀌면 live region이 새 달을 다시 알립니다. 월·연도 버튼의 이름은 버튼에 보이는 달과 해이고, 누르면 무엇을 하는지는 설명으로 붙습니다.
- trigger의 focus ring은 버튼처럼 키보드 focus에서만 보입니다. 가장자리는 어떤 focus에도 반응합니다.

:::

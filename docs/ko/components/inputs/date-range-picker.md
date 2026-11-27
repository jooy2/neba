---
title: DateRangePicker
order: 18
flutter: true
---

# DateRangePicker

<p class="neba-lede">시작일과 종료일로 이루어진 기간을 고릅니다. 달력이 두 개 나란히 놓이고, 두 번째 클릭 전에도 포인터를 따라 구간이 미리 표시됩니다.</p>

<Demo src="date-range-picker/hero" minHeight="440" />

::: fw react

```tsx
import { DateRangePicker } from 'neba';

<DateRangePicker label="숙박" startPlaceholder="체크인" endPlaceholder="체크아웃" clearable />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaDateRangePicker(
  label: const Text('숙박'),
  startPlaceholder: const Text('체크인'),
  endPlaceholder: const Text('체크아웃'),
  clearable: true,
);
```

:::

## Props

<PropsTable name="DateRangePicker" />

::: fw react

`<div>`의 native 속성은 root로 전달됩니다. `color` · `defaultValue` · `children`만 위 표와 이름이 겹쳐 제외됩니다.

값은 튜플이 아니라 객체 하나입니다.

```ts
interface DateRange {
  start: Date | null;
  end: Date | null;
}
```

`onValueChange`는 항상 객체로 호출됩니다. 비워진 범위는 `{ start: null, end: null }`이므로 두 종류의 "비어 있음"을 검사할 필요가 없습니다.

:::

::: fw flutter

값은 두 값이 아니라 `NebaDateRange` 하나이며, `NebaCalendar.range`의 값과 같은 타입입니다. 그래서 인라인 달력에서 고른 기간과 여기서 고른 기간을 한 변수에 담을 수 있습니다.

```dart
const NebaDateRange({DateTime? start, DateTime? end});
```

`onValueChange`는 항상 `NebaDateRange`로 호출됩니다. 비워진 범위는 두 끝이 모두 `null`인 `NebaDateRange()`이므로 두 종류의 "비어 있음"을 검사할 필요가 없습니다. `value`를 `null`로 두면 picker가 `defaultValue`에서 시작해 상태를 스스로 관리합니다. `format`은 `DateTime`을 트리거의 각 끝에 보일 문자열로 바꾸는 함수이고, `startPlaceholder`와 `endPlaceholder`는 위젯이며 보통 `Text`입니다. `showStartIcon: false`는 React의 `startIcon={false}`입니다. [DatePicker](./date-picker)처럼 `name`, `required`, `classNames`는 없습니다.

:::

값은 두 번째 끝을 고를 때 한 번 바뀝니다. 첫 <Fw react="클릭은" flutter="번째로 누른 날은" /> 범위가 시작될 곳만 표시하고, 두 번째 <Fw react="클릭" flutter="날을 누르기" /> 전에 팝업을 닫으면 원래 있던 범위가 그대로 남습니다. 두 번째 <Fw react="클릭이" flutter="날이" /> 첫 번째보다 앞선 날짜라면 `range` 모드의 [Calendar](./calendar)처럼 그 날짜에서 새 범위를 시작합니다.

나머지 prop(`minDate` · `maxDate` · `shouldDisableDate` · `variant` · `size`)은 [DatePicker](./date-picker)와 동일하게 동작합니다.

## 예시

### monthCount

기본값은 `2`입니다. 두 패널은 반으로 나뉜 하나의 달력이므로, 왼쪽에는 앞으로 가는 stepper가 없고 오른쪽에는 뒤로 가는 stepper가 없으며, 어느 쪽 헤더를 조작해도 두 패널이 함께 움직입니다.

패널이 둘일 때는 인접한 달의 앞뒤 날짜를 그리지 않습니다. 같은 날짜가 두 패널에 중복으로 나타나지 않게 하기 위한 것입니다.

<Demo src="date-range-picker/one-month" minHeight="440">

::: fw react

<<< @/.vitepress/demos/date-range-picker/one-month.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_range_picker/one_month.dart

:::

</Demo>

### presets

자주 쓰는 기간을 팝업 옆에 버튼으로 놓습니다.

::: fw react

프리셋의 `value`는 범위 객체이거나 범위를 반환하는 함수입니다. 함수 쪽을 쓰세요. 렌더 시점에 한 번 계산된 범위는 탭을 오래 열어 둔 사용자에게 틀린 값이 됩니다.

:::

::: fw flutter

`NebaDateRangePreset`은 고정된 `value`를 받고, `NebaDateRangePreset.computed`는 프리셋을 누를 때 범위를 계산하는 함수를 받습니다. 뒤쪽을 쓰세요. 화면을 빌드할 때 한 번 계산된 범위는 화면을 오래 열어 둔 사용자에게 틀린 값이 됩니다.

:::

<Demo src="date-range-picker/presets" minHeight="440">

::: fw react

<<< @/.vitepress/demos/date-range-picker/presets.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_range_picker/presets.dart

:::

</Demo>

### labelPlacement

`notch`와 `float`는 [TextField](./text-field#labelplacement)와 같게 동작합니다. 내려앉은 `float` 라벨은 두 placeholder를 함께 대신하다가, 한쪽 끝이라도 고르거나 trigger에 포커스가 가거나 popup이 열리면 노치로 올라갑니다. 달력 아이콘이 있으면 노치에 머물므로, 내려앉게 하려면 <Fw react="startIcon={false}" flutter="showStartIcon: false" code />를 넘깁니다.

<Demo src="date-range-picker/label-placement" minHeight="440">

::: fw react

<<< @/.vitepress/demos/date-range-picker/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/date_range_picker/label_placement.dart

:::

</Demo>

::: fw react

### name

`name`을 주면 같은 이름의 input 두 개가 그려지므로 두 끝이 함께 제출되고 `FormData.getAll(name)`으로 받습니다. [Form](./form) 안에서는 `onSubmit`이 `name` 아래에 두 항목짜리 배열로 받고, `required`인 범위가 비어 있으면 제출을 막으며, Form에 `name`으로 넘긴 오류가 필드 아래에 나옵니다.

```ts
const form = new FormData(event.currentTarget);
const [start, end] = form.getAll('stay'); // '2026-07-03', '2026-07-09'
```

두 값 모두 로컬 기준 `YYYY-MM-DD`이며, native `<input type="date">`가 제출하는 형식과 같습니다.

:::

## 접근성

::: fw react

- 각 패널은 `role="grid"`이고 자기 tab 정지를 가지므로, `Tab`은 84개 칸을 지나지 않고 두 그리드 사이를 이동합니다.
- 두 끝에만 `aria-selected`가 붙습니다. 사이의 날짜는 구간 표시만 받습니다.
- 팝업 푸터가 다음 클릭이 어느 끝을 채울지 알려 줍니다.

:::

::: fw flutter

- 화면 낭독기에게 트리거는 노드 하나입니다. `Text` 라벨로 이름 붙은 버튼이며, 두 끝을 값으로 말하고 접혔는지 펼쳐졌는지가 함께 읽힙니다.
- 각 패널은 이름 붙은 칸으로 이루어진 표이고 자기 tab 정지를 가지므로, `Tab`은 84개 칸을 지나지 않고 두 그리드 사이를 이동합니다.
- 두 끝만 선택됨으로 읽힙니다. 사이의 날짜는 구간 표시만 받습니다.
- 팝업 푸터가 다음에 누를 날이 어느 끝을 채울지 알려 줍니다.

:::

---
title: Calendar
order: 16
flutter: true
---

# Calendar

<p class="neba-lede">한 달을 페이지 안에 그리고, 지금 담고 있는 날들을 켜 둡니다. 네 개의 picker가 여는 것과 같은 그리드에서 팝업만 걷어낸 것으로, 날짜가 항상 보여야 하는 화면을 위한 것입니다.</p>

<Demo src="calendar/hero" align="center" />

::: fw react

```tsx
import { Calendar } from 'neba';

<Calendar value={day} onValueChange={setDay} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaCalendar(
  value: day,
  onValueChange: (DateTime? next) => setState(() => day = next),
);
```

:::

## Props

<PropsTable name="Calendar" />

::: fw react

`<div>`의 native 속성은 root로 전달됩니다. 공통 축은 [prop 규약](../../design/prop-conventions)에 설명돼 있습니다.

:::

::: fw flutter

`mode`는 생성자로 정합니다. `NebaCalendar`는 하루, `NebaCalendar.multiple`은 날들의 리스트, `NebaCalendar.range`는 구간을 담고, 저마다 자기 타입으로 `value`, `defaultValue`, `onValueChange`를 받습니다. `value`를 `null`로 두면 calendar가 상태를 스스로 관리하고, 날을 갖고 있던 `value`가 `null`이 되면 비워집니다. 날짜는 모두 로컬 `DateTime`이며 연·월·일로만 비교합니다. `weekStartsOn`은 `DateTime.weekday`처럼 셉니다. `DateTime.monday`가 `1`, `DateTime.sunday`가 `7`이고, React는 일요일을 `0`으로 셉니다.

월과 요일 이름은 `Intl`이 아니라 `NebaDateNames`에서 옵니다. Flutter의 widgets 레이어에는 날짜 이름이 없고(`WidgetsLocalizations`에는 텍스트 방향과 편집 라벨 몇 개뿐입니다) 이 패키지는 `intl`에 의존하지 않으므로, 영어는 내장돼 있고 다른 언어는 위젯이 스스로 쓰는 문자열처럼 태그로 한 번 등록합니다. 이 패턴이 칸을 어떻게 읽을지와 헤더의 두 버튼 순서도 정합니다. 주의 첫 요일은 등록하지 않아도 locale의 지역을 따르며, CLDR의 주 데이터에서 옵니다.

```dart
registerNebaDateNames(
  'ko',
  const NebaDateNames(
    months: <String>['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
    shortMonths: <String>['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
    weekdays: <String>['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'],
    shortWeekdays: <String>['월', '화', '수', '목', '금', '토', '일'],
    monthYear: '{year}년 {month}',
    fullDate: '{year}년 {month} {day}일 {weekday}',
    mediumDate: '{year}. {monthNumber}. {day}.',
  ),
);
```

:::

날짜가 필드 뒤에 있어야 한다면 [DatePicker](./date-picker)를 쓰세요.

## 예시

### mode

`mode`가 값이 무엇인지를 정합니다.

::: fw react

| `mode`           | `value`                                      |
| ---------------- | -------------------------------------------- |
| `single`(기본값) | `Date \| null`                               |
| `multiple`       | `Date[]`                                     |
| `range`          | `{ start: Date \| null, end: Date \| null }` |

:::

::: fw flutter

| 생성자                  | `value`                                               |
| ----------------------- | ----------------------------------------------------- |
| `NebaCalendar`          | `DateTime?`                                           |
| `NebaCalendar.multiple` | `List<DateTime>`                                      |
| `NebaCalendar.range`    | `NebaCalendarRange(start: DateTime?, end: DateTime?)` |

:::

`multiple`에서는 이미 담긴 날을 다시 누르면 빠집니다.

`range`에서는 처음 누른 날이 시작을, 두 번째가 끝을 정합니다. 시작보다 **앞을** 누르면 기존 구간을 뒤집는 대신 새 구간을 시작합니다. 구간이 완성된 뒤에 누른 날도 새 구간을 시작합니다.

<Demo src="calendar/modes">

::: fw react

<<< @/.vitepress/demos/calendar/modes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/calendar/modes.dart

:::

</Demo>

### renderDay

::: fw react

반환한 것이 날짜 칸 안, 숫자 아래에 그려집니다. 칸이 `position: relative`이므로 absolute로 배치한 마크가 원하는 자리에 놓입니다. 칸의 높이는 컨트롤과 같아서(`md`에서 32px) 점 하나, 개수 하나, 막대 하나를 놓을 자리는 있어도 하루치 일정을 담을 자리는 없습니다.

:::

::: fw flutter

반환한 위젯이 날짜 칸 안, 칸 크기의 `Stack`에 그려집니다. 그래서 `Positioned`로 감싼 마크는 원하는 자리에 놓이고, 그 밖의 것은 숫자 위 가운데에 놓입니다. 칸의 높이는 컨트롤과 같아서(`md`에서 32 논리 픽셀) 점 하나, 개수 하나, 막대 하나를 놓을 자리는 있어도 하루치 일정을 담을 자리는 없습니다.

:::

<Demo src="calendar/marks">

::: fw react

<<< @/.vitepress/demos/calendar/marks.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/calendar/marks.dart

:::

</Demo>

### granularity

[DatePicker](./date-picker)가 제공하는 것과 같은 세 단위입니다. `month`나 `year`에서는 그 뷰에서 열리고 거기서 누른 칸이 답이며, 값은 고른 단위의 첫날이 됩니다.

### minDate · maxDate · shouldDisableDate

[DatePicker](./date-picker)와 똑같이 `granularity` 단위로 읽습니다.

::: fw react

막힌 칸은 그리드에 남아 `disabled` 속성 대신 `aria-disabled`로 표시되므로 방향키 경로에서 빠지지 않습니다.

:::

::: fw flutter

막힌 칸은 그리드에 남고, 사용할 수 없다고 읽히면서도 focus node를 그대로 가지므로 방향키 경로에서 빠지지 않습니다.

:::

### bordered와 elevation

`bordered`는 picker 팝업이 그리는 시트를 같은 가장자리, `size`마다 같은 여백으로 그립니다. 이미 테두리가 있는 [Card](../surfaces/card) 안에 넣을 때는 끄고 맨 그리드만 쓰세요. `elevation`은 시트가 있든 없든 모든 표면과 같은 단계의 그림자를 주며, 기본값은 `0`입니다.

## 접근성

::: fw react

- 그리드는 `role="grid"`, 각 칸은 `role="gridcell"` 버튼입니다. 칸의 이름은 숫자가 아니라 완전한 날짜입니다.
- 그리드 전체가 tab 정지 하나이므로 `Tab`은 42개 칸을 지나지 않고 그리드를 빠져나갑니다. 정지는 담긴 날이나 오늘에서 시작합니다. 서버에서 렌더링한 달력은 서버의 오늘이 다른 날일 수 있으므로 1일에서 시작했다가 hydration이 끝나면 오늘로 옮깁니다.
- 값도 `defaultMonth`도 `month`도 없이 서버에서 렌더링하면, 달력은 서버 시계의 달로 열려 그 달 그대로 hydration되고, 독자의 달과 다르면 hydration이 끝난 뒤 독자의 달로 넘어갑니다. `locale`이 없으면 그때까지는 달과 요일 이름을 `en-US`로, 그 뒤로는 독자의 언어로 씁니다. 첫 화면부터 최종 달력을 그리려면 `defaultMonth`와 `locale`을 주세요.
- 방향키는 하루 또는 한 주씩 이동하고, 가장자리에서는 달을 넘깁니다. RTL에서는 `←`가 다음 날입니다.
- `Home`과 `End`는 주의 처음과 끝으로 이동합니다. `PageUp`과 `PageDown`은 한 달씩, `Shift`와 함께 누르면 1년씩 이동합니다.
- 담긴 날은 `aria-selected`, 오늘은 `aria-current="date"`와 숫자 아래의 점으로 표시됩니다. `multiple`과 `range` 모드에서는 그리드에 `aria-multiselectable`이 붙습니다.
- 그리드의 이름은 화면에 있는 달이며, 이 이름은 polite live region에 있어 stepper나 방향키로 달이 바뀌면 새 달을 다시 알립니다. 월·연도 버튼의 이름은 버튼에 보이는 달과 해이고, 누르면 무엇을 하는지는 설명으로 붙습니다.
- `renderDay`가 그리는 것은 `aria-hidden`을 붙이지 않는 한 칸의 accessible name에 포함됩니다. 라벨이 이미 말한 것을 되풀이하는 점은 숨기고, 무언가를 더하는 개수는 숨기지 마세요.

:::

::: fw flutter

- 그리드는 행으로 이뤄진 표이고, 열 머리는 요일의 전체 이름으로 읽힙니다. 날마다 칸 하나에 버튼 하나가 있고, 버튼의 이름은 숫자가 아니라 완전한 날짜입니다.
- 그리드 전체가 tab 정지 하나이므로 `Tab`은 42개 칸을 지나지 않고 그리드를 빠져나갑니다. 정지는 담긴 날에서 시작하고, 없으면 화면에 오늘이 있을 때 오늘에서, 그것도 아니면 1일에서 시작합니다.
- 방향키는 focus를 가진 칸에서부터 하루 또는 한 주씩 이동하고, 가장자리에서는 달을 넘깁니다. RTL에서는 `←`가 다음 날입니다.
- `Home`과 `End`는 주의 처음과 끝으로 이동합니다. `Page Up`과 `Page Down`은 한 달씩, `Shift`와 함께 누르면 1년씩 이동합니다. `Enter`와 `Space`는 focus를 가진 칸을 고릅니다.
- 담긴 날은 선택됨으로 읽힙니다. 오늘은 날짜 뒤에 오늘이라는 말이 함께 읽히고 숫자 아래에 점이 붙습니다. 월과 연도 그리드에서는 이번 달과 올해가 같은 식으로 표시됩니다.
- 그리드의 이름은 화면에 있는 달이며, stepper나 방향키로 달이 바뀌면 live region이 새 달을 다시 알립니다. 월·연도 버튼의 이름은 버튼에 보이는 달과 해이고, 누르면 무엇을 하는지가 설명으로 붙으며, 그 그리드가 열려 있는 동안 펼쳐짐으로 읽힙니다.
- `renderDay`가 그리는 것은 `ExcludeSemantics`로 감싸지 않는 한 칸의 이름과 함께 읽힙니다. 라벨이 이미 말한 것을 되풀이하는 점은 감싸서 빼고, 무언가를 더하는 개수는 그대로 두세요.

:::

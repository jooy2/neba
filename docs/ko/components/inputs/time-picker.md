---
title: TimePicker
order: 16
flutter: true
---

# TimePicker

<p class="neba-lede">하루 중의 시각을 시·분·초 열에서 골라 입력합니다. 각 열은 스크롤되는 listbox입니다.</p>

<Demo src="time-picker/hero" minHeight="400" />

::: fw react

```tsx
import { TimePicker } from 'neba';

<TimePicker label="시작" placeholder="시각을 고르세요" minuteStep={15} clearable />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaTimePicker(
  label: const Text('시작'),
  placeholder: const Text('시각을 고르세요'),
  minuteStep: 15,
  clearable: true,
);
```

:::

## Props

<PropsTable name="TimePicker" />

::: fw react

`<div>`의 native 속성은 root로 전달됩니다. `color` · `defaultValue` · `children`만 위 표와 이름이 겹쳐 제외됩니다.

`value`의 타입은 `Date | null`입니다. `referenceDate`는 값이 아직 비어 있을 때 고른 시각이 얹힐 날짜로, 기본값은 오늘의 시작 시각이라 빈 피커에서 고른 시는 정각이 되고, 컴포넌트가 마운트되어 있는 동안 고정됩니다. 자정을 넘겨 열어 둔 팝업이 값을 다음 날로 옮기지 않게 하기 위한 것입니다.

:::

::: fw flutter

`value`의 타입은 `DateTime?`이라 시각과 함께 날짜도 지닙니다. `null`로 두면 picker가 `defaultValue`에서 시작해 상태를 스스로 관리하고, 시각을 갖고 있던 `value`가 `null`이 되면 비워집니다. `referenceDate`는 값이 아직 비어 있을 때 고른 시각이 얹힐 날짜로, 기본값은 오늘의 시작 시각이라 빈 피커에서 고른 시는 정각이 되고, picker가 빌드되어 있는 동안 고정됩니다. 자정을 넘겨 열어 둔 팝업이 값을 다음 날로 옮기지 않게 하기 위한 것입니다.

`shouldDisableTime`은 React처럼 문자열이 아니라 `NebaTimeUnit`(`hour`, `minute`, `second`, `meridiem`)을 받습니다. `format`은 `DateTime`을 트리거에 보일 문자열로 바꾸는 함수이고, `showStartIcon: false`는 React의 `startIcon={false}`입니다. [DatePicker](./date-picker)처럼 `name`, `required`, `classNames`는 없습니다.

오전과 오후의 이름, 시각을 쓰는 방식, 그 언어가 12시간 다이얼을 쓰는지는 [Calendar](./calendar)가 월 이름을 가져오는 locale의 `NebaDateNames`에서 옵니다. 영어는 들어 있고, 다른 언어는 `{dialHour}`, `{hour}`, `{paddedHour}`, `{minute}`, `{second}`, `{dayPeriod}`를 넣은 패턴으로 직접 등록합니다.

```dart
registerNebaDateNames(
  'ko',
  const NebaDateNames(
    months: <String>['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
    shortMonths: <String>['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
    weekdays: <String>['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'],
    shortWeekdays: <String>['월', '화', '수', '목', '금', '토', '일'],
    am: '오전',
    pm: '오후',
    time: '{dayPeriod} {dialHour}:{minute}',
    timeWithSeconds: '{dayPeriod} {dialHour}:{minute}:{second}',
  ),
);
```

트리거는 `hour12`와 상관없이 locale의 패턴으로 시각을 씁니다. React도 같습니다. 12시간 언어에서 24시간 다이얼 옆에 24시간 표기를 쓰려면 `format`을 넘깁니다.

:::

`closeOnSelect`의 기본값은 `false`입니다. 시와 분 두 가지를 골라야 하므로 첫 선택에서 닫히지 않고, 푸터에 완료 버튼이 있습니다.

## 예시

### minuteStep · secondStep · hour12

`minuteStep`과 `secondStep`은 각 열에 표시할 간격입니다. `hour12`의 기본값은 locale을 따르며, 12시간 표기에서는 열이 `0…11`이 아니라 `12, 1, 2 … 11` 순서로 흐릅니다.

<Demo src="time-picker/columns" minHeight="400">

::: fw react

<<< @/.vitepress/demos/time-picker/columns.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/time_picker/columns.dart

:::

</Demo>

### minTime · maxTime · shouldDisableTime

`minTime`과 `maxTime`은 한 순간이 아니라 **행이 대표하는 구간**과 비교합니다. 최솟값이 09:30이면 시 열의 `9`는 09:00–09:59를 덮고 그 구간이 허용 범위와 겹치므로 남아 있고, 대신 분 열에서 `00`부터 `29`까지가 흐려집니다. 덕분에 09:30에 도달할 수 있습니다. 10:15에서 시 열의 `9`를 누른 경우처럼 행을 눌러 경계 밖의 시각이 되면, 커밋되기 전에 가장 가까운 경계인 09:30으로 옮겨집니다.

`shouldDisableTime`은 해당 행이 만들 순간과 그 행이 속한 열을 함께 받으므로, "점심시간 제외"처럼 성긴 규칙도 1분 단위 규칙도 쓸 수 있습니다.

<Demo src="time-picker/bounds" minHeight="420">

::: fw react

<<< @/.vitepress/demos/time-picker/bounds.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/time_picker/bounds.dart

:::

</Demo>

### labelPlacement

`notch`와 `float`는 [TextField](./text-field#labelplacement)와 같게 동작합니다. trigger 앞의 시계 아이콘이 `float` 라벨이 내려앉을 자리를 차지하므로, <Fw react="startIcon={false}" flutter="showStartIcon: false" code />를 넘기지 않으면 라벨은 노치에 머뭅니다. popup이 열려 있는 동안에도 노치에 있습니다.

<Demo src="time-picker/label-placement" minHeight="400">

::: fw react

<<< @/.vitepress/demos/time-picker/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/time_picker/label_placement.dart

:::

</Demo>

### showNowButton과 clearable

`showNowButton`은 현재 시각으로 이동하는 버튼을, `clearable`은 값을 비우는 버튼을 붙입니다.

## 접근성

::: fw react

- 각 열은 `role="listbox"`이고 행은 `role="option"`입니다. 열의 이름은 `locale`에서 오고, `labels`로 직접 쓸 수도 있습니다.
- 열마다 tab 정지점이 하나이며, 선택된 행이나 첫 행에 있습니다. ↑와 ↓로 열 안을 오가고 Home과 End로 양 끝으로 갑니다. 행을 고르는 것은 Enter, Space, 누르기입니다.
- 선택된 행은 `aria-selected`, 막힌 행은 `disabled` 속성 대신 `aria-disabled`로 표시됩니다. 도달할 수 있어야 왜 고를 수 없는지 전달되기 때문입니다.
- 팝업이 열릴 때 각 열의 선택된 행이 화면 안으로 스크롤됩니다.
- 열 옆의 live region이 값이 바뀔 때마다 전체 시각을 읽어 줍니다.

:::

::: fw flutter

- 화면 낭독기에게 트리거는 노드 하나입니다. `Text` 라벨로 이름 붙은 버튼이며, 보이는 시각을 값으로 말하고 접혔는지 펼쳐졌는지가 함께 읽힙니다.
- 각 열은 열 이름이 붙은 묶음이고, 그 안에 행마다 행의 글자로 이름 붙은 버튼이 하나씩 있습니다. 열의 이름은 `locale`에서 오고, `labels`로 직접 쓸 수도 있습니다.
- 열마다 tab 정지점이 하나이며, 선택된 행이나 첫 행에 있고, `Tab`은 열을 순서대로 지나갑니다. ↑와 ↓로 열 안을 오가고 `Home`과 `End`로 양 끝으로 갑니다. 행을 고르는 것은 `Enter`, `Space`, 누르기입니다. `Escape`, 바깥 누르기, 팝업 밖으로 나가는 focus는 팝업을 닫고 focus를 트리거로 돌려줍니다.
- 선택된 행은 선택됨으로 읽힙니다. 막힌 행은 사용할 수 없다고 읽히면서도 focus node를 그대로 가지므로 방향키 이동 경로에서 빠지지 않습니다.
- 팝업이 열릴 때 각 열의 선택된 행이 화면 안으로 스크롤됩니다.
- 열 옆의 live region이 값이 바뀔 때마다 전체 시각을 읽어 줍니다.

:::

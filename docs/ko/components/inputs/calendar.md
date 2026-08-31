---
title: Calendar
order: 16
---

# Calendar

<p class="neba-lede">한 달을 페이지 안에 그리고, 지금 담고 있는 날들을 켜 둡니다. 네 개의 picker가 여는 것과 같은 그리드에서 팝업만 걷어낸 것으로, 날짜가 항상 보여야 하는 화면을 위한 것입니다.</p>

<Demo src="calendar/hero" align="center" />

```tsx
import { Calendar } from 'neba';

<Calendar value={day} onValueChange={setDay} />;
```

## Props

<PropsTable name="Calendar" />

`<div>`의 native 속성은 root로 전달됩니다. 공통 축은 [prop 규약](../../design/prop-conventions)에 설명돼 있습니다.

### 이것이 아닌 것

스케줄러가 아닙니다. 칸의 크기는 컨트롤 사다리의 높이입니다 — `md`에서 32px — 그래서 `renderDay`는 숫자 아래에 점 하나, 개수 하나, 막대 하나를 놓을 자리이지 하루치 일정을 담을 자리가 아닙니다. 그것을 그리는 컴포넌트는 다른 그리드가 필요하고, 이것을 그렇게 부르는 것은 크기가 지킬 수 없는 약속입니다.

고르기 · 거르기 · 표시하기에 쓰세요. 날짜가 필드 뒤에 있어야 한다면 [DatePicker](./date-picker)입니다.

## 예시

### mode

`mode`가 값이 무엇인지를 정합니다.

| `mode`           | `value`                                      |
| ---------------- | -------------------------------------------- |
| `single`(기본값) | `Date \| null`                               |
| `multiple`       | `Date[]`                                     |
| `range`          | `{ start: Date \| null, end: Date \| null }` |

`multiple`에서는 이미 담긴 날을 다시 누르면 빠집니다. 포인터로 되돌릴 수 있는 유일한 방법입니다.

`range`에서는 첫 클릭이 시작을, 두 번째가 끝을 정합니다. 시작보다 **앞을** 누르면 기존 구간을 뒤집는 대신 새 구간을 시작합니다. 뒤집는 동작이야말로 독자가 잘못 눌렀다고 믿게 만드는 것이기 때문입니다. 구간이 완성된 뒤의 클릭은 또 새 구간을 시작합니다.

<Demo src="calendar/modes">

<<< @/.vitepress/demos/calendar/modes.tsx

</Demo>

### renderDay

반환한 것이 날짜 칸 안, 숫자 아래에 그려집니다. 칸이 `position: relative`이므로 absolute로 배치한 마크가 원하는 자리에 놓입니다.

`events` prop이 아니라 hook인 이유는, 하루에 **무엇이 있는지**를 아는 것은 호출하는 쪽뿐이고, 여기서 데이터 모양을 받는 순간 그 모양에 대한 의견을 갖게 되기 때문입니다.

<Demo src="calendar/marks">

<<< @/.vitepress/demos/calendar/marks.tsx

</Demo>

### granularity

[DatePicker](./date-picker)가 제공하는 것과 같은 세 단위입니다. `month`나 `year`에서는 그 뷰에서 열리고 거기서의 클릭이 답이며, 값은 고른 단위의 첫날이 됩니다.

### minDate · maxDate · shouldDisableDate

[DatePicker](./date-picker)와 똑같이 `granularity` 단위로 읽습니다. 막힌 칸은 그리드에 남아 `disabled` 속성 대신 `aria-disabled`로 표시되므로 방향키 경로에서 빠지지 않습니다.

### bordered와 elevation

`bordered`는 picker 팝업이 그리는 시트를 그립니다. 이미 테두리가 있는 [Card](../surfaces/card) 안에 넣을 때는 끄고 맨 그리드만 쓰세요. `elevation`의 기본값은 `0`입니다 — 페이지 안에 앉은 달력은 떠 있지 않습니다.

## 키보드

| 키                    | 동작                                       |
| --------------------- | ------------------------------------------ |
| `←` `→` `↑` `↓`       | 하루 또는 한 주 이동, 가장자리에서 달 넘김 |
| `Home` / `End`        | 주의 처음 또는 끝                          |
| `PageUp` / `PageDown` | 한 달씩 — `Shift`와 함께면 1년씩           |

그리드 전체가 tab 정지 하나이므로 `Tab`은 42개 칸을 지나지 않고 그리드를 빠져나갑니다.

## 접근성

- 그리드는 `role="grid"`, 각 칸은 `role="gridcell"` 버튼입니다. 칸의 이름은 숫자가 아니라 완전한 날짜입니다.
- 담긴 날은 `aria-selected`, 오늘은 `aria-current="date"`와 숫자 아래의 점으로 표시됩니다.
- `renderDay`가 그리는 것은 `aria-hidden`을 붙이지 않는 한 칸의 accessible name에 포함됩니다. 라벨이 이미 말한 것을 되풀이하는 점은 숨기고, 무언가를 더하는 개수는 숨기지 마세요.

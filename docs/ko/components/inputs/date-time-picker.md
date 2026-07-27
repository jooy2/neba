---
title: DateTimePicker
order: 17
---

# DateTimePicker

<p class="neba-lede">날과 시각을 한 팝업에서 고릅니다. 달력과 시계는 정확히 같은 높이로 나란히 서고, 그래서 팝업은 크기가 다른 두 덩어리가 아니라 하나의 사각형입니다.</p>

<Demo src="date-time-picker/hero" />

```tsx
import { DateTimePicker } from 'neba';

<DateTimePicker label="게시 시각" placeholder="순간을 고르세요" minuteStep={15} clearable />;
```

## Props

<PropsTable name="DateTimePicker" />

나머지는 전부 [DatePicker](./date-picker)와 [TimePicker](./time-picker)의 것 그대로입니다 — 같은 세 가지 달력 뷰, 같은 열 동작, 같은 `Date` 값. 여기서 읽을 만한 것은 정말로 다른 부분입니다.

### 범위를 시각까지 읽습니다

DateTimePicker가 필드 두 개를 나란히 놓는 대신 별도의 컴포넌트일 값을 하는 대목입니다.

[DatePicker](./date-picker)의 `minDate`는 날짜 단위입니다 — 27일은 있거나 없거나입니다. 여기서는 아닙니다. 스케줄 폼이 실제로 필요로 하는 규칙은 "**지금** 이전은 안 됨"이고, 지금은 날인 동시에 시각이기 때문입니다. 그래서 27일 09:30이 `minDate`이면 달력에서 27일은 그대로 고를 수 있고, 시계에서 오전이 흐려집니다.

<Demo src="date-time-picker/bounds">

<<< @/.vitepress/demos/date-time-picker/bounds.tsx

</Demo>

시계 쪽 검사는 [TimePicker](./time-picker)가 하는 구간 비교를, 열이 어느 날에 쓰고 있는지 알 수 있도록 절대 시간축 위로 옮긴 것입니다. 경계가 되는 날에는 최솟값 이전 시간들이 막히고, 그 뒤의 날에는 하나도 막히지 않습니다.

### 값은 하나, 반쪽은 둘, 순서는 없음

날을 고르면 날이 바뀌고 시계는 그대로입니다. 시를 고르면 시계가 바뀌고 날은 그대로입니다. 날짜를 고칠 때마다 시각을 자정으로 되돌리는 피커는 순간을 고르는 일을 순서 있는 작업으로 만듭니다. 팝업을 쓰인 순서대로 읽는 사람은 없습니다.

`closeOnSelect`의 기본값이 `false`이고 푸터에 **Done**이 있는 것도 같은 이유입니다. 순간은 날 _그리고_ 시각이므로, 둘 중 첫 번째에서 닫으면 두 번째를 묻지 못한 채 끝납니다.

### 글리프는 하나입니다

트리거는 달력을 달고 시계는 달지 않습니다. 컨트롤은 한 번에 두 가지를 말할 수 없고, 읽는 사람이 눈으로 찾는 쪽은 날짜입니다.

## 접근성

달력은 `role="grid"`, 시계는 `role="listbox"` 열들입니다 — 이 컴포넌트를 이루는 두 컴포넌트에서와 정확히 같습니다. [DatePicker](./date-picker)와 [TimePicker](./time-picker)를 보세요. 트리거는 `Intl`로 양쪽을 한 문자열에 씁니다. 스크린 리더가 읽는 것은 이어 붙여야 할 두 필드가 아니라 하나의 문장입니다.

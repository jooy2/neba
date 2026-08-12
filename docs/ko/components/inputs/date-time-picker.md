---
title: DateTimePicker
order: 17
---

# DateTimePicker

<p class="neba-lede">날짜와 시각을 한 팝업에서 함께 고릅니다. 예약 시각이나 게시 시각처럼 두 값이 하나의 순간을 이루는 입력에 씁니다.</p>

<Demo src="date-time-picker/hero" />

```tsx
import { DateTimePicker } from 'neba';

<DateTimePicker label="게시 시각" placeholder="순간을 고르세요" minuteStep={15} clearable />;
```

## Props

<PropsTable name="DateTimePicker" />

`<div>`의 native 속성은 root로 전달됩니다. `color` · `defaultValue` · `children`만 위 표와 이름이 겹쳐 제외됩니다.

달력 관련 prop은 [DatePicker](./date-picker), 시계 관련 prop은 [TimePicker](./time-picker)와 동일하게 동작합니다. 달력과 시계는 같은 높이로 나란히 놓입니다.

`closeOnSelect`의 기본값은 `false`이고 푸터에 완료 버튼이 있습니다. 날짜와 시각 두 가지를 물어야 하므로 첫 선택에서 닫히지 않습니다.

날짜를 고르면 시각은 유지되고, 시각을 고르면 날짜가 유지됩니다. 두 값을 어떤 순서로 골라도 됩니다.

## 예시

### minDate · maxDate

경계를 날짜뿐 아니라 **시각까지** 읽습니다. `minDate`가 27일 09:30이면 달력에서 27일은 그대로 고를 수 있고, 시계에서 09:30 이전 시각만 흐려집니다. 그다음 날에는 아무 시각도 막히지 않습니다.

"지금 이후만 선택 가능" 같은 규칙을 표현할 때 필요한 동작입니다.

<Demo src="date-time-picker/bounds">

<<< @/.vitepress/demos/date-time-picker/bounds.tsx

</Demo>

### trigger 표시

trigger는 달력 글리프만 표시하고 시계 글리프는 표시하지 않습니다. 값은 `Intl`로 날짜와 시각을 한 문자열로 합쳐 보여 줍니다.

## 접근성

- 달력은 `role="grid"`, 시계는 `role="listbox"` 열로 렌더링됩니다. 세부 동작은 [DatePicker](./date-picker)와 [TimePicker](./time-picker)를 보세요.
- trigger의 accessible name은 날짜와 시각이 합쳐진 하나의 문장으로 읽힙니다.

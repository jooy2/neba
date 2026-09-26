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

경계를 날짜뿐 아니라 **시각까지** 읽습니다. `minDate`가 27일 09:30이면 달력에서 27일은 그대로 고를 수 있고, 시계에서 09:30 이전 시각만 흐려집니다. 그다음 날에는 아무 시각도 막히지 않습니다. 시계가 아직 자정인 채로 27일을 고른 경우처럼 경계 밖의 순간이 선택되면, 커밋되기 전에 가장 가까운 경계로 옮겨집니다.

"지금 이후만 선택 가능" 같은 규칙을 표현할 때 필요한 동작입니다.

<Demo src="date-time-picker/bounds">

<<< @/.vitepress/demos/date-time-picker/bounds.tsx

</Demo>

### labelPlacement

`notch`와 `float`는 [TextField](./text-field#labelplacement)와 같게 동작합니다. trigger 앞의 달력 아이콘이 `float` 라벨이 내려앉을 자리를 차지하므로, `startIcon={false}`를 넘기지 않으면 라벨은 노치에 머뭅니다. popup이 열려 있는 동안에도 노치에 있습니다.

<Demo src="date-time-picker/label-placement">

<<< @/.vitepress/demos/date-time-picker/label-placement.tsx

</Demo>

### trigger 표시

trigger는 달력 글리프만 표시하고 시계 글리프는 표시하지 않습니다. 값은 `Intl`로 날짜와 시각을 한 문자열로 합쳐 보여 줍니다.

## 접근성

- 달력은 `role="grid"`, 시계는 `role="listbox"` 열로 렌더링됩니다. 세부 동작은 [DatePicker](./date-picker)와 [TimePicker](./time-picker)를 보세요.
- trigger의 accessible name은 label이 있으면 label 뒤에 값이 이어진 것이며, 값은 날짜와 시각을 함께 담은 `Intl` 문자열 하나입니다.

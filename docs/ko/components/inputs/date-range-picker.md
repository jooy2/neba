---
title: DateRangePicker
order: 18
---

# DateRangePicker

<p class="neba-lede">시작일과 종료일로 이루어진 기간을 고릅니다. 달력이 두 개 나란히 놓이고, 두 번째 클릭 전에도 포인터를 따라 구간이 미리 표시됩니다.</p>

<Demo src="date-range-picker/hero" />

```tsx
import { DateRangePicker } from 'neba';

<DateRangePicker label="숙박" startPlaceholder="체크인" endPlaceholder="체크아웃" clearable />;
```

## Props

<PropsTable name="DateRangePicker" />

`<div>`의 native 속성은 root로 전달됩니다. `color` · `defaultValue` · `children`만 위 표와 이름이 겹쳐 제외됩니다.

값은 튜플이 아니라 객체 하나입니다.

```ts
interface DateRange {
  start: Date | null;
  end: Date | null;
}
```

`onValueChange`는 항상 객체로 호출됩니다. 비워진 범위는 `{ start: null, end: null }`이므로 두 종류의 "비어 있음"을 검사할 필요가 없습니다.

첫 클릭과 두 번째 클릭 사이의 절반 상태는 `{ start, end: null }`로 보고되고, 두 번째 클릭 없이 팝업을 닫으면 버려집니다. 두 번째 클릭이 첫 번째보다 앞선 날짜여도 오류가 아니라 순서를 바꿔 말한 같은 범위로 보고 정렬합니다.

나머지 prop(`minDate` · `maxDate` · `shouldDisableDate` · `variant` · `size`)은 [DatePicker](./date-picker)와 동일하게 동작합니다.

## 예시

### monthCount

기본값은 `2`입니다. 두 패널은 반으로 나뉜 하나의 달력이므로, 왼쪽에는 앞으로 가는 stepper가 없고 오른쪽에는 뒤로 가는 stepper가 없으며, 어느 쪽 헤더를 조작해도 두 패널이 함께 움직입니다.

패널이 둘일 때는 인접한 달의 앞뒤 날짜를 그리지 않습니다. 같은 날짜가 두 패널에 중복으로 나타나지 않게 하기 위한 것입니다.

<Demo src="date-range-picker/one-month">

<<< @/.vitepress/demos/date-range-picker/one-month.tsx

</Demo>

### presets

자주 쓰는 기간을 팝업 옆에 버튼으로 놓습니다. 프리셋의 `value`는 범위 객체이거나 범위를 반환하는 함수입니다. 함수 쪽을 쓰세요. 렌더 시점에 한 번 계산된 범위는 탭을 오래 열어 둔 사용자에게 틀린 값이 됩니다.

<Demo src="date-range-picker/presets">

<<< @/.vitepress/demos/date-range-picker/presets.tsx

</Demo>

### name

`name`을 주면 같은 이름의 hidden input 두 개가 그려지므로 두 끝이 함께 제출됩니다.

```ts
const form = new FormData(event.currentTarget);
const [start, end] = form.getAll('stay'); // '2026-07-03', '2026-07-09'
```

두 값 모두 로컬 기준 `YYYY-MM-DD`이며, native `<input type="date">`가 제출하는 형식과 같습니다.

## 접근성

- 각 패널은 `role="grid"`이고 자기 tab 정지를 가지므로, `Tab`은 84개 칸을 지나지 않고 두 그리드 사이를 이동합니다.
- 두 끝에만 `aria-selected`가 붙습니다. 사이의 날짜는 구간 표시만 받습니다.
- 팝업 푸터가 다음 클릭이 어느 끝을 채울지 알려 줍니다.

---
title: TimePicker
order: 16
---

# TimePicker

<p class="neba-lede">하루 중의 시각을 시·분·초 열에서 골라 입력합니다. 각 열은 스크롤되는 listbox입니다.</p>

<Demo src="time-picker/hero" />

```tsx
import { TimePicker } from 'neba';

<TimePicker label="시작" placeholder="시각을 고르세요" minuteStep={15} clearable />;
```

## Props

<PropsTable name="TimePicker" />

`value`의 타입은 `Date | null`입니다. `referenceDate`는 값이 아직 비어 있을 때 고른 시각이 얹힐 날짜로, 기본값은 오늘이며 컴포넌트가 마운트되어 있는 동안 고정됩니다 — 자정을 넘겨 열어 둔 팝업이 값을 다음 날로 옮기지 않게 하기 위한 것입니다.

`closeOnSelect`의 기본값은 `false`입니다. 시와 분 두 가지를 골라야 하므로 첫 선택에서 닫히지 않고, 푸터에 완료 버튼이 있습니다.

## 예시

### minuteStep · secondStep · hour12

`minuteStep`과 `secondStep`은 각 열에 표시할 간격입니다. `hour12`의 기본값은 locale을 따르며, 12시간 표기에서는 열이 `0…11`이 아니라 `12, 1, 2 … 11` 순서로 흐릅니다.

<Demo src="time-picker/columns">

<<< @/.vitepress/demos/time-picker/columns.tsx

</Demo>

### minTime · maxTime · shouldDisableTime

`minTime`과 `maxTime`은 한 순간이 아니라 **행이 대표하는 구간**과 비교합니다. 최솟값이 09:30이면 시 열의 `9`는 09:00–09:59를 덮고 그 구간이 허용 범위와 겹치므로 남아 있고, 대신 분 열에서 `00`부터 `25`까지가 흐려집니다. 덕분에 09:30에 도달할 수 있습니다.

`shouldDisableTime`은 해당 행이 만들 순간과 그 행이 속한 열을 함께 받으므로, "점심시간 제외"처럼 성긴 규칙도 1분 단위 규칙도 쓸 수 있습니다.

<Demo src="time-picker/bounds">

<<< @/.vitepress/demos/time-picker/bounds.tsx

</Demo>

### showNowButton과 clearable

`showNowButton`은 현재 시각으로 이동하는 버튼을, `clearable`은 값을 비우는 버튼을 붙입니다.

## 접근성

- 각 열은 `role="listbox"`이고 행은 `role="option"`입니다. 열의 이름은 `labels`로 지정하며 영어 기본값을 가집니다.
- 선택된 행은 `aria-selected`, 막힌 행은 `disabled` 속성 대신 `aria-disabled`로 표시됩니다. 도달할 수 있어야 왜 고를 수 없는지 전달되기 때문입니다.
- 팝업이 열릴 때 각 열의 선택된 행이 화면 안으로 스크롤됩니다.
- 열 옆의 live region이 값이 바뀔 때마다 전체 시각을 읽어 줍니다.

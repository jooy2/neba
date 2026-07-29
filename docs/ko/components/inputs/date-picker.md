---
title: DatePicker
order: 15
---

# DatePicker

<p class="neba-lede">달력 팝업에서 날짜 하나를 고릅니다. 월 이름과 연도가 각각 자기 그리드를 여는 버튼이므로 먼 과거나 미래에도 몇 번의 클릭으로 닿습니다.</p>

<Demo src="date-picker/hero" />

```tsx
import { DatePicker } from 'neba';

<DatePicker label="출고일" placeholder="날짜를 고르세요" clearable />;
```

## Props

<PropsTable name="DatePicker" />

`value`의 타입은 `Date | null`입니다. 별도의 날짜 라이브러리는 쓰지 않습니다.

모든 비교는 UTC 타임스탬프가 아니라 **로컬 달력의 날**을 기준으로 합니다. 폼이 제출하는 hidden input도 로컬 기준 `YYYY-MM-DD` 문자열이므로, `toISOString()`으로 하루가 밀리는 문제가 생기지 않습니다.

### 세 가지 뷰

헤더의 두 버튼이 각각 다른 그리드를 엽니다.

- **월 이름** — 12개월 그리드
- **연도** — 12년 그리드. 이때 stepper는 한 페이지씩 움직입니다.

연도를 고르면 월 뷰로 넘어갑니다. 두 버튼의 순서는 locale을 따르므로 한국어에서는 `2026년 7월`로 표시됩니다. 세 뷰의 너비와 높이가 같아서 뷰를 바꿔도 팝업 크기가 변하지 않습니다.

## 예시

### variant

[TextField](./text-field)와 같은 세 가지 무게를 같은 shell 위에 그립니다.

<Demo src="date-picker/variants">

<<< @/.vitepress/demos/date-picker/variants.tsx

</Demo>

### size

달력의 한 칸이 컨트롤 높이 단계를 씁니다 — `md`에서 32px로, 같은 `size`의 [Button](./button)이나 [TextField](./text-field)와 같습니다.

<Demo src="date-picker/sizes">

<<< @/.vitepress/demos/date-picker/sizes.tsx

</Demo>

### minDate · maxDate · shouldDisableDate

`minDate`와 `maxDate`는 날짜 단위로 비교합니다. 27일 09:00이 최댓값이어도 27일은 고를 수 있습니다. 범위 안에 있지만 선택할 수 없는 날은 `shouldDisableDate`로 막습니다.

막힌 칸은 그리드에 남아 있고 `disabled` 속성 대신 `aria-disabled`로 표시됩니다. 방향키 이동 경로에서 빠지지 않게 하기 위한 것입니다.

<Demo src="date-picker/bounds">

<<< @/.vitepress/demos/date-picker/bounds.tsx

</Demo>

### disabled · readOnly · error

<Demo src="date-picker/states">

<<< @/.vitepress/demos/date-picker/states.tsx

</Demo>

### showTodayButton과 clearable

`showTodayButton`은 팝업 푸터에 오늘로 이동하는 버튼을, `clearable`은 trigger에 값을 비우는 버튼을 붙입니다.

## 키보드

trigger는 텍스트 입력이 아니라 버튼입니다. 날짜는 달력에서 고릅니다.

| 키                    | 동작                                       |
| --------------------- | ------------------------------------------ |
| `Space` / `Enter`     | 달력을 열고, 선택된 날에 focus             |
| `←` `→` `↑` `↓`       | 하루 또는 한 주 이동, 가장자리에서 달 넘김 |
| `Home` / `End`        | 주의 처음 또는 끝                          |
| `PageUp` / `PageDown` | 한 달씩 — `Shift`와 함께면 1년씩           |
| `Escape`              | 고르지 않고 닫기                           |

그리드 전체가 tab 정지 하나이므로 `Tab`은 42개 칸을 지나지 않고 그리드를 빠져나갑니다.

## 접근성

- 그리드는 `role="grid"`, 각 칸은 `role="gridcell"` 버튼입니다. 칸의 이름은 숫자가 아니라 완전한 날짜입니다.
- 선택된 날은 `aria-selected`, 오늘은 `aria-current="date"`와 숫자 아래의 점으로 표시됩니다.
- `label`이 trigger의 accessible name이 되고, `description`과 `error`는 `aria-describedby`로 연결됩니다.
- 팝업은 `<body>` 끝으로 portal되며 positioner에 `neba-portal` 클래스가 붙습니다.

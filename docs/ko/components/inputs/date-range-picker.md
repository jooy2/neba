---
title: DateRangePicker
order: 18
---

# DateRangePicker

<p class="neba-lede">두 날 사이의 구간을 고릅니다. 달력 두 개가 나란히 서고, 띠는 두 번째 클릭이 떨어지기 전에 — 포인터를 따라 — 그려집니다.</p>

<Demo src="date-range-picker/hero" />

```tsx
import { DateRangePicker } from 'neba';

<DateRangePicker label="숙박" startPlaceholder="체크인" endPlaceholder="체크아웃" clearable />;
```

## Props

<PropsTable name="DateRangePicker" />

### 값은 객체 하나입니다

```ts
interface DateRange {
  start: Date | null;
  end: Date | null;
}
```

`[Date, Date]` 튜플도 아니고 프롭 두 개도 아닙니다. 범위는 하나의 값입니다 — 한 동작으로 고르고, 한 동작으로 비우고, 통째로 검증합니다 — 그리고 이름 두 개가 호출하는 쪽이 끝을 시작 자리에 쓰는 것을 막습니다.

`onValueChange`는 언제나 객체로 불립니다. `null`로는 불리지 않으므로, 비워진 범위는 `{ start: null, end: null }`이고 호출하는 쪽이 두 종류의 "비어 있음"을 검사할 일이 없습니다.

절반의 범위는 실재하는 상태입니다. 첫 클릭과 두 번째 클릭 사이에 피커가 들고 있는 것이고, `{ start, end: null }`로 보고됩니다. 두 번째 클릭 없이 팝업을 닫아 버리면 그것은 버려집니다 — 한쪽 끝만 있는 범위를 폼에 남겨 두지 않습니다.

### 패널은 둘, 달력은 하나

달을 넘는 범위가 예외가 아니라 보통이므로 `monthCount`의 기본값은 `2`입니다. 두 패널은 반으로 나뉜 하나의 달력입니다. 왼쪽에는 앞으로 가는 스테퍼가 없고, 오른쪽에는 뒤로 가는 스테퍼가 없으며, 어느 쪽 헤더의 월·연도 버튼이든 둘을 함께 움직입니다.

패널은 이웃한 달의 앞뒤 날들을 일부러 **그리지 않습니다**. 단독 [DatePicker](./date-picker)는 그립니다. 두 패널이 모두 6주를 꽉 채워 보이면 8월 1일이 두 번 나타나기 때문입니다 — 한 번은 7월의 꼬리로, 한 번은 자기 자신으로. 같은 이름의 칸이 한 팝업에 둘 있는 것은 포인터에게는 모호하고 스크린 리더에게는 아예 고장입니다.

### 거꾸로 클릭하는 것은 실수가 아닙니다

두 번째 클릭이 첫 번째보다 앞에 떨어질 수 있습니다. 그것은 거절할 오류가 아니라 순서를 바꿔 말한 같은 범위이므로, 두 끝은 정렬된 뒤에 보고됩니다. 완성된 범위 다음의 클릭은 새 범위를 시작합니다.

## 예시

### 프리셋

리포팅 UI가 실제로 쓰이는 통로입니다. "최근 30일"을 하루씩 골라 넣는 사람은 없습니다.

<Demo src="date-range-picker/presets">

<<< @/.vitepress/demos/date-range-picker/presets.tsx

</Demo>

프리셋의 `value`는 범위이거나 범위를 반환하는 함수입니다. 함수 쪽을 쓰세요 — 렌더 시점에 계산된 범위는 탭을 밤새 열어 둔 사람에게 틀린 값이 됩니다.

### 패널 하나, 그리고 범위

<Demo src="date-range-picker/one-month">

<<< @/.vitepress/demos/date-range-picker/one-month.tsx

</Demo>

## 제출

`name`은 같은 이름의 hidden input 두 개를 그립니다. 두 끝이 함께 도착합니다.

```ts
const form = new FormData(event.currentTarget);
const [start, end] = form.getAll('stay'); // '2026-07-03', '2026-07-09'
```

둘 다 로컬 기준 `YYYY-MM-DD`이고, 네이티브 `<input type="date">`가 제출하는 모양 그대로입니다.

## 접근성

- 각 패널은 완전한 날짜로 이름 붙은 `role="gridcell"` 버튼들의 `role="grid"`이고, 각자 자기 탭 정지점을 가집니다 — `Tab`은 84개의 칸을 지나는 대신 두 그리드 사이를 오갑니다.
- 두 끝은 `aria-selected`를 답니다. 그 사이의 날들은 띠만 두를 뿐입니다. 범위 안에 있다는 것과 선택되었다는 것은 같은 말이 아니기 때문입니다.
- 푸터가 다음 클릭이 어느 쪽 끝을 채울지 말해 줍니다. 트리거의 두 절반도 같은 말을 하지만, 팝업이 떠 있는 동안 트리거는 그 뒤에 있습니다.

---
title: Timeline
order: 12
---

# Timeline

<p class="neba-lede">순서가 있는 단계들을 시간 흐름대로 나열합니다. 주문 처리 상태나 배포 이력처럼 순서 자체가 정보인 목록에 씁니다.</p>

<Demo src="timeline/hero" />

```tsx
import { Timeline, TimelineItem } from 'neba';

<Timeline active={2}>
  <TimelineItem title="주문" meta="7월 12일">
    결제가 완료되었습니다.
  </TimelineItem>
  <TimelineItem title="배송 중" meta="7월 14일" />
  <TimelineItem title="배송 완료" />
</Timeline>;
```

## Props

### Timeline

<PropsTable name="Timeline" />

`active`는 값이 아니라 **인덱스**입니다. 이 인덱스보다 앞선 항목은 `complete`, 해당 항목은 `current`, 뒤는 `upcoming`이 됩니다. 생략하면 전부 `upcoming`, 항목 수보다 큰 값을 주면 전부 `complete`입니다.

### TimelineItem

<PropsTable name="TimelineItem" />

## 예시

### bullet

`bullet`에는 어떤 node든 넣을 수 있습니다. 번호는 사용자를 안내하는 절차에, 아이콘은 이미 일어난 사건에 어울립니다. 생략하면 원이 그려집니다.

세 상태는 각각 다른 모양을 씁니다 — 채워진 원(`complete`), 후광이 둘린 채워진 원(`current`), 빈 원(`upcoming`). 색을 구분하지 못해도 상태가 전달됩니다.

<Demo src="timeline/bullets">

<<< @/.vitepress/demos/timeline/bullets.tsx

</Demo>

### status와 color

`active`는 정상적으로 진행되는 순서를 표현합니다. 실패해서 멈춘 단계처럼 인덱스로 설명할 수 없는 상태는 항목별 `status`와 `color`로 덮어씁니다.

`connector`는 다음 항목으로 이어지는 선의 모양입니다. 선은 도착점이 아니라 출발한 단계에 속하므로 그 단계의 상태에 따라 색이 정해집니다. `none`은 선을 없애서 한 Timeline 안에서 그룹을 나눌 때 씁니다.

<Demo src="timeline/status">

<<< @/.vitepress/demos/timeline/status.tsx

</Demo>

### orientation

`horizontal`은 결제 화면 상단의 stepper 형태입니다. 단계 수와 라벨 길이에 여유가 없으므로 짧은 라벨에만 적합합니다.

<Demo src="timeline/horizontal">

<<< @/.vitepress/demos/timeline/horizontal.tsx

</Demo>

## 접근성

- `<ol>`로 렌더링되므로 순서가 있는 목록으로 읽힙니다.
- `current` 상태의 항목에는 `aria-current="step"`이 붙습니다.

## 이럴 때는 다른 컴포넌트를

- 지난 기록이 아니라 현재 진행률을 보여 준다면 [ProgressLinear](../feedback/progress-linear)를 쓰세요.
- 순서에 의미가 없는 나열이라면 [List](./list)를 쓰세요. Timeline의 선은 "그다음"이라는 의미를 갖습니다.

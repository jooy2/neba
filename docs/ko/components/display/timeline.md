---
title: Timeline
order: 12
---

# Timeline

<p class="neba-lede">일어나는 순서대로 놓인 단계들입니다. 순서 자체가 내용인 목록입니다.</p>

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

<PropsTable name="Timeline" />

### TimelineItem

<PropsTable name="TimelineItem" />

## `active`는 인덱스입니다

값이 아니라 인덱스인 이유는 타임라인에 **선택이 없기** 때문입니다. 여기서 고르는 것은 아무것도 없고, 물어볼 것은 어디까지 왔는가뿐입니다. `active`보다 앞선 항목은 전부 `complete`, 그 항목은 `current`, 뒤는 전부 `upcoming`입니다.

생략하면 전부 `upcoming`이고 — 아직 시작하지 않은 계획입니다 — 항목 수를 넘기면 전부 `complete`입니다.

번호는 [Timeline](#) 쪽에서 매겨집니다. 항목이 자기 위치를 prop으로 받아야 한다면 그것은 모든 호출자가 틀리게 넣을 수 있는 자리이고, 중간에 하나를 끼워 넣을 때마다 뒤의 것을 전부 다시 번호 매겨야 합니다.

## 예시

### 불릿

불릿 안에는 무엇이든 들어갑니다. 번호는 사람을 걸어서 안내하는 순서에, 아이콘은 이미 일어난 순서에 어울립니다. 아무것도 넣지 않으면 그냥 원이고, 스스로에 대해 할 말이 없는 단계는 그래야 합니다.

<Demo src="timeline/bullets">

<<< @/.vitepress/demos/timeline/bullets.tsx

</Demo>

세 상태는 각각 **다른 축**을 씁니다. 투명도가 아니라 채워진 원, 후광이 둘린 채워진 원, 비어 있는 원입니다. 색을 구별하지 못하는 사람에게도 모양 세 개가 그대로 남습니다. [디자인 언어](../../guide/design-language)가 상태마다 자기 축을 요구하는 것과 같은 규칙입니다.

### 계획대로 되지 않을 때

`active`는 잘 굴러가는 순서를 설명합니다. 실패해서 멈춘 단계는 인덱스가 말할 수 있는 것이 아니고, 그것이 항목별 `status`와 `color` 덮어쓰기가 있는 이유입니다.

<Demo src="timeline/status">

<<< @/.vitepress/demos/timeline/status.tsx

</Demo>

`connector`는 다음 항목으로 이어지는 선을 정합니다. 선은 도착점이 아니라 **출발한 단계의 것**이므로, 그 단계에 도달했는지에 따라 색이 정해집니다. `none`은 선을 없애고, 한 타임라인 안에서 무리를 나눌 때 쓸 만합니다.

### 가로

`horizontal`은 결제 화면 위쪽의 스테퍼입니다. 라벨이 짧을 때만 정직하다는 점을 기억할 필요가 있습니다 — 가로 타임라인은 단계 수에도, 각 단계에 대해 할 말의 길이에도 여유가 없습니다.

<Demo src="timeline/horizontal">

<<< @/.vitepress/demos/timeline/horizontal.tsx

</Demo>

## 마크업

`<ol>`입니다. 이 컴포넌트가 존재하는 이유가 바로 그것 — 순서가 내용이기 때문입니다. 순서 없는 목록 위에서 "목록, 항목 5개"라고 읽히면 다른 것을 설명하고 있는 셈입니다. `current`인 항목에는 `aria-current="step"`이 붙습니다.

밑에 Base UI 프리미티브는 없고, 있어서도 안 됩니다. 타임라인에는 선택도, 로빙 포커스도, 자기 키보드 계약도 없습니다. 그냥 목록이고, 목록을 그리자고 복합 프리미티브를 가져오면 소비자의 사건 기록에 위젯의 의미론을 씌우게 됩니다. [List](./list)가 같은 이유로 같은 선택을 합니다.

## 이것을 쓸 자리가 아닌 것들

- 되돌아볼 기록이 아니라 **지금 얼마나 진행됐는지**라면 [ProgressLinear](../feedback/progress-linear)입니다.
- 순서가 없는 줄의 나열이라면 [List](./list)입니다. 타임라인의 선은 "그다음"이라는 주장이고, 그 주장이 사실이 아니라면 선을 그리지 말아야 합니다.

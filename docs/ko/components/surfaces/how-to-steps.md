---
title: HowToSteps
order: 15
---

# HowToSteps

<p class="neba-lede">독자가 하나씩 따라가는 안내서입니다. 한쪽에 번호가 매겨진 단계 목록이 있고 그 옆에 지금 단계의 설명이, 그 아래에 다음으로 넘어가는 버튼이 놓입니다. 끝이 있고, 끝났다고 말합니다.</p>

<Demo src="how-to-steps/hero" minHeight="420" />

```tsx
import { HowToSteps } from 'neba';

<HowToSteps
  title="cron으로 작업 예약하기"
  steps={[
    { title: 'crontab 열기', content: 'crontab -e가 $EDITOR로 내 crontab을 엽니다.' },
    { title: '스케줄 작성', content: '다섯 개의 필드, 그다음 명령어.' }
  ]}
/>;
```

## Props

<PropsTable name="HowToSteps" />

`color`, `title`, `content`를 뺀 모든 네이티브 `<div>` 속성이 그대로 전달됩니다. 이 셋은 컴포넌트가 직접 씁니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

### HowToStep

<PropsTable name="HowToStep" />

단계를 children이 아니라 배열로 받습니다. 이 컴포넌트가 다른 방식으로는 만들어질 수 없는 유일한 지점입니다 — 옆의 목록과 본문은 같은 데이터를 두 번 그린 것이고, 본문 영역의 높이는 지금 보이는 단계가 아니라 _모든_ 단계에 맞춰 정해집니다.

## Examples

### orientation

`vertical`이 기본입니다. 번호가 한쪽으로 내려가고 본문이 그 옆에 놓이며, 단계가 몇 개든 각 단계에 할 말이 얼마나 많든 받아냅니다. `sm` 아래에서는 위아래로 쌓입니다. `horizontal`은 번호를 위쪽에 가로로 늘어놓는데, 모든 제목이 짧을 때에만 정직한 배치입니다.

<Demo src="how-to-steps/orientation" minHeight="360">

<<< @/.vitepress/demos/how-to-steps/orientation.tsx

</Demo>

### maxHeight

안에서 스크롤이 시작되기 전까지 안내서가 커질 수 있는 높이입니다. 숫자는 픽셀입니다. 시트가 커지는 대신 목록과 본문이 각자 안에서 스크롤되고, 단계가 바뀌면 현재 행이 보이는 자리로 따라옵니다.

<Demo src="how-to-steps/scrolling" minHeight="400">

<<< @/.vitepress/demos/how-to-steps/scrolling.tsx

</Demo>

### step · completed

두 상태 모두 controlled로 쓸 수 있습니다. 위치를 직접 들고 있으려면 — URL에, 폼 상태에 — `step`과 `onStepChange`를, 마지막 상태에는 `completed`와 `onCompletedChange`를 씁니다.

<Demo src="how-to-steps/controlled" minHeight="380">

<<< @/.vitepress/demos/how-to-steps/controlled.tsx

</Demo>

### navigation · completion

`navigation={false}`는 버튼 줄을 없애고 목록만 남깁니다. 페이지가 자체 내비게이션을 가진 곳에 안내서를 끼워 넣을 때 쓰는 형태입니다. `completion={false}`는 완료 상태 자체를 없앱니다 — 마지막 단계는 그냥 마지막 단계가 됩니다.

<Demo src="how-to-steps/bare" minHeight="480">

<<< @/.vitepress/demos/how-to-steps/bare.tsx

</Demo>

### variant · size · color

세 가지 weight는 어디서나 하는 말을 그대로 합니다. 시트는 `color`로 물들지 않습니다 — 색을 지니는 것은 번호와 연결선과 버튼입니다. 이미 시트인 [Card](./card) 안에서는 `text`가 맞습니다.

### 무엇이든 담기는 단계

`content`는 노드를 받으므로 한 단계 안에 [CodeBlock](../display/code-block)이, `image`로 스크린샷이, 폼이, 다른 컴포넌트가 들어갈 수 있습니다. 본문 영역이 가장 긴 단계의 높이를 유지하기 때문에, 코드 블록이 들어 있는 단계에 도착해도 카드 크기가 바뀌지 않습니다.

## Accessibility

- 목록은 tablist가 아니라 버튼의 목록입니다. 현재 행은 `aria-current="step"`을 지니며, 이것이 각 패널에 순서가 있고 독자가 그 순서대로 도달할 것을 전제한다고 말합니다.
- 각 행은 "Step 3: Use it"처럼 읽힙니다. 원은 장식이고, 제목 옆에 그려진 숫자는 screen reader가 읽어 주는 숫자가 아닙니다.
- 보이지 않는 단계들은 본문 높이를 유지하기 위해 문서에 남아 있으며 `inert`입니다 — tab 순서에서 빠지고, accessibility tree에서 빠지고, 페이지 내 찾기에서도 빠집니다.
- 한 페이지에 안내서가 둘 이상이면 `title`을 주십시오.

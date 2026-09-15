---
title: HowToSteps
order: 15
---

# HowToSteps

<p class="neba-lede">독자가 하나씩 따라가는 안내서입니다. 한쪽에 번호가 매겨진 단계 목록이 있고 그 옆에 지금 단계의 설명이, 그 아래에 다음으로 넘어가는 버튼이 놓입니다. 마지막 단계까지 가면 끝났다는 것을 함께 알립니다.</p>

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

## 예시

### orientation

`vertical`이 기본입니다. 번호가 한쪽으로 내려가고 본문이 그 옆에 놓이며, `sm` 아래에서는 둘이 위아래로 쌓입니다. `horizontal`은 번호를 위쪽에 가로로 늘어놓으며, 제목이 모두 짧은 안내서에 맞습니다.

<Demo src="how-to-steps/orientation" minHeight="360">

<<< @/.vitepress/demos/how-to-steps/orientation.tsx

</Demo>

### maxHeight

안에서 스크롤이 시작되기 전까지 안내서가 커질 수 있는 높이입니다. 숫자는 픽셀입니다. 시트가 커지는 대신 목록과 본문이 각자 안에서 스크롤되고, 단계가 바뀌면 현재 행이 보이는 자리로 따라옵니다.

<Demo src="how-to-steps/scrolling" minHeight="400">

<<< @/.vitepress/demos/how-to-steps/scrolling.tsx

</Demo>

### step · completed

두 상태 모두 controlled로 쓸 수 있습니다. 위치를 직접 들고 있으려면(URL에, 폼 상태에) `step`과 `onStepChange`를, 마지막 상태에는 `completed`와 `onCompletedChange`를 씁니다.

<Demo src="how-to-steps/controlled" minHeight="380">

<<< @/.vitepress/demos/how-to-steps/controlled.tsx

</Demo>

### icon

각 단계는 glyph를 하나 받을 수 있고, 목록이 아니라 그 단계 본문의 제목 앞에 그려집니다. 터미널 작업인지, 파일 작업인지, 경고인지처럼 어떤 종류의 단계인지를 나타낼 때 쓰세요.

```tsx
{ title: 'crontab 열기', icon: <TerminalIcon />, content: … }
```

### divider

목록과 본문 사이의 얇은 선입니다. 둘이 두 열일 때는 안쪽 모서리를 따라, 위아래로 쌓인 뒤에는 목록 아래를 따라 그려집니다. 기본은 켜짐입니다.

<Demo src="how-to-steps/divider" minHeight="320">

<<< @/.vitepress/demos/how-to-steps/divider.tsx

</Demo>

### transition

독자가 어떤 단계로 옮겨갔을 때 그 단계가 등장하는 방식이며, 어디서나 [`transition`](../../design/prop-conventions)이 쓰는 것과 같은 어휘를 씁니다. effect 이름 하나를 주거나, duration과 easing, 방향까지 정하는 객체를 넘길 수 있습니다. `'none'`이면 꺼지고, reduced-motion 설정에서도 꺼집니다.

효과는 패널에서만 실행되고, 버튼과 목록 행은 움직이지 않습니다.

<Demo src="how-to-steps/transition" minHeight="340">

<<< @/.vitepress/demos/how-to-steps/transition.tsx

</Demo>

### navigation · completion

`navigation={false}`는 버튼 줄을 없애고 목록만 남깁니다. 페이지가 자체 내비게이션을 가진 곳에 안내서를 끼워 넣을 때 쓰는 형태입니다. `completion={false}`는 완료 상태 자체를 없앱니다. 마지막 단계는 그냥 마지막 단계가 됩니다.

<Demo src="how-to-steps/bare" minHeight="480">

<<< @/.vitepress/demos/how-to-steps/bare.tsx

</Demo>

### variant · size · color

세 가지 weight는 어디서나 하는 말을 그대로 합니다. `color`는 시트를 물들이지 않고 번호와 연결선, 버튼에 입혀집니다. 이미 시트인 [Card](./card) 안에서는 `text`를 쓰세요.

### headingLevel

`title`은 기본적으로 `<h3>`으로, 각 단계의 제목은 그보다 한 단계 아래인 `<h4>`로 그려집니다. 페이지에 맞춰 그 시작점을 옮기려면 `headingLevel`을 쓰세요. `<h1>` 바로 아래의 안내서라면 `2`, 섹션 안의 안내서라면 `4`입니다.

```tsx
<HowToSteps steps={steps} title="시작하기" headingLevel={2} />
```

### content

`content`는 노드를 받으므로 한 단계 안에 [CodeBlock](../display/code-block)이, `image`로 스크린샷이, 폼이, 다른 컴포넌트가 들어갈 수 있습니다. 본문 영역이 가장 긴 단계의 높이를 유지하므로 코드 블록이 들어 있는 단계에 도착해도 카드 크기가 바뀌지 않습니다. 단계가 바뀔 때 아무것도 다시 mount되지 않으므로 안내서 중간의 폼은 입력해 둔 내용을 그대로 들고 있습니다.

## 접근성

- 목록은 tablist가 아니라 버튼의 목록이며, 현재 행은 `aria-current="step"`을 지닙니다.
- 각 행은 "Step 3: Use it"처럼 읽히고, 번호가 든 원은 장식입니다. `title`이 노드인 행은 자기 내용 그대로 읽힙니다.
- 다른 단계로 넘어가면 polite live region이 "Step 2: Configure"처럼 알립니다. 본문이 제자리에서 바뀌고 focus는 누른 버튼에 머물기 때문입니다.
- 보이지 않는 단계들은 본문 높이를 유지하기 위해 문서에 남아 있으며 `inert`입니다. tab 순서에서 빠지고, accessibility tree에서 빠지고, 페이지 내 찾기에서도 빠집니다.
- 한 페이지에 안내서가 둘 이상이면 `title`을 주세요. `title`이 있으면 안내서는 그 제목으로 이름이 붙은 `role="group"`이 됩니다.

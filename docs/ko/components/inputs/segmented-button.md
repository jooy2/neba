---
title: SegmentedButton
order: 19
---

# SegmentedButton

<p class="neba-lede">한 알약 안에 든 두 개 이상의 선택지, 그중 정확히 하나가 골라집니다.</p>

<Demo src="segmented-button/hero" />

```tsx
import { Segment, SegmentedButton } from 'neba';

<SegmentedButton aria-label="기간" defaultValue="week">
  <Segment value="day">일</Segment>
  <Segment value="week">주</Segment>
  <Segment value="month">월</Segment>
</SegmentedButton>;
```

## Props

<PropsTable name="SegmentedButton" />

### Segment

<PropsTable name="Segment" />

## 밑에 있는 것은 라디오 그룹입니다

접근성 논거 전부가 여기에 있습니다. 분절 버튼은 **"이것들 중 정확히 하나"** 그 자체이므로 `role="radiogroup"`을 받고, 집합 전체가 탭 정지 하나이며, 그 안은 화살표 키로 이동하고, 골라진 하나에 `aria-checked`가 붙습니다.

`aria-pressed` 토글을 줄지어 놓아 만들었다면 — 버튼 한 줄이 주는 것이 그것입니다 — 서로 무관한 스위치 네 개가 있고 그중 셋이 꺼져 있다고 읽혔을 것입니다.

집합에는 이름이 있어야 합니다. `aria-label`이나 `aria-labelledby`를 넘기세요. 눈에 보이는 라벨이 필요하다면 그것은 아마 [RadioGroup](./radio-group)이 맞습니다.

## 타일은 움직이는데 아무것도 변형되지 않습니다

타일이 미끄러지는 것은 골라진 세그먼트에서 잰 `left` · `top` · `width` · `height`를 애니메이션하기 때문입니다. `transform`은 쓰지 않습니다. 타일은 **빈 상자**이므로, 움직이는 동안 다시 그려지는 글자가 하나도 없습니다.

[Tabs](../surfaces/tabs)의 인디케이터가 긋는 것과 같은 구분이고, 무언가 움직이는 것이 존재 이유인 컴포넌트에서도 [변형 금지 규칙](../../guide/design-language)이 살아남는 이유입니다. 규칙이 막는 것은 움직임이 아니라 **라벨이 움직이는 것**입니다.

첫 배치는 애니메이션되지 않습니다. 방금 마운트된 타일에는 출발할 자리가 없기 때문입니다. 창 크기가 바뀔 때도 마찬가지입니다 — 그때 움직이는 것은 이미 제자리에 있던 타일 밑의 컨테이너이고, 그것을 애니메이션하면 창을 끄는 동안 타일이 뒤처집니다.

## 예시

### 무게

`solid`는 서리 낀 홈통에 채워진 타일이 타고 다니고, `outline`은 같은 홈통에 얇은 선을 두르고 타일 대신 시트를 밝힙니다. `text`는 홈통을 아예 없애고, 골라진 것에만 표면이 생깁니다.

<Demo src="segmented-button/variants">

<<< @/.vitepress/demos/segmented-button/variants.tsx

</Demo>

### 크기

세그먼트는 [Button](./button)과 같은 컨트롤 사다리 위에 있습니다. `md` 세그먼트와 `md` 버튼은 같은 32px이고, 그래서 툴바에 나란히 놓아도 줄의 기준선이 흐트러지지 않습니다.

<Demo src="segmented-button/sizes">

<<< @/.vitepress/demos/segmented-button/sizes.tsx

</Demo>

### 아이콘과 상태

<Demo src="segmented-button/states">

<<< @/.vitepress/demos/segmented-button/states.tsx

</Demo>

`readOnly`는 무엇이 골라졌는지 보여 주되 바꾸지는 못하게 하고 채도만 뺍니다. `disabled`는 색 계열을 통째로 버립니다. 라이브러리 어디서나 같은 두 축입니다.

## 알약 모양

[Pill](../surfaces/pill) 말고 라이브러리에서 완전히 둥근 유일한 모양이고, 이유도 같습니다. [반경 규칙](../../guide/design-language)은 모든 컨트롤을 알약이 되는 50% 직전에서 멈춰 세웁니다. 위아래 가장자리에 남는 평평한 구간이 "모서리를 잘라낸 시트"로 읽히게 하는 부분이기 때문입니다. 하지만 세그먼트는 페이지 위에 놓인 시트가 아니라, 시트에 파인 홈에 **타고 있는** 타일입니다.

## 이것을 쓸 자리가 아닌 것들

- 선택이 아니라 **액션**의 줄이라면 [ButtonGroup](./button-group)입니다. 저쪽은 선택을 관리하지 않습니다.
- 선택지가 다섯 개를 넘거나 라벨이 길어진다면 [Select](./select)입니다. 홈통은 늘어나지만 읽히지는 않습니다.
- 밑에 패널이 딸린다면 그것은 분절 버튼이 아니라 [Tabs](../surfaces/tabs)입니다 — `variant="solid"`가 정확히 이 모양입니다.

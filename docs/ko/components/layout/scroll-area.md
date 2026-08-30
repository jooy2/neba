---
title: ScrollArea
order: 10
---

# ScrollArea

<p class="neba-lede">자기 스크롤바를 가진 상자입니다. 브라우저의 스크롤바는 운영체제가 그리므로 기기마다 두께가 다르고, 자기가 파인 시트와 색도 다릅니다. 이쪽은 요소이므로 어디서나 같고 라이브러리의 토큰으로 만들어집니다.</p>

<Demo src="scroll-area/hero" />

```tsx
import { ScrollArea } from 'neba';

<ScrollArea height={200} fade>
  …
</ScrollArea>;
```

## Props

<PropsTable name="ScrollArea" />

`<div>`의 기본 속성은 `color`를 제외하고 루트로 전달됩니다. 내부는 평범한 스크롤 컨테이너라 휠, 트랙패드, 관성, 키보드는 모두 브라우저의 것 그대로입니다.

[ScrollZone](./scroll-zone)과는 다릅니다. 그쪽은 *레일*입니다 — 한 방향으로 늘어선 항목들과 그것을 넘기는 버튼, 카드 줄이나 칩 줄을 위한 것입니다. 이쪽은 평범한 경우입니다: 안에 든 것에 비해 작은 상자.

## 예시

### height · maxHeight

세로 스크롤 영역은 무언가로 높이가 묶여야 스크롤할 것이 생깁니다. `height`는 고정 높이, `maxHeight`는 상한이며 둘 다 px 숫자나 임의의 CSS 길이를 받습니다. 가로 영역은 이미 컨테이너 너비에 묶여 있습니다.

### orientation

기본값은 `vertical`입니다. `horizontal`은 아래쪽에 레일을 그리고, `both`는 둘 다와 그 사이의 모서리까지 그립니다.

<Demo src="scroll-area/orientation">

<<< @/.vitepress/demos/scroll-area/orientation.tsx

</Demo>

### fade

내용이 더 남아 있는 가장자리에서만 내용을 서서히 지웁니다. 맨 위에 있을 때 위쪽에는 fade가 없다는 뜻입니다. 내용 위에 덧칠한 그러데이션이 아니라 mask로 그리기 때문에 반투명한 표면 위에서도 성립합니다.

<Demo src="scroll-area/fade">

<<< @/.vitepress/demos/scroll-area/fade.tsx

</Demo>

### size · color

`size`는 레일의 두께입니다. 스크롤바는 컨트롤이 아니라 레일이므로 컨트롤 높이보다 훨씬 아래에 있는 자기만의 사다리를 씁니다. `color`는 thumb이 띠는 색 계열이며, 글 옆에서 두 번째 단처럼 보이지 않도록 낮춰 섞습니다.

<Demo src="scroll-area/sizes">

<<< @/.vitepress/demos/scroll-area/sizes.tsx

</Demo>

## 접근성

- viewport에 focus가 가며 방향키, Page Up/Down, Home, End로 스크롤됩니다.
- 스크롤바는 포인터가 영역 위에 있거나 스크롤 중일 때 나타납니다. 어느 경우에도 내용은 스크롤바 없이 도달할 수 있습니다.

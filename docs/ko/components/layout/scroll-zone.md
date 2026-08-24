---
title: ScrollZone
order: 5
---

# ScrollZone

<p class="neba-lede">무엇이든 한 방향으로 늘어놓고 그 방향으로 스크롤하는 스트립입니다. 카드나 chip, 아바타, 썸네일이 상자를 가로지르거나 아래로 흐르며, 원하는 만큼의 줄로 놓이고, 휠도 손가락도 없는 포인터를 위한 버튼 한 쌍이 붙습니다.</p>

<Demo src="scroll-zone/hero" minHeight="220" />

```tsx
import { ScrollZone } from 'neba';

<ScrollZone label="Continue watching" spacing={3}>
  {shows.map((show) => (
    <Card key={show.name} className="w-40" title={show.name} />
  ))}
</ScrollZone>;
```

## Props

<PropsTable name="ScrollZone" />

나머지 `<div>` 속성은 그대로 루트에 전달됩니다. 공용 축(`variant` `size` `color` `density` `orientation`)은 [prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### orientation과 lines

`orientation`은 스트립이 흐르는 방향, 곧 스크롤되는 방향을 정합니다. `lines`는 가로 zone이 새 열로 넘어가기 전까지 채우는 줄 수입니다 — 두 줄이면 같은 너비에 두 배가 들어가고, 스크롤은 여전히 하나입니다.

`spacing`은 자식 사이의 간격이며, [GridContainer](./grid)와 같은 스케일입니다. `2`는 `0.5rem`입니다.

<Demo src="scroll-zone/lines" minHeight="220">

<<< @/.vitepress/demos/scroll-zone/lines.tsx

</Demo>

### mode

버튼을 눌렀을 때 하는 일입니다. `item`은 다음 자식으로 이동하며 `step`이 한 번에 몇 개인지를 정하고, `page`는 지금 화면에 보이는 만큼 움직이며, `hold`는 누르고 있는 동안 초당 `speed` 픽셀로 계속 스크롤합니다. hold라 하기엔 너무 짧은 누름은 item 한 칸으로 처리되므로, 짧게 눌러도 아무 일이 없는 버튼은 없습니다.

<Demo src="scroll-zone/modes" minHeight="360">

<<< @/.vitepress/demos/scroll-zone/modes.tsx

</Demo>

### buttons

기본값 `auto`는 갈 곳이 있는 버튼만 그리고, 전부 들어맞을 때에는 둘 다 그리지 않습니다. `always`는 첫 페인트부터 둘 다 그리고 갈 곳이 없는 쪽을 disabled로 둡니다 — 내용이 나중에 도착하는 스트립이 원하는 쪽입니다. `none`은 아무것도 그리지 않고 휠과 방향키, 드래그에 맡깁니다.

`snap`은 어떻게 스크롤했든 멈추는 순간 가장 가까운 자식을 시작 가장자리에 맞춥니다.

<Demo src="scroll-zone/buttons" minHeight="260">

<<< @/.vitepress/demos/scroll-zone/buttons.tsx

</Demo>

### buttonPlacement

기본값 `overlay`는 버튼을 스트립의 양 끝 위에 겹칩니다. 상자의 모든 픽셀이 내용의 것이 되고, 항목은 버튼 밑을 지나갑니다. `inline`은 버튼을 옆에 세웁니다. 스크롤 영역이 버튼 앞에서 끝나므로 항목은 버튼 밑으로 숨는 대신 그 가장자리에서 **잘리고**, 버튼은 무엇 위에 얹혔든 상관없이 페이지 위에서 또렷하게 읽힙니다.

inline 버튼은 갈 곳이 없을 때에도 자기 자리를 지킵니다. 그러지 않으면 끝에 막 닿은 포인터 아래에서 스트립이 크기를 바꾸게 됩니다.

<Demo src="scroll-zone/placement" minHeight="280">

<<< @/.vitepress/demos/scroll-zone/placement.tsx

</Demo>

### 아래로 흐르게 하기

세로 zone은 스크롤할 높이가 있어야 하고, 그 높이를 컴포넌트에서 받습니다. 루트가 flex 컬럼이고 스크롤 박스가 그것을 채우므로, 높이가 있는 상자 안에서 `className="h-full"` 하나면 충분합니다.

<Demo src="scroll-zone/vertical" minHeight="260">

<<< @/.vitepress/demos/scroll-zone/vertical.tsx

</Demo>

### drag

손가락은 이미 스트립을 스크롤합니다. 밑에 있는 것이 평범한 스크롤 컨테이너이고, 터치 스크롤은 브라우저 자신의 것이기 때문입니다 — 관성과 러버밴딩, 그리고 어떤 핸들러도 재현하지 못하는 스크롤바가 함께 옵니다. `drag`는 같은 제스처를 마우스와 펜에도 붙이며, 진짜로 끌었을 때 뒤따르는 click은 삼켜집니다. 카드 위를 지나 스트립을 당겨도 그 카드가 열리지 않습니다.

```tsx
<ScrollZone drag={false} scrollbar>
  {items}
</ScrollZone>
```

## 접근성

- 스트립은 포커스를 받고 방향키로 스크롤됩니다. 브라우저 자신의 키 처리이므로 RTL에서도 이미 올바릅니다.
- `label`이 영역의 이름이며 스크린 리더가 내용보다 먼저 읽습니다. 없으면 포커스는 받되 이름이 없는 상태가 됩니다.
- 스크롤 버튼은 이름을 가진 진짜 버튼입니다. `previousLabel` / `nextLabel`, 또는 `locale`이 그 이름을 정합니다.
- `hold` 모드에서 버튼은 Enter와 Space에도 같은 방식으로 답하며, 키를 누르고 있는 동안 스크롤합니다.
- 화면 밖으로 나간 것에는 `aria-hidden`을 붙이지 않습니다. 스크롤하면 실제로 닿을 수 있는 것이고, 키보드 사용자가 그 안으로 들어갈 수 있기 때문입니다.

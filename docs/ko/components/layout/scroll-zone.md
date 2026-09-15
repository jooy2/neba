---
title: ScrollZone
order: 9
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

나머지 `<div>` 속성과 `ref`는 그대로 루트에 전달됩니다. `scrollerRef`와 `onScroll`은 그 안에서 스크롤되는 상자에 붙습니다. 공용 축(`variant` `size` `color` `density` `orientation`)은 [prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### orientation과 lines

`orientation`은 스트립이 흐르는 방향, 곧 스크롤되는 방향을 정합니다. `lines`는 가로 zone이 새 열로 넘어가기 전까지 채우는 줄 수입니다. 두 줄이면 같은 너비에 두 배가 들어가고, 스크롤은 여전히 하나입니다.

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

기본값 `auto`는 전부 들어맞을 때에는 둘 다 그리지 않습니다. 끝에 닿으면 갈 곳이 없는 overlay 버튼은 지우고, inline 버튼은 그 자리에 `disabled`로 남깁니다. `always`는 전부 들어맞는 동안에도 첫 페인트부터 둘 다 그리므로, 내용이 나중에 도착하는 스트립에 맞습니다. `none`은 아무것도 그리지 않고 드래그와 방향키, 포인터가 이미 밀 수 있는 것에 맡깁니다.

`snap`은 어떻게 스크롤했든 멈추는 순간 가장 가까운 자식을 시작 가장자리에 맞춥니다.

<Demo src="scroll-zone/buttons" minHeight="260">

<<< @/.vitepress/demos/scroll-zone/buttons.tsx

</Demo>

### buttonPlacement

기본값 `inline`은 버튼을 스트립 옆에 세웁니다. 스크롤 영역이 버튼 앞에서 끝나므로 항목은 버튼 밑으로 숨는 대신 그 가장자리에서 **잘립니다**. `overlay`는 버튼을 스트립의 양 끝 위에 겹칩니다. 상자의 모든 픽셀이 내용의 것이 되고, 항목은 버튼 밑을 지나갑니다.

inline 버튼은 갈 곳이 없을 때에도 자기 자리를 지키므로, 끝에 닿아도 스트립의 너비가 바뀌지 않습니다.

<Demo src="scroll-zone/placement" minHeight="280">

<<< @/.vitepress/demos/scroll-zone/placement.tsx

</Demo>

### 아래로 흐르게 하기

세로 zone은 스크롤할 높이가 있어야 하고, 그 높이를 컴포넌트에서 받습니다. 루트가 flex 컬럼이고 스크롤 박스가 그것을 채우므로, 높이가 있는 상자 안에서 `className="h-full"` 하나면 충분합니다.

<Demo src="scroll-zone/vertical" minHeight="260">

<<< @/.vitepress/demos/scroll-zone/vertical.tsx

</Demo>

### drag

손가락은 이미 스트립을 스크롤합니다. `drag`는 같은 제스처를 마우스와 펜에도 붙이며, 진짜로 끌었을 때 뒤따르는 click은 삼켜지므로 카드 위를 지나 스트립을 당겨도 그 카드가 열리지 않습니다.

```tsx
<ScrollZone drag={false} scrollbar>
  {items}
</ScrollZone>
```

### wheel

`wheel`은 가로 스트립 위에서 굴린 마우스 휠을 스트립을 따라가는 이동으로 바꿉니다. 기본값은 꺼짐이며, 세로 zone은 이 prop을 무시합니다.

넘치는 스트립 위에 포인터가 있는 동안 휠은 양 끝에서도 스트립만 움직이고, 포인터가 스트립 밖으로 나가면 페이지가 휠을 되찾습니다. 옆으로 미는 트랙패드는 이미 스트립을 스크롤하므로 그대로 둡니다.

<Demo src="scroll-zone/wheel" minHeight="280">

<<< @/.vitepress/demos/scroll-zone/wheel.tsx

</Demo>

## 접근성

- 스트립은 포커스를 받고 방향키로 스크롤됩니다. 브라우저 자신의 키 처리이므로 RTL에서도 이미 올바릅니다.
- `label`이 영역의 이름이며 스크린 리더가 내용보다 먼저 읽습니다. 없으면 locale의 일반 명사가 이름이 되므로 이름이 비지는 않지만, 무엇이 들었는지는 `label`만 말할 수 있습니다.
- 스크롤 버튼은 이름을 가진 진짜 버튼입니다. `previousLabel` / `nextLabel`, 또는 `locale`이 그 이름을 정합니다.
- `hold` 모드에서 버튼은 Enter와 Space에도 같은 방식으로 답하며, 키를 누르고 있는 동안 스크롤합니다.
- 갈 곳이 없는 버튼은 `disabled` 대신 `aria-disabled`로 표시되므로, 끝에 닿게 한 누름 뒤에도 포커스가 버튼에 남습니다. `auto`가 지울 overlay 버튼은 포커스가 떠날 때까지 남아 있습니다.
- 화면 밖으로 나간 항목도 보조 기술에서 숨기지 않습니다. 스크롤하면 닿을 수 있기 때문입니다.

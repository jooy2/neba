---
title: Card
order: 2
---

# Card

<p class="neba-lede">제목·부제목·본문·푸터가 배치된 Box입니다. Box의 prop은 전부 그대로 통과하므로, 카드는 자신이 곧 박스인 것과 같은 축으로 스타일링됩니다.</p>

<Demo src="card/hero" />

```tsx
import { Card } from 'neba';

<Card title="Starter" subtitle="프로젝트 하나" footer={<Button>선택</Button>}>
  본문
</Card>;
```

## Props

<PropsTable name="Card" />

[Box](./box)의 prop을 모두 받습니다. `padded`만 예외로, 카드가 섹션별로 여백을 다시 배분하기 때문에 제외되어 있습니다.

## 예시

### 섹션

섹션은 `<Card.Header>` 같은 합성 컴포넌트가 아니라 prop입니다. 배치는 이미 정해져 있고, 호출하는 쪽이 정하고 싶은 것은 순서가 아니라 각 자리에 무엇이 들어가는가이기 때문입니다. 넘기지 않은 슬롯은 렌더링되지 않습니다.

<Demo src="card/sections">

<<< @/.vitepress/demos/card/sections.tsx

</Demo>

### 구분선

`dividers`를 켜면 섹션 사이가 공백 대신 하이라인으로 나뉩니다. 선이 시트의 양 끝까지 닿아야 하므로, 여백이 카드에서 각 섹션으로 옮겨 갑니다.

<Demo src="card/dividers">

<<< @/.vitepress/demos/card/dividers.tsx

</Demo>

### 크기

`size`는 시트의 반경과 여백, 그리고 헤더와 본문의 타입 스케일을 함께 정합니다. 제목은 본문보다 한 단계 위, 부제목은 한 단계 아래입니다.

<Demo src="card/sizes">

<<< @/.vitepress/demos/card/sizes.tsx

</Demo>

### 컨트롤을 담기

카드는 박스이므로, 담긴 컨트롤은 유리 위에 놓입니다. 제목을 문서 개요에 넣어야 한다면 실제 heading을 넘기세요 — `title={<h2>…</h2>}`. 넘긴 heading은 브라우저 기본 크기 대신 카드의 타입 스케일을 물려받습니다.

<Demo src="card/form">

<<< @/.vitepress/demos/card/form.tsx

</Demo>

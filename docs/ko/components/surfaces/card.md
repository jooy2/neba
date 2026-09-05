---
title: Card
order: 2
---

# Card

<p class="neba-lede">제목과 부제목, 본문, 푸터 자리가 배치된 Box입니다. 같은 형태의 내용을 반복해서 보여 줄 때 씁니다.</p>

<Demo src="card/hero" />

```tsx
import { Card } from 'neba';

<Card title="Starter" subtitle="프로젝트 하나" footer={<Button>선택</Button>}>
  본문
</Card>;
```

## Props

<PropsTable name="Card" />

[Box](./box)의 prop을 모두 받습니다. `padded`만 예외로, Card가 섹션별로 여백을 다시 배분하기 때문에 제외됩니다.

## 예시

### title · subtitle · headerAction · footer

섹션은 서브컴포넌트가 아니라 prop입니다. 넘기지 않은 slot은 렌더링되지 않습니다. `headerAction`은 제목 줄 오른쪽 끝의 컨트롤 자리입니다.

<Demo src="card/sections">

<<< @/.vitepress/demos/card/sections.tsx

</Demo>

### dividers

섹션 사이를 공백 대신 선으로 나눕니다. 선이 sheet 양끝까지 닿아야 하므로 여백이 Card에서 각 섹션으로 옮겨 갑니다.

<Demo src="card/dividers">

<<< @/.vitepress/demos/card/dividers.tsx

</Demo>

### size

sheet의 반경과 여백, 그리고 헤더와 본문의 타입 스케일을 함께 정합니다. 제목은 본문보다 한 단계 위, 부제목은 한 단계 아래입니다.

<Demo src="card/sizes">

<<< @/.vitepress/demos/card/sizes.tsx

</Demo>

### 컨트롤 담기

`title`에 `title={<h2>…</h2>}`처럼 실제 heading을 넘기면 문서 개요에 들어갑니다. 넘긴 heading은 브라우저 기본 크기 대신 Card의 타입 스케일을 물려받습니다.

<Demo src="card/form">

<<< @/.vitepress/demos/card/form.tsx

</Demo>

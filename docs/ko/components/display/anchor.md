---
title: Anchor
order: 21
---

# Anchor

<p class="neba-lede">지금 읽고 있는 페이지의 제목 목록이고, 독자가 있는 위치가 표시됩니다. 진짜 fragment 링크라서 추적이 동작하든 말든 해당 제목으로 이동합니다.</p>

<Demo src="anchor/hero" />

```tsx
import { Anchor } from 'neba';

<Anchor
  items={[
    { href: '#install', label: 'Install' },
    { href: '#setup', label: 'Setup', depth: 1 }
  ]}
/>;
```

## Props

<PropsTable name="Anchor" />

`<nav>`의 모든 속성이 `color`와 `children`을 제외하고 그대로 전달됩니다.

### AnchorItem

<PropsTable name="AnchorItem" />

제목은 문서에서 긁어오는 대신 직접 전달합니다. 이 목록을 만들어내는 쪽 — MDX 파이프라인, CMS, 라우트의 frontmatter — 은 이미 id를 알고 있고, 컴포넌트가 직접 찾아 나선다면 어느 제목이 본문이고 어느 것이 chrome인지 추측해야 합니다.

## 예시

### activeHref와 onActiveChange

그냥 두면 목록이 스크롤을 추적합니다. 표시되는 행은 상단선을 지나간 마지막 제목이며, 이 규칙은 아래로 내려갈 때만큼 위로 올라갈 때도 올바르게 읽힙니다. 스크롤이 맨 아래에 닿으면 마지막 제목이 표시됩니다. `activeHref`를 주면 추적을 멈추고 지시받은 대로 표시합니다.

첫 제목에 닿기 전, 즉 독자가 아직 그 위에 있는 동안에는 아무것도 표시되지 않습니다.

### offset

scrollport 상단에서 얼마나 내려온 지점을 "제목에 도달했다"고 볼지 정합니다. sticky header의 높이를 넣으세요. 그러지 않으면 바에 가려진 제목이 표시되는 일이 없습니다.

### container

문서가 아닌 다른 것이 스크롤될 때 그 요소입니다. 예를 들어 `scroll="content"`인 [PageLayout](../layout/page-layout)이 페이지를 담는 요소입니다.

### rail

앞쪽 가장자리를 따라 내려가는 선이고, 현재 행에 불이 들어옵니다. 이동하는 마커가 아니라 행의 border입니다. 이미 움직이고 있는 독자 아래에서 무언가가 미끄러지지 않게 하기 위해서입니다.

<Demo src="anchor/rail">

<<< @/.vitepress/demos/anchor/rail.tsx

</Demo>

### size

<Demo src="anchor/sizes">

<<< @/.vitepress/demos/anchor/sizes.tsx

</Demo>

## 접근성

- 진짜 `<a href="#…">`로 이루어진 진짜 `<nav>`입니다. JavaScript가 꺼져 있어도 동작하고, 스크린 리더가 불러오는 링크 목록에 들어갑니다. 추적은 그 위에 얹힌 것이지 없으면 안 되는 부분이 아닙니다.
- 표시된 행에는 `aria-current="location"`이 붙습니다. 링크 묶음 안에서 독자가 있는 위치를 뜻하는 값입니다.
- `<nav>`의 이름은 `locale`이나 `label`에서 옵니다.
- `id`가 없는 제목은 추적할 수 없고, 그 행은 아무 데도 가지 않는 링크가 됩니다.

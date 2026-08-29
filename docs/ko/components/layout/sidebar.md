---
title: Sidebar
order: 4
---

# Sidebar

<p class="neba-lede">페이지 내용 옆의 열이며, 창이 좁아져 열을 담을 수 없게 되면 drawer가 됩니다. 실제 <code>&lt;aside&gt;</code>를 렌더링하며 이는 complementary 랜드마크입니다.</p>

<Demo src="sidebar/hero" minHeight="300" />

```tsx
import { List, ListItem, Sidebar } from 'neba';

<Sidebar label="목차">
  <List variant="text">
    <ListItem href="/overview" selected>개요</ListItem>
    <ListItem href="/components">컴포넌트</ListItem>
  </List>
</Sidebar>;
```

## Props

<PropsTable name="Sidebar" />

`<aside>`의 native 속성은 그대로 전달됩니다. 다만 `color`와 `title`은 예외입니다. 공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

자기 children만 배치합니다. 페이지가 사이드바를 _둘러싸도록_ 하려면 [PageLayout](./page-layout)의 `sidebar`나 `endSidebar` 자리에 넣으세요.

## 예시

### width · size

`size`가 열의 기본 너비를 정하고 — `md`는 16rem — `width`가 픽셀 숫자나 CSS 길이로 그것을 덮어씁니다.

### resizable

안쪽 가장자리를 끌 수 있게 합니다. `minWidth`와 `maxWidth`가 범위를 정하고, `onResize`는 끄는 동안 매 걸음, `onResizeEnd`는 놓을 때 한 번 호출됩니다 — 너비를 저장해 둘 자리입니다. 핸들은 focus를 받는 `role="separator"`라 좌우 화살표로도 같은 일을 할 수 있습니다.

<Demo src="sidebar/resizable" minHeight="300">

<<< @/.vitepress/demos/sidebar/resizable.tsx

</Demo>

### side

왼쪽·오른쪽이 아니라 `start`와 `end`입니다. 탐색 레일은 어떤 쓰기 방향에서도 자기가 속한 본문 옆에 있기 때문입니다. [PageLayout](./page-layout) 안에서는 어느 자리에 넣었는지가 정해 주므로 이 prop이 필요 없습니다.

<Demo src="sidebar/sides" minHeight="300">

<<< @/.vitepress/demos/sidebar/sides.tsx

</Demo>

### collapseBelow

열이 scrim 위의 [Drawer](../feedback/dialog)가 되는 너비입니다. focus가 안에 갇히고, Escape로 닫히며, 닫으면 focus가 trigger로 돌아갑니다. 어느 모습이든 children은 문서에 한 번만 존재합니다. `title`은 drawer일 때만 그려집니다 — 열에는 주위의 페이지가 그것이 무엇인지 말해 주지만, 페이지를 덮은 패널에는 없기 때문입니다.

기본값은 PageLayout의 값이며 레이아웃 밖에서는 `none`입니다. 되돌릴 방법이 없는 채로 접힌 사이드바는 독자가 잃어버린 사이드바이기 때문입니다.

### sticky

기본값은 켜짐입니다. 페이지가 스크롤될 때는 header 아래에서 시작해 남은 창 높이만큼인 sticky 열이 되고, 내용만 스크롤될 때는 이미 레이아웃 높이만큼이라 아무것도 달라지지 않습니다.

## SidebarTrigger

창이 좁아져 담을 수 없게 된 사이드바를 다시 불러오는 버튼입니다. [Header](./header)의 `brand` 자리, 로고 앞에 두세요.

```tsx
import { Header, PageLayout, Sidebar, SidebarTrigger } from 'neba';

<PageLayout header={<Header brand={<SidebarTrigger />} />} sidebar={<Sidebar>…</Sidebar>}>
  페이지
</PageLayout>;
```

<PropsTable name="SidebarTrigger" />

[IconButton](../inputs/icon-button)이 받는 나머지 prop은 그대로 전달됩니다. 열 대상이 있으려면 PageLayout 안에 있어야 하며, 밖에서는 아무것도 그리지 않습니다. breakpoint 이상에서는 없어지는 대신 class로 숨겨지므로, 페이지가 도착하고 잠시 뒤에 header 안으로 튀어나오는 일이 없습니다.

## 접근성

- `<aside>` — `complementary` 랜드마크 — 를 렌더링하고, `label`이 없으면 `locale`의 “사이드바”에 해당하는 단어로 스스로를 이름 짓습니다. 사이드바가 둘인 페이지는 반드시 둘 다 이름을 주어야 합니다.
- 접힌 상태는 modal dialog입니다. focus가 안에 갇히고, Escape로 닫히며, focus는 trigger로 돌아갑니다.
- 크기 조절 핸들은 `tabindex="0"`인 `role="separator"`이며 `locale`이 이름을 붙입니다. 좌우 화살표가 16px씩 움직입니다.
- `locale`은 PageLayout에서 물려받으므로 페이지당 한 번만 씁니다.

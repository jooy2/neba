---
title: Tabs
order: 4
---

# Tabs

<p class="neba-lede">한 번에 하나만 보이는 패널들. 가로로도, 세로로도 놓입니다.</p>

<Demo src="tabs/hero" />

```tsx
import { Tab, TabPanel, Tabs } from 'neba';

<Tabs defaultValue="overview">
  <Tab value="overview">개요</Tab>
  <Tab value="usage">사용량</Tab>

  <TabPanel value="overview">오늘 배포 세 번, 전부 성공.</TabPanel>
  <TabPanel value="usage">빌드 1,284분 사용.</TabPanel>
</Tabs>;
```

`<TabList>` 같은 래퍼는 없습니다. 태그 사이에 쓴 것은 탭이거나 패널이고, 둘은 서로 다른 상자로 들어가야 하므로 컴포넌트가 알아서 나눕니다 — 기억해야 할 래퍼를 하나 만드는 대신에.

## Props

### Tabs

<PropsTable name="Tabs" />

### Tab

<PropsTable name="Tab" />

### TabPanel

<PropsTable name="TabPanel" />

## 예시

### Variant

`variant`는 여기서 패널이 아니라 탭 **바**의 무게입니다.

- `solid` — 분절 컨트롤. 바는 서리 낀 홈통이고, 표시자는 탭 사이를 미끄러지는 채워진 타일입니다.
- `outline` — 고전적인 형태. 바 가장자리의 선 위에 표시자가 올라탑니다.
- `text` — 같은 바에서 선을 뺀 것. 이미 자기 가장자리를 가진 [Card](./card) 안의 탭을 위한 것입니다.

<Demo src="tabs/variants">

<<< @/.vitepress/demos/tabs/variants.tsx

</Demo>

### 방향

세로 바는 가로 바를 돌려놓은 것이 아닙니다. Base UI가 화살표 키도 함께 다른 축으로 옮겨 주는데, 그것이 세로 탭 바를 애초에 닿을 수 있게 만드는 부분입니다.

<Demo src="tabs/orientation">

<<< @/.vitepress/demos/tabs/orientation.tsx

</Demo>

### 아이콘과 개수

<Demo src="tabs/icons">

<<< @/.vitepress/demos/tabs/icons.tsx

</Demo>

## 표시자는 상자를 움직입니다

Base UI가 선택된 탭의 위치와 크기를 재서 `--active-tab-left`, `--active-tab-width` 같은 슬롯에 써 줍니다. 표시자는 그 값으로 `left`/`top`과 `width`/`height`를 애니메이션합니다.

이것은 빈 상자의 레이아웃 애니메이션이지 라벨의 transform이 아닙니다 — 글자가 든 것은 아무것도 움직이지 않고, 그것이 [무-transform 규칙](../../guide/design-language)이 실제로 긋는 선입니다.

라이브러리에서 유일하게 논리 속성 대신 물리 속성(`left`)을 일부러 쓰는 곳이기도 합니다. `--active-tab-left`는 **측정값**입니다 — 리스트의 왼쪽 가장자리에서 선택된 탭까지의 픽셀 거리이고, RTL에서도 여전히 왼쪽으로부터의 거리입니다. 물리적 측정값을 논리 속성에 물리는 것이야말로 방향을 깨뜨리는 일이지 고치는 일이 아닙니다. 선이 놓이는 가장자리는 논리 속성입니다 — 그쪽은 실제로 뒤집히니까요.

## `activateOnFocus`가 기본으로 꺼져 있는 이유

자동 활성화는 모든 패널이 이미 페이지에 있을 때만 친절합니다. 패널 하나가 데이터를 받아 오는 순간, 화살표로 탭 넷을 지나가는 것은 요청 네 번이 됩니다.

## 탭은 컨트롤 사다리를 씁니다

`md` 탭과 `md` [Button](../inputs/button)은 같은 32px입니다. 그래야 탭 바를 툴바 안에 버튼 옆으로 놓아도 줄이 흐트러지지 않습니다.

## 접근성

Base UI가 탭 바를 버튼 한 줄이 아니라 탭 바로 만드는 것 전부를 소유합니다: 바 전체가 탭 스톱 하나가 되는 roving focus, 바가 흐르는 축의 화살표 키, Home과 End, `tab` / `tabpanel` 역할과 그 사이의 `aria-controls` 배선, 그리고 표시자를 선택된 탭 아래에 놓는 측정.

패널 안에 포커스 받을 것이 없으면 패널 자체가 포커스를 받습니다 — 그래야 키보드로 내용에 닿을 수 있고, 그때 브라우저 기본 테두리 대신 하우스 포커스 링이 그려집니다.

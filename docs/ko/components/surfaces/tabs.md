---
title: Tabs
order: 4
---

# Tabs

<p class="neba-lede">같은 자리에서 여러 패널 중 하나만 보여 줍니다. 내용을 나란히 두기보다 전환해서 볼 때 씁니다.</p>

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

`<TabList>` 같은 wrapper는 없습니다. `Tab`과 `TabPanel`을 나란히 두면 컴포넌트가 알아서 탭 바와 패널 영역으로 나눕니다.

## Props

### Tabs

<PropsTable name="Tabs" />

### Tab

<PropsTable name="Tab" />

### TabPanel

<PropsTable name="TabPanel" />

## 예시

### variant

`variant`는 패널이 아니라 탭 **바**의 무게입니다.

- `solid` — 홈통 안에서 채워진 타일이 탭 사이를 움직입니다.
- `outline` — 바 가장자리의 선 위에 표시자가 올라갑니다.
- `text` — 선 없이 표시자만 남습니다. 이미 테두리가 있는 [Card](./card) 안에 넣을 때 씁니다.

<Demo src="tabs/variants">

<<< @/.vitepress/demos/tabs/variants.tsx

</Demo>

### orientation

`vertical`은 탭 바를 왼쪽에 세로로 놓습니다. 방향키도 함께 세로축으로 바뀝니다.

<Demo src="tabs/orientation">

<<< @/.vitepress/demos/tabs/orientation.tsx

</Demo>

### overflow와 lines

`overflow`는 자리보다 탭이 많을 때 바가 무엇을 할지 정합니다. 기본값 `scroll`은 한 줄을 유지한 채 그 위를 스크롤하고, 그 방향에 바가 더 남아 있는 동안 양 끝을 흐립니다. 스크롤바 자체는 감춥니다. `wrap`은 탭이 필요한 만큼 줄을 쓰고, 선택된 탭 아래의 선도 그 탭이 있는 줄로 따라갑니다.

`lines`는 wrap하는 바의 높이를 탭 줄 수로 제한하고, 그 위로는 스크롤합니다. `overflow`가 `wrap`일 때만 읽습니다.

<Demo src="tabs/overflow" minHeight="420">

<<< @/.vitepress/demos/tabs/overflow.tsx

</Demo>

### startIcon과 endIcon

라벨 앞뒤에 아이콘이나 개수를 넣습니다.

<Demo src="tabs/icons">

<<< @/.vitepress/demos/tabs/icons.tsx

</Demo>

### size

[Button](../inputs/button)과 같은 컨트롤 높이 단계를 씁니다. `md` 탭과 `md` Button이 모두 32px이므로 툴바 안에 나란히 놓을 수 있습니다.

### activateOnFocus

기본값은 꺼짐입니다. 방향키로 탭을 지나가는 동안에는 패널이 바뀌지 않고, Enter나 Space로 활성화합니다. 패널이 데이터를 불러오는 경우 방향키 이동만으로 요청이 여러 번 발생하는 것을 막습니다.

### keepMounted

`TabPanel`에 지정하면 선택되지 않은 패널의 React 트리를 유지합니다.

## 접근성

- 탭 바 전체가 tab 정지 하나이고, 그 안에서는 방향키와 Home/End로 이동합니다(roving tab index).
- `tab` / `tabpanel` role과 그 사이의 `aria-controls`가 연결됩니다.
- 패널 안에 focus 받을 요소가 없으면 패널 자체가 focus를 받으므로 키보드로 내용에 닿을 수 있습니다.
- 선택 표시자는 `left` / `top`과 `width` / `height`로 이동하므로 라벨이 다시 그려지지 않습니다.

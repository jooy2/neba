---
title: FloatingBottomNavigation
order: 24
---

# FloatingBottomNavigation

<p class="neba-lede">앱의 주요 목적지들을 담은 바입니다. 아래 가장자리에 붙는 대신 그 위로 떠 있으며, 담긴 목적지만큼만 넓고, 스타디움 모양으로 잘려 있고, 그 아래로 페이지가 계속 이어집니다.</p>

<Demo src="floating-bottom-navigation/hero" minHeight="320" />

```tsx
import { BottomNavigationItem, FloatingBottomNavigation } from 'neba';

<FloatingBottomNavigation label="Main" value={section} onValueChange={setSection}>
  <BottomNavigationItem value="home" icon={<HomeIcon />}>
    Home
  </BottomNavigationItem>
  <BottomNavigationItem value="search" icon={<SearchIcon />}>
    Search
  </BottomNavigationItem>
</FloatingBottomNavigation>;
```

## Props

<PropsTable name="FloatingBottomNavigation" />

`onChange`를 빼면 나머지 `<nav>` 속성은 그대로 루트에 전달됩니다. 들을 만한 변화는 `onValueChange`입니다. 공용 축(`variant` `size` `color` `density` `elevation` `position`)은 [prop 규약](../../design/prop-conventions)에 있습니다.

목적지는 `BottomNavigationItem`으로, [BottomNavigation](./bottom-navigation)이 받는 것과 같은 항목입니다. `value`, `icon`, `href`, `disabled` 등 항목에 관한 것은 모두 그 페이지에 있습니다.

## 예시

### offset · safeArea

`offset`은 바가 아래 가장자리에서 얼마나 떠 있는지를 픽셀 수나 CSS 길이로 정합니다. `safeArea`는 그 간격에 `env(safe-area-inset-bottom)`을 더해 폰의 홈 인디케이터를 피하며, 안쪽 줄만이 아니라 시트 전체를 올립니다.

```tsx
<FloatingBottomNavigation offset={24} safeArea={false} />
```

### position

기본값 `fixed`는 창 아래에 바를 붙입니다. `absolute`는 가장 가까운 positioned 조상의 아래에 붙이며, 자기만의 화면 안에 놓이는 바가 원하는 값이자 위 미리보기가 쓰는 값입니다. `sticky`는 스크롤되는 것의 아래에 붙이고, `static`은 흐름 안에 가운데 정렬로 되돌립니다.

<Demo src="floating-bottom-navigation/pinned" minHeight="300">

<<< @/.vitepress/demos/floating-bottom-navigation/pinned.tsx

</Demo>

### labels

기본값 `selected`는 읽는 사람이 지금 있는 목적지의 이름만 그리고, `all`은 모든 이름을, `none`은 아무 이름도 그리지 않습니다. `selected`에서 목적지를 누르면 그 이름이 자라고 옆의 목적지들이 비켜서는 동안 하이라이트가 그 아래로 미끄러져 들어옵니다. 그리지 않은 이름도 문서에는 남아 옆의 글리프에게 접근성 이름을 줍니다.

<Demo src="floating-bottom-navigation/labels" minHeight="340">

<<< @/.vitepress/demos/floating-bottom-navigation/labels.tsx

</Demo>

### variant · color · size

`variant`는 시트에 색을 들이지 않으며, 색 계열을 입는 것은 지금 있는 목적지 하나뿐입니다. 기본값은 `outline`입니다.

<Demo src="floating-bottom-navigation/appearance" minHeight="320">

<<< @/.vitepress/demos/floating-bottom-navigation/appearance.tsx

</Demo>

### 직접 제어하기

`value`를 넘기면 바는 자기 상태를 갖지 않습니다. 라우터가 이미 읽는 사람의 위치를 알고 있을 때 쓰는 모양입니다.

```tsx
<FloatingBottomNavigation value={pathname} onValueChange={navigate}>
  <BottomNavigationItem value="/home" icon={<HomeIcon />}>
    Home
  </BottomNavigationItem>
</FloatingBottomNavigation>
```

## 접근성

- 루트는 `<nav>`이고 `label`이 그 이름입니다. `role="tablist"`가 아니므로 목적지마다 tab 정지점이 따로 있고, 방향키로 목적지 사이를 옮겨 다니지 않습니다.
- 지금 있는 목적지는 `aria-current="page"`를 답니다.
- 각 목적지는 진짜 `<button>`이며, `href`를 주면 진짜 `<a>`입니다.
- `labels`가 그리지 않은 이름도 문서에는 남아 목적지의 접근성 이름이 됩니다. 글리프뿐인 항목에게는 그것이 이름의 전부입니다.
- 움직임을 줄이도록 설정한 사용자에게는 하이라이트와 이름이 움직이지 않고 바로 새 배치로 바뀝니다.
- `position="fixed"`일 때는 페이지 아래쪽에 바의 높이와 `offset`만큼 여백을 두세요. 그렇지 않으면 마지막 줄이 가려집니다.

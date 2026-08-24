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

목적지는 `BottomNavigationItem`으로, [BottomNavigation](./bottom-navigation)이 받는 것과 같은 항목입니다. `value`, `icon`, `href`, `disabled` 등 항목에 관한 것은 모두 그 페이지에 있습니다.

## Props

<PropsTable name="FloatingBottomNavigation" />

`onChange`를 빼면 나머지 `<nav>` 속성은 그대로 루트에 전달됩니다 — 들을 만한 변화는 `onValueChange`입니다. 공용 축(`variant` `size` `color` `density` `elevation` `position`)은 [prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### offset

바가 아래 가장자리에서 얼마나 떠 있는지를 픽셀 수나 CSS 길이로 정합니다. [BottomNavigation](./bottom-navigation)과의 차이는 전부 여기서 나옵니다. 아래로 페이지가 계속 이어지기 때문에 시트는 모서리 두 개짜리 바가 아니라 스타디움이고, 그림자를 지며, 담긴 것만큼만 넓습니다.

`safeArea`는 그 간격에 `env(safe-area-inset-bottom)`을 더해 폰의 홈 인디케이터를 피합니다. 전체 너비 바와 달리 시트 전체가 올라가는데, 아래에 덮고 있어야 할 것이 없기 때문입니다.

```tsx
<FloatingBottomNavigation offset={24} safeArea={false} />
```

### position

기본값 `fixed`는 창 아래에 바를 붙입니다. `absolute`는 가장 가까운 positioned 조상의 아래에 붙이며, 자기만의 화면 안에 놓이는 바가 원하는 값이자 위 미리보기가 쓰는 값입니다. `sticky`는 스크롤되는 것의 아래에 붙이고, `static`은 흐름 안에 가운데 정렬로 되돌립니다.

<Demo src="floating-bottom-navigation/pinned" minHeight="300">

<<< @/.vitepress/demos/floating-bottom-navigation/pinned.tsx

</Demo>

### labels

여기서의 기본값 `selected`는 읽는 사람이 지금 있는 목적지의 이름만 그립니다. 떠 있는 바는 담긴 것만큼만 넓으므로, 이름 다섯 개를 그리면 화면을 가로지르게 되고 더 이상 로젠지가 아니게 됩니다.

`all`은 모든 이름을, `none`은 아무 이름도 그리지 않습니다. 그리지 않은 이름도 문서에는 남아, 옆의 글리프에게 접근성 이름을 주는 것이 바로 그 이름입니다.

<Demo src="floating-bottom-navigation/labels" minHeight="340">

<<< @/.vitepress/demos/floating-bottom-navigation/labels.tsx

</Demo>

### variant · color · size

`variant`는 다른 모든 컨테이너에서와 같은 말을 합니다. 시트에는 색을 들이지 않으며, 색 계열을 입는 것은 지금 있는 목적지 하나뿐입니다. 가장자리가 없는 시트 대신 `outline`이 기본인데, 아래로 지나가는 것과 떠 있는 로젠지를 갈라 주는 것이 그 헤어라인이기 때문입니다.

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

- 루트는 `<nav>`이고 `label`이 그 이름입니다. `role="tablist"`가 아닙니다 — tab list는 전체에 tab stop 하나와 그 안의 방향키 이동을 약속하지만, 하단 내비게이션은 패널이 아니라 페이지를 바꿉니다.
- 지금 있는 목적지는 `aria-current="page"`를 답니다.
- 각 목적지는 진짜 `<button>`이며, `href`를 주면 진짜 `<a>`입니다.
- `labels`가 그리지 않은 이름도 문서에는 남아 목적지의 접근성 이름이 됩니다 — 글리프뿐인 항목에게는 그것이 이름의 전부입니다.
- `position="fixed"`일 때는 페이지 아래쪽에 바의 높이와 `offset`만큼 여백을 두세요. 그렇지 않으면 마지막 줄이 가려집니다.

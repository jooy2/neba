---
title: BottomNavigation
order: 22
---

# BottomNavigation

<p class="neba-lede">창의 아래 가장자리에 고정되어 앱의 주요 목적지를 나란히 보여 주는 바입니다. 글리프 하나와 그 아래 이름 하나가 한 칸이고, 지금 있는 곳에는 <code>aria-current</code>가 붙습니다.</p>

<Demo src="bottom-navigation/hero" minHeight="200" />

```tsx
import { BottomNavigation, BottomNavigationItem } from 'neba';

<BottomNavigation label="Main" value={section} onValueChange={setSection}>
  <BottomNavigationItem value="home" icon={<HomeIcon />}>
    홈
  </BottomNavigationItem>
  <BottomNavigationItem value="search" icon={<SearchIcon />}>
    검색
  </BottomNavigationItem>
</BottomNavigation>;
```

## Props

<PropsTable name="BottomNavigation" />

<PropsTable name="BottomNavigationItem" />

나머지 `<nav>` 속성은 루트로, 나머지 `<button>` 속성은 각 목적지로 전달됩니다. 예외는 `onChange`로, 여기서 들을 만한 변화는 `onValueChange`입니다.

공통 축(`variant` `size` `color` `density` `elevation` `position`)의 의미는 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### position

기본값은 `fixed`입니다. 라이브러리의 다른 컴포넌트가 모두 `static`을 기본으로 두는 것과 반대이고, 그것이 이 컴포넌트가 하는 일입니다. 페이지가 무엇을 하든 창의 아래 가장자리에 붙어 있습니다. 그러면 페이지는 첫 화면이 바 뒤에 깔리지 않도록 스스로 아래쪽 여백을 마련해야 합니다.

`sticky`는 바를 흐름 안에 두되 스크롤 영역의 아래 가장자리에서 멈추게 합니다. `static`은 그냥 흐름 안의 시트입니다.

<Demo src="bottom-navigation/pinned" minHeight="280">

<<< @/.vitepress/demos/bottom-navigation/pinned.tsx

</Demo>

### labels

`all`은 모든 이름을 그립니다. `selected`는 지금 있는 목적지의 이름만, `none`은 아무 이름도 그리지 않습니다.

그리지 않은 이름도 문서에는 남습니다. 글리프 하나뿐인 버튼은 접근성 이름이 아예 없으므로, 사라지는 것은 픽셀뿐입니다.

<Demo src="bottom-navigation/labels" minHeight="320">

<<< @/.vitepress/demos/bottom-navigation/labels.tsx

</Demo>

### href

`href`를 준 목적지는 진짜 `<a>`가 됩니다. 길게 눌러 새 탭으로 열 수 있고, 주소가 상태 표시줄에 뜨며, 라우터를 부르는 `<button>`으로는 둘 다 되지 않습니다.

<Demo src="bottom-navigation/links" minHeight="120">

<<< @/.vitepress/demos/bottom-navigation/links.tsx

</Demo>

### variant, divider, safeArea

`variant`는 다른 컨테이너에서와 같은 말을 합니다. 시트에는 색이 들지 않고, 색 계열을 입는 것은 지금 있는 목적지 하나뿐입니다. `divider`는 내용을 마주 보는 위쪽 가장자리의 헤어라인이고 기본이 켜짐입니다. `safeArea`는 `env(safe-area-inset-bottom)`만큼 아래를 띄워 홈 인디케이터를 피하되, 시트 자체는 화면 아래 끝까지 그대로 닿습니다.

<Demo src="bottom-navigation/appearance" minHeight="360">

<<< @/.vitepress/demos/bottom-navigation/appearance.tsx

</Demo>

### 제어하기

`value`를 넘기면 바는 자체 상태를 갖지 않습니다. 라우터가 지금 있는 곳을 알고 있을 때 쓰는 형태입니다.

```tsx
<BottomNavigation value={pathname} onValueChange={navigate}>
  <BottomNavigationItem value="/home" icon={<HomeIcon />}>
    홈
  </BottomNavigationItem>
</BottomNavigation>
```

## 접근성

- 루트는 `<nav>`이고 `label`이 그 이름이 됩니다. `role="tablist"`가 아닙니다. 탭 목록은 세트 전체에 tab 정지점 하나와 그 안의 방향키 이동을 약속하고, 하단 내비게이션은 패널이 아니라 페이지를 바꿉니다.
- 지금 있는 목적지에는 `aria-current="page"`가 붙습니다.
- 각 목적지는 진짜 `<button>`이거나, `href`가 있으면 진짜 `<a>`입니다.
- `labels`가 이름을 그리지 않아도 그 이름은 문서에 남아 목적지의 접근성 이름이 됩니다.
- `position="fixed"`일 때 페이지 아래쪽에 바 높이만큼 여백을 두세요. 첫 화면의 마지막 줄이 바에 가립니다.

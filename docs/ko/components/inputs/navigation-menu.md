---
title: NavigationMenu
order: 30
---

# NavigationMenu

<p class="neba-lede">사이트의 내비게이션입니다. 목적지들이 한 줄로 놓이고, 그중 일부는 더 많은 목적지가 담긴 패널을 엽니다. 모든 행이 진짜 링크이며, 그래서 링크 목록에도, 상태 표시줄에도, 크롤러의 색인에도 들어갑니다.</p>

<Demo src="navigation-menu/hero" />

```tsx
import { NavigationMenu, NavigationMenuItem, NavigationMenuLink } from 'neba';

<NavigationMenu aria-label="Main">
  <NavigationMenuItem label="Product">
    <NavigationMenuLink href="/analytics" title="Analytics" description="Every number." />
  </NavigationMenuItem>
  <NavigationMenuItem label="Pricing" href="/pricing" />
</NavigationMenu>;
```

## Props

<PropsTable name="NavigationMenu" />

`<nav>`의 모든 속성이 `color`를 제외하고 그대로 전달됩니다.

[Menu](./menu)와의 차이는 행이 *무엇인가*에 있습니다. 메뉴는 액션을 담으므로 행이 `menuitem`입니다. 이쪽은 링크를 담으므로 `<a>`로 가득 찬 `<nav>`입니다. 행이 무언가를 _하면_ Menu를, 어딘가로 _가면_ 이 컴포넌트를 쓰세요.

### NavigationMenuItem

<PropsTable name="NavigationMenuItem" />

### NavigationMenuLink

<PropsTable name="NavigationMenuLink" />

## 예시

### 패널이 있는 항목과 없는 항목

children이 있는 항목은 trigger와 패널이 되고, `href`만 있고 children이 없는 항목은 링크가 됩니다. 두 가지는 스크린 리더에 다르게 전달됩니다.

### columns

패널이 링크를 몇 개의 열로 배치할지 정합니다. 짧은 목록은 한 열이 맞고, 지역이나 제품이 많은 넓은 메뉴는 두세 열을 원합니다.

<Demo src="navigation-menu/columns">

<<< @/.vitepress/demos/navigation-menu/columns.tsx

</Demo>

### orientation

`vertical`은 항목을 세로로 쌓고 패널을 옆으로 엽니다. 바가 아니라 내비게이션 레일이 됩니다.

<Demo src="navigation-menu/orientation">

<<< @/.vitepress/demos/navigation-menu/orientation.tsx

</Demo>

### header 안에서

<Demo src="navigation-menu/header">

<<< @/.vitepress/demos/navigation-menu/header.tsx

</Demo>

## 접근성

- 진짜 `<nav>`로 렌더링됩니다. 한 페이지에 nav가 둘 이상이면 `aria-label`을 주세요.
- 모든 목적지가 `<a href>`이므로 새 탭에서 열고, 주소를 복사하고, 크롤러가 따라가고, 스크린 리더의 링크 목록에서 도달할 수 있습니다.
- 키보드로 조작합니다. 방향키로 항목 사이와 열린 패널 안을 오가고, Escape로 닫습니다.
- 패널은 항목 사이를 이동할 때 닫혔다 열리는 대신 크기를 바꿉니다. 그래서 줄을 가로지르는 동작이 하나의 표면처럼 읽힙니다.

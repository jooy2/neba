---
title: Menubar
order: 29
---

# Menubar

<p class="neba-lede">애플리케이션 상단에 놓이는 단어들의 띠입니다 — File, Edit, View — 각각이 메뉴를 엽니다. 하나가 열린 뒤에는 띠 위를 지나가면 방금 있던 메뉴가 닫히는 대신 옆 메뉴로 넘어갑니다.</p>

<Demo src="menubar/hero" />

```tsx
import { Menubar, MenubarMenu, MenuItem, MenuSeparator } from 'neba';

<Menubar>
  <MenubarMenu label="File">
    <MenuItem shortcut="⌘N">New file</MenuItem>
    <MenuSeparator />
    <MenuItem>Open…</MenuItem>
  </MenubarMenu>
</Menubar>;
```

## Props

<PropsTable name="Menubar" />

`<div>`의 모든 속성이 `color`를 제외하고 그대로 전달됩니다.

자기 표면은 그리지 않습니다. 메뉴 바는 무언가 _위에_ 놓입니다 — [Toolbar](../surfaces/toolbar), [WindowPane](../surfaces/window-pane)의 타이틀 바, [Header](../layout/header) — 이미 시트 위에 있는 띠 아래에 시트를 한 장 더 깔면 시트가 둘이 됩니다.

### MenubarMenu

<PropsTable name="MenubarMenu" />

행은 [Menu](./menu)가 받는 것과 같은 `MenuItem`, `MenuSeparator`, `MenuGroup`, `MenuCheckboxItem`, `MenuRadioGroup`, `MenuSubmenu`입니다. 같은 메뉴이기 때문입니다. `size`, `color`, `density`는 바의 것이므로 여기에서 다시 지정하지 않습니다.

## 예시

### 중첩된 행과 선택되는 행

Menu가 담을 수 있는 것은 바 위의 메뉴도 담을 수 있습니다 — 서브메뉴, 그룹, 체크박스 행, 라디오 행.

### size

각 단계에서 컨트롤 높이보다 한 칸 아래인 자기만의 사다리를 씁니다. 메뉴 바는 버튼의 행이 아니라 단어의 띠이고, 대개 이미 높이를 가진 무언가 안에 놓이기 때문입니다.

<Demo src="menubar/sizes">

<<< @/.vitepress/demos/menubar/sizes.tsx

</Demo>

### orientation

`vertical`은 단어를 세로로 쌓고, 방향키도 그 방향을 따릅니다.

<Demo src="menubar/orientation">

<<< @/.vitepress/demos/menubar/orientation.tsx

</Demo>

### 창 위에서

<Demo src="menubar/window">

<<< @/.vitepress/demos/menubar/window.tsx

</Demo>

## 접근성

- `role="menubar"`로 렌더링되고, 각 단어는 메뉴를 소유한 `menuitem`이 됩니다.
- 바 전체가 하나의 tab stop입니다. 방향키로 단어 사이와 행 안쪽을 오갈 수 있고, typeahead도 양쪽에서 동작합니다.
- 한 페이지에 바가 둘 이상이면 `aria-label`을 주세요.

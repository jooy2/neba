---
title: Menu
order: 9
---

# Menu

<p class="neba-lede">trigger를 눌렀을 때 나타나는 액션 목록입니다. 중첩된 submenu와 체크 가능한 행을 포함할 수 있고, 키보드만으로 전체를 다룰 수 있습니다.</p>

<Demo src="menu/hero" />

```tsx
import { Button, Menu, MenuItem, MenuSeparator, MenuSubmenu } from 'neba';

<Menu trigger={<Button>액션</Button>}>
  <MenuItem shortcut="⌘E">이름 바꾸기</MenuItem>
  <MenuSubmenu label="이동">
    <MenuItem>보관함</MenuItem>
  </MenuSubmenu>
  <MenuSeparator />
  <MenuItem color="danger">삭제</MenuItem>
</Menu>;
```

행은 배열이 아니라 컴포넌트로 씁니다. 행마다 다른 핸들러와 아이콘이 붙고 그중 일부가 submenu가 되기 때문입니다. 값을 고르는 목록이 필요하다면 [Select](./select)를 쓰세요.

## Props

### Menu

<PropsTable name="Menu" />

### MenuItem

<PropsTable name="MenuItem" />

### MenuSubmenu

<PropsTable name="MenuSubmenu" />

### ContextMenu

<PropsTable name="ContextMenu" />

## 예시

### href · startIcon · shortcut

`href`를 주면 행이 실제 `<a>`로 렌더링되므로 새 탭으로 열거나 주소를 복사할 수 있습니다. `shortcut`에는 [Shortcut](../display/shortcut)을 넣습니다. `MenuSeparator`로 행을 그룹으로 나눕니다.

<Demo src="menu/basic">

<<< @/.vitepress/demos/menu/basic.tsx

</Demo>

### MenuSubmenu

깊이 제한은 없습니다. submenu의 자식도 메뉴 행이므로 그 안에 또 `MenuSubmenu`를 둘 수 있습니다. hover로 열리며, 열린 submenu로 포인터를 비스듬히 옮겨도 닫히지 않습니다.

<Demo src="menu/nested">

<<< @/.vitepress/demos/menu/nested.tsx

</Demo>

### 체크와 라디오 행

체크 표시는 여러 개를 동시에 켜는 항목, 점은 여럿 중 하나를 고르는 항목에 씁니다. 두 경우 모두 선택 후 메뉴가 닫히지 않습니다. 행 단위로 `closeOnClick`을 지정할 수 있습니다.

<Demo src="menu/state">

<<< @/.vitepress/demos/menu/state.tsx

</Demo>

### ContextMenu

우클릭으로 열리는 메뉴입니다. `content`에 메뉴 행을, `children`에 대상 영역을 넘깁니다.

<Demo src="menu/context">

<<< @/.vitepress/demos/menu/context.tsx

</Demo>

### size와 density

<Demo src="menu/sizes">

<<< @/.vitepress/demos/menu/sizes.tsx

</Demo>

### side · align · openOnHover

`side`와 `align`은 trigger를 기준으로 팝업이 놓일 자리입니다. `openOnHover`는 클릭 없이 hover만으로 열리게 합니다.

## 접근성

- `menu` / `menuitem` role, 방향키 roving focus, Home/End, typeahead, Escape, 바깥 클릭으로 닫기, 닫을 때 trigger로 focus 복귀가 모두 처리됩니다.
- 삭제처럼 파괴적인 행에는 `color="danger"`를 주세요. 글자색과 옅은 배경, focus ring이 함께 바뀝니다.
- 라벨이 문자열이 아니면 `label`에 typeahead가 매칭할 문자열을 주세요.
- `disabled` 행은 목록에 남고 typeahead에도 걸립니다. 행이 사라지면 "여기서는 쓸 수 없음"이 아니라 "그런 항목이 없음"으로 읽힙니다.

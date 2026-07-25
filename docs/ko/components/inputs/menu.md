---
title: Menu
order: 9
---

# Menu

<p class="neba-lede">무언가를 눌렀을 때 나타나는 액션 목록입니다. 중첩되고, 상태를 들고, 키보드만으로 끝까지 다룰 수 있습니다.</p>

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

### 그룹, 링크, 아이콘

`href`를 주면 행이 진짜 `<a>`가 됩니다. 이건 사소한 차이가 아닙니다 — 링크가 아닌 링크 메뉴는 새 탭으로 열 수도, 주소를 복사할 수도 없고, 스크린 리더에게는 모든 행에 대해 틀린 말을 합니다.

<Demo src="menu/basic">

<<< @/.vitepress/demos/menu/basic.tsx

</Demo>

### 중첩 메뉴

깊이 제한은 없습니다. 서브메뉴의 자식은 그냥 메뉴 행이고, 그중 하나가 또 `MenuSubmenu`일 수 있기 때문입니다. Base UI가 호버로 열면서 안전 삼각형을 그려 주므로, 열린 서브메뉴로 비스듬히 손을 뻗어도 닫히지 않습니다.

<Demo src="menu/nested">

<<< @/.vitepress/demos/menu/nested.tsx

</Demo>

### 상태를 든 행

체크는 "그리고"를, 점은 "대신"을 뜻합니다 — 라이브러리 어디서나 Checkbox와 Radio가 만드는 것과 같은 구분입니다. 둘 다 고른 뒤에도 메뉴를 닫지 않습니다: 체크할 것들의 목록은 여러 개를 체크하는 목록이니까요.

<Demo src="menu/state">

<<< @/.vitepress/demos/menu/state.tsx

</Demo>

### 컨텍스트 메뉴

<Demo src="menu/context">

<<< @/.vitepress/demos/menu/context.tsx

</Demo>

### 크기

<Demo src="menu/sizes">

<<< @/.vitepress/demos/menu/sizes.tsx

</Demo>

## 행은 데이터가 아니라 코드입니다

[Select](./select)는 `items` 배열을 받습니다. 메뉴는 받지 않습니다. 정반대이고, 의도된 것입니다.

셀렉트의 옵션은 호출하는 쪽이 이미 갖고 있는 목록의 값들입니다. 메뉴의 행은 **코드**입니다 — 행마다 다른 핸들러, 다른 아이콘, 어떤 것은 서브메뉴. 데이터로 만들면 행이 취할 수 있는 모든 모양마다 변형이 하나씩 있는 `items` 타입이 되고, 그건 판별 유니온으로 적어 놓은 컴포넌트 트리입니다.

## 팝업은 Select의 팝업과 같습니다

픽셀 단위로 같습니다. 셀렉트는 무엇을 골랐는지 기억하는 메뉴이고, 서로 맞지 않는 두 개의 떠 있는 행 목록은 눈이 따로 익혀야 하는 두 개의 목록이기 때문입니다.

행의 여백만은 다릅니다. List의 행은 다른 것이 폭을 정해 준 시트를 가로지르지만, 메뉴의 행은 자기 가장 긴 라벨만큼만 넓은 팝업 안에 있습니다. `md`에서 Box의 `px-4`는 "잘라내기"라고 적힌 메뉴에 32px을 더하고, 그것이 다섯 줄짜리 메뉴가 다이얼로그만큼 넓어지는 방법입니다.

## Base UI가 하는 일

메뉴를 "떠 있는 div 목록"이 아니라 메뉴로 만드는 것 전부입니다. 화살표 키의 roving focus, Home과 End, 타이핑 검색, Escape, 바깥 클릭으로 닫기, 트리거로 포커스 되돌리기, 호버로 열리는 서브메뉴와 안전 삼각형, 그리고 그 모든 것이 스크린 리더에게 의미를 갖게 하는 `menu` / `menuitem` 역할.

여기 있는 것은 표면과 사다리와 행의 배치입니다.

## 접근성

- 지우는 행에는 `color="danger"`를 주세요. 색 계열 전체가 넘어가므로 글자색, 옅은 배경, 포커스 링이 함께 바뀝니다.
- 라벨이 평범한 문자열이 아니면 `label`로 타이핑 검색이 맞춰 볼 문자열을 주세요.
- `disabled` 행은 목록에 남고 타이핑 검색에도 걸립니다. 사라지지 않는 것이 요점입니다 — 없어진 행은 "여기서는 쓸 수 없음"이 아니라 "그런 건 없음"을 뜻하니까요.

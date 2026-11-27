---
title: Menu
order: 9
flutter: true
---

# Menu

<p class="neba-lede">trigger를 눌렀을 때 나타나는 액션 목록입니다. 중첩된 submenu와 체크 가능한 행을 포함할 수 있고, 키보드만으로 전체를 다룰 수 있습니다.</p>

<Demo src="menu/hero" minHeight="240" />

::: fw react

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

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaMenu(
  trigger: NebaButton(onPressed: () {}, child: const Text('액션')),
  children: <Widget>[
    NebaMenuItem(onPressed: rename, shortcut: const Text('⌘E'), child: const Text('이름 바꾸기')),
    const NebaMenuSubmenu(
      label: Text('이동'),
      children: <Widget>[NebaMenuItem(child: Text('보관함'))],
    ),
    const NebaMenuSeparator(),
    NebaMenuItem(onPressed: delete, color: NebaColor.danger, child: const Text('삭제')),
  ],
);
```

:::

행은 배열이 아니라 <Fw react="컴포넌트로" flutter="위젯으로" /> 씁니다. 행마다 다른 핸들러와 아이콘이 붙고 그중 일부가 submenu가 되기 때문입니다. 값을 고르는 목록이 필요하다면 [Select](./select)를 쓰세요.

## Props

### Menu

<PropsTable name="Menu" />

::: fw flutter

`trigger`는 자기 누름으로 메뉴를 열기 때문에 `NebaButton`이나 `onPressed`를 준 `NebaChip` 같은 Neba 컨트롤이어야 합니다. trigger 역할만 하는 버튼에는 `onPressed: () {}`를 줍니다. Flutter 버튼은 `onPressed`가 없으면 비활성이 되기 때문입니다. `disabled`는 trigger가 메뉴를 열지 못하게 할 뿐 trigger의 모습은 그대로 두므로, trigger도 함께 비활성화하세요.

popup은 앱의 루트 `Overlay`에 그려집니다. `MaterialApp`, `CupertinoApp`, route가 있는 `WidgetsApp`에는 모두 overlay가 있고, overlay 없이 만든 앱은 `Overlay.wrap`으로 감쌉니다.

`keepMounted`는 없습니다. 크롤러가 읽을 문서가 없고, 닫힌 popup은 어느 쪽이든 semantics 트리 밖에 있기 때문입니다.

:::

### MenuItem

<PropsTable name="MenuItem" />

::: fw flutter

패키지는 아무것도 직접 열지 않으므로 어딘가로 가는 행은 콜백입니다. `onPressed`가 router나 URL launcher를 부르고, `href`는 screen reader와, 웹에서는 브라우저에 행이 가는 곳을 알립니다. `onPressed`가 없는 행도 고르면 메뉴가 닫힙니다. 행을 막는 것은 `disabled`입니다.

:::

### MenuSubmenu

<PropsTable name="MenuSubmenu" />

### MenuGroup

<PropsTable name="MenuGroup" />

### MenuCheckboxItem

<PropsTable name="MenuCheckboxItem" />

### MenuRadioGroup

<PropsTable name="MenuRadioGroup" />

::: fw flutter

`NebaMenuRadioGroup<T>`는 `NebaRadioGroup`처럼 값의 타입을 받는 generic이고, 그 행은 같은 `T`의 `NebaMenuRadioItem<T>`입니다.

:::

### MenuRadioItem

<PropsTable name="MenuRadioItem" />

### MenuSeparator

::: fw react

행 사이의 구분선입니다. `<div>`의 속성만 받습니다.

:::

::: fw flutter

행 사이의 구분선이며, popup 폭 전체에 걸쳐 그려집니다. 인자는 받지 않습니다.

:::

### ContextMenu

<PropsTable name="ContextMenu" />

## 예시

### href · startIcon · shortcut

::: fw react

`href`를 주면 행이 실제 `<a>`로 렌더링되므로 새 탭으로 열거나 주소를 복사할 수 있습니다. `shortcut`에는 [Shortcut](../display/shortcut)을 넣습니다. `MenuSeparator`로 행을 그룹으로 나눕니다.

:::

::: fw flutter

`href`를 주면 screen reader에게 행이 링크로 읽히고, `newTab`은 다른 곳에서 열린다는 사실을 알립니다. 따라가는 일은 `onPressed`의 몫입니다. `shortcut`에는 `Text`나 [Shortcut](../display/shortcut)을 넣습니다. `NebaMenuSeparator`로 행을 그룹으로 나눕니다.

:::

<Demo src="menu/basic" minHeight="320">

::: fw react

<<< @/.vitepress/demos/menu/basic.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/basic.dart

:::

</Demo>

### MenuSubmenu

깊이 제한은 없습니다. submenu의 자식도 메뉴 행이므로 그 안에 또 `MenuSubmenu`를 둘 수 있습니다. hover로 열리며, 열린 submenu로 포인터를 비스듬히 옮겨도 닫히지 않습니다.

<Demo src="menu/nested" minHeight="220">

::: fw react

<<< @/.vitepress/demos/menu/nested.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/nested.dart

:::

</Demo>

### 체크와 라디오 행

체크 표시는 여러 개를 동시에 켜는 항목, 점은 여럿 중 하나를 고르는 항목에 씁니다. 두 경우 모두 선택 후 메뉴가 닫히지 않습니다. 행 단위로 <Fw react="`closeOnClick`을" flutter="`closeOnPress`를" /> 지정할 수 있습니다.

<Demo src="menu/state" minHeight="300">

::: fw react

<<< @/.vitepress/demos/menu/state.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/state.dart

:::

</Demo>

### ContextMenu

::: fw react

우클릭으로 열리는 메뉴입니다. `content`에 메뉴 행을, `children`에 대상 영역을 넘깁니다. 영역은 요소 하나여야 하며, 트리거가 그 요소를 감싸지 않고 합쳐지므로 레이아웃에 아무것도 더하지 않습니다.

그 밖에 넘긴 값은 팝업이 아니라 영역으로 갑니다. 팝업은 `className`과 `style`이 맡습니다. 덕분에 `ContextMenu`는 다른 트리거 안에 들어갈 수 있습니다. 같은 요소에 [Tooltip](../feedback/tooltip)을 함께 걸려면 툴팁으로 메뉴를 감싸세요. 반대로 쓰면 동작하지 않습니다.

키보드에서는 영역에 포커스가 있을 때 context-menu 키나 `Shift+F10`으로 열립니다. 스스로 포커스를 받지 못하는 영역에는 `tabIndex={0}`을 주세요.

:::

::: fw flutter

우클릭으로, 터치 화면에서는 길게 눌러서 포인터가 있는 자리에 여는 메뉴입니다. `content`에 메뉴 행을, `child`에 대상 영역을 넘기며, 영역은 메뉴가 없을 때와 똑같이 배치됩니다. 웹에서는 포인터가 영역 위에 있는 동안 브라우저 자체의 메뉴가 뜨지 않습니다.

키보드에서는 영역 안의 무언가에 포커스가 있을 때 context-menu 키나 `Shift+F10`으로 열립니다. 스스로 포커스를 받지 못하는 영역은 `Focus`로 감싸세요.

:::

<Demo src="menu/context" minHeight="260">

::: fw react

<<< @/.vitepress/demos/menu/context.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/context.dart

:::

</Demo>

### size와 density

<Demo src="menu/sizes" minHeight="200">

::: fw react

<<< @/.vitepress/demos/menu/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/menu/sizes.dart

:::

</Demo>

### side · align · openOnHover

`side`와 `align`은 trigger를 기준으로 팝업이 놓일 자리입니다. `openOnHover`는 클릭 없이 hover만으로 열리게 합니다.

::: fw react

### keepMounted

기본적으로 닫힌 메뉴의 행은 DOM에 없습니다. `keepMounted`를 주면 메뉴가 닫혀 있는 동안에도 팝업과 행이 숨겨진 채 DOM에 남고, 안에 든 `MenuSubmenu`의 행도 함께 남습니다. 스크립트를 실행하는 크롤러가 찾아야 하는 링크 메뉴에 쓰세요. 팝업은 portal로 렌더되므로 행은 서버 HTML이 아니라 페이지가 hydration된 뒤에 들어옵니다. `ContextMenu`도 같은 prop을 받습니다.

```tsx
<Menu keepMounted trigger={<Button>Docs</Button>}>
  <MenuItem href="/guide">Guide</MenuItem>
  <MenuItem href="/changelog">Changelog</MenuItem>
</Menu>
```

:::

## 접근성

::: fw react

- `menu` / `menuitem` role, 방향키 roving focus, Home/End, typeahead, Escape, 바깥 클릭으로 닫기, 닫을 때 trigger로 focus 복귀가 모두 처리됩니다.
- 삭제처럼 파괴적인 행에는 `color="danger"`를 주세요. 글자색과 강조된 행 아래의 옅은 배경이 함께 바뀝니다.
- 라벨이 문자열이 아니면 `label`에 typeahead가 매칭할 문자열을 주세요.
- `keepMounted`로 DOM에 남은 닫힌 메뉴는 숨겨져 있으므로, 열리기 전까지 그 행은 tab 순서에도 accessibility tree에도 없습니다.
- `disabled` 행은 목록에 남고 typeahead에도 걸립니다. 행이 사라지면 "여기서는 쓸 수 없음"이 아니라 "그런 항목이 없음"으로 읽힙니다.

:::

::: fw flutter

- screen reader에게 popup은 메뉴, 각 행은 메뉴 항목으로 읽힙니다. 체크하는 행은 체크박스 항목, 여럿 중 하나를 고르는 행은 라디오 항목이며 체크 상태도 함께 읽힙니다. submenu의 행은 submenu가 펼쳐졌는지, trigger는 메뉴가 열렸는지 알립니다. 그룹은 라벨이 이름이 됩니다.
- 방향키와 Home/End는 강조를 옮기고, 글자를 치면 그 글자로 시작하는 다음 행으로 갑니다. Enter와 Space는 강조된 행을 고르고, submenu를 가리키는 방향키는 submenu를 열고 반대 방향키는 닫습니다. Escape는 맨 위 popup만 닫고, 바깥을 누르면 메뉴가 닫히며, Tab은 메뉴를 닫고 trigger 다음으로 넘어갑니다. 메뉴가 닫히면 focus는 trigger로, submenu가 닫히면 submenu의 행으로 돌아갑니다.
- 강조가 곧 focus이므로 포인터와 키가 같은 행을 밝히고, 옅은 배경이 focus 표시입니다. 행에는 링을 그리지 않습니다.
- 삭제처럼 파괴적인 행에는 `color: NebaColor.danger`를 주세요. 글자색과 강조된 행 아래의 옅은 배경이 함께 바뀝니다.
- 라벨이 `Text`가 아니면 `label`에 typeahead가 매칭할 문자열을 주세요.
- `disabled` 행은 목록에 남고, 강조되며, typeahead에도 걸립니다. 행이 사라지면 "여기서는 쓸 수 없음"이 아니라 "그런 항목이 없음"으로 읽힙니다.

:::

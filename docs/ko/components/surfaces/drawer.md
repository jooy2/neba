---
title: Drawer
order: 10
---

# Drawer

<p class="neba-lede">창의 한쪽 변에 붙는 패널입니다. 페이지 위에 떠서 열고 닫히거나, 레이아웃의 일부로 고정된 사이드바가 되거나 — 어느 쪽이든 같은 패널입니다.</p>

<Demo src="drawer/hero" align="center" />

```tsx
import { Button, Drawer } from 'neba';

<Drawer trigger={<Button variant="outline">Open navigation</Button>} title="Workspace">
  <List>…</List>
</Drawer>;
```

## Props

<PropsTable name="Drawer" />

`DrawerClose`는 Base UI의 `Dialog.Close`를 그대로 내보낸 것입니다. `render` prop을 주면 어떤 요소든 자기가 속한 drawer를 닫습니다: `<DrawerClose render={<Button>Cancel</Button>} />`. `overlay` drawer의 것이며, `inline` drawer는 dialog가 아닙니다.

공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

## 예시

### side

`side`는 패널이 붙는 변입니다. `left`와 `right`는 `size` 사다리에서 너비를 가져오고 높이를 채우며, `top`과 `bottom`은 너비를 채우고 내용만큼의 높이를 갖되 창의 85%를 넘지 않습니다.

<Demo src="drawer/sides">

<<< @/.vitepress/demos/drawer/sides.tsx

</Demo>

### mode

기본값인 `overlay`는 열어서 쓰는 drawer입니다. 스크림, focus 가둠, Esc, 그리고 닫힐 때 trigger로 돌아가는 focus까지 포함됩니다. `inline`은 같은 패널을 레이아웃에 놓습니다 — 스크림도, portal도, 닫을 것도 없고 — `open`이 패널이 흐름 안에 있는지를 정합니다. 기본이 열림이므로 고정 사이드바에는 별도의 state가 필요 없습니다.

하나의 컴포넌트이므로, breakpoint에서 햄버거로 바뀌는 사이드바는 컴포넌트를 갈아 끼우는 일이 아니라 `mode` 하나가 바뀌는 일입니다.

<Demo src="drawer/inline">

<<< @/.vitepress/demos/drawer/inline.tsx

</Demo>

### rounded

`rounded`는 페이지를 향한 변의 두 모서리만 깎습니다 — 옆면 패널이라면 위아래, 위아래 패널이라면 안쪽 두 개입니다. 창 가장자리에 닿은 모서리는 각진 채로 둡니다. 패널이 시트가 아니라 창의 연장처럼 읽혀야 한다면 끄세요.

<Demo src="drawer/rounded">

<<< @/.vitepress/demos/drawer/rounded.tsx

</Demo>

### dividers와 스크롤

스크롤되는 것은 본문뿐이므로 `title`, `description`, `actions`는 제자리에 있습니다. `dividers`는 구역 사이의 여백을 하이라인으로 바꾸는데, 헤더가 움직이지 않았다고 말해 주는 것이 바로 그 선입니다.

<Demo src="drawer/scrolling">

<<< @/.vitepress/demos/drawer/scrolling.tsx

</Demo>

### extent

`extent`는 패널이 자기 변에서 얼마나 들어오는지입니다. `left`와 `right`에서는 **너비**, `top`과 `bottom`에서는 **높이**입니다. 숫자는 픽셀, 문자열은 CSS 길이입니다. 그대로 두면 옆면 패널은 `size`가 정한 너비를 씁니다.

```tsx
<Drawer side="right" extent={420} title="Details" />
<Drawer side="bottom" extent="50vh" title="Filters" />
```

## 접근성

- `overlay` mode에서 패널은 modal dialog입니다. focus가 안에 갇히고, 뒤 페이지는 inert가 되며, Esc로 닫히고 focus는 trigger로 돌아갑니다.
- `title`이 drawer의 이름이 되고 `description`이 설명이 되며, `aria-labelledby`와 `aria-describedby`로 연결됩니다. 둘 다 없는 drawer에는 `aria-label`을 따로 주세요.
- `modal="trap-focus"`는 페이지의 스크롤과 클릭은 남기고 focus만 안에 붙잡습니다.
- `dismissible={false}`는 Esc와 스크림 클릭을 모두 취소합니다. 그런 drawer에는 닫는 action을 반드시 함께 주세요. 다른 출구가 없습니다.
- `inline` drawer는 dialog가 아닙니다. focus를 가져가지도, 가두지도, 알리지도 않습니다. `title`은 평범한 heading이므로 페이지의 heading 순서 안에 놓으세요.
- ×의 접근성 이름은 `locale`이 정합니다. `closeLabel`로 직접 쓸 수도 있습니다.

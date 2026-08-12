---
title: FloatingActionButton
order: 23
---

# FloatingActionButton

<p class="neba-lede">화면이 다루는 단 하나의 행동을, 그 화면 위에 띄워 놓은 둥근 버튼입니다. FAB이라고도 부릅니다. 자식으로 FloatingAction을 넣으면 눌렀을 때 펼쳐지는 작은 액션 묶음이 됩니다.</p>

<Demo src="floating-action-button/hero" minHeight="220" />

```tsx
import { FloatingActionButton } from 'neba';

<FloatingActionButton icon={<PencilIcon />} label="새 글" onClick={compose} />;
```

## Props

<PropsTable name="FloatingActionButton" />

<PropsTable name="FloatingAction" />

나머지 `<div>` 속성은 루트로, 나머지 `<button>` 속성은 각 액션으로 전달됩니다. `onClick`은 버튼 자신의 것입니다.

공통 축(`variant` `size` `color` `density` `elevation` `corner`)의 의미는 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### 액션 펼치기

자식으로 `FloatingAction`을 넣으면 버튼은 다이얼이 됩니다. 누르거나 마우스를 올리면 액션들이 펼쳐지고, 글리프는 ×로 바뀝니다. 각 액션의 이름은 옆의 로젠지에 그려집니다.

`closeOnAction`은 액션을 누른 뒤 다이얼을 닫을지, `showLabels`는 이름을 그릴지, `openOnHover`는 마우스가 머무를 때 열지를 정합니다.

<Demo src="floating-action-button/dial" minHeight="300">

<<< @/.vitepress/demos/floating-action-button/dial.tsx

</Demo>

### extended

`extended`는 `label`을 글리프 옆에 써서 원을 스타디움으로 바꿉니다. 화면이 다루는 행동이 무엇인지 그림만으로 분명하지 않을 때 쓰는 형태입니다. `label`은 두 경우 모두 접근성 이름이므로, 그려지는 말과 읽히는 말이 어긋날 수 없습니다.

<Demo src="floating-action-button/extended" minHeight="120">

<<< @/.vitepress/demos/floating-action-button/extended.tsx

</Demo>

### position, corner, offset

`position`은 기본이 `fixed`로 창의 모서리에 고정합니다. `absolute`는 가장 가까운 positioned 조상의 모서리에 고정하므로 카드나 지도, Mockup의 화면 안에 넣을 때 쓰고, `static`은 흐름 안으로 되돌립니다.

`corner`는 네 모서리 중 하나, `offset`은 양쪽 가장자리에서의 거리입니다. 액션이 펼쳐지는 방향은 `corner`에서 따라오며 `direction`으로 뒤집을 수 있습니다.

<Demo src="floating-action-button/corners" minHeight="340">

<<< @/.vitepress/demos/floating-action-button/corners.tsx

</Demo>

### variant, size, color

버튼 자체는 [Button](./button)이고, 변형과 elevation 사다리, 포인터 조명, 누름의 거동이 모두 그대로입니다. `size`만 한 칸 위에서 시작해 `lg`가 기본입니다 — 보지 않고 엄지로 찾아 누르는 유일한 컨트롤이기 때문입니다. 액션들은 다시 한 칸 아래에서 그려집니다.

<Demo src="floating-action-button/appearance" minHeight="260">

<<< @/.vitepress/demos/floating-action-button/appearance.tsx

</Demo>

### 제어하기

`open`을 넘기면 다이얼은 자체 상태를 갖지 않습니다.

```tsx
const [open, setOpen] = useState(false);

<FloatingActionButton label="공유" open={open} onOpenChange={setOpen}>
  <FloatingAction icon={<LinkIcon />} label="링크 복사" />
</FloatingActionButton>;
```

## 접근성

- `label`은 필수입니다. 그림만으로 된 버튼은 접근성 이름이 아예 없습니다.
- 액션이 있으면 버튼에 `aria-expanded`와, 펼쳐진 묶음을 가리키는 `aria-controls`가 붙습니다. `role="menu"`는 아닙니다 — 메뉴는 세트 전체에 tab 정지점 하나와 방향키 이동, typeahead를 약속하고, 그것이 필요하면 [Menu](./menu)가 그것입니다.
- 액션들은 버튼 바로 다음 순서의 평범한 버튼이므로 tab으로 닿습니다.
- Escape는 다이얼을 닫고 focus를 버튼으로 되돌립니다. 바깥을 누르면 닫힙니다.
- 액션 옆 로젠지는 `aria-hidden`입니다. 같은 문자열이 이미 버튼의 이름이므로 두 번 읽히지 않게 합니다.

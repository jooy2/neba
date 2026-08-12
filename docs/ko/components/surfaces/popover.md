---
title: Popover
order: 11
---

# Popover

<p class="neba-lede">자신을 연 컨트롤 옆에 열리는 시트입니다. Tooltip과 달리 그대로 떠 있고 포인터와 키보드로 닿을 수 있어서, 안의 내용을 누르고 입력할 수 있습니다.</p>

<Demo src="popover/hero" align="center" minHeight="80" />

```tsx
import { Button, Popover } from 'neba';

<Popover trigger={<Button variant="outline">Share</Button>} title="Share this page">
  <TextField size="sm" label="Link" defaultValue="https://…" readOnly />
</Popover>;
```

## Props

<PropsTable name="Popover" />

`PopoverClose`는 Base UI의 `Popover.Close`를 그대로 내보낸 것입니다. `render` prop을 주면 어떤 요소든 자기가 속한 popup을 닫습니다: `<PopoverClose render={<Button>Apply</Button>} />`.

공통 축은 [prop 규칙](../../design/prop-conventions)에서 설명합니다.

## 예시

### side와 align

`side`는 trigger의 어느 변에 popup이 놓일지, `align`은 그 변을 따라 어디에 놓일지입니다. 창에 자리가 없으면 반대쪽으로 자동으로 넘어갑니다. `sideOffset`으로 간격을, `alignOffset`으로 변을 따라 미는 거리를 조절합니다.

<Demo src="popover/sides">

<<< @/.vitepress/demos/popover/sides.tsx

</Demo>

### popup 안의 form

popup은 focus를 받을 수 있는 내용을 담으므로, 필터 패널이나 작은 form, 색 선택기는 [Dialog](../feedback/dialog)가 아니라 여기에 들어갑니다 — form을 채우는 동안 뒤 페이지가 계속 읽힙니다. 내용이 너비를 정해야 할 때는 `width`로 상한을 둡니다.

<Demo src="popover/form">

<<< @/.vitepress/demos/popover/form.tsx

</Demo>

### 제어 컴포넌트

`open`과 `onOpenChange`를 함께 넘기면 state의 주인은 caller가 되므로, 페이지의 다른 무엇이든 이 popup을 열고 닫을 수 있습니다. 넘기지 않으면 popover가 스스로 관리하고 `defaultOpen`이 초기 상태를 정합니다.

<Demo src="popover/controlled">

<<< @/.vitepress/demos/popover/controlled.tsx

</Demo>

### arrow

`arrow`는 trigger를 가리키는 쐐기를 그립니다. 기본은 꺼짐입니다. 이 표면은 흐린 backdrop 위의 반투명이고, popup의 상자 밖으로 튀어나온 쐐기는 그 backdrop을 함께 가져갈 수 없기 때문입니다. trigger가 멀어서 popup이 무엇에 속하는지 말해야 할 때 켜세요.

```tsx
<Popover arrow trigger={<Button>Details</Button>}>
  Anchored to the button it came from.
</Popover>
```

## 접근성

- popup에 `role="dialog"`가 붙습니다. `title`이 이름이 되고 `description`이 설명이 되며 `aria-labelledby`와 `aria-describedby`로 연결됩니다. 둘 다 없는 popover에는 `aria-label`을 따로 주세요.
- 열리면 focus가 popup 안으로 들어가고, 닫히면 trigger로 돌아갑니다.
- Esc로 닫히고 바깥 클릭으로도 닫힙니다. `dismissible={false}`는 둘 다 취소하지만 `PopoverClose`는 통과하므로 갇히지 않습니다.
- `modal`은 기본이 `false`이므로 뒤 페이지는 계속 스크롤되고 쓸 수 있습니다. 다른 것을 건드리기 전에 반드시 답해야 하는 popup에는 `'trap-focus'`를 쓰세요.
- ×의 접근성 이름은 `locale`이 정합니다. `closeLabel`로 직접 쓸 수도 있습니다.

---
title: Tour
order: 12
---

# Tour

<p class="neba-lede">이미 존재하는 페이지 위를 걸으며 안내합니다 — 처음 온 독자에게 한 번은 보여줘야 하는 세 가지를, 그것들이 실제로 있는 자리에서 가리킵니다.</p>

<Demo src="tour/hero" />

```tsx
import { Tour } from 'neba';

<Tour
  open={open}
  onOpenChange={setOpen}
  steps={[
    { target: '#search', title: 'Find anything', content: 'Everything is behind this field.' },
    { target: '#deploy', title: 'Ship it', content: 'Builds the current branch.', side: 'left' }
  ]}
/>;
```

## Props

<PropsTable name="Tour" />

### TourStep

<PropsTable name="TourStep" />

[HowToSteps](../surfaces/how-to-steps)를 뒤집은 것입니다. 그쪽은 설명을 페이지 _안에_ 두고 독자가 따라가게 하고, 이쪽은 페이지를 그대로 둔 채 그 위에 섭니다. 그래서 단계는 selector로 지정합니다 — tour가 말하는 대상은 이미 화면에 있고, 카드 안에서 한 번 더 설명하면 관리해야 할 사본이 둘이 됩니다.

## 예시

### steps · target

각 단계는 CSS selector로 대상을 지목하며, 그 시점의 페이지에 대해 조회됩니다. `target`이 없는 단계는 아무것도 도려내지 않은 채 가운데에 놓입니다 — 환영 단계와 마무리 단계가 그런 것입니다.

<Demo src="tour/centred">

<<< @/.vitepress/demos/tour/centred.tsx

</Demo>

### open · step

`open`은 tour를 실행하고 `step`은 몇 번째 지점인지입니다. 둘 다 uncontrolled 짝이 있고 둘 다 변화를 보고합니다. `onFinish`는 마지막 단계의 버튼을 눌렀을 때, tour가 닫히기 전에 호출됩니다.

### mask

페이지를 어둡게 하고 대상만 그 어둠에서 도려냅니다. 어두운 층은 포인터를 가로채지 않으므로 가리키는 대상을 그대로 쓸 수 있습니다. 이것이 tour와 dialog의 연속을 가르는 차이입니다.

<Demo src="tour/mask">

<<< @/.vitepress/demos/tour/mask.tsx

</Demo>

### locale과 라벨

버튼과 카운터의 문구는 `locale`에서 옵니다. `previousLabel`, `nextLabel`, `doneLabel`, `skipLabel`로 각각을 직접 쓸 수 있습니다.

### className · classNames

`className`은 카드 — 각 step이 쓰이는 popup — 에 붙습니다. 그 뒤의 dimming은 popup의 자손이 아니라 형제라서 `classNames.mask`로만 닿습니다.

```tsx
<Tour
  steps={steps}
  className="max-w-sm"
  classNames={{ mask: 'bg-black/70', footer: 'justify-between' }}
/>
```

slot은 `mask`, `title`, `description`, `close`, `footer`입니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

## 접근성

- 카드는 제목이 이름이 되고 본문이 설명이 되는 dialog이며, 각 단계가 열릴 때 focus가 그 안으로 옮겨갑니다.
- `dismissible`을 끄지 않는 한 Escape로 tour가 끝납니다. 바깥을 누르는 것으로는 끝나지 않습니다 — 페이지를 쓰는 것이 tour의 목적이기 때문입니다.
- tour가 어떤 것에 이르는 유일한 통로가 되어서는 안 됩니다. tour가 가리키는 것은 tour 없이도 찾을 수 있어야 합니다. 이미 닫아버린 독자나 애초에 보지 못한 독자에게 두 번째 기회는 없습니다.

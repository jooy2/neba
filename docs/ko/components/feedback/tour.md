---
title: Tour
order: 12
flutter: true
---

# Tour

<p class="neba-lede">이미 만들어진 페이지 위에서 단계별로 안내합니다. 처음 온 독자에게 한 번은 보여 줘야 하는 것들을, 실제로 있는 자리에서 가리킵니다.</p>

<Demo src="tour/hero" minHeight="360" />

::: fw react

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

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaTour(
  open: open,
  onOpenChange: (bool next) => setState(() => open = next),
  steps: <NebaTourStep>[
    NebaTourStep(
      target: searchKey,
      title: const Text('Find anything'),
      content: const Text('Everything is behind this field.'),
    ),
    NebaTourStep(
      target: deployKey,
      title: const Text('Ship it'),
      content: const Text('Builds the current branch.'),
      side: NebaSide.left,
    ),
  ],
);
```

:::

## Props

<PropsTable name="Tour" />

::: fw flutter

카드와 dimming은 앱의 root `Overlay`에 그려지고, tour를 쓴 자리는 공간을 차지하지 않습니다. 각 단계는 React의 CSS selector 대신 대상 위젯을 만들 때 준 `GlobalKey`로 대상을 지목합니다. lazy하게 만들어지는 목록 안의 대상은 만들어져 있어야 찾을 수 있습니다. 위젯은 class를 받지 않으므로 `className`과 `classNames`에 해당하는 것은 없습니다.

:::

### TourStep

<PropsTable name="TourStep" />

## 예시

### steps · target

::: fw react

각 단계는 CSS selector로 대상을 지목하며, 그 시점의 페이지에 대해 조회됩니다. `target`이 없는 단계는 아무것도 도려내지 않은 채 가운데에 놓입니다. 환영 단계와 마무리 단계가 그런 것입니다.

:::

::: fw flutter

각 단계는 대상을 만들 때 준 `GlobalKey`로 대상을 지목하며, 페이지가 스크롤되거나 대상이 움직이면 카드가 따라갑니다. `target`이 없는 단계는 아무것도 도려내지 않은 채 가운데에 놓입니다. 환영 단계와 마무리 단계가 그런 것입니다.

:::

<Demo src="tour/centred" minHeight="280">

::: fw react

<<< @/.vitepress/demos/tour/centred.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tour/centred.dart

:::

</Demo>

### open · step

`open`은 tour를 실행하고 `step`은 몇 번째 지점인지입니다. 둘 다 uncontrolled 짝이 있고 둘 다 변화를 보고합니다. `onFinish`는 마지막 단계의 버튼을 눌렀을 때, tour가 닫히기 전에 호출됩니다.

### mask

페이지를 어둡게 하고 대상만 그 어둠에서 도려냅니다. 어두운 층은 포인터를 가로채지 않으므로 가리키는 대상을 그대로 쓸 수 있습니다.

<Demo src="tour/mask" minHeight="300">

::: fw react

<<< @/.vitepress/demos/tour/mask.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tour/mask.dart

:::

</Demo>

### locale과 라벨

버튼과 카운터의 문구는 `locale`에서 옵니다. `previousLabel`, `nextLabel`, `doneLabel`, `skipLabel`로 각각을 직접 쓸 수 있습니다.

::: fw react

### className · classNames

`className`은 카드(각 step이 쓰이는 popup)에 붙습니다. 그 뒤의 dimming은 popup의 자손이 아니라 형제라서 `classNames.mask`로만 닿습니다.

```tsx
<Tour
  steps={steps}
  className="max-w-sm"
  classNames={{ mask: 'bg-black/70', footer: 'justify-between' }}
/>
```

slot은 `mask`, `title`, `description`, `close`, `footer`입니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

:::

## 접근성

::: fw react

- 카드는 제목이 이름이 되고 본문이 설명이 되는 dialog입니다. 단계를 바꿔도 focus는 누른 버튼에 그대로 남습니다.
- Next와 Previous는 카드를 제자리에서 바꾸므로, 새 단계를 polite live region이 "Step 2: Deploy"처럼 읽어 줍니다.
- `dismissible`을 끄지 않는 한 Escape로 tour가 끝납니다. 카드 바깥을 누르는 것으로는 끝나지 않습니다.
- tour가 어떤 것에 이르는 유일한 통로가 되어서는 안 됩니다. tour가 가리키는 것은 tour 없이도 찾을 수 있어야 합니다. 이미 닫아버린 독자나 애초에 보지 못한 독자에게 두 번째 기회는 없습니다.

:::

::: fw flutter

- 카드는 제목이 이름이 되는 dialog이며, screen reader는 제목을 heading으로 읽습니다. tour가 시작되면 focus가 카드 안으로 들어가고 끝나면 원래 자리로 돌아갑니다. 단계를 바꿔도 focus는 누른 버튼에 그대로 남습니다.
- Next와 Previous는 카드를 제자리에서 바꾸므로, 새 단계를 live region이 "Step 2: Deploy"처럼 읽어 줍니다.
- `dismissible`을 끄지 않는 한 focus가 어디에 있든 Escape로 tour가 끝납니다. 카드 바깥을 누르거나 focus가 카드를 떠나는 것으로는 끝나지 않습니다.
- tour가 어떤 것에 이르는 유일한 통로가 되어서는 안 됩니다. tour가 가리키는 것은 tour 없이도 찾을 수 있어야 합니다. 이미 닫아버린 독자나 애초에 보지 못한 독자에게 두 번째 기회는 없습니다.

:::

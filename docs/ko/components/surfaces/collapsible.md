---
title: Collapsible
order: 13
flutter: true
---

# Collapsible

<p class="neba-lede">혼자 서 있는 접이식 섹션 하나입니다. 헤더를 누르면 그 아래 내용이 열리고, 다시 누르면 닫힙니다. 여러 개를 묶어 하나만 열리게 해야 한다면 그것은 Accordion입니다.</p>

<Demo src="collapsible/hero" />

::: fw react

```tsx
import { Collapsible } from 'neba';

<Collapsible title="배송과 반품">
  <p>오후 2시 이전 주문은 당일 출고됩니다.</p>
</Collapsible>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaCollapsible(
  title: Text('배송과 반품'),
  child: Text('오후 2시 이전 주문은 당일 출고됩니다.'),
);
```

:::

## Props

<PropsTable name="Collapsible" />

::: fw react

나머지 `<div>` 속성은 모두 루트로 전달됩니다. 예외는 `onChange` 하나로, 여기서 들을 만한 변화는 `onOpenChange`입니다.

:::

::: fw flutter

슬롯은 모두 위젯이고 본문은 `child`입니다. 패널은 담은 내용의 높이까지 열리고 높이 0까지 닫히며, 기본 duration과 ease를 따르고 transform은 쓰지 않습니다. 움직임을 줄여 달라고 한 사용자에게는 바로 열립니다.

:::

공통 축(`variant` `size` `color` `density` `elevation`)의 의미는 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### title, subtitle, startIcon, action

`title`은 헤더의 제목, `subtitle`은 그 아래 줄입니다. 둘 다 줄바꿈되며, `lines`를 주면 그 줄 수에서 말줄임표로 자릅니다. `startIcon`은 제목 앞에 놓이고, `action`은 헤더 끝에 놓이되 trigger 바깥입니다. 접는 헤더와 그 위의 스위치는 누를 것이 둘이므로, 하나가 다른 하나 안에 들어갈 수 없습니다.

<Fw react="indicator={false}" flutter="indicator: false" code />는 chevron을 지웁니다. 그러면 헤더는 색으로만 상태를 말합니다.

<Demo src="collapsible/slots">

::: fw react

<<< @/.vitepress/demos/collapsible/slots.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/collapsible/slots.dart

:::

</Demo>

### <Fw react="trigger" flutter="triggerBuilder" />

::: fw react

`trigger`는 헤더를 직접 만든 컨트롤로 통째로 갈아 끼웁니다. 넘긴 요소가 곧 trigger가 되어 클릭 핸들러와 `aria-expanded`, 패널을 가리키는 `aria-controls`를 받으므로 따로 연결할 것이 없습니다.

:::

::: fw flutter

`triggerBuilder`는 헤더를 직접 만든 컨트롤로 통째로 갈아 끼웁니다. 패널이 열렸는지와 여닫는 콜백을 받아 호출되며, 콜백은 Collapsible이 `disabled`일 때 `null`입니다. 그래서 이 콜백을 `onPressed`로 받은 `NebaButton`은 저절로 비활성화됩니다. 화면 낭독기는 이 컨트롤을 펼쳐짐이나 접힘으로 읽습니다. trigger는 원래 헤더처럼 Collapsible의 너비를 다 차지합니다.

:::

<Demo src="collapsible/trigger">

::: fw react

<<< @/.vitepress/demos/collapsible/trigger.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/collapsible/trigger.dart

:::

</Demo>

### variant

세 무게는 다른 컨테이너에서와 같은 말을 합니다. `text`는 시트를 아예 그리지 않으므로 본문 한가운데나 이미 시트인 Card 안의 fold에 맞습니다.

<Demo src="collapsible/variants">

::: fw react

<<< @/.vitepress/demos/collapsible/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/collapsible/variants.dart

:::

</Demo>

### <Fw react="keepMounted, hiddenUntilFound" flutter="keepMounted" />

::: fw react

기본적으로 닫힌 패널은 `hidden="until-found"`로 DOM에 남습니다. 서버 렌더에 포함되고, 브라우저의 페이지 내 찾기가 찾아 패널을 열 수 있습니다. `hiddenUntilFound={false}`를 주면 닫힌 패널이 DOM에서 빠집니다. `keepMounted`는 찾기에 걸리지 않게 남겨 두므로, 만드는 비용이 크거나 폼 상태를 쥐고 있는 내용이 접혔다 펴져도 그대로입니다. `hiddenUntilFound`가 `keepMounted`보다 우선합니다.

:::

::: fw flutter

닫힌 패널은 기본적으로 내용을 빌드된 채로 남겨 두므로, 안에 있는 필드는 접혔다 펴져도 입력한 값을 그대로 갖습니다. `keepMounted: false`를 주면 패널이 닫혀 있는 동안 내용을 버립니다. 만드는 비용이 크고 열려 있을 때만 있으면 되는 내용에 씁니다. `hiddenUntilFound`는 없습니다. Flutter 화면에는 페이지 내 찾기도 서버 렌더도 없고, 닫힌 패널을 빌드된 채로 두는 것은 React에서 이 prop의 기본값이 하는 일과 같습니다.

:::

<Demo src="collapsible/mounting">

::: fw react

<<< @/.vitepress/demos/collapsible/mounting.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/collapsible/mounting.dart

:::

</Demo>

### 제어하기

`open`을 넘기면 Collapsible은 자체 상태를 갖지 않습니다. 여러 개를 한 번에 여닫거나, 열린 상태를 URL에 담거나, 페이지의 다른 자리에 있는 컨트롤로 열 때 씁니다.

::: fw react

```tsx
const [open, setOpen] = useState(false);

<Collapsible title="고급 설정" open={open} onOpenChange={setOpen}>
  <p>여기에 나머지가 들어갑니다.</p>
</Collapsible>;
```

:::

::: fw flutter

```dart
NebaCollapsible(
  title: const Text('고급 설정'),
  open: open,
  onOpenChange: (bool next) => setState(() => open = next),
  child: const Text('여기에 나머지가 들어갑니다.'),
);
```

:::

## 접근성

::: fw react

- trigger는 실제 `<button>`이고, 자신이 여는 패널을 가리키는 `aria-expanded`와 `aria-controls`를 갖습니다.
- `action`은 trigger 바깥에 있으므로 키보드로 따로 접근하고 누를 수 있습니다.
- 닫힌 패널은 찾기 전까지 숨겨져 있든, `keepMounted`로 남아 있든, DOM에서 빠져 있든 tab 순서에도 접근성 트리에도 없습니다.
- `hiddenUntilFound`를 끄지 않는 한 브라우저의 페이지 내 찾기가 닫힌 내용을 찾아 패널을 열 수 있습니다.

:::

::: fw flutter

- 화면 낭독기는 trigger를 펼쳐졌거나 접힌 버튼으로 읽고, 제목과 부제목을 그 이름으로 읽습니다. Enter와 Space로 여닫습니다.
- `action`은 trigger 바깥에 있으므로 키보드로 따로 접근하고 누를 수 있습니다.
- 닫힌 패널은 빌드된 채로 남아 있든 아니든, 닫히기 시작한 순간부터 focus 순서에도 semantics 트리에도 없습니다.

:::

---
title: Collapsible
order: 13
---

# Collapsible

<p class="neba-lede">혼자 서 있는 접이식 섹션 하나입니다. 헤더를 누르면 그 아래 내용이 열리고, 다시 누르면 닫힙니다. 여러 개를 묶어 하나만 열리게 해야 한다면 그것은 Accordion입니다.</p>

<Demo src="collapsible/hero" />

```tsx
import { Collapsible } from 'neba';

<Collapsible title="배송과 반품">
  <p>오후 2시 이전 주문은 당일 출고됩니다.</p>
</Collapsible>;
```

## Props

<PropsTable name="Collapsible" />

나머지 `<div>` 속성은 모두 루트로 전달됩니다. 예외는 `onChange` 하나로, 여기서 들을 만한 변화는 `onOpenChange`입니다.

공통 축(`variant` `size` `color` `density` `elevation`)의 의미는 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### title, subtitle, startIcon, action

`title`은 헤더의 제목, `subtitle`은 그 아래 한 줄입니다. `startIcon`은 제목 앞에 놓이고, `action`은 헤더 끝에 놓이되 trigger 바깥입니다. 접는 헤더와 그 위의 스위치는 누를 것이 둘이므로, 하나가 다른 하나 안에 들어갈 수 없습니다.

`indicator={false}`는 chevron을 지웁니다. 그러면 헤더는 색으로만 상태를 말합니다.

<Demo src="collapsible/slots">

<<< @/.vitepress/demos/collapsible/slots.tsx

</Demo>

### trigger

`trigger`는 헤더를 직접 만든 컨트롤로 통째로 갈아 끼웁니다. 넘긴 요소가 곧 trigger가 되어 클릭 핸들러와 `aria-expanded`, 패널을 가리키는 `aria-controls`를 받으므로 따로 연결할 것이 없습니다.

<Demo src="collapsible/trigger">

<<< @/.vitepress/demos/collapsible/trigger.tsx

</Demo>

### variant

세 무게는 다른 컨테이너에서와 같은 말을 합니다. `text`는 시트를 아예 그리지 않으므로 본문 한가운데나 이미 시트인 Card 안의 fold에 맞습니다.

<Demo src="collapsible/variants">

<<< @/.vitepress/demos/collapsible/variants.tsx

</Demo>

### keepMounted, hiddenUntilFound

기본적으로 닫힌 패널은 DOM에서 빠집니다. `keepMounted`는 그것을 남겨 두므로, 만드는 비용이 크거나 폼 상태를 쥐고 있는 내용이 접혔다 펴져도 그대로입니다. `hiddenUntilFound`는 `hidden="until-found"`로 남겨 브라우저의 페이지 내 찾기가 찾아 열 수 있게 하며, `keepMounted`보다 우선합니다.

<Demo src="collapsible/mounting">

<<< @/.vitepress/demos/collapsible/mounting.tsx

</Demo>

### 제어하기

`open`을 넘기면 Collapsible은 자체 상태를 갖지 않습니다. 여러 개를 한 번에 여닫거나, 열린 상태를 URL에 담거나, 페이지의 다른 자리에 있는 컨트롤로 열 때 씁니다.

```tsx
const [open, setOpen] = useState(false);

<Collapsible title="고급 설정" open={open} onOpenChange={setOpen}>
  <p>여기에 나머지가 들어갑니다.</p>
</Collapsible>;
```

## 접근성

- trigger는 실제 `<button>`이고, 자신이 여는 패널을 가리키는 `aria-expanded`와 `aria-controls`를 갖습니다.
- `action`은 trigger 바깥에 있으므로 키보드로 따로 접근하고 누를 수 있습니다.
- 닫힌 패널은 DOM에서 빠지므로 tab 순서에도 접근성 트리에도 없습니다. `keepMounted`로 남겨 두어도 마찬가지입니다.
- `hiddenUntilFound`를 켜면 브라우저의 페이지 내 찾기가 닫힌 내용을 찾아 패널을 열 수 있습니다.

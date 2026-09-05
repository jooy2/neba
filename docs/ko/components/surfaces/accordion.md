---
title: Accordion
order: 3
---

# Accordion

<p class="neba-lede">접었다 펼 수 있는 섹션을 쌓아 놓습니다. 긴 내용을 제목만 보이게 접어 두고 필요한 것만 펼칠 때 씁니다.</p>

<Demo src="accordion/hero" />

```tsx
import { Accordion, AccordionItem } from 'neba';

<Accordion defaultValue={['billing']}>
  <AccordionItem value="billing" title="결제는 어떻게 되나요?" subtitle="요금제와 청구서">
    매달 1일에 청구됩니다.
  </AccordionItem>
  <AccordionItem value="regions" title="빌드는 어디서 도나요?">
    기본 브랜치에 가장 가까운 리전에서 돕니다.
  </AccordionItem>
</Accordion>;
```

## Props

### Accordion

<PropsTable name="Accordion" />

`value`와 `onValueChange`로 controlled, `defaultValue`로 uncontrolled 컴포넌트가 됩니다. 값은 열려 있는 항목의 `value` 배열입니다.

### AccordionItem

<PropsTable name="AccordionItem" />

## 예시

### variant

sheet는 색으로 채워지지 않습니다. [Card](./card) 안에 넣을 때는 `text`를 쓰세요. Card가 이미 sheet이므로 테두리가 겹치지 않습니다.

<Demo src="accordion/variants">

<<< @/.vitepress/demos/accordion/variants.tsx

</Demo>

### multiple · dividers · action

`multiple`의 기본값은 꺼짐이며, 하나를 열면 열려 있던 것이 닫힙니다. 섹션들이 서로 배타적인 답이 아니라 체크리스트라면 켜세요.

`dividers`는 섹션 사이에 선을 그어 여러 항목을 한 덩어리로 묶습니다. `action`은 접는 버튼 **바깥**에 놓이는 컨트롤 자리이므로, 헤더에 스위치를 두면서 헤더 자체를 눌러 접을 수 있습니다.

<Demo src="accordion/behaviour">

<<< @/.vitepress/demos/accordion/behaviour.tsx

</Demo>

### size

<Demo src="accordion/sizes">

<<< @/.vitepress/demos/accordion/sizes.tsx

</Demo>

### hiddenUntilFound과 keepMounted

`hiddenUntilFound`는 닫힌 패널을 DOM에 남겨 브라우저의 find-on-page가 찾아 펼칠 수 있게 합니다. FAQ 페이지에 적합합니다. `keepMounted`는 닫힌 패널의 React 트리를 유지합니다.

## 접근성

- 헤더 버튼과 패널이 `aria-controls` · `aria-expanded`로 연결됩니다.
- `title`에 `title={<h3>결제</h3>}`처럼 실제 heading을 넘기면 문서 개요에 들어갑니다. 넘긴 heading은 Accordion의 타입 스케일을 물려받습니다.
- 패널은 `height`를 애니메이션하며 열립니다. 내용이 패널 안에서 이동하지는 않습니다.

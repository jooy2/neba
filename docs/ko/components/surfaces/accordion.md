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

### headingLevel · lines

`headingLevel`은 모든 섹션 헤더의 heading 단계를 스택 전체에 한 번에 정합니다. `<h2>` 아래라면 `3`, `<h3>` 아래라면 `4`를 쓰세요.

섹션의 `lines`는 제목과 부제목을 그 줄 수에서 자릅니다. 지정하지 않으면 둘 다 줄바꿈해서 다 보여 줍니다.

```tsx
<Accordion headingLevel={2}>
  <AccordionItem lines={2} title="계정을 지우면 데이터는 어떻게 되나요?">
    …
  </AccordionItem>
</Accordion>
```

### hiddenUntilFound과 keepMounted

`hiddenUntilFound`는 기본으로 켜져 있습니다. 닫힌 패널이 `hidden="until-found"`로 DOM에 남으므로 답변이 서버 렌더와 크롤러 색인에 들어가고, 브라우저의 find-on-page가 찾아 섹션을 펼칠 수 있습니다. 만드는 비용이 크고 열려 있을 때만 있으면 되는 패널이면 끄세요. 그때 `keepMounted`를 주면 찾기에는 걸리지 않으면서 닫힌 패널의 React 트리를 유지합니다.

## 접근성

- 헤더 버튼과 패널이 `aria-controls` · `aria-expanded`로 연결됩니다.
- 각 헤더가 `headingLevel`(기본값 `3`) 단계의 실제 heading 요소라서 섹션이 문서 개요에 들어갑니다. `title`에는 일반 텍스트를 넘기세요. heading을 넘기면 그 안에 또 들어갑니다.

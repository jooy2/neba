---
title: Accordion
order: 3
---

# Accordion

<p class="neba-lede">접었다 펼 수 있는 섹션들의 더미. 하나를 열면 하나가 닫힙니다.</p>

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

### AccordionItem

<PropsTable name="AccordionItem" />

## 예시

### Variant

시트는 절대 물들지 않습니다 — [Box](./box), [List](../display/list)와 같습니다. 컨테이너는 다른 사람의 콘텐츠를 담고, 그 콘텐츠는 자기 색을 갖고 도착합니다. 카드 안에 넣을 때는 `text`가 정답입니다: 카드는 이미 시트이고, 그 안의 두 번째 테두리 사각형은 그냥 두 번째 사각형입니다.

<Demo src="accordion/variants">

<<< @/.vitepress/demos/accordion/variants.tsx

</Demo>

### multiple, dividers, 그리고 헤더 옆의 컨트롤

<Demo src="accordion/behaviour">

<<< @/.vitepress/demos/accordion/behaviour.tsx

</Demo>

### 크기

<Demo src="accordion/sizes">

<<< @/.vitepress/demos/accordion/sizes.tsx

</Demo>

## `multiple`이 기본으로 꺼져 있는 이유

이것이 아코디언과 접이식 목록 더미의 차이 전부입니다. 다음 것을 열면서 마지막 것을 닫는 동작이 페이지가 독자 아래에서 자라나지 않게 막습니다. 섹션들이 서로 배타적인 답이 아니라 체크리스트라면 `multiple`을 켜세요.

`dividers`는 [List](../display/list)와 기본값이 반대입니다. 타일들의 목록은 목록이지만, 타일들의 아코디언은 마침 접히기도 하는 카드 더미입니다. 실선은 섹션들이 한 덩어리의 부분들이라고 말해 줍니다.

## 높이는 움직입니다. transform은 아닙니다

패널의 `height`는 애니메이션됩니다. [움직임을 금지하는 규칙](../../guide/design-language)의 예외처럼 보이지만 아닙니다.

transform이 없고, 다시 샘플링되는 글자가 없고, 내용이 자기가 든 패널에 대해 자리를 옮기지도 않습니다 — 패널이 내용 위로 열리는 창일 뿐입니다. 반대로 섹션이 즉시 나타나는 아코디언은 튀는 페이지이고, 그건 애초에 그 규칙이 막으려던 실패입니다.

## 헤더는 하나가 아니라 둘입니다

`action`은 접는 버튼 **바깥**에 놓입니다. 접히기도 하고 스위치도 든 헤더에는 누를 것이 두 개 있는데, 그중 하나를 다른 하나 안에 넣을 수는 없습니다 — `<button>` 안의 `<button>`은 브라우저가 파싱하면서 고쳐 쓰는 마크업입니다. [Chip](../display/chip)과 [ListItem](../display/list)이 쓰는 것과 같은 구조입니다.

## 접근성

Base UI가 `button` / `region` 짝과 그 사이의 `aria-controls` / `aria-expanded` 배선을 소유합니다. 여기서 신경 쓸 것은 `title`을 실제 헤딩으로 줄지입니다 — 문서 개요에 들어가야 하는 섹션이라면 `title={<h3>결제</h3>}`처럼 주세요. `.neba-title`이 브라우저의 기본 크기와 여백을 걷어내므로 타입 스케일은 그대로 유지됩니다.

`hiddenUntilFound`는 닫힌 패널을 DOM에 남겨 브라우저의 페이지 내 검색이 찾아서 펼칠 수 있게 합니다. FAQ 페이지라면 켜 둘 만합니다.

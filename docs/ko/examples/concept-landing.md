---
title: 랜딩 페이지
order: 2
aside: false
---

# 랜딩 페이지

<p class="neba-lede">실재하지 않는 제품 분석 도구 Kestrel의 소개 페이지입니다. 대부분이 타이포그래피와 여백, 그리고 반복되는 하나의 call to action이라 컴포넌트 라이브러리가 가장 덜 필요해 보이는 화면이고, 그래서 부품들이 서로 잘 맞물리는지 가장 잘 드러납니다.</p>

<Demo src="concepts/landing" min-height="640px" />

소스는 `docs/.vitepress/demos/concepts/landing.tsx` 한 파일입니다. 화면에 있는 것은 전부 Neba 컴포넌트이고, 컴포넌트인 척하는 맨 `div`는 없습니다.

## 무엇으로 만들었는지

| 블록 | 사용된 컴포넌트 | 볼 만한 것 |
| --- | --- | --- |
| 공지 바 | `Pill` | `onClick`이 붙은 `Pill`은 버튼이 되므로, 추가 마크업 없이 키보드로 닿습니다 |
| 헤더 | `Toolbar` `Icon` `Button` `IconButton` `Tooltip` | `render={<header />}`로 실제 landmark가 되고, 내비게이션 링크는 `variant="text"` 버튼이라 한 기준선에 놓입니다 |
| 히어로 | `Typography` `Chip` `Button` `Avatar` `Highlight` | `Typography`는 타입 스케일과 엘리먼트를 함께 정하므로 `level="h1"`은 실제 `<h1>`입니다 |
| 신뢰 표시줄 | `Divider` `Typography` | children을 가진 `Divider`가 섹션 라벨을 품어서, 선과 제목이 하나의 요소가 됩니다 |
| 수치 | `GridContainer` `Grid` `Statistic` | `unit`, `prefix`, `previousValue`로 한 줄에 놓인 서로 다른 형태의 수치를 모두 담습니다 |
| 기능 | `Card` `Icon` | 아이콘은 `headerAction`에 들어가므로 어느 `size`에서도 제목의 기준선에 맞습니다 |
| 제품 둘러보기 | `Tabs` `ProgressLinear` `List` `Chip` | 같은 데이터를 세 가지로 보여줍니다. 퍼널은 차트가 아니라 `showValue`를 켠 `ProgressLinear`입니다 |
| 인용 | `Blockquote` | `author`와 `source`가 별도 슬롯이라 모바일에서 두 줄로 자연스럽게 접힙니다 |
| 가격 | `SegmentedButton` `Card` `List` `Table` | 결제 주기 토글은 segmented control이고, 비교표는 열 목록으로 그려집니다 |
| 자주 묻는 질문 | `Accordion` | 질문 하나에 `AccordionItem` 하나, 처음에는 전부 닫힌 상태입니다 |
| 마무리 CTA | `Card` `TextField` `Button` | 페이지에서 유일한 필드이고, 자체 submit을 가진 실제 `<form>` 안에 있습니다 |
| 푸터 | `Divider` `Grid` `List` `Button` | 링크 열은 각 행에 `href`를 준 `List`라서 앵커로 렌더링됩니다 |

## 참고

- 페이지 전체는 `<main>` 위의 `Container maxWidth="xl"` 하나로 폭이 정해집니다. 안쪽에서 따로 페이지 폭을 잡는 곳은 없습니다.
- 색은 강조가 아니라 의미를 나릅니다. 추천 플랜만 `color="primary"`에 `elevation={2}`이고, 나머지 둘은 `secondary`에 그림자가 없습니다.
- 이메일 필드는 입력할 때마다 검사하지만 `error`는 무언가 입력된 뒤에만 보여주므로, 빈 폼이 빨갛게 되는 일은 없습니다.

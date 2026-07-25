---
title: List
order: 5
---

# List

<p class="neba-lede">행의 묶음. 내비게이션, 설정, 검색 결과 — 반복되는 것이라면 무엇이든.</p>

<Demo src="list/hero" />

```tsx
import { List, ListItem } from 'neba';

<List>
  <ListItem startIcon={<GlobeIcon />} description="4분 전 배포" onClick={open} selected>
    production
  </ListItem>
  <ListItem startIcon={<GlobeIcon />} description="2시간 전 배포" onClick={open}>
    staging
  </ListItem>
</List>;
```

## List

<PropsTable name="List" />

## ListItem

<PropsTable name="ListItem" />

## 예시

### 타일이냐, 선이냐

`dividers`는 들리는 것보다 많이 바꿉니다. 선을 켜면 그 선이 시트 양끝까지 닿아야 하므로, 목록은 안쪽 여백을 내놓고 행은 둥근 모서리를 내놓습니다. 행이 떠 있는 타일이면서 동시에 그어진 선일 수는 없습니다.

<Demo src="list/dividers">

<<< @/.vitepress/demos/list/dividers.tsx

</Demo>

### Card 안에서

거기서는 `variant="text"`를 쓰세요. 카드가 이미 시트이고, 그 안의 두 번째 테두리 사각형은 하나가 너무 많습니다.

<Demo src="list/variants">

<<< @/.vitepress/demos/list/variants.tsx

</Demo>

### 컨트롤이 붙은 행

`action`이 누를 수 있는 영역 **바깥**에 있는 것은 의도입니다. 이동도 하고 스위치도 든 행에는 누를 것이 둘 있고, 그중 하나를 다른 하나 안에 넣을 수는 없습니다. `<button>` 안의 `<button>`은 브라우저가 파싱하면서 고쳐 쓰는 마크업입니다.

<Demo src="list/interactive">

<<< @/.vitepress/demos/list/interactive.tsx

</Demo>

## 두 컴포넌트, 각자 하나의 축

`size`와 `density`는 그 안의 어느 한 줄이 아니라 묶음 전체의 성질이므로 `List`에 살고, 컨텍스트를 타고 행에 닿습니다. 행마다 지정하게 하면 행마다 두 번씩 틀릴 기회가 생기고, 그 실패는 조용합니다 — 네 번째 항목만 한 치수 큰 목록.

`React.Children.map` + `cloneElement`가 아니라 컨텍스트인 이유는 [ButtonGroup](../inputs/button-group)과 같습니다. 호출자가 데이터를 `.map()`하거나 행 하나를 [Tooltip](../feedback/tooltip)으로 감싸는 순간 복제는 항목에 닿지 못합니다.

## 아래에 프리미티브가 없습니다

일부러 Base UI 컴포넌트를 쓰지 않았습니다. 목록은 복합 위젯이 아닙니다. 로빙 포커스도, 선택 모델도, 자기만의 키보드 규약도 없습니다. 그걸 얻겠다고 menu나 listbox 프리미티브를 가져오면, 소비자가 만든 평범한 링크 목록 전부에 메뉴의 의미론이 붙습니다. 컴포넌트 라이브러리가 스크린 리더를 망가뜨리는 가장 흔한 방법 중 하나입니다.

## 접근성

셸은 언제나 `<li>`입니다. 바뀌는 것은 그 안입니다. 그냥 내용이 들어가거나, `onClick`이나 `href`가 주어지면 그것을 감싼 진짜 `<button>` 또는 `<a>`가 들어갑니다.

`selected`는 링크에 `aria-current="page"`를, 버튼에 `aria-current="true"`를 붙입니다. `aria-pressed`가 아닙니다. 그것은 세 번째 것 — 토글 — 이고, 고른 행은 토글이 아닙니다.

목록은 `role="list"`를 소리 내어 말합니다. Tailwind의 리셋이 모든 `<ul>`에서 불릿을 떼고, Safari는 그와 함께 목록이라는 의미까지 떼어 가기 때문입니다.

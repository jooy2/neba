---
title: List
order: 5
---

# List

<p class="neba-lede">같은 형태의 행을 세로로 쌓는 컴포넌트입니다. 내비게이션, 설정 항목, 검색 결과처럼 반복되는 목록에 씁니다.</p>

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

## Props

### List

<PropsTable name="List" />

`size`와 `density`는 `List`에만 지정합니다. context를 통해 모든 `ListItem`에 전달되므로 행마다 반복할 필요가 없습니다.

### ListItem

<PropsTable name="ListItem" />

## 예시

### dividers

`dividers`를 켜면 행 사이에 선이 그려집니다. 선이 sheet 양끝까지 닿아야 하므로 목록의 안쪽 여백과 행의 둥근 모서리가 함께 사라지고, 행은 떠 있는 타일이 아니라 구획된 줄로 바뀝니다.

<Demo src="list/dividers">

<<< @/.vitepress/demos/list/dividers.tsx

</Demo>

### variant

[Card](../surfaces/card) 안에 넣을 때는 `variant="text"`를 쓰세요. Card가 이미 sheet이므로 테두리가 겹치지 않습니다.

<Demo src="list/variants">

<<< @/.vitepress/demos/list/variants.tsx

</Demo>

### onClick · href · action

`onClick`이나 `href`를 주면 행 전체가 각각 `<button>` 또는 `<a>`가 됩니다. `action`은 그 클릭 영역 **바깥**에 놓이는 별도의 컨트롤 자리입니다. 행을 눌러 이동하면서 오른쪽 스위치는 따로 조작해야 하는 경우를 위한 것입니다.

<Demo src="list/interactive">

<<< @/.vitepress/demos/list/interactive.tsx

</Demo>

## 접근성

- `List`는 `role="list"`를 명시합니다. Tailwind의 reset이 `<ul>`의 불릿을 제거하면 Safari가 목록이라는 의미까지 함께 잃기 때문입니다.
- `ListItem`의 겉은 항상 `<li>`이고, `onClick`이나 `href`에 따라 그 안에 `<button>` 또는 `<a>`가 들어갑니다.
- `selected`는 링크에 `aria-current="page"`, 버튼에 `aria-current="true"`를 붙입니다. 선택된 행은 toggle이 아니므로 `aria-pressed`는 쓰지 않습니다.

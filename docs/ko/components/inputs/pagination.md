---
title: Pagination
order: 11
---

# Pagination

<p class="neba-lede">여러 페이지로 나뉜 목록에서 페이지를 이동하는 컨트롤입니다. 각 번호는 Button으로 렌더링됩니다.</p>

<Demo src="pagination/hero" />

```tsx
import { Pagination } from 'neba';

<Pagination count={24} page={page} onPageChange={setPage} showEdges />;
```

## Props

<PropsTable name="Pagination" />

`count`가 `1`이면 아무것도 렌더링하지 않습니다.

## 예시

### variant

`variant`는 페이지 버튼이 선택되지 않은 상태의 모습입니다. 현재 페이지는 `variant`와 무관하게 항상 채워집니다.

기본값은 [Button](./button)과 달리 `text`입니다. 한 줄에 채워진 버튼이 여러 개 있으면 어느 것이 현재 페이지인지 구분되지 않습니다.

<Demo src="pagination/variants">

<<< @/.vitepress/demos/pagination/variants.tsx

</Demo>

### siblingCount · boundaryCount · showEdges · showArrows

`siblingCount`는 현재 페이지 양옆에 보일 번호 개수, `boundaryCount`는 처음과 끝에 항상 보일 번호 개수입니다. `showEdges`는 첫·마지막 페이지로 가는 버튼을, `showArrows`는 이전·다음 버튼을 표시합니다.

줄의 칸 개수는 페이지가 바뀌어도 일정하게 유지됩니다. 창이 끝에 가까워지면 잘리는 대신 그쪽으로 미끄러지므로, 페이지를 넘길 때 버튼들이 포인터 아래에서 재배치되지 않습니다. 생략될 페이지가 하나뿐일 때는 줄임표 대신 그 번호를 그립니다.

<Demo src="pagination/range">

<<< @/.vitepress/demos/pagination/range.tsx

</Demo>

### size

<Demo src="pagination/sizes">

<<< @/.vitepress/demos/pagination/sizes.tsx

</Demo>

## 접근성

- `<nav>`가 `<ul>`을 감싸는 구조로 렌더링되고, 현재 페이지에 `aria-current="page"`가 붙습니다.
- 줄임표는 버튼이 아니라 문장 부호이므로 비활성 버튼으로 렌더링되지 않습니다.
- accessible name은 `label` · `pageLabel` · `previousLabel` · `nextLabel` · `firstLabel` · `lastLabel`로 모두 지정할 수 있습니다. 한 화면에 Pagination이 여러 개라면 `label`로 각각이 무엇의 페이지인지 밝혀 주세요.

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

### getPageHref

페이지의 주소를 돌려주면 줄의 번호들이 실제 `<a href>`가 됩니다. 크롤러는 버튼을 누르지 못하므로, 이것 없이는 목록의 2페이지 이후가 검색 엔진에 존재하지 않습니다. 새 탭으로 열기, 주소 복사, 누르기 전에 목적지 확인 같은 브라우저의 기본 동작도 함께 돌아옵니다. 좌우 화살표에는 `rel="prev"`와 `rel="next"`가 붙습니다.

`onPageChange`를 함께 넘기면 이동이 취소되고 핸들러가 대신 답합니다 — client-side router가 이미 가진 페이지를 유지하는 방식입니다. 핸들러가 없으면 링크가 하던 일을 그대로 합니다. 수정 키를 누른 채 클릭한 경우는 언제나 브라우저에 맡깁니다.

읽고 있는 페이지와 줄 끝에 닿은 화살표는 `<button>`으로 남습니다. `<a>`는 `disabled`가 될 수 없어서, 링크로 두면 키보드가 계속 도달하고 크롤러도 따라가기 때문입니다.

<Demo src="pagination/links">

<<< @/.vitepress/demos/pagination/links.tsx

</Demo>

## 접근성

- `<nav>`가 `<ul>`을 감싸는 구조로 렌더링되고, 현재 페이지에 `aria-current="page"`가 붙습니다.
- 줄임표는 버튼이 아니라 문장 부호이므로 비활성 버튼으로 렌더링되지 않습니다.
- `getPageHref`를 넘기면 번호가 링크가 되므로 스크린리더의 링크 목록에 올라가고, 키보드 사용자가 목적지를 미리 확인할 수 있습니다.
- accessible name은 `label` · `pageLabel` · `previousLabel` · `nextLabel` · `firstLabel` · `lastLabel`로 모두 지정할 수 있습니다. 한 화면에 Pagination이 여러 개라면 `label`로 각각이 무엇의 페이지인지 밝혀 주세요.

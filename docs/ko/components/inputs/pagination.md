---
title: Pagination
order: 11
---

# Pagination

<p class="neba-lede">페이지 번호가 늘어선 줄. 각각은 진짜 Button입니다.</p>

<Demo src="pagination/hero" />

```tsx
import { Pagination } from 'neba';

<Pagination count={24} page={page} onPageChange={setPage} showEdges />;
```

## Props

<PropsTable name="Pagination" />

## 예시

### Variant

`variant`는 페이지 버튼이 **쉬고 있을 때**의 모습입니다. 현재 페이지는 언제나 채워집니다 — 읽지 않고도 보여야 하는 유일한 정보이기 때문입니다.

기본값이 홀로 있는 Button과 달리 `text`인 것도 그 때문입니다. 한 줄에 채워진 버튼이 아홉 개 있으면 아홉 개 모두가 주된 액션이라는 뜻이 됩니다.

<Demo src="pagination/variants">

<<< @/.vitepress/demos/pagination/variants.tsx

</Demo>

### 어떤 페이지를 보여 줄지

<Demo src="pagination/range">

<<< @/.vitepress/demos/pagination/range.tsx

</Demo>

### 크기

<Demo src="pagination/sizes">

<<< @/.vitepress/demos/pagination/sizes.tsx

</Demo>

## 줄의 길이는 변하지 않습니다

창이 끝에 가까워지면 잘리는 대신 그쪽으로 미끄러집니다. 그래서 1페이지는 `1 2 3 4 5 … 20`이고 10페이지는 `1 … 9 10 11 … 20`입니다 — 어떤 칸이 페이지이고 어떤 칸이 말줄임인지는 바뀌지만, 칸의 개수는 바뀌지 않습니다.

그러지 않으면 1페이지에서 2페이지로 넘어갈 때 줄이 다시 배치되고, 방금 버튼을 누른 포인터 아래에서 모든 버튼이 빠져나갑니다.

한 페이지만 숨겨질 때는 말줄임 대신 그 페이지를 그립니다. `1 … 3 … 9`는 자기가 대신한 숫자보다 넓은 기호 뒤에 숫자 하나를 숨긴 것입니다.

## 진짜 Button입니다

이 줄에 있는 모든 버튼은 [Button](./button)이고, 그것이 요점입니다. 페이지네이션은 새로운 종류의 컨트롤이 아니라 서로를 알고 있는 버튼들이 한 줄에 놓인 것입니다.

컴포넌트를 재사용하므로 아크릴 표면, 누를 때 즉각적이고 뗄 때 느린 하우스 시그니처, 포커스 링, 그리고 앞으로 그 셋에 생길 모든 변화를 공짜로 물려받습니다. `lg` 페이지네이션이 옆의 `lg` 버튼과 줄이 맞는 이유도 같습니다 — 실제로 그것이니까요.

## 페이지가 하나면 아무것도 그리지 않습니다

혼자 비활성화된 "1"을 그리는 줄은 자기가 할 일이 없다고 광고하는 컨트롤입니다.

## 접근성

마크업은 `<ul>`을 감싼 `<nav>`입니다. 스크린 리더가 들어야 하는 것이 그것이기 때문입니다: 건너뛸 수 있는 이름 붙은 랜드마크, 그 안에 길이가 곧 페이지 범위를 말해 주는 목록, 그리고 현재 위치를 표시하는 `aria-current="page"`.

말줄임은 버튼이 아니고 비활성화된 버튼도 아닙니다. 마침 쓸 수 없는 컨트롤이 아니라 문장 부호입니다.

`label`, `pageLabel`, `previousLabel`처럼 접근성 이름은 전부 prop으로 열려 있습니다. 한 화면에 페이지네이션이 여러 개라면 `label`로 각각이 무엇의 페이지인지 밝혀 주세요.

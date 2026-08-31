---
title: VisuallyHidden
order: 22
---

# VisuallyHidden

<p class="neba-lede">accessibility tree에는 있고 화면에는 없는 내용입니다. 눈에 보이는 것이 글리프나 숫자나 색뿐일 때, 컨트롤이 이름을 얻어야 하는 단어를 위한 것입니다.</p>

<Demo src="visually-hidden/hero" />

```tsx
import { VisuallyHidden } from 'neba';

<button type="button">
  <span aria-hidden="true">×</span>
  <VisuallyHidden>삭제</VisuallyHidden>
</button>;
```

## Props

<PropsTable name="VisuallyHidden" />

`<span>`의 native 속성은 그대로 전달되고, `render`로 element를 바꿉니다.

### `display: none`을 쓰면 안 되는 이유

동작하는 형태는 하나뿐이고, 비슷해 보이는 나머지는 전부 아무도 눈치채지 못하다가 제보로 발견되는 방식으로 실패합니다.

|  | 무엇이 잘못되나 |
| --- | --- |
| `hidden` · `display: none` | 화면과 함께 accessibility tree에서도 사라집니다 — 목적의 정반대 |
| `opacity: 0` · `visibility: hidden` | 글자 크기만 한 클릭 가능한 유령이 남고, 포인터가 그것을 찾습니다 |
| `text-indent: -9999px` | 그만큼 넓은 상자와 가로 스크롤바가 생깁니다 |
| `font-size: 0` | 일부 스크린 리더가 아예 읽지 않습니다 |

내용을 clip한 1px 상자만이 보는 사람에게는 보이지 않고 나머지 모든 방식의 독자에게는 존재합니다. 이 컴포넌트가 그리는 것이 그것입니다.

이것은 한 쌍의 반쪽입니다. `aria-hidden="true"`는 **보이지만 읽히지 않는** 쪽이고 — 위 예시의 글리프 — 컴포넌트가 아니라 속성으로 남습니다. 이미 그려지고 있는 element에 붙는 것이기 때문입니다.

## 예시

### visible

숨김을 걷어내어 다른 것들처럼 그립니다. skip link가 필요로 하는 것이 이것입니다 — focus를 받기 전까지는 숨어 있다가, 받으면 독자가 직접 보고 누르는 진짜 컨트롤이 됩니다.

`focus-visible:`만으로는 표현할 수 없습니다. element가 1px 상자를 **완전히** 벗어나야 하기 때문입니다. 그래서 그것을 되돌리는 class를 컴포넌트에 붙입니다.

<Demo src="visually-hidden/skip-link">

<<< @/.vitepress/demos/visually-hidden/skip-link.tsx

</Demo>

### render

`<span>` 대신 다른 것을 그립니다 — 블록 내용에는 `<div>`, skip link에는 `<a>`, 제목 없이 설명만 있는 표에는 `<caption>`.

```tsx
<VisuallyHidden render={<caption />}>분기별 매출, 백만 원 단위</VisuallyHidden>
```

## 접근성

- 내용은 accessibility tree의 평범한 일부입니다. accessible name에 기여하고, 문서 순서대로 읽히며, `aria-describedby`의 대상이 될 수 있습니다.
- 이름을 붙일 컨트롤의 **옆이 아니라 안에** 넣으세요. `<button>`은 자기 내용에서 이름을 가져옵니다.
- `visible`이 참이 될 수 있는 경우가 아니라면 안에 interactive element를 넣지 마세요. 보이지 않는 focus 가능한 컨트롤은 focus가 아무 데도 가지 않는 것처럼 보입니다.

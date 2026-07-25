---
title: Chip
order: 3
---

# Chip

<p class="neba-lede">작은 토큰입니다. 태그, 필터, 상태, 목록에서 뽑아낸 항목 하나.</p>

<Demo src="chip/hero" />

```tsx
import { Chip } from 'neba';

<Chip>design-system</Chip>
<Chip color="danger" count={12}>오류</Chip>
<Chip onDelete={remove}>typescript</Chip>;
```

## Props

<PropsTable name="Chip" />

## 예시

### Variant와 색

<Demo src="chip/variants">

<<< @/.vitepress/demos/chip/variants.tsx

</Demo>

### 아이콘과 숫자

`count`는 자기 판 위에 그려지므로 "오류 12"가 두 단어가 아니라 숫자가 붙은 토큰 하나로 읽힙니다. 채워진 칩에서 그 판은 채움에 뚫린 구멍이고, 옅게 물든 칩이나 맨 칩에서는 accent가 비쳐 나오는 것입니다.

<Demo src="chip/content">

<<< @/.vitepress/demos/chip/content.tsx

</Demo>

### 누를 수 있는 칩, 지울 수 있는 칩

`selected`는 색 계열을 바꾸는 대신 표면을 한 단계 깊게 만듭니다 — 켜진 필터도 여전히 같은 필터입니다.

<Demo src="chip/interactive">

<<< @/.vitepress/demos/chip/interactive.tsx

</Demo>

### 크기

<Demo src="chip/sizes">

<<< @/.vitepress/demos/chip/sizes.tsx

</Demo>

## 칩은 사다리에서 한 칸 아래입니다

`md` 칩은 `sm` 컨트롤입니다 — 32px이 아니라 26px. 이것이 Chip과 Button의 시각적 차이 전부이고, 의도된 것입니다. 칩은 행이 기준으로 삼는 컨트롤이 아니라 콘텐츠 행 **안에** 놓인 토큰입니다. 컨트롤과 같은 높이가 되면 outline 칩과 outline 버튼은 같은 물건이 되고, 그런 화면은 어느 쪽을 누를 수 있는지 아무것도 말해 주지 않습니다.

다른 라이브러리들은 이 구분을 알약 반경으로 만들지만 이 라이브러리는 그럴 수 없습니다. 시트 위아래 가장자리의 평평한 구간이야말로 [디자인 언어](../../guide/design-language) 전체의 요점이기 때문입니다.

## 접근성

셸은 언제나 `<span>`입니다. 바뀌는 것은 그 안입니다. 그냥 내용이 들어가거나, `onClick`이 주어지면 그 내용을 감싼 진짜 `<button>`이 들어가고, `onDelete`가 있으면 두 번째 버튼이 나란히 놓입니다.

둘 다 키보드로 닿을 수 있고, 어느 쪽도 다른 쪽 안에 중첩되지 않습니다. 클릭 핸들러만 달린 `<span>`은 컴포넌트 라이브러리가 키보드 사용자를 잃는 가장 흔한 방법이고, `<button>` 안의 `<button>`은 브라우저가 조용히 고쳐 쓰는 마크업을 만들어 내는 가장 흔한 방법입니다. 이 구조는 둘 다 피합니다.

화면에 칩이 여러 개라면 삭제 버튼에 무엇을 지우는지 밝히는 `deleteLabel`을 주세요.

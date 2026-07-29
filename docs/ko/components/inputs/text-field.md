---
title: TextField
order: 3
---

# TextField

<p class="neba-lede">한 줄 또는 여러 줄 텍스트를 입력받습니다. 라벨과 설명, 오류 메시지가 하나의 컴포넌트로 묶여 있습니다.</p>

<Demo src="text-field/hero" />

```tsx
import { TextField } from 'neba';

<TextField label="이메일" value={email} onChange={(event) => setEmail(event.target.value)} />;
```

## Props

<PropsTable name="TextField" />

`<input>`의 native 속성은 그대로 전달됩니다. `color`와 `size`는 위 표의 것과 이름이 겹쳐 제외되며, `onChange`는 `multiline`일 때 `<textarea>` 이벤트도 받도록 넓혀져 있습니다.

## 예시

### variant

세 가지 무게 모두 sheet를 색으로 채우지 않습니다. 필드가 담는 것은 사용자가 입력한 텍스트이고, caret과 선택 영역, placeholder가 강조색 채움 위에서는 읽히지 않기 때문입니다. `color`는 테두리와 focus ring, caret에 나타납니다.

<Demo src="text-field/variants">

<<< @/.vitepress/demos/text-field/variants.tsx

</Demo>

### size

[Button](./button)과 높이가 같으므로 툴바처럼 한 줄에 섞어 놓아도 기준선이 맞습니다.

<Demo src="text-field/sizes">

<<< @/.vitepress/demos/text-field/sizes.tsx

</Demo>

### multiline · rows · resize

`multiline`은 `<textarea>`로 렌더링하고 나머지 축은 그대로 유지합니다. `rows={1}`은 한 줄 필드와 정확히 같은 높이입니다. `resize`의 기본값은 세로 방향만 허용합니다 — 가로 리사이즈는 폼의 열 정렬을 깨뜨립니다.

<Demo src="text-field/multiline">

<<< @/.vitepress/demos/text-field/multiline.tsx

</Demo>

### startIcon · endIcon · loading

`loading`은 `endIcon` 자리에 spinner를 놓고 `aria-busy`를 붙이지만 입력은 막지 않습니다. 대개 방금 입력한 값 때문에 로딩 중이기 때문입니다.

<Demo src="text-field/icons">

<<< @/.vitepress/demos/text-field/icons.tsx

</Demo>

### error · invalid · disabled · readOnly

`error`에 메시지를 주면 invalid 상태가 함께 켜지고 필드 전체가 `danger` 계열로 옮겨갑니다. 메시지 없이 invalid 상태만 표시하려면 `invalid`를 직접 주세요.

<Demo src="text-field/states">

<<< @/.vitepress/demos/text-field/states.tsx

</Demo>

### value와 onChange

native `<input>`과 동일하게 동작합니다.

<Demo src="text-field/controlled">

<<< @/.vitepress/demos/text-field/controlled.tsx

</Demo>

## 접근성

- `label` · `description` · `error`가 `id`와 `aria-describedby`로 컨트롤에 연결됩니다.
- floating label은 제공하지 않습니다.
- focus ring은 `<input>`이 아니라 감싸는 shell에 그려지므로 테두리를 그대로 따라갑니다.
- shell의 여백을 클릭해도 caret이 들어갑니다.

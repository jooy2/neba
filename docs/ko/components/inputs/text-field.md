---
title: TextField
order: 2
---

# TextField

<p class="neba-lede">한 줄 또는 여러 줄 텍스트 입력. 라벨·설명·오류가 하나의 컴포넌트로 묶여 있고, 연결은 Base UI의 Field가 맡습니다.</p>

<Demo src="text-field/hero" />

```tsx
import { TextField } from 'neba';

<TextField label="이메일" value={email} onChange={(event) => setEmail(event.target.value)} />;
```

## Props

<PropsTable name="TextField" />

`<input>`의 네이티브 속성은 그대로 전달됩니다. `color`와 `size`는 위 표의 것과 이름이 겹쳐 제외되며, `onChange`는 `multiline`일 때 `<textarea>`도 받도록 넓혀져 있습니다.

## 예시

### 변형

`solid`도 색으로 채우지 않습니다. 필드가 담는 것은 사용자 데이터이고, 캐럿·선택 영역·플레이스홀더가 강조색 채움 위에서는 읽히지 않기 때문입니다. 색 계열은 가장자리와 포커스 링, 캐럿에 나타납니다.

<Demo src="text-field/variants">

<<< @/.vitepress/demos/text-field/variants.tsx

</Demo>

### 크기

Button과 높이가 같습니다. 툴바처럼 한 줄에 섞어 놓아도 기준선이 맞습니다.

<Demo src="text-field/sizes">

<<< @/.vitepress/demos/text-field/sizes.tsx

</Demo>

### 여러 줄

`multiline`은 `<textarea>`로 바꿔 렌더링할 뿐, 나머지 축은 그대로입니다. `rows={1}`은 한 줄짜리 필드와 정확히 같은 높이입니다. 가로 리사이즈는 폼의 열을 깨뜨리므로 기본값이 세로뿐입니다.

<Demo src="text-field/multiline">

<<< @/.vitepress/demos/text-field/multiline.tsx

</Demo>

### 아이콘과 진행 상태

`loading`은 `endIcon` 자리에 스피너를 놓고 `aria-busy`를 붙이지만, 입력은 막지 않습니다. 필드는 대개 방금 입력된 값 _때문에_ 로딩 중이기 때문입니다.

<Demo src="text-field/icons">

<<< @/.vitepress/demos/text-field/icons.tsx

</Demo>

### 상태

`error`에 내용이 있으면 필드 전체가 `danger` 계열로 넘어갑니다 — 가장자리, 포커스 링, 캐럿, 메시지가 한꺼번에 바뀝니다. 메시지 없이 무효 상태만 켜려면 `invalid`를 직접 주세요.

<Demo src="text-field/states">

<<< @/.vitepress/demos/text-field/states.tsx

</Demo>

### 제어 컴포넌트

`value`와 `onChange`는 네이티브 그대로입니다.

<Demo src="text-field/controlled">

<<< @/.vitepress/demos/text-field/controlled.tsx

</Demo>

## 접근성

- 라벨·설명·오류는 Base UI의 Field가 `id`와 `aria-describedby`로 컨트롤에 연결합니다.
- 떠오르는 라벨(floating label)은 제공하지 않습니다. `transform`이 필요한데, 이 라이브러리의 컨트롤은 움직이지 않습니다.
- 포커스 링은 컨트롤이 아니라 껍데기에 그려지므로, 아크릴 가장자리를 그대로 따라갑니다.
- 껍데기의 여백을 클릭해도 캐럿이 들어갑니다. 네이티브 `<input>`과 같은 동작입니다.

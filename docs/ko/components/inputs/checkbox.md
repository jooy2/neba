---
title: Checkbox
order: 5
---

# Checkbox

<p class="neba-lede">하나의 예/아니오, 또는 여러 개 중 하나입니다. Base UI의 Checkbox 위에 아크릴 체크 표시를 얹었습니다.</p>

<Demo src="checkbox/hero" />

```tsx
import { Checkbox } from 'neba';

<Checkbox label="로그인 상태 유지" defaultChecked />;
```

## Props

<PropsTable name="Checkbox" />

`label`·`description`·`error`가 children이 아니라 prop인 이유는 [TextField](./text-field)와 같습니다. 배치는 이미 정해져 있고, 호출하는 쪽이 정하고 싶은 것은 각 자리에 무엇이 들어가는가입니다. `children`은 아예 받지 않습니다 — 체크박스가 해야 할 말은 셋 중 하나에 들어갑니다.

## 예시

### 상태

<Demo src="checkbox/states">

<<< @/.vitepress/demos/checkbox/states.tsx

</Demo>

`error`는 invalid 상태도 함께 켜고, 색 계열 전체를 `danger`로 옮깁니다 — 체크 표시와 포커스 링, 메시지가 한꺼번에 넘어갑니다.

### 중간 상태

하위 항목이 서로 다르면 부모는 켜진 것도 꺼진 것도 아닙니다. `indeterminate`는 세 번째 값이 아니라 세 번째 겉모습입니다. 그 아래에서 체크박스는 여전히 켜짐 아니면 꺼짐입니다.

<Demo src="checkbox/indeterminate">

<<< @/.vitepress/demos/checkbox/indeterminate.tsx

</Demo>

### 크기

<Demo src="checkbox/sizes">

<<< @/.vitepress/demos/checkbox/sizes.tsx

</Demo>

## 체크박스가 둥글지 않은 이유

체크박스의 모서리 반경은 상자의 약 30%입니다. 컨트롤이 쓰는 약 45%가 아닙니다. `--neba-radius-md`는 14px이고, 18px 상자에서 그것은 곧 원입니다 — 그리고 둥근 체크박스는 라디오 버튼입니다. 의도는 라이브러리의 다른 곳과 같습니다. 모서리를 잘라낸 시트이지, 알약이 아닙니다.

## 접근성

- 진짜 `role="checkbox"`와 그 옆의 숨은 `<input>`으로 렌더링되므로 폼과 함께 제출됩니다.
- 라벨은 Base UI Field가 컨트롤과 묶어 줍니다. 글자를 눌러도 토글됩니다.
- `label`이 없다면 `aria-label`을 주세요.
- `indeterminate`는 `aria-checked="mixed"`로 보고됩니다.

---
title: Checkbox
order: 5
---

# Checkbox

<p class="neba-lede">켜고 끌 수 있는 하나의 항목입니다. 폼과 함께 제출되는 boolean 값이나, 여러 개를 동시에 고르는 목록에 씁니다.</p>

<Demo src="checkbox/hero" />

```tsx
import { Checkbox } from 'neba';

<Checkbox label="로그인 상태 유지" defaultChecked />;
```

## Props

<PropsTable name="Checkbox" />

`label` · `description` · `error`는 `children`이 아니라 prop입니다. `children`은 받지 않습니다.

즉시 효력이 생기는 설정이라면 [Switch](./switch)를 쓰세요. Checkbox는 저장 버튼과 함께 제출되는 값입니다.

## 예시

### checked와 onCheckedChange

`checked`와 `onCheckedChange`로 controlled, `defaultChecked`로 uncontrolled 컴포넌트가 됩니다.

### disabled · readOnly · error

`error`에 메시지를 주면 invalid 상태가 함께 켜지고 색 계열이 `danger`로 옮겨갑니다 — 체크 표시와 focus ring, 메시지가 한꺼번에 바뀝니다.

<Demo src="checkbox/states">

<<< @/.vitepress/demos/checkbox/states.tsx

</Demo>

### indeterminate

하위 항목의 상태가 서로 다를 때 부모 Checkbox에 쓰는 세 번째 겉모습입니다. 값 자체는 여전히 켜짐 또는 꺼짐이며, `indeterminate`는 표시에만 관여합니다.

<Demo src="checkbox/indeterminate">

<<< @/.vitepress/demos/checkbox/indeterminate.tsx

</Demo>

### size

<Demo src="checkbox/sizes">

<<< @/.vitepress/demos/checkbox/sizes.tsx

</Demo>

## 접근성

- `role="checkbox"`와 함께 숨은 `<input>`이 렌더링되므로 `name`을 주면 폼과 함께 제출됩니다.
- 라벨이 컨트롤과 연결되어 있어 글자를 눌러도 토글됩니다.
- `label`을 쓰지 않는다면 `aria-label`을 주세요.
- `indeterminate`는 `aria-checked="mixed"`로 보고됩니다.

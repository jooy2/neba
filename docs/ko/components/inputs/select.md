---
title: Select
order: 4
---

# Select

<p class="neba-lede">정해진 목록에서 값 하나를 고릅니다. trigger는 TextField와 같은 shell에 chevron을 얹은 형태입니다.</p>

<Demo src="select/hero" />

```tsx
import { Select } from 'neba';

<Select
  label="리전"
  placeholder="리전을 고르세요"
  items={[
    { value: 'icn', label: '서울' },
    { value: 'nrt', label: '도쿄' }
  ]}
/>;
```

## Props

<PropsTable name="Select" />

선택지를 검색해서 찾아야 한다면 [Combobox](./combobox)를, 선택지가 두세 개뿐이라면 [RadioGroup](./radio-group)이나 [SegmentedButton](./segmented-button)을 쓰세요.

### items

선택지는 컴포넌트를 조합하는 대신 배열로 넘깁니다.

```ts
interface SelectOption {
  value: string | number;
  label?: React.ReactNode; // 생략하면 value 자체
  disabled?: boolean;
}
```

`value`는 문자열이나 숫자입니다. 폼과 함께 제출되는 값이므로 객체는 받지 않습니다 — 식별자만 넘기고 객체는 호출부에서 찾으세요.

## 예시

### variant

[TextField](./text-field)와 같은 세 가지 무게를 같은 shell 위에 그립니다. 한 폼 안에서 필드와 select의 높이와 테두리가 어긋나지 않습니다.

<Demo src="select/variants">

<<< @/.vitepress/demos/select/variants.tsx

</Demo>

### size

<Demo src="select/sizes">

<<< @/.vitepress/demos/select/sizes.tsx

</Demo>

### disabled · readOnly · error

<Demo src="select/states">

<<< @/.vitepress/demos/select/states.tsx

</Demo>

## 팝업

팝업은 portal을 통해 `<body>` 끝에 렌더링되므로, CSS reset을 특정 subtree에만 적용한 앱에서는 그 범위를 벗어납니다. positioner에 `neba-portal` 클래스가 붙어 있으니 그 경우 reset을 이 클래스에 걸어 주세요. Tailwind Preflight를 전역으로 적용했다면 아무것도 하지 않아도 됩니다.

## 접근성

- trigger는 `combobox` role을 갖고, `label`이 accessible name이 됩니다.
- 팝업 위치 계산과 화면 경계에서의 뒤집힘, focus 처리, typeahead, 폼 제출용 hidden input이 모두 처리됩니다.
- `disabled` 선택지는 목록에 남은 채 `aria-disabled`로 보고됩니다.

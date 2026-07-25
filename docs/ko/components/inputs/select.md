---
title: Select
order: 4
---

# Select

<p class="neba-lede">목록에서 값 하나를 고릅니다. 트리거는 TextField의 셸에 셰브런을 얹은 것이고, 이것은 의도된 것입니다.</p>

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

### 옵션은 데이터입니다

조합할 `<Select.Option>`은 없습니다. 호출하는 쪽이 가진 것은 거의 항상 이미 배열이고, 목록은 팝업이 한 번도 열리기 **전에** 트리거가 읽을 수 있어야 합니다 — `value="icn"`에 대해 첫 페인트부터 `서울`이 보이는 것은 그래서입니다.

```ts
interface SelectOption {
  value: string | number;
  label?: React.ReactNode; // 생략하면 value 자체
  disabled?: boolean;
}
```

값은 문자열과 숫자이고, 임의의 객체가 아닙니다. select는 폼 컨트롤이고 그 값은 제출되는 것입니다. 식별자만 여기 두고 객체는 반대편에서 찾으세요.

## 예시

### Variant

[TextField](./text-field)와 같은 세 가지 무게를, 같은 셸 위에 그립니다. select만 주변 필드와 높이·반경·색이 다른 폼은 디자인된 것이 아니라 조립된 것처럼 보입니다.

<Demo src="select/variants">

<<< @/.vitepress/demos/select/variants.tsx

</Demo>

### 크기

<Demo src="select/sizes">

<<< @/.vitepress/demos/select/sizes.tsx

</Demo>

### 상태

<Demo src="select/states">

<<< @/.vitepress/demos/select/states.tsx

</Demo>

## 팝업

팝업은 이 라이브러리에서 유일하게 정말로 떠 있어야 하는 표면이므로, 다른 모든 것과 달리 요청하지 않아도 그림자를 답니다. 호버 없이 도달할 수 있는 최대치인 3단계입니다.

팝업은 포털을 통해 `<body>` 끝에 렌더링되며, 그 말은 앱이 CSS 리셋을 한정해 둔 서브트리를 벗어난다는 뜻입니다. positioner에 `neba-portal` 클래스가 붙는 것은 정확히 그 경우를 위한 것으로, 스타일이 아니라 리셋을 걸어 둘 고리입니다. Tailwind Preflight를 전역으로 적용한 앱이라면 아무것도 하지 않아도 됩니다.

## 접근성

- 팝업의 위치 계산과 뒤집힘, 포커스 트랩, 타이프어헤드, 폼 제출을 가능하게 하는 숨은 input은 모두 Base UI가 담당합니다.
- `label`이 접근성 이름이 되고, 트리거는 `combobox`입니다.
- 비활성 옵션은 목록에 남은 채 `aria-disabled`로 보고됩니다 — 옵션은 존재하고, 다만 고를 수 없을 뿐입니다.

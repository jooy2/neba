---
title: ColorPicker
order: 9
---

# ColorPicker

<p class="neba-lede">눈으로 고르는 색입니다. 채도 사각형과 그 옆의 색상 레일, 선택적인 불투명도 레일, 값을 직접 입력하는 필드, 그리고 미리 준비된 스와치 묶음으로 이루어져 있습니다. hex와 <code>rgb()</code>, <code>hsl()</code>을 읽고 쓰며, 번들에 의존성을 더하지 않습니다.</p>

<Demo src="color-picker/hero" />

```tsx
import { ColorPicker } from 'neba';

const [color, setColor] = useState('#1a58d1');

<ColorPicker value={color} onValueChange={setColor} />;
```

## Props

<PropsTable name="ColorPicker" />

나머지 `<div>` 속성은 모두 루트로 전달됩니다. 예외는 `onChange` 하나로, 여기서 들을 만한 변화는 `onValueChange`입니다.

공통 축(`variant` `size` `color` `density` `elevation`)의 의미는 [Prop 규약](../../design/prop-conventions)에 있습니다. 다만 `color`는 컨트롤 자신의 테두리와 focus ring의 색 역할이며, 고르는 색과는 아무 관계가 없습니다.

## 예시

### inline

기본값은 트리거에 매달린 popup 안에 패널을 두는 것이고, 폼에서는 그쪽이 맞습니다. `inline`은 트리거 없이 패널을 페이지에 그대로 그립니다. 설정 화면이나 toolbar처럼 picker가 화면의 한 필드가 아니라 화면 그 자체일 때 씁니다.

<Demo src="color-picker/inline">

<<< @/.vitepress/demos/color-picker/inline.tsx

</Demo>

### format

`format`은 값이 나올 때의 표기를 정합니다. `hex`(기본값), `rgb`, `hsl` 중 하나입니다. 내보내는 쪽에만 영향을 주므로, 세 표기 중 무엇으로 `value`를 넘겨도 `format`과 관계없이 올바르게 읽힙니다.

<Demo src="color-picker/format">

<<< @/.vitepress/demos/color-picker/format.tsx

</Demo>

### alpha

`alpha`는 색상 레일 아래에 불투명도 레일을 더하고, 값이 네 번째 채널을 싣게 합니다 — `#rrggbbaa`, `rgba()`, `hsla()`입니다. 켜지 않으면 값은 언제나 불투명하므로, 불투명도를 요청한 적 없는 쪽에서 네 번째 인자를 보게 되는 일이 없습니다.

<Demo src="color-picker/alpha">

<<< @/.vitepress/demos/color-picker/alpha.tsx

</Demo>

### swatches

`swatches`는 CSS 색상 문자열의 배열을 받아 내장 세트를 대체합니다. 제품이 실제로 쓰는 몇 가지 색을 놓아 두는 자리입니다. `swatches={false}`면 아무것도 그리지 않고, `editable={false}`는 입력 필드를 없앱니다. 둘을 함께 쓰면 패널에는 사각형과 레일만 남습니다.

<Demo src="color-picker/swatches">

<<< @/.vitepress/demos/color-picker/swatches.tsx

</Demo>

### 폼 안에서

`label`, `description`, `error`는 라이브러리의 모든 필드가 갖는 그 세 슬롯이고, `name`은 값을 폼과 함께 전송합니다. `clearable`은 값을 비우는 ×를 답니다. 비운 뒤의 값은 빈 문자열입니다.

<Demo src="color-picker/field">

<<< @/.vitepress/demos/color-picker/field.tsx

</Demo>

### size

`size`는 공통 사다리 위에서 트리거의 높이를 정하고, 패널의 너비도 함께 정합니다. 어느 단계에서든 옆의 필드들과 같은 줄에 놓입니다.

<Demo src="color-picker/sizes">

<<< @/.vitepress/demos/color-picker/sizes.tsx

</Demo>

### 제어하기

`value`를 넘기면 picker는 자체 상태를 갖지 않습니다. `open`과 `onOpenChange`가 popup에 대해 같은 일을 합니다.

```tsx
const [color, setColor] = useState('#1a58d1');

<ColorPicker value={color} onValueChange={setColor} />;
```

### 읽고 쓰는 색 표기

네 가지 길이의 hex(`#abc`, `#abcd`, `#aabbcc`, `#aabbccdd`), 그리고 `rgb()`/`rgba()`와 `hsl()`/`hsla()`를 쉼표 문법과 공백 문법 모두로 읽습니다. 이름 있는 색과 `color()`는 읽지 않습니다. picker는 읽을 수 있는 값을 모두 되돌려 쓸 수 있어야 하는데, 패널 위에 `rebeccapurple`을 뜻하는 지점은 없기 때문입니다. 읽지 못한 문자열은 패널을 그대로 둡니다.

## 접근성

- 사각형과 각 레일은 접근 가능한 이름과 값, 방향키 지원을 갖춘 `role="slider"`입니다. 방향키는 한 단계씩, shift와 함께 누르면 열 단계씩 움직입니다.
- 사각형은 두 축을 `aria-valuetext`로 알립니다. `aria-valuenow` 하나로는 2차원의 한 점을 설명할 수 없기 때문입니다.
- 모든 스와치는 자기 색으로 이름 붙은 진짜 버튼이고, 선택된 것은 `aria-pressed`를 갖습니다. 그 위의 체크 표시는 해당 색 위에서 읽히는 쪽을 골라 검정이나 흰색으로 그려집니다.
- 사각형과 레일, 필드의 이름이 페이지의 언어로 읽히도록 `locale`을 지정하거나, `labels`로 직접 쓰세요.
- `disabled`와 `readOnly`는 둘 다 패널을 tab 순서에서 빼고 포인터와 키보드에 반응하지 않게 합니다.

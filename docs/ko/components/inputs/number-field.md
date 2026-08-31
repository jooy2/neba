---
title: NumberField
order: 13
---

# NumberField

<p class="neba-lede">숫자만 입력받는 필드입니다. 값을 단계적으로 올리고 내리는 stepper, 범위 제한, 서식 표시가 함께 제공됩니다.</p>

<Demo src="number-field/hero" />

```tsx
import { NumberField } from 'neba';

<NumberField label="좌석" defaultValue={3} min={1} max={20} />;
```

## Props

<PropsTable name="NumberField" />

`<div>`의 native 속성은 root로 전달됩니다. `color`와 `defaultValue`만 위 표와 이름이 겹쳐 제외됩니다.

`value`의 타입은 `number | null`이며 `null`이 비어 있음을 뜻합니다. 파싱해야 하는 문자열이 아닙니다.

shell은 [TextField](./text-field)와 동일하므로 같은 `size`의 필드와 한 줄에 놓을 수 있습니다.

## 예시

### steppers

`end`는 필드 오른쪽에 증감 버튼을 모아 놓습니다. `split`은 숫자 양옆에 마이너스와 플러스를 두어 눌러서 맞추는 수량에 적합합니다. `none`은 버튼을 없애고 키보드 입력만 남깁니다.

<Demo src="number-field/steppers">

<<< @/.vitepress/demos/number-field/steppers.tsx

</Demo>

### step · largeStep · smallStep

방향키는 `step`만큼, Shift와 함께 누르면 `largeStep`만큼, Alt와 함께 누르면 `smallStep`만큼 값을 움직입니다. `snapOnStep`은 그 결과를 `step`의 배수에 맞춥니다.

`allowWheelScrub`은 기본값이 꺼짐입니다. 켜면 필드 위에서 휠로 값을 조절할 수 있지만, 페이지 스크롤과 같은 제스처를 공유하게 됩니다.

### format과 locale

`format`은 `Intl.NumberFormatOptions`입니다. 필드가 `$1,240`이나 `7.5%`를 보여 주더라도 `value`는 `1240`, `0.075`로 유지됩니다.

<Demo src="number-field/format">

<<< @/.vitepress/demos/number-field/format.tsx

</Demo>

### variant

<Demo src="number-field/variants">

<<< @/.vitepress/demos/number-field/variants.tsx

</Demo>

### size

stepper는 `em` 단위로 그려지므로 숫자 크기를 따라갑니다. 같은 `size`의 [Button](./button) · [TextField](./text-field) · [Select](./select)와 높이가 맞습니다.

<Demo src="number-field/sizes">

<<< @/.vitepress/demos/number-field/sizes.tsx

</Demo>

### disabled · readOnly · error

`readOnly`는 stepper를 비활성 상태로 남기지 않고 아예 제거합니다. 숫자는 여전히 선택해서 복사할 수 있습니다.

<Demo src="number-field/states">

<<< @/.vitepress/demos/number-field/states.tsx

</Demo>

### shortcuts

`shortcuts`는 키 조합에서 할 일로 가는 map이고, 조합은 [Shortcut](../display/shortcut)이 그리는 표기 그대로 씁니다. `Mod`는 Mac에서 Command, 그 밖에서는 Control이며 modifier는 정확히 일치해야 하므로 `Enter`와 `Mod+Enter`가 함께 발동하는 일은 없습니다.

```tsx
<NumberField label="수량" shortcuts={{ Enter: commit }} />
```

root가 아니라 `<input>`에 붙는다는 점이 여기서는 중요합니다. `className`도 `onKeyDown`도 라벨과 아래 두 줄을 담는 열에 떨어지므로 `currentTarget`이 필드가 아닙니다.

대신 `preventDefault`를 해 주지는 않습니다. `ArrowUp`에 건 shortcut은 실행되고 **동시에** 값도 한 칸 올라갑니다. 그러지 않아야 한다면 핸들러에서 직접 막으세요.

### classNames

`className`은 루트 — 라벨과 shell, 그 아래 두 줄을 담는 열 — 에 붙고, `<input>` 자체는 `classNames.control`로 갑니다.

```tsx
<NumberField label="Seats" classNames={{ control: 'text-right', stepper: 'rounded-none' }} />
```

slot은 `label`, `shell`, `control`, `description`, `error`, `stepper`입니다. `stepper`는 증가·감소 버튼을 따로 두지 않고 하나로 받습니다. 서로 다르게 생긴 stepper 한 쌍을 만들려는 사람은 없기 때문입니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

## 접근성

- 보이는 컨트롤은 `inputmode="numeric"`과 `aria-roledescription`을 가진 텍스트 입력이고, 그 옆에 `min` · `max` · `step`을 들고 있는 hidden `<input type="number">`가 폼 제출과 브라우저 검증을 담당합니다. 이렇게 나뉘어 있어 보이는 필드가 `$1,240` 같은 서식을 표시할 수 있습니다.
- `label`이 accessible name이 되고, stepper 버튼의 이름은 `incrementLabel`과 `decrementLabel`이 정합니다.
- stepper는 tab 순서에서 빠져 있습니다. 필드의 방향키가 같은 일을 합니다.
- `min`이나 `max`에 도달한 stepper는 `disabled`가 됩니다.
- 두 스테퍼의 접근성 이름은 `locale`이 정합니다 — BCP 47 문자열을 넘기면 숫자와 버튼이 같은 언어로 읽힙니다.

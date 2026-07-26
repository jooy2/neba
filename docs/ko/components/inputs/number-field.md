---
title: NumberField
order: 13
---

# NumberField

<p class="neba-lede">숫자만 담는 필드입니다. 셸은 픽셀 단위로 TextField의 것이고, 그 위에 스테핑과 범위 제한과 서식이 얹힙니다.</p>

<Demo src="number-field/hero" />

```tsx
import { NumberField } from 'neba';

<NumberField label="좌석" defaultValue={3} min={1} max={20} />;
```

## Props

<PropsTable name="NumberField" />

### `<input type="number">`가 아닙니다

네이티브 숫자 입력은 브라우저마다 다른 곳의 모서리를 깎고, 로케일을 무시하고, 페이지 스크롤과 싸우는 휠 제스처를 제공하고, 필드에 말이 안 되는 것이 들어 있으면 빈 `string`을 건네줍니다. 이 컴포넌트는 지킬 만한 것만 지키고 각각에 답합니다.

- `value`는 `number | null`이고, `null`이 비어 있음입니다. 파싱해야 하는 문자열이 아닙니다.
- `format`은 `Intl.NumberFormatOptions`입니다. 필드는 `$1,240`이나 `7.5%`를 보여 주면서 값으로는 `1240`과 `0.075`를 보고합니다.
- 방향키는 `step`만큼, Shift는 `largeStep`만큼, Alt는 `smallStep`만큼 움직입니다.
- 휠은 `allowWheelScrub`이 그러라고 하지 않는 한 아무것도 하지 않습니다. 포인터 아래에서 스크롤되는 페이지와 포인터 아래에서 바뀌는 필드는 같은 제스처이고, 의도된 것은 둘 중 하나뿐입니다.

## 예시

### 스테퍼

<Demo src="number-field/steppers">

<<< @/.vitepress/demos/number-field/steppers.tsx

</Demo>

`end`는 모두가 봐 온 스피너입니다. `split`은 숫자의 양옆에 마이너스와 플러스를 두는데, 타이핑하기보다 톡톡 건드려 맞추는 수량을 위한 것입니다. `none`은 버튼만 빼고 나머지는 그대로 둡니다.

절반 높이의 셰브런을 세로로 쌓는 형태는 일부러 두지 않았습니다. `xs`에서는 화살표 하나가 3픽셀도 되지 않고, 그 정도로 작은 표적은 아무도 맞히지 못하는 표적입니다.

### 서식

필드가 무엇을 보여 주든 `value`는 순수한 숫자로 남습니다.

<Demo src="number-field/format">

<<< @/.vitepress/demos/number-field/format.tsx

</Demo>

### Variant

<Demo src="number-field/variants">

<<< @/.vitepress/demos/number-field/variants.tsx

</Demo>

### 크기

스테퍼는 `em`으로 크기가 정해지므로 자기만의 사다리를 갖는 대신 숫자를 따라갑니다 — 그리고 필드는 같은 `size`의 Button·TextField·Select와 같은 줄에 섭니다.

<Demo src="number-field/sizes">

<<< @/.vitepress/demos/number-field/sizes.tsx

</Demo>

### 상태

읽기 전용은 스테퍼를 비활성화하는 대신 아예 치웁니다. 보이는데 누를 때마다 거절하는 버튼은 없는 버튼보다 나쁩니다. 숫자는 여전히 선택할 수 있습니다 — 읽기 전용 필드도 복사해 가는 대상이기 때문입니다.

<Demo src="number-field/states">

<<< @/.vitepress/demos/number-field/states.tsx

</Demo>

## 접근성

- 파싱, 범위 제한, 스테퍼의 길게 누르기 반복은 모두 Base UI가 담당합니다.
- 보이는 것은 `<input type="number">`가 아니라 `inputmode="numeric"`과 _Number field_라는 `aria-roledescription`을 단 텍스트 입력입니다. 그 옆에는 `min`·`max`·`step`을 들고 있는 숨은 `<input type="number">`가 있고, 폼이 제출하고 브라우저가 검증하는 것은 이쪽입니다. 둘을 갈라 놓은 덕분에 보이는 필드는 브라우저가 파싱을 거부하는 일 없이 `$1,240`을 보여 줄 수 있습니다.
- `label`이 접근성 이름이 되고, 스테퍼의 이름은 `incrementLabel`과 `decrementLabel`이 짓습니다. 스테퍼는 탭 순서에서 빠져 있는데, 필드 자체의 방향키가 이미 그 일을 하기 때문입니다.
- `min`이나 `max`에 닿은 스테퍼는 `disabled`입니다 — 흐려지는 대신, 라이브러리의 다른 모든 비활성 컨트롤과 같이 색 계열이 바뀝니다.

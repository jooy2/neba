---
title: OtpField
order: 20
---

# OtpField

<p class="neba-lede">다른 곳에서 받아 옮겨 적는 짧은 코드를 위한, 한 글자씩 들어가는 칸의 행입니다. PIN, 문자로 온 인증 코드, 초대 키에 씁니다.</p>

<Demo src="otp-field/hero" />

```tsx
import { OtpField } from 'neba';

<OtpField label="Verification code" length={6} groupSize={3} onComplete={(code) => verify(code)} />;
```

## Props

<PropsTable name="OtpField" />

나머지 `<div>` 속성은 그대로 칸들의 행에 전달됩니다. `color`·`size`·`onChange`는 제외됩니다 — 앞의 둘은 Neba prop이고, 값은 `onValueChange`가 알려줍니다. 공용 축은 [prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### charset

`charset`은 입력할 수 있는 문자를 정합니다. 벗어나는 문자는 표시되지 않고 버려지며, 그 문자가 들어온 텍스트는 `onValueInvalid`가 알려줍니다. `numeric`은 휴대폰에 숫자 키패드를 띄우기도 합니다. `any`는 키보드가 만들어 내는 무엇이든 받습니다.

<Demo src="otp-field/charsets">

<<< @/.vitepress/demos/otp-field/charsets.tsx

</Demo>

### length와 groupSize

`length`는 코드의 자리수이며 2–12로 잘립니다. `groupSize`는 N칸마다 `separator`를 넣어 행을 나눕니다. `separator`는 따로 주지 않으면 en dash입니다.

<Demo src="otp-field/lengths">

<<< @/.vitepress/demos/otp-field/lengths.tsx

</Demo>

### mask · error · readOnly · disabled

`mask`는 입력한 문자를 가립니다. `error`는 메시지를 띄우면서 색 계열을 `danger`로 옮기고, `invalid`는 메시지 없이 같은 일을 합니다. `readOnly`는 코드를 선택해 복사할 수 있게 두고, `disabled`는 모든 칸이 반응하지 않게 합니다.

<Demo src="otp-field/states">

<<< @/.vitepress/demos/otp-field/states.tsx

</Demo>

### size

<Demo src="otp-field/sizes">

<<< @/.vitepress/demos/otp-field/sizes.tsx

</Demo>

### 폼 안에서

`name`은 값 전체를 그 이름으로 폼에 올립니다. `autoSubmit`은 코드가 완성되는 순간 폼을 제출하며, 필드가 하나뿐인 인증 화면이 원하는 모양입니다.

```tsx
<form action={verify}>
  <OtpField name="code" length={6} required autoSubmit />
</form>
```

## 접근성

- 입력하면 다음 칸으로 넘어가고, Backspace는 앞 글자를 지우며 뒤로 물러나며, 방향키로 행을 오갑니다.
- 붙여넣은 코드는 어떤 방식으로 붙여넣었든 caret이 있던 자리부터 칸에 나눠 들어갑니다.
- 클릭은 포인터 밑의 칸이 아니라 첫 빈 칸에 떨어지므로, 쓰다 만 코드를 중간부터 고쳐 넣을 일이 없습니다.
- 값 전체를 담은 클리핑된 input이 폼 제출과 휴대폰 autofill을 맡습니다. `autocomplete="one-time-code"`는 이미 붙어 있습니다.
- `label`·`description`·`error`가 칸들과 연결되어 있어 셋 다 필드와 함께 읽힙니다.

---
title: Fieldset
order: 28
---

# Fieldset

<p class="neba-lede">하나의 질문에 함께 답하는 컨트롤 묶음이고, 그 묶음에 이름이 붙습니다. 표면은 그리지 않습니다 — 이것은 시트가 아니라 묶음입니다.</p>

<Demo src="fieldset/hero" />

```tsx
import { Fieldset, TextField } from 'neba';

<Fieldset legend="Billing address" description="Where the card statement goes.">
  <TextField label="Street" name="street" />
  <TextField label="City" name="city" />
</Fieldset>;
```

## Props

<PropsTable name="Fieldset" />

`<fieldset>`의 모든 속성이 `color`를 제외하고 그대로 전달됩니다. 브라우저 자체의 테두리·여백·마진은 지워집니다. 표면이 필요하면 [Card](../surfaces/card)나 [Box](../surfaces/box) 안에 두세요.

## 예시

### legend · description

legend는 안에 있는 모든 컨트롤의 접근 가능한 이름이 됩니다. 그래서 각 컨트롤 앞에 붙여 읽어도 말이 되는 구절이어야 합니다 — "Where should we send it?"이 아니라 "Billing address"입니다. `description`은 그 아래 한 줄입니다.

### disabled

진짜 `<fieldset>`만 할 수 있는 일입니다. 안의 모든 컨트롤에 닿습니다. 세 단계 아래의 컴포넌트가 렌더링해 이 fieldset의 존재조차 모르는 컨트롤까지 포함해서입니다.

<Demo src="fieldset/disabled">

<<< @/.vitepress/demos/fieldset/disabled.tsx

</Demo>

### size

`size`는 legend의 타입 스케일과 컨트롤이 놓이는 간격입니다. 컨트롤 자체에는 닿지 않습니다 — `sm` field들의 묶음은 `sm` field로 직접 쓰면 됩니다.

<Demo src="fieldset/sizes">

<<< @/.vitepress/demos/fieldset/sizes.tsx

</Demo>

## 접근성

- `role="group"`을 가진 진짜 `<fieldset>`으로 렌더링되고, `aria-labelledby`로 legend와 연결됩니다.
- 스크린 리더는 안의 컨트롤마다 legend를 먼저 읽습니다. legend를 질문이 아니라 구절로 쓰는 이유입니다.

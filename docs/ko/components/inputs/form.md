---
title: Form
order: 27
---

# Form

<p class="neba-lede">어느 field가 잘못되었는지 아는 <code>&lt;form&gt;</code>입니다. 제출하면 모든 field의 유효성을 한 번에 모아 처음 실패한 곳으로 focus를 옮기고, 서버가 보낸 오류는 그 오류가 속한 field 위에 놓입니다.</p>

<Demo src="form/hero" />

```tsx
import { Button, Form, TextField } from 'neba';

<Form onSubmit={(values) => save(values)}>
  <TextField label="Email" name="email" type="email" required />
  <Button type="submit">Create account</Button>
</Form>;
```

## Props

<PropsTable name="Form" />

`<form>`의 모든 속성이 그대로 전달됩니다. 이벤트 대신 값을 받는 `onSubmit`만 예외입니다. 이것은 form *라이브러리*가 아닙니다. 스키마도, resolver도, field array도 없습니다. 그런 것이 필요한 프로젝트는 쓰던 것을 그대로 쓰고 결과를 `errors`로 넘기면 됩니다. 이 컴포넌트는 그 이음매를 중심으로 설계되었습니다.

children은 `size`가 정한 간격의 세로 열로 놓입니다. 다른 배치가 필요하면 안에 [Grid](../layout/grid)나 [Fieldset](./fieldset)을 두세요.

## 예시

### onSubmit

모든 field가 유효할 때만 호출되며, 각 field의 `name`을 키로 하는 값 객체를 받습니다. 네이티브 submit 이벤트는 막히므로 페이지가 이동하지 않습니다.

### validationMode

기본값 `onSubmit`은 사용자가 아직 이메일을 입력하는 도중에 틀렸다고 말하지 않는 유일한 값입니다. 첫 제출 이후에는 변경할 때마다 다시 검사합니다. `onBlur`는 focus가 빠질 때, `onChange`는 키를 누를 때마다 검사합니다.

<Demo src="form/validation-mode">

<<< @/.vitepress/demos/form/validation-mode.tsx

</Demo>

### errors

브라우저 자체 유효성 검사 바깥에서 온 오류(서버, form action, 스키마)를 각 오류가 속한 field의 `name`으로 키를 잡아 전달합니다. 해당 field 위에 표시되고, 그 field가 바뀌는 즉시 사라집니다.

<Demo src="form/errors">

<<< @/.vitepress/demos/form/errors.tsx

</Demo>

## 접근성

- 제출이 실패하면 처음 유효하지 않은 field로 focus가 옮겨갑니다. 문제가 있다고 알리는 대신 문제로 데려갑니다.
- 각 메시지는 `aria-describedby`로 자기 field와 연결되고, field에는 `aria-invalid`가 붙습니다.
- 한 페이지에 form이 둘 이상이면 `aria-label`을 주세요.

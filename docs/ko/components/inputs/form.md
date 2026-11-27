---
title: Form
order: 27
flutter: true
---

# Form

<p class="neba-lede">어느 field가 잘못되었는지 아는 <code>&lt;form&gt;</code>입니다. 제출하면 모든 field의 유효성을 한 번에 모아 처음 실패한 곳으로 focus를 옮기고, 서버가 보낸 오류는 그 오류가 속한 field 위에 놓입니다.</p>

<Demo src="form/hero" />

::: fw react

```tsx
import { Button, Form, TextField } from 'neba';

<Form onSubmit={(values) => save(values)}>
  <TextField label="Email" name="email" type="email" required />
  <Button type="submit">Create account</Button>
</Form>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

final GlobalKey<NebaFormState> form = GlobalKey<NebaFormState>();

NebaForm(
  key: form,
  onSubmit: (Map<String, Object?> values) => save(values),
  children: <Widget>[
    NebaFormField<String>(
      name: 'email',
      validator: (String? value) => value == null || value.isEmpty ? 'Enter your email.' : null,
      builder: (NebaFormFieldState<String> field) => NebaTextField(
        label: const Text('Email'),
        error: field.error,
        onChanged: field.didChange,
      ),
    ),
    NebaButton(onPressed: () => form.currentState!.submit(), child: const Text('Create account')),
  ],
);
```

:::

## Props

<PropsTable name="Form" />

::: fw react

`<form>`의 모든 속성이 그대로 전달됩니다. 이벤트 대신 값을 받는 `onSubmit`만 예외입니다.

:::

::: fw flutter

위젯 트리에는 `<form>`도 submit 버튼도 없으므로, form은 `NebaFormState`의 `submit()`을 불러 제출합니다. `GlobalKey<NebaFormState>`를 쓰거나 form 아래에서 `NebaForm.of(context)`로 부르면 되고, 모든 field가 유효했는지를 돌려받습니다. Neba field에는 `name`도 자기 제약 조건도 없으므로, field는 아래의 `NebaFormField`를 거쳐 form에 참여합니다. `semanticLabel`은 React의 `aria-label`입니다.

:::

이것은 form _라이브러리_가 아닙니다. 스키마도, resolver도, field array도 없습니다. 그런 것이 필요한 프로젝트는 쓰던 것을 그대로 쓰고 결과를 `errors`로 넘기면 됩니다. 이 컴포넌트는 그 이음매를 중심으로 설계되었습니다.

children은 세로 열로 놓이고<Fw flutter=" form의 너비만큼 늘어나며" />, 간격은 `size`가 정하거나 `spacing`으로 직접 줍니다. 다른 배치가 필요하면 안에 [Grid](../layout/grid)나 [Fieldset](./fieldset)을 두세요.

::: fw flutter

### NebaFormField

<PropsTable name="FormField" />

`NebaFormField`는 field 하나에 이름을 붙이고 값을 들고 있으며 그 값을 검사합니다. field 자체는 `builder`로 만들고, 그때 `NebaFormFieldState`를 건넵니다. field는 여기서 `error`를 가져가고, 값이 바뀔 때마다 `didChange`에 알립니다. Flutter의 `FormField`와 같은 모양입니다. `value`는 들고 있는 값이고, `errorText`와 `invalid`는 무엇이 잘못됐는지 알려 주며, `validate()`로 필요할 때 검사할 수 있습니다. `required`나 이메일 형식을 대신 검사해 줄 브라우저가 없으므로 모든 규칙과 문구는 `validator`가 맡습니다.

:::

## 예시

### onSubmit

::: fw react

모든 field가 유효할 때만 호출되며, 각 field의 `name`을 키로 하는 값 객체를 받습니다. picker도 다른 field와 같습니다. DatePicker, TimePicker, DateTimePicker, ColorPicker는 제출하는 문자열을, DateRangePicker와 `multiple`인 TreeSelect는 배열을 넘깁니다. `onSubmit`을 주면 네이티브 submit 이벤트가 막혀 페이지가 이동하지 않습니다. 빼면 같은 검증을 거친 뒤 submit이 그대로 진행되어, React 19에서는 함수 `action`이, 모든 버전에서는 `action`에 적은 URL이 실행됩니다.

:::

::: fw flutter

모든 field가 유효할 때만 호출되며, 각 `NebaFormField`의 값을 그 `name` 아래에 담아 받습니다. 값의 타입은 field가 들고 있는 그대로입니다. TextField에서는 `String`, Checkbox에서는 `bool`, Select에서는 고른 값입니다. `disabled`인 field와 비활성 Fieldset 안의 field는 검사에서도 값에서도 빠집니다. field에서 Enter를 눌러도 저절로 제출되지는 않습니다. hero의 비밀번호 field는 `onSubmitted`에서 `submit()`을 부릅니다.

:::

### validationMode

기본값 `onSubmit`은 사용자가 아직 이메일을 입력하는 도중에 틀렸다고 말하지 않는 유일한 값입니다. 첫 제출 이후에는 변경할 때마다 다시 검사합니다. `onBlur`는 focus가 빠질 때, `onChange`는 <Fw react="키를 누를" flutter="값이 바뀔" /> 때마다 검사합니다.

<Demo src="form/validation-mode">

::: fw react

<<< @/.vitepress/demos/form/validation-mode.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/form/validation_mode.dart

:::

</Demo>

### errors

::: fw react

브라우저 자체 유효성 검사 바깥에서 온 오류(서버, form action, 스키마)를 각 오류가 속한 field의 `name`으로 키를 잡아 전달합니다. 해당 field 위에 표시되고, 그 field가 바뀌는 즉시 사라집니다.

:::

::: fw flutter

field의 validator 바깥에서 온 오류(서버, 스키마)를 각 오류가 속한 `NebaFormField`의 `name`으로 키를 잡아 전달합니다. 값은 `String`이거나, 한 줄에 하나씩 그려지는 `List<String>`입니다. 해당 field의 `error`로 표시되고 그 field가 바뀌는 즉시 사라지며, 새 Map을 주면 다시 나타납니다. 제출을 막지는 않습니다.

:::

<Demo src="form/errors">

::: fw react

<<< @/.vitepress/demos/form/errors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/form/errors.dart

:::

</Demo>

### spacing

::: fw react

children 사이의 간격을 정확한 길이로 정합니다. Tailwind 간격 스케일이라 `7`은 `gap-7`과 같은 `1.75rem`입니다. 주지 않으면 `size`를 따르고, `md`에서는 `0.75rem`입니다. [NebaProvider](../../guide/provider)에 <code v-pre>defaults={{ spacing: 7 }}</code>을 주면 모든 Form과 [Fieldset](./fieldset)에 한 번에 적용되고, Form에 직접 준 `spacing`이 그보다 우선합니다.

:::

::: fw flutter

children 사이의 간격을 정확한 길이로 정합니다. 간격 스케일이라 `7`은 28 논리 픽셀입니다. 주지 않으면 `size`를 따르고, `md`에서는 12입니다. [NebaProvider](../../guide/provider)에 `NebaDefaults(spacing: 7)`을 주면 모든 Form과 [Fieldset](./fieldset)에 한 번에 적용되고, Form에 직접 준 `spacing`이 그보다 우선합니다.

:::

<Demo src="form/spacing">

::: fw react

<<< @/.vitepress/demos/form/spacing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/form/spacing.dart

:::

</Demo>

## 접근성

::: fw react

- 제출이 실패하면 처음 유효하지 않은 field로 focus가 옮겨갑니다. 문제가 있다고 알리는 대신 문제로 데려갑니다.
- 각 메시지는 `aria-describedby`로 자기 field와 연결되고, field에는 `aria-invalid`가 붙습니다.
- 한 페이지에 form이 둘 이상이면 `aria-label`을 주세요.

:::

::: fw flutter

- 제출이 실패하면 놓인 순서로 처음 유효하지 않은 field에 focus가 옮겨갑니다. 문제가 있다고 알리는 대신 문제로 데려갑니다.
- 모든 Neba field가 자기 `error`를 읽듯, 스크린 리더는 field 이름 뒤에 메시지를 읽고 field를 유효하지 않다고 알립니다.
- form은 form 역할로 읽힙니다. 화면에 form이 둘 이상이면 `semanticLabel`을 주세요.

:::

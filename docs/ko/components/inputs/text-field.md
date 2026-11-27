---
title: TextField
order: 3
flutter: true
---

# TextField

<p class="neba-lede">한 줄 또는 여러 줄 텍스트를 입력받습니다. 라벨과 설명, 오류 메시지가 하나의 컴포넌트로 묶여 있습니다.</p>

<Demo src="text-field/hero" />

::: fw react

```tsx
import { TextField } from 'neba';

<TextField label="이메일" value={email} onChange={(event) => setEmail(event.target.value)} />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaTextField(label: const Text('이메일'), onChanged: (String value) => email = value);
```

:::

## Props

<PropsTable name="TextField" />

::: fw react

`<input>`의 native 속성은 그대로 전달됩니다. `color`와 `size`는 위 표의 것과 이름이 겹쳐 제외되며, `onChange`는 `multiline`일 때 `<textarea>` 이벤트도 받도록 넓혀져 있습니다.

:::

::: fw flutter

`label`과 `description`, `error`는 위젯이고 보통 `Text`를 넘깁니다. 글은 `TextEditingController`가 들고 있는데, 호출하는 쪽이 `controller`로 넘기지 않으면 필드가 자기 것을 둡니다. `initialValue`가 React의 `defaultValue`입니다. React가 `<input>` 속성으로 넘기는 것은 Flutter에서 그 아래 `EditableText`로 넘어갑니다. `keyboardType`, `textInputAction`, `type="password"`에 해당하는 `obscureText`, `autofillHints`, `inputFormatters`, `maxLength`가 그렇습니다. 라벨이 없는 필드의 이름은 `semanticLabel`로 붙입니다.

:::

## 예시

### variant

세 가지 무게 모두 sheet를 색으로 채우지 않습니다. 필드가 담는 것은 사용자가 입력한 텍스트이고, caret과 선택 영역, placeholder가 강조색 채움 위에서는 읽히지 않기 때문입니다. `color`는 테두리와 focus ring, caret에 나타납니다.

<Demo src="text-field/variants">

::: fw react

<<< @/.vitepress/demos/text-field/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/variants.dart

:::

</Demo>

### size

[Button](./button)과 높이가 같으므로 툴바처럼 한 줄에 섞어 놓아도 기준선이 맞습니다. 필드에서는 이 높이가 고정값이 아니라 **하한**입니다. 단계보다 큰 글자를 넣으면(크론 표현식, 코드, 숫자 하나) 셸이 잘리지 않고 그만큼 늘어납니다.

<Demo src="text-field/sizes">

::: fw react

<<< @/.vitepress/demos/text-field/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/sizes.dart

:::

</Demo>

### labelPlacement

기본값인 `top`은 라벨을 필드 위에 둡니다. `notch`는 필드 위쪽 테두리를 끊어 낸 틈에 라벨을 올립니다. `float`는 라벨을 placeholder 자리에 두었다가, 필드가 focus를 받거나 값을 가지면 노치로 올립니다. placeholder는 라벨이 올라간 뒤에야 보입니다. `startIcon`이 있으면 아이콘이 라벨이 내려앉을 자리를 차지하므로 `float` 라벨도 노치에 머뭅니다. 내려앉은 라벨은 `endIcon` 앞에서 멈추고, 라벨만큼만 넓은 필드는 라벨이 내려앉았을 때의 크기에 맞춰 넓어집니다.

노치의 라벨은 필드 위로 한 줄이 아니라 반 줄만 올라옵니다. 넘치는 부분을 잘라 내는 컨테이너라면 맨 위 필드 위에 그만큼 여백을 두어야 합니다.

<Demo src="text-field/label-placement">

::: fw react

<<< @/.vitepress/demos/text-field/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/label_placement.dart

:::

</Demo>

### <Fw react="multiline · rows · resize" flutter="multiline · rows" />

::: fw react

`multiline`은 `<textarea>`로 렌더링하고 나머지 축은 그대로 유지합니다. `rows={1}`은 한 줄 필드와 정확히 같은 높이입니다. `resize`의 기본값은 세로 방향만 허용합니다. 가로 리사이즈는 폼의 열 정렬을 깨뜨립니다.

:::

::: fw flutter

`multiline`은 여러 줄을 받고 나머지 축은 그대로 유지합니다. `rows`는 필드가 최소한 보여 주는 줄 수이고, `rows: 1`은 한 줄 필드와 정확히 같은 높이입니다. 끌어서 늘릴 모서리가 없으므로 그 줄 수를 넘으면 글을 따라 필드가 늘어납니다.

:::

<Demo src="text-field/multiline">

::: fw react

<<< @/.vitepress/demos/text-field/multiline.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/multiline.dart

:::

</Demo>

### startIcon · endIcon · loading

`loading`은 `endIcon` 자리에 <Fw react="spinner를 놓고 aria-busy를 붙이지만" flutter="도는 링을 놓지만" /> 입력은 막지 않습니다. 대개 방금 입력한 값 때문에 로딩 중이기 때문입니다.

<Demo src="text-field/icons">

::: fw react

<<< @/.vitepress/demos/text-field/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/icons.dart

:::

</Demo>

### error · invalid · disabled · readOnly

`error`에 메시지를 주면 invalid 상태가 함께 켜지고 필드 전체가 `danger` 계열로 옮겨갑니다. 메시지 없이 invalid 상태만 표시하려면 `invalid`를 직접 주세요.

<Demo src="text-field/states">

::: fw react

<<< @/.vitepress/demos/text-field/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/states.dart

:::

</Demo>

### <Fw react="value와 onChange" flutter="controller와 onChanged" />

::: fw react

native `<input>`과 동일하게 동작합니다.

:::

::: fw flutter

`onChanged`는 글이 바뀔 때마다, `onSubmitted`는 사용자가 키보드의 동작 키를 누를 때 글을 알려 줍니다. 밖에서 글을 읽거나 바꾸려면 필드에 `TextEditingController`를 넘기세요. 넘기지 않으면 필드가 자기 것을 둡니다.

:::

<Demo src="text-field/controlled">

::: fw react

<<< @/.vitepress/demos/text-field/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/controlled.dart

:::

</Demo>

### shortcuts

::: fw react

`shortcuts`는 키 조합에서 할 일로 가는 map이고, 조합은 [Shortcut](../display/shortcut)이 그리는 표기 그대로 씁니다. 폼이 사용자에게 **보여 주는** 키와 실제로 **바인딩하는** 키가 같은 문자열이 됩니다.

```tsx
<TextField
  label="메시지"
  multiline
  shortcuts={{
    'Mod+Enter': (event) => {
      event.preventDefault();
      send();
    },
    Escape: clear
  }}
/>
```

`Mod`는 Mac에서 Command, 그 밖에서는 Control입니다. modifier는 정확히 일치해야 하므로 `Enter`와 `Mod+Enter`는 절대 함께 발동하지 않는 두 항목입니다.

control에 붙기 때문에 `event.currentTarget`이 `<input>` 또는 `<textarea>`이고, `event.currentTarget.value`가 방금 입력된 값입니다. 대신 `preventDefault`를 해 주지는 않습니다. 줄바꿈까지 막아야 하는 `Mod+Enter`라면 직접 부르세요. `onKeyDown`은 여전히 모든 키를 받고 map 다음에 실행됩니다. 둘 중 어느 쪽도 다른 쪽을 대체하지 않습니다.

:::

::: fw flutter

`shortcuts`는 `ShortcutActivator`에서 할 일로 가는 map입니다. `CallbackShortcuts`가 받는 것과 같은 모양이고, 필드가 focus를 가진 동안 바인딩됩니다.

```dart
NebaTextField(
  label: const Text('메시지'),
  multiline: true,
  shortcuts: <ShortcutActivator, VoidCallback>{
    const SingleActivator(LogicalKeyboardKey.enter, control: true): send,
    const SingleActivator(LogicalKeyboardKey.escape): clear,
  },
)
```

modifier는 정확히 일치해야 하므로 `Enter`와 `Control+Enter`는 절대 함께 발동하지 않는 두 항목입니다. `Mod`는 없습니다. 예시는 Apple 플랫폼에서 `meta`를, 그 밖에서 `control`을 바인딩합니다. 바인딩한 키는 소비되므로, 보내기에 쓴 `Control+Enter`가 줄까지 바꾸지는 않습니다. 아무도 바인딩하지 않은 키는 평소대로 필드에 들어갑니다.

:::

<Demo src="text-field/shortcuts">

::: fw react

<<< @/.vitepress/demos/text-field/shortcuts.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/text_field/shortcuts.dart

:::

</Demo>

### <Fw react="classNames" flutter="style" />

::: fw react

`className`은 루트(라벨과 shell, 그 아래 두 줄을 담는 열)에 붙습니다. `<input>` 자체는 `classNames`로 갑니다. `root` 키는 없습니다. 그것이 이미 `className`이기 때문입니다.

```tsx
<TextField
  label="Email"
  className="w-80"
  classNames={{ label: 'uppercase tracking-wide', control: 'font-mono' }}
/>
```

slot은 `label`, `shell`, `control`, `description`, `error`입니다. `shell`은 테두리와 채움, focus ring을 두른 상자이고 `control`은 그 안의 `<input>` 또는 `<textarea>`입니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

:::

::: fw flutter

`style`은 필드 안의 글에 덮어씌워지며, React의 `classNames.control`에 해당합니다. 라벨과 설명, 오류는 위젯이라 각자 스타일을 받고, 너비는 부모가 정하거나 `fullWidth`로 정합니다.

```dart
NebaTextField(
  label: const Text('Cron'),
  style: const TextStyle(fontFamily: 'monospace', fontSize: 24),
)
```

:::

## 접근성

::: fw react

- `label` · `description` · `error`가 `id`와 `aria-describedby`로 컨트롤에 연결됩니다.
- `notch`와 `float`에서도 라벨은 필드의 `<label>`입니다. 내려앉은 `float` 라벨은 placeholder를 대신하며, placeholder는 필드가 focus를 받을 때까지 보이지 않습니다.
- focus ring은 `<input>`이 아니라 감싸는 shell에 그려지므로 테두리를 그대로 따라갑니다.
- shell의 여백을 클릭해도 caret이 들어갑니다.
- iOS와 iPadOS에서는 글자가 최소 16px입니다. 그곳의 Safari는 더 작은 필드를 누르면 페이지를 확대하기 때문입니다. 다른 브라우저는 `size`가 정한 크기로 그립니다. `NumberField`, `Combobox`, `OtpField`, `CommandPalette` 등 라이브러리의 다른 텍스트 입력도 같습니다.

:::

::: fw flutter

- 화면 낭독기에는 필드 전체가 노드 하나입니다. `Text`로 준 라벨이 필드 이름이 되고, `Text`로 준 설명과 오류는 그 뒤에 읽힙니다. `error`가 있으면 필드가 invalid로도 표시됩니다.
- `notch`와 `float`에서도 라벨은 필드의 이름입니다. 내려앉은 `float` 라벨은 placeholder를 대신하며, placeholder는 필드가 focus를 받을 때까지 보이지 않습니다.
- focus ring은 shell에 그려지므로 테두리를 그대로 따라갑니다. 필드에 caret이 있으면 언제나 보이고, 읽기 전용 필드에서는 키보드 focus일 때만 보입니다.
- 라벨이나 shell의 여백을 눌러도 caret이 들어갑니다.
- 터치 화면의 선택 핸들과 복사·붙여넣기 툴바는 없습니다. 둘 다 Material이나 Cupertino가 그리는 것이기 때문입니다. 포인터와 키보드로는 여전히 선택할 수 있고, 키보드로 복사하고 붙여넣을 수 있습니다.

:::

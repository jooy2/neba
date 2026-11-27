---
title: Combobox
order: 12
flutter: true
---

# Combobox

<p class="neba-lede">입력한 글자로 목록을 걸러내면서 값을 고르는 필드입니다. 선택지가 많아 Select로는 찾기 어려울 때, 또는 목록에 없는 값도 받아야 할 때 씁니다.</p>

<Demo src="combobox/hero" minHeight="300" />

::: fw react

```tsx
import { Combobox } from 'neba';

<Combobox
  label="프레임워크"
  placeholder="검색하거나 직접 입력하세요"
  items={[
    { value: 'react', label: 'React' },
    { value: 'vue', label: 'Vue' }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaCombobox<String>(
  label: const Text('프레임워크'),
  placeholder: '검색하거나 직접 입력하세요',
  items: const <NebaComboboxOption<String>>[
    NebaComboboxOption<String>(value: 'react', label: 'React'),
    NebaComboboxOption<String>(value: 'vue', label: 'Vue'),
  ],
);
```

:::

## Props

<PropsTable name="Combobox" />

::: fw react

`<div>`의 native 속성은 root로 전달됩니다. 다만 `aria-label`과 `aria-labelledby`는 `<input>`의 이름이 됩니다. `color`와 `defaultValue`만 위 표와 이름이 겹쳐 제외됩니다.

팝업은 [Select](./select)의 팝업과 같습니다. `<body>` 끝으로 portal되며 positioner에 `neba-portal` 클래스가 붙습니다.

:::

::: fw flutter

`NebaCombobox`는 값의 타입에 대해 generic이고, `label`과 `description`, `error`는 위젯이며 보통 `Text`를 넘깁니다. 값을 여러 개 드는 combobox는 `NebaCombobox.multiple`로 만듭니다. 이 생성자의 `value`, `defaultValue`, `onValueChange`는 리스트로 말하기 때문에 `multiple` 플래그가 아니라 생성자를 따로 둡니다. `value`를 `null`로 두면 combobox가 상태를 스스로 관리합니다.

필드 안의 글은 combobox가 관리합니다. 하나를 드는 combobox에서는 고른 옵션의 label이고, 여러 개를 드는 combobox에서는 고를 때마다 비워집니다. 입력하는 동안의 글은 `onInputValueChange`가 알려 주고, focus는 `focusNode`로 다룹니다. Flutter에는 이 값을 제출하는 폼이 없으므로 `name`, `autoComplete`, `required`, `inputRef`, `classNames`는 없습니다. 목록은 [Select](./select)의 목록과 같고, 앱의 root `Overlay`에 그려집니다.

:::

### items

[Select](./select)와 같은 <Fw react="배열" flutter="리스트" /> 형태이며, `label`의 타입만 다릅니다.

::: fw react

```ts
interface ComboboxOption {
  value: string | number;
  label?: string; // ReactNode가 아니라 string
  disabled?: boolean;
}
```

:::

::: fw flutter

```dart
const NebaComboboxOption<String>(
  value: 'react',
  label: 'React', // 위젯이 아니라 String
  disabled: false,
);
```

:::

필터가 이 `label`을 상대로 매칭하고 입력란이 이 값을 그대로 채우기 때문에 <Fw react="string" flutter="String" code />이어야 합니다.

## 예시

### multiple

고른 값은 필드 안에서 [Chip](../display/chip)으로 표시되고, 입력란은 그 뒤로도 계속 필터로 동작합니다.

::: fw react

입력란이 비어 있을 때 Backspace를 누르면 마지막 chip으로 focus가 이동합니다.

:::

::: fw flutter

`NebaCombobox.multiple`로 만듭니다. 필드가 비어 있을 때 Backspace를 누르면 마지막 chip이 빠지고, chip의 ×는 그 chip을 뺍니다. ×는 누르는 버튼이고 Tab으로는 닿지 않습니다. 커서가 맨 앞에 있을 때 왼쪽 화살표(오른쪽에서 왼쪽으로 쓰는 필드에서는 오른쪽 화살표)를 누르면 마지막 chip으로 focus가 옮겨 가고, 화살표로 chip 사이를 오가다 양 끝을 넘으면 필드로 돌아옵니다. focus를 가진 chip은 Backspace나 Delete로 뺍니다. 필드는 chip 뒤로 글자 스무 개쯤이 들어가는 너비이며, 그보다 좁아지면 chip이 다음 줄로 넘어갑니다.

:::

<Demo src="combobox/multiple" minHeight="300">

::: fw react

<<< @/.vitepress/demos/combobox/multiple.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/multiple.dart

:::

</Demo>

### allowCustom · customLabel · emptyMessage

`allowCustom`은 기본값이 켜짐입니다. 입력한 글자가 목록 맨 끝에 별도 행으로 제안되므로, Enter나 <Fw react="클릭" flutter="누르기" />, 방향키 모두 다른 행과 같은 방식으로 닿습니다. focus가 빠질 때 조용히 확정되지는 않습니다.

값이 닫힌 집합이라면 <Fw react="allowCustom={false}" flutter="allowCustom: false" code />로 끄세요. 이때 일치하는 항목이 없으면 `emptyMessage`가 표시됩니다.

::: fw flutter

입력한 글은 `String`이므로, 값이 `String`일 수 있는 combobox(`String`이나 `Object?` 위의 것)만 그 행을 제안합니다. `int`나 enum 위의 combobox에서는 `allowCustom`과 상관없이 나오지 않습니다.

:::

<Demo src="combobox/custom" minHeight="260">

::: fw react

<<< @/.vitepress/demos/combobox/custom.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/custom.dart

:::

</Demo>

### variant

[TextField](./text-field)와 같은 세 가지 무게를 같은 shell 위에 그립니다.

<Demo src="combobox/variants" minHeight="220">

::: fw react

<<< @/.vitepress/demos/combobox/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/variants.dart

:::

</Demo>

### size

단일 선택 Combobox는 같은 `size`의 [TextField](./text-field)와 높이가 같습니다. `multiple`에서는 chip이 줄바꿈하는 만큼 필드가 높아지므로 고정 높이를 갖지 않습니다.

<Demo src="combobox/sizes" minHeight="300">

::: fw react

<<< @/.vitepress/demos/combobox/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/sizes.dart

:::

</Demo>

### labelPlacement

`notch`와 `float`는 [TextField](./text-field#labelplacement)와 같게 동작합니다. `multiple`에서는 고른 항목도 입력한 글자도 없을 때만 `float` 라벨이 필드 안에 내려앉습니다.

<Demo src="combobox/label-placement" minHeight="240">

::: fw react

<<< @/.vitepress/demos/combobox/label-placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/label_placement.dart

:::

</Demo>

### disabled · readOnly · error

<Demo src="combobox/states">

::: fw react

<<< @/.vitepress/demos/combobox/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/combobox/states.dart

:::

</Demo>

### clearable · limit

`clearable`은 값을 비우는 버튼을 붙입니다. `limit`은 팝업에 한 번에 표시할 옵션 수를 제한합니다. 입력한 값을 추가하는 행은 그 수에 들어가지 않으므로, 목록이 가득 차도 새 값을 받을 수 있습니다.

### filter

기본값은 입력한 글자로 목록을 좁히는 것입니다. 각 옵션의 label에 대해 대소문자와 악센트를 무시하고 비교합니다.

::: fw react

**서버가 이미 좁혀 준 목록에는 `filter={false}`가 필요합니다.** 키워드나 설명, 동의어로 검색한 결과에는 눈에 보이는 label에 질의가 들어 있지 않은 행이 섞여 있고, 여기서 한 번 더 거르면 검색이 찾아 준 결과가 바로 그 행들과 함께 사라집니다. `onInputValueChange`에서 요청하고, 받은 결과를 `items`에 넘기고, 거르지 않으면 됩니다.

```tsx
<Combobox
  items={results}
  filter={false}
  onInputValueChange={(query) => search(query)}
  label="Customer"
/>
```

:::

::: fw flutter

**서버가 이미 좁혀 준 목록에는 모든 옵션을 남기는 filter가 필요합니다.** 키워드나 설명, 동의어로 검색한 결과에는 눈에 보이는 label에 질의가 들어 있지 않은 행이 섞여 있고, 여기서 한 번 더 거르면 검색이 찾아 준 결과가 바로 그 행들과 함께 사라집니다. `onInputValueChange`에서 요청하고, 받은 결과를 `items`에 넘기고, 거르지 않으면 됩니다.

```dart
NebaCombobox<String>(
  items: results,
  filter: (NebaComboboxOption<String> option, String query) => true,
  onInputValueChange: search,
  label: const Text('Customer'),
)
```

:::

함수를 넘기면 옵션마다 직접 판단합니다. label뿐 아니라 `value`까지 보거나, 단어 중간이 아니라 앞부터 맞는 것만 남기는 식입니다. 입력한 값을 추가하겠다고 제안하는 행은 어떤 경우에도 걸러지지 않습니다.

### shortcuts

::: fw react

`shortcuts`는 키 조합과 그 조합이 할 일을 짝지어 받으며, 조합은 [Shortcut](../display/shortcut)이 그리는 표기 그대로 씁니다. `Mod`는 Mac에서 Command, 그 밖에서는 Control이며 modifier는 정확히 일치해야 합니다.

```tsx
<Combobox label="Framework" items={frameworks} shortcuts={{ 'Mod+Enter': createAndOpen }} />
```

화살표는 highlight를 옮기고 `Escape`는 팝업을 닫고 `Enter`는 확정합니다. 이 키들은 root에 쓴 `onKeyDown`에 도달하지 않으므로, Combobox에서 이 키에 반응하려면 `shortcuts`를 써야 합니다.

shortcut은 `<input>`에 붙어 목록이 키를 처리하기 **전에** 실행되지만, 목록이 하는 일을 **대신하지는** 않습니다. `Enter`에 건 shortcut은 확정과 함께 실행되지 그것을 막지 않습니다. 키를 온전히 가져야 한다면 목록이 쓰지 않는 조합을 고르세요.

:::

::: fw flutter

`shortcuts`는 [TextField](./text-field#shortcuts)처럼 `ShortcutActivator`와 그 조합이 할 일을 짝지어 받으며, modifier는 정확히 일치해야 합니다.

```dart
NebaCombobox<String>(
  label: const Text('Framework'),
  items: frameworks,
  shortcuts: <ShortcutActivator, VoidCallback>{
    const SingleActivator(LogicalKeyboardKey.enter, control: true): createAndOpen,
  },
)
```

화살표는 highlight를 옮기고 `Escape`는 목록을 닫고 `Enter`는 고릅니다. shortcut은 필드가 focus를 가진 동안 목록이 키를 처리하기 **전에** 실행되지만, 목록이 하는 일을 **대신하지는** 않습니다. `Enter`에 건 shortcut은 선택과 함께 실행되지 그것을 막지 않습니다. 키를 온전히 가져야 한다면 목록이 쓰지 않는 조합을 고르세요.

:::

::: fw react

### autoComplete

`autoComplete`는 이 필드에 무엇이 들어가는지 브라우저에 알려, 주소 폼의 다른 칸과 함께 autofill로 채워지게 합니다. 값을 제출하는 숨은 input에 붙고, 채워진 값이 옵션의 `value`나 label과 같으면 그 옵션이 선택됩니다. 글자를 입력하는 `<input>`은 `autocomplete="off"`를 유지하므로, 브라우저가 기억해 둔 입력 목록이 Combobox의 목록 위에 열리지 않습니다. `multiple` Combobox는 autofill을 받지 않습니다.

```tsx
<Combobox label="City" name="city" autoComplete="address-level2" items={cities} />
```

### classNames

`className`은 루트(라벨과 shell, 그 아래 두 줄을 담는 열)에 붙고, `<input>` 자체는 `classNames.control`로 갑니다.

```tsx
<Combobox
  items={frameworks}
  label="Framework"
  multiple
  classNames={{ control: 'font-mono', chip: 'rounded-none', popup: 'max-h-40' }}
/>
```

slot은 `label`, `shell`, `control`, `description`, `error`, `chip`, `popup`, `item`입니다. `chip`은 multiple 모드에서 input 앞에 놓이는 토큰 하나입니다. `popup`과 `item`은 `<body>` 끝에 그려지므로 루트를 기준으로 쓴 것으로는 닿지 않습니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

:::

## 접근성

::: fw react

- trigger는 `combobox`, 목록은 `listbox` role을 갖고 `label`이 accessible name이 됩니다.
- 필터링, 팝업 위치 계산과 뒤집힘, 목록과 chip을 가로지르는 방향키 이동, 폼 제출용 hidden input이 모두 처리됩니다.
- `disabled` 항목은 목록에 남은 채 `aria-disabled`로 보고됩니다.
- chip의 제거 버튼 이름은 `removeLabel`이 chip 라벨을 받아 만듭니다.
- 결과 없음 문구와 지우기 · 삭제 버튼의 이름을 `locale`이 정합니다. `emptyMessage`, `clearLabel`, `removeLabel`로 직접 쓸 수도 있습니다.

:::

::: fw flutter

- 필드는 화면 낭독기에게 텍스트 필드 하나입니다. `Text` 라벨이 이름이고, 펼쳐졌는지 접혔는지를 알리며, `Text`인 설명과 오류는 이름 뒤에 읽힙니다.
- 글을 입력하거나 필드나 chevron을 누르거나 화살표 키를 쓰면 목록이 열립니다. 화살표 키는 highlight를 옮기는데, disabled 옵션은 건너뛰고 끝에서는 반대쪽 끝으로 돌아갑니다. 입력하는 동안 첫 번째로 맞는 옵션이 켜지므로 Enter로 바로 고를 수 있습니다. Escape는 목록을 닫고, 한 번 더 누르면 필드를 비웁니다. focus는 내내 필드에 머물고, focus가 떠나면 목록이 닫힙니다.
- 각 옵션은 선택됐는지를 알리고, `disabled` 옵션은 목록에 남은 채 사용할 수 없다고 읽힙니다.
- chevron과 ×, 각 chip의 ×는 label, `clearLabel`, `removeLabel`로 이름 붙은 버튼이며, 어느 것도 필드에서 focus를 가져가지 않습니다. chip 자체는 화살표 키로만 focus를 받고 Tab으로는 받지 않습니다.
- 결과 없음 문구, 입력한 값을 더하는 행, 지우기 · 삭제 버튼의 이름을 `locale`이 정합니다. `emptyMessage`, `customLabel`, `clearLabel`, `removeLabel`로 직접 쓸 수도 있습니다.

:::

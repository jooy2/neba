---
title: CommandPalette
order: 32
flutter: true
---

# CommandPalette

<p class="neba-lede">애플리케이션이 할 수 있는 모든 것을 필드 하나 뒤에 둡니다. 메뉴 바가 담을 수 있는 것보다 액션이 많아진 키보드 중심 제품이 취하는 모양입니다. 어디에 두었는지 기억하는 대신, 원하는 것을 입력합니다.</p>

<Demo src="command-palette/hero" frameMinHeight="460" />

::: fw react

```tsx
import { CommandPalette } from 'neba';

<CommandPalette
  items={[
    { value: 'deploy', label: 'Deploy production', group: 'Actions', onSelect: deploy },
    { value: 'logs', label: 'Go to logs', group: 'Navigate' }
  ]}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaCommandPalette(
  items: <NebaCommandItem>[
    NebaCommandItem(value: 'deploy', label: 'Deploy production', group: 'Actions', onSelect: deploy),
    const NebaCommandItem(value: 'logs', label: 'Go to logs', group: 'Navigate'),
  ],
);
```

:::

## Props

<PropsTable name="CommandPalette" />

### CommandItem

<PropsTable name="CommandItem" />

[Menu](./menu)는 한자리에 있는 짧은 목록이라 찾기 전에 이미 모든 행이 보입니다. [Combobox](./combobox)는 값을 돌려줍니다. 이 컴포넌트는 실행되는 동작을 돌려줍니다.

::: fw flutter

명령 하나는 `NebaCommandItem`이고, `description`과 `icon`은 위젯입니다. 팔레트는 놓인 자리에 아무것도 그리지 않고, [Dialog](../feedback/dialog)처럼 앱의 root `Overlay`에 열립니다. Flutter 위젯에는 넘겨줄 class가 없으므로 `className`과 `classNames`는 없습니다.

:::

## 예시

### items · group

명령은 주어진 순서대로 그려지고, `group`이 바뀔 때마다 제목이 그려집니다. 그래서 한 그룹의 명령은 붙여서 나열해야 합니다. `icon`과 `shortcut`이 행의 양 끝을 채우고, `description`은 라벨 아래 한 줄이 됩니다.

<Demo src="command-palette/groups" frameMinHeight="380">

::: fw react

<<< @/.vitepress/demos/command-palette/groups.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/command_palette/groups.dart

:::

</Demo>

### keywords

검색에는 쓰이지만 화면에는 절대 그려지지 않는 단어들입니다. 같은 명령을 다른 제품이 부르는 이름, 약어, 독자가 검색했을 법한 말. `undo`라고 쳐서 `Roll back`이 나오는 것이 팔레트를 두 번 열게 만드는 이유입니다.

### shortcut

::: fw react

팔레트를 여는 키이며 window에 바인딩됩니다. `Mod`는 Mac에서 Command, 그 밖에서는 Control입니다. [Shortcut](../display/shortcut)이 그리는 것과 같은 표기를, 쓰는 대신 읽습니다. `false`는 아무것도 바인딩하지 않습니다. 키보드를 직접 관리하는 애플리케이션을 위한 것입니다.

:::

::: fw flutter

팔레트를 여는 키이며, focus가 어디에 있든, 필드 안이어도 앱 전체에 바인딩됩니다. `Mod`는 Mac에서 Command, 그 밖에서는 Control입니다. [Shortcut](../display/shortcut)이 그리는 것과 같은 표기를 쓰는 대신 읽고, 보조 키는 정확히 일치해야 합니다. `null`은 아무것도 바인딩하지 않습니다. 키보드를 직접 관리하는 애플리케이션을 위한 것입니다.

:::

### open · defaultOpen

::: fw react

`open`과 `onOpenChange`로 팔레트를 제어하고, `defaultOpen`은 비제어 팔레트를 열린 채로 시작합니다. 시트의 코드는 팔레트가 mount된 뒤 페이지가 처음 한가해질 때 받아 오고, 시트는 처음 열릴 때 mount됩니다. 그래서 페이지가 그리기 전에 받아야 하는 것에는 아무것도 더하지 않습니다. 서버에서 렌더링한 페이지에서 열린 채로 시작하는 팔레트는 hydration이 끝난 뒤에 열립니다.

:::

::: fw flutter

`open`과 `onOpenChange`로 팔레트를 제어하고, `defaultOpen`은 비제어 팔레트를 열린 채로 시작합니다. 시트는 열려 있거나 사라지는 동안에만 만들어집니다.

:::

### onSelect

각 명령이 자기 `onSelect`를 가질 수 있고, 팔레트의 `onSelect`는 그 뒤에 항목과 함께 호출됩니다. 어느 쪽이든 팔레트는 닫히며, 입력한 검색어는 닫히는 길에 버려집니다.

### size

`size`는 타입 스케일과 필드의 높이, 시트가 넓어질 수 있는 한계를 정합니다. `width`와 `maxHeight`는 뒤의 두 가지를 각각 덮어씁니다.

<Demo src="command-palette/sizes" frameMinHeight="300">

::: fw react

<<< @/.vitepress/demos/command-palette/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/command_palette/sizes.dart

:::

</Demo>

::: fw react

### className · classNames

`className`은 시트(검색 필드와 행이 놓이는 판)에 붙습니다. 그 바깥과 안쪽은 모두 `classNames`로 갑니다.

```tsx
<CommandPalette
  items={commands}
  className="max-w-2xl"
  classNames={{ backdrop: 'backdrop-blur-none', item: 'rounded-none' }}
/>
```

slot은 `backdrop`, `viewport`, `input`, `list`, `group`, `item`, `empty`입니다. `backdrop`과 `viewport`는 시트 바깥에 그려지므로 시트를 기준으로 쓴 것으로는 찾을 수 없고, `group`은 행 사이의 heading 하나이지 그 아래 행들이 아닙니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

:::

## 접근성

::: fw react

- 시트는 `label`이 이름이 되는 modal dialog입니다. 보이는 제목이 따로 없습니다. 열릴 때 focus가 필드로 들어가고, 닫힐 때 독자가 있던 자리로 되돌아갑니다.
- 필드는 `listbox` 위의 `combobox`이며, 표시된 행은 `aria-activedescendant`로 전달됩니다. 포인터와 방향키가 같은 표시를 움직이므로 Enter가 표시된 것 외의 행을 실행하는 일이 없습니다.
- 같은 `group`의 연속된 행은 제목을 이름으로 하는 `role="group"`으로 묶이므로, 그룹 안으로 들어가면 어느 그룹인지 읽힙니다.
- Escape로 닫힙니다.
- 팔레트가 어떤 명령에 이르는 유일한 통로가 되어서는 안 됩니다. 안에 있는 모든 것은 다른 경로로도 닿을 수 있어야 합니다. 팔레트의 존재를 모르는 독자에게 다른 기회는 없습니다.

:::

::: fw flutter

- 시트는 `label`이 이름이 되는 modal dialog입니다. 보이는 제목이 따로 없습니다. 열릴 때 focus가 필드로 들어가고, 닫힐 때 그 전에 focus를 가졌던 곳으로 되돌아갑니다.
- 방향키가 행 사이로 표시를 옮기는 동안 focus는 필드에 그대로 있고, 비활성 행은 건너뜁니다. 포인터도 같은 표시를 움직이므로 Enter가 표시된 것 외의 행을 실행하는 일이 없습니다. 각 행은 화면 낭독기로 누를 수 있는 버튼입니다.
- 같은 `group`의 연속된 행은 제목을 이름으로 하는 그룹으로 묶이므로, 그룹 안으로 들어가면 어느 그룹인지 읽힙니다.
- Escape, scrim 누르기, 화면 낭독기의 닫기 동작으로 닫힙니다.
- 팔레트가 어떤 명령에 이르는 유일한 통로가 되어서는 안 됩니다. 안에 있는 모든 것은 다른 경로로도 닿을 수 있어야 합니다. 팔레트의 존재를 모르는 독자에게 다른 기회는 없습니다.

:::

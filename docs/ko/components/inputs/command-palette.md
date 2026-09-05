---
title: CommandPalette
order: 32
---

# CommandPalette

<p class="neba-lede">애플리케이션이 할 수 있는 모든 것을 필드 하나 뒤에 둡니다. 메뉴 바가 담을 수 있는 것보다 액션이 많아진 키보드 중심 제품이 취하는 모양입니다. 어디에 두었는지 기억하는 대신, 원하는 것을 입력합니다.</p>

<Demo src="command-palette/hero" />

```tsx
import { CommandPalette } from 'neba';

<CommandPalette
  items={[
    { value: 'deploy', label: 'Deploy production', group: 'Actions', onSelect: deploy },
    { value: 'logs', label: 'Go to logs', group: 'Navigate' }
  ]}
/>;
```

## Props

<PropsTable name="CommandPalette" />

### CommandItem

<PropsTable name="CommandItem" />

[Menu](./menu)가 아닙니다. 메뉴는 한자리에 있는 짧은 목록이고, 찾기 전에 이미 모든 행이 보입니다. [Combobox](./combobox)도 아닙니다. 돌아오는 것은 값이 아니라 벌어지는 일입니다.

## 예시

### items · group

명령은 주어진 순서대로 그려지고, `group`이 바뀔 때마다 제목이 그려집니다. 그래서 한 그룹의 명령은 붙여서 나열해야 합니다. `icon`과 `shortcut`이 행의 양 끝을 채우고, `description`은 라벨 아래 한 줄이 됩니다.

<Demo src="command-palette/groups">

<<< @/.vitepress/demos/command-palette/groups.tsx

</Demo>

### keywords

검색에는 쓰이지만 화면에는 절대 그려지지 않는 단어들입니다. 같은 명령을 다른 제품이 부르는 이름, 약어, 독자가 검색했을 법한 말. `undo`라고 쳐서 `Roll back`이 나오는 것이 팔레트를 두 번 열게 만드는 이유입니다.

### shortcut

팔레트를 여는 키이며 window에 바인딩됩니다. `Mod`는 Mac에서 Command, 그 밖에서는 Control입니다. [Shortcut](../display/shortcut)이 그리는 것과 같은 표기를, 쓰는 대신 읽습니다. `false`는 아무것도 바인딩하지 않습니다. 키보드를 직접 관리하는 애플리케이션을 위한 것입니다.

### onSelect

각 명령이 자기 `onSelect`를 가질 수 있고, 팔레트의 `onSelect`는 그 뒤에 항목과 함께 호출됩니다. 어느 쪽이든 팔레트는 닫히며, 입력한 검색어는 닫히는 길에 버려집니다.

### size

`size`는 타입 스케일과 필드의 높이, 시트가 넓어질 수 있는 한계를 정합니다. `width`와 `maxHeight`는 뒤의 두 가지를 각각 덮어씁니다.

<Demo src="command-palette/sizes">

<<< @/.vitepress/demos/command-palette/sizes.tsx

</Demo>

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

## 접근성

- 시트는 `label`이 이름이 되는 modal dialog입니다. 보이는 제목이 따로 없습니다. 열릴 때 focus가 필드로 들어가고, 닫힐 때 독자가 있던 자리로 되돌아갑니다.
- 필드는 `listbox` 위의 `combobox`이며, 표시된 행은 `aria-activedescendant`로 전달됩니다. 포인터와 방향키가 같은 표시를 움직이므로 Enter가 표시된 것 외의 행을 실행하는 일이 없습니다.
- Escape로 닫힙니다.
- 팔레트가 어떤 명령에 이르는 유일한 통로가 되어서는 안 됩니다. 안에 있는 모든 것은 다른 경로로도 닿을 수 있어야 합니다. 팔레트의 존재를 모르는 독자에게 다른 기회는 없습니다.

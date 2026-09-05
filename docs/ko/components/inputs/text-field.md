---
title: TextField
order: 3
---

# TextField

<p class="neba-lede">한 줄 또는 여러 줄 텍스트를 입력받습니다. 라벨과 설명, 오류 메시지가 하나의 컴포넌트로 묶여 있습니다.</p>

<Demo src="text-field/hero" />

```tsx
import { TextField } from 'neba';

<TextField label="이메일" value={email} onChange={(event) => setEmail(event.target.value)} />;
```

## Props

<PropsTable name="TextField" />

`<input>`의 native 속성은 그대로 전달됩니다. `color`와 `size`는 위 표의 것과 이름이 겹쳐 제외되며, `onChange`는 `multiline`일 때 `<textarea>` 이벤트도 받도록 넓혀져 있습니다.

## 예시

### variant

세 가지 무게 모두 sheet를 색으로 채우지 않습니다. 필드가 담는 것은 사용자가 입력한 텍스트이고, caret과 선택 영역, placeholder가 강조색 채움 위에서는 읽히지 않기 때문입니다. `color`는 테두리와 focus ring, caret에 나타납니다.

<Demo src="text-field/variants">

<<< @/.vitepress/demos/text-field/variants.tsx

</Demo>

### size

[Button](./button)과 높이가 같으므로 툴바처럼 한 줄에 섞어 놓아도 기준선이 맞습니다.

<Demo src="text-field/sizes">

<<< @/.vitepress/demos/text-field/sizes.tsx

</Demo>

### multiline · rows · resize

`multiline`은 `<textarea>`로 렌더링하고 나머지 축은 그대로 유지합니다. `rows={1}`은 한 줄 필드와 정확히 같은 높이입니다. `resize`의 기본값은 세로 방향만 허용합니다. 가로 리사이즈는 폼의 열 정렬을 깨뜨립니다.

<Demo src="text-field/multiline">

<<< @/.vitepress/demos/text-field/multiline.tsx

</Demo>

### startIcon · endIcon · loading

`loading`은 `endIcon` 자리에 spinner를 놓고 `aria-busy`를 붙이지만 입력은 막지 않습니다. 대개 방금 입력한 값 때문에 로딩 중이기 때문입니다.

<Demo src="text-field/icons">

<<< @/.vitepress/demos/text-field/icons.tsx

</Demo>

### error · invalid · disabled · readOnly

`error`에 메시지를 주면 invalid 상태가 함께 켜지고 필드 전체가 `danger` 계열로 옮겨갑니다. 메시지 없이 invalid 상태만 표시하려면 `invalid`를 직접 주세요.

<Demo src="text-field/states">

<<< @/.vitepress/demos/text-field/states.tsx

</Demo>

### value와 onChange

native `<input>`과 동일하게 동작합니다.

<Demo src="text-field/controlled">

<<< @/.vitepress/demos/text-field/controlled.tsx

</Demo>

### shortcuts

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

<Demo src="text-field/shortcuts">

<<< @/.vitepress/demos/text-field/shortcuts.tsx

</Demo>

### classNames

`className`은 루트(라벨과 shell, 그 아래 두 줄을 담는 열)에 붙습니다. `<input>` 자체는 `classNames`로 갑니다. `root` 키는 없습니다. 그것이 이미 `className`이기 때문입니다.

```tsx
<TextField
  label="Email"
  className="w-80"
  classNames={{ label: 'uppercase tracking-wide', control: 'font-mono' }}
/>
```

slot은 `label`, `shell`, `control`, `description`, `error`입니다. `shell`은 테두리와 채움, focus ring을 두른 상자이고 `control`은 그 안의 `<input>` 또는 `<textarea>`입니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

## 접근성

- `label` · `description` · `error`가 `id`와 `aria-describedby`로 컨트롤에 연결됩니다.
- floating label은 제공하지 않습니다.
- focus ring은 `<input>`이 아니라 감싸는 shell에 그려지므로 테두리를 그대로 따라갑니다.
- shell의 여백을 클릭해도 caret이 들어갑니다.

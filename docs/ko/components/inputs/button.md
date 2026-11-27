---
title: Button
order: 1
flutter: true
---

# Button

<p class="neba-lede">액션을 실행하는 컨트롤입니다. 폼 제출, 저장, 삭제처럼 사용자가 의도적으로 일으키는 동작에 씁니다.</p>

<Demo src="button/hero" />

::: fw react

```tsx
import { Button } from 'neba';

<Button onClick={save}>저장</Button>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaButton(onPressed: save, child: const Text('Save'));
```

:::

## Props

<PropsTable name="Button" />

::: fw react

`<button>`의 native 속성은 그대로 전달됩니다. `color`만 위 표의 `color`와 이름이 겹쳐 제외됩니다.

:::

::: fw flutter

라벨은 보통 `Text`인 `child`로, 동작은 `onPressed`로 받습니다. 다른 Flutter 버튼처럼 `onPressed`가 없으면 비활성입니다. 아이콘만 있는 버튼의 이름은 `semanticLabel`로 붙입니다. 라벨은 한 줄을 유지하며, 버튼이 라벨보다 좁게 놓이면 라벨이 가장자리를 넘지 않고 말줄임표로 끝납니다.

:::

공통 축(`variant` `size` `color` `density` `elevation`)의 의미는 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### variant

`solid`는 주 액션, `outline`은 보조 액션, `text`는 목록이나 툴바에 놓이는 낮은 무게의 액션입니다. 한 화면에 `solid`는 하나만 두세요.

<Demo src="button/variants">

::: fw react

<<< @/.vitepress/demos/button/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/variants.dart

:::

</Demo>

### color

여섯 가지 역할 색만 받습니다. 임의의 색상값은 지정할 수 없습니다.

<Demo src="button/colors">

::: fw react

<<< @/.vitepress/demos/button/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/colors.dart

:::

</Demo>

### size

높이와 타입 스케일을 함께 정합니다. `xs` 22px · `sm` 26px · `md` 32px · `lg` 40px · `xl` 48px이며, 데스크톱 기본은 `md`입니다.

<Demo src="button/sizes">

::: fw react

<<< @/.vitepress/demos/button/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/sizes.dart

:::

</Demo>

### density

`density`는 좌우 padding만 바꿉니다. 같은 `size`라면 높이가 동일하므로 한 줄에 섞어 놓아도 기준선이 맞습니다.

<Demo src="button/density">

::: fw react

<<< @/.vitepress/demos/button/density.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/density.dart

:::

</Demo>

### startIcon과 endIcon

::: fw react

아이콘은 `1.2em`으로 그려져 라벨 크기를 따라갑니다. 크기를 따로 지정할 필요가 없습니다. `children` 없이 아이콘만 주면 정사각형 버튼이 되며, 이때는 `aria-label`이 필요합니다. 아이콘 전용 컨트롤이라면 [IconButton](./icon-button)이 `label`을 필수로 요구합니다.

:::

::: fw flutter

아이콘은 버튼이 내려주는 `IconTheme`을 통해 라벨 크기의 1.2배로 그려져 라벨 크기를 따라갑니다. 크기를 따로 지정할 필요가 없습니다. `child` 없이 아이콘만 주면 정사각형 버튼이 되며, 이때는 `semanticLabel`이 필요합니다.

:::

<Demo src="button/icons">

::: fw react

<<< @/.vitepress/demos/button/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/icons.dart

:::

</Demo>

### loading · readOnly · disabled

::: fw react

| prop       | 겉모습                             | focus | native `disabled` |
| ---------- | ---------------------------------- | ----- | ----------------- |
| `loading`  | 그대로. `startIcon` 자리에 spinner | 유지  | 아니오            |
| `readOnly` | 색은 유지, 평평해지고 채도가 빠짐  | 유지  | 아니오            |
| `disabled` | 색 계열을 버리고 중립 회색         | 빠짐  | 예                |

세 상태 모두 클릭이 부모로 전파되지 않습니다.

:::

::: fw flutter

| 인자                             | 겉모습                             | focus |
| -------------------------------- | ---------------------------------- | ----- |
| `loading`                        | 그대로. `startIcon` 자리에 도는 링 | 유지  |
| `readOnly`                       | 색은 유지, 평평해지고 채도가 빠짐  | 유지  |
| `disabled` 또는 `onPressed` 없음 | 색 계열을 버리고 중립 회색         | 빠짐  |

세 상태 모두 `onPressed`를 부르지 않습니다.

:::

<Demo src="button/states">

::: fw react

<<< @/.vitepress/demos/button/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/states.dart

:::

</Demo>

### elevation

그림자 깊이입니다. 기본값 `0`은 그림자가 전혀 없다는 뜻입니다. hover하면 한 단계 올라가고 누르면 한 단계 내려가므로, `0`인 버튼도 눌린 것이 표현됩니다.

<Demo src="button/elevation">

::: fw react

<<< @/.vitepress/demos/button/elevation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/elevation.dart

:::

</Demo>

### fullWidth

컨테이너 너비만큼 확장합니다.

<Demo src="button/full-width">

::: fw react

<<< @/.vitepress/demos/button/full-width.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/button/full_width.dart

:::

</Demo>

### render

::: fw react

`<button>` 대신 다른 요소로 렌더링합니다. 누르면 이동하는 액션은 `<a href>`여야 합니다. 크롤러가 따라갈 수 있고, 스크린리더의 링크 목록에 올라가며, 새 탭으로 열기나 주소 복사 같은 브라우저의 기본 동작이 그대로 살아납니다. 라우터의 `Link`도 같은 방식으로 넘깁니다.

표면과 크기, press 신호는 그대로입니다. `<a>`에는 `disabled`가 없으므로, 사용할 수 없어야 하는 버튼은 `<button>`으로 두세요.

:::

::: fw flutter

바꿀 요소가 없습니다. 이동하는 버튼은 `onPressed`에서 라우터를 부르고, 표면과 크기, press 신호는 어느 쪽이든 같습니다.

:::

::: fw react

<Demo src="button/render">

<<< @/.vitepress/demos/button/render.tsx

</Demo>

:::

## 접근성

::: fw react

- 기본적으로 native `<button>`으로 렌더링됩니다. `type`도 그대로 전달되므로 폼 안에서 `type="submit"`이 동작합니다.
- `render`로 요소를 바꿔도 그 요소의 semantics는 유지됩니다. `<a href>`는 `role="button"`으로 덮이지 않고 링크로 남습니다.
- 아이콘만 있는 버튼에는 `aria-label`을 주세요.
- focus ring은 `:focus-visible`에서만 나타나므로 마우스 클릭에는 보이지 않습니다.

:::

::: fw flutter

- 활성이든 아니든 화면 낭독기에는 버튼이며, 탭과 Enter, Space가 모두 누릅니다.
- 아이콘만 있는 버튼에는 `semanticLabel`을 주세요.
- focus ring은 키보드 focus에서만 나타나므로 탭에는 보이지 않습니다.

:::

- `loading`과 `readOnly`는 focus를 유지합니다. tab 순서에서 사라지면 키보드 사용자가 페이지 구조를 잃기 때문입니다.
- 모든 색 조합이 채움 위 글자 대비 4.5:1을 만족합니다.

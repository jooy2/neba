---
title: Switch
order: 7
flutter: true
---

# Switch

<p class="neba-lede">설정을 즉시 켜고 끄는 컨트롤입니다. 조작하는 순간 효력이 생기는 항목에 씁니다.</p>

<Demo src="switch/hero" />

::: fw react

```tsx
import { Switch } from 'neba';

<Switch label="이메일 알림" defaultChecked />;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaSwitch(label: Text('이메일 알림'), defaultChecked: true);
```

:::

## Props

<PropsTable name="Switch" />

::: fw flutter

`label`과 `description`, `error`는 위젯이고 보통 `Text`를 넘깁니다. Flutter 스위치에는 참여할 폼 전송이 없으므로 `name`이 없고, React 패키지가 `labelSide`의 예전 이름으로만 남겨 둔 `labelPlacement`도 없습니다. 라벨이 없는 스위치의 이름은 `semanticLabel`로 붙입니다.

:::

아래에 저장 버튼이 있어서 값이 폼과 함께 제출된다면 [Checkbox](./checkbox)를 쓰세요. 그것이 두 컴포넌트를 가르는 기준입니다.

## 예시

### checked와 onCheckedChange

`checked`와 `onCheckedChange`로 controlled, `defaultChecked`로 uncontrolled 컴포넌트가 됩니다.

### disabled · readOnly

<Demo src="switch/states">

::: fw react

<<< @/.vitepress/demos/switch/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/switch/states.dart

:::

</Demo>

### labelSide

`end`(기본)는 컨트롤 뒤에 라벨을 두어 설명처럼 읽히게 합니다. `start`는 라벨이 왼쪽 열을 이루고 스위치가 오른쪽에 정렬되는 설정 목록에 적합합니다.

::: fw react

예전 이름은 `labelPlacement`였습니다. 이 이름은 모든 필드에서 라벨을 필드의 위, 테두리, 안 가운데 어디에 그릴지를 뜻하고, [NebaProvider](../../guide/provider)가 필드 전체에 채워 넣는 값입니다. `labelSide`가 없으면 여기서도 `labelPlacement`를 그대로 읽으며, 다음 minor 릴리스에서 빠집니다.

:::

::: fw flutter

값은 `NebaSwitchLabelSide.start`와 `NebaSwitchLabelSide.end`입니다. 스위치가 오른쪽에 줄을 맞추려면 열이 스위치를 자기 너비만큼 늘려야 하며, `NebaFlex` 열은 기본으로 그렇게 합니다.

:::

<Demo src="switch/placement">

::: fw react

<<< @/.vitepress/demos/switch/placement.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/switch/placement.dart

:::

</Demo>

### size

<Demo src="switch/sizes">

::: fw react

<<< @/.vitepress/demos/switch/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/switch/sizes.dart

:::

</Demo>

### classNames

::: fw react

`className`은 track이 아니라 감싸는 field wrapper에 붙습니다. track과 thumb은 `classNames`로 갑니다.

```tsx
<Switch label="Email alerts" classNames={{ control: 'w-14', thumb: 'rounded-sm' }} />
```

slot은 `label`, `control`, `thumb`, `description`, `error`입니다. `control`은 track(켜지면 채워지는 알약)이고 `thumb`은 그 위를 오가는 원입니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

:::

::: fw flutter

class 이름은 없습니다. 라벨과 설명, 오류는 위젯이라 각자 스타일을 받고, track과 thumb은 스위치가 그립니다.

:::

## 접근성

::: fw react

- `role="switch"`와 함께 숨은 `<input>`이 렌더링됩니다.
- 라벨이 컨트롤과 연결되어 있어 글자를 눌러도 전환됩니다.
- `label`을 쓰지 않는다면 `aria-label`을 주세요.
- thumb의 이동은 `prefers-reduced-motion`에서 즉시 전환됩니다.

:::

::: fw flutter

- 화면 낭독기에는 켜짐이나 꺼짐 상태의 스위치 하나로 들립니다. `Text`로 준 라벨이 이름이 되고, `Text`로 준 설명과 오류는 그 뒤에 읽힙니다.
- 라벨을 누르거나 라벨과 track 사이의 간격을 눌러도 전환됩니다.
- `label`을 쓰지 않는다면 `semanticLabel`을 주세요.
- 플랫폼이 움직임을 줄여 달라고 하면 thumb의 이동은 즉시 전환됩니다.

:::

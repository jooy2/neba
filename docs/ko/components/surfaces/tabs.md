---
title: Tabs
order: 4
flutter: true
---

# Tabs

<p class="neba-lede">같은 자리에서 여러 패널 중 하나만 보여 줍니다. 내용을 나란히 두기보다 전환해서 볼 때 씁니다.</p>

<Demo src="tabs/hero" />

::: fw react

```tsx
import { Tab, TabPanel, Tabs } from 'neba';

<Tabs defaultValue="overview">
  <Tab value="overview">개요</Tab>
  <Tab value="usage">사용량</Tab>

  <TabPanel value="overview">오늘 배포 세 번, 전부 성공.</TabPanel>
  <TabPanel value="usage">빌드 1,284분 사용.</TabPanel>
</Tabs>;
```

`<TabList>` 같은 wrapper는 없습니다. `Tab`과 `TabPanel`을 나란히 두면 컴포넌트가 알아서 탭 바와 패널 영역으로 나눕니다. Fragment 안은 들여다보지만, `TabPanel`을 렌더링하는 직접 만든 컴포넌트는 알아보지 못하므로 `TabPanel`을 자식에 직접 쓰세요.

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaTabs<String>(
  defaultValue: 'overview',
  children: <Widget>[
    NebaTab<String>(value: 'overview', child: Text('개요')),
    NebaTab<String>(value: 'usage', child: Text('사용량')),
    NebaTabPanel<String>(value: 'overview', child: Text('오늘 배포 세 번, 전부 성공.')),
    NebaTabPanel<String>(value: 'usage', child: Text('빌드 1,284분 사용.')),
  ],
);
```

리스트를 감싸는 wrapper는 없습니다. `NebaTab`과 `NebaTabPanel`을 `children`에 나란히 두면 위젯이 타입을 보고 탭 바와 패널 영역으로 나눕니다. `NebaTabPanel`을 빌드하는 직접 만든 위젯은 알아보지 못하므로 `NebaTabPanel`을 자식에 직접 쓰세요.

:::

## Props

### Tabs

<PropsTable name="Tabs" />

::: fw flutter

세트는 탭의 `value` 타입을 제네릭으로 받습니다. `value`와 `onValueChange`로 controlled 세트가 되며, `value`를 `null`로 두면 `defaultValue`에서 시작해 상태를 스스로 관리합니다.

:::

### Tab

<PropsTable name="Tab" />

### TabPanel

<PropsTable name="TabPanel" />

## 예시

### variant

`variant`는 패널이 아니라 탭 **바**의 무게입니다.

- `solid`: 홈통 안에서 채워진 타일이 탭 사이를 움직입니다.
- `outline`: 바 가장자리의 선 위에 표시자가 올라갑니다.
- `text`: 선 없이 표시자만 남습니다. 이미 테두리가 있는 [Card](./card) 안에 넣을 때 씁니다.

<Demo src="tabs/variants">

::: fw react

<<< @/.vitepress/demos/tabs/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/variants.dart

:::

</Demo>

### orientation

`vertical`은 탭 바를 <Fw react="왼쪽에" flutter="시작 쪽에" /> 세로로 놓습니다. 방향키도 함께 세로축으로 바뀝니다.

<Demo src="tabs/orientation">

::: fw react

<<< @/.vitepress/demos/tabs/orientation.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/orientation.dart

:::

</Demo>

### align

탭이 라벨보다 넓을 때 라벨이 놓이는 자리입니다. 모든 탭이 가장 긴 것만큼 넓어지는 세로 바, 또는 `fullWidth`를 준 가로 바가 그런 경우입니다.

라벨과 아이콘만 옮기고 나머지는 그대로 둡니다. `start`와 `end`는 논리 값이라 읽는 방향을 따릅니다.

<Demo src="tabs/align">

::: fw react

<<< @/.vitepress/demos/tabs/align.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/align.dart

:::

</Demo>

### overflow와 lines

`overflow`는 자리보다 탭이 많을 때 바가 무엇을 할지 정합니다. 기본값 `scroll`은 한 줄을 유지한 채 그 위를 스크롤하고, 그 방향에 바가 더 남아 있는 동안 양 끝을 흐립니다. 스크롤바 자체는 감춥니다. `wrap`은 탭이 필요한 만큼 줄을 쓰고, 선택된 탭 아래의 선도 그 탭이 있는 줄로 따라갑니다.

`lines`는 wrap하는 바의 높이를 탭 줄 수로 제한하고, 그 위로는 스크롤합니다. `overflow`가 `wrap`일 때만 읽습니다.

<Demo src="tabs/overflow" minHeight="420">

::: fw react

<<< @/.vitepress/demos/tabs/overflow.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/overflow.dart

:::

</Demo>

### wheel

`wheel`은 바 위에서 굴린 마우스 휠을 바를 따라가는 이동으로 바꿉니다. 기본값은 켜짐이며, <Fw react="wheel={false}" flutter="wheel: false" code />로 끕니다.

넘치는 바 위에 포인터가 있는 동안 휠은 양 끝에서도 바만 움직이고, 포인터가 바 밖으로 나가면 페이지가 휠을 되찾습니다. 자리가 남는 바는 휠을 가져가지 않으며, 옆으로 미는 트랙패드는 <Fw react="브라우저에" flutter="바의 스크롤 뷰에" /> 맡깁니다.

<Demo src="tabs/wheel" minHeight="320">

::: fw react

<<< @/.vitepress/demos/tabs/wheel.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/wheel.dart

:::

</Demo>

### startIcon과 endIcon

라벨 앞뒤에 아이콘이나 개수를 넣습니다.

<Demo src="tabs/icons">

::: fw react

<<< @/.vitepress/demos/tabs/icons.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/tabs/icons.dart

:::

</Demo>

### size

[Button](../inputs/button)과 같은 컨트롤 높이 단계를 씁니다. `md` 탭과 `md` Button이 모두 32px이므로 툴바 안에 나란히 놓을 수 있습니다.

### activateOnFocus

기본값은 꺼짐입니다. 방향키로 탭을 지나가는 동안에는 패널이 바뀌지 않고, Enter나 Space로 활성화합니다. 패널이 데이터를 불러오는 경우 방향키 이동만으로 요청이 여러 번 발생하는 것을 막습니다.

### keepMounted

::: fw react

`TabPanel`에 지정하면 선택되지 않은 패널의 React 트리를 유지합니다. 그렇지 않으면 선택되지 않은 패널은 DOM에 없으므로 서버 렌더와 크롤러 색인에도 없습니다. 검색에 걸려야 하는 내용이 든 패널에는 `keepMounted`를 주세요.

`Tabs`에 지정하면 모든 패널에 같은 값이 적용되어 패널마다 쓰지 않아도 됩니다. 패널에 직접 준 `keepMounted`가 우선하므로, 한 패널에 `keepMounted={false}`를 주면 그 패널만 빠집니다.

```tsx
<Tabs defaultValue="overview" keepMounted>
  <Tab value="overview">Overview</Tab>
  <Tab value="usage">Usage</Tab>
  <TabPanel value="overview">…</TabPanel>
  <TabPanel value="usage">…</TabPanel>
</Tabs>
```

:::

::: fw flutter

`NebaTabPanel`에 지정하면 선택되지 않은 패널을 숨긴 채 빌드된 상태로 남겨, 다른 탭을 고른 동안에도 안의 폼이 입력한 값을 지킵니다. 그렇지 않으면 선택되지 않은 패널은 아예 빌드하지 않습니다.

`NebaTabs`에 지정하면 모든 패널에 같은 값이 적용되어 패널마다 쓰지 않아도 됩니다. 패널에 직접 준 `keepMounted`가 우선하므로, 한 패널에 `keepMounted: false`를 주면 그 패널만 빠집니다.

```dart
const NebaTabs<String>(
  defaultValue: 'overview',
  keepMounted: true,
  children: <Widget>[
    NebaTab<String>(value: 'overview', child: Text('Overview')),
    NebaTab<String>(value: 'usage', child: Text('Usage')),
    NebaTabPanel<String>(value: 'overview', child: Text('…')),
    NebaTabPanel<String>(value: 'usage', child: Text('…')),
  ],
);
```

:::

## 접근성

::: fw react

- 탭 바 전체가 tab 정지 하나이고, 그 안에서는 방향키와 Home/End로 이동합니다(roving tab index).
- `tab` / `tabpanel` role과 그 사이의 `aria-controls`가 연결됩니다.
- 패널 안에 focus 받을 요소가 없으면 패널 자체가 focus를 받으므로 키보드로 내용에 닿을 수 있습니다.

:::

::: fw flutter

- 탭 바 전체가 focus 순서의 정지 하나이고, 그 안에서는 방향키와 Home/End로 이동합니다. 비활성화된 탭에도 닿지만 선택되지는 않으며, 방향키로 닿은 탭은 보이는 자리까지 스크롤됩니다.
- 화면 낭독기는 탭 바와 그 안의 탭을 읽고, 선택된 탭을 선택됨으로 알립니다. 각 패널은 탭의 이름이 붙은 tab panel로 읽습니다.
- 패널은 따로 focus를 받지 않습니다. 화면 낭독기는 focus 없이도 패널을 읽고, Flutter에서는 글 덩어리에 focus가 닿는다고 스크롤되지도 않습니다.

:::

---
title: Alert
order: 1
flutter: true
---

# Alert

<p class="neba-lede">방금 일어난 일을 페이지 안에서 알리는 메시지입니다. 저장 성공, 검증 오류, 주의가 필요한 설정처럼 화면에 남아 있어야 하는 알림에 씁니다.</p>

<Demo src="alert/hero" />

::: fw react

```tsx
import { Alert } from 'neba';

<Alert color="success">변경 사항을 저장했습니다.</Alert>
<Alert color="danger" title="배포 실패" onClose={dismiss}>
  빌드가 코드 1로 종료되었습니다.
</Alert>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaAlert(color: NebaColor.success, child: Text('변경 사항을 저장했습니다.'));
NebaAlert(
  color: NebaColor.danger,
  title: const Text('배포 실패'),
  onClose: dismiss,
  child: const Text('빌드가 코드 1로 종료되었습니다.'),
);
```

:::

## Props

<PropsTable name="Alert" />

`color`의 기본값은 `primary`가 아니라 `info`입니다.

::: fw flutter

메시지는 `child`, 제목은 `title`이며 둘 다 보통 `Text`입니다. React에서 `icon={false}`로 쓰는 것은 `showIcon: false`로 쓰고, `role`에는 `SemanticsRole`을 넘깁니다. Alert는 주어진 너비를 모두 차지하므로 `Row` 안에 둘 때는 `Expanded`로 감싸거나 너비를 따로 정해 주세요.

:::

## 예시

### <Fw react="title과 children" flutter="title과 child" />

`title` 없이 <Fw react="`children`만" flutter="`child`만" /> 주면 한 줄 알림, `title`을 함께 주면 제목과 본문이 있는 두 줄 알림이 됩니다. 같은 컴포넌트에서 채운 slot의 개수만 다릅니다.

<Demo src="alert/shapes">

::: fw react

<<< @/.vitepress/demos/alert/shapes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/shapes.dart

:::

</Demo>

### variant

Alert는 색이 입혀지는 대상이므로 [Box](../surfaces/box)와 달리 sheet 자체가 물듭니다. 폼 안에 넣을 때는 `text`를 쓰세요. 입력 필드 사이에 테두리 사각형이 하나 더 생기지 않습니다.

<Demo src="alert/variants">

::: fw react

<<< @/.vitepress/demos/alert/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/variants.dart

:::

</Demo>

### color

`color`가 심각도를 정하고, 심각도에 따라 글리프도 함께 바뀝니다. 여섯 계열에 네 가지 그림이 배정되어 있어 색을 구분하지 못해도 종류가 전달됩니다.

<Demo src="alert/colors">

::: fw react

<<< @/.vitepress/demos/alert/colors.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/colors.dart

:::

</Demo>

### <Fw react="icon" flutter="icon · showIcon" />

::: fw react

기본 글리프 대신 다른 node를 넘길 수 있고, `icon={false}`면 글리프를 그리지 않습니다.

Alert 안의 `<svg>`는 주변 글자의 `1.2em`으로 그려집니다. 어떤 아이콘 세트에서 가져오든 크기를 따로 맞춰 줄 필요가 없습니다. `<svg>`가 아닌 것(`<img>`, 스프라이트, 아이콘 폰트의 글리프)은 자기 크기를 그대로 씁니다.

:::

::: fw flutter

`icon`에 위젯을 넘기면 기본 글리프를 바꾸고, `showIcon: false`면 글리프를 그리지 않습니다.

Alert는 글자 크기의 1.2배로 `IconTheme`을 내려주므로 `Icon`은 크기를 따로 정하지 않아도 알맞게 그려지고, 글리프는 메시지 첫 줄의 가운데에 맞춰집니다. `Icon`이 아닌 위젯은 자기 크기를 그대로 씁니다.

:::

### action과 onClose

`action`은 <Fw react="`children`" flutter="`child`" /> 바깥의 별도 slot이므로, 메시지가 여러 줄로 줄바꿈되어도 액션은 첫 줄에 남습니다. `onClose`를 넘기면 닫기 버튼(×)이 나타납니다.

<Demo src="alert/dismissing">

::: fw react

<<< @/.vitepress/demos/alert/dismissing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/alert/dismissing.dart

:::

</Demo>

## 접근성

::: fw react

- 심각도가 live region을 정합니다. `warning`과 `danger`는 screen reader가 읽던 내용을 끊는 `role="alert"`, 나머지는 끊기지 않고 기다리는 `role="status"`입니다. role은 제목과 메시지에 붙으므로 action과 닫기 버튼은 함께 읽히지 않습니다.
- screen reader는 live region 안의 내용이 바뀔 때 그것을 읽습니다. 문구를 담은 채 마운트되는 Alert는 모든 screen reader가 읽어 주지는 않습니다. 반드시 들려줘야 하는 문구라면 Alert를 마운트해 둔 채 내용만 바꾸거나, 이미 페이지에 있는 live region에 문구를 쓰세요.
- `role`을 직접 넘기면 기본값을 덮어쓰며, 같은 요소에 붙습니다.

:::

::: fw flutter

- 심각도가 제목과 메시지가 놓이는 live region을 정합니다. action과 닫기 버튼은 그 바깥에 있으므로 메시지와 함께 읽히지 않습니다. 웹에서는 `warning`과 `danger`가 screen reader가 읽던 내용을 끊는 `SemanticsRole.alert`, 나머지는 끊기지 않고 기다리는 `SemanticsRole.status`입니다.
- Android와 iOS에는 `alert`나 `status` role이 없습니다. 이 플랫폼에서는 제목과 메시지가 live region이 되어 Alert가 나타날 때와 내용이 바뀔 때마다 읽히며, 두 심각도를 똑같이 읽습니다.
- `role`을 넘기면 기본값을 덮어씁니다. `SemanticsRole.none`이면 메시지가 어떤 live region에도 들어가지 않습니다.
- ×는 옆 글자 크기로 그려지지만, 누르는 영역은 주변 여백까지 넓혀 가로세로 24픽셀입니다.

:::

- 여러 Alert가 있는 화면에서는 `closeLabel`로 무엇을 닫는지 밝혀 주세요.
- 닫기 버튼의 접근성 이름은 `locale`이 정합니다. `closeLabel`로 직접 쓸 수도 있습니다.

---
title: FilePicker
order: 10
flutter: true
---

# FilePicker

<p class="neba-lede">파일을 끌어다 놓거나 눌러서 파일 창을 여는 dropzone입니다. 크기와 형식, 개수 제한을 검사하고 거부된 파일을 따로 알려 줍니다.</p>

<Demo src="file-picker/hero" />

::: fw react

```tsx
import { FilePicker } from 'neba';

<FilePicker
  multiple
  label="첨부"
  accept="image/*,.pdf"
  maxSize={5_000_000}
  maxFiles={4}
  onFilesChange={setFiles}
  onReject={setRejected}
/>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaFilePicker(
  multiple: true,
  label: const Text('첨부'),
  accept: 'image/*,.pdf',
  maxSize: 5000000,
  maxFiles: 4,
  onPick: pickWithTheAppsDialog,
  onFilesChange: (List<NebaFile> files) => setState(() => this.files = files),
  onReject: (List<NebaFileRejection> rejected) => setState(() => this.rejected = rejected),
);
```

:::

## Props

<PropsTable name="FilePicker" />

::: fw react

`<div>`의 native 속성은 root로 전달됩니다. `color` · `defaultValue` · `title`은 위 표와 이름이 겹쳐 제외되고, `children`도 picker가 직접 그리므로 제외됩니다. `id`는 root가 아니라 영역 버튼에 붙습니다.

:::

::: fw flutter

위젯 계층에는 파일 창도, 앱 바깥에서 오는 파일을 받는 drop target도 없고 이 패키지는 플러그인을 쓰지 않습니다. 그래서 파일은 앱이 넘겨주며, 길은 세 가지입니다.

- **누르기.** 상자를 누르거나 Enter, Space를 누르면 `onPick`이 불립니다. 앱이 쓰는 파일 창을 열고 고른 파일을 돌려주면 됩니다. `onPick`이 없으면 상자는 드롭된 파일만 받고 focus 순서에도 들지 않습니다.
- **앱 안에서 끌기.** 상자는 `DragTarget`이라, `data`가 `NebaFile`이나 `List<NebaFile>`인 `Draggable`을 놓으면 받습니다.
- **앱 바깥에서 놓기.** 플러그인이 주는 앱의 drop target이 받은 파일을 picker의 `NebaFilePickerState`에 있는 `drop()`으로 넘깁니다. state는 `GlobalKey`로 얻고, 드래그가 위에 있는 동안 `dragging`을 켜면 테두리가 밝아집니다.

파일 하나는 `NebaFile`입니다. `name`, 바이트 단위의 `size`, 미디어 `type`, 그리고 앱이 파일을 가리키는 방식인 `data`를 담고, picker는 `data`를 읽지 않습니다. `icon`은 위젯이고, `showIcon: false`가 React의 `icon={null}`입니다. 제출할 `<input type="file">`도 라벨이 가리킬 대상도 없으므로 `name`, `required`, `id`는 없습니다. [Form](./form) 안의 picker는 `NebaFormField`로 참여하고, 파일이 꼭 있어야 하는지는 그 `validator`가 정합니다. `nebaFormatFileSize`는 목록과 같은 방식으로 크기를 적으며, `formatFileSize`에 해당합니다.

<PropsTable name="NebaFile" />

:::

## 예시

### variant

세 가지 무게 모두 점선 테두리를 공유합니다.

<Demo src="file-picker/variants">

::: fw react

<<< @/.vitepress/demos/file-picker/variants.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/file_picker/variants.dart

:::

</Demo>

### accept · maxSize · maxFiles

::: fw react

브라우저의 `accept` 속성은 파일 창에만 적용되고 드래그로 도착한 파일에는 적용되지 않으므로, 이 컴포넌트가 같은 문자열을 직접 검사합니다. `.확장자` · `type/subtype` · `type/*` 세 형태를 모두 지원합니다.

:::

::: fw flutter

어느 길로 왔든 모든 파일을 `accept`로 검사합니다. `onPick`이 여는 창에도 같은 문자열을 넘겨 그 파일만 보이게 하세요. `.확장자` · `type/subtype` · `type/*` 세 형태를 모두 지원합니다.

:::

`maxFiles`는 한 번에 놓을 수 있는 개수가 아니라 **보유할 수 있는 총 개수**입니다. 이미 두 개를 들고 있는 <Fw react="`maxFiles={3}`" flutter="`maxFiles: 3`" /> 픽커에 세 개를 놓으면 하나만 받아들입니다.

### onReject

제한에 걸려 거부된 파일과 그 이유를 전달합니다. 이 핸들러가 없으면 거부된 파일이 아무 표시 없이 사라지므로 반드시 붙이세요.

<Demo src="file-picker/rejection">

::: fw react

<<< @/.vitepress/demos/file-picker/rejection.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/file_picker/rejection.dart

:::

</Demo>

### disabled · readOnly · error

<Demo src="file-picker/states">

::: fw react

<<< @/.vitepress/demos/file-picker/states.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/file_picker/states.dart

:::

</Demo>

### title · hint · icon · showList

`title`과 `hint`는 dropzone 안의 안내 문구, `icon`은 그 위의 글리프입니다. `showList`는 선택된 파일 목록을 dropzone 아래에 표시합니다. `removeLabel`로 개별 제거 버튼의 이름을 지정합니다.

## 접근성

::: fw react

- 상자는 `<div>`이고 그 안의 누를 수 있는 영역이 실제 `<button>`입니다. 파일 목록은 그 버튼 바깥에 있으므로 제거 버튼들이 열기 버튼 안에 중첩되지 않습니다.
- 버튼의 이름은 `label` 뒤에 상자에 적힌 문구를 이은 것이라, 한 폼에 피커가 둘 있어도 무엇을 위한 것인지로 구별됩니다.
- `<input type="file">`은 `required` 검증에 그대로 참여하고, 목록에 있는 파일만 들고 있습니다. 그래서 폼은 끌어다 놓은 파일을 제출하고 목록에서 뺀 파일은 제출하지 않습니다. `readOnly` 픽커도 들고 있는 파일을 제출하며, 폼에서 빠지는 것은 `disabled`뿐입니다.

:::

::: fw flutter

- 상자는 `onPick`이 있는 동안 버튼이고, 파일 목록은 그 바깥에 있어 제거 버튼은 각자 독립된 버튼입니다.
- 상자의 이름은 `Text` 라벨 뒤에 상자에 적힌 문구를 이은 것이라, 한 폼에 피커가 둘 있어도 무엇을 위한 것인지로 구별됩니다. `Text`로 된 설명이나 오류는 이름 뒤에 읽힙니다.
- 키보드로 파일을 지우면 focus는 그 자리로 올라온 제거 버튼에, 마지막 파일이었다면 바로 앞 버튼에, 남은 파일이 없으면 상자에 놓입니다.

:::

---
title: Dialog
order: 2
flutter: true
---

# Dialog

<p class="neba-lede">답할 때까지 페이지를 가리는 modal sheet입니다. 확인이 필요한 작업이나 흐름을 끊고 처리해야 하는 입력에 씁니다.</p>

<Demo src="dialog/hero" align="center" frameMinHeight="300" />

::: fw react

```tsx
import { Button, Dialog, DialogClose } from 'neba';

<Dialog
  trigger={<Button color="danger">워크스페이스 삭제</Button>}
  title="이 워크스페이스를 삭제할까요?"
  description="안에 있는 프로젝트·배포·로그가 함께 사라집니다."
  actions={<DialogClose render={<Button color="danger">삭제</Button>} />}
>
  되돌릴 수 없습니다.
</Dialog>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaDialog(
  triggerBuilder: (BuildContext context, VoidCallback open) {
    return NebaButton(
      onPressed: open,
      color: NebaColor.danger,
      child: const Text('워크스페이스 삭제'),
    );
  },
  title: const Text('이 워크스페이스를 삭제할까요?'),
  description: const Text('안에 있는 프로젝트·배포·로그가 함께 사라집니다.'),
  actions: <Widget>[
    NebaDialogClose(
      builder: (BuildContext context, VoidCallback close) {
        return NebaButton(onPressed: close, color: NebaColor.danger, child: const Text('삭제'));
      },
    ),
  ],
  child: const Text('되돌릴 수 없습니다.'),
);
```

:::

## Props

<PropsTable name="Dialog" />

::: fw react

`<div>`의 native 속성은 popup으로 전달됩니다. `color` · `title` · `children`만 위 표와 이름이 겹쳐 제외됩니다.

:::

::: fw flutter

trigger는 [Drawer](../surfaces/drawer)와 같은 builder입니다. `triggerBuilder`는 dialog를 여는 callback을 받아 호출되고, 그것이 만든 위젯은 dialog를 쓴 자리에 남습니다. [Popover](../surfaces/popover)는 popup이 trigger에 매달려 그 옆에 놓이므로 trigger를 위젯으로 받습니다. dialog는 어디에도 매달리지 않으므로 Neba 컨트롤뿐 아니라 목록의 한 줄이나 제스처 등 어떤 위젯이든 열 수 있습니다.

dialog는 앱의 root `Overlay`에 열립니다. navigator가 있는 `WidgetsApp`에는 이미 있고, navigator 없이 만든 앱은 home을 `Overlay.wrap`으로 감쌉니다. 시트는 dialog를 쓴 자리에서 빌드되므로 그 자리의 테마와 `NebaProvider` 기본값을 그대로 씁니다. `initialFocus`와 `finalFocus`는 ref나 함수 대신 `FocusNode`를 받고, `role`은 React의 `role` 속성, `semanticLabel`은 `aria-label`에 해당합니다.

:::

`variant`와 `elevation`은 없습니다. modal은 항상 3단계 그림자를 답니다.

## 예시

### size와 width

`size`는 타입 스케일과 여백은 물론 sheet의 최대 너비까지 함께 정합니다. 작은 글씨로 넓은 표나 diff를 보여 줘야 하는 경우처럼 그 조합에서 벗어나야 할 때는 <Fw react="`width`에 길이를" flutter="`width`에 논리 픽셀 값을" /> 직접 지정하세요.

<Demo src="dialog/sizes" frameMinHeight="340">

::: fw react

<<< @/.vitepress/demos/dialog/sizes.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/dialog/sizes.dart

:::

</Demo>

### dividers

본문이 길면 본문만 스크롤되고 제목과 액션은 제자리에 남습니다. `dividers`는 그 경계에 선을 그어, 헤더가 함께 스크롤되지 않았음을 보여 줍니다.

<Demo src="dialog/scrolling" frameMinHeight="460">

::: fw react

<<< @/.vitepress/demos/dialog/scrolling.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/dialog/scrolling.dart

:::

</Demo>

### dismissible

<Fw react="`dismissible={false}`는" flutter="`dismissible: false`는" /> Esc와 바깥 <Fw react="클릭을" flutter="누름을" /> 함께 막습니다. `actions`에 답할 수 있는 버튼이 있을 때만 끄세요. 그 외에는 나갈 방법이 없습니다.

<Demo src="dialog/controlled" frameMinHeight="340">

::: fw react

<<< @/.vitepress/demos/dialog/controlled.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/dialog/controlled.dart

:::

</Demo>

### <Fw react="DialogClose" flutter="NebaDialogClose" />

::: fw react

`open` 상태를 직접 들지 않고도 버튼으로 Dialog를 닫을 수 있습니다. `render`로 원하는 컨트롤을 넣으세요.

```tsx
actions={
  <>
    <DialogClose render={<Button variant="text" color="secondary">취소</Button>} />
    <DialogClose render={<Button color="danger">삭제</Button>} />
  </>
}
```

:::

::: fw flutter

`open` 상태를 직접 들지 않고도 버튼으로 Dialog를 닫을 수 있습니다. `builder`가 자기가 속한 dialog를 닫는 callback을 받으며, dialog가 `dismissible`이든 아니든 닫습니다.

```dart
actions: <Widget>[
  NebaDialogClose(
    builder: (BuildContext context, VoidCallback close) => NebaButton(
      onPressed: close,
      variant: NebaVariant.text,
      color: NebaColor.secondary,
      child: const Text('취소'),
    ),
  ),
  NebaDialogClose(
    builder: (BuildContext context, VoidCallback close) =>
        NebaButton(onPressed: close, color: NebaColor.danger, child: const Text('삭제')),
  ),
],
```

:::

::: fw react

### classNames

`className`은 popup(sheet 자체이며, 부르는 사람이 "dialog"라고 할 때 가리키는 것)에 붙습니다. 그 바깥과 안쪽은 모두 `classNames`로 갑니다.

```tsx
<Dialog
  title="Delete this?"
  classNames={{ backdrop: 'backdrop-blur-none', actions: 'justify-between' }}
/>
```

slot은 `backdrop`, `viewport`, `title`, `description`, `close`, `body`, `actions`입니다. 앞의 둘은 달리 닿을 방법이 없는 것들입니다. 둘 다 popup 바깥, `<body>` 끝에 그려지므로 sheet를 기준으로 쓴 선택자로는 찾을 수 없습니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

:::

::: fw flutter

### fullScreen

`fullScreen`은 편집기나 휴대폰 크기의 화면을 위해 창을 가장자리까지 채우고 모서리를 각지게 합니다. 시트는 시스템 inset 아래까지 깔리고, 시트 위의 내용은 상태 표시줄, 노치, 홈 인디케이터, 키보드를 피해 안쪽에 놓입니다. 전체 화면이 아닌 시트는 inset에 더해 창과 16픽셀 간격을 두고, 키보드가 올라오면 그 위로 줄어들어 본문이 키보드 아래로 사라지지 않고 스크롤됩니다.

```dart
NebaDialog(fullScreen: true, title: const Text('글 편집'), child: editor);
```

:::

## 접근성

::: fw react

- `title`과 `description`은 각각 `aria-labelledby`, `aria-describedby`로 연결됩니다. `title`은 실제 `<h2>`로 렌더링됩니다.
- focus trap, scroll lock, 뒤 페이지 inert 처리, 닫을 때 trigger로 focus 복귀가 모두 적용됩니다.
- `showClose`는 기본값이 켜짐입니다. modal에서 나가는 길은 항상 보여야 하고, 터치 screen reader가 팝업을 빠져나오는 통로이기도 합니다.
- ×의 접근성 이름은 `locale`이 정합니다. `closeLabel`로 직접 쓸 수도 있습니다.

:::

::: fw flutter

- 시트는 route를 가르는 dialog입니다. 화면 낭독기는 dialog만 읽고, 안에서 처음 focus를 받을 수 있는 것이 focus를 받으며, Tab은 안에서만 돌고, 닫히면 focus가 열리기 전의 자리로 돌아갑니다.
- `title`은 레벨 2 heading이자 dialog의 이름입니다. Flutter에는 `aria-describedby`에 해당하는 것이 없으므로 `description`은 읽는 순서대로 제목 다음에 읽힙니다. 제목이 없는 dialog에는 `semanticLabel`을 주세요.
- `dismissible: false`는 Esc, 바깥 누름, 화면 낭독기의 닫기 동작을 모두 막습니다. `role: SemanticsRole.alertDialog`를 주면 반드시 답해야 하는 질문이 되어 더 급하게 알립니다.
- `showClose`는 기본값이 켜짐입니다. modal에서 나가는 길은 항상 보여야 하고, 터치 screen reader가 팝업을 빠져나오는 통로이기도 합니다.
- ×의 이름은 `locale`이 정합니다. `closeLabel`로 직접 쓸 수도 있습니다.

:::

---
title: Toast
order: 3
flutter: true
---

# Toast

<p class="neba-lede">화면 한쪽에 잠깐 떠올랐다 사라지는 알림입니다. 사용자의 흐름을 끊지 않고 작업 결과를 전달할 때 씁니다.</p>

<Demo src="toast/hero" align="center" minHeight="280" />

::: fw react

```tsx
import { ToastProvider, useToast } from 'neba';

// 앱 전체를 한 번 감쌉니다
<ToastProvider position="bottom-end">{children}</ToastProvider>;

// 그 아래 어디서든
const toast = useToast();
toast.add({ color: 'success', title: '배포 완료', description: 'production · 4분 02초' });
```

Toast는 컴포넌트가 아니라 hook으로 띄웁니다. 겉모습은 `ToastProvider`에서 한 번 정하고, 호출부에서는 내용만 넘깁니다.

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

// 앱 전체를 한 번 감쌉니다
NebaToastProvider(position: NebaToastPosition.bottomEnd, child: app);

// 그 아래 어디서든
NebaToastProvider.of(context).add(
  const NebaToastOptions(
    color: NebaColor.success,
    title: Text('배포 완료'),
    description: Text('production · 4분 02초'),
  ),
);
```

Toast는 위젯으로 그리지 않고 `NebaToastProvider.of(context)`로 띄웁니다. 겉모습은 `NebaToastProvider`에서 한 번 정하고, 호출부에서는 내용만 넘깁니다.

:::

## Props

### <Fw react="ToastProvider" flutter="NebaToastProvider" />

<PropsTable name="ToastProvider" />

::: fw flutter

스택은 [Popover](../surfaces/popover)의 popup처럼 앱의 root `Overlay`에 그려지고, 가장 새 Toast보다 먼저 열린 것들 위에 놓입니다. 위에 `Overlay`가 없는 provider는 직접 하나를 만들기 때문에, `WidgetsApp.builder`에서 navigator를 감싸 모든 route에 Toast를 띄울 수 있습니다.

```dart
WidgetsApp(
  builder: (BuildContext context, Widget? child) => NebaToastProvider(child: child!),
  // …
);
```

스택은 safe area를 피하고, 아래쪽에 놓이면 키보드에도 가리지 않습니다. Toast가 테마를 따르도록 provider는 `NebaProvider` 안에 두세요.

:::

### <Fw react="useToast().add(options)" flutter="NebaToastOptions" />

<PropsTable name="useToast().add" />

::: fw react

hook은 `add` 외에 `close(id?)`, `update(id, options)`, `promise(promise, { loading, success, error })`, `toasts`를 함께 돌려줍니다. 네 메서드는 컴포넌트가 살아 있는 동안 identity가 바뀌지 않지만, 이들을 담은 객체는 `toasts`가 바뀔 때마다 새로 만들어집니다. 그래서 effect의 deps에는 객체가 아니라 메서드를 넣습니다. `[toast]`가 아니라 `[add]`입니다.

:::

::: fw flutter

`NebaToastProvider.of(context)`는 `add(options)`, `close([id])`, `update(id, options)`, `promise(future, loading:, success:, error:)`, `toasts`를 가진 `NebaToastActions`를 돌려줍니다. provider가 살아 있는 동안 같은 객체이고, `of`는 위젯을 아무것에도 의존하게 만들지 않습니다. 그래서 `initState`에서도, build 안에서도, 누름 처리에서도 부를 수 있고, Toast를 띄우기만 하는 위젯은 Toast가 뜬다고 다시 빌드되지 않습니다. `toasts`는 닫히지 않은 Toast를 최신순으로 담은 `ValueListenable`이며, 목록을 보여 주는 위젯은 이것을 구독합니다.

:::

::: fw react

### useToastActions()

`useToast`와 같은 네 메서드를 `toasts` 없이 돌려줍니다. `toasts`는 구독이라서, `useToast`를 부르는 컴포넌트는 페이지 어디서든 토스트가 추가되거나 바뀌거나 닫힐 때마다 다시 렌더링됩니다. 토스트를 띄우기만 하는 컴포넌트에는 `useToastActions`를 쓰세요. 이 hook은 그 때문에 컴포넌트를 다시 렌더링하지 않습니다.

```tsx
const { add } = useToastActions();
```

:::

## 예시

### position

::: fw react

스택이 붙을 자리입니다. 세로 방향(`top`/`bottom`)과 [`NebaAlign`](../../design/prop-conventions)을 조합한 한 단어로 지정합니다.

:::

::: fw flutter

스택이 붙을 자리입니다. 세로 가장자리와 그 위의 위치를 조합한 `NebaToastPosition` 하나로 지정하며, `topStart`부터 `bottomEnd`까지 있습니다. `start`와 `end`는 읽는 방향을 따릅니다.

:::

<Demo src="toast/positions" minHeight="320">

::: fw react

<<< @/.vitepress/demos/toast/positions.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toast/positions.dart

:::

</Demo>

### timeout · actionLabel · onAction

`timeout`은 자동으로 닫히기까지의 시간입니다. 사용자가 조치를 취해야 하는 Toast에는 <Fw react="`timeout: 0`을" flutter="`timeout: Duration.zero`를" /> 주어 자동으로 닫히지 않게 하세요. `actionLabel`과 `onAction`은 Toast 안에 버튼 하나를 붙입니다.

`limit`을 넘은 Toast는 보이지 않는 곳에서 기다리는데, 기다리는 동안에도 타이머가 흐르므로 `timeout`보다 오래 기다린 Toast는 한 번도 보이지 않고 닫힙니다. 꼭 보여야 하는 Toast에는 <Fw react="`timeout: 0`을" flutter="`timeout: Duration.zero`를" /> 주거나 `limit`을 늘리세요.

<Demo src="toast/action" minHeight="280">

::: fw react

<<< @/.vitepress/demos/toast/action.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/toast/action.dart

:::

</Demo>

### update와 promise

`add`가 돌려준 `id`로 `update`를 부르면 그 Toast를 제자리에서 갱신합니다. 타이머는 그대로 흐르고, 같은 `id`로 `add`를 다시 불러야 처음부터 다시 셉니다. "업로드 중 → 업로드 완료"처럼 하나의 Toast가 상태를 바꾸는 경우에 씁니다.

::: fw react

```tsx
const toast = useToast();

const id = toast.add({
  title: '삭제됨',
  timeout: 0,
  actionLabel: '실행 취소',
  onAction: () => restore(id)
});
toast.update(id, { color: 'success', title: '복구됨' });
```

:::

::: fw flutter

```dart
final NebaToastActions toast = NebaToastProvider.of(context);

late final String id;
id = toast.add(
  NebaToastOptions(
    title: const Text('삭제됨'),
    timeout: Duration.zero,
    actionLabel: const Text('실행 취소'),
    onAction: () => restore(id),
  ),
);
toast.update(id, const NebaToastOptions(color: NebaColor.success, title: Text('복구됨')));
```

:::

`promise`는 같은 흐름을 <Fw react="Promise" flutter="Future" code /> 하나로 처리합니다. 대기 · 성공 · 실패 메시지를 넘기면 Toast 하나가 상태에 따라 바뀝니다.

::: fw flutter

`success`와 `error`는 각각 결과 값과 오류를 받는 함수라서, 돌아온 내용을 메시지에 담을 수 있습니다. 돌려받는 `Future`는 넘긴 `Future`와 똑같이 끝나며, 오류도 그대로 전합니다.

:::

### classNames

::: fw react

ToastProvider는 자기 요소를 그리지 않습니다. app을 감싸고 portal된 스택을 페이지에 놓을 뿐이라, 여기에는 `className`이 없고 그것이 붙을 `root` slot도 없습니다. 대신 스택의 각 파트에 이름이 있습니다.

```tsx
<ToastProvider classNames={{ viewport: 'p-8', toast: 'font-mono' }}>
  <App />
</ToastProvider>
```

slot은 `viewport`, `toast`, `title`, `description`, `action`, `close`입니다. `viewport`는 toast가 쌓이는 띠이고 `toast`는 그중 하나로, 스택의 모든 toast에 적용됩니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

:::

::: fw flutter

class 이름은 없습니다. 제목, 설명, 액션 라벨은 위젯이라 각자 스타일을 받고, 시트와 ×와 스택의 띠는 provider가 정합니다.

:::

## 접근성

::: fw react

- live region으로 전달되므로 갑자기 나타난 메시지도 screen reader에 읽힙니다.
- Toast는 스스로 사라지므로 독자가 놓칠 수 있습니다. 1분 뒤에도 여전히 유효한 메시지는 페이지에 남는 [Alert](./alert)로 쓰세요.
- `priority: 'high'`는 screen reader가 읽던 내용을 끊고, 기본값은 끊기지 않고 기다립니다.
- 타이머는 hover 중이거나 창이 비활성일 때 멈춥니다. F6으로 스택에 focus를 옮길 수 있습니다.
- 닫기 버튼은 스택이 hover되거나 focus를 받기 전까지 접근성 트리에서 빠져 있어, Toast가 "메시지 + 버튼"이 아니라 하나의 메시지로 읽힙니다.

:::

::: fw flutter

- Toast마다 제목과 설명이 live region이고 액션과 ×는 그 바깥에 있어서, Toast는 하나의 메시지로 읽히고 버튼은 그대로 닿을 수 있습니다. 웹에서 Toast는 쉬는 틈을 기다리는 `SemanticsRole.status`이고, `priority: NebaToastPriority.high`를 주면 읽던 내용을 끊는 `SemanticsRole.alert`가 됩니다. Android와 iOS에는 두 role이 없습니다. 그곳에서 Toast는 나타날 때 읽히는 live region이며, 두 priority가 같은 방식으로 읽힙니다.
- Toast는 스스로 사라지므로 독자가 놓칠 수 있습니다. 1분 뒤에도 여전히 유효한 메시지는 페이지에 남는 [Alert](./alert)로 쓰세요.
- 타이머는 마우스가 스택 위에 있는 동안, 키보드 focus가 스택 안에 있는 동안, 손가락이 Toast에 닿은 뒤 다른 곳에 닿기 전까지, 앱이 활성 창이 아닌 동안 멈춥니다.
- 스택은 `label`로 이름 붙은 region입니다. F6을 누르면 가장 새 Toast로 focus가 옮겨지고, 각 Toast는 자기 ring을 가진 focus 지점입니다. Esc는 focus를 가진 Toast를 닫으며, focus는 다음 Toast로, 없으면 F6을 누르기 전 자리로 돌아갑니다.
- ×는 옆 글자 크기로 그려지지만, 누를 수 있는 영역은 둘레의 여백까지 사방 24픽셀로 넓어집니다.

:::

- 모든 toast의 × 이름은 provider의 `locale`이 정합니다. `closeLabel`로 직접 쓸 수도 있습니다.

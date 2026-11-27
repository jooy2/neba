---
title: Confirm
order: 11
flutter: true
---

# Confirm

<p class="neba-lede">dialog로 묻고, 다른 답과 똑같이 기다리는 질문입니다. provider가 건네는 함수는 사용자가 누른 것으로 답을 돌려주므로, 묻는 코드가 곧 행동하는 코드입니다.</p>

<Demo src="confirm/hero" frameMinHeight="300" />

::: fw react

```tsx
import { ConfirmProvider, useConfirm } from 'neba';

<ConfirmProvider>
  <App />
</ConfirmProvider>;

// 그 아래 어디서든
const confirm = useConfirm();

if (await confirm({ title: '프로젝트를 삭제할까요?', color: 'danger' })) {
  remove();
}
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaConfirmProvider(child: app);

// 그 아래 어디서든
final NebaConfirm confirm = NebaConfirmProvider.of(context);

if (await confirm(
  const NebaConfirmOptions(title: Text('프로젝트를 삭제할까요?'), color: NebaColor.danger),
)) {
  remove();
}
```

:::

## Props

<PropsTable name="ConfirmProvider" />

### 옵션

<PropsTable name="ConfirmOptions" />

::: fw react

`confirm('프로젝트를 삭제할까요?')`는 `confirm({ title: '프로젝트를 삭제할까요?' })`의 축약형입니다.

:::

::: fw flutter

`NebaConfirmProvider.of(context)`는 React 패키지의 `useConfirm()`에 해당합니다. 함수처럼 호출하는 `NebaConfirm`을 돌려주며, provider가 있는 동안 늘 같은 객체이므로 `initState`나 누름 핸들러에서 받아 두고 계속 써도 됩니다. 위젯을 provider에 의존시키지 않으므로 질문해도 묻는 위젯이 다시 빌드되지 않습니다. provider가 없는 곳에서 `maybeOf`는 `null`을 돌려줍니다.

질문은 언제나 `NebaConfirmOptions`입니다. Dart에는 문자열과 객체를 합친 타입이 없으므로 문자열 축약형이 없고, 제목과 라벨은 보통 `Text`인 위젯입니다. dialog는 provider 위의 root `Overlay`에 열리고, 위에 overlay가 없으면 provider가 직접 하나를 두므로 `WidgetsApp.builder`에서 navigator를 감쌀 수 있습니다.

:::

## 예시

### 반환값

<Fw react="`confirm()`은" flutter="`confirm()`이 돌려주는 future는" /> 사용자가 확인하면 `true`로, 취소하거나 `Escape`를 누르거나 <Fw react="backdrop을 클릭하면" flutter="시트 바깥을 누르면" /> `false`로 <Fw react="resolve합니다. reject하지 않습니다" flutter="완료됩니다. 오류로 완료되는 일은 없습니다" />.

<Fw react="`ConfirmProvider`가 unmount되면" flutter="`NebaConfirmProvider`가 트리에서 빠지면" /> 시트에 떠 있거나 그 뒤에서 기다리던 질문은 모두 `false`로 답해지고, 그 뒤에 부른 `confirm()`도 `false`로 답해집니다.

### color와 파괴적인 질문

confirm의 대부분은 무언가를 없애는 일에 관한 것입니다. <Fw react="`color: 'danger'`가" flutter="`color: NebaColor.danger`가" /> 확인 버튼과 시트의 강조색을 함께 넘깁니다.

::: fw react

```tsx
await confirm({
  title: '파일 12개를 삭제할까요?',
  description: '휴지통으로 옮겨지고 30일 뒤에 완전히 삭제됩니다.',
  confirmLabel: '휴지통으로',
  color: 'danger'
});
```

:::

::: fw flutter

```dart
await confirm(
  const NebaConfirmOptions(
    title: Text('파일 12개를 삭제할까요?'),
    description: Text('휴지통으로 옮겨지고 30일 뒤에 완전히 삭제됩니다.'),
    confirmLabel: Text('휴지통으로'),
    color: NebaColor.danger,
  ),
);
```

:::

### alert

`alert`는 취소 버튼을 없애고 나가는 길을 하나만 남기므로, 묻는 대신 알릴 때 씁니다. 그래도 답을 돌려주며 `Escape`나 <Fw react="backdrop으로" flutter="바깥 누름으로" /> 닫아도 값은 항상 `true`이므로, 같은 `await`를 양쪽에 그대로 쓸 수 있습니다.

::: fw react

```tsx
await confirm({ title: '내보내기가 준비되었습니다.', alert: true });
```

:::

::: fw flutter

```dart
await confirm(const NebaConfirmOptions(title: Text('내보내기가 준비되었습니다.'), alert: true));
```

:::

### dismissible

`false`면 버튼으로만 답할 수 있는 질문이 되고, `Escape`와 <Fw react="backdrop으로는" flutter="바깥 누름으로는" /> 시트가 닫히지 않습니다. 실수로 닫는 것이 비싼 답이 되는 경우에만 쓰세요.

### defaults

<Fw react="`ConfirmProvider`는" flutter="`NebaConfirmProvider`는" /> 그 아래 모든 질문이 공유하는 설정을 받고, 각 호출이 그것을 덮어씁니다.

::: fw react

```tsx
<ConfirmProvider defaults={{ size: 'md', locale: 'ko' }}>
```

:::

::: fw flutter

```dart
NebaConfirmProvider(
  defaults: const NebaConfirmOptions(size: NebaSize.md, locale: Locale('ko')),
  child: app,
);
```

:::

### 질문 대기열

첫 번째 질문이 떠 있는 동안 두 번째를 올리면 그 뒤에 줄을 섭니다. 사용자를 대신해 답하는 일은 없으므로, provider가 <Fw react="mount되어 있는" flutter="트리에 있는" /> 동안 각 <Fw react="promise는" flutter="future는" /> 사용자가 그 질문에 답해야 완료됩니다. <Fw flutter="위젯의 `initState`처럼 화면을 빌드하는 도중에 올린 질문은 그 프레임이 끝난 뒤에 열립니다." />

## 접근성

- [Dialog](./dialog)를 그리므로 Dialog의 기능이 전부 여기에도 있습니다. 안에 붙잡히는 focus, <Fw react="스크롤 잠금과 뒤쪽 페이지의 inert 처리" flutter="누름을 받지 않는 뒤쪽 페이지" />, 그리고 질문을 띄운 곳으로 돌아가는 focus입니다.
- 시트는 <Fw react="`alertdialog`입니다" flutter="alert dialog, `SemanticsRole.alertDialog`입니다" />. 다른 일을 하기 전에 답해야 하는 질문이기 때문입니다.
- 시트가 열리면 확인 버튼이 focus를 받으므로 `Enter`가 예, `Escape`가 아니오입니다. `danger` 질문은 취소 버튼에서 열리므로, 질문을 띄운 `Enter` 다음의 `Enter`가 삭제로 이어지지 않습니다.
- 앞의 질문에 이어 시트를 넘겨받은 질문은 새 시트로 열리므로, focus가 그 질문의 답으로 옮겨 가고 제목도 새로 읽힙니다.
- 대기열의 마지막 질문에 답하면 focus는 첫 질문을 띄울 때 focus를 쥐고 있던 <Fw react="요소로" flutter="곳으로" /> 돌아갑니다.
- `title`이 dialog의 <Fw react="accessible name이 되고 `description`이 `aria-describedby`가 됩니다" flutter="이름이 되고 `description`은 그 다음에 읽힙니다" />. 둘 다 없는 질문은 스크린 리더가 아무것도 읽어 주지 않는 dialog입니다. 최소한 `title`은 항상 넘기세요.

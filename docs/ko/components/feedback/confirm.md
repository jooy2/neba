---
title: Confirm
order: 11
---

# Confirm

<p class="neba-lede">dialog로 묻고, 다른 답과 똑같이 기다리는 질문입니다. <code>useConfirm()</code>이 돌려주는 함수는 사용자가 누른 것으로 resolve되므로, 묻는 코드가 곧 행동하는 코드입니다.</p>

<Demo src="confirm/hero" />

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

## Props

<PropsTable name="ConfirmProvider" />

### 옵션

<PropsTable name="ConfirmOptions" />

`confirm('프로젝트를 삭제할까요?')`는 `confirm({ title: '프로젝트를 삭제할까요?' })`의 축약형입니다.

## 예시

### 반환값

`confirm()`은 사용자가 확인하면 `true`로, 취소하거나 `Escape`를 누르거나 backdrop을 클릭하면 `false`로 resolve합니다. reject하지 않습니다.

### color와 파괴적인 질문

confirm의 대부분은 무언가를 없애는 일에 관한 것입니다. `color: 'danger'`가 확인 버튼과 시트의 강조색을 함께 넘깁니다.

```tsx
await confirm({
  title: '파일 12개를 삭제할까요?',
  description: '휴지통으로 옮겨지고 30일 뒤에 완전히 삭제됩니다.',
  confirmLabel: '휴지통으로',
  color: 'danger'
});
```

### alert

`alert`는 취소 버튼을 없애고 나가는 길을 하나만 남기므로, 묻는 대신 알릴 때 씁니다. 그래도 resolve하며 `Escape`나 backdrop으로 닫아도 값은 항상 `true`이므로, 같은 `await`를 양쪽에 그대로 쓸 수 있습니다.

```tsx
await confirm({ title: '내보내기가 준비되었습니다.', alert: true });
```

### dismissible

`false`면 버튼으로만 답할 수 있는 질문이 되고, `Escape`와 backdrop으로는 시트가 닫히지 않습니다. 실수로 닫는 것이 비싼 답이 되는 경우에만 쓰세요.

### defaults

`ConfirmProvider`는 그 아래 모든 질문이 공유하는 설정을 받고, 각 호출이 그것을 덮어씁니다.

```tsx
<ConfirmProvider defaults={{ size: 'md', locale: 'ko' }}>
```

### 질문 대기열

첫 번째 질문이 떠 있는 동안 두 번째를 올리면 그 뒤에 줄을 섭니다. 사용자를 대신해 답하는 일은 없으므로, 각 promise는 사용자가 그 질문에 답해야 resolve합니다.

## 접근성

- [Dialog](./dialog)를 그리므로 Dialog의 기능이 전부 여기에도 있습니다. focus trap과 스크롤 잠금, 뒤쪽 페이지의 inert 처리, 그리고 질문을 띄운 곳으로 돌아가는 focus입니다.
- 시트는 `role="alertdialog"`입니다. 다른 일을 하기 전에 답해야 하는 질문이기 때문입니다.
- 시트가 열리면 확인 버튼이 focus를 받으므로 `Enter`가 예, `Escape`가 아니오입니다. `danger` 질문은 취소 버튼에서 열리므로, 질문을 띄운 `Enter` 다음의 `Enter`가 삭제로 이어지지 않습니다.
- 대기열의 마지막 질문에 답하면 focus는 첫 질문을 띄울 때 focus를 쥐고 있던 요소로 돌아갑니다.
- `title`이 dialog의 accessible name이 되고 `description`이 `aria-describedby`가 됩니다. 둘 다 없는 질문은 스크린 리더가 아무것도 읽어 주지 않는 dialog입니다. 최소한 `title`은 항상 넘기세요.

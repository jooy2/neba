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

## 반환되는 promise

"정말 하시겠습니까?"는 가장 흔한 dialog이고, 손으로 쓰면 질문마다 state 하나, dialog가 열릴 때 무엇을 지우려던 것이었는지 담을 `useState` 하나, 그리고 그것을 옮겨 주는 콜백 하나가 필요합니다. `onConfirm`은 하나의 결정을 두 함수로 쪼갭니다. `await`는 결정을 내린 자리에 그대로 둡니다.

reject하지 않습니다. **아니오**로 답한 질문은 실패가 아니라 답이고, 그것으로 throw하는 promise는 모든 호출 지점을 `try`로 만듭니다.

취소 · `Escape` · backdrop 클릭은 모두 `false`로 resolve합니다. 셋 다 취소 버튼을 다른 경로로 누른 것이므로, promise를 영원히 대기시키지 않고 같은 답을 냅니다.

## 예시

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

취소 버튼을 없애고 나가는 길을 하나만 남깁니다. 묻는 것이 아니라 알리는 경우입니다. 그래도 resolve하며 값은 항상 `true`이므로 같은 `await`가 양쪽에 그대로 쓰입니다.

```tsx
await confirm({ title: '내보내기가 준비되었습니다.', alert: true });
```

### dismissible

`false`면 버튼으로만 답할 수 있는 질문이 됩니다. `Escape`와 backdrop이 동작하지 않습니다. 실수로 닫는 것이 비싼 답이 되는 경우에만 쓰고, 그 밖에는 거의 쓰지 마세요. 나갈 길이 없는 모달은 사람들이 제보하는 바로 그것입니다.

### defaults

`ConfirmProvider`는 그 아래 모든 질문이 공유하는 설정을 받고, 각 호출이 그것을 덮어씁니다.

```tsx
<ConfirmProvider defaults={{ size: 'md', locale: 'ko' }}>
```

### 두 개가 동시에

**질문은 큐에 쌓입니다.** 첫 번째가 떠 있는 동안 두 번째를 올리면 뒤에 줄을 섭니다. 사용자를 대신해 답해 버리는 일은 없습니다.

이 동작은 보이는 것보다 중요합니다. 자리를 만들려고 앞선 질문을 `false`로 resolve하면 아무도 하지 않은 답을 보고하는 셈이고, 호출 지점에서 `false`는 "아니오라고 했다"로 읽힙니다. 화면에 뜬 적도 없는 질문에 대해 취소 분기를 타게 됩니다.

## 접근성

- [Dialog](./dialog)를 그리므로 Dialog의 기능이 전부 여기에도 있습니다. focus trap과 스크롤 잠금, 뒤쪽 페이지의 inert 처리, 그리고 질문을 띄운 곳으로 돌아가는 focus입니다.
- 시트가 열리면 확인 버튼이 focus를 받으므로 `Enter`가 예, `Escape`가 아니오입니다.
- `title`이 dialog의 accessible name이 되고 `description`이 `aria-describedby`가 됩니다. 둘 다 없는 질문은 스크린 리더가 아무것도 읽어 주지 않는 dialog입니다. 최소한 `title`은 항상 넘기세요.

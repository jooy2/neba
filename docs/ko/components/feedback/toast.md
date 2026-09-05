---
title: Toast
order: 3
---

# Toast

<p class="neba-lede">화면 한쪽에 잠깐 떠올랐다 사라지는 알림입니다. 사용자의 흐름을 끊지 않고 작업 결과를 전달할 때 씁니다.</p>

<Demo src="toast/hero" align="center" />

```tsx
import { ToastProvider, useToast } from 'neba';

// 앱 전체를 한 번 감쌉니다
<ToastProvider position="bottom-end">{children}</ToastProvider>;

// 그 아래 어디서든
const toast = useToast();
toast.add({ color: 'success', title: '배포 완료', description: 'production · 4분 02초' });
```

Toast는 컴포넌트가 아니라 hook으로 띄웁니다. 겉모습은 `ToastProvider`에서 한 번 정하고, 호출부에서는 내용만 넘깁니다.

## Props

### ToastProvider

<PropsTable name="ToastProvider" />

### useToast().add(options)

<PropsTable name="useToast().add" />

hook은 `add` 외에 `close(id?)`, `update(id, options)`, `promise(promise, { loading, success, error })`, `toasts`를 함께 돌려줍니다.

## 예시

### position

스택이 붙을 자리입니다. 세로 방향(`top`/`bottom`)과 [`NebaAlign`](../../design/prop-conventions)을 조합한 한 단어로 지정합니다.

<Demo src="toast/positions">

<<< @/.vitepress/demos/toast/positions.tsx

</Demo>

### timeout · actionLabel · onAction

`timeout`은 자동으로 닫히기까지의 시간입니다. 사용자가 조치를 취해야 하는 Toast에는 `timeout: 0`을 주어 자동으로 닫히지 않게 하세요. `actionLabel`과 `onAction`은 Toast 안에 버튼 하나를 붙입니다.

<Demo src="toast/action">

<<< @/.vitepress/demos/toast/action.tsx

</Demo>

### update와 promise

`add`가 돌려준 `id`로 `update`를 부르면 그 Toast를 제자리에서 갱신하고 타이머를 다시 시작합니다. "업로드 중 → 업로드 완료"처럼 하나의 Toast가 상태를 바꾸는 경우에 씁니다.

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

`promise`는 같은 흐름을 Promise 하나로 처리합니다. 대기 · 성공 · 실패 메시지를 넘기면 Toast 하나가 상태에 따라 바뀝니다.

### classNames

ToastProvider는 자기 요소를 그리지 않습니다. app을 감싸고 portal된 스택을 페이지에 놓을 뿐이라, 여기에는 `className`이 없고 그것이 붙을 `root` slot도 없습니다. 대신 스택의 각 파트에 이름이 있습니다.

```tsx
<ToastProvider classNames={{ viewport: 'p-8', toast: 'font-mono' }}>
  <App />
</ToastProvider>
```

slot은 `viewport`, `toast`, `title`, `description`, `action`, `close`입니다. `viewport`는 toast가 쌓이는 띠이고 `toast`는 그중 하나로, 스택의 모든 toast에 적용됩니다. 넘긴 class가 컴포넌트 자신의 class와 어떻게 겨루는지는 [prop 규약](../../design/prop-conventions)을 보세요.

## Toast와 Alert 중 무엇을 쓸지

[Alert](./alert)는 해당 페이지에 속하며 그 자리에 남습니다. Toast는 방금 일어난 일을 알리고 사라집니다. 1분 뒤에도 여전히 유효한 메시지라면 Alert를 쓰세요.

## 접근성

- live region으로 전달되므로 갑자기 나타난 메시지도 screen reader에 읽힙니다.
- `priority: 'high'`는 screen reader가 읽던 내용을 끊고, 기본값은 끊기지 않고 기다립니다.
- 타이머는 hover 중이거나 창이 비활성일 때 멈춥니다. F6으로 스택에 focus를 옮길 수 있습니다.
- 닫기 버튼은 스택이 hover되거나 focus를 받기 전까지 접근성 트리에서 빠져 있어, Toast가 "메시지 + 버튼"이 아니라 하나의 메시지로 읽힙니다.
- 모든 toast의 × 이름은 provider의 `locale`이 정합니다. `closeLabel`로 직접 쓸 수도 있습니다.

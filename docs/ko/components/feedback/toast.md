---
title: Toast
order: 3
---

# Toast

<p class="neba-lede">스스로 도착해서, 이미 화면에 있는 것 위에 뜨는 메시지.</p>

<Demo src="toast/hero" align="center" />

```tsx
import { ToastProvider, useToast } from 'neba';

// 앱 전체를 한 번 감쌉니다
<ToastProvider position="bottom-end">{children}</ToastProvider>;

// 그 아래 어디서든
const toast = useToast();
toast.add({ color: 'success', title: '배포 완료', description: 'production · 4분 02초' });
```

## ToastProvider

<PropsTable name="ToastProvider" />

## useToast().add(options)

<PropsTable name="useToast().add" />

`add` 외에 `close(id?)`, `update(id, options)`, `promise(promise, { loading, success, error })`, `toasts`를 함께 돌려줍니다.

## 예시

### 스택이 놓이는 자리

`position`이 `side`와 `align`의 조합이 아니라 두 단어인 이유는, 이 둘이 서로 독립적이지 않기 때문입니다. 토스트 스택은 위나 아래에 붙지 옆에 붙지 않습니다. 뒷부분은 [`NebaAlign`](../../guide/prop-conventions), 다른 모든 컴포넌트가 쓰는 그 단어입니다.

<Demo src="toast/positions">

<<< @/.vitepress/demos/toast/positions.tsx

</Demo>

### 액션, 그리고 promise 따라가기

읽고 나서 조치가 필요한 토스트는 읽히기 전에 사라지면 안 되므로 `timeout: 0`을 주세요. `promise`는 같은 생각의 나머지 절반입니다. 세 개가 쌓이는 대신 하나가 마음을 바꿉니다.

<Demo src="toast/action">

<<< @/.vitepress/demos/toast/action.tsx

</Demo>

## 컴포넌트가 아니라 훅입니다

토스트가 필요해지는 순간 호출자가 손에 쥐고 있는 것은 클릭 핸들러지 트리 안의 자리가 아닙니다. 계속 마운트해 둬야 하는 `<Toast open={…}/>`, 그리고 메시지마다 하나씩 생기는 상태 — 이 컴포넌트는 바로 그 모양을 피하려고 존재합니다.

토스트가 **어떻게 보일지**는 provider에서 한 번에 정합니다. 스택의 자리, 너비, 표면, 유지 시간. 호출부에는 마땅히 남아야 할 것 하나만 남습니다 — 무슨 일이 일어났는지.

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

같은 `id`로 다시 부르면 그 토스트를 제자리에서 갱신하고 타이머를 다시 시작합니다. "업로드 중… / 업로드 완료"가 원하는 동작입니다.

## Toast인가 Alert인가?

[Alert](./alert)는 그 일이 벌어진 페이지에 속하고 그 자리에 남습니다. 토스트는 방금 다른 곳에서 일어난 일에 대한 것이고, 떠납니다. 1분 뒤에도 여전히 참인 메시지라면 그것은 Alert입니다.

## 접근성

잘 동작할 때 보이지 않는 부분은 전부 Base UI가 가집니다. 난데없이 나타난 메시지를 스크린 리더에 닿게 하는 live region, 호버와 창 비활성화에서 멈추는 타이머, 개수 제한, 스와이프, 스택으로 포커스를 옮기는 F6까지.

`priority: 'high'`는 스크린 리더의 말을 끊고, 기본값은 말이 끊길 때까지 기다립니다. 오류는 끊을 만하고 저장 완료는 그렇지 않습니다.

×는 스택이 호버되거나 포커스를 받기 전까지 일부러 접근성 트리에서 빠져 있습니다. 토스트가 "메시지 + 버튼"이 아니라 하나의 메시지로 읽히게 하기 위해서입니다.

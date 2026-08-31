---
title: Portal
order: 9
---

# Portal

<p class="neba-lede">children을 DOM의 다른 곳 — 보통 <code>&lt;body&gt;</code>의 끝 — 에 그립니다. 제자리에 있으면 갇히게 될 clipping이나 stacking context를 빠져나가야 하는 subtree를 위한 것입니다.</p>

<Demo src="portal/hero" />

```tsx
import { Portal } from 'neba';

<Portal>
  <div className="fixed inset-x-0 top-0 z-50">공지</div>
</Portal>;
```

## Props

<PropsTable name="Portal" />

`<div>`의 native 속성은 wrapper로 전달됩니다.

### `createPortal`을 직접 쓰지 않는 이유

두 가지를 더합니다. 첫 번째가 이걸 쓰는 이유입니다.

wrapper가 **`neba-portal`**을 답니다. portal된 subtree는 페이지가 스타일을 scope해 둔 element를 벗어나므로 scoped stylesheet가 그것을 놓칩니다. 이 class가 다시 찾는 방법입니다. 이 라이브러리의 팝업들도 이미 이 class를 달고 있고, 이 문서 사이트도 `.neba-scope` 바깥에 reset을 다시 적용하는 데 씁니다.

두 번째는 서버입니다. 서버에는 `document`가 없으므로 portal은 마운트되기 전까지 아무것도 그리지 않고, 배포되는 마크업에 portal된 subtree는 들어 있지 않습니다. 이건 우회할 한계가 아니라 portal이 **무엇인지**의 문제입니다. 서버 HTML에 반드시 있어야 하는 것은 portal에 넣으면 안 됩니다.

## 예시

### container

children이 갈 곳입니다. 기본값은 `document.body`.

함수를 넘기면 마운트 이후에 호출됩니다. React가 직접 그리는 것을 대상으로 삼는 방법입니다 — `() => document.getElementById('drawer')`는 props를 만들던 시점에는 없던 element를 찾습니다.

```tsx
<Portal container={() => document.getElementById('overlay-root')}>{children}</Portal>
```

### disabled

portal 대신 제자리에 그립니다 — 이미 portal 안에 있는 subtree, 마크업이 쓰인 자리에 그대로 있기를 바라는 테스트, 닿을 만한 `document.body`가 없는 임베드를 위한 것입니다.

**마운트 시점에 한 번만 정하세요.** React에게 portal된 subtree와 제자리의 subtree는 서로 다른 child이므로, 이 값을 뒤집으면 안의 모든 것이 remount되고 그 안에 있던 것 — 반쯤 채운 폼, 스크롤 위치, 재생 중이던 영상 — 이 사라집니다. 이 컴포넌트가 우회할 수 있는 것이 아니라 React의 reconciliation입니다.

## 접근성

- portal은 DOM을 옮기지만, 스크린 리더가 읽는 순서는 그 DOM 자체입니다. 무언가와 **함께** 속하는 내용이라면 `aria-controls` · `aria-describedby`나 focus 이동으로 그렇다고 말해야 합니다.
- focus는 children을 따라가지 않습니다. portal된 dialog는 자기 focus 관리가 필요하니 이미 그것을 갖춘 [Dialog](../feedback/dialog)나 [Drawer](../surfaces/card)를 쓰세요.
- `Escape`와 바깥 클릭도 여기서 처리하지 않습니다. 이것은 배치일 뿐 그 이상이 아닙니다.

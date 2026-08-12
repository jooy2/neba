---
title: Dialog
order: 2
---

# Dialog

<p class="neba-lede">답할 때까지 페이지를 가리는 modal sheet입니다. 확인이 필요한 작업이나 흐름을 끊고 처리해야 하는 입력에 씁니다.</p>

<Demo src="dialog/hero" align="center" />

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

## Props

<PropsTable name="Dialog" />

`<div>`의 native 속성은 popup으로 전달됩니다. `color` · `title` · `children`만 위 표와 이름이 겹쳐 제외됩니다.

`variant`와 `elevation`은 없습니다. modal은 항상 3단계 그림자를 답니다.

## 예시

### size와 width

`size`는 타입 스케일과 여백은 물론 sheet의 최대 너비까지 함께 정합니다. 작은 글씨로 넓은 표나 diff를 보여 줘야 하는 경우처럼 그 조합에서 벗어나야 할 때는 `width`에 길이를 직접 지정하세요.

<Demo src="dialog/sizes">

<<< @/.vitepress/demos/dialog/sizes.tsx

</Demo>

### dividers

본문이 길면 본문만 스크롤되고 제목과 액션은 제자리에 남습니다. `dividers`는 그 경계에 선을 그어, 헤더가 함께 스크롤되지 않았음을 보여 줍니다.

<Demo src="dialog/scrolling">

<<< @/.vitepress/demos/dialog/scrolling.tsx

</Demo>

### dismissible

`dismissible={false}`는 Esc와 바깥 클릭을 함께 막습니다. `actions`에 답할 수 있는 버튼이 있을 때만 끄세요 — 그 외에는 나갈 방법이 없습니다.

<Demo src="dialog/controlled">

<<< @/.vitepress/demos/dialog/controlled.tsx

</Demo>

### DialogClose

`open` 상태를 직접 들지 않고도 버튼으로 Dialog를 닫을 수 있습니다. `render`로 원하는 컨트롤을 넣으세요.

```tsx
actions={
  <>
    <DialogClose render={<Button variant="text" color="secondary">취소</Button>} />
    <DialogClose render={<Button color="danger">삭제</Button>} />
  </>
}
```

## 접근성

- `title`과 `description`은 각각 `aria-labelledby`, `aria-describedby`로 연결됩니다. `title`은 실제 `<h2>`로 렌더링됩니다.
- focus trap, scroll lock, 뒤 페이지 inert 처리, 닫을 때 trigger로 focus 복귀가 모두 적용됩니다.
- `showClose`는 기본값이 켜짐입니다. modal에서 나가는 길은 항상 보여야 하고, 터치 screen reader가 팝업을 빠져나오는 통로이기도 합니다.
- ×의 접근성 이름은 `locale`이 정합니다. `closeLabel`로 직접 쓸 수도 있습니다.

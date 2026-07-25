---
title: Dialog
order: 2
---

# Dialog

<p class="neba-lede">답할 때까지 페이지를 가져가는 시트.</p>

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

## 예시

### size가 곧 너비입니다

<Demo src="dialog/sizes">

<<< @/.vitepress/demos/dialog/sizes.tsx

</Demo>

### 스크롤되는 본문

스크롤되는 것은 본문뿐이고 제목과 액션은 제자리에 남습니다. 여기서 `dividers`가 진짜로 하는 일이 그것입니다 — 헤더가 움직이지 않았다고 말해 주는 것이 그 하이라인입니다.

<Demo src="dialog/scrolling">

<<< @/.vitepress/demos/dialog/scrolling.tsx

</Demo>

### 반드시 답해야 하는 다이얼로그

`dismissible={false}`는 Esc와 바깥 클릭을 함께 끕니다. 답할 수 있는 액션이 있을 때만 끄세요. 그 외에는 나갈 방법이 없습니다.

<Demo src="dialog/controlled">

<<< @/.vitepress/demos/dialog/controlled.tsx

</Demo>

## 상태를 들지 않고 닫기

비제어 다이얼로그에는 Cancel 버튼이 호출할 `setOpen`이 없고, 그렇다고 모든 다이얼로그를 제어형으로 만들면 버튼 하나에 답하기 위한 상태가 다이얼로그마다 하나씩 생깁니다. `DialogClose`가 그 출구입니다. Base UI의 close 파트 그대로이므로 `render`로 진짜 Neba 버튼을 안에 넣을 수 있습니다.

```tsx
actions={
  <>
    <DialogClose render={<Button variant="text" color="secondary">취소</Button>} />
    <DialogClose render={<Button color="danger">삭제</Button>} />
  </>
}
```

## 크기 축은 하나입니다

MUI는 이것을 `size`와 `maxWidth`로 나눕니다. 여기서는 하나입니다. `size`가 타입 스케일과 여백은 물론 **시트가 넓어질 수 있는 한계까지** 정합니다. 다섯 값짜리 스케일을 하나 더 만드는 것은 이미 이름이 있는 개념에 두 번째 철자를 만드는 일입니다 — [Prop 규약](../../guide/prop-conventions)을 보세요.

다만 그 분리가 존재하는 이유 자체는 실제 상황입니다. 표나 diff를 담는, 작은 글씨에 넓은 시트. 그것이 `width`이고, 스케일이 아니라 그냥 숫자이므로 무엇과도 보조를 맞출 필요가 없습니다.

## 없는 것

`variant`가 없습니다. 세 가지 무게는 "이 표면이 주변 페이지에 대해 얼마나 자기를 주장하는가"에 답하는 축인데, 모달은 이미 페이지를 통째로 가져갔습니다.

`elevation`도 없습니다. 팝업은 라이브러리에서 **떠 있어야 마땅한** 두 표면 중 하나이므로 언제나 3단계 그림자를 답니다. 평평하게 두라고 시킬 수 있는 다이얼로그는 다이얼로그이기를 그만두라고 시킬 수 있는 다이얼로그입니다.

## 접근성

어려운 부분은 전부 Base UI가 가집니다 — 포커스 트랩, 스크롤 잠금, 뒤 페이지 비활성화, 닫을 때 트리거로 포커스 되돌리기, 그리고 `title`과 `description`을 `aria-labelledby`·`aria-describedby`로 잇는 일. 제목은 진짜 `<h2>`이므로 다이얼로그가 문서 개요에 제대로 나타납니다.

`showClose`는 이 라이브러리의 다른 불리언과 달리 기본이 켜짐입니다. 모달은 답할 때까지 페이지를 가져가고, 나가는 길은 기억해 내야 하는 것이 아니라 보여야 합니다. 터치 스크린 리더가 팝업에서 빠져나오는 통로이기도 합니다.

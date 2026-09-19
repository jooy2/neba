---
title: StreamingText
order: 8
---

# StreamingText

<p class="neba-lede">바깥에서 한 조각씩 도착하는 텍스트입니다. 첫 단어가 놓이기 전부터 높이를 잡아 두고, 도착하는 단어마다 하나씩 나타나게 하며, 스트림이 멈출 때까지 끝에 커서를 둡니다.</p>

<Demo src="streaming-text/hero" />

```tsx
import { StreamingText } from 'neba';

<StreamingText streaming={pending} lines={4}>
  {answer}
</StreamingText>;
```

## Props

<PropsTable name="StreamingText" />

`<div>`의 기본 속성은 루트로 전달됩니다. 위 표에서 다르게 정의한 `color`만 제외됩니다.

[AnimateTyping](../transitions/animate-typing)은 이미 가진 문자열을 쳐 나갑니다. 끝을 알고 있고 거기까지 가는 데 시간을 쓰는 것입니다. 이쪽은 반대 방향입니다. 문자열이 한 조각씩 넘어오고 얼마나 길어질지 아무도 모르며, 읽고 있는 사람 아래에서 페이지가 움직이지 않게 하는 것이 할 일입니다.

**`size`는 없습니다.** 이 컴포넌트가 그리는 것은 호출하는 쪽의 블록 — 말풍선, 카드, 문단 — 안에 있는 호출하는 쪽의 텍스트이고, 그 크기는 블록의 것입니다. 커서는 `em` 단위라 그 크기를 따라갑니다.

## 예시

### lines

아무것도 도착하지 않은 동안 잡아 둘 높이를 줄 수로 씁니다. 단위는 `1lh`이며, 추측한 행간이 아니라 이 블록이 실제로 가진 행간입니다.

잡아 둔 높이는 바닥값이고, 텍스트가 들어온 뒤에도 바닥값으로 남습니다. 도착과 함께 놓아 버리는 높이는 같은 흔들림을 두 번 만듭니다. 나갈 때 한 번, 돌아올 때 한 번입니다.

<Demo src="streaming-text/reserve">

<<< @/.vitepress/demos/streaming-text/reserve.tsx

</Demo>

### fade

단어마다 따로 나타나며, `opacity`만 움직입니다. 장식이 아닙니다. 블록 전체에 transition을 걸면 토큰이 하나 도착할 때마다 답 *전체*가 다시 재생됩니다.

기록해 둘 것은 없습니다. 단어는 위치로 키가 매겨지므로 이미 화면에 있는 단어는 자기 요소를 그대로 지키고 두 번 나타나지 않으며, 마지막 단어는 이미 가진 요소 안에서 한 글자씩 자랍니다. 대가는 단어마다 요소 하나이고, 아주 긴 답에서 이 기능을 끄는 이유가 됩니다.

**문자열**만 단어로 자릅니다. 그 밖의 값은 손대지 않고 그리며, 커서와 잡아 둔 높이는 그대로 둘러쌉니다.

### cursor

`streaming`인 동안 끝에 그리는 블록입니다. `false`면 그리지 않고, 노드를 주면 그것으로 바뀝니다. 도구를 기다리는 답에는 링, 점 세 개, 또는 한 단어가 될 수 있습니다.

<Demo src="streaming-text/cursor">

<<< @/.vitepress/demos/streaming-text/cursor.tsx

</Demo>

### 줄바꿈이 살아남습니다

블록은 `white-space: pre-wrap`입니다. 답이 스스로 넣은 줄바꿈이 그대로 그려집니다. 그것을 합쳐 버리면 목록이 문단이 됩니다.

## 접근성

- 스트림이 도는 동안 루트에 `aria-busy`가, 스타일링을 위해 `data-streaming`이 붙습니다.
- 일부러 live region이 **아닙니다**. 토큰 단위로 읽히는 답은 쓸 수 없고, 토큰마다 전체를 읽으면 앞부분을 계속 되풀이합니다. 다 끝난 답을 읽어 줄지는 애플리케이션의 결정입니다. 독자가 이 답을 요청했는지 아는 쪽은 애플리케이션뿐이기 때문입니다.
- 커서는 `aria-hidden`입니다.

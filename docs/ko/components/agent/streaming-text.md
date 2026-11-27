---
title: StreamingText
order: 8
flutter: true
---

# StreamingText

<p class="neba-lede">바깥에서 한 조각씩 도착하는 텍스트입니다. 첫 단어가 놓이기 전부터 높이를 잡아 두고, 도착하는 단어마다 하나씩 나타나게 하며, 스트림이 멈출 때까지 끝에 커서를 둡니다.</p>

<Demo src="streaming-text/hero" />

::: fw react

```tsx
import { StreamingText } from 'neba';

<StreamingText streaming={pending} lines={4}>
  {answer}
</StreamingText>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

NebaStreamingText(streaming: pending, lines: 4, child: Text(answer));
```

:::

## Props

<PropsTable name="StreamingText" />

::: fw react

`<div>`의 기본 속성은 루트로 전달됩니다. 위 표에서 다르게 정의한 `color`만 제외됩니다.

:::

::: fw flutter

텍스트는 `child`로 넘기는 `Text`이며, 그 스타일과 정렬, 줄바꿈 설정은 그대로 남습니다. `showCursor: false`가 React의 `cursor={false}`입니다. `render`는 없습니다. 블록이 곧 그 `Text`입니다.

:::

[AnimateTyping](../transitions/animate-typing)은 이미 가진 문자열을 쳐 나갑니다. 끝을 알고 있고 거기까지 가는 데 시간을 쓰는 것입니다. 이쪽은 반대 방향입니다. 문자열이 한 조각씩 넘어오고 얼마나 길어질지 아무도 모르며, 읽고 있는 사람 아래에서 페이지가 움직이지 않게 하는 것이 할 일입니다.

**`size`는 없습니다.** 이 컴포넌트가 그리는 것은 호출하는 쪽의 블록 — 말풍선, 카드, 문단 — 안에 있는 호출하는 쪽의 텍스트이고, 그 크기는 블록의 것입니다. 커서는 `em` 단위라 그 크기를 따라갑니다.

## 예시

### lines

::: fw react

아무것도 도착하지 않은 동안 잡아 둘 높이를 줄 수로 씁니다. 단위는 `1lh`이며, 추측한 행간이 아니라 이 블록이 실제로 가진 행간입니다.

:::

::: fw flutter

아무것도 도착하지 않은 동안 잡아 둘 높이를 줄 수로 씁니다. 추측한 행간이 아니라 텍스트 자신의 스타일로 잰 한 줄의 높이가 단위입니다.

:::

잡아 둔 높이는 바닥값이고, 텍스트가 들어온 뒤에도 바닥값으로 남습니다. 도착과 함께 놓아 버리는 높이는 같은 흔들림을 두 번 만듭니다. 나갈 때 한 번, 돌아올 때 한 번입니다.

<Demo src="streaming-text/reserve">

::: fw react

<<< @/.vitepress/demos/streaming-text/reserve.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/streaming_text/reserve.dart

:::

</Demo>

### fade

스트림으로 도착하는 단어마다 따로 나타나며, `opacity`만 움직입니다.

::: fw react

이미 화면에 있는 단어는 두 번 나타나지 않습니다. 스트림이 이어지는 동안에는 들어온 단어마다 요소가 하나씩 생기므로, 아주 긴 답에서는 `fade`를 끄세요. `streaming`이 꺼지고 마지막 단어까지 나타나면 답은 다시 단어별 요소 없이 평범한 텍스트로 그려집니다.

스트림으로 도착하지 않은 텍스트는 단어로 자르지 않고 평범한 텍스트로 한 번에 그립니다. `streaming`이 꺼진 채 처음 그린 텍스트(기록에서 불러온 메시지 등), 서버가 렌더링한 텍스트, 스트림이 시작될 때 이미 화면에 있던 텍스트가 여기에 해당합니다. `streaming`을 끄는 렌더링에 함께 도착한 단어는 앞의 단어들처럼 하나씩 나타납니다.

**문자열**만 단어로 자릅니다. 그 밖의 값은 손대지 않고 그리며, 커서와 잡아 둔 높이는 그대로 둘러쌉니다. 단어는 공백에서 자르고, 일본어·중국어·태국어처럼 띄어 쓰지 않는 문자의 구간은 `Intl.Segmenter`로 한 번 더 자릅니다. 이것이 없는 브라우저(125 이전의 Firefox)에서는 그런 구간이 한 덩어리로 나타납니다.

:::

::: fw flutter

이미 화면에 있는 단어는 두 번 나타나지 않고, 다 나타난 단어는 앞의 평범한 텍스트에 합쳐집니다. 그래서 따로 그리는 조각은 아직 도착하고 있는 단어뿐입니다.

스트림으로 도착하지 않은 텍스트는 나타나는 효과 없이 평범한 텍스트로 그립니다. `streaming`이 꺼진 채 처음 빌드한 텍스트(기록에서 불러온 메시지 등)와 스트림이 시작될 때 이미 화면에 있던 텍스트가 여기에 해당합니다. `streaming`을 끄는 빌드에 함께 도착한 단어는 앞의 단어들처럼 하나씩 나타납니다. 움직임을 줄이라는 설정에서는 모든 단어가 한 번에 놓입니다.

평범한 **`Text`**만 단어로 자릅니다. 그 밖의 위젯은 손대지 않고 그리며, 커서와 잡아 둔 높이는 그대로 둘러쌉니다. 단어는 공백에서 자르고, 일본어·중국어·태국어처럼 띄어 쓰지 않는 문자의 구간은 위젯 계층에 단어 분할기가 없으므로 한 글자씩 나타납니다.

:::

### cursor

`streaming`인 동안 끝에 그리는 블록입니다. <Fw react="false면" flutter="showCursor: false면" /> 그리지 않고, <Fw react="노드를" flutter="위젯을" /> 주면 그것으로 바뀝니다. 도구를 기다리는 답에는 링, 점 세 개, 또는 한 단어가 될 수 있습니다.

<Demo src="streaming-text/cursor">

::: fw react

<<< @/.vitepress/demos/streaming-text/cursor.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/streaming_text/cursor.dart

:::

</Demo>

### 줄바꿈

<Fw react="블록은 white-space: pre-wrap이므로" flutter="텍스트는 자기 줄바꿈을 그대로 지키므로" /> 글에 있는 줄바꿈이 그대로 그려집니다.

## 접근성

::: fw react

- 스트림이 도는 동안 루트에 `aria-busy`가, 스타일링을 위해 `data-streaming`이 붙습니다.
- 일부러 live region이 **아닙니다**. 토큰 단위로 읽히는 답은 쓸 수 없고, 토큰마다 전체를 읽으면 앞부분을 계속 되풀이합니다. 다 끝난 답을 읽어 줄지는 애플리케이션의 결정입니다. 독자가 이 답을 요청했는지 아는 쪽은 애플리케이션뿐이기 때문입니다.
- 커서는 `aria-hidden`입니다.

:::

::: fw flutter

- 일부러 live region이 **아닙니다**. 토큰 단위로 읽히는 답은 쓸 수 없고, 토큰마다 전체를 읽으면 앞부분을 계속 되풀이합니다. 다 끝난 답을 읽어 줄지는 애플리케이션의 결정입니다. 독자가 이 답을 요청했는지 아는 쪽은 애플리케이션뿐이기 때문입니다.
- 커서는 그리기만 하고 읽지 않으며, 텍스트는 몇 조각으로 그려지든 한 덩어리로 읽힙니다.

:::

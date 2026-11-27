---
title: ChatBubble
order: 8
flutter: true
---

# ChatBubble

<p class="neba-lede">대화 속 메시지 하나입니다. 아바타, 보낸 사람의 이름, 시각, 전달 표식, 텍스트 위의 미디어와 아래의 링크 카드는 각각 내용이 주어졌을 때만 그려집니다.</p>

<Demo src="chat-bubble/hero" />

::: fw react

```tsx
import { Avatar, ChatBubble } from 'neba';

<ChatBubble avatar={<Avatar name="홍길동" size="sm" />} name="길동" time="09:41">
  3시 리뷰 그대로 하나요?
</ChatBubble>

<ChatBubble side="end" variant="solid" status="read">
  네 — 방금 브랜치 올렸어요.
</ChatBubble>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaChatBubble(
  avatar: NebaAvatar(name: '홍길동', size: NebaSize.sm),
  name: Text('길동'),
  time: Text('09:41'),
  child: Text('3시 리뷰 그대로 하나요?'),
);

const NebaChatBubble(
  side: NebaChatBubbleSide.end,
  variant: NebaVariant.solid,
  status: NebaChatBubbleStatus.read,
  child: Text('네 — 방금 브랜치 올렸어요.'),
);
```

:::

## Props

<PropsTable name="ChatBubble" />

::: fw react

나머지 `<div>` 속성은 모두 줄로 전달됩니다. 예외는 `title` 하나입니다.

:::

::: fw flutter

`preview`는 `NebaChatBubbleLinkPreview`입니다. `url`은 `Uri`, `image`는 `ImageProvider`입니다. 패키지는 아무것도 직접 열지 않으므로 카드는 `onPressed`가 있을 때만 링크가 되고, router나 URL launcher는 그 안에서 부릅니다. HTML 속성인 `rel`은 없습니다. 말풍선은 512픽셀보다 넓어지지 않고, 말풍선을 담은 열은 주어진 줄의 너비를 씁니다.

:::

공통 축(`variant` `size` `color` `density` `elevation`)의 의미는 [Prop 규약](../../design/prop-conventions)에 있습니다.

## 예시

### side

기본값은 `start`로 보통 상대편 메시지가 놓이는 쪽이고, `end`는 내 메시지 쪽입니다. `end`에서는 줄이 반대 방향으로 흐르므로 아바타와 말풍선, 액션이 함께 뒤집힙니다. 어느 쪽이든 말하는 쪽에 가까운 모서리가 짧게 잘립니다.

`side`는 `variant`를 정하지 않습니다. 내 메시지를 다른 사람의 메시지와 구분하려면 `variant`를 직접 지정하세요.

<Demo src="chat-bubble/sides">

::: fw react

<<< @/.vitepress/demos/chat-bubble/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/sides.dart

:::

</Demo>

### avatar, name, time

`avatar`는 스레드가 쓰는 크기의 [Avatar](../display/avatar)를 받습니다. `name`과 `time`은 말풍선 위에 한 줄로 놓입니다. 이어지는 메시지에서 둘 다 빼면 세 번의 발언이 아니라 한 번의 발언으로 읽힙니다.

<Demo src="chat-bubble/identity">

::: fw react

<<< @/.vitepress/demos/chat-bubble/identity.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/identity.dart

:::

</Demo>

### status

다섯 단계는 `sending`, `sent`, `delivered`, `read`, `failed`이며, 색을 지니는 것은 `read`와 `failed`뿐입니다. 단계마다 모양도 달라서(`read`는 채운 원 안의 두 겹 체크) 색 없이도 어느 단계인지 보입니다.

그려지는 것은 표식이 전부입니다. 보이지 않는 단어가 스크린 리더에 단계를 알려 주며, `statusLabel`로 그 단어를 바꿀 수 있습니다.

<Demo src="chat-bubble/status">

::: fw react

<<< @/.vitepress/demos/chat-bubble/status.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/status.dart

:::

</Demo>

### typing

`typing`은 메시지 대신 점 세 개를 그립니다. <Fw react="children은" flutter="child는" code /> 건드리지 않으므로, 메시지가 도착하는 순간 같은 말풍선이 그대로 돌아옵니다.

점은 순서대로 불이 들어올 뿐 움직이지 않습니다. 움직임 줄이기 설정에서는 멈추지 않고 더 느리게 켜집니다.

<Demo src="chat-bubble/typing">

::: fw react

<<< @/.vitepress/demos/chat-bubble/typing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/typing.dart

:::

</Demo>

### media

`media`는 텍스트 위에 가장자리까지 채워 그려지고, 말풍선 자신의 모서리가 그것을 잘라 냅니다.

::: fw react

안에 든 `<img>`나 `<video>`는 말풍선 너비에 맞춰 늘어나고, 그 밖의 것은 온 그대로 배치됩니다.

:::

::: fw flutter

넘긴 위젯은 말풍선의 너비를 받습니다. `Image`에는 `BoxFit.cover` 같은 `fit`을 주고, 불러오는 동안에도 자리를 지켜야 한다면 `height`나 `AspectRatio`를 함께 주세요.

:::

<Demo src="chat-bubble/media">

::: fw react

<<< @/.vitepress/demos/chat-bubble/media.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/media.dart

:::

</Demo>

### preview

`preview`는 메시지 속 링크를 텍스트 아래 카드로 펼칩니다. `url`, `title`, `description`, `image`, `site`, 그리고 앱을 벗어나야 하는 링크를 위한 `newTab`을 받습니다. 카드는 채워진 말풍선에서도 비어 있는 말풍선에서도 잘 보입니다.

::: fw react

`rel`은 카드 링크에 그대로 쓰입니다. 미리보기는 대개 다른 사람이 올린 URL이므로, `rel: 'ugc nofollow'`를 주면 검색 엔진에 이 페이지가 고른 링크가 아니라고 알릴 수 있습니다. `newTab`이 켜져 있으면 `rel`에 쓴 값에 `noopener noreferrer`가 더해집니다.

```tsx
<ChatBubble preview={{ url, title, rel: 'ugc nofollow', newTab: true }}>{message}</ChatBubble>
```

:::

::: fw flutter

카드를 눌렀을 때 할 일은 `onPressed`가 정합니다. `newTab`은 링크가 앱 밖으로 나간다는 것을 screen reader에 알릴 뿐이고, 다른 곳에서 여는 일은 콜백의 몫입니다.

```dart
NebaChatBubble(
  preview: NebaChatBubbleLinkPreview(
    url: url,
    onPressed: () => openLink(url),
    title: Text(title),
    newTab: true,
  ),
  child: Text(message),
);
```

:::

<Demo src="chat-bubble/preview">

::: fw react

<<< @/.vitepress/demos/chat-bubble/preview.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/preview.dart

:::

</Demo>

### actions

`actions`는 말풍선 옆에 놓입니다. 대개는 [Menu](../inputs/menu)의 trigger입니다. 줄에 hover가 오거나 안쪽 어딘가가 focus를 받기 전까지는 비켜서 있고, <Fw react="hover가 불가능한 포인터에서는" flutter="hover할 포인터가 없는 Android와 iOS에서는" /> 항상 보입니다.

<Demo src="chat-bubble/actions">

::: fw react

<<< @/.vitepress/demos/chat-bubble/actions.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/actions.dart

:::

</Demo>

### locale

::: fw react

전달 표식과 입력 중 표시는 단어로 읽힙니다. `locale`은 그 단어들의 언어를 정하며, `ko`, `pt-BR`, `zh-Hant` 같은 BCP 47 태그를 받습니다. 번역이 없는 태그는 영어로 돌아갑니다.

```tsx
<ChatBubble side="end" status="read" locale="ko">
  방금 브랜치 올렸어요
</ChatBubble>
```

:::

::: fw flutter

전달 표식과 입력 중 표시는 단어로 읽힙니다. `locale`은 그 단어들의 언어를 정합니다. 생략하면 `NebaProvider`의 것, 그다음 앱의 것을 쓰고, 메시지를 등록하지 않은 언어는 영어로 돌아갑니다.

```dart
const NebaChatBubble(
  side: NebaChatBubbleSide.end,
  status: NebaChatBubbleStatus.read,
  locale: Locale('ko'),
  child: Text('방금 브랜치 올렸어요'),
);
```

:::

## 접근성

- 상태 표식은 글리프이고, 그 뒤의 단어는 screen reader만 닿는 텍스트로 들어갑니다. `locale`을 지정하거나 `statusLabel`에 단어를 직접 쓰세요.
- 입력 중 점은 live region이며, locale의 "입력 중" 단어를 읽어 줍니다.

::: fw react

- ChatBubble은 메시지 하나이지 스레드가 아닙니다. 대화 전체는 페이지에 맞는 마크업으로 감싸세요. 목록이거나, 계속 갱신되는 대화라면 `role="log"`를 가진 컨테이너입니다.
- `media`는 자체 `alt`를 갖지 않습니다. `<img alt="…">`를 직접 넘기거나, 옆의 텍스트가 이미 그림을 설명하고 있다면 빈 `alt`를 쓰세요.
- scheme이 `http`, `https`, `mailto`, `tel`이 아닌 `preview.url`은 카드의 `href`로 쓰지 않으므로, 다른 사용자의 메시지로 만든 미리보기가 `javascript:` 주소를 실행할 수 없습니다.

:::

::: fw flutter

- NebaChatBubble은 메시지 하나이지 스레드가 아닙니다. 대화는 스크롤되는 목록에 담고, 읽는 사람이 다른 곳에 있을 때 도착한 메시지는 직접 알려 주세요.
- `media`는 자체 라벨을 갖지 않습니다. `Image`에 `semanticLabel`을 주거나, 옆의 텍스트가 이미 그림을 설명하고 있다면 `excludeFromSemantics: true`를 주세요.
- scheme이 `http`, `https`, `mailto`, `tel`이 아닌 `preview.url`은 카드의 링크로 screen reader나 브라우저에 넘기지 않으므로, 다른 사용자의 메시지로 만든 미리보기가 `javascript:` 주소를 내밀 수 없습니다.

:::

---
title: ChatBubble
order: 8
flutter: true
---

# ChatBubble

<p class="neba-lede">One message in a conversation. The avatar, the sender's name, the time, the delivery mark, the media above the text and the link card below it are each drawn only when they are given something.</p>

<Demo src="chat-bubble/hero" />

::: fw react

```tsx
import { Avatar, ChatBubble } from 'neba';

<ChatBubble avatar={<Avatar name="Jane Doe" size="sm" />} name="Jane" time="09:41">
  Are we still on for the review at 3?
</ChatBubble>

<ChatBubble side="end" variant="solid" status="read">
  Yes — I pushed the branch just now.
</ChatBubble>;
```

:::

::: fw flutter

```dart
import 'package:neba/neba.dart';

const NebaChatBubble(
  avatar: NebaAvatar(name: 'Jane Doe', size: NebaSize.sm),
  name: Text('Jane'),
  time: Text('09:41'),
  child: Text('Are we still on for the review at 3?'),
);

const NebaChatBubble(
  side: NebaChatBubbleSide.end,
  variant: NebaVariant.solid,
  status: NebaChatBubbleStatus.read,
  child: Text('Yes — I pushed the branch just now.'),
);
```

:::

## Props

<PropsTable name="ChatBubble" />

::: fw react

Every other `<div>` attribute passes through to the row, except `title`.

:::

::: fw flutter

`preview` is a `NebaChatBubbleLinkPreview`. Its `url` is a `Uri` and its `image` an `ImageProvider`; the package opens nothing itself, so the card is a link only when it has an `onPressed`, which calls the router or a URL launcher. There is no `rel`, which is an HTML attribute. The bubble grows no wider than 512 pixels, and the column holding it is as wide as the row it is given.

:::

The shared axes (`variant` `size` `color` `density` `elevation`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### side

`start` is the default and the side the other party's messages usually take, and `end` is the side for your own. `end` runs the row the other way, so the avatar, the bubble and the actions all flip. On either side the corner nearest the speaker is cut short.

`side` does not set `variant`, so set `variant` yourself to tell your own messages from everyone else's.

<Demo src="chat-bubble/sides">

::: fw react

<<< @/.vitepress/demos/chat-bubble/sides.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/sides.dart

:::

</Demo>

### avatar, name and time

`avatar` takes an [Avatar](../display/avatar) at whatever size the thread uses. `name` and `time` sit above the bubble as one line; leave both out on a follow-up message and the run reads as one turn rather than three.

<Demo src="chat-bubble/identity">

::: fw react

<<< @/.vitepress/demos/chat-bubble/identity.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/identity.dart

:::

</Demo>

### status

The five steps are `sending`, `sent`, `delivered`, `read` and `failed`, and only `read` and `failed` carry a colour. Each step is also its own shape, with `read` drawn as the double tick in a filled disc, so the mark says which step it is without the colour.

The mark is the whole of what is drawn. A visually hidden word says the step to a screen reader, and `statusLabel` replaces that word.

<Demo src="chat-bubble/status">

::: fw react

<<< @/.vitepress/demos/chat-bubble/status.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/status.dart

:::

</Demo>

### typing

`typing` draws three dots in place of the message. <Fw react="children" flutter="child" code /> is left alone, so the same bubble goes back to the message the moment it arrives.

The dots light in sequence and never move. Under reduced motion they light more slowly rather than stopping.

<Demo src="chat-bubble/typing">

::: fw react

<<< @/.vitepress/demos/chat-bubble/typing.tsx

:::

::: fw flutter

<<< @/../packages/flutter/example/lib/demos/chat_bubble/typing.dart

:::

</Demo>

### media

`media` is drawn edge to edge above the text, so the bubble's own corners crop it.

::: fw react

An `<img>` or `<video>` inside it is stretched to the width of the bubble; anything else is laid out as it comes.

:::

::: fw flutter

The widget is given the bubble's width. Give an `Image` a `fit` such as `BoxFit.cover`, and a `height` or an `AspectRatio` when the picture should hold its place while it loads.

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

`preview` unfurls a link into a card under the text: `url`, `title`, `description`, `image`, `site`, and `newTab` for the ones that should leave the app. The card works on a filled bubble and a bare one alike.

::: fw react

`rel` is written on the card's link. A preview is usually of a URL somebody else posted, so `rel: 'ugc nofollow'` tells a search engine the page did not choose it. With `newTab`, `noopener noreferrer` is added to whatever `rel` says.

```tsx
<ChatBubble preview={{ url, title, rel: 'ugc nofollow', newTab: true }}>{message}</ChatBubble>
```

:::

::: fw flutter

`onPressed` is what the card does when pressed. `newTab` only tells a screen reader that the link leaves the app; opening it somewhere else is the callback's job.

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

`actions` sits beside the bubble: a [Menu](../inputs/menu) trigger, most of the time. It stays out of the way until the row is hovered or something in it takes focus, and is simply always there <Fw react="on a pointer that cannot hover" flutter="on Android and iOS, which have no pointer to hover with" />.

<Demo src="chat-bubble/actions">

<<< @/.vitepress/demos/chat-bubble/actions.tsx

</Demo>

### locale

::: fw react

The delivery marks and the typing dots are read out as words, and `locale` is which language those words are in: a BCP 47 tag such as `ko`, `pt-BR` or `zh-Hant`. Tags with no translation fall back to English.

```tsx
<ChatBubble side="end" status="read" locale="ko">
  방금 브랜치 올렸어요
</ChatBubble>
```

:::

::: fw flutter

The delivery marks and the typing dots are read out as words, and `locale` is which language those words are in. Left out, it is `NebaProvider`'s, then the app's; a language whose messages were never registered falls back to English.

```dart
const NebaChatBubble(
  side: NebaChatBubbleSide.end,
  status: NebaChatBubbleStatus.read,
  locale: Locale('ko'),
  child: Text('방금 브랜치 올렸어요'),
);
```

:::

## Accessibility

- The status mark is a glyph with the word behind it in text only a screen reader reaches. Set `locale`, or write the word out in `statusLabel`.
- The typing dots are a live region that says the locale's word for typing.

::: fw react

- A ChatBubble is one message, not a thread. Wrap the conversation in the markup the page needs: a list, or a container with `role="log"` for one that keeps updating.
- `media` carries no `alt` of its own: pass a real `<img alt="…">`, or an empty one where the text beside it already says what the picture is.
- A `preview.url` with a scheme other than `http`, `https`, `mailto` or `tel` is not written as the card's `href`, so a preview built from another user's message cannot run a `javascript:` address.

:::

::: fw flutter

- A NebaChatBubble is one message, not a thread. Put the conversation in a scrolling list, and announce a message that arrives while the reader is elsewhere yourself.
- `media` carries no label of its own: give an `Image` a `semanticLabel`, or `excludeFromSemantics: true` where the text beside it already says what the picture is.
- A `preview.url` with a scheme other than `http`, `https`, `mailto` or `tel` is not handed to a screen reader or the browser as the card's link, so a preview built from another user's message cannot offer a `javascript:` address.

:::

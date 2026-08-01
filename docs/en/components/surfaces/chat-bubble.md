---
title: ChatBubble
order: 8
---

# ChatBubble

<p class="neba-lede">One message in a conversation. The avatar, the sender's name, the time, the delivery mark, the media above the text and the link card below it are each drawn only when they are given something.</p>

<Demo src="chat-bubble/hero" />

```tsx
import { Avatar, ChatBubble } from 'neba';

<ChatBubble avatar={<Avatar name="Jane Doe" size="sm" />} name="Jane" time="09:41">
  Are we still on for the review at 3?
</ChatBubble>

<ChatBubble side="end" variant="solid" status="read">
  Yes — I pushed the branch just now.
</ChatBubble>;
```

## Props

<PropsTable name="ChatBubble" />

Every other `<div>` attribute passes through to the row, except `title` — a bubble has no headline, and the browser's tooltip on a whole message is rarely what anyone wants.

The shared axes (`variant` `size` `color` `density` `elevation`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### side

`start` is the default and `end` is the other party. It runs the row the other way — avatar, bubble and actions all flip — and cuts the corner nearest the speaker short, which is what says where the message came from without hanging a tail off the sheet.

`variant` is what tells your own messages from everyone else's, and it is deliberately not tied to `side`: filling the trailing column is a convention, not a law.

<Demo src="chat-bubble/sides">

<<< @/.vitepress/demos/chat-bubble/sides.tsx

</Demo>

### avatar, name and time

`avatar` takes an [Avatar](../display/avatar) at whatever size the thread uses. `name` and `time` sit above the bubble as one line; leave both out on a follow-up message and the run reads as one turn rather than three.

<Demo src="chat-bubble/identity">

<<< @/.vitepress/demos/chat-bubble/identity.tsx

</Demo>

### status

Five steps: `sending`, `sent`, `delivered`, `read` and `failed`. Only the last two carry a colour — a thread where every message is marked in colour is a thread where the colour has stopped meaning anything.

The mark is the whole of what is drawn. The word behind it is read out but never shown; `statusLabel` replaces it.

<Demo src="chat-bubble/status">

<<< @/.vitepress/demos/chat-bubble/status.tsx

</Demo>

### typing

`typing` draws three dots in place of the message. `children` is left alone, so the same bubble goes back to the message the moment it arrives.

The dots light in sequence and never move — colour is the axis every indeterminate indicator in the library uses, and something bouncing in the corner of a thread being read is exactly what the design language has no time for.

<Demo src="chat-bubble/typing">

<<< @/.vitepress/demos/chat-bubble/typing.tsx

</Demo>

### media

`media` is drawn edge to edge above the text, so the bubble's own corners crop it. An `<img>` or `<video>` inside it is stretched to the width of the bubble; anything else is laid out as it comes.

<Demo src="chat-bubble/media">

<<< @/.vitepress/demos/chat-bubble/media.tsx

</Demo>

### preview

`preview` unfurls a link into a card under the text: `url`, `title`, `description`, `image`, `site`, and `newTab` for the ones that should leave the app. The card's surface is mixed out of the bubble's own text colour, so it works on a filled bubble and a bare one alike.

<Demo src="chat-bubble/preview">

<<< @/.vitepress/demos/chat-bubble/preview.tsx

</Demo>

### actions

`actions` sits beside the bubble — a [Menu](../inputs/menu) trigger, most of the time. It stays out of the way until the row is hovered or something in it takes focus, and is simply always there on a pointer that cannot hover.

<Demo src="chat-bubble/actions">

<<< @/.vitepress/demos/chat-bubble/actions.tsx

</Demo>

### locale

The delivery marks and the typing dots are read out as words, and `locale` is which language those words are in — a BCP 47 tag such as `ko`, `pt-BR` or `zh-Hant`. Tags with no translation fall back to English.

```tsx
<ChatBubble side="end" status="read" locale="ko">
  방금 브랜치 올렸어요
</ChatBubble>
```

## Accessibility

- The status mark is a glyph with the word behind it in text only a screen reader reaches. Set `locale`, or write the word out in `statusLabel`.
- A ChatBubble is one message, not a thread. Wrap the conversation in the markup the page needs — a list, or a container with `role="log"` for one that keeps updating.
- `media` carries no `alt` of its own: pass a real `<img alt="…">`, or an empty one where the text beside it already says what the picture is.

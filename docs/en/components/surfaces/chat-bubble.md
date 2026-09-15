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

Every other `<div>` attribute passes through to the row, except `title`.

The shared axes (`variant` `size` `color` `density` `elevation`) are defined in [prop conventions](../../design/prop-conventions).

## Examples

### side

`start` is the default and the side the other party's messages usually take, and `end` is the side for your own. `end` runs the row the other way, so the avatar, the bubble and the actions all flip. On either side the corner nearest the speaker is cut short.

`side` does not set `variant`, so set `variant` yourself to tell your own messages from everyone else's.

<Demo src="chat-bubble/sides">

<<< @/.vitepress/demos/chat-bubble/sides.tsx

</Demo>

### avatar, name and time

`avatar` takes an [Avatar](../display/avatar) at whatever size the thread uses. `name` and `time` sit above the bubble as one line; leave both out on a follow-up message and the run reads as one turn rather than three.

<Demo src="chat-bubble/identity">

<<< @/.vitepress/demos/chat-bubble/identity.tsx

</Demo>

### status

The five steps are `sending`, `sent`, `delivered`, `read` and `failed`, and only `read` and `failed` carry a colour. Each step is also its own shape, with `read` drawn as the double tick in a filled disc, so the mark says which step it is without the colour.

The mark is the whole of what is drawn. A visually hidden word says the step to a screen reader, and `statusLabel` replaces that word.

<Demo src="chat-bubble/status">

<<< @/.vitepress/demos/chat-bubble/status.tsx

</Demo>

### typing

`typing` draws three dots in place of the message. `children` is left alone, so the same bubble goes back to the message the moment it arrives.

The dots light in sequence and never move.

<Demo src="chat-bubble/typing">

<<< @/.vitepress/demos/chat-bubble/typing.tsx

</Demo>

### media

`media` is drawn edge to edge above the text, so the bubble's own corners crop it. An `<img>` or `<video>` inside it is stretched to the width of the bubble; anything else is laid out as it comes.

<Demo src="chat-bubble/media">

<<< @/.vitepress/demos/chat-bubble/media.tsx

</Demo>

### preview

`preview` unfurls a link into a card under the text: `url`, `title`, `description`, `image`, `site`, and `newTab` for the ones that should leave the app. The card works on a filled bubble and a bare one alike.

<Demo src="chat-bubble/preview">

<<< @/.vitepress/demos/chat-bubble/preview.tsx

</Demo>

### actions

`actions` sits beside the bubble: a [Menu](../inputs/menu) trigger, most of the time. It stays out of the way until the row is hovered or something in it takes focus, and is simply always there on a pointer that cannot hover.

<Demo src="chat-bubble/actions">

<<< @/.vitepress/demos/chat-bubble/actions.tsx

</Demo>

### locale

The delivery marks and the typing dots are read out as words, and `locale` is which language those words are in: a BCP 47 tag such as `ko`, `pt-BR` or `zh-Hant`. Tags with no translation fall back to English.

```tsx
<ChatBubble side="end" status="read" locale="ko">
  방금 브랜치 올렸어요
</ChatBubble>
```

## Accessibility

- The status mark is a glyph with the word behind it in text only a screen reader reaches. Set `locale`, or write the word out in `statusLabel`.
- A ChatBubble is one message, not a thread. Wrap the conversation in the markup the page needs: a list, or a container with `role="log"` for one that keeps updating.
- `media` carries no `alt` of its own: pass a real `<img alt="…">`, or an empty one where the text beside it already says what the picture is.
- A `preview.url` with a scheme other than `http`, `https`, `mailto` or `tel` is not written as the card's `href`, so a preview built from another user's message cannot run a `javascript:` address.

import { Avatar, ChatBubble } from 'neba';

export default function ChatBubbleIdentity() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <ChatBubble
        avatar={<Avatar name="Sam Park" size="sm" color="success" />}
        name="Sam Park"
        time="14:02"
      >
        Everything at once: an avatar, a name and a time.
      </ChatBubble>

      <ChatBubble avatar={<Avatar name="Sam Park" size="sm" color="success" />}>
        A follow-up in the same run keeps the avatar and drops the header.
      </ChatBubble>

      <ChatBubble time="14:03">No avatar at all — the bubble takes the whole row.</ChatBubble>
    </div>
  );
}

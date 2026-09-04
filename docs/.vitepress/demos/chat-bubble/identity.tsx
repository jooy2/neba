import { Avatar, ChatBubble } from 'neba';

export default function ChatBubbleIdentity() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <ChatBubble
        avatar={<Avatar src="/samples/people/sam-arden.jpg" name="Sam Arden" size="sm" />}
        name="Sam Arden"
        time="14:02"
      >
        Everything at once: an avatar, a name and a time.
      </ChatBubble>

      <ChatBubble
        avatar={<Avatar src="/samples/people/sam-arden.jpg" name="Sam Arden" size="sm" />}
      >
        A follow-up in the same run keeps the avatar and drops the header.
      </ChatBubble>

      <ChatBubble time="14:03">No avatar at all — the bubble takes the whole row.</ChatBubble>
    </div>
  );
}

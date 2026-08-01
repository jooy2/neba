import { ChatBubble } from 'neba';

export default function ChatBubbleSides() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <ChatBubble>side="start", the default — someone else</ChatBubble>
      <ChatBubble side="end" variant="solid">
        side="end" with variant="solid" — you
      </ChatBubble>
      <ChatBubble side="end" variant="text">
        side="end" on its own, if a filled column is not the house style
      </ChatBubble>
    </div>
  );
}

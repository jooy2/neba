import { ChatBubble, type ChatBubbleStatus } from 'neba';

const STATUSES: ChatBubbleStatus[] = ['sending', 'sent', 'delivered', 'read', 'failed'];

export default function ChatBubbleStatuses() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      {STATUSES.map((status) => (
        <ChatBubble key={status} side="end" variant="solid" status={status}>
          {status}
        </ChatBubble>
      ))}
    </div>
  );
}

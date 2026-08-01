import { ChatBubble } from 'neba';
import { shot } from './thread';

export default function ChatBubbleMedia() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <ChatBubble
        name="Jane"
        time="11:20"
        media={<img src={shot(212, 'site-visit.jpg')} alt="The north elevation" />}
      >
        Here is the north elevation.
      </ChatBubble>

      <ChatBubble
        side="end"
        variant="solid"
        status="delivered"
        media={<img src={shot(28, 'plan.png')} alt="The revised plan" />}
      />
    </div>
  );
}

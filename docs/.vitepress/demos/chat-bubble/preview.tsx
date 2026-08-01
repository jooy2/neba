import { ChatBubble } from 'neba';
import { shot } from './thread';

export default function ChatBubblePreview() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <ChatBubble
        name="Sam"
        time="16:05"
        preview={{
          url: 'https://example.com/acrylic',
          site: 'example.com',
          title: 'Acrylic surfaces, one year on',
          description:
            'What survived contact with real products, what did not, and the two rules we would keep.',
          image: shot(150, 'acrylic'),
          newTab: true
        }}
      >
        This is the one I was talking about
      </ChatBubble>

      <ChatBubble
        side="end"
        variant="solid"
        preview={{
          url: 'https://example.com/rfc-14',
          site: 'example.com',
          title: 'RFC 14 · Cut edges'
        }}
      />
    </div>
  );
}

import { Avatar, ChatBubble } from 'neba';

export default function ChatBubbleHero() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-4">
      <ChatBubble
        avatar={<Avatar src="/samples/people/farah-wells.jpg" name="Farah Wells" size="sm" />}
        name="Farah"
        time="09:41"
      >
        Are we still on for the review at 3?
      </ChatBubble>

      <ChatBubble side="end" variant="solid" time="09:42" status="read">
        Yes — I pushed the branch just now.
      </ChatBubble>

      <ChatBubble
        avatar={<Avatar src="/samples/people/farah-wells.jpg" name="Farah Wells" size="sm" />}
        preview={{
          url: 'https://example.com/rfc-14',
          site: 'example.com',
          title: 'RFC 14 · Acrylic surfaces',
          description: 'Why a Neba surface is a sheet of cut acrylic and not a moulded key.'
        }}
      >
        Read this first
      </ChatBubble>

      <ChatBubble
        avatar={<Avatar src="/samples/people/farah-wells.jpg" name="Farah Wells" size="sm" />}
        typing
      />
    </div>
  );
}

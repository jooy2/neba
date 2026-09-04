import { ChatBubble } from 'neba';

export default function ChatBubbleMedia() {
  return (
    <div className="flex w-full max-w-lg flex-col gap-3">
      <ChatBubble
        name="Farah"
        time="11:20"
        media={
          <img
            src="/samples/photos/curved-wood-reading-nook.jpg"
            alt="The reading nook, lit from one side"
          />
        }
      >
        The nook is in. Photograph from this morning.
      </ChatBubble>

      <ChatBubble
        side="end"
        variant="solid"
        status="delivered"
        media={
          <img
            src="/samples/photos/greenhouse-fern-shadows.jpg"
            alt="Ferns throwing shadows across a glasshouse wall"
          />
        }
      />
    </div>
  );
}
